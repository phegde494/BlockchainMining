# BlockchainMining

This is a fully functional miner which works on the Accelchain server, which runs on Northeastern University's Achtung cluster.

The miner can validate transactions, mine for the appropriate cryptocurrency (Accelcoin in this case), and keep track of its own ledger. Once the miner is connected onto the server, it updates its initial ledger to keep track of every subsequent block with each of its numerous transactions. Several folding, mapping, and hashing functions are used to optimize the mining algorithm so that it remains performant even with hundreds of thousands of transactions.

To run this miner, run the program and then type the following command in the terminal: 

**(go INITIAL-VALIDATOR-STATE)**

Upon running this command, the ledger will start printing every transaction in the history of the server (which will take a really long time to finish), but your miner will have activated, meaning that you will likely be making money as you wait.

Below, is the sample output of starting the miner:


<img width="1203" alt="Screenshot 2023-06-08 at 7 44 01 PM" src="https://github.com/phegde494/BlockchainMining/assets/48624928/cf234b7f-6732-4151-8491-1272811e18a4">

**Have fun mining!**
