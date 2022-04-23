// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Equipment is IERC1155, Ownable {

    event joinedParty(address user, uint256 partyId);
    event leftParty(address user, uint256 partyId);

	// @param _uri Intial uri location 
    constructor(string memory _uri) ERC1155(_uri) {}

    // @notice Update the uri location
    // @param _newuri New uri value
    function setURI(string memory newuri) public onlyOwner {
        super._setURI(newuri);
    }

	// party/token id => creators addr
    mapping (uint256 => address) public creators;

	// party/token id => attendees
    // eventId => (possible attendee => attending?)
    mapping (uint256 => mapping(address => bool)) public events;
	// party/token id => all addresses that have ever joined
    mapping (uint256 => address[]) public eventAttendance;

    // id => (owner => balance)
    mapping (uint256 => mapping(address => uint256)) internal balances;

    // token id => uri [Keeping track of each party's nft uri]
    mapping (uint256 => string) internal tokenUri;

    // A nonce to ensure we have a unique id each time we mint.
    uint256 public nonce = 0;

    // @notice Modifier to ensure only the asset creator is calling a function
    modifier creatorOnly(uint256 _id) {
        require(creators[_id] == msg.sender);
        _;
    }

    // @notice Creates a new token type and assings contract holds initial supply
    // @param _initialSupply The max number of attendees
    // @param _uri The uri location for the event equiptment
    function createParty(uint256 _numberOfMembers, string calldata _uri) external returns(uint256 _id) {
        _id = ++nonce;
        creators[_id] = msg.sender;
        balances[_id][address(this)] = _numberOfMembers;
        tokenUri[_id] = _uri;

        // Transfer event with mint semantic
        emit TransferSingle(msg.sender, address(0x0), address(this), _id, _numberOfMembers);

        // Storing data using events (if too complex just store it onchain)
        if (bytes(_uri).length > 0)
            emit URI(_uri, _id);
    }

    // @notice Function called by attendees when joining a party
    function joinParty(uint256 _id) public {
        require(msg.sender != creators[_id], "Host cannot join own party");
        require(!events[_id][msg.sender], "User is already part of the party");
        require(eventAttendance[_id].length >= super.balanceOf(address(this), _id), "Party is currently full");
        events[_id][msg.sender] = true;
        emit joinedParty(msg.sender, _id);
    }

    // @notice Function called by attendees to leave a party
    function leaveParty(uint256 _id) public {
        events[_id][msg.sender] = false;
        emit leftParty(msg.sender, _id);
    }

    // @notice This function should only be called once the event is finished
    // @dev Allow users to have only one or multiple?
    function mintAndDistribute(uint256 _id) external creatorOnly(_id) {

        for (uint256 i = 0; i < eventAttendance[_id].length; ++i) {

            address to = eventAttendance[_id][i];

            // check if the address is attending
            if (events[_id][to])
                // Grant the items to the caller
                balances[_id][to] = 1 + balances[_id][to];

            balances[_id][address(this)] = 0;

            // Emit the Transfer/Mint event.
            // the 0x0 source address implies a mint
            // It will also provide the circulating supply info.
            emit TransferSingle(msg.sender, address(this), to, _id, 1);
        }
    }

    // @notice This function should only be called once the event is finished
    // @dev Allow users to have only one or multiple?
    function mintToAddresses(uint256 _id, address[] calldata _attendees) external creatorOnly(_id) {

        for (uint256 i = 0; i < _attendees.length; ++i) {

            address to = _attendees[i];

            // check if the address is attending
            if (events[_id][to])
                // Grant the items to the caller
                balances[_id][to] = 1 + balances[_id][to];

            // Emit the Transfer/Mint event.
            // the 0x0 source address implies a mint
            // It will also provide the circulating supply info.
            emit TransferSingle(msg.sender, address(this), to, _id, 1);
        }
    }

    function setURI(uint256 _id, string calldata _uri) external creatorOnly(_id) {
        tokenUri[_id] = _uri;
        emit URI(_uri, _id);
    }

    function balanceOf(address account, uint256 tokenId) external view returns (uint256) {
        return balances[tokenId][account];
    }
	
    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balances[tokenId][account];
        }

        return batchBalances;
    }
}
