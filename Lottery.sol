//SPDEX-Licensce-Identifer:UNDEFINED;
//Smart Contract for lotter application
pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    address public manager;
    address[] public customers;
    uint public index;
    uint public winningAmount;
    uint public TotalPlayers;

    //the one who deploys the contract is the manager
    constructor() {
        manager = msg.sender;
        TotalPlayers=customers.length;
     
    }

    //Function for getting entry fees from customers who want to participate in the lottery and further push them onto the array
    function entryFee() public payable {
        //it checks whether the participant have provided one ether or not
        require(msg.value == 1 ether, "You must Have to provide one ether");
        //if provided one ther push to the array of customers
        customers.push(msg.sender);
    }

    function random() public view returns (uint) {
        //generates a random hash
        return uint(keccak256(abi.encode(block.timestamp, customers)));
    }

    function PickWinner() public  returns(uint){
        require(
            msg.sender == manager,
            "Only manager can pick the Random Winner"
        );
        //picks the random number between the index
        index=random()%customers.length;
      return index;
    }

    function Transfer()public payable 
    {
          require(
            msg.sender == manager,
            "Only manager can pick the Random Winner"
        );
        payable(customers[index]).transfer(address(this).balance);
    }
}