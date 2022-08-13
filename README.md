# Shared Purse

- Demo link: https://nark-store.com/shared_purse

- Coston Network Faucet: https://faucet.towolabs.com/

## TLDR;

The links above present a minimum delectable product that represents what is described in the Proposed Solution section below.

The sections provided in the demo link above (built on https://bubble.io , no code yippee! 🥳), interact with two smart contracts deployed to the Coston network, and are described here to facilitate user interaction:

### Merchant
---

![](https://github.com/Femi-0/Shared_Purse/blob/main/Resources/merchant.png)

Having provided goods or services, the merchant prepares the bill in this section, filling out the following details:

- Beneficiary: The account authorized to collect the bill by the merchant

- Contributor's addresses: A series of accounts expected to settle the obligations of the bill

- Contributor's shares: A series ordered the same as the series above, that represents each accounts portion of the bill as a percentage 

- Terms: A description provided by the merchant, about the bill

- Obligation: The total amount of Shared Purse Tokens denominated in Wei, expected to be drawn on the series of contributor's addresses

After some time, the merchant or any other party my inquire about the bill, receiving one of the following responses:

- Bill Not Settled

- Bill Partially Settled

- Bill Settled

On receiving the "Bill Settled" response, the beneficiary may collect and delete the bill. 

### Vendor
---

![](https://github.com/Femi-0/Shared_Purse/blob/main/Resources/vendor.png)

A section that allows accounts to buy Shared Purse Tokens.

### Contributor
---

![](https://github.com/Femi-0/Shared_Purse/blob/main/Resources/contributor.png)

Here, anyone with an account can check their bill ids and its status, all bills are added in order starting from '0'.

While the bill is not settled, they may choose to settle the bill by inputing its id, and clicking settle. As long as their Shared Purse token balance exceeds their portion of the bill, it will be settled. Otherwise they may need to purchase more Shared Purse tokens from the vendor. 
A total of all outstanding bills is also provided for guidance. 

## Problem Statement

Whenever a group of persons that possess prior knowledge and trust of each other intend to settle a common debt obligation, it is common practice that one member of the party is selected to settle the debt and other members of the party then settle this selected member. This may seem like a trivial problem, but as the number of separate groups to which an individual belongs begins to increase, settling all of these obligations begins to become an annoyance, and a non-trivial matter in the worst case

For example: Ade, Blair and Chan share an apartment, for which Ade has signed a lease, whenever the rent is to be paid out, Ade pays the rent and is recompensed by Blair and Chan, simple enough. However, Ade also shares a phone bill with Chan which comes due about 15 days before the rent is collected, Chan pays this bill and is reimbursed by Ade.

We can begin to see how all of these payments can become tedious with one party settling the other. An unfortunate scenario also exists where one or more persons may refuse or be unable to reimburse what had been paid out on their behalf.  

## Proposed Solution

A smart contract is proposed as a solution to the above stated issue.
It will be deployed by us (think bill collections), and would allow a merchant(utility, landlord, etc) to create a shared bill for participants to freely enter into. These participants will hold a reserve of our tokens to settle their debt, whenever a debt is settled, the commensurate amount of tokens are transferred to the merchant’s account and on payout of fiat to the merchant, those tokens are burnt off the smart contract.

From the example above, Ade, Blair and Chan would have their landlord assign them to a shared bill whenever rent is due, the tokens will be drawn from their account to the landlord's account whever they settle the bill, and when the landlord is paid out in fiat, the corresponding amount of tokens are burnt. In a similar manner Chan and Ade would also have their telephone provider assign them a shared bill.


