class SendEmailSharedJob < Job
  def initialize args
    @to_email   = args[:to]
    @from_email = args[:from]
    @subject    = args[:subject]
    @body       = args[:body]
    @attachment = args[:attachment]
  end

  def perform
    gmail = Gmail.new user: @from_email
    gmail.send_email(
      to: @to_email,
      from: @from_email,
      subject: @subject,
      body: @body,
      attachment: @attachment
    )
  end
end
