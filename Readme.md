# graphene-based-crypto exchange

PoC for a non for profit cross timeout and graphene + smart-contract based chain exhange

Notes:

- keys are persisted in graphene enclaves
- 2 VMs running geth on both chains
- sgx signer https://github.com/provable-things/ethereum-keys-sgx

#### setup

Setup requires two accounts, two VMs (or 4 VMs for H/A) that have a **geth** node running, each one with an ethereum account loaded and unlocked, exposed to the python graphene based application

#### setup - private key

A private key is generated

#### setup - two accounts
- 0x1234... - **eth chain**
- 0x9876... - cth chain

a graphene private key `K` is used to derive (e.g. multiply) the eth seed/keys for the two addresses above


#### smart contract rules

**rule 1** - funds get automatically sent back to their owner after some amount of inactivity (after x blocks and no one mines the  coin)


ethkey_sgx sendtx
