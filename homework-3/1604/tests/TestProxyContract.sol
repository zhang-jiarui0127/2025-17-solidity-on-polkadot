// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/LogicContract.sol";
import "../contracts/ProxyContract.sol";

contract TestProxyContract {
    LogicContract logicContract;
    ProxyContract proxyContract;

    event TestResult(string message, uint256 count);

    constructor() {
        // Deploy LogicContract
        logicContract = new LogicContract();

        // Deploy ProxyContract
        proxyContract = new ProxyContract();
    }

    function testDelegateIncrement() public {
        // Call increment through ProxyContract
        proxyContract.delegateIncrement(address(logicContract));

        // Verify the count is updated
        uint256 count = proxyContract.count();
        require(count == 1, "Count should be 1 after increment");

        // Emit event to log the result
        emit TestResult("Test passed: count is", count);
    }
}
