class MerchantController < ApplicationController
	def mkqrcode
	user=params[:userid]
	m=Merchant.where("token"=>user).first
	str=nil
	if(m==nil)
		str={"fail"=>"user not found"}
	else
		time=Time.now.to_i.to_s
		name = "/home/weixin/merchant_qrcode/" + m.user_name+time + ".jpg"
		code=WeixinProcesser.mkrandom(10)
		File.open("/home/weixin/merchant_qrcode/context","w") do |file|
			file.puts  code
			file.puts  name
			end
		status=`java -classpath /home/weixin/myjava QRCodeEncoderHandler`
		MerchantCode.create(:merchant_id=>m.user_name,:code=>code)
		str={"success"=>200,
				"code"=>code,
				"url"=>"http://115.29.36.94:888/"+m.user_name+time+".jpg"}
		end
	render:json=>str
	end
	
	def login
	username=params[:username]
	password=params[:password]
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
	password=params[:password]
	corpname=params[:corpname]
	locname=params[:locname]
	officename=params[:officename]
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
    File.open("/home/weixin/user_photos/"+photo_name,"wb+") do |f|
      f.write(photo.read)
	  end
	
	Photos.create({:merchant_id=>i.user_name,:file_path=>photo_name,:photo_id=>code,:upload_type=>"isdownload"})
	str={"success"=>200,"url"=>"http://115.29.36.94:999/"+photo_name}
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
					str<<{"success"=>200,
						"photo"=>"http://115.29.36.94:999/"+i.file_path,
						"code"=>i.photo_id}
				else
				   if i.upload_type==status
						str<<{"success"=>200,
						"photo"=>"http://115.29.36.94:999/"+i.file_path,
						"code"=>i.photo_id}
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
				i.save
				end
			str={"success"=>200}
			end
		end
	render:json=>str
	end
end
