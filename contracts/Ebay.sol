//SPDX-License-Identifier: UNLICENSED

pragma solidity >= 0.5.0 < 0.9.0;

contract Ebay
{
    
    struct Auction
    {
        uint id;
        address payable seller;
        string name;
        string description;
        uint min;
        uint bestofferid;
        uint[] offersid;
    }
  
   struct Offers
   {
       uint id;
       uint auctionid;
       address payable buyer;
       uint price;
   }

   mapping(uint=>Auction) private auctions;
   mapping(uint=>Offers) private offers;
   mapping(address=>uint[]) private auctionList;
   mapping(address=>uint[]) private offersList;
   uint private newAuctionId=1;
   uint private newOffersId=1;

   function createAuction(string calldata _name,string calldata _description,uint _minprice)external
   {
     require(_minprice>0,"Minimum Price Cant be Negative or Zero");
     uint[] memory offersids=new uint[](0);
     auctions[newAuctionId]=Auction(newAuctionId,payable(msg.sender),_name,_description,_minprice,0,offersids);
     auctionList[msg.sender].push(newAuctionId);
     newAuctionId++;
   }

   function createOffer(uint _auctionid)external payable{
       Auction storage auction=auctions[_auctionid];
       Offers storage BestOffer=offers[auction.bestofferid];
       require(msg.value>=auction.min && msg.value > BestOffer.price,"Amount Not Sufficient");
       auction.bestofferid=newOffersId;
       auction.offersid.push(newOffersId);
       offers[newOffersId]=Offers(newOffersId,_auctionid,payable(msg.sender),msg.value);
       offersList[msg.sender].push(newOffersId);
       newOffersId++;
   }
   
   function transaction(uint _auctionId)external 
   {
       Auction storage auction=auctions[_auctionId];
       Offers storage BestOffer=offers[auction.bestofferid];

       for(uint i=0;i<auction.offersid.length;i++)
       {
           uint offersid=auction.offersid[i];
           if(offersid!=auction.bestofferid)
           {
               Offers storage offer=offers[offersid];
               offer.buyer.transfer(offer.price);
           }

       }
       auction.seller.transfer(BestOffer.price);
   }



   function getAuctions()external view returns(Auction[] memory)
   {
       Auction[] memory _auctions=new Auction[](newAuctionId-1);

       for(uint i=1;i<newAuctionId;i++)
       {
           _auctions[i-1]=auctions[i];
       }
       return _auctions;
   }
   
}