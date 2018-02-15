require 'rspec'
require_relative '../lib/model/general_meeting'

module Model::GeneralMeeting
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

  describe ".format_year" do
    it "は、年号を表す文字列を返す" do
      expect(JapaneseEra.format_year(Date.new(1989, 1, 7))).to eq('昭和64年')
      expect(JapaneseEra.format_year(Date.new(1989, 1, 8))).to eq('平成元年')
      expect(JapaneseEra.format_year(Date.new(2017, 8, 8))).to eq('平成29年')
    end
  end

  describe ".era_year_of" do
    it "は、ある年号における年をIntegerで返す" do
      expect(JapaneseEra::SHOWA.era_year_of(Date.new(1989, 1, 7))).to eq(64)
      expect(JapaneseEra::HEISEI.era_year_of(Date.new(1989, 1, 8))).to eq(1)
      expect(JapaneseEra::HEISEI.era_year_of(Date.new(2017, 8, 8))).to eq(29)
    end

    it "は、不正な年号を受け取ると、例外を投げる" do
      expect { JapaneseEra::SHOWA.era_year_of(Date.new(1989, 1, 8))  }.to raise_error(ArgumentError)
      expect { JapaneseEra::HEISEI.era_year_of(Date.new(1989, 1, 7)) }.to raise_error(ArgumentError)
    end
  end
end
end
