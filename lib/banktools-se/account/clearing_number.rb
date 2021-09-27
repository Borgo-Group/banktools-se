# encoding: utf-8

module BankTools
  module SE
    class Account
      module ClearingNumber
        MAP = {
          1100..1199 => { name: "Nordea", type: :bank },
          1200..1399 => { name: "Danske Bank", type: :bank },
          1400..2099 => { name: "Nordea", type: :bank },
          2300..2399 => { name: "Ålandsbanken", type: :bank },
          2400..2499 => { name: "Danske Bank", type: :bank },
          3000..3299 => { name: "Nordea", type: :bank },
          3300..3300 => { name: "Nordea", type: :bank, serial_number_length: 10, luhn_for_serial: true }, # Personkonto.
          3301..3399 => { name: "Nordea", type: :bank },
          3400..3409 => { name: "Länsförsäkringar Bank", type: :bank },
          3410..3781 => { name: "Nordea", type: :bank },
          3782..3782 => { name: "Nordea", type: :bank, serial_number_length: 10, luhn_for_serial: true }, # Personkonto.
          3783..4999 => { name: "Nordea", type: :bank },
          5000..5999 => { name: "SEB", type: :bank },
          6000..6999 => { name: "Handelsbanken", type: :bank, serial_number_length: 8..9 },
          7000..7999 => { name: "Swedbank", type: :bank },
          # Can be fewer chars but must be zero-filled, so let's call it 10.
          8000..8999 => { name: "Swedbank", type: :bank, serial_number_length: 10, checksum_for_clearing: true, zerofill: true },
          9020..9029 => { name: "Länsförsäkringar Bank", type: :bank },
          9040..9049 => { name: "Citibank", type: :bank },
          9060..9069 => { name: "Länsförsäkringar Bank", type: :bank },
          9090..9099 => { name: "Royal Bank of Scotland", type: :bank },
          9100..9109 => { name: "Nordnet Bank", type: :savings },
          9120..9124 => { name: "SEB", type: :bank },
          9130..9149 => { name: "SEB", type: :bank },
          9150..9169 => { name: "Skandiabanken", type: :bank },
          9170..9179 => { name: "Ikano Bank", type: :bank },
          9180..9189 => { name: "Danske Bank", type: :bank, serial_number_length: 10 },
          9190..9199 => { name: "Den Norske Bank", type: :bank },
          9230..9239 => { name: "Marginalen Bank", type: :bank },
          9250..9259 => { name: "SBAB", type: :savings },
          9260..9269 => { name: "Den Norske Bank", type: :bank },
          9270..9279 => { name: "ICA Banken", type: :bank },
          9280..9289 => { name: "Resurs Bank", type: :savings },
          9300..9349 => { name: "Swedbank (fd. Sparbanken Öresund)", type: :bank, serial_number_length: 10, zerofill: true },
          9400..9449 => { name: "Forex Bank", type: :savings },
          9460..9469 => { name: "GE Money Bank", type: :bank },
          9470..9479 => { name: "BNP Paribas", type: :bank },
          9500..9549 => { name: "Nordea/Plusgirot", type: :payment, serial_number_length: 1..10 },
          9550..9569 => { name: "Avanza Bank", type: :savings },
          9570..9579 => { name: "Sparbanken Syd", type: :bank, serial_number_length: 10, zerofill: true },
          9630..9639 => { name: "Lån og Spar Bank Sverige", type: :loans },
          9640..9649 => { name: "Nordax Bank AB", type: :savings },
          9650..9659 => { name: "MedMera Bank", type: :credit },
          9660..9669 => { name: "Svea Bank", type: :bank },
          9670..9679 => { name: "JAK Medlemsbank", type: :bank },
          9680..9689 => { name: "Bluestep Finance", type: :credit },
          9690..9699 => { name: "Folkia", type: :bank },
          9700..9709 => { name: "Ekobanken", type: :bank },
          9720..9729 => { name: "Netfonds Bank (ub)", type: :savings },
          9750..9759 => { name: "Northmill Bank", type: :loan },
          9770..9779 => { name: "FTCS", type: :payment },
          9780..9789 => { name: "Klarna Bank", type: :savings },
          9955..9955 => { name: "Kommuninvest", type: :other },
          9960..9969 => { name: "Nordea/Plusgirot", type: :payment, serial_number_length: 1..10 },
        }
      end
    end
  end
end
