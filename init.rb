require 'redmine'

require_dependency 'notify_custom_users/issue_recipients'
require_dependency 'notify_custom_users/user_notify_about'

Redmine::Plugin.register :notify_custom_users do
  name 'Notify Custom Users plugin'
  author 'danil.tashkinov@gmail.com'
  description 'Email Notifications for Custom field with User type'
  version '0.0.2'
  url 'https://github.com/Undev/notify_custom_users'
  author_url 'http://github.com/Undev'
end
