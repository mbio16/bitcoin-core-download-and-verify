# bitcoin-core-download-and-verify
## Ubuntu server 20.04

- Go to https://bitcoincore.org/en/download/ 
- verify key: "01EA5486DE18A882D4C2684590C8019E36C2E964" othervise replace PGP_KEY variable

```sh
wget https://raw.githubusercontent.com/mbio16/bitcoin-core-download-and-verify/main/downloadAndVerify.sh
chmod +x downloadAndVerify.sh
./downloadAndVerify.sh
```
