require 'rack'
require 'erb'

require_relative '../lib/router'
require_relative '../lib/controller_base'
require_relative '../lib/show_exceptions'

# NB: "Hello World" app

class Controller < ControllerBase
  def index
    render_content("HELLO WORLD", "text/html")
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/$"), Controller, :index
end

simple_app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use ShowExceptions
  run simple_app
end.to_app

Rack::Server.start(
 app: app,
 Port: 3000
)
