class JsonImporter
  @@machine_info = nil

  def self.import(file_name)
	  f = File.open(file_name)
	  json = f.read
		result = JSON.parse json
		return result
	end

	def self.machine_info
    @@machine_info = self.import("app/assets/images/Templates/mobile_model.json") if @@machine_info == nil
		return @@machine_info
	end
end
