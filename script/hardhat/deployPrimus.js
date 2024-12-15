const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );

    const contract = await hre.ethers.getContractFactory("PrimusZKTLS");
    const primus = await hre.upgrades.deployProxy(contract,
        [deployer.address], {initializer: 'initialize'});
    await primus.waitForDeployment();
    const primusProxyAddress = await primus.getAddress();
    const primusImplementationAddress = await hre.upgrades.erc1967.getImplementationAddress(primusProxyAddress);
    const adminAddress = await hre.upgrades.erc1967.getAdminAddress(primusProxyAddress);
    //await hre.run("verify:verify", {
    //  address: primusProxyAddress,
    //});
    console.log(`Proxy is at ${primusProxyAddress}`);
    console.log(`Implementation is at ${primusImplementationAddress}`);
    console.log(`adminAddress is at ${adminAddress}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
