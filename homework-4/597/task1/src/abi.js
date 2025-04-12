// abi.js
const storageAbi = [
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "newNumber",
                "type": "uint256"
            }
        ],
        "name": "NumberChanged",
        "type": "event"
    },
    {
        "inputs": [],
        "name": "retrieve",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "num",
                "type": "uint256"
            }
        ],
        "name": "store",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

const bytecode = "6080604052348015600e575f80fd5b5061017a8061001c5f395ff3fe608060405234801561000f575f80fd5b5060043610610034575f3560e01c80632e64cec1146100385780636057361d14610056575b5f80fd5b610040610072565b60405161004d91906100d2565b60405180910390f35b610070600480360381019061006b9190610119565b61007a565b005b5f8054905090565b805f819055507f2fd81fd19d3c5c4b396dd13f451dafc8bcac1b3094c49c5fa90e68456323f0e3816040516100af91906100d2565b60405180910390a150565b5f819050919050565b6100cc816100ba565b82525050565b5f6020820190506100e55f8301846100c3565b92915050565b5f80fd5b6100f8816100ba565b8114610102575f80fd5b50565b5f81359050610113816100ef565b92915050565b5f6020828403121561012e5761012d6100eb565b5b5f61013b84828501610105565b9150509291505056fea264697066735822122003996487a62208bfd55c3e20f26a8767b9ab0a87c040181d41df7ed42ecf5c5d64736f6c634300081a0033";

module.exports = { storageAbi, bytecode };
