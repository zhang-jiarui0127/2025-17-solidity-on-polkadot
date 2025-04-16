// 合约的ABI
export const ABI = [
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "newValue",
                "type": "uint256"
            }
        ],
        "name": "ValueChanged",
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
                "name": "newValue",
                "type": "uint256"
            }
        ],
        "name": "store",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

// 合约的字节码
export const BYTECODE = "6080604052348015600e575f80fd5b5061017a8061001c5f395ff3fe608060405234801561000f575f80fd5b5060043610610034575f3560e01c80632e64cec1146100385780636057361d14610056575b5f80fd5b610040610072565b60405161004d91906100d2565b60405180910390f35b610070600480360381019061006b9190610119565b61007a565b005b5f8054905090565b805f819055507f93fe6d397c74fdf1402a8b72e47b68512f0510d7b98a4bc4cbdf6ac7108b3c59816040516100af91906100d2565b60405180910390a150565b5f819050919050565b6100cc816100ba565b82525050565b5f6020820190506100e55f8301846100c3565b92915050565b5f80fd5b6100f8816100ba565b8114610102575f80fd5b50565b5f81359050610113816100ef565b92915050565b5f6020828403121561012e5761012d6100eb565b5b5f61013b84828501610105565b9150509291505056fea2646970667358221220d8da57b1afa797cad086b2ccf4f6f7feb42c3ceb49e2154103207a270ac4e58e64736f6c634300081a0033"; 