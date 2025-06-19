// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ballot.sol";
import "./Ownable.sol";

contract BallotManager is Ownable {
    Ballot[] public ballots; // list of active ballots
    uint public ballotIdCounter; // variable to assign unique ID to each ballot
    mapping(uint => Ballot) public ballotIdMapping; // mapping of units (ids) to ballots

    // initalize the ballotIdCounter variable 
    constructor() {
        ballotIdCounter = 0;
    }

    modifier ballotIdIsValid(uint _ballotId) {
        // if BallotId is greater than the counter or 0, it can't be valid 
        require(_ballotId > 0 && _ballotId <= ballotIdCounter, "Error: That is an invalid Ballot ID");

        // converts the ballot into it's address representation. If the address is 0, it means an address with the given ID was not found
        require(address(ballotIdMapping[_ballotId]) != address(0), "Error: The Ballot with that Ballot ID does not exist");
        _;
    }

    function createBallot(string memory _ballotName, string[] memory _ballotOptions) public {
        // ballot must have 2 options
        require(_ballotOptions.length >= 2, "Error: Ballots must have at least 2 options to vote on!");
        require(_ballotOptions.length <= 5, "Error: Ballots must have a max of 5 options");
        // increase the ballot counter every time a new ballot is created for unique ID
        ballotIdCounter++;

        // create a new ballot object
        Ballot newBallot = new Ballot(msg.sender, _ballotName, _ballotOptions, ballotIdCounter);

        // add the information about the new ballot to the structure array
        ballots.push(newBallot);
        // map the new ballot to the current id counter in the mapping
        ballotIdMapping[ballotIdCounter] = newBallot;
    }

    function deleteBallot(uint _ballotId) public onlyOwner ballotIdIsValid(_ballotId) {
        // remove the ballot from the array of ballots
        delete ballots[_ballotId - 1];
        delete ballotIdMapping[_ballotId];
    }

    function approveBallot(uint _ballotId) public onlyOwner ballotIdIsValid(_ballotId) {
        require(!ballots[_ballotId - 1].getApproval(), "Error: This Ballot has already been approved!");
        ballots[_ballotId - 1].setApproval(true);
    }

    function updateTotalVoteCount(uint _ballotId) external ballotIdIsValid(_ballotId) {
         Ballot ballot = ballotIdMapping[_ballotId];
         ballot.incrementTotalVotes();
    } 

    function ballotOwnerStartVoting(uint _ballotId) public ballotIdIsValid(_ballotId) {
        Ballot ballotToStart = ballotIdMapping[_ballotId];
        ballotToStart.startBallotVoting();
    }

    function ballotOwnerEndVoting(uint _ballotId) public ballotIdIsValid(_ballotId) {
        Ballot ballotToEnd = ballotIdMapping[_ballotId];
        ballotToEnd.endBallotVoting();
    }

    function vote(uint _ballotId, uint selectedOption) public ballotIdIsValid(_ballotId) {
        Ballot ballotToVoteOn = ballotIdMapping[_ballotId];
        ballotToVoteOn.voteForBallot(selectedOption);
    }

    function getSpesificBallotInformation(uint _ballotId) public ballotIdIsValid(_ballotId) view returns (Ballot) {
        // map the ballotId 
        Ballot ballot = ballotIdMapping[_ballotId];

        // return the ballot data from the structure
        return ballot;
    }

    function topFiveBallots() public view returns(Ballot[] memory) {
        // create a mirror copy of the ballots array for use in this function
        Ballot[] memory sortBallots = new Ballot[](ballots.length);
        for (uint i = 0; i < ballots.length; i++) {
            sortBallots[i] = ballots[i];
        }

        // bubble sort the ballots in decending order according to total votes
        Ballot swap;
        for(uint i = 0; i < sortBallots.length; i++) {
            for (uint j = 0; j < sortBallots.length - 1; j++) {
                if (sortBallots[j].getTotalVotes() < sortBallots[j + 1].getTotalVotes()) {
                    swap = sortBallots[j];
                    sortBallots[j] = sortBallots[j + 1];
                    sortBallots[j + 1] = swap;
                }
            }
        }

        // if there are less than 5 ballots, the return length will be set to this
        // if there are more than 5 ballots then the return length will be set to 5        
        uint lengthToReturn = (ballots.length <= 5) ? ballots.length : 5;

        // create an array of size lengthToReturn to store the top ballots
        Ballot[] memory topBallots = new Ballot[](lengthToReturn);

        // place the top values (up to 5) vfrom the newly sorted array into placeholder array
        for (uint i = 0; i < lengthToReturn; i++) {
            topBallots[i] = sortBallots[i];
        }

        return topBallots;
    }

    function getApprovedBallots() public view returns (Ballot[] memory)  {
        // determine the amount of approved ballots used for initalizing the size of the array of approvedBallots
        uint amountOfApprovedBallots = 0;
        for (uint i=0; i < ballots.length; i++) {
            if (ballots[i].getApproval()) {
                amountOfApprovedBallots++;
            }
        }

        // initilize array to store approved ballots
        Ballot[] memory approvedBallots = new Ballot[](amountOfApprovedBallots);

        // if a ballot is marked as approved, add it to the array
        uint index = 0;
        for(uint i = 0; i < ballots.length; i++) {
            if(ballots[i].getApproval()) {
                // ballots will be bigger than approvedBallots, therefore we need to use index
                // to place the found approved ballot in the correct position in the array
                approvedBallots[index] = ballots[i];
                index++;
            }
        }

        // return array of approved ballots
        return approvedBallots;
    }

    function getUnapprovedBallots() public onlyOwner view returns (Ballot[] memory) {
        // determine the amount of unapproved ballots used for initalizing the size of the array of unapprovedBallots
        uint amountOfUnapprovedBallots = 0;
        for (uint i = 0; i < ballots.length; i++) {
            if (!ballots[i].getApproval()) {
                amountOfUnapprovedBallots++;
            }
        }

        // initilize array to store unapproved ballots
        Ballot[] memory unapprovedBallots = new Ballot[](amountOfUnapprovedBallots);

        // if a ballot is marked as unapproved, add it to the array
        uint index = 0;
        for(uint i = 0; i < ballots.length; i++) {
            if(!ballots[i].getApproval()) {
                unapprovedBallots[index] = ballots[i];
                index++;
            }
        }

        // return array of approved ballots
        return unapprovedBallots;
    }
}