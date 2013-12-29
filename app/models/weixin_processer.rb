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
				if	(Time.now.to_i-i.created_at.to_i > 60*30)
					return res = self.construct_text_response(msg, "您输入的授权码已过期!")
				else
				m=Merchant.where("user_name"=>i.merchant_id).first
				photo=Photos.where("user_id"=>msg[:FromUserName],"merchant_id"=>nil)
				for img in photo do
					photo_name=m.user_name+m.loc_name+Time.at(time).strftime("%Y%m%d")+"01"+mkrandom(6).to_s+".jpg"
					photo_name_small=photo_name[0,photo_name.length-4]+"_small.jpg"
					img.file_path=photo_name
					img.merchant_id=m.user_name
					img.photo_id=content
					img.upload_type="1"
					img.save
					WeixinHelper.download_pic(img.weixin_image_path,IMG_PATH+img.file_path,IMG_PATH+photo_name_small)
					end
				user.status="normal"
				user.photo_count=0
				user.save	
				return res = self.construct_text_response(msg, "所有照片上传成功!")
				end
			end
		end
		return	res = self.construct_text_response(msg, "授权码错误\n请重新输入")
	elsif user.status=="query_picture_all"
		photo=Photos.where("user_id"=>msg[:FromUserName])
		str={}
		for i in photo do
			str.update({i.photo_id=>i.created_at})
		end
		if content=="q" || content == "Q"
			user.status="normal"
			user.save
			return	res = self.construct_text_response(msg, "您已退出全部图片查询模式")
		elsif(content.to_i>=1 and content.to_i<=str.length)
			photolist=Photos.where("photo_id"=>str.keys[content.to_i-1])
			content_str=""
			mp=MerchantProject.where("code"=>i.photo_id).last
				if(mp==nil)
					title="微信上传"
				else
					title=mp.project_name
				end
			  index = 1
			  for i in photolist do
				
				string=""+photolist[index-1].title.to_s
				 if(string.length==0)
					str="未命名"
					string+=str
			     end
				content_str += index.to_s + "。"+string+"\n"
				index+=1
			  end
			  user=User.where("weixin_id"=>msg[:FromUserName]).first
			  user.status="query_picture_last"
			  user.context=photolist.last.photo_id
			  user.save
			  return res = self.construct_text_response(msg, "您所查询的‘"+title+"’一共"+photolist.length.to_s+"页:\n回复相应的页码进行查看\n回复“序号1 空格 序号2”可查看连续页面。（最多连续显示5页）\n回复 Q 退出查询模式\n"+content_str)
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
	elsif   user.status=="query_picture_code"	
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
			 mp=MerchantProject.where("code"=>photo.first.photo_id).last
				if(mp==nil)
					title="微信上传"
				else
					title=mp.project_name
				end
			 for i in photo do
			    
				string=""+photo[index-1].title.to_s
				 if(string.length==0)
					str="未命名"
					string+=str
			     end
				content_str += index.to_s + "。"+string+"\n"
				index+=1
				if i.user_id==nil
					i.user_id=user.weixin_id
					i.save
				end
			 end
			 
			user.status="query_picture_last"
			user.context=content
			user.save
			return res = self.construct_text_response(msg, "您所查询的‘"+title+"’一共"+photo.length.to_s+"页:\n回复相应的页码进行查看\n回复“序号1 空格 序号2”可查看连续页面。（最多连续显示5页）\n回复 Q 退出查询模式\n"+content_str)
		end
	
	elsif	user.status=="query_picture_last"
		photo=Photos.where("photo_id"=>user.context)
		if content=="q" || content == "Q"
			user.status="normal"
			user.save
			return	res = self.construct_text_response(msg, "您已退出图片查询模式")
		elsif(content.split.length==1)
			if(content.to_i>=1 and content.to_i<=photo.length)
			path=photo[content.to_i-1].file_path[0,photo[content.to_i-1].file_path.length-4]
			mp=MerchantProject.where("code"=>photo[content.to_i-1].photo_id).last
				if(mp==nil)
					string="微信上传"
				else
					string=mp.project_name
				end
			string+=photo[content.to_i-1].title.to_s
			return res = self.construct_image_response(msg, "第"+content+"张照片",
						         string,
											SERVER_IMG+path+"_small.jpg",
											SERVER_IP+"/admin/manage_image?file_path="+photo[content.to_i-1].file_path
											)
			else
				return	res = self.construct_text_response(msg, "序号输入错误,请重新输入")
			end
		elsif(content.split.length==2)
			num1=content.split[0].to_i
			num2=content.split[1].to_i
			if(num1>=num2 or num2>photo.length)
				return	res = self.construct_text_response(msg, "序号范围错误,请重新输入")
			elsif(num2-num1>4)
				return	res = self.construct_text_response(msg, "范围过大,最多只能同时显示5张图片,请重新输入")
			else
				title=[]
				description=[]
				pic_url=[]
				url=[]
				for num1 in num1..num2
					if(photo[num1-1].title==nil)
						title<<"微信上传"
					else
						title<<photo[num1-1].title.to_s
					end
					pic_url<<SERVER_IMG+photo[num1-1].file_path[0,photo[num1-1].file_path.length-4]+"_small.jpg"
					url<<SERVER_IP+"/admin/manage_image?file_path="+photo[num1-1].file_path
				end
				Rails.logger.info title.to_s
				return res=self.construct_images_response(msg, title, description, pic_url, url)
			end
		else
			return	res = self.construct_text_response(msg, "序号格式错误,请重新输入")
		end
	elsif   user.status=="query_picture_id"	
		if content == "Q" || content == "q"	
			user.status="normal"
			user.save
			return res = self.construct_text_response(msg,"您已退出授权码查询模式！")
		end
		content=content+".jpg"
		photo=Photos.where("file_path"=>content).first
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
		if @@auto_response[content] != nil
		  res = self.construct_text_response(msg, @@auto_response[content])
		else    
			if content == "1"
	#				return res = self.construct_text_response(msg, "1待编辑")
					titles=["111111","222222222","3333333"]
					des=["描述1","描述2","描述3"]
					picurl=[SERVER_IMG+"hlg1hlg012013122301ZneczY.jpg",SERVER_IMG+"hlg1hlg012013122301DybC2t.jpg",SERVER_IMG+"hlg1hlg012013122301YTkUiU.jpg"]
					url=[]
					return res= self.construct_images_response(msg,titles,des,picurl,url)
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
		    return res = self.construct_text_response(msg, "请发送一张照片 \n （小提示：\n如果需要精美的高分辨率照片，请发送原图哦~）")
			
		  when "key_b1"
			 error_checking(msg[:FromUserName])
			 photo=Photos.where("user_id"=>msg[:FromUserName])
			 if(photo.first==nil)
				return res=self.construct_text_response(msg,"您没有可供查询的图片")
			else
			str={}
			 for i in photo do
			 str.update({i.photo_id=>i.created_at})
			 end
			 content=""
			 index = 1
			 for i in str.keys do
				mp=MerchantProject.where("code"=>i).last
				if(mp==nil)
					string="微信上传"
				else
					string=mp.project_name
				end
				
			 #   str1=i+" "+str.values[index-1].strftime("%m-%d %H:%M").to_s
				content += index.to_s + "。"+string+"\n"
				index+=1
			 end
			 user=User.where("weixin_id"=>msg[:FromUserName]).first
			 user.status="query_picture_all"
			 user.save
			 return res = self.construct_text_response(msg, "共查找到"+str.length.to_s+"个项目:\n回复响应的序号进入项目\n回复 Q 退出查询模式\n"+content)
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
			  mp=MerchantProject.where("code"=>img.first.photo_id).last
				if(mp==nil)
					title="微信上传"
				else
					title=mp.project_name
				end
			  for i in img do
				
				 string=""+img[index-1].title.to_s
				 if(string.length==0)
					str="未命名"
					string+=str
			     end
				content_str += index.to_s + "。"+string+"\n"
				index+=1
			  end
			  user=User.where("weixin_id"=>msg[:FromUserName]).first
			  user.status="query_picture_last"
			  user.context=photo.photo_id
			  user.save
			  
			  return res = self.construct_text_response(msg, "您所查询的‘"+title+"’ 一共"+img.length.to_s+"页:\n回复相应的页码进行查看\n回复“序号1 空格 序号2”可查看连续页面。（最多连续显示5页）\n回复 Q 退出查询模式\n"+content_str)
			end		
		when "key_b3"
			  error_checking(msg[:FromUserName])
			  user=User.where("weixin_id"=>msg[:FromUserName]).first
			  user.status="query_picture_code"
			  user.save
			  return res=self.construct_text_response(msg,"请输入照片的授权码，回复Q退出查询模式")
		when "key_b4"
			  error_checking(msg[:FromUserName])
			  user=User.where("weixin_id"=>msg[:FromUserName]).first
			  user.status="query_picture_id"
			  user.save
			  return res=self.construct_text_response(msg,"请输入照片的编码，回复Q退出查询模式")
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
												\"name\" : \"注册项目查询\",
												\"key\"  : \"key_b1\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"最后项目查询\",
												\"key\"  : \"key_b2\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"项目授权码输入\",
												\"key\"  : \"key_b3\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"照片下载\",
												\"key\"  : \"key_b4\"
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
