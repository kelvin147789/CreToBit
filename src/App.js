import logo from './logo.svg';
import './App.css';
import React, { useState, useEffect, useRef } from 'react';
import CreToBit from './abi/CreToBit.json';
import { MetaMaskButton,Flex, Box, EthAddress,Loader,Select,Field} from 'rimble-ui';
import creToBitIcon from './Media/logo.png';
import {HashRouter,Route, Switch,Link} from "react-router-dom";
 
import Web3 from 'web3';

function App() {

  let [account,setAccount] = useState("CONNECT YOUR WALLET");
  const [CTB,setCBT] = useState();
  const [deployed,setDeployed] = useState(false);
  const [ctbAddress,setctbAddress] = useState();

  useEffect(()=> {
    ethEnabled();
  })




  const Home = (props) => {return(

<div>

<div class="wrapper-1">
      <div class="typing-demo-1">
     <h2>CTB </h2>
      </div>
      </div>
    <div class="wrapper">

  
    <div class="typing-demo">
      Decentralized Bank Protocol.
    </div>
</div>
   

    <div class="wrap">
      <a href="#/app">
  <button class="button">Launch App</button>
  </a>
</div>
</div>
    )
  }

  const Apps = (props) => {return (
    <div class="typing-demo-2">
    <h2>App Dashboard </h2>

    <div class="row-element">

    <div>
  <button class="button1">Deposit</button>
</div>

<div>
  <button class="button2">Borrow</button>
</div>



</div>

</div>
  )}

 
  

 

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

  const refreshPage = ()=> {
    window.location.reload(false);
  }


  const NavBar = (props)=> {

    return (
      <div className="navBar">
  
        
        <ul>
         
         <div className="navBarMain">
        
        <span>   
        <a href="#">  
           <img src={creToBitIcon} alt="Lihkg Icon" className="navIcon" />  
           
        <h3>CreToBit</h3>
         </a>
        
  
         </span>


         <div>
           <a href="#/app">
           <h2> App</h2>
           </a>
         </div>
       
       
         
         <div>
          <a href="#" target="_blank">
         <h2 className="balance">Docs</h2>
         </a>
         </div>
  
        

         </div>
            <div className="navBarWallet">    
            
            <EthAddress address={props.account} />    
              <MetaMaskButton    width= {0.5}onClick={props.ethEnabled,props.refreshPage}>Connect Wallet</MetaMaskButton>   
            </div>
  
          

        </ul>
  
      </div>
    );
    
  }

  return (

    <HashRouter>


    <div className="App">

      <NavBar
      ethEnabled={ethEnabled}
      account={account}
      refreshPage={refreshPage}
      />

      <Switch>

        <Home exact path="/"/>
        <Apps exact path="/app"/>

      </Switch>

      

     

      











      
      


    </div>
    </HashRouter>
  );
}

export default App;
