// SPDX-License-Identifier: MIT

    pragma solidity >=0.8.4 <0.8.20;

    import "@openzeppelin/contracts/access/Ownable2Step.sol";
    import "@openzeppelin/contracts/security/Pausable.sol";
    import "erc721a/contracts/ERC721A.sol";
    import "@openzeppelin/contracts/interfaces/IERC2981.sol";
    import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
    import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
    import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
    import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

    contract GenesisDAO is ERC721A, IERC2981, ERC165, Ownable2Step, Pausable {

    uint96 constant ROYALTY_FEE = 1000; //10%

    //wrong pricing error
    error MintPriceNotPaid();

    event Withdraw(address indexed receiver, uint256 amount);
    event WithdrawToken(address indexed receiver, address token, uint256 amount);

    string public baseURI;
    string private contractBaseURI;
    string private hiddenMessage = ""; // Set the hidden message

    //bytes32 immutable public merkleRoot;

    uint256 private maxSupply = 650;
    uint256 private maxMintAmount = 5;

    uint256 private price = 0.01 ether;
    //discont for Omnes Protocol
    uint public maxDiscount;

    uint256 private whitelistStartTime;
    uint256 private whitelistDuration = 6 days;
    uint256 private publicStartTime;
    uint256 private publicDuration = 6 days;

    mapping(address => bool) private whitelistClaimed;
    mapping(address => bool) public approvedProtocol;
  
    constructor(string memory newBaseURI, string memory _contractBaseURI, string memory _hiddenMessage /*,bytes32 _merkleRoot*/) 
    ERC721A("Genesis Academy", "GNA") {
        baseURI = newBaseURI;
        contractBaseURI = _contractBaseURI;
        hiddenMessage = _hiddenMessage;
        //merkleRoot = _merkleRoot; 
    }

    function setWhitelistAndPublicSettings(
    uint256 _maxSupply,
    uint256 _maxMintAmount,
    uint256 _price,
    uint256 _whitelistStartTime,
    uint256 _whitelistDuration,  
    uint256 _publicStartTime,  
    uint256 _publicDuration
    ) public onlyOwner {
    require(_maxSupply >= totalSupply(), "setWhitelistAndPublicSettings: New max supply cannot be lower than the current total supply of tokens");
    maxSupply = _maxSupply;
    maxMintAmount = _maxMintAmount;
    price = _price;
    whitelistStartTime = _whitelistStartTime;
    whitelistDuration = _whitelistDuration;
    publicStartTime = _publicStartTime;  
    publicDuration = _publicDuration;
    }

    modifier freeMintIsActive() {  
        require(isWhitelistActive(), "Mint is not active");
        _;  
    }

    modifier publicSaleIsActive() {  
        require(isPublicActive(), "Mint is not active");
        _;  
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function isWhitelistActive() public view whenNotPaused returns (bool) {
        return (block.timestamp >= whitelistStartTime && block.timestamp <= whitelistStartTime + whitelistDuration);  
    }

    function isPublicActive() public view whenNotPaused returns (bool) {
        return (block.timestamp >= publicStartTime && block.timestamp <= publicStartTime + publicDuration);
    }

    /*function freeMint(address account, uint256 amount, bytes32[] calldata proof) public freeMintIsActive {
        require(!whitelistClaimed[account], "Already claimed");
        require(MerkleProof.verify(proof, merkleRoot, keccak256(bytes.concat(keccak256(abi.encode(account, amount))))), "Invalid merkle proof");
        _safeMint(account, amount);
        whitelistClaimed[account] = true;
    }*/

    function mint(uint256 _mintAmount) public payable publicSaleIsActive {
        require(_numberMinted(msg.sender) + _mintAmount <= maxMintAmount, "Mint amount exceeds max limit per wallet");
        require(msg.value >= price * _mintAmount, "Incorrect Ether value sent");
        _customMint(msg.sender, _mintAmount);
    }

    function mintProtocol(uint256 _mintAmount)public payable complianceProtocol(_mintAmount){
        _customMint(msg.sender, _mintAmount);
    }

    function _customMint(address account, uint256 amount) internal {
        require(totalSupply() + amount <= maxSupply, "Max supply exceeded");
        _safeMint(account, amount);
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        require(_nextTokenId() == 0, "Mint is started");
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setContractBaseURI(string memory _contractBaseURI) public onlyOwner {
        contractBaseURI = _contractBaseURI;
    }

    function contractURI() public view returns (string memory) {
        return contractBaseURI;
    }

    function getHiddenMessage() public view returns (string memory) {
        return hiddenMessage;
    }

    function transferToTreasury() public onlyOwner {
        _mint(owner(), maxSupply - _nextTokenId());
    }

    function withdraw() public onlyOwner{
        require(payable(owner()).send(address(this).balance), "Failed to send balance");
        emit Withdraw(owner(), address(this).balance);
    }

    function withdrawToken(address _tokenContract, uint256 _amount) public onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer( owner(), _amount);
    }

    function withdrawNft(address _nftContract, uint256 _tokenId) public onlyOwner {
        IERC721 nftContract = IERC721(_nftContract);
        nftContract.transferFrom( address(this), owner(), _tokenId);
    }

    function royaltyInfo(uint256,uint256 salePrice) public view returns (address, uint256){
        uint256 royaltyAmount = (salePrice * ROYALTY_FEE) / 10000;

        return (owner(), royaltyAmount);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC165, IERC165) returns (bool) {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return ERC721A.supportsInterface(interfaceId) || 
        interfaceId == type(IERC2981).interfaceId || 
        ERC165.supportsInterface(interfaceId);
    }

    //omnes protocol

    function setprice(uint256 _price)external onlyOwner{
        price = _price;
    }

    function setMaxdiscont(uint256 _maxDiscont)external onlyOwner{
        maxDiscount = _maxDiscont;
    }

    function setApprProtocol(address _addr)external onlyOwner{
        approvedProtocol[msg.sender]=true;
    }

    modifier complianceProtocol(uint256 _mintAmount){
        require(!approvedProtocol[msg.sender], "address not approval for omnesprotocol");
        require (msg.value >= price * _mintAmount-(((price* _mintAmount)* maxDiscount)/10000), "Incorrect Ether value sent");
        _;
    }
}