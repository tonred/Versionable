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

    await owner.runTarget({
        contract: master,
        method: 'upgradeSlave1',
        params: {
            destination: '0:897cf9b13c55cc60441abf8d7e7bda959cece51c51b25a5f998cfd586994da65',
        },
        value: locklift.utils.convertCrystal(0.5, 'nano')
    })

    // todo no way to check if slave1 has new data via locklift 1.4.5...
    master.address = '0:897cf9b13c55cc60441abf8d7e7bda959cece51c51b25a5f998cfd586994da65';
    master.abi = Slave1v2.abi;
    master.code = Slave1v2.code;
    const data = await master.call({
        method: '_data',
        params: {},
    });
    logger.log('Data:', data);

    // const slave1 = await locklift.factory.getDeployedContract(
    //     'Slave1', // name of your contract
    //     slave1Address,
    // );
    // const data = await slave1.call({
    //     method: '_data',
    //     params: {},
    // });
    // logger.log(data);
};


main()
    .then(() => process.exit(0))
    .catch(e => {
        console.log(e);
        process.exit(1);
    });
