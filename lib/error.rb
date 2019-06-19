class Error

  def self.handle message: 'No message', error: 'No error'
    if ENV['SCRAPPER_ENV'] == 'development'
      raise
    else
      gmail = Gmail.new user: ENV['MYFREIGHT_USER']
      gmail.send_email(
        to: 'sam.adams@myfreight.com.au',
        from: ENV['MYFREIGHT_USER'],
        subject: "Scrapper task #{TASK_NAME} raised an error.",
        body: "#{message} \n #{error}"
      )
    end
  end
end
