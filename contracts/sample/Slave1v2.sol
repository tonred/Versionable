pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../BaseSlaveNoPlatform.sol";


contract Slave1v2 is BaseSlaveNoPlatform {
    uint16 constant IS_NOT_OWNER = 1001;

    address public static _owner;
    string public _data;

    modifier onlyOwner() {
        require(msg.sender == _owner, IS_NOT_OWNER);
        _;
    }

    constructor() public onlyOwner {
        _init(1, Version(1, 2));
    }

    function _encodeContractData() internal override returns (TvmCell) {
        return abi.encode(_sid, _version, _data);
    }

    function acceptUpgrade(uint16 sid, Version version, TvmCell code, TvmCell params, address remainingGasTo) public override onlyOwner {
        _acceptUpgrade(sid, version, code, params, remainingGasTo);
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
