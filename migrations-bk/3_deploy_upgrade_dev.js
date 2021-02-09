const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');
const Airdrop = artifacts.require('Airdrop');
const StakingPool = artifacts.require('StakingPool');
const WhiteList = artifacts.require('WhiteList');

module.exports = async function (deployer) {
  const proxyAirdrop = '';
  await upgradeProxy(proxyAirdrop, Airdrop, {
    deployer,
    unsafeAllowCustomTypes: true,
  });

  const proxyStakingPool = '';
  await upgradeProxy(proxyStakingPool, StakingPool, {
    deployer,
    unsafeAllowCustomTypes: true,
  });

  const proxyWhiteList = '';
  await upgradeProxy(proxyWhiteList, WhiteList, {
    deployer,
    unsafeAllowCustomTypes: true,
  });
};
