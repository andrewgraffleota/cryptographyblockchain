// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BallotManager.sol";

contract Ballot {
    struct ballotOption {
        // stucture to store information about each ballot option
        string optionName;
        uint optionVotesAmount;
    }
    mapping(address => bool) public addressVotedOnBallot;

    ballotOption[] public ballotOptions; // Stores stucts of all options user can pick in ballot

    address public ballotOwner;
    string public ballotName;
    bool public ballotHasBeenApproved;
    bool public ballotIsActive;
    uint public ballotTotalVotes;
    uint public ballotId;

    modifier onlyBallotOwner() {
        // modifier to restrict use of methods to only the Ballot Owner
        require(msg.sender == ballotOwner, "Error: This address is not the Ballot Owner!");
        _;
    }

    modifier onlyBallotIsActive() {
        // modifier to ensure that the ballot is still active
        require(ballotIsActive, "Error: This ballot has been ended by either the Contract or Ballot Owner!");
        _;
    }

    modifier onlyApproved() {
        // modifier that requires a ballot has been approved by the Contract Owner
        require(ballotHasBeenApproved, "Error: This ballot has not been approved by the Contract Owner!");
        _;
    }

    constructor(address _ballotOwner, string memory _ballotName, string[] memory _ballotOptions, uint _ballotId) {
        ballotOwner = _ballotOwner;
        ballotName = _ballotName;
        ballotId = _ballotId;
        ballotTotalVotes = 0;
        ballotHasBeenApproved = false;
        ballotIsActive = false;


        for (uint i=0;i<_ballotOptions.length;i++) {
            // populate ballotOptions list with passed in options
            ballotOptions.push(ballotOption({optionName: _ballotOptions[i], optionVotesAmount: 0}));
        }
    }

    // function for Ballot Owners to start their ballot once it has been approved
    function startBallotVoting() external onlyBallotOwner {
        require(ballotHasBeenApproved == true, "Error: The Ballot has not been approved, therefore you cannot start voting!");
        // approve the ballot to start voting
        ballotIsActive = true;
    }

    function endBallotVoting() external onlyBallotOwner {
        require(ballotHasBeenApproved, "Error: This ballot was never approved, and therefore cannot be ended!");
        require(ballotIsActive, "Error: This ballot is not currently active, and therefore cannot be ended!");
        ballotIsActive = false;
    }

    function voteForBallot(uint indexOfSelectedOption) external {
        require(ballotIsActive, "Error: This ballot has ended, or was never started");
        // check the index of selected option is within range
        require(indexOfSelectedOption < ballotOptions.length, "Error: That index is out of range, and is not a valid option!");

        // check the user has not already voted
        require(!addressVotedOnBallot[msg.sender], "Error: This address has already voted on this ballot!");

        ballotOptions[indexOfSelectedOption].optionVotesAmount += 1;
        ballotTotalVotes++;
        
        addressVotedOnBallot[msg.sender] = true;
    }

    function getResultsOfBallot() external view returns(string memory winningOption, uint winningOptionVotes) {
        require (!ballotIsActive, "Error! Results of ballot cannot be retrieved until ballot ends!");
        uint winningOptionIndex;
        uint winningVoteAmount;

        for(uint i=0;i<ballotOptions.length;i++) {
            if (ballotOptions[i].optionVotesAmount > winningVoteAmount) {
                winningVoteAmount = ballotOptions[i].optionVotesAmount;
                winningOptionIndex = i;
            }
        }
        return (ballotOptions[winningOptionIndex].optionName, winningVoteAmount);
    }

    function setApproval(bool _newApprovalStatus) external {
        ballotHasBeenApproved = _newApprovalStatus;
    }

    function getApproval() public view returns (bool) {
        return ballotHasBeenApproved;
    }

    function incrementTotalVotes() external {
        ballotTotalVotes += 1;
    }

    function getTotalVotes() public view returns (uint) {
        return ballotTotalVotes;
    } 
}

