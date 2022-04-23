//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

// @title Looking For Party Profile Contract
// @notice simple metadata is stored onchain, image stored on ipfs
contract Profile is ERC721, ERC721Enumerable {

    // Struct to hold simple metadata for each NFT
    struct Details {
        string name;
        string description;
        string uri; // token uri
    }

    // Each addr is only allowed to mint once
    // also acts as a unique ID for each NFT (incremental)
    uint256 private numUsers = 1;

    // User is only allowed to mint one profile
    mapping(address => bool) public mintedProfile;

    // Mapping to hold profile metadata for each NFT
    mapping(uint256 => Details) public profileDetails;

    event profileCreated();

    // Makes sure that the caller is the nft owner
    modifier isOwner() {
        uint256 id = super.tokenOfOwnerByIndex(msg.sender, 0);
        require(super.ownerOf(id) == msg.sender, "caller is not the owner of the profile");
        _;
    }

    constructor() ERC721("Looking For Party Profile", "LFP") {
    }

    // @notice Function to mint new profiles
    function mintProfile(Details memory _details) public {
        uint256 id = super.tokenOfOwnerByIndex(msg.sender, 0);
        require(mintedProfile[msg.sender] == false, "Owner has already minted a profile");
        mintedProfile[msg.sender] = true;
        _mint(msg.sender, numUsers);
        profileDetails[id] = _details;
    }

    // @notice Getter for a user's profile details
    function getProfileDetails() external view returns(Details memory){
        uint256 id = super.tokenOfOwnerByIndex(msg.sender, 0);
        return profileDetails[id];
    }

    // @params _name new Name
    function setName(string memory _name) public isOwner() {
        uint256 id = super.tokenOfOwnerByIndex(msg.sender, 0);
        profileDetails[id].name = _name;
    }

    // @params description New description
    function setDescription(string memory _description) public isOwner() {
        uint256 id = super.tokenOfOwnerByIndex(msg.sender, 0);
        profileDetails[id].description = _description;
    }

    // @params uri New uri
    function setUri(string memory _uri) public isOwner() {
        uint256 id = super.tokenOfOwnerByIndex(msg.sender, 0);
        profileDetails[id].description = _uri;
    }

    // [FUNCTION OVERRIDING FOR ERC721Enumerable]
	function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}
