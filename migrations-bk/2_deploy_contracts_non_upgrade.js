const USDTToken = artifacts.require('USDTToken');
const APDToken = artifacts.require('APDToken');
const Utils = artifacts.require('Utils');

module.exports = function (deployer) {
  deployer.deploy(Utils);
  deployer.deploy(USDTToken);
  deployer.deploy(APDToken);
};
