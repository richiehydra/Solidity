
//SPDX-License-Identifier: GPL
pragma solidity >=0.5.0 <0.9.0;
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

 contract CoinFlip is VRFV2WrapperConsumerBase {
    enum CoinFlipChoices {
        HEADS,
        TAILS
    }
    struct CoinFlipStatus {
        uint randomWord;
        address player;
        uint fees;
        CoinFlipChoices choice;
        bool didWin;
        bool fulfilled;
    }
    mapping(uint => CoinFlipStatus) public statuses;

    address constant LinkTokenAdddress =
        LinkAddressofGoerli;
    address constant VRFWrapperAddress =
       VRFWrappedAddressofGoerli;
    uint constant entryFees = 0.001 ether;
    uint32 constant callbackGasLimit = 1_00_000;
    uint32 constant numWords = 1; //minimum=1 and maximum=10
    uint16 constant requestConfirmation = 3; //minimum=3 maximum=200

    constructor() payable
        VRFV2WrapperConsumerBase(LinkTokenAdddress, VRFWrapperAddress)
    {}

    function flip(CoinFlipChoices choice) external payable returns (uint) {
        require(msg.value == entryFees, "Entry Fees Not Sufficient");
        uint requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmation,
            numWords
        );
        statuses[requestId] = CoinFlipStatus({
            randomWord: 0,
            player: msg.sender,
            fees: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            choice: choice,
            didWin: false,
            fulfilled:false
        });
        return requestId;
    }

    function fulfillRandomWords(uint requestId,uint []memory randomWords) internal override
    {
         require(statuses[requestId].fees>0,"Request Not Found");
         statuses[requestId].fulfilled=true;
         statuses[requestId].randomWord=randomWords[0];
         CoinFlipChoices result=CoinFlipChoices.HEADS;
         if(statuses[requestId].randomWord %2==0)
         {
            result=CoinFlipChoices.TAILS;
         }
         if(statuses[requestId].choice==result)
         {
            statuses[requestId].didWin=true;
            payable(statuses[requestId].player).transfer(entryFees*2);
         }
    }
}
