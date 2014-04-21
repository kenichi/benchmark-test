require 'csv'

module Benchmark
  module CSV

    def csv_header
      raise 'must override'
    end

    def csv_body
      raise 'must override'
    end

    def to_csv
      csv = []
      csv << csv_header
      csv += csv_body
      csv.to_csv
    end

    def write_csv file
      ::CSV.open(file, "wb") do |csv|
        csv << csv_header
        csv_body.each {|i| csv << i }
      end
    end
  end
end
