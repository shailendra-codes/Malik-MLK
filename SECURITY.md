# 🔒 Security Policy — Malik (MLK) Protocol

## Supported Versions
Only the latest mainnet/testnet audited versions of **MalikToken** and **MalikBridge** are supported with active security monitoring.

| Contract | Version | Status |
| :--- | :--- | :--- |
| `MalikToken.sol` | v1.0.0 | Active & Protected |
| `MalikBridge.sol` | v1.0.0 | Active & Protected |

## Built-in Security Mechanisms
- **ReentrancyGuard:** Prevents recursive call exploits during asset conversion.
- **Pausable Circuit Breaker:** Allows instant emergency freeze if anomalous activity is detected.
- **AML Blacklist:** Prevents sanctioned or compromised wallets from interacting with the protocol.

## Reporting a Vulnerability
If you discover a security vulnerability, please do **not** open a public issue. Report it directly to the lead architect (**Shailendra Kumar Singh**) via GitHub Security Advisories.
 
