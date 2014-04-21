class Path

  include Benchmark::CSV
  include Benchmark::Time

  attr_reader :items

  manage_timestamps :items

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

end
