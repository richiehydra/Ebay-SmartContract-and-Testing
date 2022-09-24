const Ebay = artifacts.require("Ebay");
const { expectRevert } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const { assert } = require("console");

contract("Ebay SmartContract Testing", (accounts) => {
   let count=0;
    var contract;
    before("Smart Contract Instance", async () => {
        contract = await Ebay.deployed();
        console.log(`The Contract Address is: ${contract.address}`)
    })
    beforeEach(async () => {
        count++;
        console.log(`The Test no : ${count}`);
    })
    const auction =
    {
        name: "NFT",
        description: "Best Nft in the World",
        min: 10
    }
    const [seller,buyer1,buyer2]=[accounts[0],accounts[1],accounts[2]];

    it("Test for createAuction and getAuction functions ", async () => {

        await contract.createAuction(auction.name, auction.description, auction.min);
        const response = await contract.getAuctions();
        assert(response.length === 1);
        assert(response[0].name === auction.name);
        assert(response[0].description === auction.description)
        const result = response[0].min;
        assert(parseInt(result) === auction.min)
    })

    it("Test for not creating an offer if price is lessthan minimum price",async()=>
    {
        await expectRevert( contract.createOffer(1,{from:buyer1,value:auction.min-1}),"Amount Not Sufficient")
    })

    it("Test for Creating the Offer",async()=>
    {
        await contract.createOffer(1,{from:buyer1,value:auction.min});

    })

    it("Test for  Doing Transaction ",async()=>
    {
      const bestprice=web3.utils.toBN(auction.min+10);
      await contract.createOffer(1,{from:buyer2,value:bestprice})
      const balanceBefore=web3.utils.toBN(await web3.eth.getBalance(seller));
   
      await contract.transaction(1,{from:accounts[4]});
      const balanceAfter=web3.utils.toBN(await web3.eth.getBalance(seller));
   
      assert(balanceAfter.sub(balanceBefore).eq(bestprice));
            
    })
})