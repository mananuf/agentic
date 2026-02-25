# March Stacks Portfolio - 40 Smart Contracts

Advanced Clarity smart contract collection featuring 40 deployable contracts across 10 categories.

## Categories

- **AI & ML** (4 contracts): AI model registry, prediction markets, data marketplace, training rewards
- **Healthcare** (4 contracts): Medical records, prescription tracking, insurance claims, telemedicine
- **Legal** (4 contracts): Smart contracts, dispute resolution, notary services, IP registry
- **Charity** (4 contracts): Donation tracking, impact verification, fund distribution, volunteer rewards
- **Voting** (4 contracts): Governance, proposal system, delegation, quadratic voting
- **Loyalty** (4 contracts): Points system, rewards marketplace, tier management, referral tracking
- **Streaming** (4 contracts): Content monetization, subscription management, micropayments, royalty distribution
- **Metaverse** (4 contracts): Virtual land, avatar marketplace, event ticketing, virtual goods
- **Carbon** (4 contracts): Carbon credits, offset tracking, green energy certificates, emissions registry
- **Privacy** (4 contracts): Zero-knowledge proofs, private transactions, encrypted storage, anonymous voting

## Quick Start

```bash
# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your credentials

# Deploy all contracts
node scripts/deploy-all.js

# Interact with contracts
node scripts/interact-all.js

# Generate 10,000 commits
bash scripts/generate-commits.sh
```

## Requirements

- Node.js 16+
- Stacks wallet with STX
- Git

## Network

Supports both mainnet and testnet deployment via `STACKS_NETWORK` environment variable.
