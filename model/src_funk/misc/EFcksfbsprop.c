/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */

#include "EMS.h"

/*
 Description
   Given a surface geometry and options, this function checks
   and appropriately sets the bs-properties specified by the
   caller in the options.

  Currently the following bs-props are supported.
  EMS_VAL_PLANAR    Is sf planar.
  EMS_VAL_PHY_CLSD  Is sf phy_closed.

  History   
           RC    04/06/88     Creation Date
           Sudha 07/09/93     Modified for BSprototypes anisfication
           SCW   02/13/97     Changed emsmacros inclusion to emsmacros_c

*/
#include "bserr.h"
#include "OMerrordef.h"
#include <math.h>
#include "emsmacros_c.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "bstst_plan.h"
#include "bssftstclsd.h"

void EFck_sf_bs_props (
     EFmsg,
     sf_geom,
     options)

 IGRlong                *EFmsg;
 struct IGRbsp_surface  *sf_geom;
 IGRushort      options;

{
   IGRvector    nvec;
   IGRlong      rc;

   *EFmsg = EMS_S_Success;

   if (options & EMS_VAL_PLANAR)
   {
     BStst_plan ( (sf_geom->u_num_poles * sf_geom->v_num_poles),
                  sf_geom->poles, sf_geom->weights, &sf_geom->planar,
                  nvec, &rc);
     EMerr_hndlr (BSERROR(rc), *EFmsg, EMS_E_BSerror, wrapup);

   } /* if (options & EMS_VAL_PLANAR) */

   if (options & EMS_VAL_PHY_CLSD)
   {
     BSsftstclsd (sf_geom, &rc);
     EMerr_hndlr (BSERROR(rc), *EFmsg, EMS_E_BSerror, wrapup);

   } /* if (options & EMS_VAL_PHY_CLSD) */

wrapup:

   return;

} /* void EFck_sf_bs_props () */

