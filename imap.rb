require 'net/imap'

module Net
	class IMAP
		attr_writer :proxy, :proxy_user

		def initialize(host, port_or_options = {}, usessl = false, p_addr = nil, p_port = nil, p_user = nil, p_pass = nil, certs = nil, verify = true)
			super()
			@host = host
			begin
				options = port_or_options.to_hash
			rescue NoMethodError
				# for backward compatibility
				options = {}
				options[:port] = port_or_options
				if usessl
					options[:ssl] = create_ssl_params(certs, verify)
				end	   
			end 

			if p_addr && p_port
				@proxy = true
			end

			if p_user && p_pass
				@proxy_user = true
			end

			@port = options[:port] || (options[:ssl] ? SSL_PORT : PORT)
			@tag_prefix = "RUBY"
			@tagno = 0
			@parser = ResponseParser.new
			
			if proxy?
				@sock = TCPSocket.open(p_addr, p_port)
				buf = "CONNECT #{@host}:#{@port} HTTP/1.1\r\n"
				buf << "Host: #{@host}:#{@port}\r\n"

				if proxy_user?
					credential = ["#{p_user}:#{p_pass}"].pack('m')
				credential.delete!("\r\n")
			buf << "Proxy-Authorization: Basic #{credential}\r\n"
				end
				buf << "\r\n"
				@sock.write(buf)
				@sock.gets
			else
				@sock = TCPSocket.open(@host, @port)
			end
	    
			if options[:ssl]
				start_tls_session(options[:ssl])
				@usessl = true
			else
				@usessl = false
			end
	    
			@responses = Hash.new([].freeze)
			@tagged_responses = {}
			@response_handlers = []
			@tagged_response_arrival = new_cond
			@continuation_request_arrival = new_cond
			@idle_done_cond = nil
			@logout_command_tag = nil
			@debug_output_bol = true
			@exception = nil
			@greeting = get_response
			
			if @greeting.nil?
				@sock.close
				raise Error, "connection closed"
			end
			
			if @greeting.name == "BYE"
				@sock.close
				raise ByeResponseError, @greeting
			end
	    
			@client_thread = Thread.current
			@receiver_thread = Thread.start {
				begin
					receive_responses
				rescue Exception
				end
			}
			@receiver_thread_terminating = false
		end
		
		def proxy?
			!!@proxy
		end

		def proxy_user?
			!!@proxy_user
		end
	end
end