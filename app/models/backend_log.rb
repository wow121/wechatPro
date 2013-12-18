class BackendLog
  @@logger = Log4r::Logger.new "backend_log"
  @@out_putter = Log4r::RollingFileOutputter.new('backend_log', :filename =>  Rails.root.to_s + "/log/backend.log", :maxtime=> 24*3600, :trunc  => false)
  @@pattern_formatter = Log4r::PatternFormatter.new(:pattern => "%d %m\n")

  @@out_putter.formatter = @@pattern_formatter
  @@logger.outputters = @@out_putter
 
  def self.log(msg)
     @@logger.info msg
  end

end
