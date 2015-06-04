require 'bit_pay_rails'
require 'pry'

module Spree
  class PaymentMethod::BitPay < PaymentMethod
    has_one :bit_pay_client

    def authenticate_with_bitpay uri
      client_check = BitPayClient.find_by_bit_pay_id(self.id)
      client_check.destroy! unless client_check.nil?
      client = BitPayClient.create(api_uri: uri, bit_pay_id: self.id)
      client.save!
      client.get_pairing_code
    end

    def create_invoice params
      self.bit_pay_client.create_invoice(params)
    end

    def get_invoice params
      self.bit_pay_client.get_invoice(params)
    end

    def paired? 
      response = self.bit_pay_client.get_tokens
      return false if response.nil? || response.empty?
      check_tokens(response)
    end

    def api_uri
      self.bit_pay_client.api_uri
    end

    private
    
    def check_tokens response
      return response.reduce(false){|acc, resp| acc || check_token(resp) } if response.class == Array
      check_token response
    end

    def check_token response
      response.keys[0] == "merchant"
    end
  end
  
end
