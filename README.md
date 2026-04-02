
## learnt
Reference : https://github.com/RareSkills/Udemy-Yul-Code

add, sub, mul, div, mod, 
for, iszero, not, if, eq,
return(slot num, size) , revert(slot num, size)
sload, sstore, .slot, (( .offset, : (number, value) = number := [0..31] ))
shr, shl :(count, value) [0..255] 
mstore, mload, mstore8, msize(), each slot = 1 byte (mstore(p, value) where p is [0..31]) whereas in sstore each slot is 32 bytes
pop - just throws away the returned b32 value
return(0x00, 0x40) return from 0 to 64 bytes
address() equivalent to address(this)
keccak256(x, y) where x is starting memory slot, y is length

calldatacopy(slot num, start byte num of calldata, calldatasize())
calldataload(slot num) => loads 32 bytes
returndatacopy(p, s, returndatasize()) (p = copying to slot, s = start of returndata bytes)
switch x case y {} default {}

if topic is an indexed element, then no need to store in memory, the topic istlef will print it..,
t0 = mostly the sig of event, other topics max == 3 or 4 if sig is ignored
data in topics non-sig, need not be mstored and logged, the topic istelf will log.., only mstore non indexed data
- log0(p, s) => 0 topics, p = slot pointer, s = size/length
- log1(p, s, t0) => 1 topic, 
- log2(p, s, t0, t1) => 2 topics, 
- log3(p, s, t0, t1, t2) => 3 topics, 
- log4(p, s, t0, t1, t2, t3) => 4 topics, 3


- no overflow protection in yul, like compiler 0.8.0 
- only if, no else exists
- shr == div / 0x10, shl = mul * 0x10 (shifting is gas efficient)
- msize returns max slots in memory being accessed

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
