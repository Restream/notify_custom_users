require File.expand_path('../../test_helper', __FILE__)

class MailerTest < ActiveSupport::TestCase
  include Redmine::I18n
  fixtures :projects, :issues, :users, :email_addresses, :members,
           :member_roles, :roles,
           :journals, :journal_details,
           :trackers, :projects_trackers,
           :enabled_modules,
           :issue_statuses, :enumerations

  def setup
    Setting.host_name = 'mydomain.foo'
    Setting.protocol = 'http'
    Setting.plain_text_mail = '0'
    Setting.default_language = 'en'

    @cf = IssueCustomField.create(
        :name => 'tester',
        :field_format => 'user',
        :is_required => false,
        :is_for_all => true,
        :multiple => false)

    @cf.trackers << Tracker.all

    @custom_user = User.find(8)
    @editor = User.find(2)

    @issue = Issue.find(4)
    @journal = @issue.init_journal(@editor)

    @issue.custom_field_values = { @cf.id.to_s => @custom_user.id.to_s }
    @issue.save!

    User.current = @editor
    ActionMailer::Base.deliveries.clear
  end

  def test_mail_to_custom_users
    Mailer.deliver_issue_edit(@journal)
    mail_recipients = all_mail_recipients
    assert_includes mail_recipients, @custom_user.mail
  end

  def test_mail_to_custom_users_was
    issue = Issue.find(4)
    journal = issue.init_journal(issue.author)

    issue.custom_field_values = { @cf.id.to_s => '' }
    issue.save!

    Mailer.deliver_issue_edit(journal)
    mail_recipients = all_mail_recipients
    assert_includes mail_recipients, @custom_user.mail
  end

  private

  def all_mail_recipients
    ActionMailer::Base.deliveries.map do |message|
      message.to + message.cc + message.bcc
    end.flatten.uniq.reject(&:blank?)
  end
end
