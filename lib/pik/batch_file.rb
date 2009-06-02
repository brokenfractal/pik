
class BatchFile

	def self.open(file_name)
		bf = new(file_name, :open)
		yield bf if block_given?
		bf
	end

	attr_accessor :file_data, :file_name, :ruby_dir

	def initialize(file_name, mode=:new)
		@rubyw_exe = 'rubyw.exe'
		@ruby_exe  = 'ruby.exe'
		@file_name = file_name 
		case mode
		when :open
			@file_data = File.read(@file_name).split("\n")
			@fmode        = 'r+'
		when :new
			@file_data = [header]
			@fmode        = 'w+'
		end
		yield self if block_given?
	end

	def bin_dir
		WindowsFile.join(File.dirname(@ruby_exe))
	end

	def header
		string =  "@ECHO OFF\n\n" 
		string << "::  This batch file generated by Pik, the\n"
		string << "::  Ruby Manager for Windows\n"	
	end	
	
	def ftype(files={ 'rbfile' => @ruby_exe, 'rbwfile' => @rubyw_exe })
		files.sort.each do |filetype, open_with|
			@file_data << 	"FTYPE #{filetype}=#{open_with} \"%1\" %*\n"
		end
		self
	end

	def call(bat)
		@file_data << "CALL #{bat}\n"
		self
	end

	def set(items)
		items.each{|k,v| 	@file_data << "SET #{k}=#{v}" }
		self
	end

	def echo(string)
		string = ' ' + string unless string == '.'
		@file_data << "ECHO#{string}"
	end
	
	def to_s
		@file_data.join("\n")
	end

	def write
		File.open(@file_name, @fmode){|f| f.puts self.to_s }
	end

end
