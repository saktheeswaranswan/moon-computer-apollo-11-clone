# Copyright:	Public domain.
# Filename:	JET_SELECTION_LOGIC.agc
# Purpose:	Part of the source code for Colossus 2A, AKA Comanche 055.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	1039-1062
# Mod history:	2009-05-13 RSB	Adapted from the Colossus249/ file of the
#				same name, using Comanche055 page images.
#
# This source code has been transcribed or otherwise adapted from digitized
# images of a hardcopy from the MIT Museum.  The digitization was performed
# by Paul Fjeld, and arranged for by Deborah Douglas of the Museum.  Many
# thanks to both.  The images (with suitable reduction in storage size and
# consequent reduction in image quality as well) are available online at
# www.ibiblio.org/apollo.  If for some reason you find that the images are
# illegible, contact me at info@sandroid.org about getting access to the 
# (much) higher-quality images which Paul actually created.
#
# Notations on the hardcopy document read, in part:
#
#	Assemble revision 055 of AGC program Comanche by NASA
#	2021113-051.  10:28 APR. 1, 1969  
#
#	This AGC program shall also be referred to as
#			Colossus 2A

# Page 1039
		BANK	21
		SETLOC	DAPS4
		BANK
		
		COUNT	17/DAPJS
		
		EBANK=	KMPAC
		
# EXAMINE CHANNEL 31 FOR TRANSLATION COMMANDS

JETSLECT	LXCH	BANKRUPT
		CAF	DELTATT3	# = 60 MS  RESET TO EXECUTIVE PHASE1
		AD	T5TIME
		TS	TIME5
		TCF	+3
		CAF	DELATT20	# = 20 MS  TO ASSURE A T5RUPT
		TS	TIME5
		CAF	=14MS		# RESET T6 TO INITIALIZE THE JET CHANNELS
		TS	TIME6		# IN 14 MS
		CAF	NEGMAX
		EXTEND
		WOR	CHAN13
		EXTEND
		QXCH	QRUPT
		CAF	XLNMASK		# = 7700 OCT
		EXTEND			# EXAMINE THE TRANSLATION
		RXOR	CHAN31		# HAND CONTROLLER
		MASK	XLNMASK
		EXTEND
		BZF	NOXLNCMD
		TS	T5TEMP
		EXTEND
		MP	BIT9
		MASK	THREE
		TS	XNDX1		# AC QUAD  X-TRANSLATION INDEX
		TS	XNDX2		# BD QUAD  X-TRANSLATION INDEX
		CA	T5TEMP
		EXTEND			# 1 = + XLN
		MP	BIT7		# 2 = - XLN
		MASK	THREE		# 3 = NO XLN
		TS	YNDX		# Y-TRANSLATION INDEX
		
		CA	T5TEMP
		EXTEND
		MP	BIT5
		MASK	THREE
		TS	ZNDX		# Z-TRANSLATION INDEX
		
		CA	DAPDATR1	# SET ATTKALMN TO PICK UP FILTER GAINS FOR
		MASK	BIT14		# TRANSLATIONS.
		EXTEND			# CHECK DAPDATR1 BIT 14 FOR LEM ATTACHED.
# Page 1040
		BZF	NOLEM
		CS	THREE		# IF LEM IS ON, SET ATTKALMN = -3
		TCF	+2
NOLEM		CS	TWO		# IF LEM IS OFF, SET ATTKALMN = -2.
		TS	ATTKALMN
		CCS	XTRANS		# (+, -1, 0)
		TS	XNDX1		# USING BD-X  ZERO XNDX1
		TCF	PWORD
		TS	XNDX2		# USING AC-X  ZERO XNDX2
		TCF	PWORD
XLNMASK		OCT	7700

DELTATT3	DEC	16378		# = 60 MS
DELATT20	DEC	16382		# = 20 MS

NOXLNCMD	TS	XNDX1		# ZERO ALL REQUESTS FOR TRANSLATION
		TS	XNDX2
		TS	YNDX
		TS	ZNDX
		
# PITCH COMMANDS  TIMING(NO X-TRANS, NO QUAD FAILS) 32MCT

PWORD		CCS	TAU1		# CHECK FOR PITCH COMMANDS
		CAF	ONE
		TCF	+2		#  0 = NO PITCH
		CAF	TWO		# +1 =  + PITCH
		TS	PINDEX		# +2 =  - PITCH
		
		CCS	RACFAIL		# FLAG FOR REAL AC QUAD FAILURES
		TCF	AFAILP
		TCF	TABPCOM		# 0 = NO REAL AC FAILURES
		TCF	CFAILP		# + = A QUAD FAILED
		TCF	TABPCOM		# - = C QUAD FAILED
					# IF FAILURES ARE PRESENT IGNORE
					# X-TRANSLATIONS ON THIS AXIS
					
AFAILP		CAF	NINE		# IF FAILURE IS PRESENT 1JET OPERATION
		TCF	TABPCOM +2	# IS ASSUMED.  IGNORE X-TRANSLATION
CFAILP		CAF	TWELVE
		TCF	TABPCOM +2
		
XLNNDX		DEC	0		# INDICES FOR TRANSLATION COMMANDS
		DEC	3		# FOR USE IN TABLE LOOK UP
		DEC	6
		DEC	0
		
TWELVE		=	OCT14

# TABLE LOOK UP FOR PITCH COMMANDS WITH AND WITHOUT X-TRANSLATION AND AC QUAD FAILURES PRESENT.
# BITS 9, 10 CONTAIN THE NUMBER OF PITCH JETS USED TO PERFORM THE PITCH ROTATION
# Page 1041

TABPCOM		INDEX	XNDX1
		CA	XLNNDX
		AD	PINDEX
		INDEX	A
		CA	PYTABLE
		MASK	PJETS		# =1417 OCT
		TS	PWORD1
		EXTEND
		MP	BIT7
		TS	NPJETS		# = NO. OF PITCH JETS
		
# YAW JET COMMANDS  TIMING(N X-TRANS, NO QUAD FAILURES)  32MCT

YWORD		CCS	TAU2		# CHECK FOR YAW COMMANDS
		CAF	ONE
		TCF	+2
		CAF	TWO
		TS	YINDEX		# YAW ROTATION INDEX
		
		CCS	RBDFAIL		# FLAG FOR B OR D QUAD FAILURES
		TCF	BFAILY		# 0 = NO BD FAILURE
		TCF	TABYCOM		# + - B QUAD FAILED
		TCF	DFAILY		# - = D QUAD FAILED
		TCF	TABYCOM
		
BFAILY		CAF	NINE
		TCF	TABYCOM +2
DFAILY		CAF	TWELVE
		TCF	TABYCOM +2
		
# Page 1042
# TABLE FOR PITCH(YAW) COMMANDS
# BITS 4,3,2,1 = PITCH, X-TRANSLATION JETS SELECTED
# BITS    10,9 = NO. PITCH JETS USED TO PERFORM ROTATION
# BITS 8,7,6,5 = YAW, X-TRANSLATION JETS SELECTED
# BITS 12,11:  NO. YAW JETS USED TO PERFORM ROTATION

					# ROT	TRANS	QUAD	BIAS
PYTABLE		OCT	0		# 0	0		0
		OCT	5125		# +	0		0
		OCT	5252		# -	0		0
		OCT	0231		# 0	+		3
		OCT	2421		# +	+		3
		OCT	2610		# -	+		3
		OCT	0146		# 0	-		6
		OCT	2504		# + 	-		6
		OCT	2442		# -	-		6
		OCT	0		# 0		A(B)	9
		OCT	2421		# +		A(B)	9
		OCT	2442		# -		A(B)	9
		OCT	0		# 0		C(D)	12
		OCT	2504		# +		C(D)	12
		OCT	2610		# -		C(D)	12
		
# MASKS FOR PITCH AND YAW COMMANDS

PJETS		OCT	1417
YJETS		OCT	6360

# TABLE LOOK UP FOR YAW COMMANDS WITH AND WITHOUT X-TRANSLATION AND AC QUAD FAILURES PRESENT
# BITS 11, 12 CONTAIN THE NUMBER OF YAW JETS USED TO PERFORM THE YAW ROTATION

TABYCOM		INDEX	XNDX2
		CA	XLNNDX
		AD	YINDEX
		INDEX	A
		CA	PYTABLE
		MASK	YJETS		# = 6360 OCT
		TS	YWORD1
		EXTEND
		MP	BIT5
		TS	NYJETS		# NO. OF YAW JETS USED TO PERFORM ROTATION

# Page 1043
# ROLL COMMANDS  TIMING(NO Y,Z TRANS, NO QUAD FAILS)  45MCT

RWORD		CCS	TAU		# CHECK FOR ROLL COMMANDS
		CAF	ONE
		TCF	+2
		CAF	TWO
		TS	RINDEX
		
		CCS	ACORBD		# FLAG FOR AC OR BD QUAD SELECTION FOR
		TCF	BDROLL		# ROLL COMMANDS
		TCF	BDROLL		# +, +0 = BD ROLL
		TCF	+1		# -, -0 = AC ROLL
		
ACROLL		CCS	RACFAIL		# CHECK FOR REAL FAILURES
		TCF	RAFAIL		# ON AC QUADS
		TCF	RXLNS
		TCF	RCFAIL
		TCF	RXLNS
		
RAFAIL		CAF	NINE		# QUAD FAILURE WILL GET
		TCF	TABRCOM		# 1-JET OPERATION
RCFAIL		CAF	TWELVE
		TCF	TABRCOM
		
XLN1NDX		DEC	0
		DEC	1		# INDICES FOR TRANSLATION
		DEC	2
		DEC	0
		
# TABLE LOOK UP FOR AC-ROLL COMMANDS WITH AND WITHOUT Y-TRANSLATION AND ACQUAD FAILURES PRESENT
# BITS 9,10,11 CONTAIN THE MAGNITUDE AND DIRECTION OF THE ROLL

RXLNS		INDEX	YNDX		# NO AC QUAD FAILURES
		CA	XLNNDX		# INCLUDE +,-,0, Y-TRANSLATION
TABRCOM		AD	RINDEX
		INDEX	A
		CA	RTABLE
		MASK	ACRJETS		# = 3760 OCT
		TS	RWORD1
		
# CHECK FOR Z-TRANSLATIONS ON BD

BDZCHECK	CA	ZNDX
		EXTEND
		BZMF	NOBDZ		# NO Z-TRANSLATION
		
# Page 1044
# TABLE LOOK UP FOR BD Z-TRANSLATION WITH AND WITHOUT REAL BD QUAD FAILURES.  Z-TRANSLATION WILL BE POSS-
# IBLE AS LONG AS ROLL COMMANDS CAN BE SATISFIED WITH THE AC ROLL JETS.  CRITERION:  IF THE RESULTANT NET ROLL
# COMMANDS = 0 (WITH Z-TRANSLATION) AND IF TAU = 0, THEN INCLUDE THE BD Z-TRANSLATION COMMANDS.  IF THE RESULTANT
# ROLL COMMAND = 0, AND IF TAU NZ, THEN IGNORE THE BD Z-TRANSLATION

		CCS	RBDFAIL
		CAF	THREE
		TCF	+2
		CAF	SIX
		INDEX	ZNDX
		AD	XLN1NDX
		INDEX	A
		CA	YZTABLE
		MASK	BDZJETS		# = 3417 OCT
		AD	RWORD1		# ADD TO ROLL COMMANDS
		TS	T5TEMP		# IF POSSIBLE.  MUST CHECK TAU FIRST
		
		EXTEND
		MP	BIT7		# DETERMINE THE NET ROLL COMMAND WITH
		AD	=-4		# Z-TRANSLATION ADDED ON
		TS	NRJETS		# NET NO. OF +,- ROLL JETS ON
		EXTEND
		BZF	TAUCHECK
		
ACRBDZ		CA	T5TEMP		# Z-TRANSLATION ACCEPTED EVEN THOUGH WE MAY
		TS	RWORD1		# HAVE INTRODUCED AN UNDESIREABLE ROLL
		TCF	ROLLTIME	# BRANCH TO JET ON-TIME CALCULATIONS
		
TAUCHECK	CCS	TAU
		TCF	NOBDZ
		TCF	ACRBDZ
		TCF	NOBDZ
		TCF	ACRBDZ
		
NOBDZ		CA	RWORD1		# Z-TRANSLATION NOT ACCEPTED
		EXTEND
		MP	BIT7
		AD	=-2
		TS	NRJETS
		TCF	ROLLTIME	# BRANCH TO JET ON-TIME CALCULATION
		
# Page 1045
# BD QUAD SELECTION FOR ROLL COMMANDS

BDROLL		CCS	RBDFAIL
		TCF	RBFAIL
		TCF	RZXLNS
		TCF	RDFAIL
		TCF	RZXLNS
RBFAIL		CAF	NINE
		TCF	TABRZCMD
RDFAIL		CAF	TWELVE
		TCF	TABRZCMD
		
RZXLNS		INDEX	ZNDX		# NO BD FAILURES
		CA	XLNNDX		# +,-,0 Z-TRANSLATION PRESENT
TABRZCMD	AD	RINDEX
		INDEX	A
		CA	RTABLE
		MASK	BDRJETS		# = 34017 OCT
		TS	RWORD1
		
ACYCHECK	CA	YNDX		# ANY Y-TRANSLATION
		EXTEND
		BZF	NOACY		# NO Y-TRANSLATION
		CCS	RACFAIL
		CAF	THREE
		TCF	+2
		CAF	SIX
		INDEX	YNDX
		AD	XLN1NDX
		INDEX	A
		CA	YZTABLE
		MASK	ACYJETS		# = 34360 OCT
		AD	RWORD1
		TS	T5TEMP
		EXTEND			# FOR EXPLANATION SEE CODING ON RTABLE
		MP	BIT4
		AD	=-4
		TS	NRJETS		# NO. OF NET ROLL JETS
		EXTEND
		BZF	TAUCHCK		# IF NRJETS = 0
		
BDRACZ		CA	T5TEMP		# Y-TRANSLATION ACCEPTED
		TS	RWORD1
		TCF	ROLLTIME	# BRANCH TO JET ON-TIME CALCULATIONS
		
TAUCHCK		CCS	TAU
		TCF	NOACY
		TCF	BDRACZ
		TCF	NOACY
		TCF	BDRACZ
		
# Page 1046
NOACY		CA	RWORD1		# Y-TRANSLATION NOT ACCEPTED
		EXTEND
		MP	BIT4
		AD	=-2
		TS	NRJETS
		TCF	ROLLTIME
		
# Page 1047
# 				TABLE FOR ROLL, Y AND Z-TRANSLATION COMMANDS
#
# EITHER AC OR BD ROLL MAY BE SELECTED.  IF AC ROLL IS SELECTED, Y-TRANSLATIONS MAY BE SATISFIED SIMULTANEOUSLY
# PROVIDED THAT THERE ARE NO AC QUAD FAILURES.  IF THERE ARE AC FAILURES, Y-TRANSLATION COMMANDS WILL BE IGNORED,
# IN WHICH CASE THE ASTRONAUT SHOULD SWITCH TO BD ROLL.
#
# IF BDROLL IS SELECTED, Z-TRANSLATIONS MAY BE SATISFIED SIMULTANEOUSLY PROVIDED THAT THERE ARE NO BD QUAD
# FAILURES.  IF THERE ARE BD FAILURES, Z-TRANSLATION COMMANDS WILL BE IGNORED, IN WHICH CASE THE ASTRONAUT SHOULD
# SWITCH TO AC ROLL.
#
# NOTE THAT IF ONE QUAD FAILS (E.G. B FAILED), Z-TRANSLATION IS STILL POSSIBLE AND THAT THE UNDESIRABLE ROLL
# INTRODUCED BY THIS TRANSLATION WILL BE COMPENSATED BY THE TWO AC ROLL JETS ACTUATED BY THE AUTOPILOT LOGIC.
#
# 					   WORD MAKE UP....RTABLE
#
# TWO WORDS, CORRESPONDING TO AC OR BD ROLL SELECTION, HAVE BEEN COMBINED INTO ONE TABLE.  THE WORD CORRESPONDING
# TO AC ROLL HAS THE FOLLOWING INTERPRETATION:
#
#	BITS 9,10,11 ARE CODED TO GIVE THE NET ROLL TORQUE FOR THE WORD SELECTED.  THE CODING IS:
#
#		BIT NO. 11  10   9		NO. OF ROLL JETS
#
#			 0   0   0			-2
#			 0   0   1			-1
#			 0   1   0			 0
#			 0   1   1			+1
#			 1   0   0			+2
#
# THIS WORD MAY THEN BE ADDED TO THE WORD SELECTED FROM THE YZ-TRANSLATION TABLE, WHICH HAS THE SAME TYPE OF
# CODING AS ABOVE, AND THE NET ROLL DETERMINED BY SHIFTING THE RESULTANT WORD RIGHT 8 PLACES AND SUBTRACTING FOUR.
#
# THE WORD CORRESPONDING TO THE BD ROLL HAS A SIMILAR INTERPRETATION, EXCEPT THAT BITS 12, 13, 14 ARE CODED
# (AS ABOVE) TO GIVE THE NET ROLL TORQUE.

					# ROLL 		TRANS		QUADFAIL	BIAS
					
RTABLE		OCT	11000		#   0						  0
		OCT	22125		#   +						  0
		OCT	00252		#   -						  0
		OCT	11231		#   0		+Y(+Z)				  3
		OCT	15421		#   +		+Y(+Z)				  3
		OCT	04610		#   -		+Y(+Z)				  3
		OCT	11146		#   0		-Y(-Z)				  6
		OCT	15504		#   +		-Y(-Z)				  6
		OCT	04442		#   -		-Y(-Z)				  6
		OCT	11000		#   0				  A(B)		  9
		OCT	15504		#   +				  A(B)		  9
		OCT	04610		#   -				  A(B)		  9
		OCT	11000		#   0				  C(D)		 12
		OCT	15421		#   +				  C(D)           12
		OCT	04442		#   -				  C(D)		 12

# Page 1048
# RTABLE MASKS:

ACRJETS		OCT	03760
BDRJETS		OCT	34017

# Page 1049
#					 Y, Z TRANSLATION TABLE
#
# ONCE AC OR BD ROLL IS SELECTED THE QUAD PAIR WHICH IS NOT BEING USED TO SATISFY THE ROLL COMMANDS MAY BE
# USED TO SATISFY THE REMAINING TRANSLATION COMMANDS.  HOWEVER, WE MUST MAKE SURE THAT ROLL COMMANDS ARE SATISFIED
# WHEN THEY OCCUR.  THEREFORE, THE Y-Z TRANSLATIONS FROM THIS TABLE WILL BE IGNORED IF THE NET ROLL TORQUE OF THE
# COMBINED WORD IS ZERO AND THE ROLL COMMANDS ARE NON-ZERO.  THIS SITUATION WOULD OCCUR, FOR EXAMPLE, IF WE EN-
# COUNTER SIMULTANEOUS +R +Y -Z COMMANDS AND A QUAD D FAILURE WHILE USING AC FOR ROLL.
#
# TO FACILITATE THE LOGIC, THE Y-Z TRANSLATION TABLE HAS BEEN CODED IN A MANNER SIMILAR TO THE ROLL TABLE
# ABOVE.
#
# BITS 9,10,11 ARE CODED TO GIVE THE NET ROLL TORQUE INCURRED BY Z-TRANSLATIONS.  THE WORD SELECTED CAN THEN BE
# ADDED TO THE AC-ROLL WORD AND THE RESULTANT ROLL TORQUE DETERMINED FROM THE COMBINED WORD.  SIMILARLY BITS
# 12,13,14 ARE CODED TO GIVE THE NET ROLL TORQUE INCURRED BY Y-TRANSLATIONS WHEN BD-ROLL IS SELECTED.

					# TRANSLATION	QUADFAIL	BIAS
					#
YZTABLE		OCT	11000		# 	0			0
		OCT	11231		#    +Z(+Y)			0
		OCT	11146		#    -Z(-Y)			0
		OCT	11000		#	0	  B(A)		3
		OCT	04610		#    +Z(+Y)	  B(A)		3
		OCT	15504		#    -Z(-Y)	  B(A)		3
		OCT	11000		#  	0	  D(C)		6
		OCT	15421		#    +Z(+Y)	  D(C)		6
		OCT	04442		#    -Z(-Y)	  D(C)		6
		
# YZ-TABLE MASKS:

BDZJETS		OCT	03417
ACYJETS		OCT	34360

# ADDITIONAL CONSTANTS

=-2		=	NEG2
=-4		=	NEG4

# Page 1050
# 					CALCULATION OF JET ON-TIMES
#
# THE ROTATION COMMANDS (TAU'S), WHICH WERE DETERMINED FROM THE JET SWITCHING LOGIC ON THE BASIS OF SINGLE JET
# OPERATION, MUST NOW BE UPDATED BY THE ACTUAL NUMBER OF JETS TO BE USED IN SATISFYING THESE COMMANDS.  TAU MUST
# ALSO BE DECREMENTED ACCORDING TO THE EXPECTED TORQUE GENERATED BY THE NEW COMMANDS ACTING OVER THE NEXT T5 
# INTERVAL.
#
# IN ORDER TO MAINTAIN ACCURATE KNOWLEDGE OF VEHICLE ANGULAR RATES, WE MUST ALSO PROVIDE EXPECTED FIRING TIMES
# (DFT'S, ALSO IN TERMS OF 1-JET OPERATION) FOR THE RATE FILTER.
#
# NOTE THAT TRANSLATIONS CAN PRODUCE ROTATIONS EVEN THOUGH NO ROTATIONS WERE CALLED FOR.  NEVERTHELESS, WE MUST
# UPDATE DFT.
#
# WHEN THE ROTATIONS HAVE FINISHED, WE MUST PROVIDE CHANNEL INFORMATION TO THE T6 PROGRAM TO CONTINUE ON WITH
# THE TRANSLATIONS.  THIS WILL BE DONE IN THE NEXT SECTION.  HOWEVER, TO INSURE THAT JETS ARE NOT FIRED FOR LESS
# THAN A MINIMUM IMPULSE (14MS), ALL JET CHANNEL COMMANDS WILL BE HELD FIXED FROM THE START OF THE T5 PROGRAM FOR
# AT LEAST 14MS UNTIL THE INITIALIZATION OF NEW COMMANDS.  MOREOVER, A 14MS ON-TIME WILL BE ADDED TO ANY ROTATIONAL
# COMMANDS GENERATED BY THE MANUAL CONTROLS OR THE JET SWITCHING LOGIC, AND ALL TRANSLATION COMMANDS WILL BE
# ACTIVE FOR AT LEAST ONE CYCLE OF THE T5 PROGRAM (.1SEC)

# PITCH JET ON-TIME CALCULATION

PITCHTIM	CCS	TAU1
		TCF	PTAUPOS
		TCF	+2
		TCF	PTAUNEG
		TS	DFT1		# NO PITCH ROTATION
		TCF	PBYPASS		# COMMANDS
		
PTAUNEG		CS	NPJETS
		TS	NPJETS
PTAUPOS		CA	TAU1
		EXTEND
		INDEX	NPJETS
		MP	NJET
		TS	BLAST1
		AD	=-.1SEC
		EXTEND
		BZMF	AD14MSP
		INDEX	NPJETS
		CA	DFTMAX		# THE PITCH ON-TIME IS GREATER THAN .1 SEC
		TS	DFT1
		COM
		ADS	TAU1		# UPDATE TAU1
		CAF	=+.1SEC		# LIMIT THE LENGTH OF PITCH ROTATION
		TS	BLAST1		# COMMANDS TO 0.1 SEC SO THAT ONLY
		TCF	ASMBLWP		# X-TRANSLATIONS WILL CONTINUE ON SWITCH
					# OVER TO TVC
AD14MSP		CS	BLAST1		# SEE IF JET ON TIME IS LESS THAN
		AD	=14MS		# MINIMUM IMPULSE TIME
		EXTEND
		BZMF	PBLASTOK	# IF SO LIMIT MINIMUM ON TIME TO 14 MS
		CAF	=14MS
# Page 1051
		TS	BLAST1
PBLASTOK	CA	BLAST1
		EXTEND			# THE PITCH COMMANDS WILL BE COMPLETED
		MP	NPJETS		# WITHIN THE TS-CYCLE TIME
		LXCH	DFT1		# FOR USE IN UPDATING RATE FILTER
		TS	TAU1		# ZERO TAU1 (ACC CONTAINS ZERO)
		TCF	ASMBLWP
		
# Page 1052
# YAW JET ON-TIME CALCULATION

YAWTIME		CCS	TAU2
		TCF	YTAUPOS
		TCF	+2
		TCF	YTAUNEG
		TS	DFT2		# NO YAW ROTATION COMMANDS
		TCF	YBYPASS
		
YTAUNEG		CS	NYJETS
		TS	NYJETS
YTAUPOS		CA	TAU2
		EXTEND
		INDEX	NYJETS
		MP	NJET
		TS	BLAST2
		AD	=-.1SEC
		EXTEND
		BZMF	AD14MSY
		INDEX	NYJETS
		CA	DFTMAX		# YAW COMMANDS WILL LAST LONGER THAN .1SEC
		TS	DFT2
		COM
		ADS	TAU2		# DECREMENT TAU2
		CAF	=+.1SEC		# LIMIT THE LENGTH OF YAW ROTATION COMMAND
		TS	BLAST2		# TO 0.1 SEC SO THAT ONLY X-TRANSLATION
		TCF	ASMBLWY		# WILL CONTINUE ON SWITCH OVER TO TVC
		
AD14MSY		CS	BLAST2		# SEE IF JET ON-TIME LESS THAN
		AD	=14MS		# MINIMUM IMPULSE TIME
		EXTEND
		BZMF	YBLASTOK	# IF SO, LIMIT MINIMUM ON-TIME TO 14 MS
		CAF	=14MS
		TS	BLAST2
YBLASTOK	CA	BLAST2		# YAW COMMANDS WILL BE COMPLETED WITHIN
		EXTEND			# THE T5CYCLE TIME
		MP	NYJETS
		LXCH	DFT2
		TS	TAU2		# ZERO TAU2
		TCF	ASMBLWY
		
# Page 1053
# ROLL ON-TIME CALCULATION:

ROLLTIME	CCS	TAU
		TCF	RBLAST
		TCF	+2
		TCF	RBLAST
		INDEX	NRJETS
		CA	DFTMAX		# UPDATE DFT EVEN THO NO ROLL COMMANDS ARE
		TS	DFT		# PRESENT
		TCF	RBYPASS
		
		DEC	-480		# =-.3SEC
		DEC	-320		# =-.2SEC
=-.1SEC		DEC	-160		# =-.1SEC
DFTMAX		DEC	0		# 0
=+.1SEC		DEC	160		# =+.1SEC
		DEC	320		# =+.2SEC
		DEC	480		# =+.3SEC
=14MS		DEC	23		# =14MS

RBLAST		CA	TAU
		EXTEND
		INDEX	NRJETS
		MP	NJET
		TS	BLAST		# BLAST IS AN INTERMEDIATE VARIABLE
					# USED IN DETERMINING THE JET ON-TIMES
		AD	=-.1SEC
		EXTEND
		BZMF	AD14MSR
		INDEX	NRJETS		# THE ROLL ROTATION WILL LAST LONGER
		CA	DFTMAX		# THAN THE T5 CYCLE TIME
		TS	DFT
		COM
		ADS	TAU
		CAF	=+.1SEC		# LIMIT THE LENGTH OF ROLL ROTATION
		TS	BLAST		# COMMANDS TO 0.1 SEC SO THAT ONLY Y-Z
		TCF	ASMBLWR		# TRANSLATION COMMANDS CONTINUE
		
AD14MSR		CS	BLAST		# SEE IF THE JET ON-TIME LESS THAN
		AD	=14MS		# MINIMUM IMPULSE TIME
		EXTEND
		BZMF	RBLASTOK
		CAF	=14MS		# IF SO, LIMIT MINIMUM ON-TIME TO 14 MS
		TS	BLAST
RBLASTOK	CA	BLAST
		EXTEND
		MP	NRJETS
		LXCH	DFT
		TS	TAU		# ZERO TAU
		TCF	ASMBLWR
		
# Page 1054
		DEC	-.333333	# = -1/3
		DEC	-.500000	# = -1.2
		DEC	-.999999	# = -1 (NEGMAX)
NJET		DEC	0
		DEC	.999999		# = +1 (POSMAX)
		DEC	.500000		# = +1/2
		DEC	.333333		# = +1/3
		
# Page 1055
# WHEN THE ROTATION COMMANDS ARE COMPLETED, IT IS NECESSARY TO REPLACE THESE COMMANDS BY NEW COMMANDS WHICH
# CONTINUE ON WITH THE TRANSLATIONS IF ANY ARE PRESENT.
#
# IN THIS SECTION THESE NEW COMMANDS ARE GENERATED AND STORED FOR REPLACEMENT OF THE CHANNEL COMMANDS WHEN THE
# CORRESPONDING ROTATIONS ARE COMPLETED.
#
# GENERATION OF THE SECOND PITCH(X-TRANS) WORD...PWORD2

ASMBLWP		CCS	RACFAIL
		TCF	FPX2		# IF FAILURE ON AC IGNORE X-TRANSLATION
		TCF	+2
		TCF	FPX2
		INDEX	XNDX1
		CA	XLNNDX
		INDEX	A
FPX2		CA	PYTABLE
		MASK	PJETS
		TS	PWORD2
		TCF	YAWTIME
		
PBYPASS		CA	PWORD1		# THE T6 PROGRAM WILL LOAD PWORD2
		TS	PWORD2		# UPON ENTRY
		CAF	ZERO
		TS	BLAST1		# THERE IS NO PWORD2
		TCF	YAWTIME
		
# Page 1056
# GENERATION OF THE SECOND ROLL (Y,Z) WORD (RWORD2)

ASMBLWR		CCS	YNDX		# CHECK FOR Y-TRANS
		TCF	ACBD2Y
NO2Y		CAF	ZERO
		TS	RWORD2
		CCS	ZNDX		# CHECK FOR Z-TRANS
		TCF	ACBD2Z
NO2Z		CAF	ZERO
		ADS	RWORD2
		TCF	PITCHTIM	# RWORD2 ASSEMBLED
		
ACBD2Y		CCS	ACORBD
		TCF	AC2Y		# CAN DO Y-TRANS
		TCF	AC2Y
		TCF	+1		# USING AC FOR ROLL
		CCS	RACFAIL
		TCF	NO2Y		# USING AC AND AC HAS FAILED
		TCF	+2
		TCF	NO2Y		# DITTO
		
		INDEX	YNDX		# NO FAILURES, CAN DO Y
		CA	XLNNDX
		INDEX	A
		CA	RTABLE
		MASK	ACRJETS
		TCF	NO2Y 	+1
		
AC2Y		CCS	RACFAIL
		CAF	THREE
		TCF	+2
		CAF	SIX
		INDEX	YNDX
		AD	XLN1NDX
		INDEX	A
		CA	YZTABLE
		MASK	ACYJETS
		TS	RWORD2
		EXTEND
		MP	BIT4
		AD	=-2
		TS	NRJETS
		CS	BLAST
		AD	=+.1SEC
		EXTEND
		MP	NRJETS
		CA	L
		ADS	DFT
		TCF	NO2Y 	+2
# Page 1057
ACBD2Z		CCS	ACORBD
		TCF	BDF2Z		# USING BD-ROLL
		TCF	BDF2Z		# MUST CHECK FOR BD FAILURES
		TCF	+1
		CCS	RBDFAIL		# USING AC FOR ROLL, CAN DO Z-TRANS
		CAF	THREE
		TCF	+2
		CAF	SIX
		INDEX	ZNDX
		AD	XLN1NDX
		INDEX	A
		CA	YZTABLE
		MASK	BDZJETS
		ADS	RWORD2
		EXTEND
		MP	BIT7
		AD	=-2
		TS	NRJETS
		CS	BLAST
		AD	=+.1SEC
		EXTEND
		MP	NRJETS
		CA	L
		ADS	DFT
		TCF	PITCHTIM
		
BDF2Z		CCS	RBDFAIL
		TCF	NO2Z		# USING BD-ROLL AND BD HAS FAILED
		TCF	+2
		TCF	NO2Z		# DITTO
		INDEX	ZNDX
		CA	XLNNDX
		INDEX	A
		CA	RTABLE
		MASK	BDRJETS
		TCF	NO2Z +1
		
RBYPASS		CA	RWORD1
		TS	RWORD2
		CAF	ZERO
		TS	BLAST
		TCF	PITCHTIM
	
# Page 1058	
# GENERATION OF THE SECOND YAW (X-TRANS) WORD...YWORD2

ASMBLWY		CCS	RBDFAIL
		TCF	FYX2		# IF FAILURE ON BD IGNORE X-TRANSLATION
		TCF	+2
		TCF	FYX2
		INDEX	XNDX2
		CA	XLNNDX
		INDEX	A
FYX2		CA	PYTABLE
		MASK	YJETS
		TS	YWORD2
		TCF	T6SETUP
		
YBYPASS		CA	YWORD1
		TS	YWORD2
		CAF	ZERO
		TS	BLAST2

# Page 1059
#					SORT THE JET ON-TIMES
#
# AT THIS POINT ALL THE CHANNEL COMMANDS AND JET ON-TIMES HAVE BEEN DETERMINED.  IN SUMMARY THESE ARE:
#
#	RWORD1
#	RWORD2		BLAST
#
#	PWORD1
#	PWORD2		BLAST1
#
#	YWORD1
#	YWORD2		BLAST2
#
# IN THIS SECTION THE JET ON-TIMES ARE SORTED AND THE SEQUENCE OF T6 INTERRUPTS IS DETERMINED.  TO FACILITATE
# THE SORTING PROCESS AND THE T6 PROGRAM, THE VARIABLES BLAST, BLAST1, BLAST2, ARE RESERVED AS DOUBLE PRECISION
# WORDS.  THE LOWER PART OF THESE WORDS CONTAIN A BRANCH INDEX ASSOCIATED WITH THE ROTATION AXIS OF THE HIGHER
# ORDER WORD.

T6SETUP		CAF	ZERO		# BRANCH INDEX FOR ROLL
		TS	BLAST +1
		CAF	FOUR		# BRANCH INDEX FOR PITCH
		TS	BLAST1 +1
		CAF	ELEVEN		# BRANCH INDEX FOR YAW
		TS	BLAST2 +1
		
		CS	BLAST
		AD	BLAST1
		EXTEND
		BZMF	DXCHT12		# T1 OR T2
CHECKT23	CS	BLAST1
		AD	BLAST2
		EXTEND
		BZMF	DXCHT23
CALCDT6		CS	BLAST1
		ADS	BLAST2
		CS	BLAST
		ADS	BLAST1		# END OF SORTING PROCEDURE
		EXTEND			# RESET T5LOC TO BEGIN PHASE1
		DCA	RCS2CADR
		DXCH	T5LOC
ENDJETS		CS	BIT1		# RESET BIT1 FOR INITIALIZATION OF
		MASK	RCSFLAGS	# T6 PROGRAM
		TS	RCSFLAGS
		CS	ZERO		# RESET T5PHASE FOR PHASE1
		TS	T5PHASE
		TCF	RESUME		# RESUME INTERRUPTED PROGRAM
		
		EBANK=	KMPAC
RCS2CADR	2CADR	RCSATT

# Page 1060
DXCHT12		DXCH	BLAST
		DXCH	BLAST1
		DXCH	BLAST
		TCF	CHECKT23
		
DXCHT23		DXCH	BLAST1
		DXCH	BLAST2
		DXCH	BLAST1
		CS	BLAST
		AD	BLAST1
		EXTEND
		BZMF	+2
		TCF	CALCDT6
		DXCH	BLAST
		DXCH	BLAST1
		DXCH	BLAST
		TCF	CALCDT6
		
# Page 1061
# T6 PROGRAM AND CHANNEL SETUP

		BANK	21
		SETLOC	DAPS5
		BANK
		
T6START		LXCH	BANKRUPT
		EXTEND
		QXCH	QRUPT
		CCS	TIME6		# CHECK TO SEE IF TIME6 WAS RESET
		TCF	RESUME		# AFTER T6RUPT OCCURRED (IN T5RUPT)
		TCF	+2		# IF SO WAIT FOR NEXT T6RUPT BEFORE
		TCF	RESUME		# TAKING ACTION
		
		CS	RCSFLAGS
		MASK	BIT1		# IF BIT1 IS 0 RESET TO 1
		EXTEND			# AND INITIALIZE CHANNEL
		BZF	T6RUPTOR
		ADS	RCSFLAGS
		CA	RWORD1
		EXTEND			# INITIALIZE CHANNELS 5,6 WITH WORD1
		WRITE	CHAN6
		CA	PWORD1
		AD	YWORD1
		EXTEND
		WRITE	CHAN5
		
T6RUPTOR	CCS	BLAST
		TCF	ZBLAST		# ZERO BLAST1
		TCF	REPLACE		# REPLACE WORD1
		TCF	+2
		TCF	REPLACE
T6L1		CCS	BLAST1
		TCF	ZBLAST1
		TCF	REPLACE1
		TCF	+2
		TCF	REPLACE1
T6L2		CCS	BLAST2
		TCF	ZBLAST2
		TCF	REPLACE2
		TCF	RESUME
		TCF	REPLACE2
		
REPLACE		INDEX	BLAST +1
		TC	REPLACER
		CS	ONE
		TS	BLAST
		TCF	T6L1
		
REPLACE1	INDEX	BLAST1 +1
# Page 1062
		TC	REPLACER
		CS	ONE
		TS	BLAST1
		TCF	T6L2
		
REPLACE2	INDEX	BLAST2 +1
		TC	REPLACER
		CS	ONE
		TS	BLAST2
		TCF	RESUME
		
REPLACER	CA	RWORD2		# INITIALIZE CHANNELS 5,6 WITH WORD2
		EXTEND
		WRITE	CHAN6
		TC	Q
		
REPLACEP	CA	YJETS
		EXTEND
		RAND	CHAN5
		AD	PWORD2
		EXTEND
		WRITE	CHAN5
		TC	Q
		
REPLACEY	CA	PJETS
		EXTEND
		RAND	CHAN5
		AD	YWORD2
		EXTEND
		WRITE	CHAN5
		TC	Q

ZBLAST		CAF	ZERO
		XCH	BLAST
		TCF	ENABT6
ZBLAST1		CAF	ZERO
		XCH	BLAST1
		TCF	ENABT6
ZBLAST2		CAF	ZERO
		XCH	BLAST2
ENABT6		TS	TIME6
		CAF	NEGMAX
		EXTEND
		WOR	CHAN13		# ENABLE T6RUPT
		TCF	RESUME
		
# END OF T6 INTERRUPT

ENDSLECT	EQUALS

