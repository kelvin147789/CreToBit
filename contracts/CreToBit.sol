pragma solidity >=0.4.22 <0.8.0;
// SPDX-License-Identifier: MIT

contract CreToBit 
{
    

    // supply according to ico eth ,all remaining would be burn

    // 

 event Transfer(address indexed from, address indexed to, uint tokens);
 event Burn(address indexed burner, uint value);
 event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

  address public owner;
  string public name = "CreToBit";
  string public constant symbol = "CTB";
  uint8 public constant decimals = 18;

  
  uint totalSupply_ = 2000000000000000000;

  mapping (address=> uint) public balances;
  mapping(address=> uint) public depositedCTB;
  mapping(address=> uint) public depositedETH;
  uint public debitFactor = 200000000000000000;
  uint public creditFactor = 1050000000000000000;
  uint public governanceFactor = 500000000000000000;
  uint public icoLateRate = 950000000000000000;
  uint public icoEnd = block.timestamp + 30 days;
  uint public totalDepositedCTB;
  uint public totalDepositedETH;
  bool public isIcoEnd;
  address public ctbAddress;

  uint public ethtouint = 1000000000000000000;
  uint public uinttoeth = 1;
  
  
//   uint public testNumber = SafeMath.sub(1, 2);
  uint public borrowFactor = 100000000000000000;
  uint public boostBorrowFactorIndex = 500000000000000000;
  uint public boostBorrowFactor2x = 2000000000000000000;
  uint public preboostOffsetFactor = 900000000000000000;
  uint public boostIncentive = 5000000000000000;
  uint public timelock = 2 minutes;

  uint public borrowX = 9;
  uint public borrowY = 10;
  mapping (address => uint) public nextAvailablePayBackTime;

  mapping(address => mapping (address => uint)) allowed;

  





 
 
  

  

  

  
  
  
 constructor() public
  {
      totalSupply_ = totalSupply();
      owner = msg.sender;
      balances[msg.sender] = 1000000000000000000;
       ctbAddress = address(this);
      
      
  }

  function returnCTBAddress()public view returns(address)
  {
      return address(this);
  }

  function returnDepositCTB() public view returns (uint){
      return depositedCTB[msg.sender];
  }

  //   Transfer ownership 
  function transferOwnership() public returns(address)
  {
      require(msg.sender == owner);
      owner = msg.sender;
      return msg.sender;
  }

  function returnDepositETH() public view returns (uint){
      return depositedETH[msg.sender];
  }

  function icoCTB() payable public {
      require(!isIcoEnd);
      uint amountToBuy = msg.value;
      uint contractBalance = CreToBit.balanceOf(address(this));
      require(amountToBuy > 0 && amountToBuy <= contractBalance, "You need to send ether or ico end");
      if (contractBalance > 500)
      {
          CreToBit.transfer(msg.sender, amountToBuy);
      }

      CreToBit.transfer(msg.sender, amountToBuy * icoLateRate);

  }

  function makeIcoEnd() public {
      require(msg.sender == owner);
      isIcoEnd = true;
  }

  function icoBurn() public  {
      require(msg.sender == owner || block.timestamp > icoEnd);
      uint burnTokenAmount = balances[address(this)];
      totalSupply_ = totalSupply_ -= burnTokenAmount;
      emit Burn (address(this),burnTokenAmount);
      emit Transfer(address(this),address(0),burnTokenAmount);
      isIcoEnd = true;

  }

  function()  payable external{}

  function burnToken(uint _amount) public {
      require(msg.sender == owner);
      emit Burn (msg.sender,_amount);
      emit Transfer(msg.sender, address(0), _amount);
  }

  function totalETH() public view returns (uint)
    {   
        // return totalDepositedETH;
        return address(this).balance;
    }

   function totalSupply() public view returns (uint) 
   {
        return totalSupply_;
   }

   function allowance(address _owner, address delegate) public view returns (uint) {
       return allowed[_owner][delegate];
   }

  
 function balanceOf(address tokenOwner) public view returns (uint) {
       return balances[tokenOwner];
   }
 
  // Before this, make sure contract have enough ETH
  function borrowETH(address payable _to,uint _amount)  public payable returns(uint){
      
      
    //   require(depositedCTB[msg.sender] <= 0 && depositedETH[msg.sender] >= 0);
      nextAvailablePayBackTime[msg.sender] = nextAvailablePayBackTime[msg.sender] += timelock;
      depositedCTB[msg.sender] += _amount;
      totalDepositedCTB += _amount;
      CreToBit.transfer(address(this), _amount);
      uint actualWithdrawlETH = (_amount * debitFactor);
      depositedETH[msg.sender] -= actualWithdrawlETH;
      totalDepositedETH -= actualWithdrawlETH;
      _to.transfer(_amount *borrowX/borrowY);
     
    // CTB  Address transfer ETH to msg.sender 
     
    //   transfer(msg.sender,actualWithdrawlETH);
    //   receiver.call.value(_amount)("");
      
      
    return _amount;
      
 
  }

//   Delete after
  function withDrawlAllETH(uint _amount) public {
      require(msg.sender == owner);
      msg.sender.transfer(_amount);
  }

  function paybackETH(uint _amount) payable public returns (uint){
      address receiver = msg.sender;
      uint depositETH = _amount;
      require(block.timestamp > nextAvailablePayBackTime[msg.sender] && depositETH >= depositedCTB[msg.sender] * creditFactor && depositedCTB[msg.sender] > 0);
    //   msg.sender transfer eth to contract
      depositedETH[msg.sender] += depositETH;
      totalDepositedETH += depositETH;
      msg.sender.transfer(depositETH);
      depositedCTB[msg.sender] -= depositETH;
      totalDepositedCTB -= depositETH;   
      CreToBit.transfer(receiver, depositETH);
      return depositETH;

  }

  function adjustDebitFactor(uint _amount) public payable returns (uint){
      require(msg.sender == owner || balances[msg.sender] >= balances[address(this)]);
      debitFactor == _amount;
      return debitFactor;
  }

  function adjustCrebitFactor(uint _amount) public payable returns (uint){
      require( msg.sender == owner || balances[msg.sender] >= balances[address(this)]);
      creditFactor == _amount;
      return creditFactor;
  }

  function boostBorrowFactor() public returns (uint){
      require(totalDepositedETH * boostBorrowFactorIndex >= totalDepositedCTB * borrowFactor * preboostOffsetFactor);
      borrowFactor = borrowFactor * boostBorrowFactor2x;
      mint(totalSupply_);
    //   Booster get 0.5% incentive of totalSupply,to increase autonomy
      CreToBit.transfer(msg.sender,boostIncentive);
      return totalSupply_;
  }


  function transfer(address receiver, uint numTokens) public returns (bool) {
       require(numTokens <= balances[msg.sender]);
       balances[msg.sender] = balances[msg.sender]-=numTokens;
       balances[receiver] = balances[receiver]+=numTokens;
       emit Transfer(msg.sender, receiver, numTokens);
       return true;
   }

   function mint(uint amount) public  returns(bool){
    require( totalDepositedETH * boostBorrowFactorIndex >= totalDepositedCTB * borrowFactor * preboostOffsetFactor );
    require(totalSupply_ + amount >= totalSupply_); // Overflow check
    totalSupply_ += amount;
    balances[address(this)] += amount;
    emit Transfer(address(0), address(this), amount);
    return true;
}

    function approve(address delegate, uint numTokens) public returns (bool) {
       allowed[msg.sender][delegate] = numTokens;
       emit Approval(msg.sender, delegate, numTokens);
       return true;
   }


   function transferFrom(address _owner, address buyer, uint numTokens) public returns (bool) {
       require(numTokens <= balances[_owner]);   
       require(numTokens <= allowed[_owner][msg.sender]);
  
       balances[_owner] = balances[_owner]-= numTokens;
       allowed[_owner][msg.sender] = allowed[_owner][msg.sender] -= numTokens;
       balances[buyer] = balances[buyer] += numTokens;
       emit Transfer(_owner, buyer, numTokens);
       return true;
   }
}








 

