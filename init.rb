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
  name 'Redmine plugin for Notifying Custom Users'
  author 'Restream'
  description 'This plugin sends email notifications to users specified in the Custom field of the User format.'
  version '1.0.2'
  url 'https://github.com/Restream/notify_custom_users'
  author_url 'http://github.com/Restream'
  requires_redmine :version_or_higher => '2.6.1'
end
