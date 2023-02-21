//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.0 <0.9.0;

contract MultiSign {
    //Owners of the Contract
    address[] public owners;
    //Number of Requirements needed to sign a transaction
    uint256 public confirmations;

    //details of the Transaction
    struct Transaction {
        address to; //for whom
        uint256 value; //what value
        bool executed; //wheter it is executed or not
    }

    //uint-transactionId
    //address->from whom
    //bool-whether transacted or not

    //uint   address1   address2
    //1      true       false
    //2      true       false

    mapping(uint256 => mapping(address => bool)) public ConfirmedTransaction;

    //to store all transaction

    Transaction[] public transactions;

    event TransactionSubmitted(
        uint256 transactionid,
        address sender,
        address receiver,
        uint256 amount
    );

    event TransactionSubmitted(uint256 transactionid);

    constructor(address[] memory _owners, uint256 requiredConfirmations) {
        require(owners.length >= 1, "Invalid Owners Argument");
        require(requiredConfirmations > 0, "Invalid Confirmations");
        require(
            requiredConfirmations <= _owners.length,
            "Invalid Number of Confirmations"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid User Address");
            owners.push(_owners[i]);
        }

        confirmations = requiredConfirmations;
    }

    function submitTransaction(address to) public payable {
        require(to != address(0), "Invalid Address Provided");
        require(msg.value > 0, "Invalid Transaction Amount");
        uint256 transactionId = transactions.length; //Initially Zero
        transactions.push(Transaction(to, msg.value, false));
        emit TransactionSubmitted(transactionId, msg.sender, to, msg.value);
    }

    function confirmTransaction(uint256 transactionId) public {
        require(
            !ConfirmedTransaction[transactionId][msg.sender],
            "Already Confirmed"
        );
        ConfirmedTransaction[transactionId][msg.sender] = true;
        emit TransactionSubmitted(transactionId);
        if (isTransactionConfirmed(transactionId)) {
            executeTransaction(transactionId);
        }
    }

    function executeTransaction(uint256 _transactionId) public payable {
        require(
            _transactionId < transactions.length,
            "Invalid Transactrion Count"
        );
        require(!transactions[_transactionId].executed, "Already Executed");
        (bool success, ) = transactions[_transactionId].to.call{
            value: transactions[_transactionId].value
        }("");
        require(success);
        transactions[_transactionId].executed = true;
    }

    function isTransactionConfirmed(uint256 _transactionId)
        internal
        view
        returns (bool)
    {
        require(
            _transactionId < transactions.length,
            "Invalid Transactrion Count"
        );
        uint256 confirmedTransactionCount;

        for (uint256 i = 0; i < owners.length; i++) {
            if (ConfirmedTransaction[_transactionId][owners[i]]) {
                confirmedTransactionCount++;
            }
        }

        return confirmedTransactionCount >= confirmations;
    }
}
