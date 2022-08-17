pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../IUpgradable.sol";


contract Slave2v0 is IUpgradable {

    uint256 public _data;

    constructor() public IUpgradable(2, 0) {}

    function _encodeContractData() internal override returns (TvmCell) {
        return abi.encode(_vid, _version, _data);
    }

    // There is no possibility to upgrade to 0's version
    function onCodeUpgrade(TvmCell /*data*/, uint16 /*oldVersion*/, TvmCell /*params*/, address /*remainingGasTo*/) internal override {
        revert(69);
    }

}
