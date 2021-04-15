# deprecated prototype :D - TODO delete

require 'yaml'
require 'digest/sha1'

class ChainSwapContract

end

class ChainSwapContractETH < ChainSwapContract
  def chain
    "eth"
  end
end

class ChainSwapContractCTH < ChainSwapContract
  def chain
    "cth"
  end
end

CSWAP_CTR_CHAIN1 = ChainSwapContractETH.new
CSWAP_CTR_CHAIN2 = ChainSwapContractCTH.new

class Web3
  def get_nonce(address:)
    rand 10
  end

  def sign_tx(key:, address1:, address2:, amount:, price:,  created_at:, nonce:)
    tx_details = {
      id: id,
      key: key,
      address: address,
      pubkey: pubkey,
      amount: amount,
      price: price,
      created_at: created_at,
      nonce: nonce,
    }
    id = Digest::SHA1.hexdigest tx_details.to_json
    puts "System - Signing transaction for chain #{chain_name}:\n#{tx_details.to_yaml}\n"
  end

  def sign_create_order_tx_user(admin:, address:, pubkey:, side:, amount:, price:,  created_at:, nonce:)
    # request signature from user via user wallet (e.g. metamask)
    tx_details = {
      id: id,
      address: address,
      pubkey: pubkey,
      amount: amount,
      price: price,
      created_at: created_at,
      nonce: nonce,
      admin: admin,
    }
    # transfer funds for amount
    #

    CSWAP_CTR_CHAIN1.transfer_and_create_order user: admin, amount: amount


    # in solidity:
    CSWAP_CTR_CHAIN1.transfer user: admin, amount: amount
    CSWAP_CTR_CHAIN1.create_order side: side, amount: amount, price: price, created_at: created_at, nonce: nonce


    id = Digest::SHA1.hexdigest tx_details.to_json
    puts "User - Signing transaction for chain #{chain_name}:\n#{tx_details.to_yaml}\n"
  end

  def exchange_match(order1:, order2:)
    order2.amount = [order1, order2].min
    CSWAP_CTR_CHAIN1.transfer address: order2.address, amount: match_amount
    CSWAP_CTR_CHAIN2.transfer address: order1.address, amount: match_amount
    CSWAP_CTR_CHAIN1.remove_or_update_order order1.id
    CSWAP_CTR_CHAIN2.remove_or_update_order order2.id
  end

  def receive_signed_order(sig)
    verify_signed_message
    verify_signature_matches_address # (public key)

  end
end

class Web3CTH < Web3
  def chain_name
    "eth"
  end
end

class Web3CTH < Web3
  def chain_name
    "cth"
  end
end

class Key
  def address
    "0x12345"
  end

  def public_key
    "0x23456"
  end
end

class Chainswap
  cswap_key_chain1 = Key.new
  cswap_key_chain2 = Key.new

  web3_chain1 = Web3ETH.new
  web3_chain2 = Web3CTH.new

  pair = "eth-cth"
  price = "100"

  side = "buy"
  amount = "1"
  created_at = Time.now
  nonce = web3_chain1.get_nonce address: user1.address

  web3_chain1.sign_create_order_tx_user admin: cswap_key_chain1.address, address: user1.address, pubkey: user1.pubkey, side: side, amount: amount, price: price, created_at: created_at, nonce: nonce

  side = "sell"
  amount = "0.5"
  created_at = Time.now
  nonce = web3_chain2.get_nonce address: user2.address

  web3_chain2.sign_create_order_tx_user admin: cswap_key_chain2.address, address: user1.address, pubkey: user1.pubkey, side: side, amount: amount, price: price, created_at: created_at, nonce: nonce


  web3_chain1.sign_tx key: cswap_key_chain1


  # possible hacks
  #
  # double spend attack - we're f****d :D, e.g. 51% hashing attack on the smaller chain, reverse the chain, chainswap will think that the current orders are not executed

end
