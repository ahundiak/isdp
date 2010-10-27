/* $Id: DIdebug.h,v 1.1 2001/01/14 17:02:26 art Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/emsfixes/grnuc /DIdebug.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: DIdebug.h,v $
 *      Revision 1.1  2001/01/14 17:02:26  art
 *      sp merge
 *
 * Revision 1.1  2000/06/05  14:43:50  pinnacle
 * Created: vds/emsfixes/grnuc/DIdebug.h by apazhani for Service Pack
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/05/2000      Alwin           Added this file, as it needs to there
 *					compilation of GRoupi.I file.
 * -------------------------------------------------------------------*/

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

