# Flekos
A collection of 10K auto-generated NFTs created to build community around them. Cross-chain. Free mint. No roadmap. Just flekos and its community.

# Contracts
[Optimism](https://optimistic.etherscan.io/address/0xaab7a7a301f19b8482d6c4942e0ef977d4361e42)

[Arbitrum](https://arbiscan.io/address/0xaab7a7a301f19b8482d6c4942e0ef977d4361e42)

[Avalanche](https://snowtrace.io/address/0xaab7a7a301f19b8482d6c4942e0ef977d4361e42)

[Fantom](https://ftmscan.com/address/0xaab7a7a301f19b8482d6c4942e0ef977d4361e42)

[Binance](https://bscscan.com/address/0xaab7a7a301f19b8482d6c4942e0ef977d4361e42)

[Polygon](https://polygonscan.com/address/0xaab7a7a301f19b8482d6c4942e0ef977d4361e42)

[Ethereum](https://etherscan.io/address/0x16dfc67641218a1d6404b2b91350ac78110d56ac)

# Contract functions
### constructor
> constructor(string memory baseURI_, string memory fatherURI_, address _layerZeroEndpoint)

### mint
> mint(uint8 numTokens) external payable

### traverseChains
> traverseChains(uint16 _chainId, uint256 tokenId) public payable

### tokenURI
> tokenURI(uint256 tokenId) public view override returns (string memory)

### setBaseURI
> setBaseURI(string memory URI) external onlyOwner

### setFatherURI
> setFatherURI(string memory URI) external onlyOwner

### claimOwnership
> claimOwnership() external payable

### donate
> donate() external payable

### withdraw
> withdraw(uint256 amt) external onlyOwner

### setGasForDestinationLzReceive
> setGasForDestinationLzReceive(uint256 newVal) external onlyOwner

### _LzReceive
> _LzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal override

### _baseURI
> _baseURI() internal view override returns (string memory)

### _fatherURI
> _fatherURI() internal view returns (string memory)

# Fleko father
The **fleko father** is the main NFT of the collection and represents the fleko with id 0 (**fleko #0**). It has a special role within the contract allowing the call to the **claimOwnership** function that conveys ownership of the contract in a genuine and distinct way.
> The one who owns the **fleko father** can directly claim ownership of the contract without the need for it to be passed on by the current owner.

In this way, the **actual owner** of the contract will always be the owner of the **fleko father**. At the same time, this will allow they to use an NFT as the main representative of the flekos project and have the ability to transfer ownership on a contractive basis.
