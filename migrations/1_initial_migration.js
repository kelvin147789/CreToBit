const CreToBit = artifacts.require("CreToBit");

module.exports = async function (deployer) {

  await deployer.deploy(CreToBit);
  const creToBit = await CreToBit.deployed();

  await creToBit.transfer("0xe8dda644fD1fDcDF36b1aA70F3c588cD330b353b",'500000000000000000');

  
};