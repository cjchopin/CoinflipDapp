var web3 = new Web3(Web3.givenProvider);
var contractInstance;

$(document).ready(function() {
    window.ethereum.enable().then(function(accounts){
      contractInstance = new web3.eth.Contract(window.abi, "0x587e66865ca4768E61c7d0681DF1711819d1f3dD", {from: accounts[0]});
    });

    $("#bet_button").click(placeBet);
    $("#result_button").click(fetchResultAndDisplay);
    $("#earning_button").click(fetchEarningsAndDisplay);
    $("#withdraw_button").click(giveUserMoneyBack);
    $("#owner_button").click(letOwnerInput);

});

function placeBet(){
  var bet = $("#bet_input").val();
  bet = web3.utils.toWei(bet, "ether");

  contractInstance.methods.flip(bet).send({value: bet})
  .on('transactionHash', function(hash){
    console.log("tx hash");
  })
  .on('confirmation', function(confirmationNumber, receipt){
      console.log("conf");
  })
  .on('receipt', function(receipt){
    console.log(receipt);
  });

}


function fetchResultAndDisplay(){
  contractInstance.methods.seeWin().call().then(function(res){
    $("#result_output").text(res);
  });
}

function fetchEarningsAndDisplay(){
  contractInstance.methods.seeEarnings().call().then(function(res){
    $("#earning_output").text(web3.utils.fromWei(res, "ether") + " Ether.");
  });
}

function giveUserMoneyBack(){

  contractInstance.methods.UserWithdrawMoney().send();

}

function letOwnerInput(){
  contractInstance.methods.ContractInputMoney().send({value: 100000000000000000});
}
