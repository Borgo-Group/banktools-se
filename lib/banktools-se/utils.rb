module BankTools
  module SE
    module Utils
      MOD11_WEIGHTS = [ 1, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]


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

      # Based on/copied from https://github.com/badmanski/mod11

      def self.valid_mod11?(number)

        digits = number.to_s.scan(/\d/).reverse.map { |x| x.to_i }
        digits = digits.each_with_index do |char, i|
          char.to_i * MOD11_WEIGHTS[i]
        end

        sum = digits.inject(0) { |m, x| m + x }
        sum % 11 == 0
      end

      def self.mod11_checksum(number)
        digits = number.to_s.scan(/\d/).reverse.map { |x| x.to_i }
        digits = digits.each_with_index do |char, i|
          char.to_i * MOD11_WEIGHTS[i]
        end

        sum = digits.inject(0) { |m, x| m + x }
        remainder = 10 - sum % 11

        case remainder
        when 0 then remainder
        when 1 then nil
        else 11 - remainder
        end
      end
    end
  end
end
