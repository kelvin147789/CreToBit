pragma solidity >=0.4.22 <0.8.0;
// SPDX-License-Identifier: MIT

contract CreToBit 
{
    

    // supply according to ico eth ,all remaining would be burn

    // 

 event Transfer(address indexed from, address indexed to, uint tokens);
 event Burn(address indexed burner, uint256 value);
 event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

  address public owner;
  string public name = "CreToBit";
  string public constant symbol = "CTB";
  uint8 public constant decimals = 18;

  
  uint256 totalSupply_ = 2000000000000000000;

  mapping (address=> uint256) public balances;
  mapping(address=> uint256) public depositedCTB;
  mapping(address=> uint256) public depositedETH;
  uint256 public debitFactor = 950000000000000000;
  uint256 public creditFactor = 1050000000000000000;
  uint256 public governanceFactor = 500000000000000000;
  uint256 public icoLateRate = 950000000000000000;
  uint256 public icoEnd = block.timestamp + 30 days;
  uint256 public totalDepositedCTB;
  uint256 public totalDepositedETH;

  uint256 public ethtouint256 = 1000000000000000000;
  uint256 public uint256toeth = 1;
  
  
//   uint256 public testNumber = SafeMath.sub(1, 2);
  uint256 public borrowFactor = 100000000000000000;
  uint256 public boostBorrowFactorIndex = 500000000000000000;
  uint256 public boostBorrowFactor2x = 2000000000000000000;
  uint256 public preboostOffsetFactor = 900000000000000000;
  uint256 public timelock = 2 minutes;
  mapping (address => uint256) public nextAvailablePayBackTime;

  mapping(address => mapping (address => uint256)) allowed;

  





 
 
  

  

  

  
  
  
 constructor() public
  {
      totalSupply_ = totalSupply();
      owner = msg.sender;
      balances[msg.sender] = 1000000000000000000;
      
      
  }

  function returnDepositCTB() public view returns (uint256){
      return depositedCTB[msg.sender];
  }

  function returnDepositETH() public view returns (uint256){
      return depositedETH[msg.sender];
  }

  function icoCTB() payable public {
      uint256 amountToBuy = msg.value;
      uint256 contractBalance = CreToBit.balanceOf(address(this));
      require(amountToBuy > 0 && amountToBuy <= contractBalance, "You need to send ether or ico end");
      if (contractBalance > 500)
      {
          CreToBit.transfer(msg.sender, amountToBuy);
      }

      CreToBit.transfer(msg.sender, amountToBuy * icoLateRate);

  }

  function icoBurn() public  {
      require(msg.sender == owner || block.timestamp > icoEnd);
      uint256 burnTokenAmount = balances[address(this)];
      totalSupply_ = totalSupply_ -= burnTokenAmount;
      emit Burn (address(this),burnTokenAmount);
      emit Transfer(address(this),address(0),burnTokenAmount);

  }

  function burnToken(uint256 _amount) public {
      require(msg.sender == owner);
      emit Burn (msg.sender,_amount);
      emit Transfer(msg.sender, address(0), _amount);
  }

  function totalETH() public view returns (uint256)
    {   
        // return totalDepositedETH;
        return address(this).balance;
    }

   function totalSupply() public view returns (uint256) 
   {
        return totalSupply_;
   }

   function allowance(address _owner, address delegate) public view returns (uint) {
       return allowed[_owner][delegate];
   }

  
 function balanceOf(address tokenOwner) public view returns (uint) {
       return balances[tokenOwner];
   }

  function borrowETH(uint256 _amount,address payable ctbAddress) payable external returns (uint256){
      require(depositedCTB[msg.sender] <= 0 && depositedETH[msg.sender] >= 0);
      nextAvailablePayBackTime[msg.sender] = nextAvailablePayBackTime[msg.sender] += timelock;
      depositedCTB[msg.sender] += _amount;
      totalDepositedCTB += _amount;
      CreToBit.transfer(address(this), _amount);
      uint256 actualWithdrawlETH = _amount * debitFactor;
    // CTB  Address transfer ETH to msg.sender 
      depositedETH[msg.sender] -= actualWithdrawlETH;
      totalDepositedETH -= actualWithdrawlETH;
      ctbAddress.transfer(actualWithdrawlETH);
      return actualWithdrawlETH;

  }

  function paybackETH(uint256 _amount) payable public returns (uint256){
      uint256 depositETH = _amount;
      require(block.timestamp > nextAvailablePayBackTime[msg.sender] && depositETH >= depositedCTB[msg.sender] * creditFactor && depositedCTB[msg.sender] > 0);
    //   msg.sender transfer eth to contract
      depositedETH[msg.sender] += depositETH;
      totalDepositedETH += depositETH;
      msg.sender.transfer(depositETH);
      depositedCTB[msg.sender] -= depositETH;
      totalDepositedCTB -= depositETH;   
      CreToBit.transfer(msg.sender, depositETH);
      return depositETH;

  }

  function adjustDebitFactor(uint256 _amount) public payable returns (uint256){
      require(msg.sender == owner || balances[msg.sender] >= balances[address(this)]);
      debitFactor == _amount;
      return debitFactor;
  }

  function adjustCrebitFactor(uint256 _amount) public payable returns (uint256){
      require( msg.sender == owner || balances[msg.sender] >= balances[address(this)]);
      creditFactor == _amount;
      return creditFactor;
  }

  function boostBorrowFactor() public returns (uint256){
      require(totalDepositedETH * boostBorrowFactorIndex >= totalDepositedCTB * borrowFactor * preboostOffsetFactor);
      borrowFactor = borrowFactor * boostBorrowFactor2x;
      mint(totalSupply_);
      return totalSupply_;
  }


  function transfer(address receiver, uint numTokens) public returns (bool) {
       require(numTokens <= balances[msg.sender]);
       balances[msg.sender] = balances[msg.sender]-=numTokens;
       balances[receiver] = balances[receiver]+=numTokens;
       emit Transfer(msg.sender, receiver, numTokens);
       return true;
   }

   function mint(uint256 amount) public  returns(bool){
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








 

