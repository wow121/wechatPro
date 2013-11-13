class API
  @@key = "d*(dDEF2=@YNOPd298&lih#2$"
  @@api_url = "http://api20.vimi.in"

  def API.create_a_coupon(type_id)
	begin
    params = {"coupon_type_id" => type_id}
    query_string =  params.sort.map {|kv| kv[0] + "=" + kv[1].to_s}.join("&")
		sign =  Digest::MD5.hexdigest(query_string + @@key)
    response = RestClient.get @@api_url + "/coupons/create?" + params.to_query, {:sign => sign}
		result = JSON.parse response
		return result["coupon"]
	rescue
	  return nil
	end
	end

  def self.get_wap_pay_url(order_id, callback)
	  params = {}
		params["order_id"] = order_id
		params["callback"] = callback
    query_string =  params.sort.map {|kv| kv[0] + "=" + kv[1].to_s}.join("&")
		sign =  Digest::MD5.hexdigest(query_string + @@key)

    res = RestClient.get @@api_url + "/alipay/get_wap_pay_url?" + params.to_query, {:sign => sign}
		puts res
	  url = JSON.parse(res)["url"]
	end

	def self.login(user_name)
	  params = {}
		params["site"] = "weixin"
		params["site_id"] = user_name
		params["name"] = user_name
    query_string =  params.sort.map {|kv| kv[0] + "=" + kv[1].to_s}.join("&")
		sign =  Digest::MD5.hexdigest(query_string + @@key)

		res = RestClient.post @@api_url + "/users/login", params, {:sign => sign}
		result = JSON.parse res

		return result["user"]["id"]
	end

	def self.create_address(user_id, state, city, district, detail_address, telephone, recipient)
	  params = {}
		params["user_id"] = user_id
		params["state"] = state
		params["city"] = city
		params["district"] = district
		params["detail_address"] = detail_address
		params["telephone"] = telephone
		params["recipient"] = recipient
    query_string =  params.sort.map {|kv| kv[0] + "=" + kv[1].to_s}.join("&")
		sign =  Digest::MD5.hexdigest(query_string + @@key)

		res = RestClient.post @@api_url + "/addresses/create", params, {:sign => sign}
		result = JSON.parse res

		return result["address"]["id"]
	end

	def self.create_order(user_id, address_id, machine, display_name, template, tplname, border, pic_url)
    params = {}
		params["user_id"] = user_id
		params["address_id"] = address_id
		params["platform"] = "weixin"
		params["version"] = "1.0"
		params["channel"] = "moregg"
    params["product_list"] = [{:product_category => "WeixinPhoneShell", :count => 1, :description=>"", 
		                          :item_list => [{:item_category=>"WeixinPhoneShell"}]}].to_json

    query_string =  params.sort.map {|kv| kv[0] + "=" + kv[1].to_s}.join("&")
		sign =  Digest::MD5.hexdigest(query_string + @@key)

		res = RestClient.post @@api_url + "/orders/create", params, {:sign => sign}
		result = JSON.parse(res)["order"]

		order_id = result["id"]
		product_id = result["products"][0]["id"]
		item_id = result["products"][0]["items"][0]["id"]
		
		params = {}
		params["order_id"] = order_id
		params["products_data"] = {product_id => [{:item_category=>"WeixinPhoneShell", :item_id => item_id, 
		                                          :machine => machine, :display_name => display_name,
                                              :template => template,
                                              :tplname => tplname,
																							:border => border, :pic_url => pic_url}]}.to_json

    query_string =  params.sort.map {|kv| kv[0] + "=" + kv[1].to_s}.join("&")
		sign =  Digest::MD5.hexdigest(query_string + @@key)

		res = RestClient.post @@api_url + "/orders/upload_products", params, {:sign => sign}
		result = JSON.parse(res)["order"]

		return result 
	end

	def self.use_coupon(order_id, code)
	  params = {}
		params["order_id"] = order_id
		params["code"] = code 
    query_string =  params.sort.map {|kv| kv[0] + "=" + kv[1].to_s}.join("&")
		sign =  Digest::MD5.hexdigest(query_string + @@key)

		res = RestClient.post @@api_url + "/orders/use_coupon", params, {:sign => sign}
		res = JSON.parse(res)
	end

	def self.get_order(order_id)
	  params = {}
		params["order_id"] = order_id
    query_string =  params.sort.map {|kv| kv[0] + "=" + kv[1].to_s}.join("&")
		sign =  Digest::MD5.hexdigest(query_string + @@key)

		res = RestClient.post @@api_url + "/orders/get_order", params, {:sign => sign}
		order = JSON.parse(res)["order"]
    order["products"][0]["items"][0]["detail_info"] = JSON.parse(order["products"][0]["items"][0]["detail_info"])
    order
  end

	def self.get_order_list(user_name)
	  user_id = self.login(user_name)

	  params = {}
		params["user_id"] = user_id
    query_string =  params.sort.map {|kv| kv[0] + "=" + kv[1].to_s}.join("&")
		sign =  Digest::MD5.hexdigest(query_string + @@key)

		res = RestClient.post @@api_url + "/users/order_list", params, {:sign => sign}
		orders = JSON.parse(res)["order_list"]
	end
  
  def self.express_query(express_name, express_code)
	  params = {
	    "express_name" => express_name,
      "express_code" => express_code
	  }
    query_string =  params.sort.map {|kv| kv[0] + "=" + kv[1].to_s}.join("&")
		sign =  Digest::MD5.hexdigest(query_string + @@key)

		res = RestClient.post @@api_url + "/expresses/query", params, {:sign => sign}
    
    JSON.parse(res)["express_data"]
  end
    
end
