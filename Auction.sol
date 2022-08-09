//SPDEX-licensce-Identifier:unlicensced
pragma solidity >= 0.5.0 < 0.9.0;

contract Auction
{
uint public highestbid;
address  public  highestbidder ;
address public owner ;
constructor()
{
    owner=msg.sender;
}

address[] public Bidders;
mapping(address=>uint)BalanceOf;
function bid()public payable
{
    require(msg.value > 1 ether,"The bidding amount must be atleast greater1 ether");
    Bidders.push(msg.sender);
    require(msg.value > highestbid,"The biddingamount at present is greater than your bid");
    if(highestbid == 0)
    {
    highestbid=msg.value;
    highestbidder=msg.sender;
    payable(owner).transfer(msg.value);
    BalanceOf[owner]=BalanceOf[owner]+msg.value; 
    }
    else
    {
    highestbid=msg.value;
    highestbidder=msg.sender;
    payable(owner).transfer(msg.value);
    BalanceOf[owner]=BalanceOf[owner]+msg.value;
    }
    
}
function GetHighestBidder()  public view returns(address)
{
require(msg.sender==owner,"Only owner can call theSE");
return highestbidder;

}

function GetbalanceofOwner() public view  returns(uint)
{
    require(msg.sender==owner,"Only owner can call theSE");
    return BalanceOf[owner];
}

function getallBidders() public view returns( address [] memory)
{
    return Bidders; 
}
function withdrawamount() payable public
{
    require(msg.sender==owner,"Only owner can be able to call these");
    payable(highestbidder).transfer(msg.value);
    BalanceOf[owner]=BalanceOf[owner]-msg.value;
}
}