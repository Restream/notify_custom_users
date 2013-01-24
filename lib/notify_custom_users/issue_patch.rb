module NotifyCustomUsers
  module IssuePatch
    def self.included(base)
      base.send :include, InstanceMethods
      base.class_eval do
        alias_method_chain :notified_users, :custom_users
      end
    end

    module InstanceMethods
      # find users selected in custom fields with type 'user'
      def custom_users
        custom_user_values = custom_field_values.select do |v|
          v.custom_field.field_format == "user"
        end
        custom_user_ids = custom_user_values.map(&:value).flatten
        custom_user_ids.reject! { |id| id.blank? }
        User.find(custom_user_ids)
      end

      # users selected in custom fields with type 'user' before change
      def custom_users_was
        if last_journal_id && (journal = journals.find(last_journal_id))
          custom_user_ids = []
          journal.details.each do |det|
            c_user_field = custom_field_values.detect do |v|
              det.prop_key == v.custom_field_id.to_s && v.custom_field.field_format == 'user'
            end
            custom_user_ids << det.old_value if c_user_field && det.old_value.present?
          end
          User.find(custom_user_ids)
        else
          []
        end
      end

      # add 'custom users' to notified_users
      def notified_users_with_custom_users
        notified = notified_users_without_custom_users

        notified_custom_users = (custom_users + custom_users_was).select do |u|
          u.active? && u.notify_custom_user?(self) && visible?(u)
        end
        notified += notified_custom_users
        notified.uniq
      end
    end
  end
end
