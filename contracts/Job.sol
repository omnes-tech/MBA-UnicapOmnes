// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./iOmnes/IMentoring.sol";


/** @author Omnes Blockchain team www.omnestech.org (@Afonsodalvi, @G-Deps @EWCunha and @renancorreadev)
    @title ERC721A contract for smart contract course for law professionals
    ipfs: https://bafybeid7rsqvtd454ra4tkfa3y2vobmz75zexgxe6zndsj5jk23tbjdnsq.ipfs.nftstorage.link/
    */
contract Job is ERC721A, Pausable, Ownable, IMentoring {

    //erros
    error NonExistentTokenURI();
    error WithdrawTransfer();
    error MentoringNotApproved();
    error MintPriceNotPaid();

    
    string public baseURI;
    mapping(uint256 => string) public idURIs;
    mapping(address => bool) approveAdr;
    mapping(address => aboutMentoring) private interestList;

    // SFTRec settings -- omnesprotocol
    uint256 public price;  // full price per hour
    uint256 public maxDiscount;

    // Mentoring setting
    uint public priceSign; // payment sign

    constructor(string memory baseuri, uint256 _price, 
    uint256 _priceSign, string memory _nome, string memory _symbol)
    ERC721A(_nome, _symbol) {
       baseURI = baseuri;
       priceSign = _priceSign;
       price = _price;
       
    }

    function mintmMentoring() external payable whenNotPaused MentoringCompliance{
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`
        if (msg.value < price-((price*maxDiscount)/10000)) {
            revert MintPriceNotPaid();
        }
        _mint(msg.sender, 1);
    }

    function interest(uint256 _definiteHours, 
    string memory _name, string memory _email, string memory _socialnetwork) external payable{
        require(msg.value >= priceSign, "wrong price sign");
        interestList[msg.sender] = aboutMentoring(_definiteHours, _name, _email, _socialnetwork, false);
    
        emit addressAndCost(msg.sender, msg.value);
    }

    function acceptOmnes(address _user)external onlyOwner{
        interestList[_user].approved = true;
        emit acceptOmnesConculting(_user);
    }

    function mintAllowed(address _to) external payable addrApprove{
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(_to, 1);
    }

    //set functions

    function setApprAddr(address _addrApprove, bool aprovar)external onlyOwner{
        approveAdr[_addrApprove] = aprovar;
        emit addrApproved(_addrApprove, aprovar);
    }

    function setURI(string memory newUri)external onlyOwner{
        baseURI = newUri;
    }

    function setTokenIdURI(string memory _idURI, uint256 _id) external onlyOwner{
        if (!_exists(_id)) revert URIQueryForNonexistentToken();
        string memory newidURI = _idURI; // insert / after IPFS link CID to work properly
        idURIs[_id] = newidURI;
    }

    function setPrices(uint256 _priceperHour, uint256 _priceSign) external onlyOwner{
        price = _priceperHour;
        priceSign = _priceSign;
    }

    function setMaxdiscont(uint256 _maxDiscont)external onlyOwner{
        maxDiscount = _maxDiscont;
    }

    // Souldbound token delimitations
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal override(ERC721A){
        require(from == address(0) || to == address(0), 
        "Not allowed to transfer token");
    }

    function _afterTokenTransfers(address from,
        address to,
        uint256 startTokenId,
        uint256 quantity) override internal {
        if (from == address(0)) {
            emit Attest(to, startTokenId);
        } else if (to == address(0)) {
            emit Revoke(to, startTokenId);
        }
    }

    function revoke(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    // returns functions
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseuRI = _baseURI();
        string memory json = ".json";
        if (!compareStrings(idURIs[tokenId],baseuRI)) {
        return bytes(idURIs[tokenId]).length != 0 ? string(abi.encodePacked(idURIs[tokenId], _toString(tokenId), json)) : '';
        } else { 
        return bytes(baseuRI).length != 0 ? string(abi.encodePacked(baseuRI, _toString(tokenId), json)) : '';
        }
    }

    function pause() public onlyOwner{
        _pause();
    }

    function unpause() public onlyOwner{
        _unpause();
    }

    //returns
    function _baseURI() internal view override returns (string memory){
        return baseURI;
    }

    function mentoringData(address _mentored) external override view onlyOwner returns (aboutMentoring memory) {
        return(interestList[_mentored]);
    }

     //withdraw Functions
    function withdrawPayments(address payable payee) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = payee.call{value: balance}("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }

    //Helpers functions
    function compareStrings(string memory a, string memory b) internal pure returns(bool){
        return (keccak256(abi.encodePacked(a)) ==  keccak256(abi.encodePacked(b)));
    }

    //Modifiers 
    modifier addrApprove(){
        require(approveAdr[msg.sender], "not approve");
        _;
    }

    modifier MentoringCompliance(){
        uint256 discont = price - priceSign;
        require(msg.value >= price * interestList[msg.sender].definiteHours - discont, "wrong price");
        if(!interestList[msg.sender].approved) revert MentoringNotApproved();
        _;
    }

}