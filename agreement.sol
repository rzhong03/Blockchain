pragma solidity ^ 0.4.13;
   contract escrow {   
    address public buyer;
    address public seller;
    address public arbitrator;
    bool public buyer_agreement;
    bool public seller_agreement;
    uint public amount;
    uint public to_escrow;
    uint public to_seller;
    uint public to_buyer;
    uint public start_block;
    uint public end_block;
    string transaction_State;
    string public arbitrator_decision;
       function transact() public {
            if(buyer_agreement == true && seller_agreement == true)
            {
                to_escrow = amount/100;
                to_seller = amount - (to_escrow);
                seller.transfer(to_seller);
            }
            else
            {
                if(buyer_agreement == false && seller_agreement == false)
                {
                    to_escrow = amount/100;
                    to_buyer = amount - (to_escrow);
                    buyer.transfer(to_buyer);
                }
            }
       } 
       function MakeDeposit() payable {
             if (msg.value > 0 ether)
             {
                buyer = msg.sender;
                amount = msg.value;
             }
       }
       function register_seller() {
             seller = msg.sender;
       }
       function register_arbitrator() {
             arbitrator = msg.sender;
       }
       function ApproveTxSuccess() {
             if(msg.sender == buyer)
                     buyer_agreement = true;
             else if(msg.sender == seller)
                     seller_agreement = true;
            Timelock();
       }
       function ApproveTxFail() {
             if(msg.sender == buyer)
                     buyer_agreement = false;
             else if(msg.sender == seller)
                     seller_agreement = false;
            Timelock();
       }
       function Timelock(){
            if((!buyer_agreement && seller_agreement) || (buyer_agreement && !seller_agreement)){
                start_block = block.number;
                transaction_State = "Dispute"; 
            }
       }
       function Arbitrate(string choice){
             end_block = block.number - start_block;
             if(msg.sender == arbitrator){
                if(end_block < 12 && hashCompareWithLengthCheck(transaction_State, "Dispute"))
             	    arbitrator_decision = choice;
             }
       }
       function hashCompareWithLengthCheck(string a, string b) internal returns (bool) {
            if(bytes(a).length != bytes(b).length) {
                return false;
            } else {
                return keccak256(a) == keccak256(b);
            }
        }
}
