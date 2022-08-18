pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../BaseSlave.sol";


contract Slave1v2 is BaseSlave {

    string public _data;

    constructor() public BaseSlave(1, Version(1, 2)) {}

    function _encodeContractData() internal override returns (TvmCell) {
        return abi.encode(_sid, _version, _data);
    }

    function onCodeUpgrade(TvmCell data, Version oldVersion, TvmCell params, address remainingGasTo) internal override {
        (_sid, _version, _data) = abi.decode(data, (uint16, Version, string));
        if (oldVersion.equals(Version(1, 1))) {
            string append = abi.decode(params, string);
            _data += append;
        // } else if (oldVersion.equals(Version(1, 2))) { ...
        } else {
            revert(ErrorCodes.INVALID_OLD_VERSION);
        }
        tvm.rawReserve(4, 0);
        remainingGasTo.transfer({value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false});
    }

}
