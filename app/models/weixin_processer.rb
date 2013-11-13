#encoding: utf-8

class WeixinProcesser
  @@token = "molitown_test"
	@@appid = "wx4e8af5e356a9710e"
	@@appsecret = "c8ec825158fbc4d399b204044e47d086"
  
	@@register_intro = "Hi~小印恭候多时啦~您可以点击下面的菜单按钮玩玩，也可以试试这些自动回复哦↓↓
	1 - 了解微米印微信定制手机壳
	2 - 开始微信定制手机壳
	3 - 了解微米印个性定制服务
	4 - 领取电子代金券
	5 - 下载微米印手机App"

	@@coupon_message = "感谢您关注微米印！
	
初次关注微米印可以得到10元代金券，小印会尽快审核，给您发来您的代金券~
	"


	@@intro = "【微米印，个性尚品为爱定制】\r\n\r\n
生活忙碌紧张，如何记录不该忘却的瞬间？\r\n
工作千篇一律，如何彰显您的个性和品味？\r\n\r\n
微米印，中国第一个微信定制服务和首个手机照片个性化定制App\r\n
专注于让您在现代城市生活中，发现并享受生活之美，表现您内在与众不同的个性！
无论是个性洋溢的定制手机壳，高端大气的照片书，还是时尚洋气的快拍卡，微米印秉持\"优悦生活\"理念，坚持高品质产品，高品质快速服务，100%微笑承诺，免去您导出照片的繁琐，免去淘宝上良莠不齐的质量和低效的反复沟通，免去付款后漫长的等待。。。\r\n
【微米印主页】http://vimi.in
【苹果App下载链接】http://vimi.in/d/iphone_book
【安卓App下载链接】http://download.vida.fm/vimi_official_20131025.apk
【官方微博 @vimi微米印】http://weibo.com/weimiyin
【微笑客服电子邮箱】help@vimi.in
【用户交流QQ群】244058790 "


	@@chat = "今天天气不错！您想聊些什么呢？

	如果需要帮助，您还可以试试——
	回复【下载】：抢先下载微米印
	回复【介绍】：小印会为您介绍微米印
	回复【怎么玩】：小印会告诉您如何玩转微米印
	回复【领钱】：将获得10元现金券
	回复【帮助】：了解更多关于微米印
	回复【树洞】：把你说不出口的表白、吐槽告诉小印，就有机会通过微米印官微匿名发布哦~"


	 @@prelaunch = "手机壳制作正在测试中，敬请期待!"

   @@auto_response = {"介绍" => @@intro,
	                    "是什么" => @@intro,
	                    "聊天" => @@chat,
		                  "聊聊"=> @@chat,
		                  "聊一会儿"=> @@chat,
											"说说话"=> @@chat,
	                    "prelaunch" => @@prelaunch}

  def self.process_register(params)
    sign_string = params[:nonce] + params[:timestamp] + @@token
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

		if @@auto_response[content] != nil
		  res = self.construct_text_response(msg, @@auto_response[content])
	  else
		  if content == "我要"  
		     res = self.construct_text_response(msg, "发送一张照片开始手机壳制作!")
				 SessionHistory.set_test_flag(msg[:FromUserName])
	    elsif content == "Q" || content == "q" || content == "退出"
		     res = self.construct_text_response(msg, "您已经退出手机壳定制，感谢关注微米印!\r\n\r\n您可以点击下面的菜单按钮玩玩，了解更多关于微米印哦~")
			   SessionHistory.disable_phone_shell_state(msg[:FromUserName])
	    elsif content == "1"
		    return res = self.construct_image_response(msg, "微信定制手机壳，轻松与众不同",
						          "为什么选择《微米印》手机壳定制服务？",
											"http://weixin.vimi.in/assets/phone_shell_intro.png",
											"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MjM5Njc3NjYyMQ==&appmsgid=10000181&itemidx=1&sign=da359435e4f8790f628958f3202d7f21#wechat_redirect") 
			elsif content == "2"
			  SessionHistory.enable_phone_shell_state(msg[:FromUserName])
		    res = self.construct_text_response(msg, "请发送一张照片，开始手机壳定制!\r\n小贴士: 亲，要发竖版照片哦~")
			elsif content == "3"
		    return res = self.construct_text_response(msg, @@auto_response["介绍"])
			elsif content == "4"
		    res = self.construct_text_response(msg, @@coupon_message)
			elsif content == "5"
		    res = self.construct_text_response(msg, "【苹果手机下载链接】\r\nhttp://vimi.in/d/iphone_book
						                           \r\n\r\n【安卓手机下载链接】\r\nhttp://download.vida.fm/vimi_official_20131025.apk")
			elsif content == "与众不同"
		    res = self.construct_text_response(msg, "感谢您对微米印的支持！小印会尽快审核好您的截屛，给您发来代金券~")
			elsif content == "1111" || content == "驴妈妈" || content == "电影票"
			  cur_time = Time.now()
	      if cur_time > Time.parse("2013-11-11 23:59:59")
		      res = self.construct_text_response(msg, "感谢您参加双11活动，您已成功报名抢奖品，小印会尽快审核您的截屏，给您发来等额代金券，并通知您是否获得驴妈妈代金券和电影票~")
				else
		      res = self.construct_text_response(msg, "感谢您参加双十一脱\"光\"活动，领奖需11月12日当天留言才有效哦!")
				end
			elsif content == "iphone" || content == "iPhone" || content == "吃货" || content == "辣妈" || content == "苹果"
			  coupon = API.create_a_coupon(58)
	      if coupon != nil
		      res = self.construct_text_response(msg, "感谢关注微米印！这是您的10元代金券：#{coupon["code"]} \r\n\r\n您可以点击下方菜单“定制手机壳”—“开始微信定制”，下单时使用代金券立减10元现金哦！
							") if coupon != nil
				else
		      res = "error"
				end
			else
# res = self.construct_text_response(msg, "小印不太明白，您可以试试以下自动回复：
#	1 - 了解微米印个性定制手机壳
#	2 - 开始手机壳订制
#	3 - 了解关于微米印
#	4 - 领取代金券
#	5 - 下载微米印
#	微笑客服小印的工作时间是工作日10:00~19:00
#	您可以直接留言，小印会一一回复您的疑问！\r\n
#	周末了，小印回家陪爸妈了，您周末发的消息会在星期一统一回复~很抱歉让您久等了！")

		    res = self.construct_text_response(msg, "小印不太明白，您可以试试以下自动回复：
	1 - 了解微米印个性定制手机壳
	2 - 开始手机壳订制
	3 - 了解关于微米印
	4 - 领取代金券
	5 - 下载微米印
	微笑客服小印的工作时间是工作日10:00~19:00
	您可以直接留言，小印会一一回复您的疑问!")
			end
	  end

		return res
	end

	def self.process_image(msg)
	  if SessionHistory.check_test_flag(msg[:FromUserName]) || SessionHistory.check_phone_shell_state(msg[:FromUserName])
	    res = self.construct_image_response(msg, "点击开始您的手机壳定制", "点击图片开始手机壳定制\r\n\r\n回复\"q\"或\“退出\”，退出手机壳定制", msg[:PicUrl],"http://weixin.vimi.in/phone_shells/nav.html?user_name=#{msg[:FromUserName]}&pic_url=#{msg[:PicUrl]}")
		else
		  res = "error"
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
		res = self.construct_text_response(msg, @@register_intro)
	  return res
	end
	
	def self.process_unsubscribe(msg)
	  Rails.logger.info "==========process_unsubscribe======="
	end

	def self.process_click(msg)
	  Rails.logger.info "==========click==============="
		case msg[:EventKey]
		  when "phone_shell"
			  SessionHistory.enable_phone_shell_state(msg[:FromUserName])
		    return res = self.construct_text_response(msg, "请发送一张照片，开始手机壳定制!\r\n小贴士1: 亲，要发竖版照片哦~\r\n小贴士2：传图时选择【原图】，会让手机壳效果好很多！")
		  when "phone_shell_intro"
		    return res = self.construct_image_response(msg, "微信定制手机壳，轻松与众不同",
						          "为什么选择《微米印》手机壳定制服务？",
											"http://vimi.in/static/phone_shell_intro.jpeg",
											"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MjM5Njc3NjYyMQ==&appmsgid=10000181&itemidx=1&sign=da359435e4f8790f628958f3202d7f21#wechat_redirect") 
		  when "introduction"
		    return res = self.construct_text_response(msg, @@auto_response["介绍"])
		  when "query"
        return res = self.construct_image_response(msg, "点击查看历史订单", "这里可以看到您的所有手机壳历史订单哦!", "http://vimi.in/static/find_order.jpg", "http://weixin.vimi.in/phone_shells/query_my_order.html?user_name=#{msg[:FromUserName]}") 
        #  return res = self.construct_text_response(msg, @@auto_response["prelaunch"])
		  when "coupon"
		    return res = self.construct_text_response(msg, @@coupon_message)
		  when "download"
		    return res = self.construct_text_response(msg, "手机客户端可直接定制个性化精美照片书、快拍卡。
点击以下链接，立即开始个性化定制之旅：\r\n
【苹果App下载链接】\r\nhttp://vimi.in/d/iphone_book
\r\n\r\n【安卓App下载链接】\r\nhttp://download.vida.fm/vimi_official_20131025.apk")
		  when "service"
#return res = self.construct_text_response(msg, "微笑客服小印的工作时间是工作日10:00~19:00
#您可以直接留言，小印会一一回复您的疑问！\r\n\r\n 周末了，小印回家陪爸妈了，您周末发的消息会在星期一统一回复~很抱歉让您久等了！")

		    return res = self.construct_text_response(msg, "微笑客服小印的工作时间是工作日10:00~19:00
您可以直接留言，小印会一一回复您的疑问！")

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
										  {\"name\" : \"定制手机壳\",
											 \"sub_button\" : [
											 {\"type\" : \"click\",
												\"name\" : \"手机壳介绍\",
												\"key\"  : \"phone_shell_intro\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"开始微信定制\",
												\"key\"  : \"phone_shell\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"查询订单\",
												\"key\"  : \"query\"
											 }]
											},
										  {\"name\" : \"微米印\",
											 \"sub_button\" : [
											 {\"type\" : \"click\",
												\"name\" : \"关于微米印\",
												\"key\"  : \"introduction\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"领取代金券\",
												\"key\"  : \"coupon\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"下载手机App\",
												\"key\"  : \"download\"
											 },
											 {\"type\" : \"click\",
												\"name\" : \"微笑客服\",
												\"key\"  : \"service\"
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

	end
