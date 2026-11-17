// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MalikToken is ERC20, ERC20Pausable, Ownable {
   
    // संदिग्ध या अवैध वॉलेट्स को ब्लॉक करने की सूची (AML Security)
    mapping(address => bool) public isBlacklisted;

    event AccountBlacklisted(address indexed account);
    event AccountUnblacklisted(address indexed account);

    // कॉइन का नाम: Malik, सिंबल: MLK (1 MLK = $1 USD Standard)
    constructor(uint256 initialSupply) ERC20("Malik", "MLK") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // किसी संदिग्ध वॉलेट को ब्लॉक करने का फंक्शन
    function blacklistAddress(address account) external onlyOwner {
        isBlacklisted[account] = true;
        emit AccountBlacklisted(account);
    }

    // वॉलेट से ब्लॉक हटाने का फंक्शन
    function unblacklistAddress(address account) external onlyOwner {
        isBlacklisted[account] = false;
        emit AccountUnblacklisted(account);
    }

    // आपातकालीन स्थिति में सभी ट्रांसफर रोकने का फंक्शन
    function pause() external onlyOwner {
        _pause();
    }

    // ट्रांसफर दोबारा शुरू करने का फंक्शन
    function unpause() external onlyOwner {
        _unpause();
    }

    // हर ट्रांज़ैक्शन से पहले अवैध वॉलेट की जांच
    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Pausable) {
        require(!isBlacklisted[from], "Malik Security: Sender is blacklisted");
        require(!isBlacklisted[to], "Malik Security: Receiver is blacklisted");
        super._update(from, to, value);
    }
}
