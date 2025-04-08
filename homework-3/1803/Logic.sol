// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

// tx hash: 0xd5726ee17df0fe05f925168aee2c2b52648de358a2250a8289908f8d3ee2a1b6
// contract address: 0xca0bad9cc36ae7f1e89704b5fbb7978f7bd9573c
contract Logic {
    uint256 public sum;

    function changeCounter(uint256 _number) external {
        sum = _number;
    }
}
