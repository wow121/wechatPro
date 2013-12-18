class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def check_login
    if cookies[:merchant_id].blank?
      Rails.logger.info "check_login merchant id is nil"
      redirect_to "/admin/index.html"
      return false
    else
      Rails.logger.info "check_login merchant id is not nil"
      return true
    end
  end
end
