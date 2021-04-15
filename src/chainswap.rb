require "bundler"
require "json"
require "digest/sha1"
require 'digest/sha3'
Bundler.require :default

CERTS_PATH = File.expand_path "../../cert", __FILE__
PATH = File.expand_path "../", __FILE__

STDOUT.sync = true

Excon.defaults[:ssl_verify_peer] = false

# SGX ruby client

FmtSnakecase = -> { Dry::Inflector.new.tableize _1 }

class SGXRb

  CLIENT_CERT = File.open "#{CERTS_PATH}/sgx.crt"
  CLIENT_KEY  = File.open "#{CERTS_PATH}/sgx.key"

  RPC_URL = "https://localhost:1026"

  DEBUG = false
  # DEBUG = true # enables rpc debug log

  LOG_OUTPUT = DEBUG ? STDOUT : File::NULL
  LOG = Logger.new LOG_OUTPUT

  NET = Excon.new RPC_URL, client_cert: CLIENT_CERT, client_key: CLIENT_KEY, logger: LOG, instrumentor: Excon::LoggingInstrumentor

  def jsonrpc(rpc_method:, args:)
    headers = { "Content-Type" => "application/json" }
    rpc_call = {
      "id": 0,
      "jsonrpc": "2.0",
      "method": rpc_method,
      "params": args,
    }
    rpc_call = rpc_call.to_json
    resp = NET.post body: rpc_call, headers: headers
    resp.body
  end

  def self.test_connection
    new.test_connection
  end

  def rpc(rpc_meth, args: {})
    resp = jsonrpc rpc_method: rpc_meth, args: args
    resp = JSON.parse resp
    resp = resp["result"]
    resp = resp.transform_keys &FmtSnakecase
    resp = resp.transform_keys &:to_sym
    puts "#{rpc_meth}:"
    p resp
    resp
  end

  def gen_key
    resp = rpc "generateECDSAKey"
    resp.fetch :key_names
  end

  def sign(message:, with_key:)
    message_hash = Digest::SHA1.hexdigest message
    # message_hash = Digest::SHA3.hexdigest message
    puts "message_hash: #{message_hash}"
    key = with_key
    args = {
      base: 10,
      keyName: key,
      messageHash: message_hash
    }.transform_keys &:to_s
    rpc "ecdsaSignMessageHash", args: args
  end

  def test_connection
    rpc "getServerStatus"
  end

  def initialize
    # ...
  end

end

SGX = SGXRb.new

def main
  puts "test connection"
  SGXRb.test_connection

  key = SGX.gen_key
  p key

  signed_message = SGX.sign message: "test", with_key: key
  p signed_message

  # TODO: verify sgx message in web3

  # TODO - next steps
  #
  # sign message
  # perfom transaction passing signed messages as transaction parameters

  puts "done"
end

main
