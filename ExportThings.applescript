# ExportThings - for exporting Things database as markdown files 
# Somewhat based on https://github.com/hhje22/ExportThings
#
# Tested with Things 2.8 and OS X High Sierra
#

on trimLine(this_text, trim_chars, trim_indicator)
	set x to the length of the trim_chars
	if the trim_indicator is in {0, 2} then
		repeat while this_text begins with the trim_chars
			try
				set this_text to characters (x + 1) thru -1 of this_text as string
			on error
				return ""
			end try
		end repeat
	end if
	if the trim_indicator is in {1, 2} then
		repeat while this_text ends with the trim_chars
			try
				set this_text to characters 1 thru -(x + 1) of this_text as string
			on error
				return ""
			end try
		end repeat
	end if
	return this_text
end trimLine

on writeFile(toDo, theFile)
	tell application "Things"
		set tdName to the name of toDo
		set tdName to my trimLine(tdName as string, " ", 2)
		set tdStatus to the status of toDo
		set tdDueDate to the due date of toDo
		set tdNotes to the notes of toDo
		
		if tdStatus is completed then
			set xline to "* ~~" & tdName & "~~"
		else
			set xline to "* " & tdName
		end if
		write xline & linefeed to theFile
		
		if tdDueDate is not missing value then
			write "  Due: " & date string of tdDueDate & linefeed to theFile
		end if
		if tdNotes is not "" then
			repeat with noteParagraph in paragraphs of tdNotes
				write "    * " & noteParagraph & linefeed to theFile
			end repeat
		end if
	end tell
end writeFile

tell application "Things" to activate

tell application "Things"
	
	log completed now
	empty trash
	
	set theFilePath to (path to desktop as Unicode text) & "_Things Backup.md"
	set theFile to (open for access file theFilePath with write permission)
	set eof of theFile to 0
	
	set theList to {"Inbox", "Today", "Scheduled", "Someday", "Projects"}
	
	repeat with theListItem in theList
		
		write "# " & theListItem & linefeed & linefeed to theFile
		
		set toDos to to dos of list theListItem
		repeat with toDo in toDos
			my writeFile(toDo, theFile)
			
			# Special case for Projects, we get the tasks for each project.
			if (theListItem as string = "Projects") then
				set tdProject to the name of toDo
				set prToDos to to dos of project tdProject
				
				set theProjectPath to (path to desktop as Unicode text) & tdProject & ".md"
				set theProjectFile to (open for access file theProjectPath with write permission)
				set eof of theProjectFile to 0
				
				write "# " & tdProject & linefeed & linefeed to theProjectFile
				repeat with prToDo in prToDos
					my writeFile(prToDo, theProjectFile)
				end repeat
				
				close access theProjectFile
			end if
			
		end repeat
		
	end repeat
	
	write "# Tags" & linefeed & linefeed to theFile
	repeat with aTag in tags
		write "* " & name of aTag & linefeed to theFile
	end repeat
	
	close access theFile
	
end tell
