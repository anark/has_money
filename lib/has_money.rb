require 'bigdecimal'

module HasMoney

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def has_money(*attributes)
      attributes.each do |attribute|
        class_eval <<-EOS
          def #{attribute}_in_dollars
            return #{attribute} if self.class.zero_decimal_currency?(currency)
            self.class.calculate_dollars_from_cents(#{attribute})
          end

          def #{attribute}_in_dollars=(dollars)
            self.#{attribute} = dollars and return if self.class.zero_decimal_currency?(currency)
            self.#{attribute} = self.class.calculate_cents_from_dollars(dollars)
          end

          # Special dollars only formatting (no decimal place and rounded to the nearest dollar)
          def #{attribute}_in_dollars_without_cents
            return self.#{attribute} if self.class.zero_decimal_currency?(currency)
            self.class.calculate_dollars_without_cents_from_cents(#{attribute})
          end

          def #{attribute}_in_dollars_without_cents=(dollars)
            self.#{attribute} = dollars and return if self.class.zero_decimal_currency?(currency)
            self.#{attribute} = self.class.calculate_cents_from_dollars_without_cents(dollars)
          end
        EOS
      end
    end

    def zero_decimal_currencies
      ['BIF', 'CLP', 'DJF', 'GNF', 'JPY', 'KMF', 'KRW', 'MGA', 'PYG', 'RWF', 'VND', 'VUV', 'XAF', 'XOF', 'XPF']
    end

    def zero_decimal_currency?(currency)
      zero_decimal_currency.include?(currency.upcase)
    end

    def calculate_dollars_from_cents(cents)
      return nil if cents.nil? ||  cents == ''
      "%.2f" % (BigDecimal(cents.to_s) / 100).to_f
    end

    def calculate_cents_from_dollars(dollars)
      return nil if dollars.nil?

      dollars = dollars.to_s.gsub(/[$,]/, "").strip
      dollars[0] = '0.' if dollars =~ /^\.\d{1,2}/
      return nil unless dollars.match(/^-?\d+\.?(\d+)?$/) # xx.xxx

      (BigDecimal(dollars).round(2) * 100).to_i
    end

    def calculate_dollars_without_cents_from_cents(cents)
      return nil if cents.nil? ||  cents == ''
      "%i" % (BigDecimal(cents.to_s) / 100).to_f.round
    end

    def calculate_cents_from_dollars_without_cents(dollars)
      return nil if dollars.nil?

      dollars = dollars.to_s.gsub(/[$,]/, "").strip
      dollars[0] = '0.' if dollars =~ /^\.\d{1,2}/
      return nil unless dollars.match(/^-?\d+\.?(\d+)?$/) # xx.xxx

      (BigDecimal(dollars).round * 100).to_i
    end
  end
end

# Inlcude in all AR Models
ActiveRecord::Base.send :include, HasMoney
