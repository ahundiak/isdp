/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmass.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "madef.h"
#include "gocmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "EMSpromacros.h"
#include "maidmx.h"
#include "bseig3x3.h"

from EMSmassprop import EMretn_mass_prop,
                        EMstore_geometry,
                        EMget_objectid,
			EMrefxform,
                        EMupdate_orient,
                        EMload_mass_prop;

method EMmassprop(IGRlong           *msg;
                  IGRint            num_surfaces;
                  IGRdouble         sld_range;
                  struct GRmd_env   *my_env;
                  IGRdouble         scaling_factor;
		          IGRvector         trans_vector;
		          IGRdouble	        *density;
                  IGRdouble         *mass_int)
/*
Descrpition
	If the surface is closed in both u and v directions, this
	method returns the "effective" mass properties of the surface

History:
	gk	11/12/87	the begining
	gk	3/17/88		compute mass props of cs that are
                    not closed too!
    gupta 07/19/89  Changed for associativity.. etc.
        Sudha   06/28/93        Modified for BSprototype ansification
*/

{
  IGRlong               stat_OM, i, option, mysize;
  IGRint                surf_index;
  IGRdouble             loc_sf[NUMB_PROPS], loc_mass[NUMB_PROPS];
  IGRdouble             eig_matrix[3][3];
  IGRdouble             dest_glo_loc[9];
  IGRdouble             tol, negtol, sum;
  struct GRmd_env       loc_md_env;
  void                  MSsftoms();
/*  void                MSaccprop();*/
  struct IGRbsp_surface *surf = NULL;
  OM_S_CHANSELECT       notify_chan;
  struct GRid           mass_prop_obj;
  IGRboolean            not_closed, validity;
  static IGRdouble      identity_matrix[9] = { 1.0,  0.0,  0.0, 
                                               0.0,  1.0,  0.0, 
                                               0.0,  0.0,  1.0 };

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  surf_index = 0;
  option = 0;		/* mass properties */

  /*
   * Do I have a massprop object associated with me?
   * If so, then retrieve the properties and quit
   */

  stat_OM = om$make_chanselect(channame = "GRnotify.notification",
                               p_chanselect = &notify_chan);
  if (EMSmsgReport (stat_OM,"EMssMassProp: chanselect", FALSE))
      goto wrapup;

  validity = FALSE;
  stat_OM = om$send(msg = message EMSmassprop.EMretn_mass_prop(msg,
                          &validity, loc_mass),
                    p_chanselect = &notify_chan,
                    from = 0,
                    to = 100000);

  if (stat_OM && validity)	/* object found */
   {
    /* if densities are different then what is to be done */
/************************************************************
    MSaccprop(loc_mass, mass_int);
************************************************************/
    ems$accprop(
         propobj1 = loc_mass,
         propobj2_cumprop = mass_int);
    return(OM_S_SUCCESS);
   }

  /* No mass prop object; so crunch dutifully */

  BSEXTRACTPAR(msg, BSTOLBASIS, tol);
  tol *= 5.0;
  negtol = -tol;

/* begin pp */

/* First calculate the properties based on an identity matrix, and load
 * the same. Thereafter transform the properties based on incoming matrix.
 */


  loc_md_env = *my_env;
  
  loc_md_env.md_env.matrix_type = MAIDMX;
  MAidmx(msg,loc_md_env.md_env.matrix);

/* end pp (02/17/90) */

  stat_OM = om$send(msg = message GRvg.GRgetsize(msg,
                          &loc_md_env.md_env.matrix_type,
                          loc_md_env.md_env.matrix,
                          &mysize),
                    targetid = my_id);
  if (EMSmsgReport (stat_OM,"EMssmasspr: getsiz error", FALSE))
                    goto wrapup;

  surf = (struct IGRbsp_surface *)om$malloc(size = mysize);
  if(!surf)
   {
    *msg = EMS_E_NoDynamicMemory;
    stat_OM = OM_E_ABORT;
    goto wrapup;
   }

  stat_OM = om$send(msg = message GRvg.GRgetgeom(msg,
                          &loc_md_env.md_env.matrix_type,
                          loc_md_env.md_env.matrix,
                          ( IGRchar * )surf),
                    targetid = my_id);
  if (EMSmsgReport (stat_OM,"EMssmasspr:get geom error", FALSE))
      goto wrapup;

  /* Is this surface closed in both directions? */

  not_closed = FALSE;
  if (NOT (surf->u_phy_closed AND surf->v_phy_closed))
   {
    ex$message(field = ERROR_FIELD, msgnumb = EMS_E_SurfaceNotClosed)
    ex$message(field = PROMPT_FIELD, msgnumb = EMS_I_WarnSfNotClosedCont)
    not_closed = TRUE;
   }

  /*
     3/17/88   GK;
     surface may not be closed but compute the mass props anyway. But a
     smart alec intentionally using this Achilles heel will be rewarded
     with screwed up numbers. "Garbage in garbage out"
  */

  for (i=0; i<NUMB_PROPS; i++) loc_sf[i] = 0.0;

  stat_OM = om$send(msg = message EMSsurface.EMfaceintgrl(msg, TRUE,
                          FALSE, &surf_index, num_surfaces, &loc_md_env,
                          surf, scaling_factor, trans_vector, NULL,
                          option, density, loc_sf),
                    targetid = my_id);
  if (EMSmsgReport (stat_OM, "EMssmasspr: EMfaceintgrl", FALSE))
                    goto wrapup;
  if(! (1 & *msg))goto wrapup;

  /* Ensure that properties are for "solid" */

  if (loc_sf[0] < 0.0)
   {
    for(i=0; i<11; i++) loc_sf[0] *= -1.0;
   }
  if (loc_sf[11] < 0.0) loc_sf[11] *= -1.0;

  MSsftoms(trans_vector, scaling_factor, loc_sf, loc_mass);
/*********************************************************************
  MSaccprop(loc_mass, mass_int);
*********************************************************************/
  ems$accprop(
      propobj1 = loc_mass,
      propobj2_cumprop = mass_int);     
/* check if it is a planar surface and get the hell out 'cause it get into a 
   infinite loop in BSeig3x3() */

  sum=0.0;
  for(i=5; i<11;i++)
    sum += loc_sf[i];

  if(sum == 0.0)
    {
    fprintf(stderr,"cannot calculate mass properties for plane\n");
    stat_OM=0;
    goto wrapup;
    }

  stat_OM = om$send(msg = message EMSmassprop.EMget_objectid(msg,
                          &mass_prop_obj),
                    p_chanselect = &notify_chan,
                    from = 0,
                    to = 100000);


  /* send it load message */

  for (i=0; i<9; i++) dest_glo_loc[i] = identity_matrix[i];

  eig_matrix[0][0] =  mass_int[5];
  eig_matrix[0][1] = -mass_int[8];
  eig_matrix[0][2] = -mass_int[10];

  eig_matrix[1][0] = -mass_int[8];
  eig_matrix[1][1] =  mass_int[6];
  eig_matrix[1][2] = -mass_int[9];

  eig_matrix[2][0] = -mass_int[10];
  eig_matrix[2][1] = -mass_int[9];
  eig_matrix[2][2] =  mass_int[7];


  BSeig3x3 (eig_matrix, (IGRint *)&stat_OM, &mass_int[5], (IGRvector *)dest_glo_loc, msg);

  mass_int[8] = 0.0;
  mass_int[9] = 0.0;
  mass_int[10] = 0.0;

  stat_OM = om$send(msg = message EMSmassprop.EMload_mass_prop(msg, TRUE,
                          mass_int),
                    targetid = mass_prop_obj.objid);
  if (EMSmsgReport (stat_OM,"EMssfaceint: massprop load",FALSE))
                    goto wrapup;

  for (i=0; i<9; i++)
   {
    if ((dest_glo_loc[i] <= tol) && (dest_glo_loc[i] >= negtol))
         dest_glo_loc[i] = 0.0;
   }

  stat_OM = om$send(msg = message EMSmassprop.EMupdate_orient(msg,
                          dest_glo_loc),
                    targetid = mass_prop_obj.objid,
                    targetos = mass_prop_obj.osnum);
  if (EMSmsgReport (stat_OM, "EMcsfaceint: update orient", FALSE))
                    goto wrapup;

/* begin pp */

   if (my_env->md_env.matrix_type != MAIDMX)
   {
    IGRdouble ref_point[3];
    IGRboolean validity;
    IGRdouble  in_glo_loc[9];
    
    for (i=0; i<NUMB_PROPS; i++) mass_int[i] = 0.0;

/*
 * Fudge.
 */

    stat_OM = om$send(msg = message EMSmassprop.EMstore_geometry(msg,
                           dest_glo_loc),
                     targetos = mass_prop_obj.osnum,
                     targetid = mass_prop_obj.objid);
    if (! (1 & stat_OM & *msg)) goto wrapup;

    stat_OM = om$send(msg = message EMSmassprop.EMrefxform(msg,
                          my_env,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix,
                          ref_point, mass_int,
                          in_glo_loc,
                          &validity),
                       targetid = mass_prop_obj.objid,
                       targetos = mass_prop_obj.osnum);
    if (EMSmsgReport (stat_OM,"EMssfaceint: massprop refxform",FALSE))
       goto wrapup;
    if (!validity)
    {
      *msg = EMS_E_Fail;
      stat_OM = OM_E_ABORT;
      goto wrapup;
    }
   }
/* end pp (02/17/90) */

  if(not_closed) mass_int[13] = -5.0;

wrapup:

  if (surf) om$dealloc (ptr = surf);
  return(stat_OM);
}

end implementation EMSsubbs;

