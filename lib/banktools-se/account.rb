# encoding: utf-8

# https://www.bankgirot.se/globalassets/dokument/anvandarmanualer/bankernaskontonummeruppbyggnad_anvandarmanual_sv.pdf

require "banktools-se/account/clearing_number"

module BankTools
  module SE
    class Account
      DEFAULT_SERIAL_NUMBER_LENGTH = 7
      CLEARING_NUMBER_MAP = ClearingNumber::MAP

      attr_reader :number

      def initialize(number)
        @number = number
      end

      def valid?
        errors.empty?
      end

      def errors
        errors = []

        errors << Errors::TOO_SHORT if serial_number.length < min_length
        errors << Errors::TOO_LONG if serial_number.length > max_length
        errors << Errors::INVALID_CHARACTERS if number.to_s.match(/[^\d -]/)

        if mod10_for_serial?
          errors << Errors::BAD_CHECKSUM unless Utils.valid_mod10?(serial_number)
        end

        if mod11_for_serial?
          errors << Errors::BAD_CHECKSUM unless validate_mod11
        end

        errors << Errors::UNKNOWN_CLEARING_NUMBER unless bank

        errors
      end

      def normalize
        if valid?
          [ clearing_number, serial_number ].join("-")
        else
          number
        end
      end

      def bank
        bank_data[:name]
      end

      def type
        bank_data[:type]
      end

      def clearing_number
        [
          digits[0, 4],
          checksum_for_clearing? ? digits[4, 1] : nil,
        ].compact.join("-")
      end

      def serial_number
        number = digits.slice(clearing_number_length..-1) || ""

        if zerofill?
          number.rjust(serial_number_length, "0")
        else
          number
        end
      end

      private

      def clearing_number_length
        checksum_for_clearing? ? 5 : 4
      end

      def bank_data
        number = digits[0, 4].to_i
        _, found_data = CLEARING_NUMBER_MAP.find { |interval, data| interval.include?(number) }
        found_data || {}
      end

      def min_length
        if bank_data
          Array(serial_number_length).first
        else
          0
        end
      end

      def max_length
        if bank_data
          Array(serial_number_length).last +
            (checksum_for_clearing? ? 1 : 0)
        else
          1 / 0.0  # Infinity.
        end
      end

      def serial_number_length
        bank_data.fetch(:serial_number_length, DEFAULT_SERIAL_NUMBER_LENGTH)
      end

      def mod10_for_serial?
        bank_data[:mod10_for_serial]
      end

      def mod11_for_serial?
        bank_data[:mod11_for_serial]
      end

      def checksum_for_clearing?
        bank_data[:checksum_for_clearing]
      end

      def digits
        number.to_s.gsub(/\D/, "")
      end

      def zerofill?
        !!bank_data[:zerofill]
      end

      def validate_mod11
        number = digits.gsub(clearing_number.gsub("-", ""), "").scan(/\d/)
        check_digit = number.pop

        number = number.join("").to_s

        resp = if bank_data[:mod11_for_serial][:type] == 1 && bank_data[:mod11_for_serial][:comment] == 1
                 Utils.mod11_checksum(
                   [ clearing_number.split("").last(3), number.rjust(serial_number_length, "0") ].join(""),
                 )
              elsif bank_data[:mod11_for_serial][:type] == 1 && bank_data[:mod11_for_serial][:comment] == 2
                Utils.mod11_checksum(number.rjust(serial_number_length, "0"))
              elsif bank_data[:mod11_for_serial][:type] == 2 && bank_data[:mod11_for_serial][:comment] == 2
                Utils.mod11_checksum(number.rjust(9, "0"))
              else
                Utils.mod10_checksum(number.rjust(10, "0"))
              end

        check_digit.to_i === resp.to_i
      end
    end
  end
end
