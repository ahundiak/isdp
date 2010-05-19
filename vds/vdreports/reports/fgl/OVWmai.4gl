DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION OVWmain ()
  CALL ERRORLOG ("Enter  in Overall Weight report")
  CALL OVWform_input ()

  BEGIN WORK
     DELETE FROM MFTABLE
  COMMIT WORK

  CALL BMWpart ()
  CALL PLWpart ()

  CALL HVWpart ()
  CALL RWWpart ()

  CALL update_piping_off()
  CALL PPWpart ()
  CALL EQWpart ()

  CALL OVWpart ()

  OPTIONS MESSAGE LINE 22
  MESSAGE "Overall Weight report completed"
  CALL ERRORLOG ("Exit from Overall Weight report")
END FUNCTION
