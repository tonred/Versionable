pragma ton-solidity >= 0.61.2;

import "@broxus/contracts/contracts/libraries/MsgFlag.sol";


abstract contract IUpgradable {
    event CodeUpgraded(uint16 oldVersion, uint16 newVersion);

    uint16 public _vid;
    uint16 public _version;

    constructor(uint16 vid, uint16 version) internal {
        _vid = vid;
        _version = version;
    }

    function acceptUpgrade(uint16 version, TvmCell code, TvmCell params, address remainingGasTo) external virtual {
        if (version == _version) {
            remainingGasTo.transfer({value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false});
            return;
        }
        uint16 oldVersion = _version;
        _version = version;
        emit CodeUpgraded(oldVersion, version);  // todo reserve
        TvmCell data = _encodeContractData();
        tvm.setcode(code);
        tvm.setCurrentCode(code);
        onCodeUpgrade(data, oldVersion, params, remainingGasTo);
    }

    function _encodeContractData() internal virtual returns (TvmCell);

    function onCodeUpgrade(TvmCell data, uint16 oldVersion, TvmCell params, address remainingGasTo) internal virtual;

}
