//SPDEX-Licensce-Identifer:UNDEFINED;
pragma solidity >0.5.0 < 0.9.0;

contract EventOrganization
{
    struct Event
    {
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }
    mapping(uint=>Event)public Events;
    mapping(address=>mapping(uint=>uint))public tickets;

    uint public nextId;

    function CreateEvent(string memory _name,uint _date,uint _price,uint _TicketCount)public
    {
        require(_date>block.timestamp,"You can only organize event for Future use");
        require(_TicketCount>0,"You have to provider tickets greater than zero");
        Events[nextId]=Event(msg.sender,_name,_date,_price,_TicketCount,_TicketCount);
        nextId++;
    }
    function Buy(uint _id,uint quantity)public payable 
    {
        
          require(Events[_id].date > block.timestamp,"The Event has already Finished Up");
          require(msg.value>=(Events[_id].price*quantity),"Please Provide Required Amount of Money To buy the tickets");
          require(Events[_id].ticketRemain>=quantity,"Not Enough Tickets to buy");
          Events[_id].ticketRemain=Events[_id].ticketRemain-quantity;
          tickets[msg.sender][_id]+=quantity;
    }
    function transfer(uint _id,uint quantity,address to)public payable
    {

          require(Events[_id].date > block.timestamp,"The Event has already Finished Up");
          require(tickets[msg.sender][_id]>=quantity,"You dont have enough quantity of tickets to transfer");
         tickets[msg.sender][_id]-=quantity;
         tickets[to][_id]-=quantity;
    }
}