export const ABI = [
  { type: 'constructor', inputs: [], stateMutability: 'nonpayable' },
  {
    type: 'function',
    name: 'favoriteNumber',
    inputs: [],
    outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'store',
    inputs: [
      { name: '_favoriteNumber', type: 'uint256', internalType: 'uint256' },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
] as const;

export const BYTECODE =
  '0x6080604052348015600f57600080fd5b5060b180601d6000396000f3fe6080604052348015600f57600080fd5b506004361060325760003560e01c8063471f7cdf1460375780636057361d146051575b600080fd5b603f60005481565b60405190815260200160405180910390f35b6061605c3660046063565b600055565b005b600060208284031215607457600080fd5b503591905056fea26469706673582212200bd3a58c9a4bd9474f58d0e1e45f70e637c88c099c10dc98e166e1a5749cb09b64736f6c634300081c0033';
