import logo from './logo.svg';
import './App.css';
import React, { useState, useEffect, useRef } from 'react';
import CreToBit from './abi/CreToBit.json';

import Web3 from 'web3';

function App() {

  let [account,setAccount] = useState("CONNECT YOUR WALLET");
  const [CTB,setCBT] = useState();
  const [deployed,setDeployed] = useState(false);
  const [ctbAddress,setctbAddress] = useState();

  useEffect(()=> {
    ethEnabled();
  })

 

  const ethEnabled = async() => {
  
    if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider);
      await window.ethereum.enable();
  
      const web3js = await window.web3;
      const accounts = await web3js.eth.getAccounts();
      const networkID = await web3js.eth.net.getId();
      
      console.log(networkID)
      setAccount(accounts[0]);  
  
      console.log("Account connected");

      const creToBitData = await CreToBit.networks[networkID];

      if (web3js && !deployed)
      {
        const creToBit = await new web3js.eth.Contract(CreToBit.abi,creToBitData.address);
        console.log("creToBit",creToBit)
        setCBT(creToBit);
        setDeployed(true);
        setctbAddress(creToBit._address)
      }
  
   
  
    
     
  
      
      
    }
  
    return false;
  }


  return (
    <div className="App">

      Welcom to CreToBit.
      <div>

      {account}

      </div>

      <div>
        CTB address : 

        <div>
        {ctbAddress}
        </div>
      </div>
      
    </div>
  );
}

export default App;
