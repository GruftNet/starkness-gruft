# StarkVault

This is a simple vault contract implemented in Cairo for the StarkNet platform. It allows users to lock funds for a specified period and provides a bonus for larger deposits.
Features

### Three locking periods: 
- 7 days
- 14 days
- 21 days
- 30 days

### Bonus
- 12% bonus for deposits below 300 strk tokens
- 15% bonus for deposit above 500 strk tokens

### Profile Template
```
[sncast.<name>]
account = "<name>"
accounts-file = "~/.starknet_accounts/starknet_open_zeppelin_accounts.json"
url = "https://free-rpc.nethermind.io/sepolia-juno/"
```


// 0x596e3262b7d3c6af4989edc46c99e7286c663c43590d8cdd6d9b97a7f687953 - class hash vault
// example contract owner - 0x10b2d12c2221b750cd11ee2a3bc23d950f68daad9f4db9fce89fed1bb7b840d
// contract address - 0x1147fa9819ed58f9c4924c88ffd3d64c172c71367c18edf0f8cbb2d658db9c6