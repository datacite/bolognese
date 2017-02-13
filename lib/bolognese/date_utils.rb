module Bolognese
  module DateUtils
    def get_date_parts(iso8601_time)
      return { "date_parts" => [[]] } if iso8601_time.nil?

      year = iso8601_time[0..3].to_i
      month = iso8601_time[5..6].to_i
      day = iso8601_time[8..9].to_i
      { 'date-parts' => [[year, month, day].reject { |part| part == 0 }] }
    end

    def get_year_month(iso8601_time)
      return [] if iso8601_time.nil?

      year = iso8601_time[0..3]
      month = iso8601_time[5..6]

      [year.to_i, month.to_i].reject { |part| part == 0 }
    end

    def get_year_month_day(iso8601_time)
      return [] if iso8601_time.nil?

      year = iso8601_time[0..3]
      month = iso8601_time[5..6]
      day = iso8601_time[8..9]

      [year.to_i, month.to_i, day.to_i].reject { |part| part == 0 }
    end

    def get_date_parts_from_parts(year, month = nil, day = nil)
      { 'date-parts' => [[year.to_i, month.to_i, day.to_i].reject { |part| part == 0 }] }
    end

    def get_date_from_parts(year, month = nil, day = nil)
      [year.to_s.rjust(4, '0'), month.to_s.rjust(2, '0'), day.to_s.rjust(2, '0')].reject { |part| part == "00" }.join("-")
    end

    # parsing of incomplete iso8601 timestamps such as 2015-04 is broken
    # in standard library
    # return nil if invalid iso8601 timestamp
    def get_datetime_from_iso8601(iso8601_time)
      ISO8601::DateTime.new(iso8601_time).to_time.utc
    rescue
      nil
    end
  end
end
