const Lotdrug = artifacts.require('Lotdrug.sol');

module.exports = function(deployer) {
    deployer.deploy(Lotdrug);
};