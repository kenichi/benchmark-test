require 'json'

module Benchmark

  class FeatureWriter

    def initialize opts={}
      @start_time = opts[:start_time]
      @end_time = opts[:end_time]

      @color_bin_size = (@end_time - @start_time)/COLORS.length
    end

    def self.create_point item, properties
      {
        type: "Feature",
        properties: properties,
        geometry: {
          type: "Point",
          coordinates: item.coordinates
        }
      }
    end

    def self.create_line coord_array, properties={}
      {
        type: "Feature",
        properties: properties,
        geometry: {
          type: "LineString",
          coordinates: coord_array
        }
      }
    end

    def self.create_marker item, opts={}
      properties = {}
      properties['marker-size'] = opts[:size] if opts[:size]
      properties['marker-color'] = opts[:color] if opts[:color]
      properties['marker-symbol'] = opts[:symbol] if opts[:symbol]

      Benchmark::FeatureWriter.create_point(item, properties)
    end

    def featurify_path path, opts={}
      features = []
      if opts[:colorify]
        path_bins = path.inject({}) do |bins, item|
          color_bin = (item.timestamp - @start_time)/@color_bin_size

          bins[color_bin] ||= []
          bins[color_bin] << item
          bins
        end

        path_bins.each do |key, paths|

          color = COLORS[key]
          coords = paths.collect{|i| i.coordinates }

          unless key == 0
            linker = path_bins[key-1].last
            coords = [linker.coordinates] | coords
          end

          properties = {'stroke' => color}
          features << Benchmark::FeatureWriter.create_line(coords, properties)
        end
      else
        coords = path.collect{|i| i.coordinates }
        features << Benchmark::FeatureWriter.create_line(coords)
      end
      return features
    end

    def featurify_triggers triggers
      features = []
      triggers.each do |t|
        features <<  {
          type: "Feature",
          properties: {},
          geometry: t.condition['geo']['geojson']
        }
      end

      return features
    end

    def featurify_markers markers, opts={}
      features = []
      markers.each do |item|
        color = opts[:color]
        color ||= COLORS[(item.timestamp - @start_time)/@color_bin_size]

        size = opts[:size]
        size ||= 'large'

        properties =  { size: 'large', color: color }
        properties[:symbol] = opts[:symbol] if opts[:symbol]
        features << Benchmark::FeatureWriter.create_marker(item, properties)
      end

      return features
    end


    def generate features, file='benchmark.geojson'
      features = [features] unless features.is_a?(Array)
      puts "writing #{features.length} features to #{file}"
      File.open(file, 'w') do |geojson|
        geojson_hash = { type: "FeatureCollection", features: features }
        geojson.write JSON.pretty_generate geojson_hash
      end
    end

    COLORS = [
      "#F3806D",
      "#F47F73",
      "#F57E78",
      "#F57D7D",
      "#F57D83",
      "#F57D89",
      "#F47D8E",
      "#F27E94",
      "#F07E99",
      "#EE7F9F",
      "#EB81A4",
      "#E882A9",
      "#E484AE",
      "#E086B3",
      "#DC88B8",
      "#D78ABC",
      "#D18CC0",
      "#CC8EC4",
      "#C691C8",
      "#BF93CB",
      "#B896CE",
      "#B198D0",
      "#AA9BD2",
      "#A29DD4",
      "#9A9FD5",
      "#92A1D6",
      "#8AA4D7",
      "#81A6D7",
      "#79A8D6",
      "#70A9D5",
      "#67ABD4",
      "#5EADD3",
      "#55AED0",
      "#4CB0CE",
      "#43B1CB",
      "#3AB2C8",
      "#31B4C4",
      "#29B5C1",
      "#22B5BC",
      "#1CB6B8",
      "#19B7B3",
      "#19B8AE",
      "#1CB8A9",
      "#21B8A4",
      "#28B99F",
      "#2FB999",
      "#36B993",
      "#3DB98E",
      "#44B988",
      "#4CB982",
      "#53B87D",
      "#5AB877",
      "#61B872",
      "#68B76C",
      "#6FB667",
      "#75B662",
      "#7CB55D",
      "#83B458",
      "#89B354",
      "#90B250",
      "#96B04C",
      "#9CAF49",
      "#A3AE46",
      "#A9AC43",
      "#AFAA41",
      "#B5A940",
      "#BBA73F",
      "#C1A53E",
      "#C6A33F",
      "#CCA13F",
      "#D19F41",
      "#D69D43",
      "#DB9B45",
      "#E09848",
      "#E4964B",
      "#E8944E",
      "#EC9252",
      "#F09056",
      "#F38E5B",
      "#F68C5F",
      "#F98A64",
    ]
  end
end
