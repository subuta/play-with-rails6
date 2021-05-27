class HelloController < ApplicationController
  def index
    render plain: "OK"
  end
end
