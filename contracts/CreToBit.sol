pragma solidity ^0.7.6;
// SPDX-License-Identifier: MIT

contract  CreToBit  
{
    

    // supply according to ico eth ,all remaining would be burn

    // 

 event Transfer(address indexed from, address indexed to, uint256 tokens);
 event Burn(address indexed burner, uint256 value);
 event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

  address public owner;
  string public name = "CreToBit";
  string public constant symbol = "CTB";
  uint256 public constant decimals = 18;

  
  uint256 totalSupply_ = 2000000000000000000;

  mapping (address=> uint256) public balances;
  mapping(address=> uint256) public depositedCTB;
  mapping(address=> uint256) public depositedETH;
//   uint256 public debitFactor = 200000000000000000;
//   uint256 public creditFactor = 1050000000000000000;
  uint256 public governanceFactor = 500000000000000000;
  uint256 public icoLateRate = 950000000000000000;
  uint256 public icoEnd = block.timestamp + 30 days;
  uint256 public totalDepositedCTB;
  uint256 public totalDepositedETH;
  bool public isIcoEnd;
  address payable public  ctbAddress;
  uint256 public updatedFactor;

  uint256 public ethtouint256 = 1000000000000000000;
  uint256 public uint256toeth = 1;
  
  
//   uint256 public testNumber = SafeMath.sub(1, 2);
  uint256 public borrowFactor = 100000000000000000;
  uint256 public boostBorrowFactorIndex = 500000000000000000;
  uint256 public boostBorrowFactor2x = 2000000000000000000;
  uint256 public preboostOffsetFactor = 900000000000000000;
  uint256 public boostIncentive = 5000000000000000;
  uint256 public timelock = 1 minutes;
  mapping (address=> uint256) ableToClaim;
  

  uint256 public borrowX = 95;
  uint256 public borrowY = 100;

  uint256 public payBackX = 110;
  uint256 public payBackY = 100;
  
  mapping (address => uint256) public nextAvailablePayBackTime;

  mapping(address => mapping (address => uint256)) allowed;

  





 
 
  

  

  

  
  
  
 constructor() public
  {
      totalSupply_ = totalSupply();
      owner = msg.sender;
      balances[msg.sender] = 1*ethtouint256/10;
      balances[ctbAddress] = 1*ethtouint256;
      
      
  }

  function ableToClaimAmount() public view returns (uint256)
  {
      return ableToClaim[msg.sender];
  }


  function holderIncentive(address payable _to) public payable  returns(uint256){
    
    uint256 rewards = totalETH() - balanceOf(address(this)) ;
    uint256 div = rewards/ depositedCTB[msg.sender];
    uint256 rewardDistribute = rewards/div - ableToClaim[msg.sender];
    require( rewardDistribute > 0);
    ableToClaim[msg.sender] += rewardDistribute;
    _to.transfer(rewardDistribute);
    
    return rewardDistribute;

  }

  function returnCTBAddress()public view returns(address)
  {
      return address(this);
  }

  function returnDepositCTB() public view returns (uint256){
      return depositedCTB[msg.sender];
  }

  //   Transfer ownership 
  function transferOwnership() public returns(address)
  {
      require(msg.sender == owner);
      owner = msg.sender;
      return msg.sender;
  }

  function returnDepositETH() public view returns (uint256){
      return depositedETH[msg.sender];
  }

  function icoCTB() payable public {
      require(!isIcoEnd);
      uint256 amountToBuy = msg.value;
      uint256 contractBalance = CreToBit.balanceOf(address(this));
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
      uint256 burnTokenAmount = balances[address(this)];
      totalSupply_ = totalSupply_ -= burnTokenAmount;
      emit Burn (address(this),burnTokenAmount);
      emit Transfer(address(this),address(0),burnTokenAmount);
      isIcoEnd = true;

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

    function returnFactor() public  returns (uint256)
    {
        uint256 ethA = CreToBit.totalETH();
        uint256 ctbA = CreToBit.balanceOf(address(this));
        updatedFactor = (ethA/ctbA) + 1;

        return updatedFactor;
    }

   function totalSupply() public view returns (uint256) 
   {
        return totalSupply_;
   }

   function allowance(address _owner, address delegate) public view returns (uint256) {
       return allowed[_owner][delegate];
   }

  
 function balanceOf(address tokenOwner) public view returns (uint256) {
       return balances[tokenOwner];
   }
 
  // Before this, make sure contract have enough ETH
  function borrowETH(address payable _to,uint256 _amount)  public payable returns(uint256){
      
      
      require(depositedETH[msg.sender] >= 0);
      nextAvailablePayBackTime[msg.sender] = nextAvailablePayBackTime[msg.sender] += timelock;
      depositedCTB[msg.sender] += _amount;
      totalDepositedCTB += _amount;
      CreToBit.transfer(address(this), _amount);

      uint256 actualWithdrawlETH = _amount *borrowX/borrowY;
      depositedETH[msg.sender] -= actualWithdrawlETH;
      totalDepositedETH -= actualWithdrawlETH;
      _to.transfer(actualWithdrawlETH);
          return _amount;
      }


     function transferEther(address payable recipient,uint256 _amount) public  {
      recipient.transfer(_amount);
  }

  receive() payable external {
      uint256 _amount = msg.value;
      totalDepositedETH += _amount;
      depositedETH[msg.sender] += _amount;
      allowed[address(this)][msg.sender] += _amount;
      
  }



  function getDepositCTB() public payable {
     
      require(depositedETH[msg.sender] > 0 && depositedCTB[msg.sender] > 0 && block.timestamp > nextAvailablePayBackTime[msg.sender]);
      nextAvailablePayBackTime[msg.sender] = nextAvailablePayBackTime[msg.sender] += timelock;
      uint256 _amount = depositedCTB[msg.sender];
      depositedCTB[msg.sender] -= _amount;
      totalDepositedCTB -= _amount;
      // This can send back eth from contract to msg.sender
    //   msg.sender.transfer(_amount);
      transferFrom(address(this), msg.sender, _amount);
  }


  

      


    //   function paybackETH() payable public{
    //   require(block.timestamp > nextAvailablePayBackTime[msg.sender]);
    //   nextAvailablePayBackTime[msg.sender] = nextAvailablePayBackTime[msg.sender] += timelock;
    //   require(msg.value  >= depositedCTB[msg.sender] * payBackX / payBackY); 
    //   totalDepositedETH += msg.value;
    //   depositedETH[msg.sender] += msg.value;
    //   totalDepositedCTB -= msg.value;
    //   depositedCTB[msg.sender] -= msg.value;
      
    //   msg.sender.transfer(msg.value);

    //   }

    

    


//   Delete after testing
//   function withDrawlAllETH(uint256 _amount) public {
//       require(msg.sender == owner);
//       msg.sender.transfer(_amount);
//   }

  

  function adjustDebitFactor(uint256 _debitX,uint256 _debitY) public payable returns (uint256){
      require(msg.sender == owner || balances[msg.sender] >= balances[address(this)]);
      borrowX = _debitX;
      borrowY = _debitY;
      return borrowX/borrowY;
  }

  function adjustCrebitFactor(uint256 _payBackX,uint256 _payBackY) public payable returns (uint256){
      require( msg.sender == owner || balances[msg.sender] >= balances[address(this)]);
      payBackX = _payBackX;
      payBackY = _payBackY;
      return payBackX/payBackY;
  }

  function governanceMint() public returns (uint256){
      require(totalDepositedETH * boostBorrowFactorIndex >= totalDepositedCTB *  preboostOffsetFactor);
      mint(totalSupply_);
    //   Booster get 0.5% incentive of totalSupply,to increase autonomy
      CreToBit.transfer(msg.sender,totalSupply_ * 5 / 10);
      return totalSupply_;
  }


  function transfer(address receiver, uint256 numTokens) public returns (bool) {
       require(numTokens <= balances[msg.sender]);
       balances[msg.sender] = balances[msg.sender]-=numTokens;
       balances[receiver] = balances[receiver]+=numTokens;
       emit Transfer(msg.sender, receiver, numTokens);
       return true;
   }

   function mint(uint256 amount) public  returns(bool){
    require(totalDepositedETH * boostBorrowFactorIndex >= totalDepositedCTB *  preboostOffsetFactor);
    require(totalSupply_ + amount >= totalSupply_); // Overflow check
    totalSupply_ += amount;
    balances[address(this)] += amount;
    emit Transfer(address(0), address(this), amount);
    return true;
}

    function approve(address delegate, uint256 numTokens) public returns (bool) {
       allowed[msg.sender][delegate] = numTokens;
       emit Approval(msg.sender, delegate, numTokens);
       return true;
   }


   function transferFrom(address _owner, address buyer, uint256 numTokens) public returns (bool) {
       require(numTokens <= balances[_owner]);   
       require(numTokens <= allowed[_owner][msg.sender]);
  
       balances[_owner] = balances[_owner]-= numTokens;
       allowed[_owner][msg.sender] = allowed[_owner][msg.sender] -= numTokens;
       balances[buyer] = balances[buyer] += numTokens;
       emit Transfer(_owner, buyer, numTokens);
       return true;
   }
}








 

