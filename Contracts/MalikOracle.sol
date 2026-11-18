// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";

contract MalikOracle is Ownable {
    struct RateData {
        uint256 usdPrice;
        uint256 lastUpdated;
    }
mapping(string => RateData) public rates;
    mapping(address => bool) public authorizedFeeds;
    event RateVerified(string indexed symbol, uint256 usdPrice, uint256 timestamp);
    event FeedAuthorized(address indexed feed, bool status);
     authorizedFeeds[msg.sender] = true;
    }modifier onlyFeed() {
        require(authorizedFeeds[msg.sender], "MalikOracle: Unauthorized rate feed");
        _;
    }    // भरोसेमंद रेट डेटा स्रोत को अनुमति देना
    function setAuthorizedFeed(address feed, bool status) external onlyOwner {
        authorizedFeeds[feed] = status;
        emit FeedAuthorized(feed, status);
    }    // किसी भी ग्लोबल करेंसी या क्रिप्टो का वेरिफाइड रेट अपडेट करना
    function submitVerifiedRate(string memory symbol, uint256 usdPrice) external onlyFeed {
        require(usdPrice > 0, "MalikOracle: Price must be positive");
        rates[symbol] = RateData(usdPrice, block.timestamp);
        emit RateVerified(symbol, usdPrice, block.timestamp);
    }
// रेट की ताज़गी (Freshness) जांचने का फंक्शन (1 घंटे से पुराना रेट अमान्य होगा)
    function getLatestRate(string memory symbol) external view returns (uint256) {
        RateData memory data = rates[symbol];
        require(data.usdPrice > 0, "MalikOracle: Rate not available");
        require(block.timestamp - data.lastUpdated <= 1 hours, "MalikOracle: Stale price data");
        return data.usdPrice;
    }
}
 
