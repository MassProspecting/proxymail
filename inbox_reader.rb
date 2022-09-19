require "rubygems" 
require "bundler/setup"
require "tmail"

require_relative "imap"
require_relative "email"

class InboxReader

	attr_accessor :domain_params, :imap

	def open(email_address, email_password, proxy_address, proxy_port, proxy_user, proxy_password)
		domain = email_address.split('@').last
		imap_host = get_params_from_domain(domain)

		raise_invalid_domain_exception if imap_host.nil?
		
		@imap = Net::IMAP.new(imap_host, 993, true, proxy_address, proxy_port, proxy_user, proxy_password)
		@imap.login(email_address, email_password)
		@imap.select('INBOX')
	end

	def close
		@imap.disconnect
	end

	def get_emails_from(date_from)
		emails = []
		
		@imap.search(["SINCE", date_from.strftime("%d-%b-%Y")]).each do |message_id|
			msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
    	mail = TMail::Mail.parse(msg)

    	date = mail.date.to_datetime.to_date
    	time = mail.date.to_datetime.strftime("%H:%M:%S")
    	emails << Email.new(mail.subject, mail.body, mail.from.first, date, time)
		end

		emails
	end

	private	

		def get_params_from_domain(domain)
			return 'imap.gmail.com' if domain.include?("gmail")
			return 'imap-mail.outlook.com' if ["hotmail", "outlook"].any? { |d| domain.include?(d) }
			return 'imap.mail.yahoo.com' if domain.include?("yahoo")	
		end

		def raise_invalid_domain_exception  
		  raise 'Only Outlook, Gmail and Yahoo accounts are supported'  
		end  
	
end