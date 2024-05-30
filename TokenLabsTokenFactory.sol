// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./ERCToken.sol";

contract TokenLabsTokenFactory is Ownable(msg.sender) {
    struct TokenInfo {string name; string symbol; address creator; uint256 creationDate; uint256 initialSupply; string imageUrl;}

    mapping(address => TokenInfo) public tokenInfo;
    mapping(address => address[]) public tokensCreatedBy;
    uint256 public creationFee = 0.0001 ether;

    event TokenCreated(address indexed tokenAddress, string name, string symbol, address creator, uint256 creationDate, uint256 initialSupply, string imageUrl);

    function setCreationFee(uint256 _fee) public onlyOwner { creationFee = _fee; }

    function createToken(string memory name, string memory symbol, uint256 initialSupply, string memory imageUrl) public payable returns (address newTokenAddress){
        require(msg.value >= creationFee, "Creation fee is not met");

        ERCToken newToken = new ERCToken(name, symbol, msg.sender, initialSupply); // Ajustar el constructor de ERCToken
        
        tokenInfo[address(newToken)] = TokenInfo(name,symbol,msg.sender,block.timestamp,initialSupply,imageUrl);

        tokensCreatedBy[msg.sender].push(address(newToken));

        emit TokenCreated(address(newToken),name,symbol,msg.sender,block.timestamp,initialSupply,imageUrl);

        payable(owner()).transfer(creationFee);
        if (msg.value > creationFee) { payable(msg.sender).transfer(msg.value - creationFee); }

        return address(newToken);

    }

    function getCreatedTokens(address creator) public view returns (address[] memory) { return tokensCreatedBy[creator]; }

    function withdraw() public onlyOwner { payable(owner()).transfer(address(this).balance); }
}
