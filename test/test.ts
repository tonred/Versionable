import {expect} from "chai";
import {Address, Contract, fromNano, Signer, toNano, TraceType, WalletTypes} from "locklift";
import {FactorySource} from "../build/factorySource";
import {log} from "mocha-logger"
import {Account} from "everscale-standalone-client/nodejs";

const STRING_DATA_V2 = "Some v2 append value";

const contracts = [
  'Master',
  'Slave1v1',
  'Slave2v1',
]

let signer: Signer;
let account: Account;
let master: Contract<FactorySource["Master"]>;
let slave: Contract<FactorySource["Slave1v1"] | FactorySource["Slave1v2"]>;

describe("Test Versionable contracts", async function () {
  before(async () => {
    signer = await locklift.keystore.getSigner("0");
    const {account: contract} = await locklift.factory.accounts.addNewAccount({
      type: WalletTypes.EverWallet,
      value: toNano(10),
      publicKey: signer.publicKey,
    });
    account = contract;
  });

  it("Load contract factory", async function () {
    for (let name of contracts) {
      const contract = await locklift.factory.getContractArtifacts(name);
      expect(contract.code).not.to.equal(undefined, `Code should be available for contract: ${name}`);
      expect(contract.abi).not.to.equal(undefined, `ABI should be available for contract: ${name}`);
      expect(contract.tvc).not.to.equal(undefined, `tvc  should be available for contract: ${name}`);
    }
  });

  it("Deploy master", async function () {
    const {contract: contract, tx} = await locklift.factory.deployContract({
      contract: "Master",
      publicKey: signer.publicKey,
      initParams: {
        _randomNonce: locklift.utils.getRandomNonce(),
      },
      constructorParams: {
        owner: account.address,
        slave1Code: locklift.factory.getContractArtifacts('Slave1v1').code,
        slave2Code: locklift.factory.getContractArtifacts('Slave2v1').code,
      },
      value: locklift.utils.toNano(1),
    });
    master = contract;
    expect(await master.fields._constructorFlag()).to.be.true;
    log(`Master deployed: ${master.address.toString()}`);
  });

  it("Deploy slave", async function () {
    const tx = await locklift.tracing.trace(master.methods.deploySlave1().send({
      from: account.address,
      amount: toNano(0.5),
    }));

    const deploys = tx.traceTree.findByTypeWithFullData({type: TraceType.DEPLOY, name: 'constructor'});
    for (let deploy of deploys) {
      if (deploy.contract.name === 'Slave1v1') {
        const slaveAddress = new Address(deploy.msg.dst)
        slave = await locklift.factory.getDeployedContract('Slave1v1', slaveAddress)
      }
    }
    log(`Slave deployed: ${slave.address.toString()}`);
    log(`Gas used: ${fromNano(tx.traceTree.totalGasUsed())}`);
    await tx.traceTree?.beautyPrint();
  });

  it("Publish new version", async function () {
    const code = locklift.factory.getContractArtifacts('Slave1v2').code;
    const packed = await locklift.provider.packIntoCell({
      structure: [{name: 'value', type: 'string'}],
      data: {value: STRING_DATA_V2},
    });
    const tx = await locklift.tracing.trace(master.methods.createNewVersionSlave1({
      minor: false,
      code: code,
      params: packed.boc,
    }).send({
      from: account.address,
      amount: toNano(0.5),
    }));

    const data = await master.methods.getSlaveData({
      answerId: 0,
      sid: 1,
    }).call();
    expect(data).to.deep.equal({
      code: code,
      params: packed.boc,
      latest: {major: "2", minor: "1"},
      versionsCount: "2",
    });
    log(`Latest version: ${data.latest.major}.${data.latest.minor}`);
    log(`Gas used: ${fromNano(tx.traceTree.totalGasUsed())}`);
    await tx.traceTree?.beautyPrint();
  });

  it("Upgrade slave", async function () {
    const tx = await locklift.tracing.trace(master.methods.upgradeSlave1({
      destination: slave.address,
    }).send({
      from: account.address,
      amount: toNano(0.5),
    }));
    slave = await locklift.factory.getDeployedContract('Slave1v2', slave.address);

    const data = await slave.methods._data().call();
    expect(data._data).to.deep.equal(STRING_DATA_V2);
    log(`V2 data: "${data._data}"`);
    log(`Gas used: ${fromNano(tx.traceTree.totalGasUsed())}`);
    await tx.traceTree?.beautyPrint();
  });

});
