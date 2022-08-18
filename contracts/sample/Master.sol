pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../BaseMaster.sol";


contract Master is BaseMaster {

    constructor(TvmCell slave1Code, TvmCell slave2Code) public BaseMaster(
        [uint16(1), uint16(2)], [slave1Code, slave2Code]
    ) {}

}
