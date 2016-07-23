require 'json'

class Flash
  attr_reader :now

  def initialize(req)
    flash_cookie = req.cookies["_third_rail_app_flash"]
    if flash_cookie
      @flash = JSON.parse(flash_cookie)
    else
      @flash = {}
    end
    @now = {}
  end

  def [](key)
    @flash[key] || @now[key]
  end

  def []=(key, val)
    @flash[key] = val
  end

  def store_flash(res)
    res.set_cookie("_third_rail_app_flash", path: "/", value: @flash.to_json)
  end
end
