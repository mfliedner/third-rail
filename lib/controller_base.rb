require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
    @already_built_response = false
    @@protect_from_forgery ||= false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise DoubleRenderError if already_built_response?
    @res['Location'] = url
    @res.status = 302
    @already_built_response = true
    store_session
    store_flash
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise DoubleRenderError if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    @already_built_response = true
    store_session
    store_flash
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    template = ERB.new(File.read(path))
    render_content(template.result(binding), "text/html")
  end

  # methods exposing `Session` and `Flash` objects
  def session
    @session ||= Session.new(@req)
  end

  def store_session
    session.store_session(@res)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def store_flash
    flash.store_flash(@res)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    if protect_from_forgery? && req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end
    
    self.send(name)
    self.render(name) unless already_built_response?
    nil
  end

  def form_authenticity_token
    @token ||= generate_authenticity_token
    res.set_cookie('authenticity_token', value: @token, path: '/')
    @token
  end

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  private

  def protect_from_forgery?
    @@protect_from_forgery
  end

  def check_authenticity_token
    cookie = @req.cookies["authenticity_token"]
    unless cookie && cookie == params["authenticity_token"]
      raise "Invalid authenticity token"
    end
  end

  def generate_authenticity_token
    SecureRandom.urlsafe_base64(16)
  end
end
