
/* $Id: VRXoptcode.I,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRXoptcode.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRXoptcode.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:43:08  pinnacle
# Created: vrpdu/VRXoptcode.I by hverstee for route
#
 *
 * History:
 *  MM/DD/YY   AUTHOR  DESCRIPTION
 *  01/17/96   tlb    Add prototypes
 *                    Change VRget_opt_code_txt to ANSII style
 *
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

/*
#define  MY_DEBUG
*/

extern
struct VRPDB_project   VRGL_PROJ;
extern
IGRint                 VRGL_specunit;


/**********************************************/
/*   dynamic cache, refilled at each call     */
%safe
static
short         nOPT = 0;
static
short        *VROptCodes = NULL;
%endsafe
/**********************************************/

/*********************************************************************/
/*                                                                   */
/* This routine extracts the list of possible option codes and       */
/* code texts for given component.                                   */
/*                                                                   */
/*********************************************************************/       
IGRint VRget_opt_code_txt ( 
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* Piping only                       (I) */
      IGRchar     *comp_code,  /* Piping component code             (I) */
      IGRchar     *specname,   /* Piping spec name                  (I) */
      IGRdouble   size_g,      /* green dia                         (I) */
      IGRdouble   size_r,      /* red dia                           (I) */
      IGRshort    **opt_codes, /* code numbers                      (O) */
      IGRchar     **opt_txt,   /* code text                         (O) */
      IGRshort    *opt_cnt,    /* number of optcodes                (O) */
      IGRchar     *err_ptr     /* Error message buffer              (O) */
                           )
{
  IGRint       sts, i;
  IGRdouble    SIZE_1, SIZE_2;
  IGRint       proj_no;
  IGRshort     NN;
  IGRshort     snum;
  IGRdouble    dd1, dd2;

  struct VRPDB_comps_key  YY;
  struct VRPDB_comps     *XX;

   /* Initialize */

  *opt_cnt = 0;

  if ( application != VR_PIPING )
      return OM_E_INVARG;

  sts = VRenq_proj_units();

  proj_no = 0;          /*    NOT USED   */

  sts = Get_piping_spec_units( proj_no, specname,err_ptr);
  if(sts != 1)
  {
    *msg = VR_E_DbShortErrMsg;
    return (OM_E_ABORT);
  }

  if( VRGL_PROJ.prj_units != VRGL_specunit )
  {
    SIZE_1 = get_allowed_npd(VRGL_PROJ.prj_units,VRGL_specunit,size_g,
                                   specname,proj_no,err_ptr);
    SIZE_2 = get_allowed_npd(VRGL_PROJ.prj_units,VRGL_specunit,size_r,
                                   specname,proj_no,err_ptr);      
  }
  else
  {
    SIZE_1 = size_g;
    SIZE_2 = size_r;
  }

  VR$PDB_SNUM (p_nam = specname,
               p_num = &snum);

  dd1 = SIZE_1;
  dd2 = SIZE_2;
  if (dd1 == dd2) dd2 = 0.0;

  strcpy (YY.comp_code, comp_code);
  YY.option = VRPDB_UNDEF;

  VR$PDB_COMP (p_msg = msg,
               spec  = snum,
               keyin = &YY,
               dia1  = dd1,
               dia2  = dd2,
               p_num = &NN);
  if ((*msg != MSSUCC) || (NN == 0)) return OM_E_ABORT;

  if (NN > nOPT)
  {
    if (VROptCodes == NULL)
      VROptCodes = _MALLOC (NN, short);
    else
      VROptCodes = _REALLOC (VROptCodes, NN, short);

    nOPT = NN;
  }

  XX = _MALLOC (NN, struct VRPDB_comps);

  VR$PDB_COMP (p_msg = msg,
               spec  = snum,
               keyin = &YY,
               dia1  = dd1,
               dia2  = dd2,
               p_num = &NN,
               p_rec = XX);

  for (i=0; i<NN; i++)
    VROptCodes[i] = XX[i].key.option;

  _FREE (XX);

  *opt_cnt = NN;

  *opt_codes = VROptCodes;
  *opt_txt = (char *)NULL;

  return OM_S_SUCCESS ;
}

end implementation Root;
