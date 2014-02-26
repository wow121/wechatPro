#encoding: utf-8

class WeixinProcesser
	

	@@chat = "今天天气不错！您想聊些什么呢？
	如果您想要上传照片，请点击菜单的上传按钮
	如果您想要查看您的照片，请点击菜单上的查询按钮
	如果需要帮助，您还可以试试——
	回复【1】：待编辑
	回复【2】：待编辑
	回复【3】：待编辑
	回复【4】：待编辑
	回复【5】：待编辑
	回复【6】：待编辑
	"
	@@token = "weixin_test"
 	@@appid = "wxae61f378f1c0978f"
 	@@appsecret = "d1381a12da5871b7099e3a5a7847db15"
 	
   @@auto_response = {"介绍" => @@chat,
	                    "是什么" => @@chat,
	                    "聊天" => @@chat,
		                  "聊聊"=> @@chat,
		                  "聊一会儿"=> @@chat,
											"说说话"=> @@chat
	                    }
	def self.process_register(params)
     a = []
     a << params[:nonce]
     a << params[:timestamp]
     a << @@token
     a.sort!
 
     #sign_string = params[:nonce] + params[:timestamp] + @@token
     sign_string = a[0] + a[1] + a[2]
 		signed_string = Digest::SHA1.hexdigest(sign_string)
 
 		 Rails.logger.info signed_string
 
 	  if signed_string == params[:signature]
 		  Rails.logger.info "======success!========"
 		  return params[:echostr]
 		else
 		  Rails.logger.info "======error!========"
 		  return "error"
 		end
 	end
  

	def self.process_msg(params)
	  msg = params[:xml]
		Rails.logger.info msg[:MsgType]
		case(msg[:MsgType])
		  when "text"
        return self.process_text(msg) 
			when "image"
        return self.process_image(msg)
			when "voice"
		return self.process_voice(msg)
			when "location"
        return self.process_location(msg)
			when "link"
        return self.process_link(msg)
	    when "event"
			  return self.process_event(msg)
			else
			  return "error" 
	  end
	end
	
	def self.process_voice(msg)
		voice_msg=Message.where("key"=>msg[:Recognition].to_s).first
		if voice_msg==nil
			product=Product.where("sku"=>msg[:Recognition].to_s).first
			if(product==nil)
				return res=self.construct_text_response(msg,"语音识别结果为:\n  "+msg[:Recognition]+"\n对不起，没有找到您想要的产品，请重试")
			else
			return res=self.construct_image_response(msg, product.name.to_s,  product.description.to_s, "http://203.156.196.150:999/"+product.pic,"http://203.156.196.150/win/manage_image?sku="+product.sku.to_s+"&open_id="+msg[:FromUserName])
			#	return res = self.construct_text_response(msg,product.name.to_s)
			end
		#return res = self.construct_text_response(msg,msg[:Recognition].to_s)
		else
			  UserActivityLog.create({:open_id=>msg[:FromUserName],:event=>"key_word",:content=>msg[:Recognition]})
			  voice_msg = JSON.parse voice_msg.value
			  message=voice_msg["id"].to_s
			  message=message.split(/,/)
			  name=[]
			  description=[]
			  pic_url=[]
			  url=[]
			  for id in message
				product=Product.where("id"=>id).first
				if(product!=nil)
					name<<product.name
					description<<product.description
					pic_url<<"http://203.156.196.150:999/"+product.pic
					url<<"http://203.156.196.150/win/manage_image?sku="+product.sku.to_s+"&open_id="+msg[:FromUserName]	
				end 
			  end	
			return res=self.construct_images_response(msg,name,description,pic_url,url)
		end
	end

	def self.process_text(msg)
		product=Product.where("sku"=>msg[:Content]).first
		if(product==nil)
			return res=self.construct_text_response(msg,"没有找到sku")
		else
		return res=self.construct_image_response(msg, product.name.to_s,  product.description.to_s, "http://203.156.196.150:999/"+product.pic,"http://203.156.196.150/win/manage_image?sku="+product.sku.to_s+"&open_id="+msg[:FromUserName])
		#	return res = self.construct_text_response(msg,product.name.to_s)
		end
	end

	def self.process_image(msg)
		
	    
		weixin_url=msg[:PicUrl]
		username=msg[:FromUserName]
		
		user=User.where("weixin_id"=>username).first
		
		if user.status == "update_photo"
			Photos.create({:user_id=>username,:weixin_image_path=>weixin_url,:upload_type=>"-1"})
			user.photo_count=1
			user.status="update_succees_and_input_code"
			user.save
			res = self.construct_text_response(msg, "图片已上传\n您已上传1张照片\n可继续上传或输入授权码")
		elsif  user.status == "update_succees_and_input_code"
			Photos.create({:user_id=>username,:weixin_image_path=>weixin_url,:upload_type=>"1"})
			user.photo_count=user.photo_count+1
			user.save
			res = self.construct_text_response(msg, "图片已上传\n您已上传"+user.photo_count.to_s+"张照片\n可继续上传或输入授权码")
		elsif user.status == "query_picture_all"
			res = self.construct_text_response(msg, "少年别闹 \n查询模式只能回复序号 \n如果要退出查询模式可以回复Q噢")
		else
			res = self.construct_text_response(msg, "请先点击图片上传再上传图片")
		end
		
	  return res
	end

	def self.process_location(msg)
	  Rails.logger.info "process_location"
	end

	def self.process_link(msg)
	  Rails.logger.info "process_link"
	end

	def self.process_event(msg)
	  case msg[:Event]
		  when "subscribe"
			  return self.process_subscribe(msg)
	    when "unsubscribe"
        return self.process_unsubscribe(msg)
	    when "CLICK"
			  return self.process_click(msg)
	 end
	end

	def self.process_subscribe(msg)
	  Rails.logger.info "==========process_subscribe====="
		user=User.where("openid"=>msg[:FromUserName]).first
		if user==nil
			access_token=self.get_access_token
			inf = RestClient.get "https://api.weixin.qq.com/cgi-bin/user/info?access_token="+access_token+"&openid="+msg[:FromUserName]
			inf = JSON.parse inf
			User.create(
			:subscribe=>inf["subscribe"].to_s,
			:openid=>inf["openid"],
			:nickname=>inf["nickname"],
			:sex=>inf["sex"].to_s,
			:language=>inf["language"],
			:city=>inf["city"],
			:province=>inf["province"],
			:country=>inf["country"],
			:headimgurl=>inf["headimgurl"],
			:subscribe_time=>inf["subscribe_time"].to_s
			)
		end
		

		res = self.construct_text_response(msg, "感谢您关注我们！ 回复介绍可查看目录~~")
		
	  return res
	end
	
	def self.process_unsubscribe(msg)
	  Rails.logger.info "==========process_unsubscribe======="
	end

	def self.process_click(msg)
	  Rails.logger.info "==========click==============="
	  btn_msg=Message.where("key"=>"button_message").first
	  Rails.logger.info btn_msg.value
	  btn_msg = JSON.parse btn_msg.value
	  
		case msg[:EventKey]		  
		  
		  when "key_a1"
			  
			  message=btn_msg["key_a1"].to_s
			  message=message.split(/,/)
			  name=[]
			  description=[]
			  pic_url=[]
			  url=[]
			  for id in message
				product=Product.where("id"=>id).first
				if(product!=nil)
					name<<product.name
					description<<product.description+product.to_s
					pic_url<<"http://203.156.196.150:999/"+product.pic
					url<<"http://203.156.196.150/win/manage_image?sku="+product.sku.to_s+"&open_id="+msg[:FromUserName]
				end
			  end			  
			  return res=self.construct_images_response(msg,name,description,pic_url,url)
		  when "key_a2"
			   message=btn_msg["key_a2"].to_s
			  message=message.split(/,/)
			  name=[]
			  description=[]
			  pic_url=[]
			  url=[]
			  for id in message
				product=Product.where("id"=>id).first
				if(product!=nil)
					name<<product.name
					description<<product.description+product.to_s
					pic_url<<"http://203.156.196.150:999/"+product.pic
					#url<<"http://203.156.196.150/win/manage_image?sku="+product.sku.to_s
						url<<"http://203.156.196.150/win/hello"
				end
			  end			  
			  return res=self.construct_images_response(msg,name,description,pic_url,url)
		end
	end

	def self.construct_text_response(msg, content)
	  res_data = REXML::Document.new
		root = res_data.add_element("xml")

		to_user_name_node = root.add_element("ToUserName")
		to_user_name_node.add_text(msg[:FromUserName])

		from_user_name_node = root.add_element("FromUserName")
		from_user_name_node.add_text(msg[:ToUserName])

		create_time_node = root.add_element("CreateTime")
		create_time_node.add_text(Time.now().to_s)

		msg_type_node = root.add_element("MsgType")
	  msg_type_node.add_text("text")

		content_node = root.add_element("Content")
		content_node.add_text(content)

	  Rails.logger.info res_data.to_s
	  res_data.to_s
	end


	def self.construct_image_response(msg, title, description, pic_url, url)
		res_data = REXML::Document.new
		root = res_data.add_element("xml")

		to_user_name_node = root.add_element("ToUserName")
		to_user_name_node.add_text(msg[:FromUserName])

		from_user_name_node = root.add_element("FromUserName")
		from_user_name_node.add_text(msg[:ToUserName])

		create_time_node = root.add_element("CreateTime")
		create_time_node.add_text(Time.now().to_s)

		msg_type_node = root.add_element("MsgType")
	  msg_type_node.add_text("news")

		article_count_node = root.add_element("ArticleCount")
		article_count_node.add_text("1")

		articles = root.add_element("Articles")

		item_1_node = articles.add_element("item")
		title_node = item_1_node.add_element("Title")
		title_node.add_text(title)
		description_node = item_1_node.add_element("Description")
		description_node.add_text(description)
		pic_url_node = item_1_node.add_element("PicUrl")
    pic_url_node.add_text(pic_url)
		url_node = item_1_node.add_element("Url")
    url_node.add_text(url)

=begin
		item_2_node = articles.add_element("item")
		title_node = item_2_node.add_element("Title")
		title_node.add_text("title")
		description_node = item_2_node.add_element("Description")
		description_node.add_text("description")
		pic_url_node = item_2_node.add_element("PicUrl")
		pic_url_node.add_text("")
#pic_url_node.add_text("http://vimi.in/static/test.jpg")
		url_node = item_2_node.add_element("Url")
		url_node.add_text("http://vimi.in")
#url_node.add_text("http://vimi.in")
=end
	  Rails.logger.info res_data.to_s
	  res_data.to_s

	end

	def self.get_access_token
    res = RestClient.get "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid="+APPID+"&secret="+APPSECRET
    access_token = JSON.parse(res)["access_token"]
	end

	def self.create_menu
     string_menu = "{\"button\" : [
										  {\"name\" : \"全部产品\",
											 \"sub_button\" : [
											 {\"type\" : \"click\",
												\"name\" : \"手套\",
												\"key\"  : \"key_a1\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"口罩\",
												\"key\"  : \"key_a2\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"眼镜\",
												\"key\"  : \"key_a3\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"防护服\",
												\"key\"  : \"key_a4\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"耳塞\",
												\"key\"  : \"key_a5\"
											 }
											 ]
											},
										  {\"name\" : \"预留\",
											 \"sub_button\" : [
											 {\"type\" : \"click\",
												\"name\" : \"预留1\",
												\"key\"  : \"key_b1\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"预留2\",
												\"key\"  : \"key_b2\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"预留3\",
												\"key\"  : \"key_b3\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"预留4\",
												\"key\"  : \"key_b4\"
											 }
											 }]
                      }] 
									}"
	   access_token = self.get_access_token
     response =	RestClient.post "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{access_token}", string_menu   
    # response =	RestClient.post "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{access_token}", menus.to_json  

		 puts response
	end

	def self.delete_menu
	   access_token = self.get_access_token
     response =	RestClient.get "https://api.weixin.qq.com/cgi-bin/menu/delete?access_token=#{access_token}"
		 puts response
	end
	
	def self.error_checking(name)
		photos=Photos.where("user_id"=>name)
		for i in photos do
			if(i.merchant_id==nil)
				Photos.delete(i.id)
				end
		end
	end
	def self.mkrandom(len)
		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		newpass = ""
		1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
		return newpass
	end
	
	def self.construct_images_response(msg, title, description, pic_url, url)
		res_data = REXML::Document.new
		root = res_data.add_element("xml")

		to_user_name_node = root.add_element("ToUserName")
		to_user_name_node.add_text(msg[:FromUserName])

		from_user_name_node = root.add_element("FromUserName")
		from_user_name_node.add_text(msg[:ToUserName])

		create_time_node = root.add_element("CreateTime")
		create_time_node.add_text(Time.now().to_s)

		msg_type_node = root.add_element("MsgType")
		msg_type_node.add_text("news")

		article_count_node = root.add_element("ArticleCount")
		article_count_node.add_text(title.length.to_s)
		
		articles = root.add_element("Articles")
		
		for i in 0..title.length-1
			item_1_node = articles.add_element("item")
			title_node = item_1_node.add_element("Title")
			title_node.add_text(title[i])
			description_node = item_1_node.add_element("Description")
			description_node.add_text(description[i])
			pic_url_node = item_1_node.add_element("PicUrl")
			pic_url_node.add_text(pic_url[i])
			url_node = item_1_node.add_element("Url")
			url_node.add_text(url[i])
		end
		
		Rails.logger.info res_data.to_s
		res_data.to_s
	end
	
	
	
end
