// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
contract MalikComplianceRegistry is Ownable {
    // KYC स्तर: 0 = Unverified, 1 = Basic KYC, 2 = Full KYC (Aadhaar/PAN/Passport)
    mapping(address => uint8) public kycLevel;
    mapping(address => string) public userCountryCode; // e.g., "IN", "US", "AE"  
    // भारत के क्रिप्टो नियमों के अनुसार 1% TDS (100 basis points)
    uint256 public constant INDIA_TDS_BPS = 100;
    uint256 public constant BPS_DENOMINATOR = 10000;
    event KYCVerified(address indexed user, uint8 level, string country);
    event TDSCalculated(address indexed user, uint256 amount, uint256 tdsDeducted);

        // यूज़र का KYC वेरिफाई करना
    function setUserKYC(address user, uint8 level, string memory countryCode) external onlyOwner {
        require(level <= 2, "Invalid KYC level");
        kycLevel[user] = level;
        userCountryCode[user] = countryCode;
        emit KYCVerified(user, level, countryCode);
    }

    // जांचें कि यूज़र लेनदेन के लिए योग्य है या नहीं
    function isCompliantForTransfer(address user, uint256 usdAmount) external view returns (bool) {
        if (kycLevel[user] == 0) return false; // बिना KYC कोई लेनदेन नहीं
        if (kycLevel[user] == 1 && usdAmount > 1000 * 10**18) return false; // Basic KYC पर $1,000 लिमिट
        return true;
    }

    // भारतीय यूज़र्स के लिए 1% TDS की गणना
    function calculateApplicableTDS(address user, uint256 amount) external view returns (uint256) {
        if (keccak256(bytes(userCountryCode[user])) == keccak256(bytes("IN"))) {
            return (amount * INDIA_TDS_BPS) / BPS_DENOMINATOR;
        }
        return 0;
    }
}
 
