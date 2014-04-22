require 'csv'
require 'json'
require 'geotrigger'

module Benchmark
  class Parser

    attr_reader :properties
    attr_reader :start_time, :end_time

    def initialize
      @properties = {}
    end

    def get_triggers
      gt = Geotrigger::Application.new YAML.load_file 'geotrigger.yml'
      @properties[:triggers] = gt.triggers(tags: 'battery')
    end

    def self.parse_run file, mode
      path = Path.new # only used for realtime run
      run = Run.new mode:mode

      prev_line = nil

      ::CSV.foreach file do |line|

        time = line[0].split(' ').last.to_i

        if time == 0
          time = DateTime.parse(line[0]).strftime('%s').to_i
        end

        if line.length == 8
          if line[6].match('enter') || line[2].match('enter')
            run.add_item Marker.new type: 'enter', timestamp: time, trigger_id: line[1],
              lat: line[3].to_f, lon: line[4].to_f, accuracy: line[5]
          elsif line[6].match('exit') || line[2].match('exit')
            run.add_item Marker.new type: 'exit', timestamp: time, trigger_id: line[1],
              lat: line[3].to_f, lon: line[4].to_f, accuracy: line[5]
          end
        elsif line.length == 5
          if line[3].match 'start'
            run.battery_start time, line[2].to_f
            run.device_id = line[1]
          elsif line[3].match 'stop'
            run.battery_stop time, line[2].to_f
          elsif line[2].match 'enter'
            run.add_item Marker.new type: 'enter', timestamp: time, trigger_id: line[1],
              lat: prev_line[1].to_f, lon: prev_line[2].to_f, accuracy: line[5]

          elsif line[2].match 'exit'
            run.add_item Marker.new type: 'exit', timestamp: time, trigger_id: line[1],
              lat: prev_line[1].to_f, lon: prev_line[2].to_f, accuracy: line[5]

          elsif mode == 'realtime'
            path.add_item Item.new timestamp: time, lat: line[1].to_f, lon: line[2].to_f, accuracy: line[3]
            prev_line = line
          end
        end

      end

      return run if path.items.empty?

      return path, run
    end

    def self.parse_realtime file='realtime.txt'
      return self.parse_run file, 'realtime'
    end

    def self.parse_region file='region.txt'
      return self.parse_run file, 'region'
    end

    def self.parse_adaptive file='sdk.txt'
      return self.parse_run file, 'adaptive'
    end

    def self.parse_timeline directory, os, tag, wifi

      mode = [os, tag, wifi].join('_')

      realtime_file = "#{directory}/realtime_#{mode}.txt"
      region_file = "#{directory}/region_#{mode}.txt"
      adaptive_file = "#{directory}/sdk_#{mode}.txt"

      puts "parsing #{realtime_file}"
      path, realtime = Benchmark::Parser.parse_realtime realtime_file
      if File.exists? region_file
        puts "parsing #{region_file}"
        region = Benchmark::Parser.parse_region region_file
      end
      puts "parsing #{adaptive_file}"
      adaptive = Benchmark::Parser.parse_adaptive adaptive_file

      realtime.trim path.start_time, path.end_time
      region.trim path.start_time, path.end_time if region
      adaptive.trim path.start_time, path.end_time

      puts
      puts "Parsed #{mode} to timeline"
      puts "gathered path data of #{path.total_minutes} minutes with #{path.items.size} data points"
      puts
      puts "Realtime: #{realtime.items.size} data points over #{realtime.total_minutes} minutes"
      puts "     - #{realtime.items.select{|i| i.type == 'enter'}.size} enter and #{realtime.items.select{|i| i.type == "exit"}.size} exit"
      puts "     - battery: %.2f percent per hour" % realtime.battery_usage
      if region
        puts "Region: #{region.items.size} data points over #{region.total_minutes} minutes"
        puts "     - #{region.items.select{|i| i.type == 'enter'}.size} enter and #{region.items.select{|i| i.type == "exit"}.size} exit"
        puts "     - battery: %.2f percent per hour" % region.battery_usage
      end
      puts "Adaptive: #{adaptive.items.size} data points over #{adaptive.total_minutes} minutes"
      puts "     - #{adaptive.items.select{|i| i.type == 'enter'}.size} enter and #{adaptive.items.select{|i| i.type == "exit"}.size} exit"
      puts "     - battery: %.2f percent per hour" % adaptive.battery_usage
      puts

      out_dir = "public/data/#{mode}"
      Dir.mkdir out_dir unless Dir.exists? out_dir

      fw = Benchmark::FeatureWriter.new start_time: path.start_time, end_time: path.end_time
      fw.generate path.to_feature, "#{out_dir}/path.geojson"

      colors = {path: "#F765E1",
                realtime: {enter: "#F72F2F", exit: "#A11010"},
                region: {enter: "#5873E0", exit: "#0D34D1"},
                adaptive: {enter: "#49E364", exit: "#1B852E"}}

      marker_features = []
      marker_features += path.items.collect{|i| i.to_feature color: colors[:path], radius: 3}
      marker_features += realtime.items.collect{|i| i.to_feature color: colors[:realtime][i.type.to_sym], radius: 10}

      if region
        marker_features += region.items.collect{|i| i.to_feature color: colors[:region][i.type.to_sym], radius: 10}
      end

      marker_features += adaptive.items.collect{|i| i.to_feature color: colors[:adaptive][i.type.to_sym], radius: 10}

      marker_features.sort_by! {|f| f[:properties]["time"] }

      fw.generate marker_features, "#{out_dir}/slider.geojson"

    end

  end
end
