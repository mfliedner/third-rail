require 'json'

class Flash
  attr_reader :now

  def initialize(req)
    flash_cookie = req.cookies["_rails_lite_app_flash"]
    if flash_cookie
      @flash = JSON.parse(flash_cookie)
    else
      @flash = {}
    end
    @now = {}
    p @flash
  end

  def [](key)
    p key
    p @flash
    p @flash[key.to_s]
    p @now
    p @now[key]
    p @flash[key] || @now[key]
    @flash[key] || @now[key]
  end

  def []=(key, val)
    p "key: #{key}, val: #{val}"
    @flash[key] = val
  end

  # def now
  #   @flash_now = @flash
  # end

  def store_flash(res)
    res.set_cookie("_rails_lite_app_flash", path: "/", value: @flash.to_json)
  end
end
