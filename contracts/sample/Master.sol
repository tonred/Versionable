pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../BaseMaster.sol";
import "./Slave1v1.sol";

import "@broxus/contracts/contracts/access/InternalOwner.sol";
import "@broxus/contracts/contracts/utils/RandomNonce.sol";


contract Master is BaseMaster, InternalOwner, RandomNonce {

    modifier cashBack() {
        tvm.rawReserve(4, 0);
        _;
        msg.sender.transfer({value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false});
    }

    constructor(address owner, TvmCell slave1Code, TvmCell slave2Code) public BaseMaster(
        [uint16(1), uint16(2)], [slave1Code, slave2Code], true
    ) {
        setOwnership(owner);
    }

    function expectedSlave1Address(address owner) public view responsible returns (address slave1) {
        slave1 = address(tvm.hash(_buildSlave1StateInit(owner)));
        return {value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false} slave1;
    }

    function deploySlave1() public view cashBack {
        TvmCell stateInit = _buildSlave1StateInit(msg.sender);
        new Slave1v1{
            stateInit: stateInit,
            value: 0.5 ton,
            flag: MsgFlag.SENDER_PAYS_FEES,
            bounce: false
        }();
    }

    function createNewVersionSlave1(bool minor, TvmCell code, TvmCell params) public onlyOwner cashBack {
        _createNewVersion(1, minor, code, params);
    }

    function upgradeSlave1(address destination) public view {
        _upgradeToLatest(1, destination, msg.sender);
    }


    function _buildSlave1StateInit(address owner) private view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: Slave1v1,
            varInit: {
                _owner: owner
            },
            code: _getLatestCode(1)
        });
    }

}
