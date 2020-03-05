pragma solidity >= 0.5.0 < 0.6.0;

contract Ownable {

    address internal owner;

    modifier onlyOwner(){
      require(msg.sender == owner);
      _;
    }

    constructor() public {
      owner = msg.sender;
    }

}
