#!/usr/bin/env node
const {
    makeContractCall,
    broadcastTransaction,
    AnchorMode,
    PostConditionMode,
    getAddressFromPrivateKey,
    TransactionVersion,
    uintCV,
    stringAsciiCV,
    standardPrincipalCV,
    bufferCV,
    boolCV,
    intCV,
} = require('@stacks/transactions');
const { StacksMainnet, StacksTestnet } = require('@stacks/network');
const fs = require('fs');
require('dotenv').config();

const NETWORK = process.env.STACKS_NETWORK === 'testnet' ? new StacksTestnet() : new StacksMainnet();
const PRIVATE_KEY = process.env.STACKS_PRIVATE_KEY;
const DEPLOYER_ADDRESS = process.env.DEPLOYER_ADDRESS;
const INTERACTION_DELAY = 30000;
const MIN_GAS_FEE = 2000;

const INTERACTIONS = {
    'model-registry': [
        { function: 'register-model', args: [stringAsciiCV('GPT-Model'), stringAsciiCV('v1.0'), uintCV(95)], desc: 'Register AI model' },
    ],
    'prediction-market': [
        { function: 'create-prediction', args: [stringAsciiCV('Will BTC reach 100k?'), uintCV(10000)], desc: 'Create prediction' },
    ],
    'data-marketplace': [
        { function: 'list-dataset', args: [stringAsciiCV('ImageNet'), uintCV(50000), uintCV(1000000)], desc: 'List dataset' },
    ],
    'training-rewards': [
        { function: 'add-contribution', args: [uintCV(100)], desc: 'Add compute hours' },
    ],
    'medical-records': [
        { function: 'create-record', args: [bufferCV(Buffer.from('0'.repeat(64), 'hex'))], desc: 'Create medical record' },
    ],
    'prescription-tracker': [
        { function: 'issue-prescription', args: [standardPrincipalCV(DEPLOYER_ADDRESS), stringAsciiCV('Aspirin'), stringAsciiCV('100mg')], desc: 'Issue prescription' },
    ],
    'insurance-claims': [
        { function: 'submit-claim', args: [standardPrincipalCV(DEPLOYER_ADDRESS), uintCV(5000)], desc: 'Submit claim' },
    ],
    'telemedicine': [
        { function: 'book-appointment', args: [standardPrincipalCV(DEPLOYER_ADDRESS), uintCV(1000), uintCV(500)], desc: 'Book appointment' },
    ],
    'smart-contracts': [
        { function: 'create-contract', args: [standardPrincipalCV(DEPLOYER_ADDRESS), bufferCV(Buffer.from('0'.repeat(64), 'hex'))], desc: 'Create legal contract' },
    ],
    'dispute-resolution': [
        { function: 'file-dispute', args: [standardPrincipalCV(DEPLOYER_ADDRESS), standardPrincipalCV(DEPLOYER_ADDRESS), uintCV(1000)], desc: 'File dispute' },
    ],
    'notary-service': [
        { function: 'request-notarization', args: [bufferCV(Buffer.from('0'.repeat(64), 'hex')), standardPrincipalCV(DEPLOYER_ADDRESS)], desc: 'Request notarization' },
    ],
    'ip-registry': [
        { function: 'register-ip', args: [stringAsciiCV('patent'), stringAsciiCV('Invention'), bufferCV(Buffer.from('0'.repeat(64), 'hex'))], desc: 'Register IP' },
    ],
    'donation-tracker': [
        { function: 'make-donation', args: [standardPrincipalCV(DEPLOYER_ADDRESS), uintCV(1000), stringAsciiCV('education')], desc: 'Make donation' },
    ],
    'impact-verification': [
        { function: 'report-impact', args: [stringAsciiCV('Clean Water Project'), uintCV(500)], desc: 'Report impact' },
    ],
    'fund-distribution': [
        { function: 'add-funds', args: [uintCV(10000)], desc: 'Add funds' },
    ],
    'volunteer-rewards': [
        { function: 'log-hours', args: [uintCV(10)], desc: 'Log volunteer hours' },
    ],
    'governance': [
        { function: 'create-proposal', args: [stringAsciiCV('Upgrade Protocol')], desc: 'Create proposal' },
    ],
    'proposal-system': [
        { function: 'submit-proposal', args: [stringAsciiCV('New feature proposal')], desc: 'Submit proposal' },
    ],
    'delegation': [
        { function: 'delegate-votes', args: [standardPrincipalCV(DEPLOYER_ADDRESS), uintCV(100)], desc: 'Delegate votes' },
    ],
    'quadratic-voting': [
        { function: 'create-poll', args: [stringAsciiCV('Should we implement feature X?')], desc: 'Create poll' },
    ],
    'points-system': [
        { function: 'earn-points', args: [uintCV(100)], desc: 'Earn points' },
    ],
    'rewards-marketplace': [
        { function: 'add-reward', args: [stringAsciiCV('Gift Card'), uintCV(1000), uintCV(50)], desc: 'Add reward' },
    ],
    'tier-management': [
        { function: 'update-tier', args: [uintCV(5000)], desc: 'Update tier' },
    ],
    'referral-tracking': [
        { function: 'register-referral', args: [standardPrincipalCV(DEPLOYER_ADDRESS)], desc: 'Register referral' },
    ],
    'content-monetization': [
        { function: 'publish-content', args: [stringAsciiCV('My Video'), uintCV(100)], desc: 'Publish content' },
    ],
    'subscription-management': [
        { function: 'subscribe', args: [stringAsciiCV('premium')], desc: 'Subscribe' },
    ],
    'micropayments': [
        { function: 'deposit', args: [uintCV(10000)], desc: 'Deposit funds' },
    ],
    'royalty-distribution': [
        { function: 'register-split', args: [uintCV(1), standardPrincipalCV(DEPLOYER_ADDRESS), uintCV(50)], desc: 'Register split' },
    ],
    'virtual-land': [
        { function: 'mint-parcel', args: [intCV(10), intCV(20)], desc: 'Mint land parcel' },
    ],
    'avatar-marketplace': [
        { function: 'mint-item', args: [stringAsciiCV('Hat'), stringAsciiCV('rare')], desc: 'Mint avatar item' },
    ],
    'event-ticketing': [
        { function: 'create-event', args: [stringAsciiCV('Virtual Concert'), uintCV(1000), uintCV(100)], desc: 'Create event' },
    ],
    'virtual-goods': [
        { function: 'create-good', args: [stringAsciiCV('Sword'), stringAsciiCV('weapon')], desc: 'Create virtual good' },
    ],
    'carbon-credits': [
        { function: 'issue-credit', args: [uintCV(100), stringAsciiCV('Reforestation')], desc: 'Issue carbon credit' },
    ],
    'offset-tracking': [
        { function: 'record-offset', args: [uintCV(50)], desc: 'Record offset' },
    ],
    'green-energy-certificates': [
        { function: 'issue-certificate', args: [stringAsciiCV('solar'), uintCV(1000)], desc: 'Issue certificate' },
    ],
    'emissions-registry': [
        { function: 'report-emissions', args: [uintCV(500)], desc: 'Report emissions' },
    ],
    'zero-knowledge-proofs': [
        { function: 'submit-proof', args: [bufferCV(Buffer.from('0'.repeat(64), 'hex'))], desc: 'Submit ZK proof' },
    ],
    'private-transactions': [
        { function: 'execute-private-tx', args: [bufferCV(Buffer.from('0'.repeat(64), 'hex')), bufferCV(Buffer.from('1'.repeat(64), 'hex')), bufferCV(Buffer.from('2'.repeat(64), 'hex'))], desc: 'Execute private tx' },
    ],
    'encrypted-storage': [
        { function: 'store-data', args: [bufferCV(Buffer.from('0'.repeat(64), 'hex')), bufferCV(Buffer.from('1'.repeat(64), 'hex')), uintCV(1024)], desc: 'Store encrypted data' },
    ],
    'anonymous-voting': [
        { function: 'create-ballot', args: [stringAsciiCV('Should we proceed?')], desc: 'Create ballot' },
    ],
};

const interactionState = {
    successfulInteractions: [],
    failedInteractions: [],
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

async function executeContractCall(contractAddress, contractName, functionName, functionArgs, description, nonce) {
    try {
        console.log(`      📝 ${description}`);
        const [deployer, contract] = contractAddress.split('.');

        const txOptions = {
            contractAddress: deployer,
            contractName: contract,
            functionName,
            functionArgs,
            senderKey: PRIVATE_KEY,
            network: NETWORK,
            anchorMode: AnchorMode.Any,
            postConditionMode: PostConditionMode.Allow,
            fee: MIN_GAS_FEE,
            nonce,
        };

        const transaction = await makeContractCall(txOptions);
        const broadcastResponse = await broadcastTransaction(transaction, NETWORK);

        if (broadcastResponse.error) {
            throw new Error(`${broadcastResponse.error}`);
        }

        console.log(`         ✅ TX: ${broadcastResponse.txid}`);

        return {
            success: true,
            contractAddress,
            functionName,
            txId: broadcastResponse.txid,
            fee: MIN_GAS_FEE,
            description,
        };
    } catch (error) {
        console.error(`         ❌ Failed: ${error.message}`);
        return {
            success: false,
            contractAddress,
            functionName,
            error: error.message,
            description,
        };
    }
}

async function interactWithAllContracts() {
    console.log('🎮 March Portfolio Contract Interactions');
    console.log(`🌐 Network: ${NETWORK.isMainnet() ? 'Mainnet' : 'Testnet'}\n`);

    if (!PRIVATE_KEY || !DEPLOYER_ADDRESS) {
        console.error('❌ Missing environment variables');
        process.exit(1);
    }

    const senderAddress = getAddressFromPrivateKey(
        PRIVATE_KEY,
        NETWORK.version === TransactionVersion.Mainnet ? TransactionVersion.Mainnet : TransactionVersion.Testnet
    );

    console.log(`👤 Interacting from: ${senderAddress}\n`);

    let currentNonce = await getCurrentNonce(senderAddress);
    const startTime = Date.now();

    for (const [contractName, interactions] of Object.entries(INTERACTIONS)) {
        console.log(`\n   🔗 ${contractName}`);
        const contractAddress = `${DEPLOYER_ADDRESS}.${contractName}`;

        for (const interaction of interactions) {
            const result = await executeContractCall(
                contractAddress,
                contractName,
                interaction.function,
                interaction.args || [],
                interaction.desc,
                currentNonce
            );

            if (result.success) {
                interactionState.successfulInteractions.push(result);
                interactionState.totalFees += result.fee;
                currentNonce++;
            } else {
                interactionState.failedInteractions.push(result);
            }

            await sleep(INTERACTION_DELAY);
        }
    }

    const duration = (Date.now() - startTime) / 1000;

    console.log('\n\n' + '='.repeat(80));
    console.log('📊 INTERACTION SUMMARY');
    console.log('='.repeat(80));
    console.log(`\n✅ Successful: ${interactionState.successfulInteractions.length}`);
    console.log(`❌ Failed: ${interactionState.failedInteractions.length}`);
    console.log(`💰 Total Fees: ${(interactionState.totalFees / 1000000).toFixed(6)} STX`);
    console.log(`⏱️  Duration: ${duration.toFixed(2)}s\n`);

    const report = {
        timestamp: new Date().toISOString(),
        network: NETWORK.isMainnet() ? 'mainnet' : 'testnet',
        interactorAddress: senderAddress,
        successful: interactionState.successfulInteractions,
        failed: interactionState.failedInteractions,
        totalFees: interactionState.totalFees,
        totalFeesSTX: interactionState.totalFees / 1000000,
        duration,
    };

    fs.writeFileSync('interaction-report.json', JSON.stringify(report, null, 2));
    console.log('📄 Report saved: interaction-report.json\n');
}

interactWithAllContracts()
    .then(() => {
        console.log('✨ Interactions complete!');
        process.exit(0);
    })
    .catch(error => {
        console.error('❌ Failed:', error);
        process.exit(1);
    });
