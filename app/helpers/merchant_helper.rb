module MerchantHelper
	def self.mksmallphoto
		photo=Photos.all
		for i in photo do
			photo_name=i.file_path
			photo_name_small=i.file_path[0,photo_name.length-4]+"_small.jpg"
			system 'convert '+"/home/weixin/user_photos/"+photo_name+' -resize 30% '+"/home/weixin/user_photos/"+photo_name_small
			end
	end
	
	def self.checkerror
		photo=Photos.where(Time.now.to_i.to_s+"- UNIX_TIMESTAMP(created_at) < 60*5 ").last
		BackendLog.log "===============check_error================"
		if photo==nil
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
	
end
