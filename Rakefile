$: << "."
require 'lib/benchmark'

namespace :parse do

  task :realtime do
    path, realtime = Benchmark::Parser.parse_realtime

    path.write_csv 'path_test_write.csv'
    realtime.write_csv 'realtime_test_write.csv'
  end

  task :region do
    region = Benchmark::Parser.parse_region

    region.write_csv 'region_test_write.csv'
  end

  task :adaptive do
    adaptive = Benchmark::Parser.parse_adaptive

    adaptive.write_csv 'adaptive_test_write.csv'
  end

  task :timeline do
    path, realtime = Benchmark::Parser.parse_realtime 'analyze/realtime.txt'
    region = Benchmark::Parser.parse_region 'analyze/region.txt'
    adaptive = Benchmark::Parser.parse_adaptive 'analyze/sdk.txt'

    realtime.trim path.start_time, path.end_time
    region.trim path.start_time, path.end_time
    adaptive.trim path.start_time, path.end_time

    puts "gathered path data of #{path.total_minutes} minutes with #{path.items.size} data points"
    puts
    puts "found #{realtime.items.size} realtime data points over #{realtime.total_minutes} minutes"
    puts "     - #{realtime.items.select{|i| i.type == 'enter'}.size} enter and #{realtime.items.select{|i| i.type == "exit"}.size} exit"
    puts "found #{region.items.size} region data points over #{region.total_minutes} minutes"
    puts "     - #{region.items.select{|i| i.type == 'enter'}.size} enter and #{region.items.select{|i| i.type == "exit"}.size} exit"
    puts "found #{adaptive.items.size} adaptive data points over #{adaptive.total_minutes} minutes"
    puts "     - #{adaptive.items.select{|i| i.type == 'enter'}.size} enter and #{adaptive.items.select{|i| i.type == "exit"}.size} exit"


    fw = Benchmark::FeatureWriter.new start_time: path.start_time, end_time: path.end_time
    fw.generate path.to_feature, 'public/data/path.geojson'

    colors = {path: "#F765E1",
              realtime: {enter: "#F72F2F", exit: "#A11010"},
              region: {enter: "#5873E0", exit: "#0D34D1"},
              adaptive: {enter: "#49E364", exit: "#1B852E"}}

    marker_features = []
    marker_features += path.items.collect{|i| i.to_feature color: colors[:path], radius: 5}
    marker_features += realtime.items.collect{|i| i.to_feature color: colors[:realtime][i.type.to_sym], radius: 10}
    marker_features += region.items.collect{|i| i.to_feature color: colors[:region][i.type.to_sym], radius: 10}
    marker_features += adaptive.items.collect{|i| i.to_feature color: colors[:adaptive][i.type.to_sym], radius: 10}

    marker_features.sort_by! {|f| f[:properties]["time"] }

    fw.generate marker_features, 'public/data/slider.geojson' 

  end

=begin

old stuff
    fw = Benchmark::FeatureWriter.new start_time: path.start_time, end_time: path.end_time

    second_timestamp = path.items[1].timestamp
    current_path = []
    (second_timestamp..path.end_time).each do |timestamp|

      path_items = path.items_at timestamp
      current_path += path_items if path_items

      features = []
      features += fw.featurify_path current_path if current_path.length > 1

      opts_hash = {"realtime" => {symbol: 'fire-station', color: '#ff0000'},
                   "region" => {symbol: 'zoo', color: '#00ff00'},
                   "adaptive" => {symbol: 'star', color: '#0000ff'}
      }

      [realtime, region, adaptive].each do |run|

        marker_json = {}
        run.markers.sort_by(&:timestamp).each do |marker|
          marker_json
        end

        markers = run.items_at timestamp 
        next if markers.empty?
        features += fw.featurify_markers(markers, {} ) #opts_hash[run.mode])
      end

      fw.generate features, "timeslice/feature_#{timestamp - second_timestamp}.geojson"

    end

  end
=end
end


