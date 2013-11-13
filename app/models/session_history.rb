class SessionHistory < ActiveRecord::Base
   attr_accessible :user_name, :session_info
	 
def self.save_current_page_state(user_name, data)
   s = SessionHistory.find_or_initialize_by_user_name(user_name)
   begin
      info = JSON.parse s.session_info
   rescue
      info = {}
   end

   info = info.merge(data)
   s.session_info = info.to_json
   s.save

   return s
end

def self.set_test_flag(user_name)
   s = SessionHistory.find_or_initialize_by_user_name(user_name)
   begin
      info = JSON.parse s.session_info
   rescue
      info = {}
   end

   info = info.merge({:test_flag => 1})
   s.session_info = info.to_json
   s.save

   return s
end

def self.check_test_flag(user_name)
   s = SessionHistory.find_by_user_name(user_name)

   begin
      info = JSON.parse s.session_info
			if info["test_flag"] != nil
			   return true
			else
			   return false
			end
   rescue
      return false 
   end
end

def self.enable_phone_shell_state(user_name)
   s = SessionHistory.find_or_initialize_by_user_name(user_name)
   begin
      info = JSON.parse s.session_info
   rescue
      info = {}
   end

   info = info.merge({:phone_shell_state => 1})
   s.session_info = info.to_json
   s.save
end

def self.disable_phone_shell_state(user_name)
   s = SessionHistory.find_or_initialize_by_user_name(user_name)
   begin
      info = JSON.parse s.session_info
   rescue
      info = {}
   end

   info = info.merge({:phone_shell_state => 0})
   s.session_info = info.to_json
   s.save
end

def self.check_phone_shell_state(user_name)
   s = SessionHistory.find_by_user_name(user_name)

   begin
      info = JSON.parse s.session_info
			if info["phone_shell_state"] == 1
			   return true
			else
			   return false
			end
   rescue
      return false 
   end
end

end
