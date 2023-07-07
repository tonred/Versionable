pragma ton-solidity >= 0.61.2;


library ErrorCodes {

    // Master
    uint16 constant DIFFERENT_LENGTH                    = 12301;
    uint16 constant INVALID_SID                         = 12302;
    uint16 constant INVALID_VERSION                     = 12303;
    uint16 constant CANNOT_CHANGE_LATEST_ACTIVATION     = 12304;
    uint16 constant VERSION_IS_DEACTIVATED              = 12305;
    uint16 constant INVALID_HASH                        = 12306;

    // Slave (user's implementation)
    // Use this code in your custom Slaves when you denied upgrades
    // from specific versions directly to current version
    // For example, deny upgrades from v1.1 to v1.4 directly,
    // but users still can upgrade like v1.1 -> v1.3 -> v1.4
    uint16 constant INVALID_OLD_VERSION                 = 12308;

}
