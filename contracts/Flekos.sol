// SPDX-License-Identifier: MIT

/*
................................................................................
.........&&&&&&.................................................................
.........&&&...............................&&&&&&....................&&&&&&.....
......&&&&&&&&&...&&&&&......&&&&&&........&&&.......................&&&........
......&&&&&&   ...&&.........&&&...........&&&...   .................&&&........
......   &&&......&&.........&&&&&&   .....&&&&&&......&&&&&%%%......&&&........
......   &&&......&&.........&&&&&&   .....&&&&&&......&&&&&%%%......&&&........
.........&&&......&&.........&&&...........   &&&......&&&..&&&......   ........
.........%%%......  &&&%%%...&&&&&&%%%..%%%&&&...%%%...&&&&&   ...%%%&&&........
................................................................................
An NFT collection minted across different chains.
*/

import "contracts/interfaces/ILayerZeroUserApplicationConfig.sol";

import "contracts/NonblockingReceiver.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

pragma solidity ^0.8.7;

contract flekos is Ownable, ERC721, NonblockingReceiver {
    using Strings for uint256;

    address public _owner;
    string private baseURI;
    string private fatherURI;
    uint256 nextTokenId = 0;
    uint256 MAX_MINT = 10000;

    uint256 gasForDestinationLzReceive = 350000;

    constructor(string memory baseURI_, string memory fatherURI_, address _layerZeroEndpoint)
        ERC721("Flekos", "FLK")
    {
        _owner = msg.sender;
        endpoint = ILayerZeroEndpoint(_layerZeroEndpoint);
        baseURI = baseURI_;
        fatherURI = fatherURI_;
        _safeMint(_owner, nextTokenId); // mint father fleko on deploy
    }

    // mint function
    // you can choose to mint 1 or 2
    // mint is free, but payments are accepted
    function mint(uint8 numTokens) external payable {
        require(numTokens < 3, "Flekos contract: Max 2 NFTs per transaction");
        require(
            nextTokenId + numTokens <= MAX_MINT,
            "Flekos contract: Mint exceeds supply"
        );
        _safeMint(msg.sender, ++nextTokenId);
        if (numTokens == 2) {
            _safeMint(msg.sender, ++nextTokenId);
        }
    }

    // This function transfers the nft from your address on the
    // source chain to the same address on the destination chain
    function traverseChains(uint16 _chainId, uint256 tokenId) public payable {
        require(
            msg.sender == ownerOf(tokenId),
            "You must own the token to traverse"
        );
        require(
            trustedRemoteLookup[_chainId].length > 0,
            "This chain is currently unavailable for travel"
        );

        // burn NFT, eliminating it from circulation on src chain
        _burn(tokenId);

        // abi.encode() the payload with the values to send
        bytes memory payload = abi.encode(msg.sender, tokenId);

        // encode adapterParams to specify more gas for the destination
        uint16 version = 1;
        bytes memory adapterParams = abi.encodePacked(
            version,
            gasForDestinationLzReceive
        );

        // get the fees we need to pay to LayerZero + Relayer to cover message delivery
        // you will be refunded for extra gas paid
        (uint256 messageFee, ) = endpoint.estimateFees(
            _chainId,
            address(this),
            payload,
            false,
            adapterParams
        );

        require(
            msg.value >= messageFee,
            "Flekos contract: msg.value not enough to cover messageFee. Send gas for message fees"
        );

        endpoint.send{value: msg.value}(
            _chainId, // destination chainId
            trustedRemoteLookup[_chainId], // destination address of nft contract
            payload, // abi.encoded()'ed bytes
            payable(msg.sender), // refund address
            address(0x0), // 'zroPaymentAddress' unused for this
            adapterParams // txParameters
        );
    }

    // ERC721 tokenURI function override to allow a different URI for tokenId 0
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory bURI;
        if (tokenId == 0) { bURI = _fatherURI(); }
        else { bURI = _baseURI(); }
        return bytes(bURI).length > 0 ? string(abi.encodePacked(bURI, tokenId.toString())) : "";
    }

    function setBaseURI(string memory URI) external onlyOwner {
        baseURI = URI;
    }

    // Set URI for father fleko (with tokenId = 0)
    function setFatherURI(string memory URI) external onlyOwner {
        fatherURI = URI;
    }

    // You can claim the ownership of the contract if you are the owner of the fleko father.
    function claimOwnership() external payable {
        require(msg.sender == ownerOf(0), "Flekos contract: You have to be the owner of the fleko father");
        _transferOwnership(msg.sender);
    }

    function donate() external payable {
        // thank you! <3
    }

    // This allows the devs to receive kind donations
    function withdraw(uint256 amt) external onlyOwner {
        (bool sent, ) = payable(_owner).call{value: amt}("");
        require(sent, "Flekos contract: Failed to withdraw");
    }

    // Just in case this fixed variable limits us from future integrations
    function setGasForDestinationLzReceive(uint256 newVal) external onlyOwner {
        gasForDestinationLzReceive = newVal;
    }

    // ------------------
    // Internal Functions
    // ------------------

    function _LzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal override {
        // decode
        (address toAddr, uint256 tokenId) = abi.decode(
            _payload,
            (address, uint256)
        );

        // mint the tokens back into existence on destination chain
        _safeMint(toAddr, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _fatherURI() internal view returns (string memory) {
        return fatherURI;
    }
}