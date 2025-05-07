# Homework 4 - Solidity on Polkadot (1581)

## Description
This project completes three tasks for Homework 4:
- **Task 1**: Deploy, call, and listen to events of a `Storage` contract using `ethers.js` and `viem.js`.
- **Task 2**: Deploy `MiniDex` on Polkadot Asset Hub using Remix and interact with it.
- **Task 3**: Set up a Hardhat Revive environment to compile and test a `Storage` contract on PolkaVM.

## Directory Structure
- `contracts/`: Contains `1581-Storage.sol` and `1581-MiniDex.sol`.
- `scripts/`: Contains `1581-ethers-deploy.ts` and `1581-viem-deploy.ts`.
- `test/`: Contains `1581-Storage.ts` for testing.
- `screenshots/`: Contains `1581-minidex-screenshot.png` and `1581-hardhat-revive-screenshot.png`.
- `hardhat.config.ts`: Hardhat configuration for localhost and PolkaVM.

## Setup and Execution
### Task 1: ethers and viem
1. Install dependencies: `npm install`
2. Run Hardhat node: `npx hardhat node`
3. Deploy with ethers: `npx hardhat run scripts/1581-ethers-deploy.ts --network localhost`
4. Deploy with viem: `npx hardhat run scripts/1581-viem-deploy.ts --network localhost`

### Task 2: Mini DEX
1. Open [remix.polkadot.io](https://remix.polkadot.io/).
2. Deploy `1581-MiniDex.sol` on Polkadot Asset Hub.
3. Interact with `addLiquidity`, `swap`, and `removeLiquidity`.
4. Screenshots in `screenshots/1581-minidex-screenshot.png`.

### Task 3: Hardhat Revive
1. Compile `resolc` and `polkadot-sdk` as per instructions.
2. Run `substrate-node` and `eth-rpc`.
3. Test `1581-Storage.sol` on PolkaVM: `npx hardhat test test/1581-Storage.ts --network polkavm`
4. Screenshots in `screenshots/1581-hardhat-revive-screenshot.png`.

## Results
- Task 1: Successfully deployed and interacted with `Storage` using `ethers.js` and `viem.js`.
- Task 2: Deployed `MiniDex` on Asset Hub, performed liquidity and swap operations.
- Task 3: Set up Hardhat Revive, tested `Storage` on PolkaVM.