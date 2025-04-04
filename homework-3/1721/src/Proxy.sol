// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 0️⃣ **Proxy合约**
contract Proxy {
    // 1️⃣ **使用特定的存储位置，避免覆盖问题**
    bytes32 private constant IMPLEMENTATION_SLOT = keccak256("proxy.implementation");
    
    function _getImplementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _setImplementation(address _newImplementation) internal {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _newImplementation)
        }
    }

    // 添加 `getImplementation()` 让测试合约可以访问**
    function getImplementation() public view returns (address) {
        return _getImplementation();
    }

    constructor(address _implementation) {
        _setImplementation(_implementation);
    }

    function upgrade(address _newImplementation) public {
        _setImplementation(_newImplementation);
    }

    // 2️⃣ **delegatecall 代理所有函数**
    fallback() external payable {
        address impl = _getImplementation();
        require(impl != address(0), "Logic contract not set");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    // 添加 `receive()` 让合约能收 ETH
    receive() external payable {}
}
