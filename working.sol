pragma solidity ^0.4.0;
contract working {

    struct Proposal {
        uint voteCount;
        string description;
    }

    address public owner;
    Proposal[] public proposals;
    uint public maxvotes;

    function TestContract(uint _maxvotes) {
        owner = msg.sender;
        maxvotes = _maxvotes;
    }

    function createProposal(string description) {
        Proposal memory p;
        p.description = description;
        proposals.push(p);
    }

    function vote(uint proposal) public {
        proposals[proposal].voteCount < maxvotes;
        proposals[proposal].voteCount += 1;
    }
}