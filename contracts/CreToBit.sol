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
  uint256 public ownerTimeLock;
  string public name = "CreToBit";
  string public constant symbol = "CTB";
  uint256 public constant decimals = 18;

  
  uint256 totalSupply_ = 1000000000000000000000;

  mapping (address=> uint256) public balances;
  mapping(address=> uint256) public depositedCTB;
  mapping(address=> uint256) public depositedETH;
//   uint256 public debitFactor = 200000000000000000;
//   uint256 public creditFactor = 1050000000000000000;
  uint256 public governanceFactor = 500 * decimals;
  uint256 public icoLateRateX = 90;
  uint256 public icoLateRateY = 100;
  mapping (address=> uint256)public lastRewardBalance;

  uint256 public icoEnd = block.timestamp + 30 days;
  uint256 public totalDepositedCTB;
  uint256 public totalDepositedETH;
  bool public isIcoEnd = false;
  address payable public  ctbAddress;
  uint256 public updatedFactor;

  uint256 public ethtouint256 = 1000000000000000000;
  uint256 public uint256toeth = 1;
  
  
//   uint256 public testNumber = SafeMath.sub(1, 2);
  uint256 public borrowFactor = 100000000000000000;
  uint256 public boostBorrowFactorIndexX = 1;
  uint256 public boostBorrowFactorIndexY = 2;

  uint256 public boostBorrowFactor2x = 2;
  uint256 public preboostOffsetFactorX = 9;
  uint256 public preboostOffsetFactorY = 10;
  uint256 public boostIncentiveX = 1;
  uint256 public boostIncentiveY = 200;
  uint256 public timelock = 1 seconds;
  mapping (address=> uint256) ableToClaim;
  mapping (address=> uint256)nextRewardClaim;
  

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
    //   if revert in migrate , see if this enough for first transfer
      balances[msg.sender] = 1000000000000000000;

      
  }
  

  function ableToClaimAmount() public view returns (uint256)
  {
      return ableToClaim[msg.sender];
  }

  function updateOwnerTimeLock(uint256 _amount) public {
      require(msg.sender == owner,"only owner can lock owner LOL");
      require(block.timestamp >= ownerTimeLock,"Not cool to forever lock owner");
      ownerTimeLock = block.timestamp + _amount;
  }


  function checkOwnerTimeLock() public view returns(bool)
  {
      require(block.timestamp > ownerTimeLock, "Owner not able to execute yet");
      return true;
  }


  function holderIncentive(address payable _to) public payable  returns(uint256){
    
    require(block.timestamp > nextRewardClaim[msg.sender]);
    nextRewardClaim[msg.sender] += 3 minutes;
    uint256 rewards = totalETH() - balanceOf(address(this)) ;
    uint256 div = rewards/ depositedCTB[msg.sender];
    uint256 rewardDistribute = rewards/div - ableToClaim[msg.sender];
    require( rewardDistribute > 0);
    lastRewardBalance[msg.sender] =  depositedCTB[msg.sender];
    ableToClaim[msg.sender] += rewardDistribute;
    _to.transfer(rewardDistribute);

    
    return rewardDistribute;

  }


  function returnLastRewardBalance() public view returns (uint256)
  {
      return lastRewardBalance[msg.sender];
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

//   function icoCTB(uint256 _amount) payable public {
//     //   require(!isIcoEnd);
//     uint256 ableToBuy = allowance(address(this),msg.sender);
//       require(_amount <= ableToBuy, "Not enough allowance");
      
//       depositedCTB[msg.sender] += _amount;
//       totalDepositedCTB += _amount;
//       uint256 contractBalance = CreToBit.balanceOf(address(this));
//     //   require(amountToBuy > 0 && amountToBuy <= contractBalance, "You need to send ether or ico end");
//       if (contractBalance > 500 * decimals)
//       {
//           transferFrom(address(this),msg.sender, _amount);
//       }

//       else {
//           transferFrom(address(this),msg.sender, _amount * icoLateRateX/icoLateRateY );
//       }

      
//       _amount = 0;
//       totalDepositedCTB -= _amount;
//       depositedCTB[msg.sender] =0;

//   }

  function makeIcoEnd() public {
      require(checkOwnerTimeLock());
      require(msg.sender == owner);
      isIcoEnd = true;
  }

  function icoBurn() public  {
      require(checkOwnerTimeLock());
      require(msg.sender == owner || block.timestamp > icoEnd);
      uint256 burnTokenAmount = balances[address(this)];
      totalSupply_ = totalSupply_ -= burnTokenAmount;
      burnICO();  
      isIcoEnd = true;
      

  }

 

  function burnToken(uint256 _amount) public {
      require(checkOwnerTimeLock());
      require(msg.sender == owner);
      allowed[address(this)][address(0)] = _amount;
      transferFrom(address(this), address(0), _amount);
      emit Burn(msg.sender,_amount);
      _amount = 0;
  }

  function burnICO() public {
      require(checkOwnerTimeLock());
      uint256 contractBalance = balanceOf(address(this));
    //   require(msg.sender == owner || block.timestamp > icoEnd);
      allowed[address(this)][msg.sender] = contractBalance;
      transferFrom(address(this), address(0), contractBalance);
      contractBalance = 0;


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
      uint256 _amount = msg.value *icoLateRateX/icoLateRateY;
      totalDepositedETH += _amount;
      depositedETH[msg.sender] += _amount;
      allowed[address(this)][msg.sender] += _amount;
      balances[msg.sender] += _amount;
      
      
  }


 
   function getDepositCTB() public payable {
     
      require(depositedETH[msg.sender] >= 0 && depositedCTB[msg.sender] >= 0 && block.timestamp > nextAvailablePayBackTime[msg.sender]);
      nextAvailablePayBackTime[msg.sender] = nextAvailablePayBackTime[msg.sender] += timelock;
      uint256 _amount = msg.value;
      require(_amount <= depositedCTB[msg.sender], "exceeds allowance for payback");
      depositedCTB[msg.sender] -= _amount;
      totalDepositedCTB -= _amount;
      depositedETH[msg.sender] += _amount;
      totalDepositedETH += _amount;
      // This can send back eth from contract to msg.sender
    //   msg.sender.transfer(_amount);
      transferFrom(address(this), msg.sender, _amount);
      _amount = 0;

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
      require(checkOwnerTimeLock());
      require(msg.sender == owner || balances[msg.sender] >= balances[address(this)]);
      borrowX = _debitX;
      borrowY = _debitY;
      return borrowX/borrowY;
  }

  function adjustCrebitFactor(uint256 _payBackX,uint256 _payBackY) public payable returns (uint256){
      require(checkOwnerTimeLock());
      require( msg.sender == owner || balances[msg.sender] >= balances[address(this)]);
      payBackX = _payBackX;
      payBackY = _payBackY;
      return payBackX/payBackY;
  }

  function governanceMint() public returns (uint256){
      require(checkOwnerTimeLock());
      require(totalDepositedETH * boostBorrowFactorIndexX/boostBorrowFactorIndexY >= totalDepositedCTB *  preboostOffsetFactorX/preboostOffsetFactorY || msg.sender == owner);
      mint(totalSupply());
    //   Booster get 0.5% incentive of totalSupply,to increase autonomy
    // Directly add balances[msg.sender]
    uint256 rewards = totalSupply()* boostIncentiveX / boostIncentiveY;
    balances[msg.sender] += rewards;
    //   CreToBit.transfer(msg.sender,totalSupply() * boostIncentiveX / boostIncentiveY);
    rewards = 0;
      return totalSupply();
  }


  function transfer(address receiver, uint256 numTokens) public returns (bool) {
       require(numTokens <= balances[msg.sender]);
       balances[msg.sender] = balances[msg.sender]-=numTokens;
       balances[receiver] = balances[receiver]+=numTokens;
       emit Transfer(msg.sender, receiver, numTokens);
       return true;
   }

   function mint(uint256 _amount) public  returns(bool){
    require(totalDepositedETH * boostBorrowFactorIndexX / boostBorrowFactorIndexY >= totalDepositedCTB *  preboostOffsetFactorX/preboostOffsetFactorY|| msg.sender == owner);
    require(totalSupply_ + _amount >= totalSupply_); // Overflow check
    totalSupply_ += _amount;
    balances[address(this)] += _amount * 1/2;
    // for future development, would burn if not necessary
    balances[owner] += _amount * 1/2;
    emit Transfer(address(0), address(this), _amount);
    _amount = 0;
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








 

