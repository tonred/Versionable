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
    const master = migration.load(await locklift.factory.getAccount('Master'), 'Master');

    logger.log('Deploying Slave1 for account');
    await owner.runTarget({
        contract: master,
        method: 'deploySlave1',
        params: {},
        value: locklift.utils.convertCrystal(0.5, 'nano')
    });
    const slave1Address = await master.call({
        method: 'expectedSlave1Address',
        params: {
            owner: owner.address,
        }
    });
    logger.log('Slave1 address:', slave1Address);
};


main()
    .then(() => process.exit(0))
    .catch(e => {
        console.log(e);
        process.exit(1);
    });
