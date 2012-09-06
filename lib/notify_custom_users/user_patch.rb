module NotifyCustomUsers
  module UserPatch
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def notify_custom_user?(object)
        if %w(selected only_my_events only_assigned).include?(mail_notification)
          object.is_a?(Issue) &&
              (object.custom_users.include?(self) || object.custom_users_was.include?(self))
        end
      end
    end
  end
end
