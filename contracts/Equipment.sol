// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Equipment is ERC1155, Ownable {

    event joinedParty(address user, uint256 partyId);
    event leftParty(address user, uint256 partyId);

	// @param _uri Intial uri location 
    constructor(string memory _uri) ERC1155(_uri) {}

    // @notice Update the uri location
    // @param _newuri New uri value
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

	// party/token id => creators addr
    mapping (uint256 => address) public creators;

	// party/token id => all addresses that have ever joined
    mapping (uint256 => address[]) public eventAttendance;

	// keeping track of # of participants at the event
	// party/token id => number of participants
    mapping (uint256 => uint) public eventParticipants;

    // id => (owner => balance)
    mapping (uint256 => mapping(address => uint256)) internal balances;

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
    function createParty(uint256 _initialSupply, string calldata _uri) external returns(uint256 _id) {
        _id = ++nonce;
        creators[_id] = msg.sender;
        balances[_id][address(this)] = _initialSupply;

        // Transfer event with mint semantic
        emit TransferSingle(msg.sender, address(0x0), address(this), _id, _initialSupply);
        eventParticipants[_id] = 0;

        uint256 index = eventParticipants[_id];

        eventAttendance[_id][index] = msg.sender;
        eventParticipants[_id] = eventParticipants[_id] + 1;
        emit joinedParty(msg.sender, _id);

        // Storing data using events (if too complex just store it onchain)
        if (bytes(_uri).length > 0)
            emit URI(_uri, _id);
    }

    // @notice Function called by attendees when joining a party
    // note : stop user joining twice
    function joinParty(uint256 _id) public {
        require(msg.sender != creators[_id], "Host cannot join own party");
        require(eventParticipants[_id] < balances[_id][address(this)], "Party is already full");

        emit joinedParty(msg.sender, _id);

        eventAttendance[_id][eventParticipants[_id]] = msg.sender;
        eventParticipants[_id] = eventParticipants[_id] + 1;
    }

    // @notice Function called by attendees to leave a party
    function leaveParty(uint256 _id) public {
        emit leftParty(msg.sender, _id);
        eventParticipants[_id] = eventParticipants[_id] - 1;
    }

    // @notice This function should only be called once the event is finished
    // @dev Allow users to have only one or multiple?
    function mintAndDistribute(uint256 _id) external creatorOnly(_id) {

        for (uint256 i = 0; i < eventAttendance[_id].length; ++i) {

            address to = eventAttendance[_id][i];

            balances[_id][to] = 1 + balances[_id][to];

            // Emit the Transfer/Mint event.
            // the 0x0 source address implies a mint
            // It will also provide the circulating supply info.
            emit TransferSingle(msg.sender, address(this), to, _id, 1);
        }
        balances[_id][address(this)] = 0;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return balances[id][account];
    }

    // @notice This function should only be called once the event is finished
    // @dev Allow users to have only one or multiple?
    function mintToAddresses(uint256 _id, address[] calldata _attendees) external creatorOnly(_id) {

        for (uint256 i = 0; i < _attendees.length; ++i) {

            address to = _attendees[i];

            balances[_id][to] = 1 + balances[_id][to];

            // Emit the Transfer/Mint event.
            // the 0x0 source address implies a mint
            // It will also provide the circulating supply info.
            emit TransferSingle(msg.sender, address(this), to, _id, 1);
        }
    }

    function setURI(string calldata _uri, uint256 _id) external creatorOnly(_id) {
        emit URI(_uri, _id);
    }
}
