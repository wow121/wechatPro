class WeixinController < ApplicationController
  def gateway
    if request.method == "GET"
		  result = WeixinProcesser.process_register(params) 
      render :text=> result	  	
			return
		end

    res	= WeixinProcesser.process_msg(params)
	  render :text=>res 
	end

end
