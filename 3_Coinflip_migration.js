const Coinflip = artifacts.require("Coinflip");

module.exports = function(deployer) {
  deployer.deploy(Coinflip);
};
// let instance = await Coinflip.deployed();
// instance.inputMoney({from: accounts[0], value: 40000000000000000000})
