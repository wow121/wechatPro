#encoding: utf-8
class WinController < ApplicationController
	def add_product
                 name=params[:name]
         	     sku=params[:sku]
                 sname=params[:sname]
                 description=params[:description]
                 pic=params[:file]
				 product=Product.where("sku"=>sku).first
				 if product==nil
					 pic_name=sku
					 path="/home/xianrui/pic/"+pic_name+".jpg"
					 File.open(path,"wb+") do |f|
							 f.write(pic.read)	
					 end
					 msg=Product.new
					 msg.name=name
					 msg.sku=sku
					 msg.sname=sname
					 msg.description=description
					 msg.pic=pic_name+".jpg"
					 msg.save
					 str={"status"=>200}
				  else
					str={"status"=>100,"error"=>"sku已使用，请核对后输入"}
				end
                
                render:json=>str
        end
	
	def get_product
                msg=Product.all
                content=[]
                for i in msg do
                        str={"id"=>i.id,"name"=>i.name,"sku"=>i.sku,"sname"=>i.sname,"description"=>i.description,"pic"=>i.pic}
                        content<<str
                end
                render:json=>content
        end

	def remove_product
                id=params[:id].to_i
                Product.delete(id)
                str={"status"=>200}
                render:json=>str
        end

	 def upload_product
                id=params[:id].to_i
                name=params[:name]
                description=params[:description]
				sku=params[:sku]
				product=Product.where("sku"=>sku).first
				pro=Product.where("id"=>id).first
				if product==nil or pro.sku==sku
					msg=Product.find(id)
					msg.name=name
					msg.description=description
					msg.sku=sku
					pic=params[:file]
					pic_name=sku
					path="/home/xianrui/pic/"+pic_name+".jpg"
					File.open(path,"wb+") do |f|
						f.write(pic.read)	
						end
					msg.pic=pic_name+".jpg"
					msg.save
					str={"status"=>200}
				else
					str={"status"=>100,"error"=>"sku已使用，请核对后输入"}
				end
                render:json=>str
        end
	
	def update_user_list
		access_token=WeixinProcesser.get_access_token
		res = RestClient.get "https://api.weixin.qq.com/cgi-bin/user/get?access_token="+access_token
		res = JSON.parse res
		for user in res["data"]["openid"] do
			i=User.where("openid"=>user).first
			inf = RestClient.get "https://api.weixin.qq.com/cgi-bin/user/info?access_token="+access_token+"&openid="+user
			inf = JSON.parse inf
			if i==nil				
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
			else
				i.subscribe=inf["subscribe"].to_s
				i.openid=inf["openid"]
				i.nickname=inf["nickname"]
				i.sex=inf["sex"].to_s
				i.language=inf["language"]
				i.city=inf["city"]
				i.province=inf["province"]
				i.country=inf["country"]
				i.headimgurl=inf["headimgurl"]
				i.subscribe_time=inf["subscribe_time"].to_s
				i.save
			end
		end
		user=User.all
		content=[]
        for i in user do
            str={"subscribe"=>i.subscribe,"openid"=>i.openid,"nickname"=>i.nickname,"sex"=>i.sex,"language"=>i.language,"city"=>i.city,"province"=>i.province,"country"=>i.country,"headimgurl"=>i.headimgurl,"subscribe_time"=>i.subscribe_time}
            content<<str
        end               
				render:json=>content
	end

	def get_user_list
		 user=User.all
                content=[]
        for i in user do
            str={"subscribe"=>i.subscribe,"openid"=>i.openid,"nickname"=>i.nickname,"sex"=>i.sex,"language"=>i.language,"city"=>i.city,"province"=>i.province,"country"=>i.country,"headimgurl"=>i.headimgurl,"subscribe_time"=>i.subscribe_time}
            content<<str
	 end
                render:json=>content	
	end

	
 
	def set_button_message
		json=params[:json]
		msg=Message.where("key"=>"button_message").first
		if(msg==nil)
				Message.create(:key=>"button_message",:value=>json)
		else
			msg.value=json
			msg.save
		end
		str={"status"=>200}
		render:json=>str
	end
	
	def set_voice_message
		json=params[:json]
		voice=params[:voice_key]
		msg=Message.where("key"=>voice.to_s).first
		if(msg==nil)
				Message.create(:key=>voice.to_s,:value=>json)
		else
			msg.value=json
			msg.save
		end
		str={"status"=>200}
		render:json=>str
	end
	
	def get_access_token
		access_token=WeixinProcesser.get_access_token
		render:json=>{"access_token"=>access_token}
	end
	
	def manage_image
    		sku=params[:sku]
		open_id=params[:open_id]
		product=Product.where("sku"=>sku).first
		@name=product.name
		@description=product.description
		@pic = product.pic 
		UserActivityLog.create({:open_id=>open_id,:event=>"product",:content=>sku})
	end
	
	def index
		@string=params[:string]
		@email=params[:email]
		@userid=params[:userid]
	end

	
	def send_mail
		email=params[:email]
		userid=params[:userid]
		user=User.where("openid"=>userid).first
		user.code=WeixinProcesser.mkrandom(6)
		user.save
		UserMailer.send_mail("绑定邮箱验证码",email,"您的验证码为:"+user.code).deliver
#		render(:action=>"index",:string=>"已发送") 
		redirect_to :action => "index", :string=>"已发送",:email=>email,:userid=>userid	
	end

	def verify_mail
		code=params[:code]
		userid=params[:userid]
		email=[:email]
		user=User.where("openid"=>userid).first
		if code == user.code
		user.email=email
		user.save
		redirect_to :action => "success"
		else



		end	


	end

	def success
		


	end

		
end
