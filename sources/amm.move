// An implementation of a constant product AMM on Aptos.
module aptos_amm::amm {
    use aptos_framework::coin;
    use std::signer;
    use std::string;

    struct LPToken<phantom X, phantom Y> has key {}

    struct TokenPairMetadata<phantom X, phantom Y> has key {
        locked: bool,
        creator: address,
        fee_to: address,
        fee_on: bool,
        k_last: u128,
        lp: coin::Coin<LPToken<X, Y>>,
        balance_x: coin::Coin<X>,
        balance_y: coin::Coin<Y>,
        mint_cap: coin::MintCapability<LPToken<X, Y>>,
        burn_cap: coin::BurnCapability<LPToken<X, Y>>,
    }

    struct TokenPairReserve<phantom X, phantom Y> has key {
        reserve_x: u64,
        reserve_y: u64,
        block_timestamp_last: u64
    }

    // ================= Init functions ========================
    /// Create the specified token pair
    public fun create_token_pair<X, Y>(
        admin: &signer,
        fee_to: address,
        fee_on: bool,
        lp_name: vector<u8>,
        lp_symbol: vector<u8>,
        decimals: u64
    ) {
        let sender_addr = signer::address_of(admin);

        // Init LP token
        let (mint_cap, burn_cap) = coin::initialize<LPToken<X, Y>>(
            admin,
            string::utf8(lp_name),
            string::utf8(lp_symbol),
            decimals,
            true
        );

        move_to(
            admin,
            TokenPairReserve<X, Y> {
                reserve_x: 0,
                reserve_y: 0,
                block_timestamp_last: 0
            }
        );

        move_to(
            admin,
            TokenPairMetadata<X, Y> {
                locked: false,
                creator: sender_addr,
                fee_to,
                fee_on,
                k_last: 0,
                lp: coin::zero<LPToken<X, Y>>(),
                balance_x: coin::zero<X>(),
                balance_y: coin::zero<Y>(),
                mint_cap,
                burn_cap
            }
        );

    }

}
