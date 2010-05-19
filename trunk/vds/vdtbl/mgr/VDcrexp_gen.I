
/* $Id: VDcrexp_gen.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrexp_gen.I
 *
 * Description:
 *
 * Implementation file for top level criterion manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrexp_gen.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/29  08:26:36  pinnacle
# Replaced: vdtbl/mgr/VDcrexp_gen.I for:  by ksundar for vds
#
# Revision 1.1  1997/10/21  04:01:28  pinnacle
# Created: vdtbl/mgr/VDcrexp_gen.I by ksundar for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *	10/03/97        Sundar		Creation Date
 * -------------------------------------------------------------------*/

class implementation VDcrexp;

#include <time.h>
#include <sys/types.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "vdpardef.h"
#include "VDmem.h"

// #define vdsDEBUG        1
#include "v_dbgmacros.h"




method   VDcrexp_init   (IGRlong         *msg;
                struct VDdrwexp_tab   *Exprec;
		IGRint                  NbExpDat;
 		struct VDdrwexp_data *Expdat)
{
  IGRint      i, status;

  SetProc( VDcrexp.VDcrexp_init ); Begin
  *msg = MSSUCC;

  if ( Exprec ){

     strcpy (me->Expid_tab.Tabtyp, Exprec->Tabtyp);
     strcpy (me->Expid_tab.Tabnam, Exprec->Tabnam);
     strcpy (me->Expid_tab.Shdesc, Exprec->Shdesc);

     status = VD_EXP_SetIndx (me->Expid_tab.Userid,
                           me->Expid_tab.Timest,
                          &me->Expid_tab.Local,
                          &me->Expid_tab.LcUnit);

     me->Expid_tab.data_type = Exprec->data_type;
  }

  /*   (re) initialize variable length arrays   */

  status = om$vla_set_dimension (varray = me->Ldatarec, size = NbExpDat);	
  for (i=0; i<NbExpDat; i++){
     strcpy (me->Ldatarec[i].Datnam ,Expdat[i].Datnam);
     strcpy (me->Ldatarec[i].Datgrp ,Expdat[i].Datgrp);
     me->Ldatarec[i].Datsegn = Expdat[i].Datsegn;	
     strcpy (me->Ldatarec[i].Datinfo ,Expdat[i].Datinfo);
  }

  End
  return (OM_S_SUCCESS);
}

method   VDcrexp_gtab   (IGRlong	*msg;
                struct VDdrwexp_tab	*Exprec;
		IGRint			*NbExpDat;
                struct VDdrwexp_data	**ExpDataRet)
{
  IGRint i;

  SetProc( VDcrexp.VDcrexp_gtab  ); Begin
  *msg = MSSUCC;

  if (Exprec)
  {
    strcpy (Exprec->Tabtyp,  me->Expid_tab.Tabtyp);
    strcpy (Exprec->Tabnam,  me->Expid_tab.Tabnam);
    strcpy (Exprec->Timest,  me->Expid_tab.Timest);
    strcpy (Exprec->Userid,  me->Expid_tab.Userid);
    strcpy (Exprec->Shdesc,  me->Expid_tab.Shdesc);

    Exprec->data_type  = me->Expid_tab.data_type;
    Exprec->LcUnit  = me->Expid_tab.LcUnit;
    Exprec->Local  = me->Expid_tab.Local;

  }
  if( ExpDataRet && NbExpDat ) {
  	*NbExpDat = om$dimension_of(varray = me->Ldatarec);
  	*ExpDataRet = _MALLOC (*NbExpDat, struct VDdrwexp_data);
  } else {
	goto wrapup ;
  }
	
  for (i=0; i<*NbExpDat; i++){
     strcpy ((*ExpDataRet)[i].Datnam,  me->Ldatarec[i].Datnam);
     strcpy ((*ExpDataRet)[i].Datgrp,  me->Ldatarec[i].Datgrp);
     (*ExpDataRet)[i].Datsegn = me->Ldatarec[i].Datsegn;
     strcpy ((*ExpDataRet)[i].Datinfo,  me->Ldatarec[i].Datinfo);
  }

  wrapup :
  End
  return (OM_S_SUCCESS);
}

method VDcrexp_gdata (IGRlong                *msg;
                      IGRint               *nCount;
                      struct VDdrwexp_data   **Data)
{
   IGRint i;  
  
   SetProc( VDcrexp.VDcrexp_gdata  ); Begin

   *nCount = om$dimension_of(varray = me->Ldatarec);
   *Data = _MALLOC (*nCount, struct VDdrwexp_data);

   for (i=0; i<*nCount; i++){
      strcpy ((*Data)[i].Datnam,  me->Ldatarec[i].Datnam);
      strcpy ((*Data)[i].Datgrp,  me->Ldatarec[i].Datgrp);
      (*Data)[i].Datsegn = me->Ldatarec[i].Datsegn;
      strcpy ((*Data)[i].Datinfo,  me->Ldatarec[i].Datinfo);
   }
 
   wrapup :
   End
   return (OM_S_SUCCESS);
}
end implementation VDcrexp;

