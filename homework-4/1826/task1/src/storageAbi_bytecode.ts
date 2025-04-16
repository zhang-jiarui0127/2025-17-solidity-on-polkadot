export const ABI = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: 'uint256',
        name: 'newNumber',
        type: 'uint256',
      },
    ],
    name: 'NumChanged',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: 'uint256',
        name: 'oldNumber',
        type: 'uint256',
      },
    ],
    name: 'oldNum',
    type: 'event',
  },
  {
    inputs: [],
    name: 'getNumber',
    outputs: [
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'number',
    outputs: [
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'newNum',
        type: 'uint256',
      },
    ],
    name: 'setNumber',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
];

export const BYTECODE =
  '6080604052348015600e575f5ffd5b506101e08061001c5f395ff3fe608060405234801561000f575f5ffd5b506004361061003f575f3560e01c80633fb5c1cb146100435780638381f58a1461005f578063f2c9ecd81461007d575b5f5ffd5b61005d60048036038101906100589190610157565b61009b565b005b610067610113565b6040516100749190610191565b60405180910390f35b610085610118565b6040516100929190610191565b60405180910390f35b7fcd74ca260a4df3a7a8f4488d229208e39b0b73a0fbfb367597334ee7261825ba5f546040516100cb9190610191565b60405180910390a1805f819055507f0969e25fb400bee82e6104dfd1bc672b0fe0b21c14f577fb803c1070b1dcc855816040516101089190610191565b60405180910390a150565b5f5481565b5f5f54905090565b5f5ffd5b5f819050919050565b61013681610124565b8114610140575f5ffd5b50565b5f813590506101518161012d565b92915050565b5f6020828403121561016c5761016b610120565b5b5f61017984828501610143565b91505092915050565b61018b81610124565b82525050565b5f6020820190506101a45f830184610182565b9291505056fea26469706673582212200a0393e3d9aed73d2100a0ac053cbc8532d7cd2a1537b13a94b59aa33c29d0c764736f6c634300081d0033';
