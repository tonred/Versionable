pragma ton-solidity >= 0.61.2;

import "@broxus/contracts/contracts/wallets/Account.sol";


contract Wallet is Account {

    function encodeString(string value) public pure returns (TvmCell) {
        return abi.encode(value);
    }

}
