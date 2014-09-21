
tell OmnifocusTask
	set ot to OmnifocusTask
	SyncEvernote() of ot
end tell

script OmnifocusTask
	
	property completedTagName : "didFinishAddTask" as text
	
	on SyncEvernote()
		
		set r to findReminderNote("-tag:" & completedTagName)
		createTaskFromNotes(r, {completedTagName})
		
		set t to findToDoNote("-tag:" & completedTagName)
		createTaskFromNotes(t, {completedTagName})
		
	end SyncEvernote
	
	on createTaskFromNotes(ennotes, tagnames)
		
		if (not (ennotes is missing value)) then
			
			if class of ennotes = class of {} then
				
			else
				ennotes = {ennotes}
				
			end if
			
			if length of ennotes > 0 then
				createOmnifocusToDoFromNotes(ennotes)
				addTagsToNotes(ennotes, tagnames)
			end if
			
		end if
		
	end createTaskFromNotes
	
	-- リマインダーが終わっていないノートを探す	
	-- andFilter is additional search words.
	on findReminderNote(andFilter)
		
		set filteredNotes to findENNotes("reminderOrder:* -reminderDoneTime:* " & andFilter)
		return filteredNotes
		
	end findReminderNote
	
	-- ToDoが終わっていないノートを探す
	-- andFilter is additional search words.
	on findToDoNote(andFilter)
		
		set filteredNotes to findENNotes("todo:false -todo:true " & andFilter)
		
		return filteredNotes
		
	end findToDoNote
	
	on findENNotes(filter)
		
		try
			tell application "Evernote"
				
				set filteredNotes to find notes filter
				return filteredNotes
				
			end tell
			
		on error
			
			return {}
			
		end try
		
	end findENNotes
	
	-- ennotes is ENNote List. tagStrList is Tag name list.
	-- Add tag to note.
	on addTagsToNotes(ennotes, tagStrList)
		
		tell application "Evernote"
			
			if length of tagStrList > 0 then
				
				set tagList to {}
				repeat with t in tagStrList
					
					if (not (tag named t exists)) then
						make tag with properties {name:t}
					end if
					
					set the end of tagList to tag t
					
				end repeat
				
				assign tagList to ennotes
				
			end if
			
		end tell
		
	end addTagsToNotes
	
	
	on createOmnifocusToDoFromNotes(ennotes)
		
		repeat with n in ennotes
			
			tell application "Evernote"
				
				set t to title of n
				set h to HTML content of n
				set s to current date
				set e to reminder time of n
				
			end tell
			
			createOmnifocusToDo(t, h, s, e, false)
			
		end repeat
		
	end createOmnifocusToDoFromNotes
	
	on createOmnifocusToDo(taskName, taskNote, startDate, endDate, flags)
		
		if (startDate is missing value) then
			set startDate to current date
		end if
		
		if (endDate is missing value) then
			set endDate to current date
		end if
		
		tell application "OmniFocus"
			tell default document
				
				set t to make new inbox task with properties {name:taskName, note:taskNote, defer date:startDate, creation date:current date, due date:endDate, flagged:flags}
				
			end tell
		end tell
		
	end createOmnifocusToDo
	
end script



