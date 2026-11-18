// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract MalikGovernance is Ownable {
    IERC20 public malikToken;
struct Proposal {
        uint256 id;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        bool executed;
    }
uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
event ProposalCreated(uint256 indexed id, string description, uint256 deadline);
event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
malikToken = IERC20(_malikToken);
}
// नया प्रस्ताव (जैसे नई करेंसी या बैंक पार्टनर जोड़ना) बनाना
    function createProposal(string memory description, uint256 durationDays) external onlyOwner 
       {proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            deadline: block.timestamp + (durationDays * 1 days),
            executed: false
        });
        emit ProposalCreated(proposalCount, description, proposals[proposalCount].deadline);
    }
    // MLK धारकों द्वारा वोट डालना
    function vote(uint256 proposalId, bool support) external {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp < p.deadline, "Voting period ended");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        uint256 voterBalance = malikToken.balanceOf(msg.sender);
        require(voterBalance > 0, "Must hold MLK tokens to vote");
        hasVoted[proposalId][msg.sender] = true;
        if (support) {
            p.votesFor += voterBalance;
        } else {
            p.votesAgainst += voterBalance;
        }

        emit Voted(proposalId, msg.sender, support, voterBalance);
    }
}
 
