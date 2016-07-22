require 'rack'
require_relative '../lib/show_exceptions'

# NB: demo app throwing exceptions
# in this case, a mispelled pathname:
# "dem" instead of "demo"
#
# The corrected app will bring up the static root page
# of Buffon's Needle (follow the "Project hosted ...")
# link for the live app

app_with_errors = Proc.new do |env|
  res = Rack::Response.new
  file = File.open('./dem/index.html', 'r')
  lines = file.read

  res['Content-Type'] = 'text/html'
  res.write(lines)
  res.finish
end

app = Rack::Builder.new do
  use ShowExceptions
  run app_with_errors
end.to_app

Rack::Server.start({
  app: app,
  Port: 3000
})
