pragma ton-solidity >= 0.61.2;


struct SlaveData {
    TvmCell code;
    TvmCell params;
    Version latest;
    uint32 versionsCount;
    mapping(Version => VersionData) versions;
}

struct Version {
    uint32 major;
    uint32 minor;
}

struct VersionData {
    uint256 hash;
    bool active;
}
