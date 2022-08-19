// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

contract Saving {
    uint public target;   
    constructor(uint _target) {
        target = _target;
    }
    receive() external payable {}
    function getMyBalance() public view returns (uint) {
        return address(this).balance;
    }   
    function withdraw() public {
        if (getMyBalance() > target) {
            selfdestruct(msg.sender);
        }
    }
}