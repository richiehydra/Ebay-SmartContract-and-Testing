var myContract = artifacts.require("Ebay");

module.exports = function(deployer){
  deployer.deploy(myContract);
}