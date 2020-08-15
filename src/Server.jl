module Server
include("Blockchain.jl")
using .Blockchain

using Sockets, HTTP, JSON

# create a ROUTER
const ROUTER = HTTP.Router()


function get_chain(req::HTTP.Request)
    return JSON.json(Blockchain.chain)
end

function mine_block(req::HTTP.Request)
    previous_block = Blockchain.get_previous_block()
    previous_proof = previous_block["proof"]
    proof = Blockchain.proof_of_work(previous_proof)
    previous_hash = Blockchain.hash(previous_block)

    block = Blockchain.create_block(proof, previous_hash)
    response = Dict("message" => "new block mined",
                    "index" => block["index"],
                    "timestamp" => block["timestamp"],
                    "proof" => block["proof"],
                    "previous_hash" => block["previous_hash"])
    return JSON.json(response)
end

function verify_chain(req::HTTP.Request)
    is_valid = Blockchain.is_chain_valid()
    if(is_valid)
        response = Dict("message" => "Everything looks good")
    else
        response = Dict("message" => "Invalid chain") 
    end
    return JSON.json(response)
end

# create /chain route
HTTP.@register(ROUTER, "GET", "/chain", get_chain) 

# create /mine route 
HTTP.@register(ROUTER, "GET", "/mine", mine_block)

# create /verify route
HTTP.@register(ROUTER, "GET", "/verify", verify_chain)

# run_chain method

run_chain() = HTTP.serve(ROUTER, Sockets.localhost, 8081)

# export run_chain method
export run_chain

end