#encoding = utf-8
class MerchantController < ApplicationController
	def mkqrcode
	user=params[:userid]
	str=WeixinHelper.mkqrcode(user)
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
	photo_name_small=photo_name[0,photo_name.length-4]+"_small.jpg"
    File.open("/home/weixin/user_photos/"+photo_name,"wb+") do |f|
      f.write(photo.read)	
	  end
	system 'convert '+"/home/weixin/user_photos/"+photo_name+' -resize 30% '+"/home/weixin/user_photos/"+photo_name_small
	Photos.create({:merchant_id=>i.user_name,:file_path=>photo_name,:photo_id=>code,:upload_type=>"isdownload"})
	str={"success"=>200,"url"=>"http://115.29.36.94:999/"+photo_name,"s_url"=>"http://115.29.36.94:999/"+photo_name_small}
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
						"photo"=>"http://115.29.36.94:999/"+i.file_path,
						"code"=>i.photo_id,
						"s_photo"=>"http://115.29.36.94:999/"+path+"_small.jpg"}
				else
				   if i.upload_type==status
						path=i.file_path[0,i.file_path.length-4]
						str<<{"success"=>200,
						"photo"=>"http://115.29.36.94:999/"+i.file_path,
						"code"=>i.photo_id,
						"s_photo"=>"http://115.29.36.94:999/"+path+"_small.jpg"}
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
	m=Merchant.where("token"=>username).first
	str=nil
	if(m==nil)
		str={"fail"=>"user not found"}
	else
		if(status=="userlist")
			photos=Photos.all
			label=['商户id','微信id','授权码','文件名','下载记录','下载次数','创建时间','最后修改时间']
				context=[]
				for i in photos
					con=[]
					con<<i.merchant_id
					con<<i.user_id
					con<<i.photo_id
					con<<i.file_path
					con<<i.upload_type
					con<<i.downloads
					con<<i.created_at
					con<<i.updated_at	
					context<<con
					end
				str={"success"=>200,"url"=>"http://115.29.36.94:777/"+WeixinHelper.mkexecl(label,context)}
		
		else
			photos=Photos.where("UNIX_TIMESTAMP(created_at) >= "+Time.at(stime.to_i).to_i.to_s).where("UNIX_TIMESTAMP(created_at)<="+Time.at(etime.to_i).to_i.to_s).where("merchant_id"=>m.user_name)
			if(photos.first==nil)
				str={"fail"=>"photo not found"}
			else
				label=['商户id','微信id','授权码','文件名','下载记录','下载次数','创建时间','最后修改时间']
				context=[]
				for i in photos
					con=[]
					con<<i.merchant_id
					con<<i.user_id
					con<<i.photo_id
					con<<i.file_path
					con<<i.upload_type
					con<<i.downloads
					con<<i.created_at
					con<<i.updated_at	
					context<<con
					end
				str={"success"=>200,"url"=>"http://115.29.36.94:777/"+WeixinHelper.mkexecl(label,context)}
				end
			end
		end
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
