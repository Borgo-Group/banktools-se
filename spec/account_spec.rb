# encoding: utf-8

require "spec_helper"
require "banktools-se"

describe BankTools::SE::Account do
  it "should initialize" do
    expect(BankTools::SE::Account.new("foo")).to be_a(BankTools::SE::Account)
  end

  describe "#valid?" do
    it "should be true with no errors" do
      account = BankTools::SE::Account.new("foo")
      allow(account).to receive(:errors).and_return([])
      expect(account).to be_valid
    end

    it "should be false with errors" do
      account = BankTools::SE::Account.new("foo")
      allow(account).to receive(:errors).and_return([ :error ])
      expect(account).not_to be_valid
    end

    it "should be true with no errors when correct checksum" do
      account = BankTools::SE::Account.new("8351-93922422245")
      expect(account.errors).not_to include(BankTools::SE::Errors::BAD_CHECKSUM)
    end

    it "should be false with errors when incorrect checksum" do
      account = BankTools::SE::Account.new("8351-93922422240")
      expect(account.errors).to include(BankTools::SE::Errors::BAD_CHECKSUM)
    end
  end

  describe "#errors" do
    [
      "1100-0017728",       # Nordea.
      "1200-0017729",       # Danske Bank.
      "1400-0017720",       # Nordea.
      "2300-0017727",       # Ålandsbanken.
      "2400-0017720",       # Danske Bank.
      "3000-0017727",       # Nordea.
      "3300-8009286249",   # Nordea personkonto.
      "3301-0017720",       # Nordea.
      "3400-0017720",       # Länsförsäkringar Bank.
      "3410-0017721",       # Nordea.
      "3782-8009286249",   # Nordea personkonto.
      "3783-0017723",       # Nordea.
      "4164-0010720",       # Nordea.
      "5000-0017727",       # SEB.
      "6196-123456784",     # Handelsbanken.
      "7000-0017727",       # Swedbank.
      "8000-93922422245",  # Swedbank/Sparbanker with clearing number checksum.
      "9020-0017727",       # Länsförsäkringar Bank.
      "9040-0017727",       # Citibank.
      "9060-0017722",       # Länsförsäkringar Bank.
      "9090-0017727",       # Royal Bank of Scotland.
      "9100-0017727",       # Nordnet Bank.
      "9120-0017708",       # SEB.
      "9130-0017720",       # SEB.
      "9150-0017727",       # Skandiabanken.
      "9170-0017724",       # Ikano Bank.
      "9180-3922422245",    # Danske Bank.
      "9190-0017727",       # Den Norske Bank.
      "9230-0017721",       # Marginalen.
      "9250-0017723",       # SBAB.
      "9260-0017727",       # Den Norske Bank.
      "9270-0017725",       # ICA Banken.
      "9280-0017726",       # Resurs Bank.
      "9300-3922422245",    # Sparbanken Öresund.
      "9400-0017720",       # Forex Bank.
      "9460-0017726",       # GE Money Bank.
      "9470-0017727",       # Fortis Bank.
      "9500-00",            # Nordea/Plusgirot.
      "95583214820",       # Avanza Bank.
      "9570-3922422245",    # Sparbanken Syd.
      "9789-0017727",        # Klarna Bank.
      "9960-00",            # Nordea/Plusgirot.
    ].each do |number|
      it "should be empty for a valid number like #{number}" do
        expect(BankTools::SE::Account.new(number).errors).to eq([])
      end
    end

    it "should include :too_short for numbers shorter than the bank allows" do
      expect(BankTools::SE::Account.new("11007").errors).to include(BankTools::SE::Errors::TOO_SHORT)
    end

    xit "should not include :too_short for Swedbank/Sparbanker numbers that can be zerofilled" do
      expect(BankTools::SE::Account.new("8000-2-00000000").errors).not_to include(BankTools::SE::Errors::TOO_SHORT)
      expect(BankTools::SE::Account.new("9300-2-00000000").errors).not_to include(BankTools::SE::Errors::TOO_SHORT)
      expect(BankTools::SE::Account.new("9570-2-00000000").errors).not_to include(BankTools::SE::Errors::TOO_SHORT)
    end

    it "should include :too_long for numbers longer than the bank allows" do
      expect(BankTools::SE::Account.new("1100000000007").errors).to include(BankTools::SE::Errors::TOO_LONG)
    end

    it "should not include :too_long for Swedbank/Sparbanker numbers with clearing checksum" do
      expect(BankTools::SE::Account.new("8000-2-0000000000").errors).not_to include(BankTools::SE::Errors::TOO_LONG)
    end

    it "should include :invalid_characters for numbers with other character than digits, spaces and dashes" do
      expect(BankTools::SE::Account.new("1 2-3X").errors).to include(BankTools::SE::Errors::INVALID_CHARACTERS)
      expect(BankTools::SE::Account.new("1 2-3").errors).not_to include(BankTools::SE::Errors::INVALID_CHARACTERS)
    end

    it "should include :bad_checksum for Nordea personkonto if the serial Luhn/mod 10 checksum is incorrect" do
      expect(BankTools::SE::Utils.valid_mod10?("800928-6249")).to eq(true)
      expect(BankTools::SE::Utils.valid_mod10?("3300-800928-6249")).to eq(false)
      expect(BankTools::SE::Account.new("3300-800928-6249").errors).not_to include(BankTools::SE::Errors::BAD_CHECKSUM)
    end

    it "should include :unknown_clearing_number if the clearing number is unknown" do
      expect(BankTools::SE::Account.new("10000000009").errors).to include(BankTools::SE::Errors::UNKNOWN_CLEARING_NUMBER)
      expect(BankTools::SE::Account.new("11000000007").errors).not_to include(BankTools::SE::Errors::UNKNOWN_CLEARING_NUMBER)
    end
  end

  describe "#bank" do
    it "should return the bank for the current clearing number" do
      expect(BankTools::SE::Account.new("11000000007").bank).to eq("Nordea")
      expect(BankTools::SE::Account.new("11550000001").bank).to eq("Nordea")
      expect(BankTools::SE::Account.new("11990000009").bank).to eq("Nordea")
      expect(BankTools::SE::Account.new("12000000005").bank).to eq("Danske Bank")
    end

    it "should return nil for unknown clearing numbers" do
      expect(BankTools::SE::Account.new("10000000009").bank).to be_nil
    end
  end

  describe "#clearing_number" do
    it "should be the first four digits" do
      expect(BankTools::SE::Account.new("12345678").clearing_number).to eq("1234")
    end

    it "should be the first five digits if there is a clearing number checksum" do
      expect(BankTools::SE::Account.new("8000-2-0000000000").clearing_number).to eq("8000-2")
    end
  end

  describe "#serial_number" do
    it "should be the digits after the first four digits" do
      expect(BankTools::SE::Account.new("12345678").serial_number).to eq("5678")
    end

    it "should be the digits after the first five digits if there is a clearing number checksum" do
      expect(BankTools::SE::Account.new("8000-2-0000000000").serial_number).to eq("0000000000")
    end

    it "should be the empty string if there aren't enough numbers" do
      expect(BankTools::SE::Account.new("12").serial_number).to eq("")
    end

  end

  describe "#normalize" do
    it "should normalize to clearing number dash serial number" do
      account = expect(BankTools::SE::Account.new("37828009286249").normalize).to eq("3782-8009286249")
    end

    it "should keep any Swedbank/Sparbanker clearing checksum" do
      expect(BankTools::SE::Account.new("8000-2-0000000000").normalize).to eq("8000-2-0000000000")
    end

    it "should not attempt to normalize invalid numbers" do
      account = expect(BankTools::SE::Account.new(" 1-2-3 ").normalize).to eq(" 1-2-3 ")
    end

    xit "should prepend zeroes to the serial number if necessary" do
      expect(BankTools::SE::Account.new("8000-2-80000003").normalize).to   eq("8000-2-0080000003")
      expect(BankTools::SE::Account.new("8000-2-8000000003").normalize).to eq("8000-2-8000000003")
    end
  end
end
