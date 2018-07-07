### 	You must have both the Sound 
###	and the TextGrid already open!

form Vowel start and File name
	positive Time
	positive VowelID
	sentence Filename archi-sample
	comment You must have both the Sound 
	comment and the TextGrid already open!
endform

###This could be used unless the files were opened each time anew
#wavname$ = filepath$ + filename$ + ".wav"
#tgname$ = filepath$ + filename$ + ".TextGrid"
#s = Read from file: wavname$
#tg = Read from file: tgname$

wavname$ = "Sound " + filename$
tgname$ = "TextGrid " + filename$ 
selectObject: wavname$
s = selected ("Sound")
selectObject: tgname$
tg = selected ("TextGrid")

intnum = Get interval at time: 1, time
intstart = Get start point: 1, intnum
intend = Get end point: 1, intnum
phonenum = Get interval at time: 2, time+0.001
phonelabel$ = Get label of interval: 2, phonenum

plusObject: s
#View & Edit
editor: tg
	Select: intstart, intend
	Zoom to selection
	Extract selected TextGrid (preserve times)
endeditor
tgextr = selected ("TextGrid")
#If we don't rename the extracted TG the next query to the same sound file/TG will fail

Rename: "vow_"+string$(vowelID)+"_at_"+fixed$(intstart,3)+"_with_"+phonelabel$

###If many editors are open they take too much memory
#plusObject: s
#View & Edit
#editor: tgextr
#	Move cursor to: time
#endeditor
