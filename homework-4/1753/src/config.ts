const ABI = [
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_number",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "number",
				"type": "uint256"
			}
		],
		"name": "NumberUpdated",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "number",
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
				"name": "_number",
				"type": "uint256"
			}
		],
		"name": "setNumber",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]
const BYTECODE = "6080604052348015600e575f5ffd5b506040516101c43803806101c48339818101604052810190602e9190606b565b805f81905550506091565b5f5ffd5b5f819050919050565b604d81603d565b81146056575f5ffd5b50565b5f815190506065816046565b92915050565b5f60208284031215607d57607c6039565b5b5f6088848285016059565b91505092915050565b6101268061009e5f395ff3fe6080604052348015600e575f5ffd5b50600436106030575f3560e01c80633fb5c1cb1460345780638381f58a14604c575b5f5ffd5b604a60048036038101906046919060a6565b6066565b005b6052606f565b604051605d919060d9565b60405180910390f35b805f8190555050565b5f5481565b5f5ffd5b5f819050919050565b6088816078565b81146091575f5ffd5b50565b5f8135905060a0816081565b92915050565b5f6020828403121560b85760b76074565b5b5f60c3848285016094565b91505092915050565b60d3816078565b82525050565b5f60208201905060ea5f83018460cc565b9291505056fea26469706673582212209ee5fd28adb1c495a240ca759bb90c5d9a645c807d2bd1ac2781dd4d3502a35664736f6c634300081d0033"

export {ABI, BYTECODE}