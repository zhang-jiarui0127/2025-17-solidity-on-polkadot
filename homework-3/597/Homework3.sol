pragma solidity ^0.8.0;

// 逻辑合约 V1：将存储槽 0 的值加 1
contract LogicV1 {
    function increment() public {
        assembly {
            let c := sload(0)       // 读取存储槽 0
            sstore(0, add(c, 1))    // 加 1 后存储
        }
    }
}

// 逻辑合约 V2：将存储槽 0 的值加 2
contract LogicV2 {
    function increment() public {
        assembly {
            let c := sload(0)       // 读取存储槽 0
            sstore(0, add(c, 2))    // 加 2 后存储
        }
    }
}

// 代理合约：管理逻辑合约的调用和升级
contract Proxy {
    uint256 public counter;         // 计数器，存储在代理合约的存储槽 0
    address public logicContract;   // 当前逻辑合约的地址
    address public owner;           // 合约所有者

    // 构造函数：初始化逻辑合约地址并设置所有者
    constructor(address _logicContract) {
        logicContract = _logicContract;
        owner = msg.sender;         // 部署者为所有者
    }

    // 修饰符：限制只有所有者可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 升级逻辑合约地址
    function upgradeLogic(address _newLogicContract) public onlyOwner {
        logicContract = _newLogicContract;
    }

    // 调用逻辑合约的 increment 函数
    function increment() public {
        (bool success, ) = logicContract.delegatecall(abi.encodeWithSignature("increment()"));
        require(success, "Delegatecall failed");
    }
}