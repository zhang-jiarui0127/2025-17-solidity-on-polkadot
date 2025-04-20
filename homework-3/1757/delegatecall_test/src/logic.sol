// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

contract Logic {
    // 链上变量,链上的变量最好使用s_开头
    uint256 public s_x;

    function setX(uint256 _x) public {
        s_x = _x;
    }

    function getX() public view returns (uint256) {
        return s_x;
    }
    // 每次让X+1
    function increment() public returns (uint256) {
        setX(s_x + 1);
        return s_x;
    }
}