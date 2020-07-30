# This script is distributed under the GNU General Public License.
# George Moroz 01.03.2019
# The last vertion of this script is here: https://raw.githubusercontent.com/agricolamz/from_sound_to_html_viewer/master/extract_sound_and_picture.praat

form Get spectrum and waveform from 
  comment List tiers (space-separated) from which to take intervals (empty=all)
  sentence tier_name_list Word Stimulus
  comment Where should the script write a result sound files?
  comment don't forget the final slash; on Windows change your backslashes to slashes
  text directory_sound sound/
  comment Where should the script write a result picture files?
  comment don't forget the final slash; on Windows change your backslashes to slashes
  text directory_picture picture/
  comment What is the maximum formant value for your pictures (Hz)?
  positive max_frequency 10000
  comment What is the dynamic range value for your pictures (Db)?
  positive dynamic_range 55
endform

n = numberOfSelected()
for j to n
	files[j] = selected(j)
endfor
object_name$ = selected$ ("Sound")
select TextGrid 'object_name$'
number_of_tiers = Get number of tiers

str = Create Strings as tokens: tier_name_list$, " "
Sort
tl = To WordList

for tier_n to number_of_tiers
	select TextGrid 'object_name$'
	tn$ = Get tier name: tier_n
	select tl
	todo = Has word: tn$
	if todo or tier_name_list$=""
		select TextGrid 'object_name$'
		for j to n
			plusObject: files[j]
		endfor
		@plot_and_extract: directory_sound$, directory_picture$, tier_n
	endif
endfor

select tl
plusObject: str
Remove
select TextGrid 'object_name$'
for j to n
	plusObject: files[j]
endfor

procedure plot_and_extract directory_s$, directory_p$, tier_number
	n = numberOfSelected()
	for j to n
		files[j] = selected(j)
	endfor
	object_name$ = selected$ ("Sound")
	select TextGrid 'object_name$'
	number_of_intervals = Count intervals where: tier_number, "is not equal to", ""
	name_of_tier$ = Get tier name: tier_number
	for k to number_of_intervals
		labels$[k] = Get label of interval: 'tier_number', k*2
		labels$[k] = replace_regex$(labels$[k],"[#_\? ]","-",0)
		labels$[k] = replace$(labels$[k],"*","+",0)
	endfor
	for j to n
		plusObject: files[j]
	endfor
	Extract non-empty intervals: tier_number, "yes"
	for b to number_of_intervals
		extracted[b] = selected("Sound", b)
	endfor
	for id to number_of_intervals
        id$ = string$ (id)
		selectObject: extracted[id]
		Save as WAV file: directory_s$ + object_name$ + "_" + name_of_tier$ + "_" + labels$[id] + "_" + id$ + ".wav"
		To Spectrogram: 0.005, max_frequency, 0.002, 20, "Gaussian"
		Select outer viewport: 0, 6, 1.5, 6
		Paint: 0, 0, 0, 0, 100, "yes", dynamic_range, 6, 0, "yes"
		Marks left every: 1, 1000, "yes", "yes", "no"
		Remove
		selectObject: extracted[id]
		Convert to mono
		Select outer viewport: 0, 6, 0, 2
		Draw: 0, 0, 0, 0, "yes", "Curve"
		Select outer viewport: 0, 6, 0, 6
		Text top: "yes", object_name$ + " " + name_of_tier$ + " " + labels$[id]+"_" + id$
		Save as 300-dpi PNG file: directory_p$ + object_name$ + "_" + name_of_tier$ + "_" + labels$[id]+ "_" + id$ + ".png"
		Erase all
		plusObject: extracted[id]
		Remove
	endfor
endproc
