pragma ton-solidity >= 0.61.2;


struct VersionData {
    TvmCell code;
    TvmCell params;
    uint256[] hashes;
}
