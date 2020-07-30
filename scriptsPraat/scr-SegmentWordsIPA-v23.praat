#v2.3
#added digraphs

#v2.2
#enhanced modifiers -- Unicode range + user list

#v2.1
#fixed filter_out

form Specify the following parameters
	natural Word_tier 1
#for Archi: qχ kɬ
	sentence Digraph_list qχ kɬ
#for Archi: '‘’Ӏӏ
	word Modifier_list '‘’
#for Alutor: #-⁻
	word Filter_out #-
endform

numintw = Get number of intervals... word_tier
numtiers = Get number of tiers
numtiers = numtiers+1
Insert interval tier... numtiers Phones

prev_int = 0

for i to numintw
	word$ = Get label of interval... word_tier i
	if word$ <> ""
		call lengthIPA
#NOTE access to global variables:
#puts the length of *word$* excluding any of *modifier_list* into *numlet*
		t0 = Get start point... word_tier i
		t1 = Get end point... word_tier i
		timestep = (t1-t0)/numlet
		for j to numlet
			time[j] = t0 + timestep*j
		endfor
		time[numlet]=t1

		numintl = Get number of intervals... numtiers

		if i=1 or prev_int < i-1
			Insert boundary... numtiers t0
		else
			numintl = numintl-1
		endif
#check if previous word was adjacent interval
#if yes then don't insert first boundary and count one interval less

		for j to numlet
			hip = time[j]
			hop$ = letter$[j]
			Insert boundary... numtiers hip
			Set interval text... numtiers numintl+j 'hop$'
		endfor

		prev_int = i
#will need end of previous word to avoid putting a new boundary there
	endif
endfor

procedure lengthIPA
	numlet=0
	for jj to length(word$)
		.ch$ = mid$(word$,jj)
		@isModifier (.ch$)
		@isDigraph (mid$(word$,jj-1,2))
		if index(filter_out$, .ch$)=0 
			if jj=1 or (isModifier.result=0 and isDigraph.result=0)
				numlet = numlet+1
				letter$[numlet] = .ch$
			else
				letter$[numlet] = letter$[numlet] + .ch$
			endif
		endif
	endfor
endproc

procedure isDigraph (.string$)
	if length(.string$)>1 and index(digraph_list$, .string$)<>0
		.result = 1
	else
		.result = 0
	endif
endproc

procedure isModifier (.char$)
#02B0--036F (space modifiers + combining diacritics)
	if (.char$ <= "ͯ" and .char$ >= "ʰ") or (index(modifier_list$, .char$)<>0)
		.result = 1
	else
		.result = 0
	endif
endproc