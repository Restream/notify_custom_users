module NotifyCustomUsers
  module IssueRecipients
    def self.included(base)
      # find users selected in custom fields with type 'user'
      base.send :define_method, :custom_users do
        custom_user_values = custom_field_values.select do |v|
          v.custom_field.field_format == "user"
        end
        custom_user_ids = custom_user_values.map(&:value).flatten.compact
        User.find(custom_user_ids)
      end

      # users selected in custom fields with type 'user' before change
      base.send :define_method, :custom_users_was do
        if @custom_values_before_change
          custom_user_values = @custom_values_before_change.select do |v|
            v.custom_field.field_format == "user"
          end
          custom_user_ids = custom_user_values.map(&:value).flatten.compact
          User.find(custom_user_ids)
        else
          []
        end
      end

      # add 'custom users' to recipients
      base.send :define_method, :recipients_with_custom_users do
        notified = recipients_without_custom_users

        notified_custom_users = custom_users.select do |u|
          u.active? && u.notify_custom_user?(self) && visible?(u)
        end

        notified += notified_custom_users.map(&:mail)
        notified.uniq
      end
      base.send :alias_method_chain, :recipients, :custom_users
    end
  end
end

::Issue.send :include, NotifyCustomUsers::IssueRecipients
