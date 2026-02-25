#!/usr/bin/env node
const {
    makeContractDeploy,
    broadcastTransaction,
    AnchorMode,
    PostConditionMode,
    getAddressFromPrivateKey,
    TransactionVersion,
} = require('@stacks/transactions');
const { StacksMainnet, StacksTestnet } = require('@stacks/network');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const NETWORK = process.env.STACKS_NETWORK === 'testnet' ? new StacksTestnet() : new StacksMainnet();
const PRIVATE_KEY = process.env.STACKS_PRIVATE_KEY;
const DEPLOY_DELAY = 60000;
const MAX_RETRIES = 3;
const GAS_BUFFER = 1.1;

const CONTRACT_SETS = {
    'ai-ml': [
        { name: 'model-registry', file: 'model-registry.clar' },
        { name: 'prediction-market', file: 'prediction-market.clar' },
        { name: 'data-marketplace', file: 'data-marketplace.clar' },
        { name: 'training-rewards', file: 'training-rewards.clar' },
    ],
    'healthcare': [
        { name: 'medical-records', file: 'medical-records.clar' },
        { name: 'prescription-tracker', file: 'prescription-tracker.clar' },
        { name: 'insurance-claims', file: 'insurance-claims.clar' },
        { name: 'telemedicine', file: 'telemedicine.clar' },
    ],
    'legal': [
        { name: 'smart-contracts', file: 'smart-contracts.clar' },
        { name: 'dispute-resolution', file: 'dispute-resolution.clar' },
        { name: 'notary-service', file: 'notary-service.clar' },
        { name: 'ip-registry', file: 'ip-registry.clar' },
    ],
    'charity': [
        { name: 'donation-tracker', file: 'donation-tracker.clar' },
        { name: 'impact-verification', file: 'impact-verification.clar' },
        { name: 'fund-distribution', file: 'fund-distribution.clar' },
        { name: 'volunteer-rewards', file: 'volunteer-rewards.clar' },
    ],
    'voting': [
        { name: 'governance', file: 'governance.clar' },
        { name: 'proposal-system', file: 'proposal-system.clar' },
        { name: 'delegation', file: 'delegation.clar' },
        { name: 'quadratic-voting', file: 'quadratic-voting.clar' },
    ],
    'loyalty': [
        { name: 'points-system', file: 'points-system.clar' },
        { name: 'rewards-marketplace', file: 'rewards-marketplace.clar' },
        { name: 'tier-management', file: 'tier-management.clar' },
        { name: 'referral-tracking', file: 'referral-tracking.clar' },
    ],
    'streaming': [
        { name: 'content-monetization', file: 'content-monetization.clar' },
        { name: 'subscription-management', file: 'subscription-management.clar' },
        { name: 'micropayments', file: 'micropayments.clar' },
        { name: 'royalty-distribution', file: 'royalty-distribution.clar' },
    ],
    'metaverse': [
        { name: 'virtual-land', file: 'virtual-land.clar' },
        { name: 'avatar-marketplace', file: 'avatar-marketplace.clar' },
        { name: 'event-ticketing', file: 'event-ticketing.clar' },
        { name: 'virtual-goods', file: 'virtual-goods.clar' },
    ],
    'carbon': [
        { name: 'carbon-credits', file: 'carbon-credits.clar' },
        { name: 'offset-tracking', file: 'offset-tracking.clar' },
        { name: 'green-energy-certificates', file: 'green-energy-certificates.clar' },
        { name: 'emissions-registry', file: 'emissions-registry.clar' },
    ],
    'privacy': [
        { name: 'zero-knowledge-proofs', file: 'zero-knowledge-proofs.clar' },
        { name: 'private-transactions', file: 'private-transactions.clar' },
        { name: 'encrypted-storage', file: 'encrypted-storage.clar' },
        { name: 'anonymous-voting', file: 'anonymous-voting.clar' },
    ],
};

const deploymentState = {
    deployedContracts: [],
    failedDeployments: [],
    totalFees: 0,
};

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function getCurrentNonce(address) {
    try {
        const response = await fetch(`${NETWORK.coreApiUrl}/v2/accounts/${address}?proof=0`);
        const data = await response.json();
        return data.nonce;
    } catch (error) {
        return 0;
    }
}

async function estimateGasFee(codeBody) {
    const baselineFee = 5000;
    const bytesMultiplier = 10;
    const contractSize = Buffer.from(codeBody).length;
    return Math.ceil((baselineFee + (contractSize * bytesMultiplier)) * GAS_BUFFER);
}

async function waitForConfirmation(txId, maxWaitTime = 600000) {
    const startTime = Date.now();
    const pollInterval = 10000;

    while (Date.now() - startTime < maxWaitTime) {
        try {
            const response = await fetch(`${NETWORK.coreApiUrl}/extended/v1/tx/${txId}`);
            const data = await response.json();

            if (data.tx_status === 'success') return { success: true, data };
            if (data.tx_status === 'abort_by_response' || data.tx_status === 'abort_by_post_condition') {
                return { success: false, error: data.tx_status, data };
            }

            await sleep(pollInterval);
        } catch (error) {
            await sleep(pollInterval);
        }
    }

    return { success: false, error: 'Timeout' };
}

async function deployContract(contractName, contractFile, folderPath, nonce, retryCount = 0) {
    try {
        console.log(`\n   📄 Deploying: ${contractName}`);

        const contractPath = path.join(process.cwd(), 'contracts', folderPath, contractFile);
        if (!fs.existsSync(contractPath)) {
            throw new Error(`Contract file not found: ${contractPath}`);
        }

        const codeBody = fs.readFileSync(contractPath, 'utf-8');
        const estimatedFee = await estimateGasFee(codeBody);
        console.log(`      💰 Fee: ${(estimatedFee / 1000000).toFixed(6)} STX`);

        const senderAddress = getAddressFromPrivateKey(
            PRIVATE_KEY,
            NETWORK.version === TransactionVersion.Mainnet ? TransactionVersion.Mainnet : TransactionVersion.Testnet
        );

        const txOptions = {
            contractName,
            codeBody,
            senderKey: PRIVATE_KEY,
            network: NETWORK,
            anchorMode: AnchorMode.Any,
            postConditionMode: PostConditionMode.Allow,
            fee: estimatedFee,
            nonce,
        };

        const transaction = await makeContractDeploy(txOptions);
        const broadcastResponse = await broadcastTransaction(transaction, NETWORK);

        if (broadcastResponse.error) {
            throw new Error(`${broadcastResponse.error}`);
        }

        const txId = broadcastResponse.txid;
        console.log(`      ✅ TX: ${txId}`);

        const confirmation = await waitForConfirmation(txId);
        if (!confirmation.success) throw new Error(`Failed: ${confirmation.error}`);

        return {
            success: true,
            contractName,
            txId,
            fee: estimatedFee,
            contractAddress: `${senderAddress}.${contractName}`,
        };
    } catch (error) {
        console.error(`      ❌ Error: ${error.message}`);

        if (retryCount < MAX_RETRIES) {
            console.log(`      🔄 Retry ${retryCount + 1}/${MAX_RETRIES}`);
            await sleep(30000);
            return deployContract(contractName, contractFile, folderPath, nonce + 1, retryCount + 1);
        }

        return { success: false, contractName, error: error.message };
    }
}

async function deployAllContracts() {
    console.log('🚀 March Stacks Portfolio Deployment - 40 Contracts');
    console.log(`🌐 Network: ${NETWORK.isMainnet() ? 'Mainnet' : 'Testnet'}\n`);

    if (!PRIVATE_KEY) {
        console.error('❌ STACKS_PRIVATE_KEY not set');
        process.exit(1);
    }

    const senderAddress = getAddressFromPrivateKey(
        PRIVATE_KEY,
        NETWORK.version === TransactionVersion.Mainnet ? TransactionVersion.Mainnet : TransactionVersion.Testnet
    );

    console.log(`👤 Deployer: ${senderAddress}\n`);

    let currentNonce = await getCurrentNonce(senderAddress);
    const startTime = Date.now();

    for (const [folderPath, contracts] of Object.entries(CONTRACT_SETS)) {
        console.log(`\n📦 ${folderPath} (${contracts.length} contracts)`);

        for (const contract of contracts) {
            const result = await deployContract(contract.name, contract.file, folderPath, currentNonce);

            if (result.success) {
                deploymentState.deployedContracts.push(result);
                deploymentState.totalFees += result.fee;
                currentNonce++;
            } else {
                deploymentState.failedDeployments.push(result);
            }

            if (contracts.indexOf(contract) < contracts.length - 1) {
                await sleep(DEPLOY_DELAY);
            }
        }
    }

    const duration = (Date.now() - startTime) / 1000;

    console.log('\n\n' + '='.repeat(80));
    console.log('📊 DEPLOYMENT SUMMARY');
    console.log('='.repeat(80));
    console.log(`\n✅ Successful: ${deploymentState.deployedContracts.length}`);
    console.log(`❌ Failed: ${deploymentState.failedDeployments.length}`);
    console.log(`💰 Total Fees: ${(deploymentState.totalFees / 1000000).toFixed(6)} STX`);
    console.log(`⏱️  Duration: ${duration.toFixed(2)}s\n`);

    const report = {
        timestamp: new Date().toISOString(),
        network: NETWORK.isMainnet() ? 'mainnet' : 'testnet',
        deployerAddress: senderAddress,
        successful: deploymentState.deployedContracts,
        failed: deploymentState.failedDeployments,
        totalFees: deploymentState.totalFees,
        totalFeesSTX: deploymentState.totalFees / 1000000,
        duration,
    };

    fs.writeFileSync('deployment-report.json', JSON.stringify(report, null, 2));
    console.log('📄 Report saved: deployment-report.json\n');
}

deployAllContracts()
    .then(() => {
        console.log('✨ Deployment complete!');
        process.exit(0);
    })
    .catch(error => {
        console.error('❌ Failed:', error);
        process.exit(1);
    });
