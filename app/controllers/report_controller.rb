#encoding: utf-8
class ReportController < ApplicationController
	
	def get_user_province 
		user=User.all
		province=[]
		for i in user do
			province<<i.province
		end
		province=province.sort
		province.delete("")
		@test="i123"
		@data1=[]
		colors=["#d71345","#f47920","#ffd400","#228B22","#102b6a","#4d4f36","#411445"]
		index=0
		num=0
		while province.size!=0
			index=index+1			
			str=province[0]
			province.delete_at(0)
			if str==province[0]
			   num=num+1
			else
			   string={"name"=>str,"value"=>num+1,"color"=>colors[index%5]}
			   num=0
			  @data1<<string	   
			end
		end	
		@data1=@data1.to_json
	end

	def user_info
		user=User.all
		
		 label=['用户id','关注时间','昵称','发送信息数','','照片张数']
=begin		 file.puts "<table class="altrowstable" id="alternatecolor">"
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
=end
	end
end
