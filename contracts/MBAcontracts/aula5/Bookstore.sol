// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';

contract Bookstore is ERC1155{

	mapping(uint256 => BookDetails) private _BookDetails;
	
    struct BookDetails{
	address author;
	string title;
	uint256 copies;
	}

	uint256 public tokenCounter;

	constructor() ERC1155("http://")
	{
		tokenCounter=0;
		}

	function publish(string memory _title,uint256 _copies) public {

	uint256 newTokenId = tokenCounter+1;
	_BookDetails[newTokenId].author=msg.sender;
	_BookDetails[newTokenId].title=_title;
	_BookDetails[newTokenId].copies=_copies;
	_mint(msg.sender,newTokenId,_copies,"");
	tokenCounter+=1;
		}

	function Approve(address operator) public{ 
        //temos que dar o aprove para quem quiser comprar o do autor
		require(operator!=msg.sender); 
		setApprovalForAll(operator, true);
		}

	function purchaseFromAuthor(uint256 TokenId, uint256 _copies) public{
        //comprando depois da aprovação
		safeTransferFrom(_BookDetails[TokenId].author,msg.sender,TokenId,_copies,"");
		}

	function TitleOfTheBook (uint256 BookId) public view returns (string memory){
	
		return(_BookDetails[BookId].title);
		}

	function TotalCopiesOfTheBook (uint256 BookId) public view returns(uint256){

		return (_BookDetails[BookId].copies);
	}

	function AuthorOfTheBook (uint256 BookId) public view returns (address){
	
		return (_BookDetails[BookId].author);
	}
}