// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Storage.sol";

abstract contract UUPSUpgradeable is Storage{
    // 升级函数
    function upgradeTo(address newImplementation) external onlyAdmin {
        // _authorizeUpgrade(newImplementation);
        _setImplementation(newImplementation);
    }

    // 内部设置实现地址
    function _setImplementation(address newImplementation) internal {
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    modifier onlyAdmin {
        require(msg.sender == getAdmin(), "Unauthorized");
        _;
    }

    function _disableInitializers() internal {
        assembly {
            sstore(0x0000000000000000000000000000000000000000000000000000000000000000, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE)
        }
    }

    // 授权检查
    // function _authorizeUpgrade(address) internal virtual;
}