require 'rspec'
require_relative '../lib/model/general_meeting'

module Model::GeneralMeeting
RSpec.describe MeetingDate do
  describe "#fiscal_year" do
    it "は、年度を西暦で返す" do
      is_asserted_by { MeetingDate.new(Date.new(1989, 1, 7)).fiscal_year(4) == 1988 }
      is_asserted_by { MeetingDate.new(Date.new(1989, 1, 8)).fiscal_year(4) == 1988 }
      is_asserted_by { MeetingDate.new(Date.new(1989, 4, 8)).fiscal_year(4) == 1989 }
    end
  end

  describe "#fiscal_year_japanese" do
    it "は、年度を和暦で返す" do
      is_asserted_by { MeetingDate.new(Date.new(1989, 1, 7)).fiscal_year_japanese(4) == "昭和63年" }
      is_asserted_by { MeetingDate.new(Date.new(1989, 1, 8)).fiscal_year_japanese(4) == "昭和63年" }
      is_asserted_by { MeetingDate.new(Date.new(1989, 4, 8)).fiscal_year_japanese(4) == "平成元年" }
    end
  end
end

RSpec.describe JapaneseEra do
  describe ".from" do
    it "は、年号オブジェクトを返す" do
      expect(JapaneseEra.from(Date.new(1989, 1, 7))).to be(JapaneseEra::SHOWA)
      expect(JapaneseEra.from(Date.new(1989, 1, 8))).to be(JapaneseEra::HEISEI)
    end

    it "は、未知が年号の場合はnilを返す" do
      expect(JapaneseEra.from(Date.new(9999, 12, 31))).to be_nil
    end
  end

  describe ".year_of" do
    it "は、ある年号における年をIntegerで返す" do
      expect(JapaneseEra::SHOWA.year_of(Date.new(1989, 1, 7))).to eq(64)
      expect(JapaneseEra::HEISEI.year_of(Date.new(1989, 1, 8))).to eq(1)
      expect(JapaneseEra::HEISEI.year_of(Date.new(2017, 8, 8))).to eq(29)
    end

    it "は、不正な年号を受け取ると、例外を投げる" do
      expect { JapaneseEra::SHOWA.year_of(Date.new(1989, 1, 8))  }.to raise_error(ArgumentError)
      expect { JapaneseEra::HEISEI.year_of(Date.new(1989, 1, 7)) }.to raise_error(ArgumentError)
    end
  end
end
end
