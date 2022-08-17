pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../IVersionable.sol";


contract Master is IVersionable {

    constructor(TvmCell slave1Code, TvmCell slave2Code) public IVersionable(
        [uint16(1), uint16(2)], [slave1Code, slave2Code]
    ) {}

}
