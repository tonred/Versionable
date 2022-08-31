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

    const Master = await locklift.factory.getContract('Master');
    const Slave1v1 = await locklift.factory.getContract('Slave1v1');
    const Slave2v1 = await locklift.factory.getContract('Slave2v1');

    logger.log('Deploying Master');
    let master = await locklift.giver.deployContract({
        contract: Master,
        constructorParams: {
            owner: owner.address,
            slave1Code: Slave1v1.code,
            slave2Code: Slave2v1.code,
        },
        initParams: {},
        keyPair
    }, locklift.utils.convertCrystal(1, 'nano'));
    await logContract(master);
    migration.store(master, `Master`);
};


main()
    .then(() => process.exit(0))
    .catch(e => {
        console.log(e);
        process.exit(1);
    });
