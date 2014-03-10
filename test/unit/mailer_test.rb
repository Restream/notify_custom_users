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

  class EmailCollector
    include Singleton

    attr_accessor :messages

    def self.delivering_email(message)
      instance.messages ||= []
      instance.messages << message
    end
  end

  def setup
    @cf = IssueCustomField.create(
        :name => 'tester',
        :field_format => 'user',
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
    ActionMailer::Base.register_interceptor(EmailCollector)
    EmailCollector.instance.messages = []
    Setting.host_name = 'mydomain.foo'
    Setting.protocol = 'http'
    Setting.plain_text_mail = '0'
  end

  def test_mail_to_custom_users
    deliver_issue_edit(@journal)
    mail_recipients = mail_recipients
    assert_includes mail_recipients, @custom_user.mail
  end

  def test_mail_to_custom_users_was
    issue = Issue.find(4)
    journal = issue.init_journal(issue.author)

    issue.custom_field_values = { @cf.id.to_s => '' }
    issue.save

    deliver_issue_edit(journal)
    mail_recipients = mail_recipients
    assert_includes mail_recipients, @custom_user.mail
  end

  private

  def mail_recipients
    EmailCollector.instance.messages.map do |message|
      message.to + message.cc + message.bcc
    end.flatten.uniq.reject(&:blank?)
  end

  def deliver_issue_edit(journal)
    if Redmine::VERSION.to_s >= '2.4'
      Mailer.deliver_issue_edit(journal)
    else
      Mailer.issue_edit(journal)
    end
  end
end
