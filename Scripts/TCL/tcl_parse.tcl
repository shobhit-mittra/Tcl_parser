# TCL_Parser v1.0

# File handle for openning timing report [Note : File must be present in the same directory as the script!!]


set fOpen [open "timing_path.rpt" r]
set fOut [open "timing_path_summary.txt" w]

global start_path
global end_path
global inv_count
global buff_count
global logic_depth_count
global dp_delay
global slack

while { ![eof $fOpen] } {
	
      # Extracting a line from the report and storing it in 'line' variable
	gets $fOpen line
	
      # Extracting Startpoint		
	if { [regexp {Startpoint: (.*)} $line -> match] } {
		set start_path $match
	}
	
      # Extracting Endpoint
	if { [regexp {Endpoint: (.*)} $line -> match1] } {
		set end_path $match1
	}

      # Extracting INV/BUFF count
	if { [regexp {INV.} $line] } {
		incr inv_count
	}
	
	if { [regexp {BUFF.} $line] } {
		incr buff_count
	}

      # Extracting logic depth count
	if { [regexp {(?:^|\s)[rf](?=\s|$)} $line] } {
		# if { [regexp {\((.*)\)} $line] } {
			incr logic_depth_count
		# }
	}

      # Extracting Data-Path Delay
	if { [regexp {data arrival time\s*-?(\d+\.\d+)} $line -> match2] } {
		set dp_delay $match2
	}

      # Extracting Slack
	if { [regexp {slack.*\s*(-+\d+\.\d+)} $line -> match3] } {
		set slack $match3
	}	
	
}

puts $fOut \
"Timing Summary for the report
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Startpoint is : $start_path \
\nEndpoint is : $end_path     \
\nNumber of Buffers and Inverters used are : $buff_count Buffers, $inv_count Inverters	\
\nLogic Depth b/w the startpoint and endpoint is : $logic_depth_count	\
\nThe Data-Path delay is : $dp_delay ns	\
\nSlack on the path is reported as : $slack ns"


close $fOpen
close $fOut


