# TCL_Parser v1.1

# File handle for openning timing report [Note : TCL_Parse shell script  must be present in the same directory as it's TCL  script!!]
set filename [lindex $argv 0]
set outfile "timing_rpt_summary.txt"
set fOpen [open $filename r]
set fOut [open $outfile w]

# Time unit as per the Liberty (.lib) used
set time_unit "ns"

# Dictionary containing alphabetic non-recurring patterns for info extraction 
set patterns {
	{Startpoint: (.*)} "Startpoint Path"			
	{Endpoint: (.*)} "Endpoint Path"	
	{data arrival time\s*-?(\d+\.\d+)} "Data Path Delay(in ns)"	
	{slack.*\s*(-+\d+\.\d+)} "Slack(in ns)"		
}

# Dictionary containing non-alphabetic recurring patterns for info extraction 
set num_patterns {
	{INV.} "Inverter count"	
	{BUFF.}	"Buffer count"	
	{(?:^|\s)[rf](?=\s|$)} "Logic depth count"	
}

# Creating an empty dictionary to store incremental numeric elements
set countDict [dict create]
global countDict

# Dynamically populating the count dictionary
foreach {pattern description} $num_patterns {
	# Creating a key for the dictionary
	 set key "$description"
	# Initialise the key value as zero     
	 dict set countDict $key 0	; # Imp : Note here name of the dictionary is used since it's an empty dictionary as of this command		
}

# Creating an empty dictionary for storing static non-incremental elements
set extr_info [dict create]
global extr_info

while { ![eof $fOpen] } {

      # Extracting a line from the report and storing it in 'line' variable
	gets $fOpen line
	
      # Itterating through the patterns dictionary 
	foreach {pattern description} $patterns { 
		if { [regexp "$pattern" $line -> match] } {
		#	lappend extr_info [list "$description" "$match"]
			dict set extr_info $description $match
		  # Break out of the loop as soon as pattern is detected and stored			
			break
		}
	}

	# Itterating through the num_patterns dictionary 
	foreach {pattern key} $num_patterns { 
		if { [regexp "$pattern" $line -> match] } {
			dict incr countDict $key 			
		}
	}
}

# Merging the 2 global dictionaries
set merge_dict [dict merge $extr_info $countDict]

# Dumping out the results into timing_rpt_summary.txt
puts $fOut "---------------------Timing report summary created at : [clock format [file mtime $outfile] -format "%d-%m-%Y %H:%M:%S"]---------------------"
foreach key [dict keys $merge_dict] {
	set value [dict get $merge_dict $key]
	puts $fOut "$key is : $value"
}

close $fOpen
close $fOut

