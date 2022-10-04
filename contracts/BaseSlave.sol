pragma ton-solidity >= 0.61.2;

import "./utils/Constants.sol";
import "./utils/ErrorCodes.sol";
import "./utils/VersionLibrary.sol";

import "@broxus/contracts/contracts/libraries/MsgFlag.sol";


abstract contract BaseSlave {
    using VersionLibrary for Version;

    event CodeUpgraded(Version oldVersion, Version newVersion);

    uint16 public _sid;
    Version public _version;

    function _initVersion(uint16 sid, Version version) internal {
        _sid = sid;
        _version = version;
    }

    function getSID() public view responsible virtual returns (uint16 sid) {
        return {value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false} _sid;
    }

    function getVersion() public view responsible virtual returns (Version version) {
        return {value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false} _version;
    }

    // Check sender in implementation
    function acceptUpgrade(uint16 sid, Version version, TvmCell code, TvmCell params, address remainingGasTo) public virtual;

    function _acceptUpgrade(uint16 sid, Version version, TvmCell code, TvmCell params, address remainingGasTo) internal {
        if (sid != _sid || version.compare(_version) != 1) {
            remainingGasTo.transfer({value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false});
            return;
        }
        Version oldVersion = _version;
        _version = version;
        emit CodeUpgraded(oldVersion, version);
        TvmCell data = _encodeContractData();
        tvm.setcode(code);
        tvm.setCurrentCode(code);
        _onCodeUpgrade(data, oldVersion, params, remainingGasTo);
    }

    function _encodeContractData() internal virtual returns (TvmCell);

    // This is wrapper around `onCodeUpgrade` function because
    // contract can be a Platform with own `onCodeUpgrade` function
    function _onCodeUpgrade(TvmCell data, Version oldVersion, TvmCell params, address remainingGasTo) internal virtual;

}
