class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def home
  end

  def health
    render text: 'ok'
  end
end
