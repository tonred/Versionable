pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../BaseSlaveNoPlatform.sol";
import "../utils/Constants.sol";


contract Slave1v1 is BaseSlaveNoPlatform {
    uint16 constant IS_NOT_OWNER = 1001;

    address public static _owner;
    string public _data;

    modifier onlyOwner() {
        require(msg.sender == _owner, IS_NOT_OWNER);
        _;
    }

    constructor() public onlyOwner {
        _init(1, Version(Constants.INITIAL_MINOR, Constants.INITIAL_MAJOR));
    }

    function _encodeContractData() internal override returns (TvmCell) {
        return abi.encode(_sid, _version, _data);
    }

    function acceptUpgrade(uint16 sid, Version version, TvmCell code, TvmCell params, address remainingGasTo) public override onlyOwner {
        _acceptUpgrade(sid, version, code, params, remainingGasTo);
    }

    // There is no possibility to upgrade to 0's version
    function onCodeUpgrade(TvmCell /*data*/, Version /*oldVersion*/, TvmCell /*params*/, address /*remainingGasTo*/) internal override {
        revert(ErrorCodes.INVALID_OLD_VERSION);
    }

}
