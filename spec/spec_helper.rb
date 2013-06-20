PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

# You can use this method to custom specify a Rack app
# you want rack-test to invoke:
#
#   app Xxx::App
#   app Xxx::App.tap { |a| }
#   app(Xxx::App) do
#     set :foo, :bar
#   end
#
def app(app = nil &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end

def load_fixture(file)
  Pathname(Padrino.root("spec/fixtures", file)).read{}
end
