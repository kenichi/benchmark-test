class Run

  include Benchmark::CSV
  include Benchmark::Time

  attr_accessor :device_id, :mode, :wifi, :markers

  attr_reader :battery_start, :battery_stop

  manage_timestamps :markers

  def initialize opts={}
    super
    @device_id = opts[:device_id]
    @mode = opts[:mode]
    @wifi = opts[:wifi] || true
  end

  def battery_start timestamp, battery
    @battery_start = {timestamp: timestamp, battery: battery}
  end

  def battery_stop timestamp, battery
    @battery_stop = {timestamp: timestamp, battery: battery}
  end

  def battery_usage
    unless @battery_start && @battery_stop
      return Float::INFINITY
    end

    seconds = @battery_stop[:timestamp] - @battery_start[:timestamp]
    hours = seconds / 3600.0
    drain = @battery_start[:battery].to_f - @battery_stop[:battery].to_f

    drain / hours
  end

  def csv_header
    %w{ Timestamp Type Lon Lat Accuracy Trigger Device Mode Wifi }
  end

  def csv_body
    @markers.collect do |marker|
      [marker.timestamp, marker.type, marker.lon, marker.lat, marker.accuracy,
       marker.trigger_id, @device_id, @mode, @wifi]
    end
  end
end

class Marker

  attr_reader :timestamp, :type, :lon, :lat, :accuracy, :trigger_id

  def initialize opts={}
    @timestamp = opts[:timestamp]
    @type = opts[:type]
    @lon = opts[:lon]
    @lat = opts[:lat]
    @accuracy = opts[:accuracy]
    @trigger_id = opts[:trigger_id]
  end

  def coordinates
    [lon, lat]
  end

end
