pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../BaseSlaveNoPlatform.sol";


contract Slave1v3 is BaseSlaveNoPlatform {
    uint16 constant IS_NOT_OWNER = 1001;

    address public static _owner;
    string public _data;

    constructor() public BaseSlave(1, Version(1, 3)) {}

    function _encodeContractData() internal override returns (TvmCell) {
        return abi.encode(_sid, _version, _data);
    }

    function acceptUpgrade(uint16 sid, Version version, TvmCell code, TvmCell params, address remainingGasTo) public override {
        require(msg.sender == _owner, IS_NOT_OWNER);
        _acceptUpgrade(sid, version, code, params, remainingGasTo);
    }

    function onCodeUpgrade(TvmCell data, Version oldVersion, TvmCell params, address remainingGasTo) internal override {
        (_sid, _version, _data) = abi.decode(data, (uint16, Version, string));
        if (oldVersion.equals(Version(1, 1))) {
            string append = abi.decode(params, string);
            _data += append;
            if (_data == "BUG") {
                _data = "FIX";
            }
        } else if (oldVersion.equals(Version(1, 2))) {
            if (_data == "BUG") {
                _data = "FIX";
            }
        } else {
            revert(ErrorCodes.INVALID_OLD_VERSION);
        }
        tvm.rawReserve(4, 0);
        remainingGasTo.transfer({value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false});
    }

}
