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
- **Two-step ownership (`Ownable2Step`)** — transferring ownership requires the new owner to explicitly accept, preventing accidental, irreversible loss of control from a mistyped address
- **Custom errors + zero-address guards** — gas-efficient reverts with no unguarded zero-address paths in constructor or `mint()`
- **Fully NatSpec-documented** — every function and error has doc comments, matching the verified source on each explorer
- Static analysis run with [Slither](https://github.com/crytic/slither) — no High/Medium findings in `src/MyToken.sol` (see [Security](#security))

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

## Deploying to a brand-new chain for the first time

A wallet's very first transaction on any chain always uses nonce `0`, and a
contract's address is computed from `(deployer address, deployer nonce)` —
chain ID plays no part in that formula. This means the *first* contract you
ever deploy from a given wallet will land on the **same address on every
chain** where that wallet has never transacted before.

If you'd prefer each deployment to get its own unique address (matching how
most real-world multichain tokens end up looking, simply through incidental
prior wallet activity), send one throwaway transaction to bump the nonce
**before** your real deploy:

```bash
# 1. Fund the wallet from that chain's faucet first (needed for gas either way)

# 2. Confirm funds arrived
cast balance <YOUR_WALLET_ADDRESS> --rpc-url <network>

# 3. Bump the nonce with a trivial self-transfer
cast send <YOUR_WALLET_ADDRESS> --value 1 --rpc-url <network> --private-key $PRIVATE_KEY

# 4. Now deploy — this will produce a fresh, unique address
forge script script/DeployMyToken.s.sol:DeployMyToken --rpc-url <network> --broadcast --verify
```

This step is optional — a repeated address across chains causes no technical
issue and does not link the contracts in any way. It's purely cosmetic.

## Transferring ownership

Ownership uses OpenZeppelin's `Ownable2Step`, so handing off control (e.g. to
a multisig) takes two transactions, not one:

```bash
# 1. Current owner proposes the new owner — ownership does NOT change yet
cast send <CONTRACT_ADDRESS> "transferOwnership(address)" <NEW_OWNER_ADDRESS> \
  --rpc-url <network> --private-key $PRIVATE_KEY

# 2. New owner must explicitly accept, from their OWN key
cast send <CONTRACT_ADDRESS> "acceptOwnership()" \
  --rpc-url <network> --private-key <NEW_OWNER_PRIVATE_KEY>

# Check current owner / pending owner at any time:
cast call <CONTRACT_ADDRESS> "owner()(address)" --rpc-url <network>
cast call <CONTRACT_ADDRESS> "pendingOwner()(address)" --rpc-url <network>
```

If step 2 never happens, ownership stays exactly where it was — a mistyped
or unreachable new-owner address cannot lock you out, unlike plain `Ownable`.

## Deployed addresses

### Current — production-hardened (Ownable2Step, custom errors, NatSpec)

| Network              | Address                                       | Explorer |
|-----------------------|------------------------------------------------|----------|
| Sepolia (testnet)     | `0x4602E3EDc16d24457C7Af5f286e89a43e7575119`   | [View](https://sepolia.etherscan.io/address/0x4602e3edc16d24457c7af5f286e89a43e7575119#code) |
| BSC Testnet           | `0x4602E3EDc16d24457C7Af5f286e89a43e7575119`   | [View](https://testnet.bscscan.com/address/0x4602e3edc16d24457c7af5f286e89a43e7575119#code) |
| Polygon Amoy (testnet)| `0x9025521D790e5a507918eCe466eD66023f2C553C`   | [View](https://amoy.polygonscan.com/address/0x9025521d790e5a507918ece466ed66023f2c553c#code) |

### Superseded — earlier version (plain `Ownable`, string reverts)

Kept live for reference; not maintained further.

| Network              | Address                                       | Status     | Explorer |
|-----------------------|------------------------------------------------|------------|----------|
| Sepolia (testnet)     | `0x91f5B7e55226f983f52B7878671e668C5d4880f3`   | Superseded | [View](https://sepolia.etherscan.io/address/0x91f5b7e55226f983f52b7878671e668c5d4880f3#code) |
| BSC Testnet           | `0x91f5B7e55226f983f52B7878671e668C5d4880f3`   | ⏸ Paused, superseded | [View](https://testnet.bscscan.com/address/0x91f5b7e55226f983f52b7878671e668c5d4880f3#code) |
| BSC Testnet           | `0x9025521D790e5a507918eCe466eD66023f2C553C`   | Superseded | [View](https://testnet.bscscan.com/address/0x9025521d790e5a507918ece466ed66023f2c553c#code) |
| Polygon Amoy (testnet)| `0x91f5B7e55226f983f52B7878671e668C5d4880f3`   | Superseded | [View](https://amoy.polygonscan.com/address/0x91f5b7e55226f983f52b7878671e668c5d4880f3#code) |

*(Update these tables as you deploy to additional networks.)*

> Note: several addresses above being identical across chains is a
> coincidence of matching deployer nonces at deploy time — it does not mean
> the contracts are linked in any way. Each deployment is fully independent
> on-chain. See
> [`cast nonce`](https://book.getfoundry.sh/reference/cast/cast-nonce) to
> check a wallet's transaction count on a given chain.

## Security

Completed hardening for this contract:

- ✅ Built on OpenZeppelin's audited `ERC20`, `ERC20Burnable`, `ERC20Pausable`, `Ownable2Step`
- ✅ Two-step ownership transfer (see [Transferring ownership](#transferring-ownership))
- ✅ Custom errors + zero-address checks in constructor and `mint()`
- ✅ Full NatSpec documentation
- ✅ Static analysis run with [Slither](https://github.com/crytic/slither) — `slither src/MyToken.sol` reports no High/Medium findings

Still required before any mainnet deployment involving real value:

- Replace the single-EOA owner with a multisig (e.g. [Gnosis Safe](https://safe.global/))
- Get an independent, professional security audit — Slither and OpenZeppelin's own audits do not substitute for a human review of this contract's specific logic
- Test extensively on testnet, including edge cases (max supply, pause/unpause, zero-value transfers, ownership transfer)
- Rotate any private key that has ever been shared, pasted, or committed anywhere
- Verify every deployment on its block explorer immediately after deploy

## License

MIT
