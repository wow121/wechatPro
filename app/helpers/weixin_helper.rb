#encoding = utf-8
module WeixinHelper
  def current_step session_info=nil, order_state=nil
    step = 0
    if session_info == nil || session_info["machine"] == nil || session_info["template"] == nil
      step = 0
    elsif session_info["address"] == nil || session_info["order_id"] == nil
      step = 1
    elsif order_state == nil || order_state == "NOT_PAY"
      step = 2
    else
      step = 3
    end

    step
  end
  
  def shell_mask session_info={},tpl_folder=""
    border = session_info["border"] || "3d"
    image_tag("Templates/" + tpl_folder + "/mask_" + border + ".png", style: "position:absolute; left:0px; top: 0px; z-index: 3; width: 100%;height:100%;", "data-foldername" => tpl_folder, "data-border" => border, id: "mask")
    
  end
  
  def template_img no="t001", tplname="Standard", tpl_folder="", session_info
    border = (session_info["border"] == "white" ? "white" : "black");
    image_tag("Templates/" + tpl_folder.to_s + "/" + no + "/" + tpl_folder.to_s + "_" + no + "_preview_" + border + ".png", "data-no" => no, "data-tplname" => tplname, "style" => "width: 100%;height:100%;")

  end
  
  #选择手机壳样式
  def shell_select_text session_info={}
    border = session_info["border"] || "3d"
    border_hash = {
      "black" => "选择边框（当前：大气黑软边）",
      "white" => "选择边框（当前：优雅白软边）",
      "3d" => "选择边框（当前：全彩硬边）"
    }
    if session_info["border"].nil?
      return "选择边框（当前默认：全彩硬边）"
    else
      return border_hash[border]
    end
  end
  
  def shell_is_selected select_border, session_info={}
    border = session_info["border"] || "3d"
    if select_border == border
      return raw('<div class="shell-selected"></div>')
    else
      return ""
    end

  end
  
  def express_err_code express
    # #0无错误
    # errDes = {
    #   "1" => "单号不存在",
    #   "2" => "验证码错误",
    #   "3" => "链接查询服务器失败",
    #   "4" => "程序内部错误",
    #   "5" => "程序执行错误",
    #   "6" => "快递单号格式错误",
    #   "7" => "快递公司错误",
    #   "10" => "未知错误"
    # }
    
    if express["errCode"] == "0"
      return ""
    else
      return raw("<div class=\"express-errcode\">" + express["message"] + "</div>")
    end
    
  end
  
  
  
  def self.download_pic(url,location,location1)
           res = RestClient.get url
           File.open(location, "wb") do |f|
              f.write(res.body)
           end
		   system 'convert '+location+' -resize 30% '+location1
     end	

  def self.mkexecl(label,context,name)
    time=Time.now.strftime("%Y_%m_%d").to_s+name
	File.open("/home/weixin/excel/"+time+".xls","w+") do |file|
		file.puts "<html>"
		file.puts "<body>"
		file.puts "<table>"
		file.puts "<tr>"
		for i in label
			file.print "<td>"+i+"</td>"
			end
		file.puts ""
		file.puts "</tr>"
		for con in context
			file.puts "<tr>"
			for co in con
				file.print "<td>"+co.to_s+"</td>"
				end
			file.puts ""
			file.puts "</tr>"
			end
		file.puts "</table>"
		file.puts "</body>"
		file.puts "</html>"
		end
	return time+".xls"
	end 
	
	def self.mkqrcode(user)
		m=Merchant.where("token"=>user).first
	str=nil
	if(m==nil)
		str={"fail"=>"user not found"}
	else
		time=Time.now.to_i.to_s
		name = "/home/weixin/merchant_qrcode/" + m.user_name+time + ".jpg"
		code=WeixinProcesser.mkrandom(10)
		system 'java -classpath /home/weixin/myjava QRCodeEncoderHandler '+name+' '+code
		MerchantCode.create(:merchant_id=>m.user_name,:code=>code)
		str={"success"=>200,
				"code"=>code,
				"url"=>SERVER_QRCODE+m.user_name+time+".jpg"}
		end
	
		return str
	end
    
	def self.mv_old_photo
		time=Time.now
		photo=Photos.all
		BackendLog.log "===============move================"
		for i in photo do
			if(time.to_i-i.created_at.to_i>=24*60*60*24)
				BackendLog.log "move "+i.file_path
				system 'mv /home/weixin/user_photos/'+i.file_path+' /home/weixin/old_photos/'
				Photos.delete(i.id)
				end
		end
		
	end
	
	def self.add_photo_log
		time=Time.now
		photo=Photos.all
		BackendLog.log "===============add to photolog================"
		for i in photo do
			if(time.to_i-i.updated_at.to_i<=24*60*60)
				p=PhotoLog.where("file_path"=>i.file_path).first
				if p==nil
					BackendLog.log "create "+i.file_path
					PhotoLog.create(:upload_type=>i.upload_type,
							:user_id=>i.user_id ,
							:merchant_id=>i.merchant_id ,
							:photo_id=>i.photo_id,
							:file_path=>i.file_path,
							:state=>i.state,  
							:payment_id=>i.payment_id , 
							:payment_email=>i.payment_email ,
							:paid_at=>i.paid_at,
							:weixin_image_path=>i.weixin_image_path,
							:downloads=>i.downloads ,
							:description=>i.description)
				else
					BackendLog.log "updated "+i.file_path
					p.upload_type=i.upload_type
					p.user_id=i.user_id
					p.merchant_id=i.merchant_id
					p.photo_id=i.photo_id
					p.file_path=i.file_path
					p.state=i.state
					p.payment_id=i.payment_id
					p.payment_email=i.payment_email
					p.paid_at=i.paid_at
					p.weixin_image_path=i.weixin_image_path
					p.downloads=i.downloads
					p.description=i.description
					p.save
				end
			end
		end
	end
	

end
