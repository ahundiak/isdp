
/* $Id: VDADS_gen.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDADS_gen.I
 *
 * Description:
 *
 * Implementation file for top level attr driven symbol manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDADS_gen.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1995/11/16  15:41:42  pinnacle
# Replaced: vdtbl/mgr/VDADS_gen.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/09/25  23:45:36  pinnacle
# Replaced: vdtbl/mgr/VDADS_gen.I for:  by sundar for vds.240
#
# Revision 1.5  1995/08/18  15:53:36  pinnacle
# Replaced: vdtbl/mgr/VDADS_gen.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/14  22:12:58  pinnacle
# Replaced: vdtbl/mgr/VDADS_gen.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/11  19:10:24  pinnacle
# Replaced: vdtbl/mgr/VDADS_gen.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  14:39:16  pinnacle
# Replaced: vdtbl/mgr/VDADS_gen.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/19  19:32:02  pinnacle
# Created: vdtbl/mgr/VDADS_gen.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/09/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDADS;

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

extern void    VD_ADS_move ();



method   VDADS_init   (IGRlong         *msg;
                struct VDdrwlo_sstab   *Tabrec)
{
  IGRint      status;

  *msg = MSSUCC;

  strcpy (me->SSid_tab.Tabnam, Tabrec->Tabnam);
  strcpy (me->SSid_tab.Shdesc, Tabrec->Shdesc);

  status = VD_DLO_SetIndx (me->SSid_tab.Userid,
                           me->SSid_tab.Timest,
                          &me->SSid_tab.Local,
                          &me->SSid_tab.LcUnit);

  /*   (re) initialize variable length arrays   */

  status = om$vla_set_dimension (varray = me->Ladsrec, size = 0);

  return (OM_S_SUCCESS);
}


method   VDADS_gtab   (IGRlong         *msg;
                struct VDdrwlo_sstab   *Tabrec)
{

  *msg = MSSUCC;

  if (Tabrec)
  {
    strcpy (Tabrec->Tabnam,  me->SSid_tab.Tabnam);
    strcpy (Tabrec->Timest,  me->SSid_tab.Timest);
    strcpy (Tabrec->Userid,  me->SSid_tab.Userid);
    strcpy (Tabrec->Shdesc,  me->SSid_tab.Shdesc);

    Tabrec->Local  = me->SSid_tab.Local;
  }

  return (OM_S_SUCCESS);
}


method   VDADS_srec  (IGRlong         *msg;
                      IGRshort         nCount;
               struct VDadsym_rec     *AdsRec)
{
  IGRint     status;
  IGRshort   irec;

  *msg = MSSUCC;

  status = om$vla_set_dimension (varray = me->Ladsrec, size = nCount);

  for (irec = 0; irec < nCount; irec++)
    VD_ADS_move (&(me->Ladsrec[irec]), &(AdsRec[irec]));

  return (OM_S_SUCCESS);
}

method   VDADS_check (IGRlong         *msg;
                      IGRshort        *nIndex)
{
  IGRshort   irec;
  IGRshort   nCount;

  *msg    = MSSUCC;
  *nIndex = -1;

  nCount = om$dimension_of (varray = me->Ladsrec);

  for (irec = 0; irec < nCount; irec++)
  {
    if (me->Ladsrec[irec].nDattyp == VD_DRWLO_EN_ASCII)
    {
      if ((me->Ladsrec[irec].Symbol[0]   != '\0') &&
          (me->Ladsrec[irec].szAtt[0]    != '\0') &&
          (me->Ladsrec[irec].szAttval[0] != '\0') &&
          (me->Ladsrec[irec].nnREL       != VD_cnt_qry_NONE)) continue;
    }
    else
    {
      if ((me->Ladsrec[irec].Symbol[0]   != '\0') &&
          (me->Ladsrec[irec].szAtt[0]    != '\0') &&
          (me->Ladsrec[irec].nnREL       != VD_cnt_qry_NONE)) continue;
    }

    if (me->Ladsrec[irec].nnREL     == VD_cnt_qry_NONE) continue;

    /*    found incomplete     */

    *msg = MSFAIL;

    *nIndex = irec;
    break;
  }

  return (OM_S_SUCCESS);
}





method   VDADS_grec  (IGRlong         *msg;
                      IGRchar         *AttNam;
               struct ret_struct      *AttVal;
                      IGRshort        *nCount;
               struct VDadsym_rec     *AdsRec)
{
  IGRshort   nNumrec;
  IGRshort   irec;
  IGRdouble  dEPS;
  IGRint     nEPS;

  struct VDadsym_rec    *pLoc;

  *msg    = MSSUCC;
  nNumrec = om$dimension_of (varray = me->Ladsrec);
  *nCount = 0;
  pLoc    = AdsRec;

  for (irec=0; irec < nNumrec; irec++)
  {
    if (AttNam == NULL) goto ADD_IT;

    if (strcmp (AttNam, me->Ladsrec[irec].szAtt) != 0) continue;

    if (AttVal == NULL) goto ADD_IT;

    if (me->Ladsrec[irec].nDattyp == VD_DRWLO_EN_ASCII)
    {   /*   ASCII compare of attribute values   */

      if (AttVal->type != text_type) continue; 

      nEPS = strcmp (AttVal->var.text_st.text_string,
                     me->Ladsrec[irec].szAttval);
      dEPS = nEPS;
    }
    else
    {   /*   numeric compare of attribute values   */

      if (AttVal->type != double_type) continue; 

      dEPS = AttVal->var.root_pm_st.value - me->Ladsrec[irec].dAttval;
    }

    switch (me->Ladsrec[irec].nnREL)
    {
      default:
      case VD_cnt_qry_NONE:    goto ADD_IT;
      case VD_cnt_qry_EQUAL:   if (dEPS == 0) goto ADD_IT;      break;
      case VD_cnt_qry_N_EQUAL: if (dEPS != 0) goto ADD_IT;      break;
      case VD_cnt_qry_G_EQUAL: if (dEPS >= 0) goto ADD_IT;      break;
      case VD_cnt_qry_L_EQUAL: if (dEPS <= 0) goto ADD_IT;      break;
      case VD_cnt_qry_G_THAN:  if (dEPS >  0) goto ADD_IT;      break;
      case VD_cnt_qry_L_THAN:  if (dEPS <  0) goto ADD_IT;      break;
    }

    continue;

    ADD_IT:     /*   add to output    */

    if (pLoc != NULL)
    {
      VD_ADS_move (pLoc, &(me->Ladsrec[irec]));

      pLoc++;
    }

    (*nCount)++;
  }

  return (OM_S_SUCCESS);
}

void    VD_ADS_move (struct VDadsym_rec     *pDest,
                     struct VDadsym_rec     *pOrg)
{
  strcpy (pDest->Symbol  , pOrg->Symbol);
  strcpy (pDest->szAtt   , pOrg->szAtt);
  strcpy (pDest->szAttval, pOrg->szAttval);
  strcpy (pDest->font    , pOrg->font);

  pDest->nDattyp   = pOrg->nDattyp;
  pDest->nnREL     = pOrg->nnREL;
  pDest->dAttval   = pOrg->dAttval;
  pDest->nnSide    = pOrg->nnSide;
  pDest->dOffset   = pOrg->dOffset;
  pDest->dCharhgt  = pOrg->dCharhgt;
  pDest->dCharwdt  = pOrg->dCharwdt;
  pDest->dCharspc  = pOrg->dCharspc;
  pDest->nCharwgt  = pOrg->nCharwgt;

  return;
}

end implementation VDADS;

