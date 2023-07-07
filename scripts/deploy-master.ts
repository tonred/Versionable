import {toNano, WalletTypes} from "locklift";
import lockliftConfig from "../locklift.config";

async function main() {
  const signer = await locklift.keystore.getSigner("0");
  const {account} = await locklift.factory.accounts.addNewAccount({
    type: WalletTypes.EverWallet,
    value: toNano(10),
    publicKey: signer.publicKey,
  });
  const {contract} = await locklift.factory.deployContract({
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
  console.log(`Master deployed at: ${contract.address.toString()}`);
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });
