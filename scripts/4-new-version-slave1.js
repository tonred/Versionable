const {
    logContract,
    logger,
    Migration,
    afterRun,
} = require('./utils');


const main = async () => {
    const migration = new Migration();

    const [keyPair] = await locklift.keys.getKeyPairs();
    const owner = migration.load(await locklift.factory.getAccount('Wallet'), 'Account');
    owner.setKeyPair(keyPair);
    owner.afterRun = afterRun;

    const Slave1v2 = await locklift.factory.getContract('Slave1v2');
    const master = migration.load(await locklift.factory.getAccount('Master'), 'Master');

    const params = await owner.call({
        method: 'encodeString',
        params: {
            value: 'Some v2 append value',
        }
    });

    logger.log('Creating new Slave1 version');
    await owner.runTarget({
        contract: master,
        method: 'createNewVersionSlave1',
        params: {
            minor: false,
            code: Slave1v2.code,
            params: params,
        },
        value: locklift.utils.convertCrystal(0.5, 'nano')
    });

    const versionsInfo = await master.call({
        method: 'getSlaveData',
        params: {
            sid: 1,
            version: {
                major: 1,
                minor: 1,
            }
        }
    });
    logger.log(versionsInfo.versionsCount);
};


main()
    .then(() => process.exit(0))
    .catch(e => {
        console.log(e);
        process.exit(1);
    });
