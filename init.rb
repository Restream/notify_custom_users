require 'redmine'

ActionDispatch::Callbacks.to_prepare do
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
  name 'Redmine Plugin for Notifying Custom Users'
  author 'Undev'
  description 'Email notifications for users specified in the Custom field of the User format.'
  version '0.0.7'
  url 'https://github.com/Undev/notify_custom_users'
  author_url 'http://github.com/Undev'
  requires_redmine :version_or_higher => '2.2.4'
end
