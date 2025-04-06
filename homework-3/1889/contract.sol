// 逻辑合约
contract LogicContract {
    function increment() public {
        // 使用 assembly 直接操作存储位置 0 的值（状态变量）
        uint256 value = 0;
        assembly {
            value := sload(0)
        }
        value++;
        assembly {
            sstore(0, value)
        }
    }
}

// 代理合约
contract ProxyContract {
    address public logicContractAddress;

    constructor(address _logicContractAddress) {
        logicContractAddress = _logicContractAddress;
    }

    function increment() public {
        bytes memory data = abi.encodeWithSignature("increment()");
        (bool success, ) = logicContractAddress.delegatecall(data);
        require(success, "delegatecall failed");
    }

    function getValue() public view returns (uint256) {
        uint256 value = 0;
        assembly {
            value := sload(0)
        }
        return value;
    }
}