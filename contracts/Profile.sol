//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Profile is ERC721, Ownable {
    string private name;
    string private description;
    string private tokenURI;
    uint256 private numUsers = 1;
    mapping(address => bool) public mintedProfile;

    function setName(string memory _name) public {
        name = _name;
    }

    constructor() ERC721("Looking For Party Profile", "LFP") {
    }

    function mintProfile() public {
        require(mintedProfile[msg.sender] == false, "Owner has already minted a profile");
        mintedProfile[msg.sender] = true;
        _mint(msg.sender, numUsers);
    }
    
}
