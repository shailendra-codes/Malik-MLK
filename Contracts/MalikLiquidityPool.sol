// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
contract MalikLiquidityPool is Ownable, ReentrancyGuard {
    IERC20 public malikToken;uint256 public totalPoolLiquidity;
    mapping(address => uint256) public providerBalances;    // लिक्विडिटी पूल में MLK जमा करने का फंक्शन
    function depositLiquidity(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(malikToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
providerBalances[msg.sender] += amount;
        totalPoolLiquidity += amount;
emit LiquidityAdded(msg.sender, amount);
    }
    // अपनी जमा की गई लिक्विडिटी वापस निकालने का फंक्शन
    function withdrawLiquidity(uint256 amount) external nonReentrant {
        require(providerBalances[msg.sender] >= amount, "Insufficient pool balance");
       providerBalances[msg.sender] -= amount;
        totalPoolLiquidity -= amount;
require(malikToken.transfer(msg.sender, amount), "Withdraw failed");
emit LiquidityRemoved(msg.sender, amount);
    }
}
 
