// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Project {
    
    // Struct to represent a candidate
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
        bool exists;
    }
    
    // Struct to represent a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedCandidateId;
    }
    
    // State variables
    address public owner;
    string public electionName;
    bool public votingActive;
    uint public totalVotes;
    uint public candidateCount;
    
    // Mappings
    mapping(uint => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    // Events
    event CandidateAdded(uint candidateId, string name);
    event VoterRegistered(address voter);
    event VoteCast(address voter, uint candidateId);
    event VotingStatusChanged(bool status);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyDuringVoting() {
        require(votingActive, "Voting is not currently active");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "You are not registered to vote");
        _;
    }
    
    // Constructor
    constructor(string memory _electionName) {
        owner = msg.sender;
        electionName = _electionName;
        votingActive = false;
        totalVotes = 0;
        candidateCount = 0;
    }
    
    // Core Function 1: Add Candidate (Only owner can add candidates)
    function addCandidate(string memory _name) public onlyOwner {
        require(!votingActive, "Cannot add candidates during active voting");
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        
        candidateCount++;
        candidates[candidateCount] = Candidate({
            id: candidateCount,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        emit CandidateAdded(candidateCount, _name);
    }
    
    // Core Function 2: Register Voter
    function registerVoter(address _voterAddress) public onlyOwner {
        require(!voters[_voterAddress].isRegistered, "Voter already registered");
        
        voters[_voterAddress] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        
        emit VoterRegistered(_voterAddress);
    }
    
    // Core Function 3: Cast Vote
    function vote(uint _candidateId) public onlyDuringVoting onlyRegisteredVoter {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        // Record the vote
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        // Increment candidate vote count
        candidates[_candidateId].voteCount++;
        totalVotes++;
        
        emit VoteCast(msg.sender, _candidateId);
    }
    
    // Additional Functions
    
    // Start/Stop voting (Owner only)
    function toggleVotingStatus() public onlyOwner {
        votingActive = !votingActive;
        emit VotingStatusChanged(votingActive);
    }
    
    // Get candidate details
    function getCandidate(uint _candidateId) public view returns (uint, string memory, uint) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    // Get voter details
    function getVoterDetails(address _voterAddress) public view returns (bool, bool, uint) {
        Voter memory voter = voters[_voterAddress];
        return (voter.isRegistered, voter.hasVoted, voter.votedCandidateId);
    }
    
    // Get election results (returns winning candidate)
    function getWinner() public view returns (uint winnerId, string memory winnerName, uint winnerVoteCount) {
        require(candidateCount > 0, "No candidates available");
        
        uint winningVoteCount = 0;
        uint winningCandidateId = 0;
        
        for (uint i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }
        
        return (winningCandidateId, candidates[winningCandidateId].name, winningVoteCount);
    }
    
    // Get all candidates (for frontend display)
    function getAllCandidates() public view returns (uint[] memory, string[] memory, uint[] memory) {
        uint[] memory ids = new uint[](candidateCount);
        string[] memory names = new string[](candidateCount);
        uint[] memory voteCounts = new uint[](candidateCount);
        
        for (uint i = 0; i < candidateCount; i++) {
            uint candidateId = i + 1;
            ids[i] = candidates[candidateId].id;
            names[i] = candidates[candidateId].name;
            voteCounts[i] = candidates[candidateId].voteCount;
        }
        
        return (ids, names, voteCounts);
    }
}
