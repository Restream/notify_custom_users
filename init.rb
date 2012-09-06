require 'redmine'

callbacks = if Redmine::VERSION::MAJOR < 2
  require 'dispatcher'
  Dispatcher
else
  ActionDispatch::Callbacks
end

callbacks.to_prepare do
  require_dependency 'project'
  require_dependency 'principal'
  require_dependency 'user'
  require_dependency 'issue'
  unless Issue.included_modules.include? NotifyCustomUsers::IssuePatch
    Issue.send :include, NotifyCustomUsers::IssuePatch
  end
  unless User.included_modules.include? NotifyCustomUsers::UserPatch
    User.send :include, NotifyCustomUsers::UserPatch
  end
end

Redmine::Plugin.register :notify_custom_users do
  name 'Notify Custom Users plugin'
  author 'danil.tashkinov@gmail.com'
  description 'Email Notifications for Custom field with User type'
  version '0.0.4'
  url 'https://github.com/Undev/notify_custom_users'
  author_url 'http://github.com/Undev'
  requires_redmine :version_or_higher => '1.4.0'
end
