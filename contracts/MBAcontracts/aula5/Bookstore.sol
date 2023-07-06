// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

//responsável por armazenar o metadado por IDs

//https://polygonscan.com/token/0xA2b52aDeB011BfC82C1cEDd9420F159433a53E5E#writeContract 

contract Bookstore is ERC1155URIStorage {

    mapping(uint256 => BookDetails) private _BookDetails;

    mapping(address => bool) public allowAdress;
    string public name = "Book-StoreMBA";
    string public symbol = "BOOKMBA";

    struct BookDetails {
        address author;
        string title;
		string benefits;
        uint256 copies;
    }

    uint256 public tokenCounter;

    //https://nft.storage/ -- baixe o aplicativo em sua máquina para inserir pastas

    constructor() ERC1155("") {
        tokenCounter = 0;
        allowAdress[msg.sender] = true;
    }

    //publique seu livro ou qualquer outra coisa
    function publish(
        string memory _title,
        uint256 _copies,
		string memory _benefitis,
        string memory _myUri
    ) public {
        uint256 newTokenId = tokenCounter + 1;
        _BookDetails[newTokenId] = BookDetails({
            author: msg.sender,
            title: _title,
			benefits: _benefitis,
            copies: _copies
        });

        //contabiliza o NFT para ser o próximo id corretamente
        tokenCounter += 1;
        _setURI(newTokenId, _myUri); //vamos setar aqui o metadado
        //https://bafybeiaovxrwhbliwzwrcxgakzxrs55me6ulryfk7iwkqajipt2g5le5tq.ipfs.nftstorage.link/book.json
        _mint(msg.sender, newTokenId, _copies, "");
    }

    function Approve(address operator) public {
        //temos que dar o aprove para quem quiser comprar do do autor e chamamos o contrato principal
        setApprovalForAll(operator, true);
    }

    function purchaseFromAuthor(uint256 TokenId, uint256 _copies) public {
        //comprando depois da aprovação -- só funciona depois de aprovarmos
        safeTransferFrom(_BookDetails[TokenId].author, msg.sender, TokenId, _copies, "");
    }

    function TitleOfTheBook(uint256 BookId) public view returns (string memory) {
        return (_BookDetails[BookId].title);
    }

    function TotalCopiesOfTheBook(uint256 BookId) public view returns (uint256) {
        return (_BookDetails[BookId].copies);
    }

    function AuthorOfTheBook(uint256 BookId) public view returns (address) {
        return (_BookDetails[BookId].author);
    }

    function setURI(uint256 _id, string memory _newUri) external AllowList {
        _setURI(_id, _newUri);
    }

    function setAllow(address _allowAddr, bool _allow) external AllowList {
        allowAdress[_allowAddr] = _allow;
    }

	function setBenefits(string memory _benefitis, uint _id) external{
		require(_BookDetails[_id].author == msg.sender, "you are not the author");
		_BookDetails[_id].benefits = _benefitis;
	}

	function myBenefits(uint _idNFT)external view returns(string memory){
		require(balanceOf(msg.sender, _idNFT) >= 1, "You don't have any books from this collection");
		return _BookDetails[_idNFT].benefits;
	}

    modifier AllowList() {
        require(!allowAdress[msg.sender], "address not allowed");
        _;
    }
}