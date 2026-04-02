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

    function isPrime(uint256 _x) external pure returns (bool y) {
        assembly {
            let halfX := add(div(_x, 2), 1)
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

contract StorageComplex {
    uint256[3] public fixedArray;
    uint256[] bigArray;
    uint8[] smallArray;

    mapping(uint256 => uint256) public myMapping;
    mapping(uint256 => mapping(uint256 => uint256)) public nestedMapping;
    mapping(address => uint256[]) public addressToList;

    constructor() {
        fixedArray = [99, 999, 9999];
        bigArray = [10, 20, 30, 40];
        smallArray = [1, 2, 3];

        myMapping[10] = 5;
        myMapping[11] = 6;
        nestedMapping[2][4] = 7;

        addressToList[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = [
            42,
            1337,
            777
        ];
    }

    function addressToListLocation(
        address key,
        uint index
    ) external view returns (uint8 r) {
        uint slot;
        assembly {
            slot := addressToList.slot
        }
        bytes32 location = keccak256(
            abi.encode(keccak256(abi.encode(key, slot)), index)
        );

        assembly {
            r := sload(location)
        }
    }

    function nestedMappingLocation(
        uint256 key1,
        uint key2
    ) external view returns (uint8 r) {
        uint slot;
        assembly {
            slot := nestedMapping.slot
        }
        bytes32 location = keccak256(
            abi.encode(key2, keccak256(abi.encode(key1, slot)))
        );

        assembly {
            r := sload(location)
        }
    }

    function myMappingLocation(uint256 key) external view returns (uint8 r) {
        uint slot;
        assembly {
            slot := myMapping.slot
        }
        bytes32 location = keccak256(abi.encode(key, slot));

        assembly {
            r := sload(location)
        }
    }

    function set_fixedArray(uint a, uint b, uint c) public {
        assembly {
            let slot := fixedArray.slot
            sstore(slot, a)
            sstore(add(slot, 1), b)
            sstore(add(slot, 2), c)
        }
    }

    function get_bigArraylength() public view returns (uint l) {
        assembly {
            l := sload(bigArray.slot)
        }
    }
    function get_bigArray(uint index) public view returns (uint v) {
        uint slot;

        assembly {
            slot := bigArray.slot
        }

        bytes32 location = keccak256(abi.encode(slot));

        assembly {
            v := sload(add(location, index))
        }
    }

    function readSmallArrayLen() external view returns (uint256 l) {
        assembly {
            l := sload(smallArray.slot)
        }
    }

    function readSmallArrayLocation(
        uint256 index
    ) external view returns (uint8 r) {
        uint slot;
        assembly {
            slot := smallArray.slot
        }
        bytes32 location = keccak256(abi.encode(slot));

        assembly {
            r := and(
                0xff,
                shr(
                    mul(mod(index, 32), 8),
                    sload(add(location, div(index, 32)))
                )
            )
        }
    }

    event Debug(bytes32, bytes32, bytes32, bytes32);
    function args(uint256[] memory arr) external {
        bytes32 location;
        bytes32 len;
        bytes32 valueAtIndex0;
        bytes32 valueAtIndex1;
        assembly {
            location := arr // 0x80
            len := mload(arr) // mload(0x80)
            valueAtIndex0 := mload(add(arr, 0x20)) // mload(0xa0)
            valueAtIndex1 := mload(add(arr, 0x40)) // mload(0xc0)
            // ...
        }
        emit Debug(location, len, valueAtIndex0, valueAtIndex1);
    }


    function xx() public pure returns(uint ,uint) {
        assembly {
            mstore(0x00, 2)
            mstore(0x20, 9)
            return(0x00, 0x40)
        }
    }

     function yy(address m) public view  {
        assembly {
            if iszero(eq(m, address())) {revert(0,0)}
            
            
        }
    }

    function zz() public pure returns(bytes32) {
        assembly {
            let pointer := mload(0x60)

            mstore(pointer, 2)
            mstore(add(pointer, 0x20), 4)

            mstore(0x0, keccak256(pointer, 0x40))

            return(0x0, 0x40)
        }
    }

    event A();
    event A1(uint a);
    event A2(uint indexed a);
    event B1(uint a, uint128 b);
    event B2(uint indexed a, uint128 b);
    
    event C1(uint a, uint128 b, uint c);
    event C2(uint indexed a, uint128 b, uint c);

    event D1(uint indexed a, uint128 indexed b, uint indexed c, uint d);

    function emitter() public {
        emit A();
        bytes32 sig = keccak256("A()");
        assembly {
            log1(0, 0, sig)
        }

        emit A1(1);
        sig = keccak256("A1(uint256)");
        assembly {
            mstore(0x0, 1)
            log1(0x0, 0x20, sig)
        }

        emit A2(2);
        sig = keccak256("A2(uint256)");
        assembly {
            log2(0, 0, sig, 2)
        }
        emit B1(1, 2);

        sig = keccak256("B1(uint256,uint128)");
        assembly {
            mstore(0x0, 1)
            mstore(0x20, 2)
            log1(0x0, 0x40, sig)
        }

        emit B2(1, 2);
        sig = keccak256("B2(uint256,uint128)");
        assembly {
            mstore(0x0, 2)
            log2(0x0, 0x20, sig, 1)
        }

        emit C1(1, 2, 3);
        sig = keccak256("C1(uint256,uint128,uint256)");
        assembly {
            let ptr := mload(0x40) // read actual free memory pointer
            mstore(ptr, 1) // a=1
            mstore(add(ptr, 0x20), 2) // b=2
            mstore(add(ptr, 0x40), 3) // c=3
            log1(ptr, 0x60, sig) // log 96 bytes, topic0=sig
        }

        emit C2(1, 2, 3);
        sig = keccak256("C2(uint256,uint128,uint256)");
        assembly {
            mstore(0x0, 2)
            mstore(0x20, 3)
            log2(0x0, 0x40, sig, 1)
        }

        emit D1(1, 2, 3, 4);
        sig = keccak256("D1(uint256,uint128,uint256,uint256)");
        assembly {
            mstore(0x0, 4)
            log4(0x0, 0x20, sig, 1, 2, 3)
        }
    }

    function calls() public {
        bytes4 sig = bytes4(keccak256("yy(address)"));

        assembly {
            let pointer := mload(0x40)
            mstore(add(pointer, 28), sig)
            mstore(add(pointer, 0x20), address())
            pop(staticcall(gas(), address(), add(pointer, 28), add(4 , 0x20), 0, 0))
        }

        sig = bytes4(keccak256("set_fixedArray(uint256,uint256,uint256)"));

        assembly {
            let pointer := mload(0x40)
            mstore(add(pointer, 28), sig)
            mstore(add(pointer, 0x20), 1)
            mstore(add(pointer, 0x40), 2)
            mstore(add(pointer, 0x60), 3)
            let result := call(gas(), address(), 0, add(pointer, 28), add(4, 0x60), 0, 0)

            returndatacopy(0, 0, returndatasize())
            if iszero(result) {
                revert(0, returndatasize())
            }
            return(0, returndatasize())
        }

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), address(), 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result 
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

}




object "Simple" {
    code {
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))        
    }

    object "runtime" {
        
        code {
            datacopy(0x00, dataoffset("Message"), datasize("Message"))
            return(0x00, datasize("Message"))
        }

        data "Message" "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt"
    }
}