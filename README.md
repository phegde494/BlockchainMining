# BlockchainMining

This is a fully functional miner which works on the Accelchain server, which runs on Northeastern University's Achtung cluster.

The miner can validate transactions, mine for the appropriate cryptocurrency (Accelcoin in this case), and keep track of its own ledger. Once the miner is connected onto the server, it updates its initial ledger to keep track of every subsequent block with each of its numerous transactions. Several folding, mapping, and hashing functions are used to optimize the mining algorithm so that it remains performant even with hundreds of thousands of transactions.

To run this miner, run the program and then type the following command in the terminal: 

##(go INITIAL-VALIDATOR-STATE)##
