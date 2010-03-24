/*
   Henry BEQUET                                                  DIdebug.h
   
  
   This file contains some debug declarations for the directory
   sub-system.
*/
/* This macro is used to display an error message corresponding to
   the specified status. The non-debug version ignores comment.

   return status :
                      DIR_S_SUCCESS : successful operation

      Argument description :
      --------------------

        DIint  sts       : the status					(IN)
        DIchar *comment  : a comment to be printed with   		(IN)
                           the error message
*/
/*
#omdef di$report_error ( sts, comment = NULL )
       DIreport_error ( sts, NULL )
#endomdef
*/
#undef DEBUG

