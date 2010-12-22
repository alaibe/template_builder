module TemplateBuilder::App::ConfWriter  
  def self.write_new_framework(name,priority)
    #raise Exception, "Framework #{name} already exists." if test ?e, TemplateBuilder::PATH+"/conf/"+name+".yml"
    File.open(File.join(TemplateBuilder::PATH+"/conf/",name+".yml"),"w")
    File.open(File.join(TemplateBuilder::PATH+"/conf/","param.yml"),"a+") do |out|
      out.write "\n#{name} : \n\t help : set the #{name} framework you want use\n\tpriority : #{priority}"
    end
  end
  
  def self.write_new_plugin(framework_name,plugin_name)
    raise Exception, "Framework #{name} doesn't exists." unless test ?e, TemplateBuilder::PATH+"/conf/"+framework_name+".yml"
  end
end