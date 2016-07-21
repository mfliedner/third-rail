require 'rack'
require 'erb'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue Exception => @exception
      render_exception
    end
  end

  private

  def render_exception
    res = Rack::Response.new

    dir = File.dirname(__FILE__)
    file_name = File.join(dir, "templates", "rescue.html.erb")
    template = File.read(file_name)
    body = ERB.new(template).result(binding)

    res.status = 500
    res['Content-Type'] = 'text/html'

    res.write(body)
    res.finish
  end

  def stack_trace
    @exception.backtrace
  end

  def source_code # pull out problematic code, and preceding / following lines
    pattern = Regexp.new("^(?<path>.*rb):(?<line_num>\\d+).*$")
    capture = pattern.match(@exception.backtrace[0])
    path = capture[:path]
    line_num = capture[:line_num].to_i - 1
    file = File.readlines(path)

    file[line_num - 3..line_num + 3]
  end

  def exception_msg # pull out error message
    @exception.message
  end

end
