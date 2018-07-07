# Plot formants with points and ellipses

title$ = selected$("Table") 

form Form
	natural Picture_width 9
	natural Picture_height 6
	natural left_F1_Range 200
	natural right_F1_Range 950
	natural left_F2_Range 500
	natural right_F2_Range 2700
	natural left_F3_Range 2000
	natural right_F3_Range 3750
	natural Sigmas 2
	optionmenu Point_column: 1
		option vowel
		option phone
		option phone_ctx
	optionmenu Ellipse_column: 1
		option vowel
		option phone
		option phone_ctx
endform

#	natural Picture_width 9
#	natural Picture_height 6

#all vowels
#	natural left_F1_Range 200
#	natural right_F1_Range 900
#	natural left_F2_Range 500
#	natural right_F2_Range 2700
#	natural left_F3_Range 2000
#	natural right_F3_Range 3750

#front-close quadrant
#	natural left_F1_Range 200
#	natural right_F1_Range 600
#	natural left_F2_Range 1500
#	natural right_F2_Range 2700
#	natural left_F3_Range 2250
#	natural right_F3_Range 3750

#	word Point_column phone_ctx

Erase all
Line width: 1
Select outer viewport: 0, picture_width, 0, picture_height
Grey
Text top: "yes", title$
Scatter plot: "F2", right_F2_Range, left_F2_Range, "F1", right_F1_Range, left_F1_Range, point_column$, 12, "yes"
Black
Line width: 1.5
Draw ellipses where: "F2", right_F2_Range, left_F2_Range, "F1", right_F1_Range, left_F1_Range, ellipse_column$, sigmas, 20, "no", "1"
Line width: 1
Marks left every: 1, 100, "yes", "yes", "no"
Marks bottom every: 1, 250, "yes", "yes", "no"

Select outer viewport: 0, picture_width, picture_height, picture_height*2
Grey
Scatter plot: "F2", right_F2_Range, left_F2_Range, "F3", left_F3_Range, right_F3_Range, point_column$, 12, "yes"
Black
Line width: 1.5
Draw ellipses where: "F2", right_F2_Range, left_F2_Range, "F3", left_F3_Range, right_F3_Range, ellipse_column$, sigmas, 20, "no", "2"
Line width: 1
Marks left every: 1, 250, "yes", "yes", "no"
Marks bottom every: 1, 250, "yes", "yes", "no"

Select outer viewport: 0, picture_width, 0, picture_height*2
