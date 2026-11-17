// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MalikBridge is Ownable, ReentrancyGuard {
    IERC20 public malikToken;

    // 1 MLK = $1 USD (8 decimals precision के साथ, जैसे Chainlink Oracles में होता है)
    uint256 public constant MLK_USD_PRICE = 100000000; // $1.00000000

    // किसी भी करेंसी या कॉइन के लाइव रेट (USD के मुकाबले) सेव करने के लिए
    // उदाहरण: "INR" => 1190476 ($0.0119), "BTC" => 9000000000000 ($90,000)
    mapping(string => uint256) public assetUsdPrices;
    mapping(string => bool) public isAssetSupported;
    
    // दैनिक ट्रांज़ैक्शन लिमिट (अवैध बड़े ट्रांसफर रोकने के लिए - $10,000 प्रति दिन)
    uint256 public dailyLimit = 10000 * 10**18;
    mapping(address => uint256) public dailySpent;
    mapping(address => uint256) public lastResetDay;

    event AssetRateUpdated(string indexed symbol, uint256 usdPrice);
    event CurrencyConverted(
        address indexed user,
        string fromAsset,
        string toAsset,
        uint256 mlkAmount,
        uint256 convertedAmount
    );
    cocnstructor(address _malikTokenAddress) Ownable(msg.sender) {
        malikToken = IERC20(_malikTokenAddress);
    }// किसी भी ग्लोबल करेंसी (INR, EUR, JPY) या क्रिप्टो (BTC, ETH, SOL) का लाइव रेट सेट करना
    function updateAssetRate(string memory symbol, uint256 usdPriceIn8Decimals) external onlyOwner {
        require(usdPriceIn8Decimals > 0, "Invalid price");
        assetUsdPrices[symbol] = usdPriceIn8Decimals;
        isAssetSupported[symbol] = true;
        emit AssetRateUpdated(symbol, usdPriceIn8Decimals);
    }
    // कैलकुलेट करें कि दिए गए MLK कॉइन के बदले कितनी विदेशी करेंसी या क्रिप्टो मिलेगी
    function calculateConversion(uint256 mlkAmount, string memory targetSymbol) public view returns (uint256) {
        require(isAssetSupported[targetSymbol], "Asset not supported yet");
        uint256 targetUsdPrice = assetUsdPrices[targetSymbol];
        // फॉर्मूला: (MLK की संख्या * $1) / टारगेट करेंसी की कीमत
        return (mlkAmount * MLK_USD_PRICE) / targetUsdPrice;
    }
    // सुरक्षित कन्वर्ज़न और ब्रिज ट्रांसफर फंक्शन (AML Daily Limit के साथ)
    function bridgeConvert(
        uint256 mlkAmount,
        string memory fromSymbol,
        string memory toSymbol
    ) external nonReentrant {
        require(mlkAmount > 0, "Amount must be greater than 0");
        require(isAssetSupported[fromSymbol] && isAssetSupported[toSymbol], "Unsupported currency/coin");
     // दैनिक सुरक्षा लिमिट की जांच
        uint256 currentDay = block.timestamp / 1 days;
        if (lastResetDay[msg.sender] < currentDay) {
            dailySpent[msg.sender] = 0;
            lastResetDay[msg.sender] = currentDay;
        }
        require(dailySpent[msg.sender] + mlkAmount <= dailyLimit, "AML Security: Daily limit exceeded");
dailySpent[msg.sender] += mlkAmount;

        // यूज़र से MLK टोकन ब्रिज कॉन्ट्रैक्ट में लॉक करना
        require(malikToken.transferFrom(msg.sender, address(this), mlkAmount), "MLK transfer failed");

        uint256 convertedAmount = calculateConversion(mlkAmount, toSymbol);

        emit CurrencyConverted(msg.sender, fromSymbol, toSymbol, mlkAmount, convertedAmount);
    }
}
 
