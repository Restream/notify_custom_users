require File.expand_path('../../test_helper', __FILE__)

class MailerTest < ActiveSupport::TestCase
  include Redmine::I18n
  include ActionDispatch::Assertions::SelectorAssertions
  fixtures :projects, :issues, :users, :members,
           :member_roles, :roles,
           :journals, :journal_details,
           :trackers, :projects_trackers,
           :enabled_modules,
           :issue_statuses, :enumerations

  def setup
    @cf = IssueCustomField.create(
        :name => "tester",
        :field_format => "user",
        :is_required => false,
        :is_for_all => true,
        :multiple => false)

    @cf.trackers << Tracker.all

    @custom_user = User.find(8)
    @issue = Issue.find(4)
    @journal = @issue.init_journal(@custom_user)

    @issue.custom_field_values = { @cf.id.to_s => @custom_user.id.to_s }
    @issue.save

    ActionMailer::Base.deliveries.clear
    Setting.host_name = 'mydomain.foo'
    Setting.protocol = 'http'
    Setting.plain_text_mail = '0'
  end

  def test_mail_to_custom_users
    mail = Mailer.issue_edit(@journal)
    mail_recipients = mail_recipients(mail)
    assert_includes mail_recipients, @custom_user.mail
  end

  def test_mail_to_custom_users_was
    issue = Issue.find(4)
    journal = issue.init_journal(issue.author)

    issue.custom_field_values = { @cf.id.to_s => "" }
    issue.save

    mail = Mailer.issue_edit(journal)
    mail_recipients = mail_recipients(mail)
    assert_includes mail_recipients, @custom_user.mail
  end

  private

  def mail_recipients(mail)
    (mail.to + mail.cc + mail.bcc).flatten.uniq.reject(&:blank?)
  end
end
