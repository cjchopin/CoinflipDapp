import "./Ownable.sol";
import "./provableAPI.sol";
pragma solidity >= 0.5.0 < 0.6.0;

contract Coinflip is Ownable, usingProvable{

    struct Better {

        address payable userAddress;
        uint userValue;
        uint userEarnings;
        string message;

    }

    mapping(bytes32 => Better) private waiting;
    mapping(address => Better) private result;

    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1;
    uint256 latestNumber;
    uint public balance;

    event LogNewProvableQuery(string description);
    event notification(address, string, uint, string);


        modifier costs(uint cost){
        require(msg.value == cost);
        _;
    }

    function ContractInputMoney() public onlyOwner payable costs(100000000000000000 wei) returns(uint) {                                                                     //40 Ether for experiment temporary 0.1 Ether
        balance += msg.value;
        return balance;
    }

    function OwnerWithdrawMoney(uint withdrawal) public onlyOwner{
        uint toTransfer = withdrawal;
        balance -= withdrawal;
        msg.sender.transfer(toTransfer);
    }

    function UserWithdrawMoney() public {
        uint toTransfer = result[msg.sender].userEarnings;
        balance -= toTransfer;
        result[msg.sender].userEarnings = 0;
        msg.sender.transfer(toTransfer);
    }

    function seeEarnings() public view returns (uint){
        return (result[msg.sender].userEarnings);
    }

    function seeWin() public view returns(string memory){
        return (result[msg.sender].message);
    }


    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public{
        require(msg.sender == provable_cbAddress());

        //linking the waiting mapping to the result mapping
        Better memory oldNewBetter;

        oldNewBetter.userAddress = waiting[_queryId].userAddress;
        oldNewBetter.userValue = waiting[_queryId].userValue;

        //clear the waiting mapping
        delete(waiting[_queryId].userAddress);
        waiting[_queryId].userValue = 0;
        waiting[_queryId].userEarnings = 0;

        //fetching users past earnings

        oldNewBetter.userEarnings = result[oldNewBetter.userAddress].userEarnings;

        uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 2;
        latestNumber = randomNumber;

        if (latestNumber == 0){
                    emit notification(oldNewBetter.userAddress, " has lost ", oldNewBetter.userValue, " wei!");
                    balance += oldNewBetter.userValue;
                    oldNewBetter.userValue = 0;
                    oldNewBetter.message = "You lost";
                    result[oldNewBetter.userAddress] = oldNewBetter;
                }

                else {
                    oldNewBetter.userEarnings += oldNewBetter.userValue*2;
                    balance -= oldNewBetter.userEarnings;
                    oldNewBetter.message = "You won!";
                    oldNewBetter.userValue = 0;
                    result[oldNewBetter.userAddress] = oldNewBetter;
                    emit notification(oldNewBetter.userAddress, " has won ", oldNewBetter.userEarnings, " wei!");
                }
    }




    function flip(uint bet) public payable costs(bet){
        require(bet>=10000000000000000 && bet <= 10000000000000000000);
        if(balance % 2 == 1){
            balance = balance - 1;
            balance = balance / 2;
            require(balance/2 >= bet);
        }
        else{
        require(balance/2 >= bet);
        }

        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;
        bytes32 queryId = provable_newRandomDSQuery(
            QUERY_EXECUTION_DELAY,
            NUM_RANDOM_BYTES_REQUESTED,
            GAS_FOR_CALLBACK
            );

        balance -= provable_getPrice("Random");

        Better memory newBetter;

        newBetter.userAddress = msg.sender;
        newBetter.userValue = bet;

        waiting[queryId] = newBetter;

        emit LogNewProvableQuery("Provable query was sent, standing by for answer...");
    }

}
