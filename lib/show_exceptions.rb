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

  def locate_exception
    stack_trace.first.split(":")
  end

  def exception_line_number
    locate_exception[1].to_i
  end

  def source_file_name
    locate_exception.first
  end

  def source_view
    file = File.readlines(source_file_name)
    start_idx = [0, exception_line_number - 3].max
    end_idx = [file.length-1, exception_line_number + 3].min
    file[start_idx..end_idx].map.with_index do |line, i|
      "#{start_idx+i+1}: #{line}"
    end
  end

  def exception_message
    "#{@exception.class}: #{@exception.message}"
  end

end
