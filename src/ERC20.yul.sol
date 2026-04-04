
object "Token" {
    code {
        sstore(0, caller())
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime" {
        code {
            // requireCondition(iszero(callvalue()))
            if callvalue() {revert(0,0)}

            switch selector()
            case 0x70a08231 /* "balanceOf(address)" */ {
                returnAsUint(balanceOf(decodeAddress(0)))
            }
            case 0x18160ddd /* "totalSupply()" */ {
                returnAsUint(totalSupply())
            }
            case 0xa9059cbb /* "transfer(address,uint256)" */ {
                transfer(decodeAddress(0), decodeCalldataSlot(1))
                returnTrue()
            }
            case 0x23b872dd /* "transferFrom(address,address,uint256)" */ {
                transferFrom(decodeAddress(0), decodeAddress(1), decodeCalldataSlot(2))
                returnTrue()
            }
            case 0x095ea7b3 /* "approve(address,uint256)" */ {
                approve(decodeAddress(0), decodeCalldataSlot(1))
                returnTrue()
            }
            case 0xdd62ed3e /* "allowance(address,address)" */ {
                returnAsUint(allowance(decodeAddress(0), decodeAddress(1)))
            }
            case 0x40c10f19 /* "mint(address,uint256)" */ {
                mint(decodeAddress(0), decodeCalldataSlot(1))
                returnTrue()
            }
            default {
                revert(0,0)
            }

            function mint(to, amount) {
                requireCondition(calledByOwner())
                mintTokens(to, amount)
                addToBalance(to, amount)
                emitTransfer(0, to, amount)
            }
            function approve(to, amount) {
                revertIfZeroAddress(to)
                setAllowance(caller(), to, amount)
                emitApproval(caller(), to, amount)
            }
            
            function transfer(to, amount) {
                executeTransfer(caller(), to, amount)
            }
            function transferFrom(from, to, amount) {
                decreaseAllowanceBy(from, caller(), amount)
                executeTransfer(from, to, amount)
            }
            function executeTransfer(from, to, amount) {
                revertIfZeroAddress(to)

                deductBalance(from, amount)
                addToBalance(to, amount)
                emitTransfer(from, to, amount)
            }

            /* ---------- calldata decoding functions ----------- */
            function selector() -> s {
                s := shr(mul(28, 8), calldataload(0))
            }
            function decodeAddress(slotNum) -> r {
                r := decodeCalldataSlot(slotNum)
                if shr(mul(20, 8), r) {revert(0,0)}
            }
            function decodeCalldataSlot(slotNum) -> r {
                let start := add(4, mul(slotNum, 32))
                requireCondition(lte(add(start, 32), calldatasize()))
                r := calldataload(start)
            }

            /* ---------- calldata encoding functions ---------- */
            function returnAsUint(v) {
                mstore(0, v)
                return(0, 0x20)
            }
            function returnTrue() {
                returnAsUint(1)
            }

            /* -------- events ---------- */
            function emitTransfer(from, to, amount) {
                let sig := 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
                emitEvent(sig, from, to, amount)  
            }
            function emitApproval(from, to, amount) {
                let sig := 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
                emitEvent(sig, from, to, amount)  
            }
            function emitEvent(sig, top1, top2, data1) {
                mstore(0, data1)
                log3(0, 0x20, sig, top1, top2)
            }
        
            /* -------- storage layout ---------- */
            function ownerPos() -> s {s := 0}
            function totalSupplyPos() -> s {s := 1}
            function accountToStorageOffset(account) -> s {
                s := add(0x1000, account)
            }
            function allowancePos(owner, spender) -> s {
                mstore(0, accountToStorageOffset(owner))
                mstore(0x20, spender)
                s := keccak256(0, 0x40)
            }

            /* -------- storage access ---------- */
            function owner() -> r {
                r:= sload(ownerPos())
            }
            function totalSupply() -> r {
                r:= sload(totalSupplyPos())
            }
            function balanceOf(account) -> r {
                r:= sload(accountToStorageOffset(account))
            }
            function allowance(owner, spender) -> r {
                r:= sload(allowancePos(owner, spender))
            }

            function mintTokens(account, amount) {
                sstore(totalSupplyPos(), safeAdd(totalSupply(), amount))
            }
            function addToBalance(account, amount) {
                sstore(accountToStorageOffset(account), safeAdd(balanceOf(account), amount))
            }
            function deductBalance(account, amount) {
                let bal := balanceOf(account)
                requireCondition(lte(amount, bal))
                sstore(accountToStorageOffset(account), sub(bal, amount))
            }
            function setAllowance(account, spender, amount) {
                sstore(allowancePos(account, spender), amount)
            }
            function decreaseAllowanceBy(account, spender, amount) {
                let allowance := allowance(account, spender)
                requireCondition(gte(allowance, amount))
                setAllowance(account, spender, sub(allowance, amount))
            }

            /* ---------- utility functions ---------- */
            function lte(a, b) -> r {
                r := iszero(gt(a, b))
            }
            function gte(a, b) -> r {
                r := iszero(lt(a, b))
            }
            function safeAdd(a, b) -> r {
                r := add(a, b)
                if or(lt(r, a), lt(r, b)) {revert(0,0)}
            }

            function calledByOwner() -> r {
                r := eq(caller(), owner())
            }
            function revertIfZeroAddress(addr) {
                requireCondition(addr)
            }
            function requireCondition(condition) {
                if iszero(condition) {revert(0, 0)}
            }

        }
    }
}