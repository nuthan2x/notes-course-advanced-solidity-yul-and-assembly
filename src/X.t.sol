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
}
