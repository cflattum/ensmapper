//SPDX-License-Identifier: MIT
/*
_____ _    _ _____ _____ _____ ___________
|_   _| |  | |_   _/  ___|_   _|  ___|  _  \
  | | | |  | | | | \ `--.  | | | |__ | | | |
  | | | |/\| | | |  `--. \ | | |  __|| | | |
  | | \  /\  /_| |_/\__/ / | | | |___| |/ /
  \_/  \/  \/ \___/\____/  \_/ \____/|___/
 _____ _    _ _____  ___   _   __ _____
|_   _| |  | |  ___|/ _ \ | | / //  ___|
  | | | |  | | |__ / /_\ \| |/ / \ `--.
  | | | |/\| |  __||  _  ||    \  `--. \
  | | \  /\  / |___| | | || |\  \/\__/ /
  \_/  \/  \/\____/\_| |_/\_| \_/\____/
  Twisted Tweaks / 2021
*/
//test chang3
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity ^0.8.0;



contract TwistedTweaks is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string public baseURI;
    string public baseExtension = ".json";
    uint256 public cost = 0.06 ether;
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmount = 10;
    uint256 public maxPerWallet = 100;
    
    mapping (address => uint256) private walletCap;
    mapping (address => uint256) private ogTweakPresaleList;

    bool private _isOgPresaleActive;
    bool private _isSaleActive;

    constructor(
        string memory _initBaseURI
    ) ERC721("Twisted Tweaks", "TT10K") {
        setBaseURI(_initBaseURI);
        _isOgPresaleActive = false;
        _isSaleActive = false;
    }
    
    function isOgPresaleActive() external view returns (bool) {
        return _isOgPresaleActive;
    }
    
    function isSaleActive() external view returns (bool) {
        return _isSaleActive;
    }
    
    function getTotalSupply() external view returns (uint256) {
        return totalSupply();
    }
    
    function addToOgPresaleList(address entry, uint256 claimable) external onlyOwner {
        require(entry != address(0), "NULL_ADDRESS");
        require(ogTweakPresaleList[entry] == 0, "DUPLICATE_ENTRY");

        ogTweakPresaleList[entry] = claimable;

    }

    function removeFromOgPresaleList(address entry) external onlyOwner {
        require(entry != address(0), "NULL_ADDRESS");

        ogTweakPresaleList[entry] = 0;
    }
    
    function getClaimsByAddress(address entry) public view onlyOwner returns (uint256) {
        return ogTweakPresaleList[entry];
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
    
     // @dev Pre-Presale Mint for OG Tweak holders
    // @param _mintAmount The tokens a user wants to purchase
    // @param _to Address to mint to
    function mintOgPresale(
        address _to,
        uint256 _mintAmount
    ) external payable {
        uint256 supply = totalSupply();
        require(_isOgPresaleActive, "Presale not active");
        require(!_isSaleActive, "Cannot mint while main sale is active");
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);
        require(ogTweakPresaleList[_to] > 0, "Wallet not on OG presale list.");
        require((ogTweakPresaleList[_to] - _mintAmount) >= 0, "OG Tweak holders can only mint 5 tweaks max in this presale");
        require(walletCap[_to] <= maxPerWallet, "Can't mint more than the wallet cap");
        require(walletCap[_to] + _mintAmount <= maxPerWallet, "Can't mint more than the wallet cap");

        ogTweakPresaleList[_to] -= _mintAmount;
        walletCap[_to] += _mintAmount;

        for(uint256 i = 1; i < _mintAmount; i++) {
            _safeMint(_to, supply + i);
        }
    }

    // public
    function mint(address _to, uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!_isOgPresaleActive);
        require(_isSaleActive);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);
        require(msg.value >= cost * _mintAmount);
        require(walletCap[_to] <= maxPerWallet, "Can't mint more than the wallet cap");
        require(walletCap[_to] + _mintAmount <= maxPerWallet, "Can't mint more than the wallet cap");
        
        walletCap[_to] += _mintAmount;

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(_to, supply + i);
        }
    }

    // @dev Private mint function reserved for company.
    // @param _to The user receiving the tokens
    // @param _mintAmount The number of tokens to distribute
    function mintToAddress(address _to, uint256 _mintAmount) external onlyOwner {
        require(_isSaleActive, "Sale has not concluded");
        require(_mintAmount > 0, "You can only mint more than 0 tokens");

        uint256 supply = totalSupply();
        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(_to, supply + i);
        }
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    //only owner
    function setCost(uint256 _newCost) public onlyOwner() {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function flipSaleState() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }
    
    function flipOgPresaleState() public onlyOwner {
        _isOgPresaleActive = !_isOgPresaleActive;
    }

    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}