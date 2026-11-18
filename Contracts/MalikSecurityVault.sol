// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MalikSecurityVault is ReentrancyGuard {
    IERC20 public malikToken;   
    // 3 सुरक्षित एडमिन वॉलेट्स (जिनमें से कम से कम 2 की मंज़ूरी अनिवार्य है)
    address[3] public guardians;
    mapping(address => bool) public isGuardian;  
    // बड़े ट्रांसफर पर 24 घंटे का सुरक्षा ताला (Time-Lock)
    uint256 public constant TIMELOCK_DELAY = 24 hours;
    struct TransferRequest {
        address to;
        uint256 amount;
        uint256 unlockTime;
        uint8 approvals;
        bool executed;
        bool cancelled;
    }
    uint256 public requestCount;
    mapping(uint256 => TransferRequest) public requests;
    mapping(uint256 => mapping(address => bool)) public hasApproved;

    event TransferProposed(uint256 indexed id, address indexed proposer, address to, uint256 amount, uint256 unlockTime);
    event TransferApproved(uint256 indexed id, address indexed guardian);
    event TransferExecuted(uint256 indexed id, address to, uint256 amount);
    event TransferCancelled(uint256 indexed id, address indexed guardian);

    modifier onlyGuardian() {
        require(isGuardian[msg.sender], "MalikVault: Unauthorized access blocked");
        _;
    }  
    // वॉल्ट बनाते समय 3 अलग-अलग सुरक्षित वॉलेट एड्रेस सेट होंगे
    malikToken = IERC20(_malikToken);
        for (uint8 i = 0; i < 3; i++) {
            require(_guardians[i] != address(0), "Invalid guardian address");
            require(!isGuardian[_guardians[i]], "Duplicate guardian");
            guardians[i] = _guardians[i];
            isGuardian[_guardians[i]] = true;
        }
    }
    // 1. टोकन निकालने का प्रस्ताव डालना (24 घंटे का टाइमर शुरू होगा)
    function proposeTransfer(address to, uint256 amount) external onlyGuardian returns (uint256) {
        require(to != address(0) && amount > 0, "Invalid transfer parameters");
       
        requestCount++;
        requests[requestCount] = TransferRequest({
            to: to,
            amount: amount,
            unlockTime: block.timestamp + TIMELOCK_DELAY,
            approvals: 1,
            executed: false,
            cancelled: false
        }); 
        hasApproved[requestCount][msg.sender] = true;
        emit TransferProposed(requestCount, msg.sender, to, amount, block.timestamp + TIMELOCK_DELAY);
        return requestCount;
    }
    // 2. दूसरे सुरक्षित वॉलेट से मंज़ूरी (2nd Signature) देना
    function approveTransfer(uint256 requestId) external onlyGuardian {
        TransferRequest storage req = requests[requestId];
        require(!req.executed && !req.cancelled, "Request inactive");
        require(!hasApproved[requestId][msg.sender], "Already approved by this guardian");

        hasApproved[requestId][msg.sender] = true;
        req.approvals += 1;
        emit TransferApproved(requestId, msg.sender);
    }
    // 3. हैकिंग की आशंका होने पर किसी भी गार्डियन द्वारा तुरंत ट्रांसफर रद्द करना
    function cancelTransfer(uint256 requestId) external onlyGuardian {
        TransferRequest storage req = requests[requestId];
        require(!req.executed && !req.cancelled, "Cannot cancel");
       
        req.cancelled = true;
        emit TransferCancelled(requestId, msg.sender);
    }
    // 4. 24 घंटे पूरे होने और 2 मंज़ूरी मिलने के बाद ही टोकन बाहर निकलेंगे
    function executeTransfer(uint256 requestId) external onlyGuardian nonReentrant {
        TransferRequest storage req = requests[requestId];
        require(!req.executed && !req.cancelled, "Request inactive");
        require(req.approvals >= 2, "Security Alert: Minimum 2 Guardian approvals required");
        require(block.timestamp >= req.unlockTime, "Security Alert: 24-hour Time-Lock active");

        req.executed = true;
        require(malikToken.transfer(req.to, req.amount), "Vault transfer failed");

        emit TransferExecuted(requestId, req.to, req.amount);
    }
}
 
