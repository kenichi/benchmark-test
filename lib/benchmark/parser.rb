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

          elsif mode == 'realtime'
            path.add_item Item.new timestamp: time, lat: line[1].to_f, lon: line[2].to_f, accuracy: line[3]
          end
        end
      end

      puts sprintf "%s battery usage: %.2f percent per hour", mode, run.battery_usage

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

    def do_it
      features = []

      get_triggers
      features += featurify_triggers

      parse_realtime
      parse_region
      parse_adaptive

      fw = FeatureWriter.new start_time: @start_time, end_time: @end_time

      path_features = fw.featurify_path @properties[:path]

      puts "found #{@properties[:realtime].length} realtime items"
      realtime_features = fw.featurify_markers @properties[:realtime], { symbol: 'fire-station' }


      puts "found #{@properties[:region].length} region items"
      region_features = fw.featurify_markers @properties[:region], { symbol: 'zoo' }

      puts "found #{@properties[:adaptive].length} adaptive items"
      adaptive_features = fw.featurify_markers @properties[:adaptive], { symbol: 'star' }

      fw.generate features

    end
  end
end
