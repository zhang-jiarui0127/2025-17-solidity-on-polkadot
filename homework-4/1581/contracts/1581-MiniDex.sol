// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MiniDex {
    address public token0;
    address public token1;
    uint256 public reserve0;
    uint256 public reserve1;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external {
        reserve0 += amount0;
        reserve1 += amount1;
    }

    function removeLiquidity(uint256 amount0, uint256 amount1) external {
        reserve0 -= amount0;
        reserve1 -= amount1;
    }

    function swap(uint256 amountIn, bool isToken0) external returns (uint256 amountOut) {
        if (isToken0) {
            amountOut = (reserve1 * amountIn) / (reserve0 + amountIn);
            reserve0 += amountIn;
            reserve1 -= amountOut;
        } else {
            amountOut = (reserve0 * amountIn) / (reserve1 + amountIn);
            reserve1 += amountIn;
            reserve0 -= amountOut;
        }
    }
}