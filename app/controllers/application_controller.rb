class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def health
    render plain: 'OK'
  end
end
