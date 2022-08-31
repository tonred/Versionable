const {
    logContract,
    Migration,
    logger
} = require('./utils');


const main = async () => {
    const migration = new Migration();
    const [keyPair] = await locklift.keys.getKeyPairs();
    const Account = await locklift.factory.getAccount('Wallet');

    logger.log('Deploying account');
    let account = await locklift.giver.deployContract({
        contract: Account,
        constructorParams: {},
        initParams: {
            randomNonce: locklift.utils.getRandomNonce(),
        },
        keyPair
    }, locklift.utils.convertCrystal(10, 'nano'));
    await logContract(account);
    migration.store(account, `Account`);
};


main()
    .then(() => process.exit(0))
    .catch(e => {
        console.log(e);
        process.exit(1);
    });
