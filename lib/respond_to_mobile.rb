module ActionController
  module RespondToMobile
    
    # These are various strings that can be found in mobile devices. Please feel free
    # to add on to this list.
    MOBILE_USER_AGENTS =  'palm|palmos|palmsource|iphone|blackberry|nokia|phone|midp|mobi|pda|' +
                          'wap|java|nokia|hand|symbian|chtml|wml|ericsson|lg|audiovox|motorola|' +
                          'samsung|sanyo|sharp|telit|tsm|mobile|mini|windows ce|smartphone|' +
                          '240x320|320x320|mobileexplorer|j2me|sgh|portable|sprint|vodafone|' +
                          'docomo|kddi|softbank|pdxgw|j-phone|astel|minimo|plucker|netfront|' +
                          'xiino|mot-v|mot-e|portalmmm|sagem|sie-s|sie-m|android|ipod'
    
    BROWSER_USER_AGENTS = {
      :safari => 'mobile\/.+safari',
      :opera => 'opera mobile',
      :iphone => 'iphone|ipod',
      :android => 'android',
      :touch => 'iphone|ipod|android'
    }
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      # Add this to one of your controllers to use RespondToMobile.  
      #
      #    class ApplicationController < ActionController::Base 
      #      responds_to_mobile
      #    end
      def responds_to_mobile(options = {})
        send :include, InstanceMethods
        
        opts = { :formats => [:mobile], :test_mode => false }.merge(options)
        
        test_mode = opts[:test_mode]
        formats = opts[:formats]
        
        if test_mode
          before_filter { |c| c.force_mobile_format(test_mode) }
        else
          before_filter { |c| c.set_mobile_format(formats) }
        end
        
      end
    end
    
    module InstanceMethods
      
      # Forces the request format to be :mobile
      def force_mobile_format(test_mode)
        if test_mode == true
          request.format = :mobile
        else
          request.format = test_mode
        end
        session[:mobile_view] = true if session[:mobile_view].nil?
      end
      
      # Determines the request format based on whether the device is mobile or if
      # the user has opted to use either the 'Standard' view or 'Mobile' view.
      def set_mobile_format(formats)
        if is_mobile_device?
          if session[:mobile_view] == false
            request.format = :html 
          else
            request.format = device_format_match(formats)
          end
          session[:mobile_view] = true if session[:mobile_view].nil?
        end
      end
      
      # Returns either true or false depending on whether or not the user agent of
      # the device making the request is matched to a device in our regex.
      def is_mobile_device?
        request.user_agent.to_s.downcase =~ Regexp.new(ActionController::RespondToMobile::MOBILE_USER_AGENTS)
      end
      
      def is_device_or_browser?(format)
        case format
        when Symbol
          request.user_agent.to_s.downcase =~ Regexp.new(ActionController::RespondToMobile::BROWSER_USER_AGENTS[format])
        when Regexp
          request.user_agent.to_s.downcase =~ format
        when String
          request.user_agent.to_s.downcase.include?(format.to_s.downcase)
        end
      end
      
      def is_format?(format)
        request.format == format
      end
      
      def device_format_match(formats)
        if formats.last.to_sym == :mobile
          format = :mobile
          formats.pop
        else
          format = :html
        end
        formats.each do |f|
          if is_device_or_browser?(f)
            format = f
            break
          end
        end
        return format
      end
    end
    
  end
  
end

ActionController::Base.send(:include, ActionController::RespondToMobile)