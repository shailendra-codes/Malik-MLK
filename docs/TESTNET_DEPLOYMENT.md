# 🚀 Zero-Cost Testnet Deployment Guide — Malik (MLK)

Follow these steps to deploy and test the **Malik (MLK)** Universal Bridge ecosystem on **Polygon Amoy Testnet** with zero financial cost.

## Step 1: Get Free Testnet Tokens
1. Install **MetaMask** and switch to **Polygon Amoy Testnet** (`Chain ID: 80002`).
2. Visit the official Polygon Faucet to claim free test `POL` gas tokens.

## Step 2: Deploy Smart Contracts via Remix IDE
1. Open [Remix Ethereum IDE](https://ethereum.org).
2. Load the 4 core contracts from the `Contracts/` directory:
   - `MalikToken.sol` (Deploy with initial supply `100000000` for 100M MLK)
   - `MalikOracle.sol`
   - `MalikBridge.sol` (Pass `MalikToken` deployed address)
   - `MalikLiquidityPool.sol` (Pass `MalikToken` deployed address)

## Step 3: Verify AML & Conversion Rules
- Test `blacklistAddress()` on `MalikToken.sol` to verify illicit wallets are blocked.
- Test `calculateConversion()` on `MalikBridge.sol` using the `1 MLK = $1.00 USD` peg.
 
