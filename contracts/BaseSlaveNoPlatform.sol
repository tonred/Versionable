pragma ton-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "./BaseSlave.sol";


abstract contract BaseSlaveNoPlatform is BaseSlave {

    function _onCodeUpgrade(TvmCell data, Version oldVersion, TvmCell params, address remainingGasTo) internal override {
        onCodeUpgrade(data, oldVersion, params, remainingGasTo);
    }

    function onCodeUpgrade(TvmCell data, Version oldVersion, TvmCell params, address remainingGasTo) internal virtual;

}
