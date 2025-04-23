pragma solidity ^0.8.20;

// 存储基类（定义 ERC-1967 存储布局）
abstract contract Storage {
    // ERC-1967 实现地址插槽
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    
    // 管理员地址插槽
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    // 获取实现地址
    function getImplementation() public view returns (address impl) {
        assembly {
            impl := sload(_IMPLEMENTATION_SLOT)
        }
    }

    // 获取管理员
    function getAdmin() public view returns (address adm) {
        assembly {
            adm := sload(_ADMIN_SLOT)
        }
    }

    //===========================app存储
    uint256 internal number;
}