# Wrapped HBAR

hbar_filter.sol uses smart contracts to filter transactions. It enforces a required minimum amount in HBAR for a transaction to be transferred, otherwise it fails.

There's an secure environment signing events from Hedera to Ethereum, through a Gnosis Safe which collects the group of transactions and submits it through to the erc20 contract to mind whbar.

whbar_erc20.sol mints wrapped hbars through a Gnosis Safe which collects enough signatures to "validate" the transaction. 

On the way back. The secure environment signs an "out" transaction. This is based on if the secure environment receives a block that contains the "burn" transaction and a valid account ID (X.X.X) which it can sign cryptotransfer to.

