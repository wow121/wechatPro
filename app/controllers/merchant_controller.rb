#encoding = utf-8
class MerchantController < ApplicationController
	def mkqrcode
	user=params[:userid]
	str=WeixinHelper.mkqrcode(user)
	render:json=>str
	end
	
	def login
	username=params[:username]
	pw=params[:password]
	password=Digest::MD5.hexdigest(pw)
	str={"fail"=>"username or password wrong"}
	m=Merchant.where("user_name"=>username,"password"=>password).first
	if(m==nil)
		{"fail"=>"username or password wrong"}
	else
		str={"userid"=>m.token,"success"=>200}
		end
	render:json=>str
	end
	
	def register
	username=params[:username]
	pw=params[:password]
	corpname=params[:corpname]
	locname=params[:locname]
	officename=params[:officename]
	password=Digest::MD5.hexdigest(pw)
	code=WeixinProcesser.mkrandom(12)
	str=nil
	m=Merchant.where("user_name"=>username).first
	if(m==nil)
		Merchant.create({:user_name=>username,:password=>password,:corp_name=>corpname,:loc_name=>locname,:office_name=>officename,:token=>code})
		str={"userid"=>code,"success"=>200}
	else
		str={"fail"=>"username is used"}
	end
	render:json=>str
	end
	
	def upload
	username=params[:userid]
	photo=params[:photo]
	code=params[:code]
	pic=params[:pic]
	i=Merchant.where("token"=>username).first
	Rails.logger.info 	params.to_s
	str={"fail"=>"error"}
	if i==nil 
		str={"fail"=>"user not found"}
	elsif photo==nil
		str={"fail"=>"photo error"}
	else
	photo_name=i.user_name+i.loc_name+Time.now.strftime("%Y%m%d")+"01"+WeixinProcesser.mkrandom(6).to_s+".jpg"
	photo_name_small=photo_name[0,photo_name.length-4]+"_small.jpg"
    File.open(IMG_PATH+photo_name,"wb+") do |f|
      f.write(photo.read)	
	  end
	system 'convert '+IMG_PATH+photo_name+' -resize 30% '+IMG_PATH+photo_name_small
	Photos.create({:merchant_id=>i.user_name,:file_path=>photo_name,:photo_id=>code,:upload_type=>"1"})
	str={"success"=>200,"url"=>SERVER_IMG+photo_name,"s_url"=>SERVER_IMG+photo_name_small}
	end
	render:json=>str
	end
	
	def photolist 	
	username=params[:userid]
	code=params[:code]
	pic=params[:pic]
	status=params[:status]
	m=Merchant.where("token"=>username).first
	str=nil
	if(m==nil)
		str={"fail"=>"user not found"}
	else
		photo=Photos.where("photo_id"=>code)
		if(photo.first==nil)
			str={"fail"=>"photo not found"}
			
		else
			str=[]
			for i in photo do
				if status==nil
					path=i.file_path[0,i.file_path.length-4]
					str<<{"success"=>200,
						"photo"=>SERVER_IMG+i.file_path,
						"code"=>i.photo_id,
						"s_photo"=>SERVER_IMG+path+"_small.jpg"}
				else
				   if i.upload_type==status
						path=i.file_path[0,i.file_path.length-4]
						str<<{"success"=>200,
						"photo"=>SERVER_IMG+i.file_path,
						"code"=>i.photo_id,
						"s_photo"=>SERVER_IMG+path+"_small.jpg"}
						end
					end
				end
		end
	end
	if str.length==0
		str={"fail"=>"photo not found"}
		end
	render:json=>str
	end
	
	def setstatus
	username=params[:userid]
	code=params[:code]
	status=params[:status]
	m=Merchant.where("token"=>username).first
	str=nil
	if(m==nil)
		str={"fail"=>"user not found"}
	else
		photo=Photos.where("photo_id"=>code)
		if(photo.first==nil)
			str={"fail"=>"photo not found"}
			
		else
			for i in photo do
				i.upload_type=status
				i.downloads=i.downloads+1
				i.save
				end
			str={"success"=>200}
			end
		end
	render:json=>str
	end
	
	def getlog
	username=params[:userid]
	status=params[:status]
	stime=params[:stime]
	etime=params[:etime]
	str=MerchantHelper.getlog(username,status,stime,etime)
	render:json=>str
	end
	
	def getmerchant
		username=params[:userid]
		m=Merchant.where("token"=>username).first
		str=nil
		if(m==nil)
			str={"fail"=>"user not found"}
		else
			str={"success"=>200,
				"user_name"=>m.user_name,
				"created_at"=>m.created_at,
				"corp_name"=>m.corp_name,
				"loc_name"=>m.loc_name,
				"office_name"=>m.office_name
				}
			end
		render:json=>str
	end
end
