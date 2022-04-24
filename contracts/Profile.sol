//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Equipment.sol";

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

    event profileCreated(address owner, uint256 id);

    // @notice Makes sure that the caller is the nft owner
    modifier isOwner() {
        uint256 id = super.tokenOfOwnerByIndex(msg.sender, 0);
        require(super.ownerOf(id) == msg.sender, "caller is not the owner of the profile");
        _;
    }

    constructor() ERC721("Looking For Party Profile", "LFP") {
    }

    // @notice Function to mint new profiles
    // @params _details Initial details to mint nft with
    function mintProfile(string memory _name, string memory _description, string memory _uri) public {
        //require(mintedProfile[msg.sender] == false, "Owner has already minted a profile");
        Details memory details = Details(_name, _description, _uri);
        uint256 id = numUsers;
        _mint(msg.sender, numUsers);
        mintedProfile[msg.sender] = true;
        profileDetails[id] = details;
        emit profileCreated(msg.sender, id);
        numUsers += 1;
    }

    // @notice Getter for a user's profile details
    // @param _id Id of the profile to query
    function getProfileDetails(uint256 _id) external view returns(Details memory) {
        return profileDetails[_id];
    }

    // @notice Chage the user's name
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

    // @notice Change a token's Uri (image hosting)
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
