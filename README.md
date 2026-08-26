# MyToken — Multi-Chain ERC-20

A production-oriented ERC-20 token (also valid as BEP-20 on BNB Chain — same
standard) built with [Foundry](https://book.getfoundry.sh/) and
[OpenZeppelin](https://www.openzeppelin.com/contracts). One codebase, one
deploy script, config-driven per network — the same command deploys to any
EVM chain (Ethereum, Arbitrum, Polygon, BNB Chain, Celo, and any testnet or
mainnet equivalent) by swapping the `--rpc-url` flag and `.env` values.

## Features

- **ERC-20** standard interface (OpenZeppelin, audited base)
- **Burnable** — token holders can burn their own balance
- **Pausable** — owner can freeze all transfers in an emergency
- **Supply-capped minting** — owner can mint new tokens, but never past `maxSupply`
- **Ownable** — single-owner access control (swap for a multisig in production, see [Security](#security))

## Project structure

```
.
├── src/MyToken.sol              # Token contract
├── script/DeployMyToken.s.sol   # Network-agnostic deploy script
├── test/MyToken.t.sol           # Unit + fuzz tests
├── .github/workflows/test.yml   # CI: tests + formatting on every push/PR
├── foundry.toml                 # RPC + explorer config for every chain
├── .env.example                 # Template for required environment variables
└── remappings.txt               # OpenZeppelin import remapping
```

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (`forge`, `cast`, `anvil`)
- A wallet funded with testnet or mainnet ETH (or the chain's native gas token)
- An RPC endpoint (e.g. [Alchemy](https://www.alchemy.com/) or [Infura](https://www.infura.io/))
- An explorer API key for verification (Etherscan / Polygonscan / Arbiscan / BscScan / Celoscan)

## Setup

```bash
git clone https://github.com/iamsaddamahmad/MultichainContract.git
cd MultichainContract
forge install
cp .env.example .env
```

Fill in `.env` with your own values — **never commit this file** (it's already
in `.gitignore`).

## Testing

```bash
forge test -vv
```

Includes unit tests for minting, pausing, burning, access control, and a fuzz
test on arbitrary transfer amounts.

## Local deployment (Anvil)

```bash
# Terminal 1
anvil

# Terminal 2 — use one of anvil's printed default accounts in .env
forge script script/DeployMyToken.s.sol:DeployMyToken \
  --rpc-url http://127.0.0.1:8545 --broadcast
```

## Testnet / mainnet deployment

Same script, any chain — just change the `--rpc-url` name (defined in
`foundry.toml`) and make sure `.env` points at a funded wallet for that chain:

```bash
# Sepolia (Ethereum testnet)
forge script script/DeployMyToken.s.sol:DeployMyToken --rpc-url sepolia --broadcast --verify

# Arbitrum Sepolia
forge script script/DeployMyToken.s.sol:DeployMyToken --rpc-url arbitrum_sepolia --broadcast --verify

# BNB Chain testnet
forge script script/DeployMyToken.s.sol:DeployMyToken --rpc-url bsc_testnet --broadcast --verify

# Polygon Amoy testnet
forge script script/DeployMyToken.s.sol:DeployMyToken --rpc-url polygon_amoy --broadcast --verify

# Celo Alfajores testnet
forge script script/DeployMyToken.s.sol:DeployMyToken --rpc-url celo_alfajores --broadcast --verify
```

For mainnet, use the corresponding mainnet network name (`ethereum`,
`arbitrum`, `bsc`, `polygon`, `celo`) with a properly secured, funded
production wallet.

## Deployed addresses

| Network              | Address                                       | Status     | Explorer |
|-----------------------|------------------------------------------------|------------|----------|
| Sepolia (testnet)     | `0x91f5B7e55226f983f52B7878671e668C5d4880f3`   | Active     | [View](https://sepolia.etherscan.io/address/0x91f5b7e55226f983f52b7878671e668c5d4880f3#code) |
| BSC Testnet           | `0x91f5B7e55226f983f52B7878671e668C5d4880f3`   | ⏸ Paused (deprecated) | [View](https://testnet.bscscan.com/address/0x91f5b7e55226f983f52b7878671e668c5d4880f3#code) |
| BSC Testnet           | `0x9025521D790e5a507918eCe466eD66023f2C553C`   | Active     | [View](https://testnet.bscscan.com/address/0x9025521d790e5a507918ece466ed66023f2c553c#code) |

*(Update this table as you deploy to additional networks.)*

> Note: the two BSC/Sepolia addresses being identical at first is a coincidence
> of matching deployer nonces on both chains at deploy time — it does not mean
> the contracts are linked in any way. Each is fully independent. See
> [`cast nonce`](https://book.getfoundry.sh/reference/cast/cast-nonce) to check
> a wallet's transaction count on a given chain.

## Security

This contract is suitable for testnets and learning purposes as-is. Before
any mainnet deployment involving real value:

- Replace the `Ownable` owner with a multisig (e.g. [Gnosis Safe](https://safe.global/)) rather than a single EOA
- Run static analysis with [Slither](https://github.com/crytic/slither)
- Get an independent security audit
- Test extensively on testnet, including edge cases (max supply, pause/unpause, zero-value transfers)
- Rotate any private key that has ever been shared, pasted, or committed anywhere
- Verify every deployment on its block explorer immediately after deploy

## License

MIT
