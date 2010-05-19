DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

MAIN
	DEFINE	RPTkey		CHAR(20),
		prod		INTEGER,
		type		INTEGER,
		logfile		CHAR(20)

	LET default_prj_no = 0  # set the default project number to 0

	CALL get_rpt_key () RETURNING RPTkey
	CALL decrypt_key (RPTkey) RETURNING prod, type
	LET logfile = RPTkey CLIPPED, ".log"
	CALL STARTLOG (logfile)
	CALL RPTform_input ( prod, type)

	IF type != 6 AND type != 7 THEN
	IF drawing_flag = 0 THEN CALL ERRORLOG ( "Report from regular checkin")
	ELSE		         CALL ERRORLOG ( "Report from drawing checkin")
	END IF
	END IF

	OPTIONS MESSAGE LINE 22

	CASE RPTkey
	     WHEN "BMB"	CALL BMBmain ()
	     WHEN "BMG"	CALL BMGmain ()
	     WHEN "BMN"	CALL BMNmain ()
	     WHEN "BMW"	CALL BMWmain ()

	     WHEN "BPG"	CALL BPGmain ()

	     WHEN "EQB"	CALL EQBmain ()
	     WHEN "EQN"	CALL EQNmain ()
	     WHEN "EQW"	CALL EQWmain ()

	     WHEN "HVB"	CALL HVBmain ()
	     WHEN "HVE"	CALL HVEmain ()
	     WHEN "HVN"	CALL HVNmain ()
	     WHEN "HVW"	CALL HVWmain ()

	     WHEN "NZB"	CALL NZBmain ()

	     WHEN "OVW"	CALL OVWmain ()

	     WHEN "PLB"	CALL PLBmain ()
	     WHEN "PLN"	CALL PLNmain ()
	     WHEN "PLW"	CALL PLWmain ()

	     WHEN "PPB"	CALL PPBmain ()
	     WHEN "PPD"	CALL PPDmain ()
	     WHEN "PPE"	CALL PPEmain ()
	     WHEN "PPN"	CALL PPNmain ()
	     WHEN "PPR"	CALL PPRmain ()
	     WHEN "PPV"	CALL PPVmain ()
	     WHEN "PPW"	CALL PPWmain ()

	     WHEN "RWB"	CALL RWBmain ()
	     WHEN "RWE"	CALL RWEmain ()
	     WHEN "RWN"	CALL RWNmain ()
	     WHEN "RWW"	CALL RWWmain ()
	     WHEN "CMB"	CALL CMBmain ()
	     WHEN "CMT"	CALL CMTmain ()
	     WHEN "CMC"	CALL CMCmain ()
	END CASE
END MAIN
