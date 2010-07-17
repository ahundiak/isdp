/* $Id: VRdberrmsg.I,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRdberrmsg.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRdberrmsg.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/15  19:34:34  pinnacle
# Replaced: vrpdu for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/04/22  13:49:44  pinnacle
# Replaced: vrpdu/VRdberrmsg.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/17  17:29:48  pinnacle
# Replaced: vrpdu/VRdberrmsg.I for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/
class implementation Root;

#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "VRmsg.h"
#include "VRDbStruct.h"
#include "vrpdu_pto.h"

int VRdb_err_msg (long   msgnum,
                  char  *err_ptr,
                  char  *var1,
                  char  *var2,
                  char  *var3)
{
       
      switch(msgnum)
      {
          
         case VR_E_DbLongErrMsg:

                                 if(err_ptr != NULL)
                                 {
                                  ex$message ( msgnumb = msgnum,
                                               type    = "%s%s%s",
                                               var     = `var1,var2,var3`,
                                               buff    =  err_ptr );
                                 }
                                 break;
         case VR_E_DbErrPrepQuery:
                                 if(err_ptr != NULL)
                                 {
                                      ex$message ( msgnumb  = msgnum,
                                                   buff    = err_ptr);
                                 }
                                  ex$message( field = ERROR_FIELD,
                                              msgnumb = msgnum);
                                 break;                  

         case VR_E_DbUnitErrMsg:
                              
                                 if(err_ptr != NULL)
                                 {
                                     ex$message(msgnumb = msgnum,
                                                buff   = err_ptr);
                                 }
                                 ex$message(field = ERROR_FIELD,
                                            msgnumb = msgnum);
                                 break;

         case VR_E_RisInitFailed:
                              
                                 if(err_ptr != NULL)
                                 {
                                     ex$message(msgnumb = msgnum,
                                                buff   = err_ptr);
                                 }
                                 ex$message(field = ERROR_FIELD,
                                            msgnumb = msgnum);
                                 break;
         case VR_E_HvCatNotFound:
                              
                                 if(err_ptr != NULL)
                                 {
                                     ex$message(msgnumb = msgnum,
                                                type    = "%s",
                                                var     = `var1`,
                                                buff   = err_ptr);
                                 }
                                 ex$message(field = ERROR_FIELD,
                                            type    = "%s",
                                            var     = `var1`,
                                            msgnumb = msgnum);
                                 break;

         case VR_E_CatColNotFound:
                              
                                 if(err_ptr != NULL)
                                 {
                                     ex$message(msgnumb = msgnum,
                                                type    = "%s%s",
                                                var     = `var1,var2`,
                                                buff   = err_ptr);
                                 }
                                 ex$message(field = ERROR_FIELD,
                                            type    = "%s%s",
                                            var     = `var1,var2`,
                                            msgnumb = msgnum);
                                 break;

         default:
                  printf("VRdb_err_msg: Invalid Message number%d\n",msgnum);
      }
      return (1);
}
end implementation Root;

