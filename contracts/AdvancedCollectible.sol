// SPDX-License-Identifier: MIT

pragma solidity 0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {
    uint256 public tokenCounter;
    bytes32 public keyHash;
    uint256 public fee;
    enum Animal {MONKEY, TIGER, CROCODILE, DUMBO, REINDEER, ELEPHANT, DONKEY, BEAR, CRICKET, CAT, UNICORN, HUSKY, OCTOPUS, BABYSEAL, OWL, SEAL, POLARBEAR, OTTER, PANDA, PUG}
    mapping(uint256 => Animal) public tokenIdToAnimal;
    mapping(bytes32 => address) public requestIdToSender;
    event requestedCollectible(bytes32 indexed requestId, address requester);
    event animalAssigned(uint256 indexed tokenId, Animal animal);

    constructor(address _vrfCoordinator, address _linkToken, bytes32 _keyHash, uint256 _fee) public
        VRFConsumerBase(_vrfCoordinator, _linkToken)
        ERC721("ZooAnimal", "ZOO")
    {
        tokenCounter = 0;
        keyHash = _keyHash;
        fee = _fee;
    }

    function createCollectible() public returns (bytes32) {
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestIdToSender[requestId] = msg.sender;
        emit requestedCollectible(requestId, msg.sender);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
        Animal animal = Animal(randomNumber % 20);
        uint256 newTokenId = tokenCounter;
        tokenIdToAnimal[newTokenId] = animal;
        emit animalAssigned(newTokenId, animal);
        address owner = requestIdToSender[requestId];
        _safeMint(owner, newTokenId);
        tokenCounter = tokenCounter + 1;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not owner nor approved!");
        _setTokenURI(tokenId, _tokenURI);
    }
}