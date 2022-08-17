pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../IUpgradable.sol";


contract Slave1v1 is IUpgradable {

    string public _data;

    constructor() public IUpgradable(1, 1) {}

    function _encodeContractData() internal override returns (TvmCell) {
        return abi.encode(_vid, _version, _data);
    }

    function onCodeUpgrade(TvmCell data, uint16 oldVersion, TvmCell params, address remainingGasTo) internal override {
        (_vid, _version, _data) = abi.decode(data, (uint16, uint16, string));
        if (oldVersion == 0) {
            (_vid, _version) = abi.decode(data, (uint16, uint16));
            string append = abi.decode(params, string);
            _data += append;
        // else if (oldVersion == 1) ...
        } else {
            revert(69);
        }
        remainingGasTo.transfer({value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false});
    }

}
