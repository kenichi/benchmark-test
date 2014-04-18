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
    @trigger_list = @gt.post 'trigger/list', boundingBox: :geojson
    erb :index
  end

end

BenchmarkViewer.run
