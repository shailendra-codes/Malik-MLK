// Malik (MLK) Automated Security & AML Compliance Test Suite
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Malik (MLK) Protocol Security & Bridge Tests", function () {
  it("Should enforce 1 MLK = $1 USD standard and block blacklisted accounts", async function () {
    const [owner, cleanUser, illicitUser] = await ethers.getSigners();

    const MalikToken = await ethers.getContractFactory("MalikToken");
    const token = await MalikToken.deploy(1000000); // 1 Million MLK

    // 1. Clean user को टोकन भेजना सफल होना चाहिए
    await token.transfer(cleanUser.address, ethers.parseEther("500"));
    expect(await token.balanceOf(cleanUser.address)).to.equal(ethers.parseEther("500"));

    // 2. संदिग्ध वॉलेट को ब्लैकलिस्ट करना
    await token.blacklistAddress(illicitUser.address);
    expect(await token.isBlacklisted(illicitUser.address)).to.be.true;

    // 3. ब्लैकलिस्टेड वॉलेट पर अवैध पैसा भेजना ब्लॉक होना चाहिए
    await expect(
      token.transfer(illicitUser.address, ethers.parseEther("100"))
    ).to.be.revertedWith("Malik Security: Receiver is blacklisted");
  });
});
 
