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

    let slaveAddress = '0:ba8964312707666f49411b09c2289ffd48f4de77f054298cccc800404197e351'
    // todo no way to check if slave1 has new data via locklift 1.4.5...
    logger.log('Slave address:', slaveAddress, '(replace with your address in code!)');
    await owner.runTarget({
        contract: master,
        method: 'upgradeSlave1',
        params: {
            destination: slaveAddress,
        },
        value: locklift.utils.convertCrystal(0.5, 'nano')
    })

    master.address = slaveAddress;
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
