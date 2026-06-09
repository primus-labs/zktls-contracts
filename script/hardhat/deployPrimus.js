const hre = require("hardhat");

function requiredEnv(name) {
    if (!process.env[name]) {
        throw new Error(`Missing required env: ${name}`);
    }
    return process.env[name];
}

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );

    const initialAttestors = [
        {
            attestorAddr: requiredEnv("ATTESTOR_1_ADDRESS"),
            url: requiredEnv("ATTESTOR_1_URL"),
        },
        {
            attestorAddr: requiredEnv("ATTESTOR_2_ADDRESS"),
            url: requiredEnv("ATTESTOR_2_URL"),
        },
        {
            attestorAddr: requiredEnv("ATTESTOR_3_ADDRESS"),
            url: requiredEnv("ATTESTOR_3_URL"),
        },
    ];

    const contract = await hre.ethers.getContractFactory("PrimusZKTLS");
    const primus = await hre.upgrades.deployProxy(contract,
        [deployer.address, initialAttestors], {initializer: 'initialize'});
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
