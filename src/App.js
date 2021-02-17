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
        await setctbAddress(creToBit._address)
      }
  
   
  
    
     
  
      
      
    }
  
    return false;
  }


  return (


    <div className="App">

<aside>
  <p> CreToBit </p>
  
  <a href="javascript:void(0)">
    <i class="fa fa-clone" aria-hidden="true"></i>
   Start CreToBit
  </a>

  <a href="javascript:void(0)">
    <i class="fa fa-star-o" aria-hidden="true"></i>
    Contract
  </a>

  <a href="javascript:void(0)">
    <i class="fa fa-star-o" aria-hidden="true"></i>
    Documentation
  </a>

  <a href="javascript:void(0)">
    <i class="fa fa-trash-o" aria-hidden="true"></i>
    GitHub
  </a>

  <a href="javascript:void(0)">
    <i class="fa fa-trash-o" aria-hidden="true"></i>
    Contact Us
  </a>

</aside>

<body>



     <h2> Welcom to CreToBit </h2>
      <div>

      {account}

      </div>

      <div>
        <h3>
        CTB address : 
        </h3>
       

        <div>
        {ctbAddress}
        </div>
        



        

      </div>

      </body>
      
    </div>
  );
}

export default App;
