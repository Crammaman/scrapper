class Gmail
	require 'google/apis/gmail_v1'
	require 'googleauth'
	require 'fileutils'
	require 'mail'

	def initialize user: ENV['MYFREIGHT_USER']

		@user = user

		# Initialize the API
		@gmail = Google::Apis::GmailV1::GmailService.new
		@gmail.client_options.application_name = "fetch"
		@gmail.authorization = get_authorization

	end

	#Returns an array of [{ id: message_id, threadId: ?? }]
	def search query_string
		@gmail.list_user_messages( @user, q: query_string ).messages
	end

	def delete messages
		message_ids = messages.map(&:id)
		delete_request = Google::Apis::GmailV1::BatchDeleteMessagesRequest.new ids: message_ids
		@gmail.batch_delete_messages @user, delete_request
	end

	def get_message id
		@gmail.get_user_message @user, id
	end

  def get_email_attachment(search_string, attachment_index = 0, message_index = 0)
    #Attachments start at index 1
    attachment_index += 1

		search_result = @gmail.list_user_messages("sam.adams@myfreight.com.au",q: search_string)

		if search_result.messages

			meta_email = search_result.messages[message_index]
			email = @gmail.get_user_message("sam.adams@myfreight.com.au",meta_email.id)
			attachment_id = email.payload.parts[attachment_index].body.attachment_id
			attachment_data = @gmail.get_user_message_attachment("sam.adams@myfreight.com.au",email.id,attachment_id).data
			email_subject_header = email.payload.headers.detect{ |header| header.name == 'Subject' }

		else

			puts "No emails found for #{search_string}"
			return nil

		end

		puts "Retreived #{attachment_data.to_s.bytesize} bytes from email with subject '#{email_subject_header.value}'"

		attachment_data

  end
	
  def set_user_signature signature
		send_as_settings = @gmail.list_user_setting_send_as 'me'
		@gmail.patch_user_setting_send_as( send_as_settings.send_as[0].send_as_email, send_as_settings.send_as[0].send_as_email, { "signature": signature}, options: {})

  end

  def send_email email_args

		m = Mail.new(to: email_args[:to],
			from: email_args[:from] || @user,
			subject: email_args[:subject],
			body: email_args[:body])

		m.add_file email_args[:attachment] if email_args[:attachment]

		#message = Google::Apis::GmailV1::Message.new raw: m.to_s

		@gmail.send_user_message( email_args[:from] || @user, nil, upload_source: StringIO.new(m.to_s), content_type: 'message/rfc822')

		puts "Sent email to #{email_args[:to]} from #{email_args[:from] || @user}"

  end

  private
	def get_authorization

		authorizer = Google::Auth::ServiceAccountCredentials.new(
			token_credential_uri: "https://www.googleapis.com/oauth2/v4/token",
      audience:             "https://www.googleapis.com/oauth2/v4/token",
			scope:               ['https://www.googleapis.com/auth/gmail.settings.basic',
														'https://mail.google.com/'],
      issuer:               ENV['GMAIL_CLIENT_EMAIL'],
      signing_key:          OpenSSL::PKey::RSA.new(Secrets.gmail_private_key),
      project_id:           ENV['GMAIL_PROJECT_ID']
		).configure_connection({})

		impersonate_auth = authorizer.dup
    impersonate_auth.sub = @user
		impersonate_auth
	end
end
