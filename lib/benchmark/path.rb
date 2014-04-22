module Benchmark
  class Path

    include Benchmark::CSV
    include Benchmark::Time

    attr_accessor :os, :tag, :wifi

    attr_reader :items

    manage_timestamps :items

    def initialize opts={}
      super
      @os = opts[:os]
      @tag = opts[:tag]
      @wifi = opts[:wifi] || 'wifi'
    end

    def description
      "path: #{@os} #{@tag} #{@wifi}\n" +
      "  - #{total_minutes} minutes\n" +
      "  - #{items.size} data points"
    end

    def to_feature opts={}

      properties = {os: @os, wifi: @wifi}
      properties.merge!(opts)

      coords = items.collect{|i| i.coordinates}

      Benchmark::FeatureWriter.create_line coords, properties
    end

    def csv_header
      %w{ Timestamp Lon Lat Accuracy }
    end

    def csv_body
      @items.collect do |item|
        [item.timestamp, item.lon, item.lat, item.accuracy]
      end
    end
  end

  class Item

    attr_reader :timestamp, :lon, :lat, :accuracy

    def initialize opts={}
      @timestamp = opts[:timestamp]
      @lon = opts[:lon]
      @lat = opts[:lat]
      @accuracy = opts[:accuracy]
    end

    def coordinates
      [lon, lat]
    end

    def to_feature opts={}
      properties = {accuracy: @accuracy}
      properties["time"] = ::Time.at(timestamp).to_s
      properties.merge!(opts)

      Benchmark::FeatureWriter.create_point self, properties
    end

  end
end
