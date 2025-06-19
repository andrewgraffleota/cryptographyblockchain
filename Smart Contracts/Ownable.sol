// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address public owner;
    
    constructor() {
        owner = msg.sender; // Whoever deploys the contract will become the Contract Owner
    }

    modifier onlyOwner() {
        // modifier to restrict use of methods to only the Contract Owner
        require(msg.sender == owner, "Error: This address is not the Contract Owner!");
        _;
    }
}