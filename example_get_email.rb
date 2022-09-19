# En el caso de las cuentas Gmail, es necesario permitir el acceso desde un nuevo dispositivo
# Para habilitar nuevo acceso: https://accounts.google.com/b/0/DisplayUnlockCaptcha

# En el caso de las cuentas Outlook, se recibirá un email a la cuenta notificando del acceso
# remoto, y se podrá habilitar el nuevo dispositivo.
# Para ver los últimos inicios de sesión de Outlook: https://account.live.com/activity

require_relative 'inbox_reader'
require_relative 'email'

# Datos de conexión
email = ''
pass = ''
proxy_host = ''
proxy_port = ''
proxy_user = ''
proxy_pass = ''

# Abrir conexión IMAP a través de Proxy utilizando SSL
inbox = InboxReader.new
inbox.open(email, pass, proxy_host, proxy_port, proxy_user, proxy_pass)

# Fecha desde la cual recuperar emails, ejemplo: Hace 5 días
date_from = Date.today - 5

# Recuperar correos del servidor
emails = inbox.get_emails_from(date_from)

# Cerrar conexión con el servidor
inbox.close

# Mostrar salida
puts "\n\n#{emails.count} emails recuperados desde #{date_from.strftime('%D')}\n"

emails.each_with_index do |e, i|
	puts "\nCorreo #{i+1}"
	puts "--------------"
	puts "Remitente: #{e.sender_email_address}"
	puts "Asunto: #{e.subject}"
	puts "Fecha: #{e.date}"
	puts "Hora: #{e.time}"
end