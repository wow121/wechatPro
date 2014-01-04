#encoding = utf-8
module MerchantHelper
	def self.mksmallphoto
		photo=Photos.all
		for i in photo do
			photo_name=i.file_path
			photo_name_small=i.file_path[0,photo_name.length-4]+"_small.jpg"
			system 'convert '+IMG_PATH+photo_name+' -resize 30% '+IMG_PATH+photo_name_small
			end
	end
	
	def self.checkerror
		photo=Photos.where(Time.now.to_i.to_s+"- UNIX_TIMESTAMP(created_at) < 60*5 ")
		BackendLog.log "===============check_error================"
		if photo.last==nil
			BackendLog.log "====normal===="
			end
		for i in photo do
			if(i.file_path==nil and Time.now.to_i-i.created_at.to_i>60*3)
				user=User.where("weixin_id"=>i.user_id).last
				user.status="normal"
				user.photo_count=0
				user.save
				BackendLog.log "user"+user.weixin_id
				Photos.delete(i.id)
			end
		end
	end
	
	def self.getlog (username,status,stime,etime)
	if(stime==nil)
		stime=0
		end
	if(etime==nil)
		etime=Time.now.to_i
		end
	m=Merchant.where("token"=>username).first
	str=nil
	if(m==nil)
		str={"fail"=>"user not found"}
	else
		if(status=="projectlist")
			mp=MerchantProject.all
			label=['项目名','项目名_简称','项目简介','创建时间','属于商户','照片数量','项目识别码']
				context=[]
				for i in mp
					con=[]
					p=Photos.where("photo_id"=>i.code)
					con<<i.project_name
					con<<i.project_name_short
					con<<i.project_intro
					con<<i.created_at
					con<<i.merchant_id
					con<<p.length
					con<<i.code
					context<<con
					end
				str={"success"=>200,"url"=>SERVER_DOWNLOAD_IP+WeixinHelper.mkexecl(label,context,"项目列表")}
		
		elsif(status=="weixinuserlist")
			us=User.all
			label=['微信id','注册时间','最后操作时间','照片张数']
				context=[]
				for i in us
					con=[]
					p=Photos.where("user_id"=>i.weixin_id)
					
					con<<i.weixin_id
					con<<i.created_at
					con<<i.updated_at
					con<<p.length
					context<<con
					end
				str={"success"=>200,"url"=>SERVER_DOWNLOAD_IP+WeixinHelper.mkexecl(label,context,"微信用户列表")}
		elsif(status=="merchantlist")
			m=Merchant.all
			label=['商户名','注册时间','公司名称','商户店面','地点码','照片张数']
				context=[]
				for i in m
					con=[]
					p=Photos.where("merchant_id"=>i.user_name)
					con<<i.user_name
					con<<i.created_at
					con<<i.corp_name
					con<<i.office_name
					con<<i.loc_name
					con<<p.length
					context<<con
					end
				str={"success"=>200,"url"=>SERVER_DOWNLOAD_IP+WeixinHelper.mkexecl(label,context,"商户列表")}
		elsif(status=="photolist")
			photos=PhotoLog.where("UNIX_TIMESTAMP(created_at) >= "+Time.at(stime.to_i).to_i.to_s).where("UNIX_TIMESTAMP(created_at)<="+Time.at(etime.to_i).to_i.to_s)
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
				str={"success"=>200,"url"=>SERVER_DOWNLOAD_IP+WeixinHelper.mkexecl(label,context,"照片列表")}
				end
		else
			photos=PhotoLog.where("UNIX_TIMESTAMP(created_at) >= "+Time.at(stime.to_i).to_i.to_s).where("UNIX_TIMESTAMP(created_at)<="+Time.at(etime.to_i).to_i.to_s).where("merchant_id"=>status)
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
				str={"success"=>200,"url"=>SERVER_DOWNLOAD_IP+WeixinHelper.mkexecl(label,context,"照片列表"+i.merchant_id)}
				end
			end
		end
		return str
	end
	
	
	def self.register(username,pw,corpname,locname,officename,admin)
		password=Digest::MD5.hexdigest(pw)
		code=WeixinProcesser.mkrandom(12)
		Merchant.create({:user_name=>username,:password=>password,:corp_name=>corpname,:loc_name=>locname,:office_name=>officename,:token=>code,:admin=>admin})
	end
end
