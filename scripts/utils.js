const logger = require('mocha-logger');
const BigNumber = require('bignumber.js');
const chai = require('chai');
const fs = require("fs");
chai.use(require('chai-bignumber')());

const {expect} = chai;

const stringToHex = (s) => {
    return Buffer.from(s).toString('hex')
}

const logContract = async (contract) => {
    const balance = await locklift.ton.getBalance(contract.address);
    logger.log(`${contract.name} (${contract.address}) - ${locklift.utils.convertCrystal(balance, 'ton')}`);
};

async function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Due to the network lag, graphql may not catch wallets updates instantly
const afterRun = async (tx) => {
    if (locklift.network === 'dev' || locklift.network === 'prod') {
        await sleep(100000);
    }
    if (locklift.network === 'local') {
        await sleep(1000);
    }
};

class Migration {
    constructor(log_path = 'migration-log.json') {
        this.log_path = log_path;
        this.migration_log = {};
        this.balance_history = [];
        this._loadMigrationLog();
    }

    _loadMigrationLog() {
        if (fs.existsSync(this.log_path)) {
            const data = fs.readFileSync(this.log_path, 'utf8');
            if (data) this.migration_log = JSON.parse(data);
        }
    }

    reset() {
        this.migration_log = {};
        this.balance_history = [];
        this._saveMigrationLog();
    }

    _saveMigrationLog() {
        fs.writeFileSync(this.log_path, JSON.stringify(this.migration_log));
    }

    exists(alias) {
        return this.migration_log[alias] !== undefined;
    }

    load(contract, alias) {
        if (this.migration_log[alias] !== undefined) {
            contract.setAddress(this.migration_log[alias].address);
        } else {
            throw new Error(`Contract ${alias} not found in the migration`);
        }
        return contract;
    }

    store(contract, alias) {
        this.migration_log = {
            ...this.migration_log,
            [alias]: {
                address: contract.address,
                name: contract.name
            }
        }
        this._saveMigrationLog();
    }

    async balancesCheckpoint() {
        const b = {};
        for (let alias in this.migration_log) {
            await locklift.ton.getBalance(this.migration_log[alias].address)
                .then(e => b[alias] = e.toString())
                .catch(e => { /* ignored */
                });
        }
        this.balance_history.push(b);
    }

    async balancesLastDiff() {
        const d = {};
        for (let alias in this.migration_log) {
            const start = this.balance_history[this.balance_history.length - 2][alias];
            const end = this.balance_history[this.balance_history.length - 1][alias];
            if (end !== start) {
                const change = new BigNumber(end).minus(start || 0).shiftedBy(-9);
                d[alias] = change;
            }
        }
        return d;
    }
}

module.exports = {
    logContract,
    afterRun,
    stringToHex,
    logger,
    expect,
    Migration,
};
