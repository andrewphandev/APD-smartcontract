const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const Airdrop = artifacts.require('Airdrop');
const StakingPool = artifacts.require('StakingPool');
const WhiteList = artifacts.require('WhiteList');

module.exports = async function (deployer) {
  await deployProxy(Airdrop, { deployer, initializer: 'initialize' });
  console.log('[Proxy Airdrop]', (await Airdrop.deployed()).address);

  await deployProxy(StakingPool, { deployer, initializer: 'initialize' });
  console.log('[Proxy StakingPool]', (await StakingPool.deployed()).address);

  await deployProxy(WhiteList, { deployer, initializer: 'initialize' });
  console.log('[Proxy WhiteList]', (await WhiteList.deployed()).address);
};
