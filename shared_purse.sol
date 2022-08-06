// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.7/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.7/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
/** 
 * @title Shared Purse
 * @dev Implements a bill sharing protocol 
 */

contract SharedPurse is ERC20PresetMinterPauser{
    constructor(string memory name_, string memory symbol_)ERC20PresetMinterPauser(name_, symbol_){}

    using SafeMath for uint;

    struct Bill {
        address beneficiary; // bill beneficiary
        address merchant; // bill administrator
        address [] contributor_addresses; //accounts contributing to payment
        uint8 [] contributor_share; //list of bill split expressed as a percentage value
        string terms; //stores hyperlink to bill terms
        uint obligation; //total amount to be paid
        uint8 [] contributor_status; // 1-outstanding, 2-settled, 3-delinquent, 4-settled_weekly (3&4 for future work)
        bool _isDeleted; //monitors bill liveness
    }


    mapping (bytes32 => Bill) public bills; //establishes relationships for bills and their structs
    
    mapping (address => bytes32 []) merchant_bills; //holds all bills created by merchant

    mapping (address => bytes32[]) public subscribed_bills; //holds all contributors bills

    mapping (address => mapping(bytes32 => uint)) public subscribed_bill_index; //holds contibutors position in bill

    mapping (address => uint) public burnRate; //holds burnRate per contributor

    event newBill (address merchant, bytes32 bill);// broadcaste when new bills are created by merchant
    
    event billDeleted (address merchant, bytes32 bill);// broadcaste when new bills are created by merchant

    event payOut (address merchant);

    /**
    *@dev function to update contributors bills 
    **/
    function _add_bill_subscription (address contributor_addresse_, 
                                     bytes32 bill,
                                     uint position
                                     ) private {
                                         subscribed_bills[contributor_addresse_].push(bill);
                                         subscribed_bill_index[contributor_addresse_][bill] = position;
                                     } 


    /**  
    *@dev function to return sum of elements of dynamic array
    **/
    function _getArraySum (uint8 [] calldata arr) private pure returns(uint)
    {
    uint i;
    uint sum = 0;
        
    for(i = 0; i < arr.length; i++)
        sum = sum + arr[i];
    return sum;
    }

    
    
    /**
    *@dev merchant creates a new bill assigned to an array of contributors 
    */
    function create_new_bill (address beneficiary_,
                              address [] calldata contributor_addresses_, 
                              uint8 [] calldata contributor_share_,
                              string memory terms_,
                              uint obligation_, // this value should be 10**18 of the lowest fiat unit
                              uint8 [] calldata contributor_status_ 
                              ) public {
                                  require(contributor_addresses_.length == contributor_share_.length && contributor_share_.length == contributor_status_.length,"Contributor fields are not the same lenght");
                                  require(_getArraySum(contributor_share_)==100,"Total of shares should be 100");
                                  require(beneficiary_ != msg.sender,"Usa a different account to collect funds as precaution");
                                  bytes32 bill_id = keccak256(abi.encodePacked(msg.sender,msg.data,terms_,block.timestamp));
                                  bills[bill_id].beneficiary = beneficiary_;
                                  bills[bill_id].merchant = msg.sender;
                                  bills[bill_id].contributor_addresses = contributor_addresses_;
                                  bills[bill_id].contributor_share = contributor_share_;
                                  bills[bill_id].terms = terms_;
                                  bills[bill_id].obligation = obligation_;
                                  bills[bill_id].contributor_status = contributor_status_;
                                  merchant_bills[msg.sender].push(bill_id);
                                  for (uint i = 0; i < contributor_addresses_.length; i++) {
                                       uint share_amount = obligation_.mul(bills[bill_id].contributor_share[i]).div(100);
                                       address contributor = contributor_addresses_[i];
                                       burnRate[contributor] = burnRate[contributor].add(share_amount);
                                       _add_bill_subscription(contributor_addresses_[i],bill_id,i);
                                       }
                                  emit newBill(msg.sender,bill_id);
                                       }


    /**
    *@dev merchant deletes an existing bill
    *add require to make callable only by contract of bill creator
    */

    function delete_bill (bytes32 bill_id) public {
        require(bills[bill_id].beneficiary == msg.sender,"Only Bill beneficiary may call this function");
        bills[bill_id]._isDeleted = true;
        emit billDeleted(msg.sender,bill_id);
    }

    /**
    *@dev contributor settles merchants bills
    **/
    function settle_bill(bytes32 bill_id) public  {
        uint index = subscribed_bill_index[msg.sender][bill_id];
        if(index == 0){
            require(bills[bill_id].contributor_addresses[index] == msg.sender,"Account does not have obligation to settle this bill");
        }
        uint8 status = bills[bill_id].contributor_status[index];
        require( status==1 ,"Bill is already settled");
        uint total_bill = bills[bill_id].obligation;
        uint bill_share = bills[bill_id].contributor_share[index];
        uint owing = total_bill.mul(bill_share).div(100);
        address pay_to = (bills[bill_id].beneficiary);
        transfer(pay_to,owing);
        bills[bill_id].contributor_status[index] = 2;
        burnRate[msg.sender] = burnRate[msg.sender].sub(owing);
    }


    /**
    *@dev merchant collects on bills
    */
    function collect_bill (bytes32 bill_id) public {
        require(bills[bill_id].beneficiary == msg.sender,"Only Bill beneficiary may call this function");
        require(bills[bill_id]._isDeleted == false, "Bill Deleted");
        for (uint i; i < bills[bill_id].contributor_share.length; i++) {
        if (bills[bill_id].contributor_status[i] == 1) {
            revert("Not all contributors have settled this bill");
        }
        }
        address pay_to = getRoleMember(MINTER_ROLE,0);
        uint pay_out = bills[bill_id].obligation;
        delete_bill(bill_id);
        transfer(pay_to,pay_out);
        }

}

