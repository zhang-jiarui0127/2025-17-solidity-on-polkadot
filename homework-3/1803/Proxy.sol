// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

// tx hash: 0x72c4f71035b93eeb0903c8d633618249dd1ea2447245285984fd96c2f20c3ad5
// contract address: 0xa53664f64d006042840bab1eb68861bd0e6e5ef7
contract Proxy {
    uint256 public num;
    // tx hash: 0xc98416ec6a0d7a0e06527b1bcf41cfdf881b7b60c2cb46344868778965dd97cc
    function sumCount(address _logicAddr, uint256 _num) external {
        (bool success, ) = _logicAddr.delegatecall(
            abi.encodeWithSignature("changeCounter(uint256)", _num)
        );

        require(success, "Delegatecall failed");
    }
}