# Quick Start Guide

## Setup

1. Install dependencies:
```bash
cd mar
npm install
```

2. Configure environment:
```bash
cp .env.example .env
# Edit .env with your Stacks credentials
```

## Deploy Contracts

Deploy all 40 contracts to the blockchain:

```bash
npm run deploy
# or
node scripts/deploy-all.js
```

This will deploy:
- 4 AI & ML contracts
- 4 Healthcare contracts
- 4 Legal contracts
- 4 Charity contracts
- 4 Voting contracts
- 4 Loyalty contracts
- 4 Streaming contracts
- 4 Metaverse contracts
- 4 Carbon contracts
- 4 Privacy contracts

## Interact with Contracts

Execute sample interactions with all deployed contracts:

```bash
npm run interact
# or
node scripts/interact-all.js
```

## Generate 10,000 Commits

Create a rich commit history:

```bash
npm run commits
# or
bash scripts/generate-commits.sh
```

This generates 10,000 commits across 10 phases (1,000 commits per category).

## Contract Categories

### AI & ML
- `model-registry`: Register and verify AI models
- `prediction-market`: Create prediction markets
- `data-marketplace`: Buy/sell training datasets
- `training-rewards`: Reward compute contributors

### Healthcare
- `medical-records`: Secure patient records
- `prescription-tracker`: Track prescriptions
- `insurance-claims`: Process insurance claims
- `telemedicine`: Virtual appointments

### Legal
- `smart-contracts`: Legal agreements
- `dispute-resolution`: Arbitration system
- `notary-service`: Digital notarization
- `ip-registry`: Intellectual property

### Charity
- `donation-tracker`: Track donations
- `impact-verification`: Verify charitable impact
- `fund-distribution`: Distribute funds
- `volunteer-rewards`: Reward volunteers

### Voting
- `governance`: Decentralized governance
- `proposal-system`: Submit proposals
- `delegation`: Delegate voting power
- `quadratic-voting`: Quadratic voting mechanism

### Loyalty
- `points-system`: Earn/spend points
- `rewards-marketplace`: Redeem rewards
- `tier-management`: Customer tiers
- `referral-tracking`: Track referrals

### Streaming
- `content-monetization`: Monetize content
- `subscription-management`: Manage subscriptions
- `micropayments`: Small payments
- `royalty-distribution`: Distribute royalties

### Metaverse
- `virtual-land`: Own virtual land
- `avatar-marketplace`: Trade avatar items
- `event-ticketing`: Virtual event tickets
- `virtual-goods`: Trade virtual items

### Carbon
- `carbon-credits`: Trade carbon credits
- `offset-tracking`: Track carbon offsets
- `green-energy-certificates`: Renewable energy certs
- `emissions-registry`: Track emissions

### Privacy
- `zero-knowledge-proofs`: ZK proof verification
- `private-transactions`: Confidential transactions
- `encrypted-storage`: Encrypted on-chain storage
- `anonymous-voting`: Anonymous voting system

## Network Configuration

Switch between mainnet and testnet by editing `.env`:

```bash
# Mainnet
STACKS_NETWORK=mainnet

# Testnet
STACKS_NETWORK=testnet
```

## Reports

After deployment and interaction, check the generated reports:
- `deployment-report.json`: Deployment details
- `interaction-report.json`: Interaction results
