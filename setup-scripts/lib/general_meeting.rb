require 'date'

class GeneralMeeting
  def initialize(date, times)
    @date = date
    @times = times
  end

  attr_reader :date, :times
end

class JapaneseEra
  def initialize(first_date: , end_date: , kanji: )
    @first_date = first_date
    @end_date = end_date
    @kanji = kanji
  end

  def include?(date)
    first_date  = self.first_date
    end_date    = self.end_date || Date.today

    (first_date .. end_date).include? date.to_date
  end

  def format_year(date)
    year = self.era_year_of(date)
    year = '元年' if year.equal? 1

    "#{self.kanji}#{year}"
  end

  def era_year_of(date)
    year = date.to_date.year - era.start_date.year + 1
  end

  def self.from(date)
    ERAS.find {|era| era.include?(date.to_date) }
  end

  def self.format_year(date)
    self.from(date).format_year(date)
  end

  attr_reader :first_date, :end_date, :kanji

  SHOWA  = self.new(start_date: Date.new(1926, 12, 25), end_date: Date.new(1989, 1, 7), kanji: '昭和')
  HEISEI = self.new(start_date: Date.new(1989, 1, 8),   end_date: nil,                  kanji: '平成')

  ERAS = [ SHOWA, HEISEI ]

  private_class_method :new
end

class MeetingDate
  def initialize(date)
    @date = date.to_date
  end

  def japanese_era_year
    JapaneseEra.format_date(@date)
  end

  # 前期
  def is_first_semester?
    (4..9).include? @date.month
  end

  # 後期
  def is_second_semester?
    [10..12, 1..3].any? {|range| range.include? @date.month }
  end
end
