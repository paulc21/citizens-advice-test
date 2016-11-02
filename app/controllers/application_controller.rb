class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Handle multi-format responses
  def format_response(_message, _root="response")
    respond_to do |format|
      format.html { render json: _message }
      format.json { render json: _message }
      format.xml { render xml: _message.to_xml(:root => _root) }
    end
  end
end
