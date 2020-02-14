pragma solidity ^ 0.4.13;
contract SimpleToken {
    uint256 internal _totalSupply;
    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    
    function SimpleToken (uint256 _initialSupply) public {
        balances[msg.sender] = _initialSupply;
        _totalSupply = _initialSupply;
    }
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    function transfer(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
     require(_value <= balances[_from]);

    balances[_from] = balances[_from] - _value;
     balances[_to] = balances[_to] + _value;
    Transfer(_from, _to, _value);
     return true;
   }
    address public buyer;
    address public seller;
    address public arbitrator;
    address public escrow;
    bool public buyer_agreement;
    bool public seller_agreement;
    uint public amount;
    uint public start_block;
    uint public end_block;
    uint256 public balance;
    string transaction_State;
    string public arbitrator_decision;
       function transact() public {
            if(buyer_agreement == true && seller_agreement == true)
            {
                transfer(escrow, seller, amount);
            }
            else
            {
                if(buyer_agreement == false && seller_agreement == false)
                {
                    transfer(escrow, buyer, amount);
                }
                else
                {
                    while(end_block < 12 && hashCompareWithLengthCheck(arbitrator_decision, "")){
                        end_block = block.number - start_block;
                    }
                    if(end_block >= 12 && hashCompareWithLengthCheck(arbitrator_decision, "")){
                        transfer(escrow, buyer, amount);
                    } else {
                        if(hashCompareWithLengthCheck(arbitrator_decision, "Success")){
                            transfer(escrow, seller, amount);
                        } else {
                            transfer(escrow, buyer, amount);
                        }
                    }
                    arbitrator_decision = "";
                }
            }
       } 
       function MakeDeposit(uint256 tokenValue) payable {
            require(balances[msg.sender] >= tokenValue);
            balances[msg.sender] -= tokenValue;
            balances[escrow] += tokenValue;
            amount = tokenValue;
            buyer = msg.sender;
       }
       function register_seller() {
             seller = msg.sender;
       }
       function register_escrow(){
           escrow = msg.sender;
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
        function returnBalance() {
            balance =  balances[msg.sender];
        }
}
