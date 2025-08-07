module janani_addr::MultiRecipientTransfer {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

    struct TransferStats has store, key {
        total_transfers: u64,
        total_recipients: u64,
    }

    public fun initialize_stats(account: &signer) {
        let stats = TransferStats {
            total_transfers: 0,
            total_recipients: 0,
        };
        move_to(account, stats);
    }

    
    public fun batch_transfer(
        sender: &signer,
        recipients: vector<address>,
        amounts: vector<u64>
    ) acquires TransferStats {
        let sender_addr = signer::address_of(sender);
        let recipients_count = vector::length(&recipients);
        let amounts_count = vector::length(&amounts);
        
       
        assert!(recipients_count == amounts_count, 1);
        assert!(recipients_count > 0, 2);

        let i = 0;
        while (i < recipients_count) {
            let recipient = *vector::borrow(&recipients, i);
            let amount = *vector::borrow(&amounts, i);
            
            
            let coins = coin::withdraw<AptosCoin>(sender, amount);
            coin::deposit<AptosCoin>(recipient, coins);
            
            i = i + 1;
        };

        if (exists<TransferStats>(sender_addr)) {
            let stats = borrow_global_mut<TransferStats>(sender_addr);
            stats.total_transfers = stats.total_transfers + 1;
            stats.total_recipients = stats.total_recipients + recipients_count;
        };
    }

}

