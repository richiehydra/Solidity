//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.0 <0.9.0; // ---------------------------------------------------------------------------- // EIP-20: ERC-20 Token Standard // https://eips.ethereum.org/EIPS/eip-20 // -----------------------------------------

interface ERC20Interface {
    
function totalSupply() external view returns (uint); 
function balanceOf(address tokenOwner) external view returns (uint balance); 
function transfer(address to, uint tokens) external returns (bool success);
function allowance(address tokenOwner, address spender) external view returns (uint remaining);
function approve(address spender, uint tokens) external returns (bool success);
function transferFrom(address from, address to, uint tokens) external returns (bool success);
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Block is ERC20Interface{ 
string public name="Block";
string public symbol ="BLK";
string public decimal="0";
uint public override totalSupply;
address public founder;
mapping(address=>uint) public balances;
mapping(address=>mapping(address=>uint)) allowed;

constructor(){
    totalSupply=100000;
    founder=msg.sender;
    balances[founder]=totalSupply;
}

function balanceOf(address tokenOwner) public view override returns(uint balance){
    return balances[tokenOwner];
}

function transfer(address to,uint tokens) public override virtual returns(bool success){
    require(balances[msg.sender]>=tokens);
    balances[to]+=tokens; //balances[to]=balances[to]+tokens;
    balances[msg.sender]-=tokens;
    emit Transfer(msg.sender,to,tokens);
    return true;
}

function approve(address spender,uint tokens) public override returns(bool success){
    require(balances[msg.sender]>=tokens);
    require(tokens>0);
    allowed[msg.sender][spender]=tokens;
    emit Approval(msg.sender,spender,tokens);
    return true;
}

function allowance(address tokenOwner,address spender) public view override returns(uint noOfTokens){
    return allowed[tokenOwner][spender];
}

function transferFrom(address from,address to,uint tokens) public override virtual returns(bool success){
    require(allowed[from][to]>=tokens);
    require(balances[from]>=tokens);
    balances[from]-=tokens;
    balances[to]+=tokens;
    return true;
}
}
contract ICO is Block
{
    address payable public manager;
    uint public raisedAmount;
    uint public cap=300 ether;
    address payable public deposit;
    uint public Tokenprice=0.1 ether;
    uint public icostart=block.timestamp;
    uint public icoend=block.timestamp+3600;
    uint public maxInvest=10 ether;
    uint public minInvest=0.1 ether;

    enum state
    {
        beforeStart,
        afterEnd,
        running,
        hault
    }
   
    state public icostate;

    constructor(address payable _deposit)
    {
        deposit=payable(_deposit);
        manager=payable(msg.sender);
        icostate=state.beforeStart;
    }
    modifier onlyManger()
    {
        require(msg.sender==manager,"Only Manager Can call these");
         _;
    }

    function hault()public onlyManger
    {
        icostate=state.hault;
    }
    function resume()public onlyManger
    {
        icostate=state.running;
    }
    function changeDeposit(address payable newdeposit)public onlyManger
    {
        deposit=payable(newdeposit);
    }

    function getState()public view returns(state)
    {
        if(block.timestamp<icostart)
        {
            return state.beforeStart;
        }
        else if (block.timestamp>icoend)
        {
            return state.afterEnd;
        }
        else if(block.timestamp>=icostart && block.timestamp<icoend)
        {
            return state.running;
        }
        else
        {
            return state.hault;
        }
    }

    function invest()payable public  returns(bool)
    {
     state icocurrentstate=getState();
     require(icocurrentstate==state.running,"Ico Is Currently Not Running");
     require(msg.value>=minInvest && msg.value<=maxInvest,"Amount Overflow or Underflow");
     raisedAmount=raisedAmount+msg.value;
     uint tokens=msg.value/Tokenprice;
     balances[msg.sender]=balances[msg.sender]+tokens;
     balances[founder]=balances[founder]-tokens;
     deposit.transfer(msg.value);
     return true;
    }
    function burn()public onlyManger returns(bool)
    {
        state icoprsentstate=getState();
        require(icoprsentstate==state.afterEnd,"Only After End of ICO");
        balances[founder]=0;
        return true;
    }
  

   receive() external payable {}

}
