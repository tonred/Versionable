pragma ton-solidity >= 0.61.2;

import "./IUpgradable.sol";
import "./VersionData.sol";


abstract contract IVersionable {
    event NewVersion(uint16 vid, uint16 version, uint256 hash);

    mapping(uint16 => VersionData) public _versions;

    constructor(uint16[] vids, TvmCell[] codes) internal {
        require(vids.length == codes.length, 69);
        TvmCell empty;
        for (uint16 i = 0; i < codes.length; i++) {
            uint16 vid = vids[i];
            TvmCell code = codes[i];
            uint256 hash = _versionHash(0, code, empty);
            _versions[vid] = VersionData(code, empty, [hash]);
        }
    }

    function _createUpgrade(uint16 vid, TvmCell code, TvmCell params) internal {
        // todo reserve
        require(_versions.exists(vid), 69);
        VersionData data = _versions[vid];
        uint16 version = uint16(data.hashes.length);
        uint256 hash = _versionHash(version, code, params);
        data.code = code;
        data.params = params;
        data.hashes.push(hash);
        _versions[vid] = data;
        emit NewVersion(vid, version, hash);
    }

    function _upgradeSpecific(
        uint16 vid,
        address destination,
        uint16 version,
        TvmCell code,
        TvmCell params,
        address remainingGasTo
    ) internal view {
        require(_versions.exists(vid), 69);
        VersionData data = _versions[vid];
        require(data.hashes.length > version && version != 0, 69);
        uint256 hash = _versionHash(version, code, params);
        require(hash == data.hashes[version], 69);
        _sendUpgrade(destination, version, code, params, remainingGasTo);
    }

    function _upgradeLatest(uint16 vid, address destination, address remainingGasTo) internal view {
        require(_versions.exists(vid), 69);
        VersionData data = _versions[vid];
        // dont unpack in order to optimize gas usage (hashes[] can be huge)
        require(data.hashes.length > 1, 69);
        uint16 version = uint16(data.hashes.length - 1);
        _sendUpgrade(destination, version, data.code, data.params, remainingGasTo);
    }

    function _sendUpgrade(address destination, uint16 version, TvmCell code, TvmCell params, address remainingGasTo) internal pure inline {
        IUpgradable(destination).acceptUpgrade{
            value: 0,
            flag: MsgFlag.REMAINING_GAS,
            bounce: false
        }(version, code, params, remainingGasTo);
    }

    function _versionHash(uint16 version, TvmCell code, TvmCell params) private pure inline returns (uint256) {
        TvmCell union = abi.encode(version, code, params);
        return tvm.hash(union);
    }

}
