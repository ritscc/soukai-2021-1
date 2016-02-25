log_file = ARGV.shift

File.open(log_file) do |file|
  puts (file.read.scan(%r<\((\./.*?\.tex).*\n(![\d\D]*?l\..*[\d\D]*?)(?=.*tex)>)).flatten
end
