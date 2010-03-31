/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include <stdio.h>
#include "EMSdef.h"
#include "OMmacros.h"
#include "emsplndef.h"
#include "emsmass.h"
#include "bsparameters.h"
#include "bserr.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "maidmx.h"
#include "bsdotp.h"

from EMSmassprop import EMretn_mass_prop,
                        EMget_objectid,
			EMstore_geometry,
                        EMrefxform,
                        EMload_mass_prop;

from GRowner import GRget_number_components,
                    GRget_components;

method EMareaprop(IGRlong 	       *msg;
                  IGRboolean       want_status;
                  IGRint           num_surfaces;
                  struct GRmd_env  *my_env;
                  IGRdouble        scaling_factor;
                  IGRvector        trans_vector;
                  IGRdouble        *out_int)
/*
Description
	This method returns the area properties of a comp surface about its
	centroid.

Return values
	EMS_S_Success if all's well
Notes

History
        Sudha   06/28/93        Modified for BSprototype ansification

        pp    02/17/90          Should the object be in a reference file
                                the properties were not being loaded
                                correctly into the mass property object.
        gupta 07/19/89          Changed for associativity.. etc.
                                Also declared fabs and dotp functions.
        PP      01/11/89        Fixed a problem wherein a 3by3 matrix was
                                being sent in to MAidmx which was
                                expecting a 4by4. This only occurs when
                                area properties of a plane which is normal
                                to global z axis is computed.
	    gk	11/23/87            Design date

*/

{
  IGRdouble             loc_trans_vect[3], tran_mat[9],
                        loc_sf[NUMB_PROPS];
  IGRdouble             dot_tol, z_axis[3];
  IGRlong               stat_OM, option, rc, i;
  void                  MSsurfmat(), MSsftosf();
  extern IGRboolean     IGEstop();
  IGRboolean            area_only, planar, validity;
  IGRboolean            interrupt= FALSE;
  IGRlong               EMtest_planar();
extern IGRdouble fabs() ;
  struct GRmd_env       loc_md_env;
  struct EMparms        sf_parm;
  IGRint                attempt_no = 0, only_one = 1, surf_index;
  OMuword               myclass_id;
  extern OMuword        OPP_EMScompsurf_class_id;
  GRobjid               *p_my_id;
  OM_S_CHANSELECT       notify_chan;
  struct GRid           *comp_GRids = NULL; 
  GRobjid               **comp_objids=NULL;
  struct GRid           mass_prop_obj;
  struct EMStest_plan_group data;

/* Initialize */

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  z_axis[0] = 0; z_axis[1] = 0; z_axis[2] = 1;
  surf_index = 0;

  /*
   * Do I have a areaprop object associated with me?
   * If so, then retrieve the properties and quit
   */

  stat_OM = om$make_chanselect(channame = "GRnotify.notification",
                               p_chanselect = &notify_chan);
  if (EMSmsgReport (stat_OM,"EMsfAreaProp: chanselect", FALSE))
      goto wrapup;

  validity = FALSE;
  stat_OM = om$send(msg = message EMSmassprop.EMretn_mass_prop(msg,
                          &validity, out_int),
                    p_chanselect = &notify_chan,
                    from = 0,
                    to = 100000);

  if (stat_OM && validity)	/* object found */
      return(OM_S_SUCCESS);
 
  /* No area prop object; so crunch dutifully */

/* begin pp */

/* First calculate the properties based on an identity matrix, and load
 * the same. Thereafter transform the properties based on incoming matrix.
 */


  loc_md_env = *my_env;
  
  loc_md_env.md_env.matrix_type = MAIDMX;
  MAidmx(msg,loc_md_env.md_env.matrix);

/* end pp (02/17/90) */


/*
  OM_BLOCK_MOVE(my_env->md_env.matrix, &loc_md_env.md_env.matrix[0],
                sizeof(IGRmatrix));
*/

  /* Get my ancestry */

  stat_OM = om$get_classid(object = me,
			  p_classid = &myclass_id);
  if(EMSmsgReport(stat_OM, "EMsfareaprop: myclass id", FALSE))goto wrapup;

  stat_OM = om$is_ancestry_valid(subclassid = myclass_id,
				superclassid = OPP_EMScompsurf_class_id);

  p_my_id = (GRobjid *)&my_id;

  if(stat_OM IS OM_S_SUCCESS)
   {
    IGRint comp_count, leaf_count;
    stat_OM = om$send (msg = message GRowner.GRget_number_components(msg,
                             &comp_count),
              targetid = my_id);
    if(EMSmsgReport(stat_OM, "EMsfareaprop: myclass id", FALSE))goto wrapup;

    if (comp_count)
    {
     extern OMuword OPP_EMSsubbs_class_id;

     comp_GRids = (struct GRid *) alloca(sizeof(struct GRid) *
                                        comp_count);

     comp_objids = (GRobjid **)alloca(sizeof(GRobjid *) * comp_count);
     if (!comp_GRids || !comp_objids) goto wrapup;
   

     stat_OM = om$send (msg = message GRowner.GRget_components(msg, my_env,
                             comp_GRids,comp_count, &comp_count,0,
                             comp_count),
                       targetid = my_id);
     if(EMSmsgReport(stat_OM, "EMsfareaprop: myclass id", FALSE))goto wrapup;

     leaf_count = 0;
     for (i=0;i<comp_count;i++)
     {
      if (EFisAncestryValid(msg, comp_GRids[i].objid, 
                            OM_Gw_current_OS, OPP_EMSsubbs_class_id, FALSE))
      {
       comp_objids[leaf_count] = (GRobjid *) &comp_GRids[i].objid;
       ++leaf_count;
      }
     }
     data.option = EMIndividual_Ids;
     data.data.sf_ids = comp_objids;
     data.num_sfs = leaf_count;
    }
   }
  else
   {
    data.option = EMIndividual_Ids;
    data.data.sf_ids = &p_my_id;
    data.num_sfs = 1;
   }

  stat_OM = EMtest_planar(msg, &data, &loc_md_env, &planar);
  if(EMSmsgReport(stat_OM, "EMsfareaprop: EMtest_planar", FALSE))
     goto wrapup;

  for (i=0; i<NUMB_PROPS; i++) loc_sf[i] = 0.0;

  if(NOT planar)
   {
    option = 2;
    area_only = TRUE;
    scaling_factor = 1.0;
    loc_trans_vect[0] = 0.0;
    loc_trans_vect[1] = 0.0;
    loc_trans_vect[2] = 0.0;
    stat_OM = om$send(msg = message EMSsurface.EMfaceintgrl(msg, 
                            want_status, FALSE, &surf_index, num_surfaces,
                            &loc_md_env, NULL, scaling_factor, NULL, NULL,
                            option, NULL, loc_sf),
                      targetid = my_id);

    if ((*msg == EMS_I_Interrupt) || ((interrupt = IGEstop())))
     {
      *msg = EMS_I_Interrupt; return (OM_S_SUCCESS);
     }
    if(EMSmsgReport (stat_OM,"EMcsareapr: faceint", FALSE) )goto wrapup;
   }
  else
   {
    option = 1;
    area_only = FALSE;

    /* Get a point on surface and surface normal */

    stat_OM = om$send(msg = message EMSsurface.EMget_point_on_surface(msg,
                            &loc_md_env, attempt_no, only_one,
                            loc_trans_vect, &sf_parm),
                      targetid = my_id);
    if(EMSmsgReport(stat_OM,"EMcsareapr: get point", FALSE) )goto wrapup;

    BSEXTRACTPAR(&rc, BSTOLCOLLINVEC, dot_tol);

    if (1 - fabs(BSdotp(&rc, z_axis, sf_parm.normal)) < dot_tol)
     {
      for (i=0;i<9;i++) tran_mat[i] = 0.0;
      tran_mat[0] = tran_mat[4] = tran_mat[8] = 1.0;
     }
    else MSsurfmat(&sf_parm.normal[0], tran_mat);

    stat_OM = om$send(msg = message EMSsurface.EMfaceintgrl(msg,
                            want_status, FALSE, &surf_index, num_surfaces,
                            &loc_md_env, NULL, scaling_factor, loc_trans_vect,
                            tran_mat, option, NULL, loc_sf),
                      targetid = my_id);
    if ((*msg == EMS_I_Interrupt) || ((interrupt = IGEstop())))
     {
      *msg = EMS_I_Interrupt; return (OM_S_SUCCESS);
     }
    if(EMSmsgReport(stat_OM,"EMcsareapr: faceint", FALSE) )goto wrapup;
   }

  MSsftosf(area_only, loc_trans_vect, scaling_factor, &tran_mat[0],
   	       &tran_mat[3], loc_sf, out_int);

  stat_OM = om$send(msg = message EMSmassprop.EMget_objectid(msg,
                          &mass_prop_obj),
                    p_chanselect = &notify_chan,
                    from = 0,
                    to = 100000);

  /* send it load message */

  stat_OM = om$send(msg = message EMSmassprop.EMload_mass_prop(msg, TRUE,
                          out_int),
                    targetid = mass_prop_obj.objid);
  if (EMSmsgReport (stat_OM,"EMssfaceint: massprop load",FALSE))
      goto wrapup;

/* begin pp */

   if (my_env->md_env.matrix_type != MAIDMX)
   {
    IGRdouble ref_point[3];
    IGRboolean validity;
    IGRdouble  in_glo_loc[9],glo_loc[9];
    
    

/*
 * Fudge.
 */
  for (i=0;i<6;i++)
    glo_loc[i] = out_int[i+5];

    glo_loc[6] = out_int[6]*out_int[10] - out_int[9]*out_int[7];
    glo_loc[7] = out_int[7]*out_int[8]  - out_int[10]*out_int[5];
    glo_loc[8] = out_int[5]*out_int[9]  - out_int[8]*out_int[6];

    for (i=0; i<NUMB_PROPS; i++) out_int[i] = 0.0;

    stat_OM = om$send(msg = message EMSmassprop.EMstore_geometry(msg,
                           glo_loc),
                     targetos = mass_prop_obj.osnum,
                     targetid = mass_prop_obj.objid);
    if (! (1 & stat_OM & *msg)) goto wrapup;

    stat_OM = om$send(msg = message EMSmassprop.EMrefxform(msg,
                          my_env,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix,
                          ref_point, out_int,
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

wrapup:

  if (!(1&stat_OM&*msg)) *msg = EMS_E_Fail;
   else
  *msg = EMS_S_Success;
  return(stat_OM);
}
end implementation EMSsurface;

