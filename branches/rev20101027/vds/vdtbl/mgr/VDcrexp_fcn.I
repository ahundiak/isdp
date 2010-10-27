
/* $Id: VDcrexp_fcn.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrexp_fcn.I
 *
 * Description:
 *
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrexp_fcn.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/12/29  04:57:40  pinnacle
# Replaced: vdtbl/mgr/VDcrexp_fcn.I for:  by ksundar for vds
#
# Revision 1.2  1997/10/27  06:20:44  pinnacle
# Replaced: vdtbl/mgr/VDcrexp_fcn.I for:  by ksundar for vds
#
# Revision 1.1  1997/10/21  03:58:48  pinnacle
# Created: vdtbl/mgr/VDcrexp_fcn.I by ksundar for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *	10/03/97        Sundar		Creation Date
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <sys/types.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VDmacdef.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "cotxmacros.h"

#include "vdbmacros.h"
#include "vdsmacros.h"
#include "vdparmacros.h"
#include "VDDbtbldef.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_pr.h"
#include "v_miscmacros.h"
#include "vdtblmacros.h"
#include "VDmem.h"

/*
#define     MY_DEBUG	1
*/
// #define vdsDEBUG        1
#include "v_dbgmacros.h"


IGRint   VD_EXP_SetIndx (IGRchar      *Userid,
                         IGRchar      *Timest,
                         IGRboolean   *Local,
                         IGRshort     *LcUnit)
{
  IGRint      i, ilen;
  char       *pNam;
  time_t      curtime;
  char       *pTim;

  extern  char * getlogin();
  extern  char * cuserid();

  SetProc( VD_EXP_SetIndx ); Begin
  if (Timest)
  {
    for (i=0; i<VD_CREXP_CHR_STAMP; i++)
     Timest[i] = '\0';

    time(&curtime);
    pTim = ctime (&curtime);


    Timest[0]  = pTim[4];
    Timest[1]  = pTim[5];
    Timest[2]  = pTim[6];
    Timest[3]  = ' ';
    Timest[4]  = pTim[8];
    Timest[5]  = pTim[9];
    Timest[6]  = ',';
    Timest[7]  = pTim[20];
    Timest[8]  = pTim[21];
    Timest[9]  = pTim[22];
    Timest[10]  = pTim[23];
    Timest[11]  = '-';
    Timest[12] = pTim[11];
    Timest[13] = pTim[12];
    Timest[14] = pTim[13];
    Timest[15] = pTim[14];
    Timest[16] = pTim[15];
    Timest[17] = '\0';
  }

  if (Userid)
  {
    for (i=0; i<VD_CREXP_CHR_IDFLD; i++)
     Userid[i] = '\0';

    pNam = getlogin();

    if (pNam == NULL) pNam = cuserid (NULL);

    if (pNam != NULL)
    {
      ilen = strlen (pNam);
      if (ilen > VD_CREXP_CHR_IDFLD) ilen = VD_CREXP_CHR_IDFLD;
      for (i=0; i<ilen; i++)
        Userid[i] = pNam[i];

      Userid[VD_CREXP_CHR_IDFLD-1] = '\0';
    }
    else
      strcpy (Userid, "Xuser");
  }

  if (Local)
    *Local = TRUE;

  /* Set units of design file    */

  if (LcUnit)
    *LcUnit = 0;

  End
  return (OM_S_SUCCESS);
}

IGRint  VD_crexp_inew  (IGRlong      *msg,
                        IGRchar      *Tabnam,
                 struct GRid         *DRWloid)
{
  GRspacenum     cur_os;
  IGRint         status;
 
  SetProc( VD_crexp_inew ); Begin
  ex$get_cur_mod (osnum = &cur_os);
 
           vd$tblexp_new (msg    = msg,
                          osnum  = cur_os,
                          tabnam = Tabnam,
                          GRid   = DRWloid);
 
  End
  return (status);
}

IGRint  VD_crexp_getnm (IGRlong      *msg,
                        IGRboolean    bLocal,
                        IGRboolean    bDB,
                        IGRshort     *nCount,
                        IGRchar      *Tabtyp,
                        IGRchar      *Tabnam,
                        IGRchar      *Tabdes)
{
  IGRint         status;
  GRspacenum     cur_os;
 
  SetProc( VD_crexp_getnm ); Begin
  status = OM_S_SUCCESS;
 
  ex$get_cur_mod (osnum = &cur_os);
 
           vd$tblexp_idx (msg     = msg,
                          osnum   = cur_os,
                          local   = bLocal,
                          dbget   = bDB,
                          p_count = nCount,
                          p_typs  = Tabtyp,
                          p_nams  = Tabnam,
                          p_desc  = Tabdes);
 
  End
  return (status);
}

IGRint  VD_crexp_getnd (IGRlong      *msg,
                        IGRboolean    bLocal,
                        IGRboolean    bDB,
                        IGRchar      *Tabtyp,
                        IGRshort     *nCount,
                        IGRchar      *Tabnam,
                        IGRchar      *Tabdes)
{
  IGRint         status;
  GRspacenum     cur_os;
 
  SetProc( VD_crexp_getnm ); Begin
  status = OM_S_SUCCESS;
 
  ex$get_cur_mod (osnum = &cur_os);
 
           vd$tblexp_idnd (msg     = msg,
                          osnum   = cur_os,
                          local   = bLocal,
                          dbget   = bDB,
                          p_type  = Tabtyp,
                          p_count = nCount,
                          p_nams  = Tabnam,
                          p_desc  = Tabdes);
 
  End
  return (status);
}

IGRint  VD_crexp_gett (IGRlong      *msg,
                        IGRboolean    bLocal,
                        IGRboolean    bDB,
                        IGRshort     *nCount,
                        IGRchar      *Tabtyp)
{
  IGRint         status;
  GRspacenum     cur_os;
 
  SetProc( VD_crexp_getnm ); Begin
  status = OM_S_SUCCESS;
 
  ex$get_cur_mod (osnum = &cur_os);
 
           vd$tblexp_idt (msg     = msg,
                          osnum   = cur_os,
                          local   = bLocal,
                          dbget   = bDB,
                          p_count = nCount,
                          p_typs  = Tabtyp);
 
  End
  return (status);
}

IGRint  VD_crexp_getid (IGRlong      *msg,
                        IGRchar      *Tabnam,
                 struct GRid         *Expid)
{
  IGRint         status;
  GRspacenum     cur_os;
 
  SetProc( VD_crexp_getid ); Begin
  status = OM_S_SUCCESS;
 
  ex$get_cur_mod (osnum = &cur_os);
 
           vd$tblexp_old (msg    = msg,
                          osnum  = cur_os,
                          tabnam = Tabnam,
                          GRid   = Expid);
 
  End
  return (status);
}

IGRint VD_crexp_set (IGRlong           *msg,
                        IGRchar                 *Tabnam,
                        struct GRid             *Expid,
                        struct VDdrwexp_tab     *Exptab,
                        IGRint                  num_exp_data,
                        struct VDdrwexp_data    *Expdat)
{
  IGRint status;
  GRspacenum     cur_os;

  SetProc( VD_crexp_set ); Begin
  status = OM_S_SUCCESS;
 
  ex$get_cur_mod (osnum = &cur_os);
 
	if ( Tabnam != NULL ){
           vd$tblexp_set (msg = msg, 
                          osnum = cur_os,
			  tabnam = Tabnam,
			  drwexp_tab= Exptab,
			  num_exp_data = num_exp_data,
			  drwexp_data = Expdat);
	} else if ( Expid != NULL ) {
	   vd$tblexp_set (msg = msg,
                          osnum = cur_os,
                          tab_id = Expid ,
                          drwexp_tab= Exptab,
                          num_exp_data = num_exp_data,
                          drwexp_data = Expdat);
	}
 
  End
  return (status);

}

IGRint  VD_crexp_idelete (IGRlong      *msg,
                          IGRchar      *Tabnam)
{
  IGRint         status;
  GRspacenum     cur_os;
 
  status = OM_S_SUCCESS;
 
  ex$get_cur_mod (osnum = &cur_os);
 
           vd$tblexp_del (msg    = msg,
                          osnum  = cur_os,
                          tabnam = Tabnam);
 
  return (status);
}


end implementation Root;
