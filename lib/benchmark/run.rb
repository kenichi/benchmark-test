module Benchmark
  class Run

    include Benchmark::CSV
    include Benchmark::Time

    attr_accessor :device_id, :mode, :os, :tag, :wifi, :markers

    attr_reader :battery_start, :battery_stop

    manage_timestamps :markers

    def initialize opts={}
      super
      @device_id = opts[:device_id]
      @mode = opts[:mode]
      @os = opts[:os]
      @tag = opts[:tag]
      @wifi = opts[:wifi] || 'wifi'
    end

    def description
      "#{@mode}: #{@os} #{@tag} #{@wifi} #{@device_id}\n" +
      "  - #{items.size} data points over #{total_minutes} minutes\n" +
      "  - #{items.select{|i| i.type == 'enter'}.size} enter and #{items.select{|i| i.type == "exit"}.size} exit\n" +
      "  - battery: %.2f percent per hour" % battery_usage
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

    def to_features opts={}
      properties = {os: @os, mode: @mode, wifi: @wifi, device_id: @device_id}
      properties.merge!(opts)

      @markers.collect{|m| Benchmark::FeatureWriter.create_point m, properties}
    end

    def csv_header
      %w{ Timestamp Type Lon Lat Accuracy Trigger Device OS Mode Wifi }
    end

    def csv_body
      @markers.collect do |marker|
        [marker.timestamp, marker.type, marker.lon, marker.lat, marker.accuracy,
         marker.trigger_id, @device_id, @os, @mode, @wifi]
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

    def to_feature opts={}
      properties = {type: @type, accuracy: @accuracy, trigger_id: @trigger_id}
      properties["time"] = ::Time.at(timestamp).to_s
      properties.merge!(opts)

      Benchmark::FeatureWriter.create_point self, properties
    end
  end
end
