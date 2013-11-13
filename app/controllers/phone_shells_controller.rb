class PhoneShellsController < ApplicationController
  def nav
    s = SessionHistory.find_by_user_name(params[:user_name])
	  begin
		  @session_info = JSON.parse s.session_info
			order_id = @session_info["order_id"]
      if order_id != nil
        @order = API.get_order(order_id)
        @order = {} if @order == nil
			  @order_state = @order["state"]
			else
        @order = {}
			  @order_state = nil
			end
		rescue
		  @session_info = @session_info || nil
      @order = {}
			@order_state = nil
		end

    respond_to :html
	end

  def select_machine
	  respond_to :html
	end

	def select_template
    s = SessionHistory.find_by_user_name(params[:user_name])
	  begin
		  @session_info = JSON.parse s.session_info
			machine_info = @session_info["machine"].split("_")
			manu_index = machine_info[1].to_i
      model_index = machine_info[2].to_i

      mobile_model = JsonImporter.machine_info["manufacturers"][manu_index]["models"][model_index]
      @tpl_folder = mobile_model["folder_name"]
			@preview_info = mobile_model["preview_info"]
      @preview_height = @preview_info["height"]
      @preview_width = @preview_info["width"]*300/@preview_height
      @preview_height = 300
      # @preview_width = 500 
      #       @preview_height = 850 
			@neg_half_preview_width = - @preview_width/2
		rescue
		  @session_info = @session_info || {}
		end
    
    @session_info["border"] = "3d" if @session_info["border"] == "white"

	  respond_to :html
	end
  
  def select_shell
    s = SessionHistory.find_by_user_name(params[:user_name])
	  begin
		  @session_info = JSON.parse s.session_info
      @session_info["border"] = "3d" if @session_info["border"] == "white"
		rescue
		  @session_info = nil
		end

  end
 
	def address
    s = SessionHistory.find_by_user_name(params[:user_name])
	  begin
		  @session_info = JSON.parse s.session_info
			@address = @session_info["address"]
			@address = {} if @address == nil
		rescue
		  @session_info = @session_info || {}
			@address = {}
		end
    @order_id = @session_info["order_id"]

	  respond_to :html
	end
	  
	def confirm
	  begin
			@order = API.get_order(params[:order_id])
		rescue
      @order = {
        "products" => [{
          "items" => [{
            "detail_info" => {}
          }]
        }]
      }
		end

		Rails.logger.info "================xxx=============="
		Rails.logger.info @order.to_json

    return redirect_to "/phone_shells/wap_alipay_callback.html?out_trade_no=print20_" + params[:order_id].to_s + "&result=success" if @order["price"] == 0

	  respond_to :html
	end

	def use_coupon
	  res = API.use_coupon(params[:order_id], params[:code])
	  render :json => res
	end

	def complete
	  address = params[:address]
	  s = SessionHistory.save_current_page_state(params[:user_name], {:address => address})
	  session_info = JSON.parse s.session_info

	  user_id = API.login(params[:user_name])
	  Rails.logger.info "=====#{user_id}==========="

	  address_id = API.create_address(user_id, nil, address["city"], nil, address["detail_address"], address["telephone"], address["recipient"])
		Rails.logger.info "=====#{address_id}=========="

	  order = API.create_order(user_id, address_id, session_info["machine"], session_info["display_name"], session_info["template"], session_info["tplname"], session_info["border"], session_info["pic_url"])

	  s = SessionHistory.save_current_page_state(params[:user_name], {:order_id => order["id"]})

	  render :json=>{:result => 0, :order_id => order["id"]}
	end

	def pay
	  callback = "http://weixin.vimi.in/phone_shells/wap_alipay_callback.html"
	  url = API.get_wap_pay_url(params[:order_id], callback)
		redirect_to url
	end

  def save_current_page_state
    SessionHistory.save_current_page_state(params[:user_name], params[:data])
    render :json=>{:result => 0}
  end

	def query_my_order
	  @orders = API.get_order_list(params[:user_name])
	  @detail_info = []
		@orders.each do |order|
		  @detail_info << JSON.parse(order["products"][0]["items"][0]["detail_info"])
		end

	  respond_to :html
	end

	def express
		@order = API.get_order(params[:order_id])

    express_info = @order["products"][0]["express"]
    
    @express = API.express_query(express_info["express_name"], express_info["express_code"])

    @express["data"].reverse! unless @express["data"].nil? || @express["ord"] == "DESC"

		Rails.logger.info "================xxx=============="
		Rails.logger.info @order.to_json

	  respond_to :html
	end

	def wap_alipay_callback
    @order_id = params[:out_trade_no][8..-1]
	  respond_to :html
	end
  
  def share
    @order = API.get_order(params[:order_id])
    
    @detail_info = @order["products"][0]["items"][0]["detail_info"]

		machine_info = @detail_info["machine"].split("_")
		manu_index = machine_info[1].to_i
    model_index = machine_info[2].to_i

    mobile_model = JsonImporter.machine_info["manufacturers"][manu_index]["models"][model_index]
    @tpl_folder = mobile_model["folder_name"]
		@preview_info = mobile_model["preview_info"]
    @preview_height = @preview_info["height"]
    @preview_width = @preview_info["width"]*300/@preview_height
    @preview_height = 300
		@neg_half_preview_width = - @preview_width/2

    @session_info = {
      "border" => @detail_info["border"],
      "pic_url" => @detail_info["pic_url"]
    }

  end
end
