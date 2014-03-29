#encoding: utf-8

class WeixinProcesser
	
	def self.process_register(params)
     a = []
    a << params[:nonce]
     a << params[:timestamp]
     a << "weixin_test"
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
<<<<<<< HEAD
	elsif   user.status=="query_picture_id"	
		if content == "Q" || content == "q"	
			user.status="normal"
			user.save
			return res = self.construct_text_response(msg,"您已退出授权码查询模式！")
		end
		#content=content+".jpg"
		photo=Photos.where("photo_id"=>content).first
		if photo==nil
			return res = self.construct_text_response(msg,"没有找到照片！\n请确定照片编码输入正确\n请重新输入\n回复Q可退出查询模式")
		else
			path=photo.file_path[0,photo.file_path.length-4]
			mp=MerchantProject.where("code"=>photo.photo_id).last
				if(mp==nil)
					string="微信上传"
				else
					string=mp.project_name
				end
			string+=photo.title.to_s
			return res = self.construct_image_response(msg,"照片编码为"+content[0,content.length-4],
														string,
														SERVER_IMG+path+"_small.jpg",
														SERVER_IP+"/admin/manage_image?file_path="+photo.file_path)
			end
	
	else
		message=Message.where("key"=>content).first
		if message==nil
			message=Message.where("key"=>"默认回复").first
			return res = self.construct_text_response(msg,message.value.to_s)
		else
			return res = self.construct_text_response(msg,message.value.to_s)
=======
	end

	def self.process_text(msg)
		product=Product.where("sku"=>msg[:Content]).first
		if(product==nil)
			return res=self.construct_text_response(msg,"没有找到sku")
		else

>>>>>>> e8a78ed63dfcec5335a2e33593aa1800ebef3dda
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
<<<<<<< HEAD
		message=Message.where("key"=>"关注回复").first
		res = self.construct_text_response(msg,message.value.to_s)
=======
		

		res = self.construct_text_response(msg,"感谢您关注我们！")
>>>>>>> e8a78ed63dfcec5335a2e33593aa1800ebef3dda
		
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
		  when "key_c1"
			return res=self.construct_image_response(msg,"绑定邮箱","点击进入绑定邮箱",nil,"http://203.156.196.150/win/index?userid="+msg[:FromUserName])
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
	  Rails.logger.info res_data.to_s
	  res_data.to_s

	end

	def self.get_access_token
	appid="wxc4b66bd289110ae8"
 	appsecret="a22967215b6bbc1111b2afb5d69365ec"
    res = RestClient.get "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid="+appid+"&secret="+appsecret
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
                                         \"name\" : \"预留\",
                                         \"key\"  : \"key_b1\"
                                          },
                                          {\"type\" : \"click\",
                                             \"name\" : \"预留\",
                                             \"key\"  : \"key_b2\"
                                          },
                                          {\"type\" : \"click\",
                                          \"name\" : \"预留\",
                                           \"key\"  : \"key_b3\"
                                          },
                                        {\"type\" : \"click\",
                                         \"name\" : \"预留\",
                                          \"key\"  : \"key_b4\"
                                          },
                                        {\"type\" : \"click\",
                                          \"name\" : \"预留\",
                                          \"key\"  : \"key_b5\"
                                           }
                                          ]
                                        },
										  {\"name\" : \"预留\",
											 \"sub_button\" : [
											 {\"type\" : \"click\",
												\"name\" : \"绑定邮箱\",
												\"key\"  : \"key_c1\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"获取商品信息\",
												\"key\"  : \"key_c2\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"预留3\",
												\"key\"  : \"key_c3\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"预留4\",
												\"key\"  : \"key_c4\"
											 }
											 }
                      ] 
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
