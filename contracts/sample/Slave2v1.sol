pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../BaseSlaveNoPlatform.sol";
import "../utils/Constants.sol";


contract Slave2v1 is BaseSlaveNoPlatform {
    uint16 constant IS_NOT_MASTER = 1001;

    address public static _master;
    address public static _owner;
    uint256 public _data;

    modifier onlyMaster() {
        require(msg.sender == _master, IS_NOT_MASTER);
        _;
    }

    constructor() public onlyMaster {
        _initVersion(2, Version(Constants.INITIAL_MINOR, Constants.INITIAL_MAJOR));
    }

    function acceptUpgrade(uint16 sid, Version version, TvmCell code, TvmCell params, address remainingGasTo) public override onlyMaster {
        _acceptUpgrade(sid, version, code, params, remainingGasTo);
    }

    function _encodeContractData() internal override returns (TvmCell) {
        return abi.encode(_sid, _version, _data);
    }

    // There is no possibility to upgrade to 0's version
    function onCodeUpgrade(TvmCell /*data*/, Version /*oldVersion*/, TvmCell /*params*/, address /*remainingGasTo*/) internal override {
        revert(ErrorCodes.INVALID_OLD_VERSION);
    }

}
