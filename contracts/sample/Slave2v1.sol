pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../BaseSlave.sol";
import "../utils/Constants.sol";


contract Slave2v1 is BaseSlave {

    uint256 public _data;

    constructor() public BaseSlave(2, Version(Constants.INITIAL_MINOR, Constants.INITIAL_MAJOR)) {}

    function _encodeContractData() internal override returns (TvmCell) {
        return abi.encode(_sid, _version, _data);
    }

    // There is no possibility to upgrade to 0's version
    function onCodeUpgrade(TvmCell /*data*/, Version /*oldVersion*/, TvmCell /*params*/, address /*remainingGasTo*/) internal override {
        revert(ErrorCodes.INVALID_OLD_VERSION);
    }

}
