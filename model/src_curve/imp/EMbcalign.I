/*
 Description

 This method is used to align two curves
 given the curves, endpoints indicating which endpoints
 to align, and the alignment mode:
               
     0:  modify 1st curve
     1:  modify 2nd curve
     2:  modify both curves and fix end points
     3:  modify both curves and don't fix end points

 History

    RC : 9/28/86  : Creation Date
   rlw : 03/18/87 : Modified options to pass to math
   rlw : 06/11/87 : Repaired tolerance restoration.        
   rlw : 01/06/88 : Totally reworked, renamed it from EMbcalign
    Sudha  06/16/93     Modified for BSprototype ansification
 */

class implementation GRsubbc;

#include "EMS.h"
#define DEBUG 1

#if DEBUG
#include <stdio.h>
#endif
#include "bs.h"
#include "msdef.h"
#include "gocmacros.h"		/* GRgetasbsg macro */
#include "bsfreecv.h"
#include "bsalloccv.h"
#include "bsaligncvt.h"

method EMalign_curve(
 struct		GRlc_info *my_curve;
 IGRpoint	my_end;
 struct		GRlc_info *his_curve;
 IGRpoint	his_end;
 IGRlong	mode;
 IGRlong	*msg)

{
 extern  IGRboolean  GRabsg_del_all();
 IGRboolean	status;
 IGRlong	sts, loc_msg;
 struct		IGRbsp_curve *curve_1, *curve_2;
 struct		IGRbsp_curve *mod_curve_1, *mod_curve_2;
/*
 * Initialize
 */
 *msg = MSSUCC;
 curve_1 = NULL;
 mod_curve_1 = NULL;
 mod_curve_2 = NULL;
/*
 * Get his geometry
 */
 sts = EMget_the_geometry(
   his_curve,
   TRUE,
   FALSE,
   FALSE,
   my_id,
   &curve_2,
   msg);
/*
 * Get my geometry
 */
 {
  struct	GRmdenv_info *mdenv_info;

  mdenv_info = &my_curve->module_info.md_env;
  GRgetabsg(
    msg,
    &mdenv_info->matrix_type, 
    mdenv_info->matrix,
    (IGRchar **) &curve_1,
    i);
   if (! (1 & *msg)) goto wrapup;
 }
/*
 * Allocate memory for the modified curves
 */
 {

  BSalloccv(
    curve_1->order,
    curve_1->num_poles,
    curve_1->rational,
    0,
    &mod_curve_1,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
  BSalloccv(
    curve_2->order,
    curve_2->num_poles,
    curve_2->rational,
    0,
    &mod_curve_2,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
     *msg = MANOMEMORY;
     goto wrapup;
    }
 }
/*
 * Call the math
 */
 {
  IGRlong	new_mode;

  switch (mode)
   {
    case 0:
     new_mode = 2;
     break;
    case 2:
     new_mode = 0;
     break;
    default:
     new_mode = mode;
     break;
   }
  BSaligncvt(
    curve_1,
    curve_2,
    my_end,
    his_end,
    new_mode,
    mod_curve_1,
    mod_curve_2,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
#if DEBUG
     fprintf(stderr, "\nBSaligncvt failure, rc = %d", loc_msg);
#endif
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Post my modified geometry if I have changed
 */
 if ((mode != 1) &&
     mod_curve_1)
  {
   GRobjid	newobjid;
   struct	GRpost_info info;

   info.construct_flag = FALSE;
   sts = om$send(
     msg = message GRvg.GRpostabsg(
      msg,
      &my_curve->module_info,
      &info,
      (IGRchar *) mod_curve_1,
      &newobjid),
     targetid = my_id);
    if (! (1 & sts)) goto wrapup;
  }
/*
 * Post his modified geometry if he has changed
 */
 if ((mode != 0) &&
     mod_curve_2)
  {
   GRobjid	newobjid;
   struct	GRid *id;
   struct	GRpost_info info;

   info.construct_flag = FALSE;
   id = &his_curve->located_obj;
   sts = om$send(
     msg = message GRvg.GRpostabsg(
      msg,
      &his_curve->module_info,
      &info,
      (IGRchar *) mod_curve_2,
      &newobjid),
     targetid = id->objid, 
     targetos = id->osnum); 
    if (! (1 & sts)) goto wrapup;
  }
/*
 * eof
 */
wrapup:
 if (curve_2) free(curve_2);
 if (mod_curve_1)
  {
   status = BSfreecv(
    &loc_msg, 
    mod_curve_1);
   status = GRabsg_del_all();
  }
 if (mod_curve_2)
  {
   status = BSfreecv(
    &loc_msg, 
    mod_curve_2);
  }
 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation GRsubbc;
