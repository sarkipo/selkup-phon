#v2.7 fixed error in calculations with F3; fixed error if 1 token; sound filename saved in table;
#++++ separate calculations for +/- phar AND +/- stress; U+0301 (grave) counted as stress
#v2.6 F1+F2+F3, front vowels have higher ceiling range (+1kHz) and mid vowels, +0.5 kHz
#++++ ceiling range 1 kHz for each vowel instead of 2 kHz
#v2.3 Calculates best ceiling for F2+F3 instead of F1+F2

t = selected("TextGrid")
s = selected("Sound")
s$ = selected$("Sound") 
#сохраняем имя файла, положим в таблицу

select t
form Specify the following parameters
	word Speaker PSX
	natural Vowel_tier 2
	sentence Vowel_list_(with_spaces) i e a o u ə ɪ ɐ
	optionmenu Search_criteria: 3
		option is equal to
		option is not equal to
		option starts with
		option ends with
		option contains
		option does not contain
		option matches (regex)
	natural Min_ceiling_(for_F5) 4000
	boolean Draw_picture yes
	boolean Overwrite_file yes
endform

#Archi = i í e é a á o ó u ú ə ˤ
#i e a o u ə ɪ ɐ ɵ ʊ ᵊ
#mylist1 = i0 i1 i2 e0 e1 e2 a0 a1 a2 o0 o1 o2 u0 u1 u2
#сколько гласных будем искать в разметке

a$ = replace_regex$(replace_regex$(vowel_list$,"\s+"," ",0),"(^ | $)","",0)

i = 1
while a$<>"" 
	len = length(a$)
	wordlen = index(a$," ")
	if wordlen > 1 
		wordlen = wordlen-1
		vowel$[i] = left$(a$,wordlen)
		a$ = right$(a$,len-wordlen-1)
	else
		vowel$[i] = a$
		a$ = ""
	endif

	v$ = vowel$[i]
	i = i+1
endwhile
vowel_num = i-1
#какие гласные надо искать в разметке (и сколько их)


tb_phones = 0 		
tb_phones_sum = 0	
#указатели на будущие таблицы


@get_all_phones: vowel_tier, "matches (regex)", "^[ieaouəɪɐɵʊᵊ]"
#вытащить все фоны (гласная = первая буква в транскрипции фона)

#for i to vowel_num
#	@get_all_phones: vowel_tier, vowel$[i]
#endfor


defaultfilename$ = "formants.txt"
outfilename$ = chooseWriteFile$ ("Write formants to text file...", defaultfilename$)
outfilename$ = if outfilename$ <> "" then outfilename$ else defaultfilename$ fi
if not fileReadable (outfilename$)
	writeFileLine: outfilename$, "speaker",tab$, "vowel",tab$, "phone",tab$, "time",tab$, "duration",tab$, "F1",tab$, "F2",tab$, "F3",tab$, "ceiling",tab$, "F1Bk",tab$, "F2Bk",tab$, "F3Bk",tab$, "filename"
elsif overwrite_file = 1
	writeFileLine: outfilename$, "speaker",tab$, "vowel",tab$, "phone",tab$, "time",tab$, "duration",tab$, "F1",tab$, "F2",tab$, "F3",tab$, "ceiling",tab$, "F1Bk",tab$, "F2Bk",tab$, "F3Bk",tab$, "filename"
endif
#запрашиваем имя файла для записи формант


str$ = "[́̀]"		;stress char
nsph$ = "[^ˤ́̀]"		;neither stress nor phar char

for i to vowel_num
	#считаем отдельно для комбинаций +/-фаринг. и +/-удар.
	pharstresscond$[1]= "^"+vowel$[i]+nsph$+"*"+str$+nsph$+"*$"	; +stress -phar
	pharstresscond$[2]= "^"+vowel$[i]+".*"+str$+".*ˤ.*$"		; +stress +phar
	pharstresscond$[3]= "^"+vowel$[i]+nsph$+"*$"			; -stress -phar
	pharstresscond$[4]= "^"+vowel$[i]+nsph$+"*ˤ"+nsph$+"*$"		; -stress +phar
	for c to 4
		select tb_phones_sum
		row = Search column: "vowel", vowel$[i]+(if c=1 or c=2 then "́" else "" fi)
			...+(if c=2 or c=4 then "ˤ" else "" fi)
		if row > 0
			tokens = Get value: row, "count"
			if tokens > 0
				select t
				plus s
			#перебираем комбинации условий
				Extract intervals where: vowel_tier, "yes", "matches (regex)", pharstresscond$[c]
			###Для гласных разного ряда повышаем порог
				if index_regex(vowel$[i],"^[ieɪ]")>0
					the_ceiling = min_ceiling + 1000
				elsif index_regex(vowel$[i],"^[aɐ]")>0
					the_ceiling = min_ceiling + 500
				else
					the_ceiling = min_ceiling
				endif
				@getformants20: tokens, vowel$[i], vowel_tier, the_ceiling
			endif
		endif
	endfor
endfor
#считаем форманты


if draw_picture = 1
	tb = Read Table from tab-separated file: outfilename$
	#считываем результаты из текстового файла в таблицу

	runScript: "scr-Formants20-plots-v21.praat"
	#рисуем картинки
endif

select s
plus t
#вернуть выделенные файлы




########
########
########

procedure get_all_phones .tier .search_criteria$ .vowels$
	select t
	Extract one tier: .tier
	tg_tmp = selected ("TextGrid")
	tb_tmp_1 = Down to Table: "no", 2, "no", "no"
	Sort rows: "text"
	tb_tmp_2 = Extract rows where column (text): "text", .search_criteria$, .vowels$
###	Extract rows where column (text): "text", "matches (regex)", "^[aeiouə]"
### ONLY WORKS FOR SPECIFIED REGEX: ALL VOWELS INCL. SCHWA AS FIRST LETTER OF THE PHONE

	Append column: "count"
	Formula: "count", "1"
	tb_phones = Collapse rows: "text", "count", "", "", "", ""

	Append column: "vowel"
#distinguish +/- stressed, +/- pharyngzd
	Formula: "vowel", "left$(self$[row,1],1) 
		...+ (if index(self$[row,1],""́"")>0 or index(self$[row,1],""̀"")>0 then ""́"" else """" fi)
		...+ (if index(self$[row,1],""ˤ"")>0 then ""ˤ"" else """" fi)"
	tb_phones_sum = Collapse rows: "vowel", "count", "", "", "", ""

	select tg_tmp
	Remove
endproc



procedure getformants20 .filenum .vowel$ .tier .min_ceiling
#.filenum	Количество звукфайлов
#.vowel$	Символ для гласного, который будет вписан в таблицу
#.phone$	Полная транскрипция фона (тоже впишем в таблицу)
#.tier		Слой, откуда берём транскрипцию
#.min_ceiling	Минимальный потолок для F5

for k to .filenum
	sound[k] = selected ("Sound", k)
endfor

n = .filenum
#Количество звукфайлов

min = 1000000000000 
# Техническая переменная для измерения минимума



for j from 0 to 20
   ceiling = .min_ceiling + 50*j 
# ADULT WOMEN
   for k to n
      select sound[k]
      t1 = Get start time
      t2 = Get end time
# 40% ANALYSIS WINDOW
      tdur = t2-t1
      t1 = t1+0.3*tdur
      t2 = t2-0.3*tdur
      noprogress To Formant (burg)... 0.0 5 ceiling 0.025 50
      formant = selected ("Formant")
      select formant
      f1[k] = Get mean... 1 t1 t2 Hertz
      f2[k] = Get mean... 2 t1 t2 Hertz
      f3[k] = Get mean... 3 t1 t2 Hertz
      f1b[k] = Get mean... 1 t1 t2 Bark
      f2b[k] = Get mean... 2 t1 t2 Bark
      f3b[k] = Get mean... 3 t1 t2 Bark
      Remove
   endfor

   mf1 = 0 
# Выборочное среднее первой форманты
   mf2 = 0 
# Выборочное среднее второй форманты
   mf3 = 0 
   vf1 = 0 
# Исправленная выборочная дисперсия первой форманты
   vf2 = 0 
# Исправленная выборочная дисперсия второй форманты
   vf3 = 0 
   sum1 = 0
   sum2 = 0
   sum3 = 0
   sumsqr1 = 0
   sumsqr2 = 0
   sumsqr3 = 0

   for k to n
      sum1 = sum1 + f1b[k]
      sum2 = sum2 + f2b[k]
      sum3 = sum3 + f3b[k]
      sumsqr1 = sumsqr1 + f1b[k]^2
      sumsqr2 = sumsqr2 + f2b[k]^2
      sumsqr3 = sumsqr3 + f3b[k]^2
   endfor

   mf1 = sum1/n
   mf2 = sum2/n
   mf3 = sum3/n
   vf1 = if n>1 then (sumsqr1 - sum1*mf1)/(n - 1) else 0 fi
   vf2 = if n>1 then (sumsqr2 - sum2*mf2)/(n - 1) else 0 fi
   vf3 = if n>1 then (sumsqr3 - sum3*mf3)/(n - 1) else 0 fi
   
   if vf1 + vf2 + vf3 < min 
# Запись результатов с минимальной суммой дисперсий
      for k to n
         result_f1[k] = f1[k]
         result_f2[k] = f2[k]
         result_f3[k] = f3[k]
         result_f1b[k] = f1b[k]
         result_f2b[k] = f2b[k]
         result_f3b[k] = f3b[k]
      endfor
      result_ceiling = ceiling 
# Запись оптимального "потолка" изм-ий
      min = vf1 + vf2 + vf3
   endif
endfor

for k to n
   select sound[k]
   .start_time = Get start time
   .duration = Get total duration
   select t
   .int = Get high interval at time: .tier, .start_time
   .phone$ = Get label of interval: .tier, .int
   appendFileLine: outfilename$, speaker$,tab$, .vowel$,tab$, .phone$,tab$, fixed$(.start_time,3),tab$, 
	... fixed$(.duration,3),tab$, fixed$(result_f1[k],0),tab$, fixed$(result_f2[k],0),tab$, fixed$(result_f3[k],0),tab$, result_ceiling,tab$,
	... fixed$(result_f1b[k],2),tab$, fixed$(result_f2b[k],2),tab$, fixed$(result_f3b[k],2),tab$, s$
endfor


select sound[1]
if .filenum > 1
	for k from 2 to .filenum
		plus sound[k]
	endfor
endif
Remove
#Remove analysed vowels

endproc



########
########
########
