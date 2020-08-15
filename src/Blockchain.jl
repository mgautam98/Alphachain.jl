module Blockchain

    # Import packagers
    using SHA, JSON, Dates

    # create expty chain
    chain = []

    # init Genesis block
    function __init__()
        global chain = []
        create_block(1, "0")
    end

    # create block method
    function create_block(proof, previous_hash)
        block = Dict("index" => length(chain) + 1,
                    "timestamp" => Dates.now(),
                    
                    "proof" => proof,
                    "previous_hash" => previous_hash)
        push!(chain, block)
        return block
    end

    # get_previous_block method
    function get_previous_block()
        return last(chain)
    end

    # hash method
    function hash(block)
        return bytes2hex(sha256(JSON.json(block)))   
    end

    # proof_of_work method
    function proof_of_work(previous_proof)
        new_proof = 1
        check_proof = false

        while check_proof == false
            hash_operation = bytes2hex(sha256(string(new_proof^2 - previous_proof^2)))
            if hash_operation[1:4] == "0000"
                check_proof = true
            else
                new_proof += 1
            end
        end
        return new_proof
    end

    # is_chain_valid method
    
    function is_chain_valid()
        previous_block = chain[1]
        block_index = 2

        while block_index < length(chain)
            block = chain[block_index]
            if block["previous_hash"] != hash(previous_block)
                return false
            end
            previous_proof = previous_block["proof"]
            proof = block["proof"]
            hash_operation = bytes2hex(sha256(string(proof^2 - previous_proof^2)))
            if hash_operation[1:4] != "0000"
                return false
            end
            previous_block = block
            block_index += 1
        end
        return true
    end
end