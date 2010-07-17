
/* $Id: VRXnpdlst.I,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRXnpdlst.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRXnpdlst.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *  Initial import to CVS
 *
# Revision 1.2  1998/06/26  23:06:12  pinnacle
# Replaced: vrpdu/VRXnpdlst.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:43:04  pinnacle
# Created: vrpdu/VRXnpdlst.I by hverstee for route
#
 *
 * History:
 *  01/17/96   tlb    Add prototypes, 
 *        Change check_spec, VRget_npd_list to ANSII style
 *  06/24/98   law    fix for TR179801140 included in TR179801141-check_spec
 *                    was only checking the piping spec for hvac, rway, and
 *                    piping.
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "VDmem.h"
#include "VRdef.h"
#include "VRDbStruct.h"
#include "dberror.h"
#include "VRmsg.h"
#include "VRDbTbl.h"
#include "VRDbCache.h"

#include "vrpdu_pto.h"

#include "VRPDBdef.h"
#include "VRPDBmac.h"
#include "VRRDBdef.h"
#include "VRRDBmac.h"
#include "VRHDBdef.h"
#include "VRHDBmac.h"

/*
#define MY_DEBUG
*/

/**************************************************************/
/*     static buffer                                          */
%safe
static
IGRshort       nRETB = 0;
static
IGRdouble     *dRETB = NULL;
%endsafe
/**************************************************************/
/*             GLOBALS                                        */

extern
struct VRPDB_project   VRGL_PROJ;
extern 
IGRint                 VRGL_specunit;

/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clnpd ()
{
  _FREE (dRETB);

  nRETB = 0;

  return;
}
/**************************************************************/

/********************************************************************* 
 *                                                                   * 
 * This routine extracts the list of allowable npds when             * 
 * spec name is given.                                               * 
 *                                                                   * 
 *********************************************************************/
IGRint VRget_npd_list ( 
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* Piping only                       (I) */
      IGRchar     *specname,   /* Piping spec name (or "NOZZLE")    (I) */
      IGRshort    *listsize,   /* No of elements in npd list        (O) */
      IGRdouble   **npdlist,   /* List of allowable npds            (O) */
      IGRchar     *err_ptr     /* Error buffer                      (O) */
                      )
{
  IGRint              sts, i;
  IGRint              proj_no;
  IGRshort            NN;
  IGRshort            snum;
  IGRint              units_in;
  IGRint              units_out;
  IGRdouble           resolution;
  IGRchar            *ep;

  struct VRPDB_npd   *XX;

  if ( application != VR_PIPING )   return OM_E_INVARG;

#ifdef MY_DEBUG
  printf ("Get_npd_list\n");
#endif

  /* Initialize */
  *listsize  = 0;
  proj_no    = VRPDB_UNDEF;
  XX         = NULL;
  ep         = err_ptr;   /*   get rid of warning  */

  /* Get project  and spec infono */
  sts = VRenq_proj_units();
  sts = Get_piping_spec_units (proj_no, specname, err_ptr);

  VR$PDB_SNUM (p_nam = specname,
               p_num = &snum);

  if(snum < 0) 
  {  /*   no spec, give base     */
    VR$PDB_NPDB (p_msg = msg,
                 p_num = &NN);

    XX = _MALLOC (NN, struct VRPDB_npd);

    VR$PDB_NPDB (p_msg = msg,
                 p_num = &NN,
                 p_rec = XX);

  }
  else
  {
    VR$PDB_NPD  (p_msg = msg,
                 spec  = snum,
                 p_num = &NN);

    XX = _MALLOC (NN, struct VRPDB_npd);

    VR$PDB_NPD  (p_msg = msg,
                 spec  = snum,
                 p_num = &NN,
                 p_rec = XX);
  }

  if (NN != nRETB)
  {
    if (dRETB == NULL)
      dRETB = _MALLOC (NN, IGRdouble);
    else
      dRETB = _REALLOC (dRETB, NN, IGRdouble);

    nRETB = NN;
  }

  *npdlist  = dRETB;
  *listsize = NN;

  /*   for non_spec or equal return npd   */

  if(sts == 0)
  {
    for (i=0;i<NN; i++)
      dRETB[i] = XX[i].npd;
  }
  else
  {
    VR_units_def ("npd_g", (int) VRGL_PROJ.prj_units, VRGL_specunit,
                    &units_in, &units_out, &resolution);

    if ((VRGL_PROJ.prj_units == VRGL_specunit) ||
        (units_in == units_out))
    {
      for (i=0;i<NN; i++)
        dRETB[i] = XX[i].npd;
    }
    else
    {
      for (i=0;i<NN; i++)
        dRETB[i] = XX[i].npd_eq;
    }
  }

  _FREE (XX);

  return OM_S_SUCCESS;
}


/*------------------------------------------------------------------*/
IGRint check_spec (IGRlong   *msg,
                   IGRshort  app,
                   IGRchar   *spec,
                   IGRchar   *err_ptr)
{
  IGRshort NN;

  err_ptr = NULL;

  if ( (strcmp (spec, "nozzle") == 0) ||
       (strcmp (spec, "NOZZLE") == 0) )       return 1;

  if( spec[0] == 0 || (strcmp(spec, " " ) == 0) )  return 0;

  /* TR179801140 & TR179801141 fixes */
  if(app == VR_PIPING)
  {
       struct VRPDB_spec_key  YY;
       struct VRPDB_spec      XX;
       strcpy (YY.spec_name, spec);
       YY.spec_no = VRPDB_UNDEF;

       VR$PDB_SPEC (p_msg = msg,
                    keyin = &YY,
                    p_num = &NN,
                    p_rec = &XX);

  }
  else if(app == VR_HVAC)
  {
       struct VRHDB_spec_key  YY;
       struct VRHDB_spec      XX;
       strcpy (YY.hvac_class, spec);
       YY.class_no = VRHDB_UNDEF;

       VR$HDB_SPEC (p_msg = msg,
                    keyin = &YY,
                    p_num = &NN,
                    p_rec = &XX);
  }
  else if(app == VR_RWAY)
  {
       struct VRRDB_spec_key  YY;
       struct VRRDB_spec      XX;
       strcpy (YY.vendor_code, spec);
       YY.vendor_no = VRRDB_UNDEF;

       VR$RDB_SPEC (p_msg = msg,
                    keyin = &YY,
                    p_num = &NN,
                    p_rec = &XX);
  }
  else return 0;
  /* end TR179801140 & TR179801141 fixes */

  if (NN > 0)  return 1;

  return 0;
}

end implementation Root;

