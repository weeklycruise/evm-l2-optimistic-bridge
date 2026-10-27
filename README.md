# EVM Layer 2 Optimistic Bridge & Message Relayer

[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-363636?logo=solidity)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FF4B4B.svg)](https://getfoundry.sh/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A trust-minimized, dispute-enabled cross-domain bridging protocol enabling bidirectional asset transfers and arbitrary message relaying between Ethereum Layer 1 and high-throughput EVM Layer 2 rollups.

---

## 🏗 Bridge Protocol Architecture

```mermaid
sequenceDiagram
    autonumber
    actor User as User / DApp
    participant L1Portal as L1 Bridge Portal
    participant Relayer as Rollup Sequencer / Relayer
    participant L2Receiver as L2 Message Receiver

    User->>L1Portal: depositERC20(token, amount, l2Recipient)
    L1Portal-->>L1Portal: Lock tokens & emit MessageSent(msgHash)
    Relayer->>L1Portal: Observe MessageSent event & state commitment
    Relayer->>L2Receiver: relayMessage(msgHash, l2Recipient, amount, proof)
    L2Receiver-->>L2Receiver: Verify fraud-proof window & mint / release L2 tokens
    L2Receiver-->>User: Transfer minted L2 representative tokens
```

## 🔒 Security & Verification Engine

- **Fraud Proof Challenge Window**: 7-day state dispute period with cryptographic Merkle mountain range inclusion verification.
- **ERC-4337 Compatible Gas Abstraction**: Relayer paymasters allow users to bridge gaslessly with fee sponsorship.
- **Reentrancy & Rate Limiting**: Token-specific velocity caps and non-reentrant execution gates on both L1/L2 domains.

## 📂 Repository Layout

```text
├── contracts/
│   ├── IL2CrossDomainMessenger.sol
│   ├── L1StandardBridge.sol
│   └── L2StandardBridge.sol
├── test/
│   └── Bridge.t.sol
├── script/
│   └── DeployBridge.s.sol
└── foundry.toml
```

## 🚀 Building & Testing

```bash
# Compile contracts with via-IR optimizer enabled
forge build

# Run unit tests and invariant fuzz tests
forge test -vvv
```

## 📄 License
MIT
