// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Ownable{
    address payable _owner;
    constructor() payable {
        _owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(isOwner(),"You are not the owner.");
        _;
    }

    function isOwner() public view returns(bool) {
        return (msg.sender == _owner);
    }
}