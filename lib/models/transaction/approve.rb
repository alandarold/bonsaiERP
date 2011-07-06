# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::Transaction
  module Approve

    def approve!
      unless state == "draft"
        false
      else
        self.state       = "approved"
        self.approver_id = UserSession.user_id
        create_account_ledger_details
        self.save
      end
    end

    private
      def create_account_ledger_details
        kl = self.class.to_s

        al = build_account_ledger(
          :account_id => account_id,
          :to_id => Account.org.find_by_original_type(kl).id,
          :currency_id => currency_id,
          :operation => 'transaction',
          :amount => total_currency,
          :reference => "#{I18n.t("#{kl.downcase}.account_ledger_reference")} #{ref_number}",
          :exchange_rate => exchange_rate
        )
        al.account_ledger_details.build(:account_id => account_id, :amount => total_currency, :state => 'con', :currency_id => currency_id )
        al.account_ledger_details.build(:account_id => al.to_id, :amount => - total_currency, :state => 'con', :currency_id => currency_id )
      end
  end
end