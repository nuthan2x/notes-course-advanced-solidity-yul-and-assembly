//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

contract Yul {
    uint public x;

    function setX(uint256 _x) external {
        assembly {
            sstore(x.slot, _x)
        }
    }

    function getX() external view returns (uint256 _x) {
        assembly {
            _x := sload(x.slot)
        }
    }
    function getXOffset() external view returns (uint256 y) {
        assembly {
            y := x.offset
        }
    }

    function isPrime(uint256 x) external pure returns (bool y) {
        assembly {
            let halfX := add(div(x, 2), 1)
            for {
                let i := 2
            } lt(i, halfX) {
                i := add(i, 1)
            } {
                if iszero(mod(halfX, i)) {
                    y := false
                    break
                }
            }
        }
    }
}

contract Yul2 {
    uint public x;
    uint128 public p;
    uint16 public m;
    uint48 public n;

    function setM(uint16 val) external {
        assembly {
            let mSlot := sload(m.slot)
            let cleanMslot := and(mSlot, not(shl(mul(m.offset, 8), 0xffff)))
            let shiftedM := shl(mul(m.offset, 8), val)
            sstore(m.slot, or(cleanMslot, shiftedM))
        }
    }
}
