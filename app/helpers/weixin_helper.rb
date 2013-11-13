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
end
