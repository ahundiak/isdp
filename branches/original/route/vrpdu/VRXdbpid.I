/* $Id: VRXdbpid.I,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRdbpid.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRXdbpid.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/02/03  05:15:50  pinnacle
# Replaced: vrpdu/VRXdbpid.I for:  by apazhani for route
#
# Revision 1.1  1997/08/15  19:42:44  pinnacle
# Created: vrpdu/VRXdbpid.I by hverstee for route
#
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.4  1996/04/22  13:58:22  pinnacle
 * Replaced: vrpdu/VRdbpid.c for:  by hverstee for route240
 *
 * Revision 1.3  1996/04/04  21:47:34  pinnacle
 * Replaced: vrpdu/VRdbpid.c for:  by ashankar for route240
 *
 * Revision 1.2  1996/01/17  17:30:50  pinnacle
 * Replaced: vrpdu/VRdbpid.c for:  by r240_int for route240
 *
 *
 * History:
 *  01/15/96  tlb  Add prototypes, 
 *        Make VRdbCachePidTbl a static function
 *        Change VRdbGetPidSym to ANSII style
 *
 *  02/03/98  Alwin   Added _FREE(), in the Fn VRdbCachePidTbl().
 *
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <string.h>
#include "OMerrordef.h"
#include "igrtypedef.h"

#include "VDmem.h"
#include "VDDbDef.h"
#include "vdbmacros.h"

#include "VRdef.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRDbTbl.h"
#include "vrpdu_pto.h"

struct  VRDbPidSymTbl 
        {
           char   comp_code[10];
           char   macro_name[20];
        };


/**************************************************************/
/*   these static externals to be initialized at DB change    */
%safe
static short  DbPidArrNum = 0;

static struct VRDbPidSymTbl *DbPidSym = NULL;
%endsafe
/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clpid ()

{
  DbPidArrNum   = 0;

  _FREE (DbPidSym);

  return;
}

/* ---------------------------------------------*/
static IGRint 
VRdbCachePidTbl ()
{
  /*********************************************************************/
  /*                                                                   */
  /* This routine caches the PID table                                 */
  /*                                                                   */
  /*********************************************************************/       

  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;

  status =
  vdb$RisSelect (select     = "comp_code, macro_name",
                 table_name = VRDB_PIDSYM_TBL,
                 numselect  = 2,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (status & OM_S_SUCCESS)
  {
    status = OM_E_NODYNMEM;
    DbPidSym = _MALLOC (NbRow, struct VRDbPidSymTbl);
    if (DbPidSym == NULL) goto wrapup;

    for (i=0; i<NbRow; i++)
    {
      VRDBstr (DbPidSym[i].comp_code , DbIO[i*2]);
      VRDBstr (DbPidSym[i].macro_name, DbIO[i*2 + 1]);
    }

    status      = OM_S_SUCCESS;
    DbPidArrNum = NbRow;
  }

  wrapup:

  _FREE( DbIO ); // added by alwin
  return(status);
}

/*----------------------------------------------------*/
IGRint VRdbGetPidSym ( 
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* Piping only                       (I) */
      IGRshort    free_flg,    /* flag to indicate to free buffers  (I) */
      IGRchar     *code,       /* component codes                   (I) */
      IGRchar     *macro,      /* macro names                       (O) */  
      IGRchar     *err_ptr     /* Error message buffer              (O) */
  )
{
  IGRint    sts, i;
  IGRchar  *ep;
  IGRshort  ap;

  ep = err_ptr;
  ap = application;

  if(VdsRisAttach() != OM_S_SUCCESS)
  {
    VRdb_err_msg(VR_E_RisInitFailed, err_ptr,NULL,NULL,NULL);
    *msg = VR_E_RisInitFailed;
    return(OM_E_ABORT);
  }

  *msg = MSSUCC;

  if( free_flg )
  {
    VR_DbC_Clpid();
    return(OM_S_SUCCESS);
  }

  macro[0] = '\0';

  if(VdsRisAttach() != OM_S_SUCCESS) 
  {
       VRdb_err_msg(VR_E_RisInitFailed, err_ptr,NULL,NULL,NULL);
       *msg = VR_E_RisInitFailed;
       return(OM_E_ABORT);
  }

  if (DbPidArrNum == 0)
  {
    sts = VRdbCachePidTbl ();
    if (!(sts & OM_S_SUCCESS))
    {
       *msg = VR_E_DbShortErrMsg;  
       return(OM_E_ABORT);
    }
  }

  for(i=0; i < DbPidArrNum; i++ )
  {
     if(strcmp(DbPidSym[i].comp_code, code ) == 0 )
     {
         VRDBstr(macro, DbPidSym[i].macro_name);
         break;
     }
  }

  return (OM_S_SUCCESS);

}

end implementation Root;

