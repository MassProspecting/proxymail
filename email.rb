class Email
	attr_accessor :subject, :body, :sender_email_address, :date, :time

	def initialize(subject, body, sender_email_address, date, time)
		@subject = subject
		@body = body
		@sender_email_address = sender_email_address
		@date = date
		@time = time
	end
end