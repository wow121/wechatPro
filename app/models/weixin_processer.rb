#encoding: utf-8

class WeixinProcesser
  @@token = "weixin_test"
	@@appid = "wxae61f378f1c0978f"
	@@appsecret = "d1381a12da5871b7099e3a5a7847db15"

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
		case(msg[:MsgType])
		  when "text"
        return self.process_text(msg) 
			when "image"
        return self.process_image(msg)
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

	def self.process_text(msg)
		content = msg[:Content]
		content.strip!
		user=User.where("weixin_id"=>msg[:FromUserName]).first
		time=msg[:CreateTime].to_i
	if user.status=="update_succees_and_input_code"
		if content == "Q" || content == "q"
			user.status="normal"
			user.save
			return res = self.construct_text_response(msg,"您已退出照片上传模式！")
			end
		merchant=MerchantCode.all
		for i in merchant do
			if  i.code==content
				m=Merchant.where("user_name"=>i.merchant_id).first
				photo=Photos.where("user_id"=>msg[:FromUserName],"merchant_id"=>nil)
				for img in photo do
					photo_name=m.user_name+m.loc_name+Time.at(time).strftime("%Y%m%d")+"01"+mkrandom(6).to_s+".jpg"
					img.file_path=photo_name
					img.merchant_id=m.user_name
					img.photo_id=content
					img.save
					WeixinHelper.download_pic(img.weixin_image_path,"/home/weixin/user_photos/"+img.file_path)
					end
				user.status="normal"
				user.photo_count=0
				user.save	
				return res = self.construct_text_response(msg, "所有照片上传成功!",
											)
				end
		end
		return	res = self.construct_text_response(msg, "授权码错误\n请重新输入")
	elsif user.status=="query_picture_all"
		photo=Photos.where("user_id"=>msg[:FromUserName])
		if content=="q" || content == "Q"
			user.status="normal"
			user.save
			return	res = self.construct_text_response(msg, "您已退出全部图片查询模式")
		elsif(content.to_i>=1 and content.to_i<=photo.length)
		return res = self.construct_image_response(msg, "第"+content+"张照片",
						         "商户code为"+photo[content.to_i-1].merchant_id+"\n照片的唯一识别码为\n"+photo[content.to_i-1].file_path[0,photo[content.to_i-1].file_path.length-4],
											photo[content.to_i-1].weixin_image_path,
											"http://115.29.36.94:999/"+photo[content.to_i-1].file_path
											)
		else
			return	res = self.construct_text_response(msg, "序号输入错误,请重新输入")
		end
	elsif	user.status=="update_photo" 
		
		if content == "Q" || content == "q"
			user.status="normal"
			user.save
			return res = self.construct_text_response(msg,"您已退出照片上传模式！")
			end
		return res = self.construct_text_response(msg,"您现在处于照片上传模式噢！ \n 如果想要退出照片上传模式请回复 Q ")
	elsif   user.status=="query_picture_id"	
		if content == "Q" || content == "q"	
			user.status="normal"
			user.save
			return res = self.construct_text_response(msg,"您已退出授权码查询模式！")
			end
		photo=Photos.where("photo_id"=>content)
		if photo.first==nil
			return res = self.construct_text_response(msg,"没有找到授权码！\n请确定授权码输入正确\n请重新输入\n回复Q可退出查询模式")
		else 
			 content_str=""
			 index = 1
			 for i in photo do
			    str=photo[index-1].updated_at.to_s
				content_str += index.to_s + "。"+str[0,str.length-3]+"\n"
				index+=1
				if i.user_id==nil
					i.user_id=user.weixin_id
					i.save
				end
			 end
			 
			user.status="query_picture_id_show"
			user.context=content
			user.save
			return res = self.construct_text_response(msg, "您的的图片共"+photo.length.to_s+"张:\n回复响应的序号查看图片\n回复 Q 退出查询模式\n"+content_str)
		end
	elsif	user.status=="query_picture_id_show"
		photo=Photos.where("photo_id"=>user.context)
		if content=="q" || content == "Q"
			user.status="normal"
			user.save
			return	res = self.construct_text_response(msg, "您已退出图片查询模式")
		elsif(content.to_i>=1 and content.to_i<=photo.length)
		return res = self.construct_image_response(msg, "第"+content+"张照片",
						         "商户code为"+photo[content.to_i-1].merchant_id+"\n照片的唯一识别码为\n"+photo[content.to_i-1].file_path[0,photo[content.to_i-1].file_path.length-4],
											photo[content.to_i-1].weixin_image_path,
											"http://115.29.36.94:999/"+photo[content.to_i-1].file_path
											)
		else
			return	res = self.construct_text_response(msg, "序号输入错误,请重新输入")
		end
	elsif	user.status=="query_picture_last"
		photo=Photos.where("photo_id"=>user.context)
		if content=="q" || content == "Q"
			user.status="normal"
			user.save
			return	res = self.construct_text_response(msg, "您已退出图片查询模式")
		elsif(content.to_i>=1 and content.to_i<=photo.length)
		return res = self.construct_image_response(msg, "第"+content+"张照片",
						         "商户code为"+photo[content.to_i-1].merchant_id+"\n照片的唯一识别码为\n"+photo[content.to_i-1].file_path[0,photo[content.to_i-1].file_path.length-4],
											photo[content.to_i-1].weixin_image_path,
											"http://115.29.36.94:999/"+photo[content.to_i-1].file_path
											)
		else
			return	res = self.construct_text_response(msg, "序号输入错误,请重新输入")
		end
	
	else
		if @@auto_response[content] != nil
		  res = self.construct_text_response(msg, @@auto_response[content])
		else    
			if content == "1"
					return res = self.construct_text_response(msg, "1待编辑") 
			elsif content == "2"
					return res = self.construct_text_response(msg, "2待编辑") 
			elsif content == "3"
					return res = self.construct_text_response(msg, "3待编辑") 
			elsif content == "4"
					return res = self.construct_text_response(msg, "4待编辑") 
			elsif content == "5"
					return res = self.construct_text_response(msg, "5待编辑")
			else
					return res = self.construct_text_response(msg, "您在说神马？？？？
如果您想要上传照片，请点击菜单的上传按钮
如果您想要查看您的照片，请点击菜单上的查询按钮
如果需要帮助，您还可以试试——
回复【1】：待编辑
回复【2】：待编辑
回复【3】：待编辑
回复【4】：待编辑
回复【5】：待编辑
回复【6】：待编辑") 
			end
		end
	end
		return res
	end

	def self.process_image(msg)
		
	    
		weixin_url=msg[:PicUrl]
		username=msg[:FromUserName]
		
		user=User.where("weixin_id"=>username).first
		
		if user.status == "update_photo"
			Photos.create({:user_id=>username,:weixin_image_path=>weixin_url,:upload_type=>"wait_download"})
			user.photo_count=1
			user.status="update_succees_and_input_code"
			user.save
			res = self.construct_text_response(msg, "图片已上传\n您已上传1张照片\n可继续上传或输入授权码")
		elsif  user.status == "update_succees_and_input_code"
			Photos.create({:user_id=>username,:weixin_image_path=>weixin_url,:upload_type=>"wait_download"})
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
		
		username=msg[:FromUserName]
		time=msg[:CreateTime]
		if User.where("weixin_id"=>username).first== nil
			User.create(:weixin_id=>username)
			
		end

		res = self.construct_text_response(msg, "感谢您关注我们！ 回复介绍可查看目录~~")
		
	  return res
	end
	
	def self.process_unsubscribe(msg)
	  Rails.logger.info "==========process_unsubscribe======="
	end

	def self.process_click(msg)
	  Rails.logger.info "==========click==============="
		user=User.where("weixin_id"=>msg[:FromUserName]).first
		case msg[:EventKey]
		  when "key_a1"
			  
			  user.status="update_photo"
			  user.save
		    return res = self.construct_text_response(msg, "请发送一张照片 \n （小提示：\n用微信发送照片时最好发送原图噢！）")
			
		  when "key_b1"
			 error_checking(msg[:FromUserName])
			 photo=Photos.where("user_id"=>msg[:FromUserName])
			 if(photo.first==nil)
				return res=self.construct_text_response(msg,"您没有可供查询的图片")
			else
			 content=""
			 index = 1
			 for i in photo do
			    str=photo[index-1].updated_at.to_s
				content += index.to_s + "。"+str[0,str.length-3]+"\n"
				index+=1
			 end
			 user=User.where("weixin_id"=>msg[:FromUserName]).first
			 user.status="query_picture_all"
			 user.save
			 return res = self.construct_text_response(msg, "您的的图片共"+photo.length.to_s+"张:\n回复响应的序号查看图片\n回复 Q 退出查询模式\n"+content)
			end
		  
		  when "key_b2"
			  error_checking(msg[:FromUserName])
			  photo=Photos.where("user_id"=>msg[:FromUserName]).last
			  
			  if photo==nil
				return res=self.construct_text_response(msg,"您没有可供查询的图片")
			  else
			  img=Photos.where("photo_id"=>photo.photo_id)
			  content_str=""
			  index = 1
			  for i in img do
			    str=img[index-1].updated_at.to_s
				content_str += index.to_s + "。"+str[0,str.length-3]+"\n"
				index+=1
			  end
			  user=User.where("weixin_id"=>msg[:FromUserName]).first
			  user.status="query_picture_last"
			  user.context=photo.photo_id
			  user.save
			  return res = self.construct_text_response(msg, "您的的图片共"+img.length.to_s+"张:\n回复响应的序号查看图片\n回复 Q 退出查询模式\n"+content_str)
			end
			
		when "key_b3"
			  error_checking(msg[:FromUserName])
			  user=User.where("weixin_id"=>msg[:FromUserName]).first
			  user.status="query_picture_id"
			  user.save
			  return res=self.construct_text_response(msg,"请输入照片的授权码，回复Q退出查询模式")
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
    res = RestClient.get "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{@@appid}&secret=#{@@appsecret}"
    access_token = JSON.parse(res)["access_token"]
	end

	def self.create_menu
     menus = {"button" => [
			             {"type" => "click",
										"name" => "PhoneShell",
									  "key" => "phone_shell"
									 },
									 {"type" => "view",
										"name" => "Activity",
										"url" => "http://vimi.in"},
			             {"type" => "click",
										"name" => "More",
									  "key" => "more"}
									 ]
							}

     string_menu = "{\"button\" : [
										  {\"name\" : \"上传\",
											 \"sub_button\" : [
											 {\"type\" : \"click\",
												\"name\" : \"上传照片\",
												\"key\"  : \"key_a1\"
											 }
											 ]
											},
										  {\"name\" : \"查询\",
											 \"sub_button\" : [
											 {\"type\" : \"click\",
												\"name\" : \"全部照片\",
												\"key\"  : \"key_b1\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"最后上传照片\",
												\"key\"  : \"key_b2\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"输入授权码查询\",
												\"key\"  : \"key_b3\"
											 }
											 }]
                      }] 
									}"


=begin
     string_menu = "{\"button\" : [
		                  {\"type\" : \"click\",
											 \"name\" : \"个性定制手机壳\",
											 \"key\"  : \"phone_shell\"
											},
										  {\"name\" : \"更多\",
											 \"sub_button\" : [
											 {\"type\" : \"click\",
												\"name\" : \"介绍\",
												\"key\"  : \"introduction\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"查询订单\",
												\"key\"  : \"query\"
											 }]
											},
										  {\"name\" : \"客服\",
											 \"sub_button\" : [
											 {\"type\" : \"click\",
												\"name\" : \"介绍\",
												\"key\"  : \"introduction\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"查询订单\",
												\"key\"  : \"query\"
											 }]
                      }] 
									}"
=end
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
end