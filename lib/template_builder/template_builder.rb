require File.join(File.dirname(__FILE__),"/framework_builder.rb")
class TemplateBuilder
    
    def initialize
      @frameworks = {"database"=>nil, "orm"=>nil, "javascript"=>nil,
                     "templating"=>nil,"css"=>nil, "authentication"=>nil,
                     "unit_testing"=>nil, "integration_testing"=>nil
                    }
      @options = []
      @after = []
    end

    def build_template_file(filename)
      choose_all_framework
      create_file filename
      generate_file
    end
    
    def choose_all_framework
      @frameworks.sort.each do |key,value|
        @frameworks[key] = choose_framework key.to_sym unless @frameworks[key]
        if key == "database"
          @frameworks["orm"] = choose_framework "orm_mongo" if "mongo" == @frameworks[key].name
          @frameworks["orm"] = choose_framework "orm_redis" if "redis" == @frameworks[key].name
          @frameworks["orm"] = choose_framework "orm" unless @frameworks["orm"]
        end
      end
    end
    
    def choose_framework(type)
      possibility_framework = FrameworkBuilder.build_all_frameworks type
      question = "\r\n\r\n Choose => "+type.to_s+" ?\r\n\r\n"
      possibility_framework.each_index{ |index| question+="("+(index+1).to_s+") "+possibility_framework[index].name.to_s+"\r\n" }
      result = false
      until result do
        puts question
        answer = gets.chomp
        result = possibility_framework[answer.to_i-1] if (1..possibility_framework.length).include?(answer.to_i)
      end
      say_recipe result.name
      result
    end
    
    def create_file(filename)
      @file = File.new(filename,  "w+")
    end
    
    def say_recipe(name); puts "\033[36m" + "recipe".rjust(10) + "\033[0m" + "    Running #{name} recipe..." end
    
    def generate_file
      initialize_gem_file
      generate_orm
      generate_templating
      generate_css
      generate_javascript
      generate_testing
      generate_authentication
      finalize      
    end
    
    def start_rails
      option = building_option
      file_path = @file.path
      "rails new 'your_rails_project' #{option} -f -m #{file_path}"
    end
    
    def building_option
      @options.flatten.to_s
    end
    
    def initialize_gem_file
      @file.write "remove_file 'Gemfile'\n"
      @file.write "create_file 'Gemfile' do
      <<-GEMFILE
      source 'http://rubygems.org'
      
      RAILS_VERSION = '~> 3.0.3'
      gem 'activesupport',      RAILS_VERSION, :require => 'active_support'
      gem 'actionpack',         RAILS_VERSION, :require => 'action_pack'
      gem 'actionmailer',       RAILS_VERSION, :require => 'action_mailer'
      gem 'railties',           RAILS_VERSION, :require => 'rails'
      
      GEMFILE
      end\n"
    end
    
    def generate_orm
      orm_framework = @frameworks["orm"]
      write_gem orm_framework.gems
      framework_name = orm_framework.name
      if framework_name == "active_record"
        @options << "-d "+ @frameworks["database"].name+" "
      elsif framework_name == "data_mapper"
        @options << "-O"
        database_name = @frameworks["database"].name
        @file.write "gem 'dm-"+database_name+"-adapter'\n"
      elsif ["mongoid", "mongo_mapper"].include?(framework_name)
        @options << "-O"
        @after << "generate '"+framework_name+":config'\n"
        @file.write "gsub_file 'config/initializers/session_store.rb', ':cookie_store, :key => \"_foo_session\"', '"+framework_name+"_store' \n"
      end
    end
    
    def generate_templating
      write_gem @frameworks["templating"].gems 
    end
    
    def generate_css
      write_gem @frameworks["css"].gems
      framework_name =  @frameworks["css"].name
      if framework_name == "sass"
        compass = ask_for_compass
        unless compass == "none"
          @file.write "gem 'compass'\n"
          @after << "run 'compass init --force --using "+compass.name.to_s+" --app rails --css-dir public/stylesheets'\n"
        end
      end
    end
    
    def ask_for_compass
      choose_framework "compass"
    end
    
    def generate_javascript
      framework_name = @frameworks["javascript"].name
      js_framework = @frameworks["javascript"]
      unless framework_name == "prototype"
        @file.write "run 'rm -rf public/javascripts/*'\n"
        @options << "-J"
        @file.write "inside 'public/javascripts' do\n"
        js_framework.gems.each { |gem| @file.write "get '"+gem.source+"', '"+gem.name+"'\n" }
        @file.write "end\n"
        
        js_name = ""
        js_framework.gems.each { |element| js_name +=" "+element.name[0..-4] } 
        @file.write "application do\n"
        @file.write "'config.action_view.javascript_expansions[:defaults] = %w("+js_name+")'\n"
        @file.write "end\n"
        
        @file.write "gsub_file 'config/application.rb', /# JavaScript.*\\n/, ''\n"
        @file.write "gsub_file 'config/application.rb', /# config\.action_view\.javascript.*\\n/, ''\n"      
      end
    end
    
    def generate_testing
      generate_unit_testing
      generate_integration_testing
      
      if "rspec" == @frameworks["unit_testing"].name
        @after << "generate 'rspec:install'\n"
        @options << "-T"
        @file.write "run 'rm -rf test'\n"
      end
      if "cucumber" == @frameworks["integration_testing"].name
        @after << "generate 'cucumber:install --capybara#{' --rspec' if @frameworks['unit_testing'].name=='rspec'}#{' -D' unless @frameworks['orm'].name=='activerecord'}'\n"
      end
    end
    
    def generate_unit_testing
      test_framework = @frameworks["unit_testing"]  
      write_gem test_framework.gems      
    end
    
    def generate_integration_testing
      test_framework = @frameworks["integration_testing"]  
      write_gem test_framework.gems
    end
    
    def generate_authentication
      auth_framework = @frameworks["authentication"]
      write_gem auth_framework.gems
      if auth_framework.name == "devise"
        @after << "generate 'devise:install'\n"
        case @frameworks["orm"].name
          when 'mongo_mapper'
            @file.write "gem 'mm-devise'\n"
            @after << "gsub_file 'config/initializers/devise.rb', 'devise/orm/active_record', 'devise/orm/mongo_mapper_active_model\n'"
          when 'mongoid'
            @after << "gsub_file 'config/initializers/devise.rb', 'devise/orm/active_record', 'devise/orm/mongoid'\n"
        end
        @after << "generate 'devise user'"
      elsif auth_framework.name == "omniauth"
        @file.write "initializer 'omniauth.rb', <<-RUBY
        Rails.application.config.middleware.use OmniAuth::Builder do
          # Set up your authentication providers here.
          # Once you've done that you will need to set up a
          # route that handles /auth/:provider/callback
          # and takes a look at request.env['omniauth.auth']
          # for authentication information.
          #
          # provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
          # provider :facebook, 'APP_ID', 'APP_SECRET'
          # provider :open_id, OpenID::Storage::Filesystem.new('/tmp')
        end
        RUBY"
      end
    end
    
    def finalize
      @file.write "run 'bundle install'\n"
      @file.write "application  <<-GENERATORS 
      config.generators do |g|
        g.template_engine :#{@frameworks['templating'].name}
        g.test_framework  :#{@frameworks['unit_testing'].name}, :fixture => true, :views => false
        g.integration_tool :#{@frameworks["integration_testing"].name}, :fixture => true, :views => true
        g.orm :#{@frameworks["orm"].name}
      end
      GENERATORS\n"
      
      @after.each { |item| @file.write item}
      @file.close
    end
    
    def write_gem_test(gems)
      gems.each { |gem| @file.write "gem "+gem.gemify.to_s+", :group => :test\n"}
    end
    
    def write_gem(gems)   
      gems.each { |gem| @file.write "gem "+gem.gemify.to_s+"\n"}
    end
end
