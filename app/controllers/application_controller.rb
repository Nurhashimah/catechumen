# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details


  include AuthenticatedSystem
   before_filter :set_locale
   before_filter :get_pages_for_tabs
   before_filter :put_current_login_into_model
   before_filter { |c| Authorization.current_user = Login.current_user}


    def get_pages_for_tabs
      if logged_in?
        @tabs = Page.find_main
      else
        @tabs = Page.find_main_public
      end

    end

    protected

      def current_user
        Authorization.current_user = Login.current_login || nil
      end


      def set_locale
        session[:locale] = params[:locale] if params[:locale]
        I18n.locale = session[:locale] || I18n.default_locale

        locale_path = "#{LOCALES_DIRECTORY}#{I18n.locale}.yml"

        unless I18n.load_path.include? locale_path
          I18n.load_path << locale_path
          I18n.backend.send(:init_translations)
        end

      rescue Exception => err
        logger.error err
        flash.now[:notice] = "#{I18n.locale} translation not available"

        I18n.load_path -= [locale_path]
        I18n.locale = session[:locale] = I18n.default_locale
      end

      def put_current_login_into_model
        @login = Login.find_by_id(session[:login_id])
        if @login
          Login.current_login = @login
        end
      end

      def permission_denied
        flash[:error] = "Sorry, your user permissions do not allow you to access this information"
        redirect_to root_url
      end

      def late_to_be_approved
        Attendance.count(:all, :conditions => ["approve_id=? AND approvestatus IS ?", Login.current_login.staff_id, nil])
      end


end
