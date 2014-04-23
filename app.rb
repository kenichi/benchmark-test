require 'yaml'
require 'bundler'
Bundler.require
require 'angelo/tilt/erb'

class BenchmarkViewer < Angelo::Base
  include Angelo::Tilt::ERB

  before do
    @gt = Geotrigger::Application.new YAML.load_file 'geotrigger.yml'
  end

  get '/' do
    @tag = params["tag"]
    @os = params["os"]
    @wifi = params["wifi"]
    @mode = [@os, @tag, @wifi].join('_')
    #@trigger_list = @gt.post 'trigger/list', tags: [@tag], boundingBox: :geojson
    @trigger_list = @gt.post 'trigger/list', tags: ['biking'], boundingBox: :geojson
    erb :index
  end

end

BenchmarkViewer.run
