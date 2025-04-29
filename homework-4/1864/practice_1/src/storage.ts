export const ABI = [
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "oldValue",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "newValue",
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
]
// 采用eth remix 的bytecode
export const BYTECODE = "0x6080604052348015600e575f80fd5b506101a98061001c5f395ff3fe608060405234801561000f575f80fd5b5060043610610034575f3560e01c80632e64cec1146100385780636057361d14610056575b5f80fd5b610040610072565b60405161004d91906100da565b60405180910390f35b610070600480360381019061006b9190610121565b61007a565b005b5f8054905090565b5f80549050815f819055507f31431e8e0193815c649ffbfb9013954926640a5c67ada972108cdb5a47a0d72881836040516100b692919061014c565b60405180910390a15050565b5f819050919050565b6100d4816100c2565b82525050565b5f6020820190506100ed5f8301846100cb565b92915050565b5f80fd5b610100816100c2565b811461010a575f80fd5b50565b5f8135905061011b816100f7565b92915050565b5f60208284031215610136576101356100f3565b5b5f6101438482850161010d565b91505092915050565b5f60408201905061015f5f8301856100cb565b61016c60208301846100cb565b939250505056fea264697066735822122008af77229643dd242d65151c5d66ed529a005a099de2addd30d571064621a69664736f6c634300081a0033"
			
			
