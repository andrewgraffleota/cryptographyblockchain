pragma solidity ^0.4.24;
//andrew
//name of contract
contract votingtest {
    struct Proposal {
        uint countvote; //count votes
        string description; //proposal description
    }
    address public owner; //store address of the owner calling contract
    Proposal[] public proposals; 
    uint public maxvote = 100; //limiting votes to 100
    mapping(address => bool) public alreadyvoted; //new mapping track to check if address has voted
//change to constructor because of upgrade to new compiler
    constructor() public {
        owner = msg.sender; //who ever calls contract is the owner
    }
//create proposal function 
    function Candidate(string memory description) public {
        proposals.push(Proposal({
            countvote: 0, //initial vote count of 0 
            description: description //to enter description
        }));
    }
//voting function 
    function vote(uint proposal_) public { 
        require(proposal_ < proposals.length, "non exisistent proposal");//check if proposal exists
        require(proposals[proposal_].countvote < maxvote, "votes reached max limit.");
        require(!alreadyvoted[msg.sender], "vote has been counted"); //check if user already voted
        proposals[proposal_].countvote += 1; //increment counting
        alreadyvoted[msg.sender] = true; //responds if vote has been counted
    }
}