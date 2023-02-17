// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTDutchAuction {

    uint256 public reservePrice;
    uint256 public numBlocksAuctionOpen;
    uint256 public auctionOpenedOn;
    uint256 public offerPriceDecrement;
    uint256 public initialPrice;
    
    address  public sellerAddress;
    address public winnerAddress;
    bool public auctionOpen;
    bool public amountSent;

    address public collectionAddress;
    uint256 public nftTokenID;

    constructor(address erc721TokenAddress, uint256 _nftTokenId, uint256 _reservePrice, uint256 _numBlocksAuctionOpen, uint256 _offerPriceDecrement)  {
        
        require(_reservePrice > 0);
        reservePrice = _reservePrice;
        require(_numBlocksAuctionOpen > 0);
        numBlocksAuctionOpen = _numBlocksAuctionOpen; 
        auctionOpenedOn = block.number;
        require(_offerPriceDecrement > 0);
        offerPriceDecrement = _offerPriceDecrement;
        sellerAddress = msg.sender;

        initialPrice = reservePrice + numBlocksAuctionOpen * offerPriceDecrement;

        auctionOpen = true;
        amountSent = false;

        collectionAddress = erc721TokenAddress;
        nftTokenID = _nftTokenId;
        
    }

    function bid() public payable returns(address) {

        require(IERC721(collectionAddress).ownerOf(nftTokenID) == sellerAddress, "Seller does not own nft");

        require(block.number < auctionOpenedOn + numBlocksAuctionOpen, "Auction expired");

        require(auctionOpen, "Auction not open");
        
        require(initialPrice - (block.number - auctionOpenedOn) * offerPriceDecrement <= msg.value, 
                "Offer less than currentPrice");

        require(msg.sender == tx.origin); // only allow EOA

        auctionOpen = false;
        amountSent = true;
        _transferNFT(msg.sender);
        _transfer(sellerAddress, msg.value);
        

        return msg.sender;
    }

    function nop() public returns(bool) {
        return true;
    }

    function _transfer(address  _to, uint256 amount) internal {
        (bool success, ) = _to.call{value:amount}("");
        require(success, "Transfer failed.");
    }

    function _transferNFT(address  _to) internal {
        IERC721(collectionAddress).safeTransferFrom(sellerAddress,_to,nftTokenID);
    }

}
