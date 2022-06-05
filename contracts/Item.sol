// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./Ownable.sol";
import "./ItemManager.sol";
contract Item {
    uint public priceInWei;
    uint public index;
    uint public pricePaid;
    ItemManager parentContract;

    constructor (ItemManager _parentContract, uint _priceInWei, uint _index)  {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract; 
    }

    receive() external payable {
        require(pricePaid == 0,"Item is paid already");
        require(priceInWei == msg.value , "Only full payments allowed");
        pricePaid += msg.value;
        (bool success,) = address(parentContract).call{value:msg.value}(abi.encodeWithSignature("triggerPayment(uint256)",index));
        // (bool success,) = address(parentContract).call.value(msg.value)(abi.encodeWithSignature("triggerPayment(uint256)",index));
        require(success,"The transaction wasn't successfull, cancelling");
    }

    fallback() external {}
}