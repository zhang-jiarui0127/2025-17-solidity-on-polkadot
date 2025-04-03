// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestContract {
    LogicContract public logicContract;
    ProxyContract public proxyContract;

    constructor() {
        logicContract = new LogicContract();
        proxyContract = new ProxyContract(address(logicContract));
    }

    // 调用 ProxyContract 的 increment 方法，并验证 counter 是否正确更新
    function testIncrement() public {
        uint256 initialCounter = proxyContract.counter();

        // 调用 ProxyContract 的 increment 方法
        proxyContract.increment();

        uint256 newCounter = proxyContract.counter();
        require(newCounter == initialCounter + 1, "Increment failed");

        // 如果 testIncrement 通过，counter 应该加一
    }

    // 测试修改 LogicContract 的地址
    function testSetLogicContract(address newLogicContract) public {
        // 调用 ProxyContract 的 setLogicContract 方法
        proxyContract.setLogicContract(newLogicContract);

        // 验证 LogicContract 是否更新
        require(
            proxyContract.logicContract() == newLogicContract,
            "Logic contract update failed"
        );
    }

    // 获取 LogicContract 的 counter 值，验证是否与 ProxyContract 相同
    function testLogicContractCounter() public view returns (uint256) {
        return logicContract.counter();
    }
}

contract LogicContract {
    uint256 public counter;

    function increment() public {
        counter += 1;
    }
}

contract ProxyContract {
    uint256 public counter;
    address public logicContract;

    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    function setLogicContract(address _logicContract) public {
        logicContract = _logicContract;
    }

    function increment() public {
        (bool success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
    }
}
