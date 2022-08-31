pragma ton-solidity >= 0.61.2;

import "./utils/Constants.sol";
import "./BaseSlave.sol";


abstract contract BaseMaster {
    event NewVersion(uint16 sid, Version version, uint256 hash, bool initial);
    event SetActivation(Version version, bool active);

    // cannot be public due to "ABIEncoderV2" exception
    mapping(uint16 /*sid*/ => SlaveData) _slaves;


    constructor(uint16[] sids, TvmCell[] codes, bool withTvmAccept) internal {
        require(sids.length == codes.length, ErrorCodes.DIFFERENT_LENGTH);
        if (withTvmAccept) {
            // credit funds is not enough for constructor is case of external message
            tvm.accept();
        }
        TvmCell empty;
        for (uint16 i = 0; i < sids.length; i++) {
            uint16 sid = sids[i];
            TvmCell code = codes[i];
            Version version = Version(Constants.INITIAL_MINOR, Constants.INITIAL_MAJOR);
            uint256 hash = _versionHash(version, code, empty);
            mapping(Version => VersionData) versions = emptyMap;
            versions[version] = VersionData(hash, false);  // disallow upgrading to initial version
            _slaves[sid] = SlaveData(code, empty, version, /*versionsCount*/ 1, versions);
            emit NewVersion(sid, version, hash, true);
        }
    }

    // cannot create getter for `_slave` because mapping key in getter cannot be `Version` type

    function getSIDs() public view responsible virtual returns (uint16[] sids) {
        return {value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false} _slaves.keys();
    }

    function getSlaveData(uint16 sid) public view responsible virtual returns (
        TvmCell code, TvmCell params, Version latest, uint32 versionsCount
    ) {
        require(_slaves.exists(sid), ErrorCodes.INVALID_SID);
        SlaveData data = _slaves[sid];
        return {value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false} (
            data.code, data.params, data.latest, data.versionsCount
        );
    }

    function getSlaveVersions(uint16 sid) public view responsible virtual returns (Version[] versions) {
        require(_slaves.exists(sid), ErrorCodes.INVALID_SID);
        return {value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false} _slaves[sid].versions.keys();
    }

    function getSlaveVersion(uint16 sid, Version version) public view responsible virtual returns (VersionData data) {
        require(_slaves.exists(sid), ErrorCodes.INVALID_SID);
        mapping(Version => VersionData) versions = _slaves[sid].versions;
        require(versions.exists(version), ErrorCodes.INVALID_VERSION);
        return {value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false} versions[version];
    }


    function _createNewVersion(uint16 sid, bool minor, TvmCell code, TvmCell params) internal {
        require(_slaves.exists(sid), ErrorCodes.INVALID_SID);
        SlaveData data = _slaves[sid];
        Version version = _calcNewVersion(data.latest, minor);
        uint256 hash = _versionHash(version, code, params);
        data.code = code;
        data.params = params;
        data.latest = version;
        data.versionsCount++;
        data.versions[version] = VersionData(hash, true);
        _slaves[sid] = data;
        emit NewVersion(sid, version, hash, false);
    }

    function _calcNewVersion(Version latest, bool minor) internal pure returns (Version) {
        if (minor) {
            Version version = latest;
            version.minor++;
            return version;
        } else {
            return Version(latest.major + 1, Constants.INITIAL_MINOR);
        }
    }

    function _setVersionActivation(uint16 sid, Version version, bool active) internal view {
        require(_slaves.exists(sid), ErrorCodes.INVALID_SID);
        SlaveData data = _slaves[sid];
        require(data.versions.exists(version), ErrorCodes.INVALID_VERSION);
        require(VersionLibrary.compare(data.latest, version) == 1, ErrorCodes.CANNOT_CHANGE_LATEST_ACTIVATION);
        data.versions[version].active = active;
        emit SetActivation(version, active);
    }


    function _upgradeToSpecific(
        uint16 sid,
        address destination,
        Version version,
        TvmCell code,
        TvmCell params,
        address remainingGasTo
    ) internal view {
        require(_slaves.exists(sid), ErrorCodes.INVALID_SID);
        SlaveData data = _slaves[sid];
        require(data.versions.exists(version), ErrorCodes.INVALID_VERSION);
        (uint256 expectedHash, bool active) = data.versions[version].unpack();
        require(active, ErrorCodes.VERSION_IS_DEACTIVATED);
        uint256 hash = _versionHash(version, code, params);
        require(hash == expectedHash, ErrorCodes.INVALID_HASH);
        _sendUpgrade(destination, version, code, params, remainingGasTo);
    }

    function _upgradeToLatest(uint16 sid, address destination, address remainingGasTo) internal view {
        require(_slaves.exists(sid), ErrorCodes.INVALID_SID);
        SlaveData data = _slaves[sid];
        require(data.versionsCount > 1, ErrorCodes.NO_NEW_VERSIONS);
        // dont unpack `data` in order to optimize gas usage (versions[] can be huge)
        _sendUpgrade(destination, data.latest, data.code, data.params, remainingGasTo);
    }

    function _sendUpgrade(address destination, Version version, TvmCell code, TvmCell params, address remainingGasTo) internal pure inline {
        BaseSlave(destination).acceptUpgrade{
            value: 0,
            flag: MsgFlag.REMAINING_GAS,
            bounce: false
        }(version, code, params, remainingGasTo);
    }

    function _getLatestCode(uint16 sid) internal view returns (TvmCell) {
        require(_slaves.exists(sid), ErrorCodes.INVALID_SID);
        return _slaves[sid].code;
    }


    function _versionHash(Version version, TvmCell code, TvmCell params) private pure inline returns (uint256) {
        TvmCell union = abi.encode(version, code, params);
        return tvm.hash(union);
    }

}
