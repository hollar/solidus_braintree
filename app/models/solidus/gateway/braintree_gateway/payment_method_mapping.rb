module Solidus
  class Gateway::BraintreeGateway
    class PaymentMethodMapping
      def self.build(source)
        representer(source.class.name).new(source)
      end

      def self.representer(name)
        self.const_get(name.demodulize)
      rescue NameError
        NullRepresenter
      end
      private_class_method :representer

      Base = Struct.new(:source)

      class PayPalAccount < Base
        def to_hash
          {
            cc_type: 'paypal',
            data: { email: source.email }.to_json
          }
        end
      end

      class CreditCard < Base
        def to_hash
          {
            name: source.cardholder_name,
            cc_type: CARD_TYPE_MAPPING[source.card_type],
            month: source.expiration_month,
            year: source.expiration_year,
            last_digits: source.last_4
          }
        end
      end

      class AndroidPayCard < Base
        def to_hash
          {
            cc_type: "android_pay",
            month: source.expiration_month,
            year: source.expiration_year,
            last_digits: source.source_description
          }
        end
      end

      class ApplePayCard < Base
        APPLE_CARD_TYPE_MAPPING = {
          Braintree::ApplePayCard::CardType::Visa => "apple_pay_visa",
          Braintree::ApplePayCard::CardType::AmEx => "apple_pay_american_express",
          Braintree::ApplePayCard::CardType::MasterCard => "apple_pay_master_card",
          "Apple Pay - Discover" => "apple_pay_discover",
        }

        def to_hash
          {
            cc_type: APPLE_CARD_TYPE_MAPPING[source.card_type],
            month: source.expiration_month,
            year: source.expiration_year,
            last_digits: source.source_description
          }
        end
      end

      class VenmoAccount < Base
        def to_hash
          {
            cc_type: "venmo",
            last_digits: source.source_description
          }
        end
      end

      class NullRepresenter < Base
        def to_hash
          {}
        end
      end
    end
  end
end
