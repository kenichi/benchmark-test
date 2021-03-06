require 'yaml'
require 'bundler'
Bundler.require
require 'angelo/tilt/erb'

class BenchmarkViewer < Angelo::Base
  include Angelo::Tilt::ERB

  before do
#    @gt = Geotrigger::Application.new YAML.load_file 'geotrigger.yml'
  end

  get '/' do
    @run = params["run"]
    @tag = params["tag"]
    @os = params["os"]
    @wifi = params["wifi"]
    @mode = [@os, @tag, @wifi].join('_')
    erb :index
  end

end

BenchmarkViewer.run
