// SPDX-License-Identifier: MIT

    pragma solidity >=0.7.0 <0.9.0;

    import "../openzeppelin/Ownable.sol";
    import "erc721a/contracts/ERC721A.sol";

    
    interface ERC2981Royalty {    
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount); 
    }

    contract GenesisDAO is ERC721A, Ownable {
    //using Strings for uint256;

    event Mint(address indexed to, uint256 amount);
    event Withdraw(address indexed receiver, uint256 amount);

    struct NFTMetadata {
        string uriSuffix;
        string metadata; // Stores the metadata JSON of each NFT
        address royaltyReceiver;
        uint256 royaltyPercentage;
    }

    address _contractOwner;
    string public baseURI;
    string private contractBaseURI;
    string private baseExtension = ".json";
    string private hiddenMessage = ""; // Set the hidden message
    uint256 private maxSupply = 650;
    uint256 private maxMintAmount = 5;
    uint256 private maxFreeMintPerStudentWallet = 5;
    uint256 private maxFreeMintPerTeacherWallet = 5;
    uint256 private pricePerNFT = 10000000000000000; // 0.01 ETH
    uint256 private publicSaleMaxMintPerWallet = 5;
    uint256 private whitelistStartTime;
    uint256 private whitelistDuration = 6 days;
    uint256 private publicDuration = 6 days;
    uint256 private publicStartTime;


    // Mapping from tokenId to creator's address
    mapping (uint256 => address) public tokenCreator;
    
    // Mapping from creator's address to their token count
    mapping (address => uint256) public creatorTokenCount;
    mapping(address => uint256) private _mintAmountPerWallet;
    mapping(address => uint256) private teacherHours;
    mapping (address => bool) public whitelist;
    mapping(address => bool) private whitelistClaimed;
    mapping(address => bool) private teacherList;
    mapping(address => bool) private studentList;
    mapping(uint256 => NFTMetadata) private _nftMetadata;
    mapping(uint256 => string) internal tokenURIs;

     // Mapping from tokenId to NFT Properties
    struct NFTProperties {
        string name;
        uint256 creationTime;
        string description;
    }
    mapping (uint256 => NFTProperties) public tokenProperties;

    
    
    constructor() ERC721A("Genesis Academy", "GNA") {
        baseURI = "";
        contractBaseURI = "";
        _contractOwner = msg.sender;
    }

    function setTeacherHours(address teacher, uint256 _hours) public onlyOwner {
        teacherHours[teacher] = _hours; 
    }

    function getTeacherHours(address teacher) public view returns (uint256) {
        return teacherHours[teacher];
    }

    function setTeacher(address teacher) public onlyOwner {
        require(!isTeacher(teacher), "setTeacher: The address is already a teacher");
        teacherList[teacher] = true;
    }

    function setStudent(address student) public onlyOwner {
        studentList[student] = true;
    }

     function addToWhitelist(address _addr) public onlyOwner {
        whitelist[_addr] = true;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function isTeacher(address wallet) public view returns (bool) {
        return teacherList[wallet];
    }

    function isStudent(address wallet) public view returns (bool) {
        return studentList[wallet];
    }

    function isSaleActive() public view returns (bool) {
        return isWhitelistActive() || isPublicActive();
    }

    function setWhitelistAndPublicSettings(
    uint256 _maxSupply,
    uint256 _maxMintAmount,
    uint256 _maxFreeMintPerStudentWallet,
    uint256 _maxFreeMintPerTeacherWallet,
    uint256 _pricePerNFT,
    uint256 _publicSaleMaxMintPerWallet,
    uint256 _whitelistStartTime,
    uint256 _whitelistDuration,  
    uint256 _publicStartTime,  
    uint256 _publicDuration
    ) public onlyOwner {
    require(_maxSupply >= totalSupply(), "setWhitelistAndPublicSettings: New max supply cannot be lower than the current total supply of tokens");
    maxSupply = _maxSupply;
    maxMintAmount = _maxMintAmount;
    maxFreeMintPerStudentWallet = _maxFreeMintPerStudentWallet;
    maxFreeMintPerTeacherWallet = _maxFreeMintPerTeacherWallet;
    pricePerNFT = _pricePerNFT;
    publicSaleMaxMintPerWallet = _publicSaleMaxMintPerWallet;
    whitelistStartTime = _whitelistStartTime;
    whitelistDuration = _whitelistDuration;

    publicStartTime = _publicStartTime;  
    publicDuration = _publicDuration;
    }

    modifier whitelistSaleIsActive() {  
        require(isWhitelistActive(), "Mint is not active");
        _;  
    }

    function freeMint(uint256 _mintAmount) public  whitelistSaleIsActive whenMintsNotPaused{
        require(whitelist[msg.sender], "Sender not whitelisted");
        require(isTeacher(msg.sender) || isStudent(msg.sender), "Not a teacher or student");
        require(_mintAmount <= maxMintAmount, "Mint amount exceeds max limit");
        require(!whitelistClaimed[msg.sender], "Already claimed free mint");
        require(_mintAmountPerWallet[msg.sender] + _mintAmount <= maxMintAmount, "Mint amount exceeds max limit per wallet");

        if (isTeacher(msg.sender)) {
            require(_mintAmount <= maxFreeMintPerTeacherWallet, "Mint amount exceeds max free mint for teacher");
        } else {
            require(_mintAmount <= maxFreeMintPerStudentWallet, "Mint amount exceeds max free mint for student");
        }
        emit Mint(msg.sender, _mintAmount);
        _customMint(msg.sender, _mintAmount, '', false);
        whitelistClaimed[msg.sender] = true;
    }

    modifier publicsaleIsActive() {
        require(isSaleActive(), "Mint is not active");
        _;
    }

    function publicSaleMint(uint256 _mintAmount) public payable publicsaleIsActive {
        require(whitelist[msg.sender], "Sender not whitelisted");
        require(_mintAmount <= publicSaleMaxMintPerWallet, "Mint amount exceeds max limit for public sale");
        require(_mintAmountPerWallet[msg.sender] + _mintAmount <= publicSaleMaxMintPerWallet, "Mint amount exceeds max limit per wallet");
        require(msg.value == pricePerNFT * _mintAmount, "Incorrect Ether value sent");
        _customMint(msg.sender, _mintAmount, '', false);
        emit Mint(msg.sender, _mintAmount); 
    }


    function _customMint(address to, uint256 _mintAmount, string memory _data, bool isFreeMint) internal {
        require(totalSupply() + _mintAmount <= maxSupply, "Max supply exceeded");

        // Additional code to keep track of the token creator and their token count
        tokenCreator[totalSupply() + 1] = to;
        creatorTokenCount[to] += _mintAmount;

        if(isFreeMint){
            // Do something if the mint is free
            whitelistClaimed[to] = true;
        } else {
            // Do something if the mint is paid
            require(msg.value == pricePerNFT * _mintAmount, "Incorrect Ether value sent");
        }
            
        if (bytes(_data).length > 0) {
            (string memory uriSuffix, string memory metadata, uint256 royaltyPercentage) = abi.decode(bytes(_data), (string, string, uint256));

            for (uint256 i = 0; i < _mintAmount; i++) {
                uint256 tokenId = totalSupply();
                _safeMint(to, tokenId);

        NFTMetadata memory newNFTMetadata = NFTMetadata({
            uriSuffix: uriSuffix, 
            metadata: metadata,      
            royaltyReceiver: address(0),  
            royaltyPercentage: royaltyPercentage  
        });

                _nftMetadata[tokenId] = newNFTMetadata;
            }
        } else {
            for (uint256 i = 0; i < _mintAmount; i++) {
                uint256 tokenId = totalSupply();
                _safeMint(to, tokenId);
                _mintAmountPerWallet[to] += _mintAmount;
            }
        }
    }

        function airdropTokens(address[] memory recipients, uint256[] memory tokenIds) public onlyOwner {
            require(recipients.length == tokenIds.length, "airdropTokens: recipients and tokenIds array length must match.");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 tokenId = tokenIds[i];

            // Make sure token exists and DAO owns it before airdrop
            require(_exists(tokenId), "airdropTokens: No such token.");
            require(ownerOf(tokenId) == msg.sender, "airdropTokens: Only the owner of the token can airdrop it.");

            // Transfer the token to the recipient
            transferFrom(msg.sender, recipient, tokenId);
        }
    }

    ///mudar tudo isso aqui ------->

    /*function contractURI() public view returns (string memory) {
        return contractBaseURI;
    }

    function setTokenURI(uint256 tokenId, string calldata _uri) public {
        tokenURIs[tokenId] = _uri;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        
        NFTMetadata storage metadata = _nftMetadata[tokenId];
    
        // Build the URI by concatenating the baseURI + tokenId + uriSuffix
        string memory currentBaseURI = _baseURI(); 
        return bytes(currentBaseURI).length > 0  
            ? string(
                abi.encodePacked(currentBaseURI, tokenId.toString(), metadata.uriSuffix)
            )
            : metadata.metadata; //If there isn't baseURI, return the metadata JSON
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setContractBaseURI(string memory _contractBaseURI) public onlyOwner {
        contractBaseURI = _contractBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setHiddenMessage(string memory newHiddenMessage) public onlyOwner {
        hiddenMessage = newHiddenMessage;
    }


    function getHiddenMessage() public view returns (string memory) {
        return hiddenMessage;
    }
    */

    //----------------------------------------------------------------------------------

    function isWhitelistActive() public view returns (bool) {
        return (block.timestamp >= whitelistStartTime && block.timestamp <= whitelistStartTime + whitelistDuration);  
    }

    function isPublicActive() public view returns (bool) {
        return (block.timestamp >= publicStartTime && block.timestamp <= publicStartTime + publicDuration);
    }
    function withdraw() public payable onlyOwner whenTxsNotPaused{
        require(payable(_contractOwner).send(address(this).balance), "Failed to send balance");
        emit Withdraw(_contractOwner, address(this).balance);
    }

    function setTokenRoyalty(uint256 tokenId, address _receiver, uint256 royaltyPercentage) public {
        require(_exists(tokenId), "setTokenRoyalty: No such token");
        require(ownerOf(tokenId) == msg.sender, "setTokenRoyalty: Only the owner of the token can set the royalty");
        require(royaltyPercentage <= 10000, "setTokenRoyalty: Royalty percentage exceeds max (10000)");

        NFTMetadata storage metadata = _nftMetadata[tokenId];
        metadata.royaltyReceiver = _receiver; 
        metadata.royaltyPercentage = royaltyPercentage;
    }   

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address, uint256) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        NFTMetadata storage royaltyData = _nftMetadata[_tokenId];
        uint256 royaltyAmount = (_salePrice * royaltyData.royaltyPercentage) / 10000;
        return (royaltyData.royaltyReceiver, royaltyAmount); 
    }

    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) { // Convert bytes32 into string
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
        
        }

    // General contract pause
    bool public paused = false;

        modifier whenNotPaused {  
        require(!paused, "The contract is paused");  
        _;  
    }

    function setPaused(bool _paused) public onlyOwner {
        paused = _paused; 
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    // Pause just mints
    bool public mintPaused = false;

        modifier whenMintsNotPaused {  
        require(!mintPaused, "Mints are paused");  
        _;  
    }

    function setMintPaused(bool _paused) public onlyOwner {
        mintPaused = _paused;  
    }

    function unpauseMints() public onlyOwner {
        mintPaused = false;
    }
    // Pause just transactions
    bool public txPaused = false;

        modifier whenTxsNotPaused {  
        require(!txPaused, "Transactions are paused");  
        _;
    }

    function setTxPaused(bool _paused) public onlyOwner {
         txPaused = _paused;
    }  

    function unpauseTransactions() public onlyOwner {
         txPaused = false;
    }

    function transferToTreasury() public onlyOwner {
    uint256 supply = totalSupply();
        for (uint256 i = 1; i <= supply; i++) {
            if (!_isTokenMinted(i)) {
                _safeMint(_contractOwner, i);
            } 
        }
    }

    function _isTokenMinted(uint256 tokenId) internal view returns (bool) {
    address owner = ownerOf(tokenId);
        return owner != address(0); 
    }

      function setTokenProperties(uint256 tokenId, string memory name, string memory description) public {
        require(_exists(tokenId), "setTokenProperties: No such token");
        require(ownerOf(tokenId) == msg.sender, "setTokenProperties: Only the owner of the token can set the properties");
        
        NFTProperties storage properties = tokenProperties[tokenId];
        properties.name = name;
        properties.description = description;
        properties.creationTime = block.timestamp;
    }

    function getTokenProperties(uint256 tokenId) public view returns (string memory name, uint256 creationTime, string memory description) {
        require(_exists(tokenId), "getTokenProperties: No such token");
        
        NFTProperties storage properties = tokenProperties[tokenId];
        return (properties.name, properties.creationTime, properties.description);
    }

    
}