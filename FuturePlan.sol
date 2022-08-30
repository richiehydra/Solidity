// A Contract on Crpto-For-Future
//SPDEX-Licensce-Identifier:MIP
pragma solidity^0.8.7;

contract CryptoKids
{
    address public dad;

    constructor()
    {
        dad=msg.sender;
    }

    modifier OnlyDad()
    {
        require(msg.sender==dad,"Only Dad can be able to access these ");
        _;
    }

    struct Kid 
    {
        address walletaddress;
        string firstname;
        string lastname;
        uint born_date;
        uint amount_deposited;
        uint releaseDate;
        uint balance;
    }
 
   Kid[] public kids;
   

   function addKid(address _walletaddress,string memory _firstname, string memory _lastname,uint _born_date,uint _amount_deposited,uint _releaseDate)public OnlyDad
        {
       
       kids.push(Kid(_walletaddress,_firstname,_lastname,_born_date,_amount_deposited,_releaseDate,0));

        }

    function getBalanceof(uint index)view public returns(uint)
    {
        return kids[index].balance;
    }

function Transfer(uint _amount,uint index)public OnlyDad
{
require(_amount > 0 ,"Amount must be greater than zero");
kids[index].balance=kids[index].balance+_amount;
}

function withdrawal(uint value,uint index)public returns(string memory)
{
    require(msg.sender==kids[index].walletaddress ,"You are Accessing some Others Account!");
    require(kids[index].balance >= value,"You Dont Have Sufficient Balance to Withdraw");
    if(block.timestamp>=kids[index].releaseDate)
    {
        kids[index].balance=kids[index].balance-value;
        return "You have withdrawn the Amount ! Thank You!";
    }
    else
    {
        return "Sorry You are Not Eligible To Withdraw The Amount Now!!";
    }

}
}

