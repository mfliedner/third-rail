require 'rack'
require 'erb'

require_relative '../lib/router'
require_relative '../lib/controller_base'
require_relative '../lib/show_exceptions'

class Controller < ControllerBase
  def index
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/$"), Controller, :index
end

# NB: renders the static root page of Buffon's Needle

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
