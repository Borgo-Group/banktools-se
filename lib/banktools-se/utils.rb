module BankTools
  module SE
    module Utils
      # Based on http://blog.internautdesign.com/2007/4/18/ruby-luhn-check-aka-mod-10-formula
      def self.valid_mod10?(number)
        digits = number.to_s.scan(/\d/).reverse.map { |x| x.to_i }
        digits = digits.each_with_index.map { |d, i|
          d *= 2 if i.odd?
          d > 9 ? d - 9 : d
        }
        sum = digits.inject(0) { |m, x| m + x }
        sum % 10 == 0
      end

      def self.mod10_checksum(number)
        digits = number.to_s.scan(/\d/).reverse.map { |x| x.to_i }
        digits = digits.each_with_index.map { |d, i|
          d *= 2 if i.even?
          d > 9 ? d - 9 : d
        }
        sum = digits.inject(0) { |m, x| m + x }
        mod = 10 - sum % 10
        mod == 10 ? 0 : mod
      end

      # Based on/copied from https://github.com/tilljoel/bgc-account

      def self.valid_mod11?(number)
        return false unless number

        weights_array = [ 1, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
        digits = number.scan(/./).map(&:to_i)
        weights = weights_array[-digits.length..-1]
        weighted_array = weights.zip(digits).map do |weight, val|
          weight * val
        end
        rest = weighted_array.reduce(0) { |a, e| a + e } % 11
        rest == 0
      end
    end
  end
end
