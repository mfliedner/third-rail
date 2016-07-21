class Static
  attr_reader :app, :route, :asset

  def initialize(app)
    @app = app
    @route = :public
    @asset = StaticAsset.new(route)
  end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path

    if path.index("/#{@route}")
      res = asset.call(env)
    else
      res = app.call(env)
    end
    res
  end
end

class StaticAsset

  MIME_TYPES = {
    '.txt' => 'text/plain',
    '.jpg' => 'image/jpeg',
    '.zip' => 'application/zip'
  }

  def initialize(route)
    @route = route
  end

  def call(env)
    res = Rack::Response.new
    req = Rack::Request.new(env)

    path = req.path
    dir = File.dirname(__FILE__)
    file_name = File.join(dir, "..", path)

    if File.exist?(file_name)
      respond_with_asset(res, file_name)
    else
      res.status = 404
      res.write("File not found")
    end
    res
  end

  private

  def respond_with_asset(res, file_name)
    ext = File.extname(file_name)
    content_type = MIME_TYPES[ext]
    res["Content-type"] = content_type
    res.write(File.read(file_name))
  end
end
