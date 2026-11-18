// Malik (MLK) Protocol Automated Deployment Script
const hre = require("hardhat");

async function main() {
  console.log("🚀 Starting Malik (MLK) Protocol Deployment...");

  // 1. Deploy MalikToken (Initial Supply: 100 Million MLK, 1 MLK = $1 USD)
  const initialSupply = 100000000;
  const MalikToken = await hre.ethers.getContractFactory("MalikToken");
  const malikToken = await MalikToken.deploy(initialSupply);
  await malikToken.waitForDeployment();
  const tokenAddress = await malikToken.getAddress();
  console.log(`✅ MalikToken (MLK) deployed at: ${tokenAddress}`);

  // 2. Deploy MalikOracle
  const MalikOracle = await hre.ethers.getContractFactory("MalikOracle");
  const malikOracle = await MalikOracle.deploy();
  await malikOracle.waitForDeployment();
  console.log(`✅ MalikOracle deployed at: ${await malikOracle.getAddress()}`);

  // 3. Deploy MalikBridge linked to MalikToken
  const MalikBridge = await hre.ethers.getContractFactory("MalikBridge");
  const malikBridge = await MalikBridge.deploy(tokenAddress);
  await malikBridge.waitForDeployment();
  console.log(`✅ MalikBridge deployed at: ${await malikBridge.getAddress()}`);

  // 4. Deploy MalikLiquidityPool linked to MalikToken
  const MalikLiquidityPool = await hre.ethers.getContractFactory("MalikLiquidityPool");
  const malikPool = await MalikLiquidityPool.deploy(tokenAddress);
  await malikPool.waitForDeployment();
  console.log(`✅ MalikLiquidityPool deployed at: ${await malikPool.getAddress()}`);

  console.log("🎉 Malik (MLK) Global Bridge Ecosystem Deployed Successfully!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
 
