/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "ma.h"
#include "madef.h" 
#include "emsmass.h"
#include "maoptsxfo.h"
#include "mainvmx.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdistptpt.h"
/*
  HISTORY
           pp        02/17/90     Made changes to EMedit_mass_prop so that
                                  orientation is properly stored in case
                                  of area properties.
           gupta     07/06/89     Creation Date
	   Sudha     06/28/93     Modified for BSprototype ansification
*/

method EMinitialize (IGRlong *EMmsg)

{
  IGRlong stat_OM, i; 
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  ME.EMSmassprop->mp_valid = FALSE;
  ME.EMSmassprop->density = 0.0;
  for (i=0; i<12; i++) 
       ME.EMSmassprop->mass_props[i] = 0.0;

  for (i=0; i<9; i++)
   {
    if ((i==0) || (i==4) || (i==8))
     {
      ME.EMSmassprop->glo_loc[i] = 1.0;
     }
    else
     {
      ME.EMSmassprop->glo_loc[i] = 0.0;
     }
   }

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMinitialize");
  return (stat_OM);
}

method EMget_objectid (IGRlong      *EMmsg;
                       struct GRid  *mp_objectid)

{
  IGRlong stat_OM; 
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  mp_objectid->objid = my_id;
  mp_objectid->osnum = OM_Gw_current_OS;

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMget_objectid");
  return (stat_OM);
}

method EMset_type (IGRlong *EMmsg;
                   IGRint  operation_type)
/* History
   Inasu    March 28, 1990   TR 90N0628   : added few lines for fix
*/
{
  IGRlong stat_OM; 
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
 
/* The following lines were inserted to fix TR 90N0628  */
  if((operation_type == MASS_PROPERTIES) && 
                    (ME.EMSmassprop->operation_type == AREA_PROPERTIES))
    ME.EMSmassprop->mp_valid = FALSE;
/* insertion over */

  ME.EMSmassprop->operation_type = operation_type;

  if (operation_type != MASS_PROPERTIES)
      me->axes_orient = 0;  /* area props */
wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMset_type");
  return (stat_OM);
}

method EMedit_mass_prop (IGRlong *EMmsg;
                         struct GRmd_env *my_env;
                         IGRboolean validity;
                         IGRdouble *mass_props;
                         IGRdouble density;
                         IGRpoint refer_point;
                         IGRdouble *glo_loc;
                         IGRlong   axes_orient)

{

  IGRlong            i, stat_OM, msg;
  OMuint             chan_count;
  IGRshort           dim=4;
  IGRdouble          scratch_1, scratch_2;
  IGRdouble          norm_1, norm_2, norm_3;
  IGRdouble          norm_4, norm_5, norm_6;
  IGRdouble          zero_tol;
  IGRdouble          scaling_2, scaling_3, scaling_4, scaling_5;
  IGRmatrix          inverse_matrix;
  IGRdouble          points[3];
  IGRdouble          props[NUMB_PROPS];
  IGRpoint           ref_pnt;
  IGRdouble          global_or[9], xpoints[9], ppoints[9];
  IGRboolean         status;
  static IGRdouble   zero_vect[3] = {0.0,  0.0,  0.0};
  OM_S_CHANSELECT    to_object;
  
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  status = OM_S_SUCCESS;

  stat_OM = om$make_chanselect (channame = "EMSmassprop.to_object",
                                p_chanselect = &to_object);
  if (! (1 & stat_OM)) goto wrapup;

  chan_count = 0;
  stat_OM = om$get_channel_count(object = me,
                                 p_chanselect = &to_object,
                                 count = &chan_count);
  if (! (1 & stat_OM)) goto wrapup;

  ME.EMSmassprop->mp_valid = validity;
  ME.EMSmassprop->axes_orient = axes_orient;

  for (i=0; i<NUMB_PROPS; i++) props[i] = mass_props[i];
  for (i=0; i<9; i++) global_or[i] = glo_loc[i];
  for (i=0; i<3; i++) ref_pnt[i] = refer_point[i];

  status = MAinvmx(&msg, &dim, my_env->md_env.matrix, inverse_matrix);
  if (! (1 & status & msg)) goto wrapup;

  if ((my_env->md_env.matrix_type != MAIDMX) && (chan_count))
   {
    BSEXTRACTPAR (&msg, BSTOLCLOSETOZERO, zero_tol);

    norm_1 = BSdistptpt(&msg, &inverse_matrix[0], zero_vect);
    norm_2 = BSdistptpt(&msg, &inverse_matrix[4], zero_vect);
    norm_3 = BSdistptpt(&msg, &inverse_matrix[8], zero_vect);

    scratch_1 = (norm_1 >= norm_2) ? (norm_1-norm_2) : (norm_2-norm_1);
    scratch_2 = (norm_1 >= norm_3) ? (norm_1-norm_3) : (norm_3-norm_1);

    if ((scratch_1 <= zero_tol) && (scratch_2 <= zero_tol))
     {
      i = 1;
      status = MAoptsxform(&msg, &i, &my_env->md_env.matrix_type,
                           inverse_matrix, &props[2], points);
      if (! (1 & status & msg)) goto wrapup;
      for (i=0; i<3; i++) props[2+i] = points[i];

      i = 1;
      status = MAoptsxform(&msg, &i, &my_env->md_env.matrix_type,
                           inverse_matrix, ref_pnt, points);
      if (! (1 & status & msg)) goto wrapup;
      for (i=0; i<3; i++) ref_pnt[i] = points[i];

      for (i=0; i<3; i++)
       {
        ppoints[i] = glo_loc[i] + refer_point[i];
        ppoints[3+i] = glo_loc[3+i] + refer_point[i];
        ppoints[6+i] = glo_loc[6+i] + refer_point[i];
       }

      i = 3;
      status = MAoptsxform(&msg, &i, &my_env->md_env.matrix_type,
                           inverse_matrix, ppoints, xpoints);
      if (! (1 & msg)) goto wrapup;

      norm_4 = BSdistptpt(&msg, points, &xpoints[0]);
      norm_5 = BSdistptpt(&msg, points, &xpoints[3]);
      norm_6 = BSdistptpt(&msg, points, &xpoints[6]);
      
      for (i=0; i<3; i++)
       { 
        global_or[i] = (xpoints[i] - points[i])/norm_4;
        global_or[3+i] = (xpoints[3+i] - points[i])/norm_5;
        global_or[6+i] = (xpoints[6+i] - points[i])/norm_6;
       }

      scaling_2 = norm_1 * norm_1;
      scaling_3 = scaling_2 * norm_1;
      scaling_4 = scaling_3 * norm_1;
      scaling_5 = scaling_4 * norm_1;

      props[0]  *=  scaling_3;
      props[1]  *=  scaling_3;
      props[11]  *=  scaling_2;
      props[14]  *=  scaling_4;
      props[15]  *=  scaling_4;
      props[16]  *=  scaling_4;

      if (me->operation_type == MASS_PROPERTIES)
       {
        props[5]  *=  scaling_5;
        props[6]  *=  scaling_5;
        props[7]  *=  scaling_5;
        props[8]  *=  scaling_5;
        props[9]  *=  scaling_5;
        props[10]  *=  scaling_5;
       }
      else
       {
/* begin pp */

        IGRdouble temp_axis[3];
        IGRdouble trans_zero_vect[3];
        IGRdouble *matrix;
        IGRshort *matrix_type;

        matrix = inverse_matrix;
        matrix_type = &my_env->md_env.matrix_type;

        i = 1;
        status = MAoptsxform(&msg, &i, matrix_type, matrix,
                             zero_vect, trans_zero_vect);
        if (! (1 & status & msg)) goto wrapup;

        status = MAoptsxform(&msg, &i, matrix_type, matrix,
                           &props[5], points);
        if (! (1 & status & msg)) goto wrapup;

        status = BSmkvec(&msg,temp_axis,trans_zero_vect,points);
        if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}
      
        status = BSnorvec(&msg, temp_axis);
        if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}

        for (i=0; i<3; i++) props[5+i] = temp_axis[i];
 
        i = 1;

        status = MAoptsxform(&msg, &i, matrix_type, matrix,
                             &props[8], points);
        if (! (1 & status & msg)) goto wrapup;

        status = BSmkvec(&msg,temp_axis,trans_zero_vect,points);
        if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}
      
        status = BSnorvec(&msg, temp_axis);
        if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}

        for (i=0; i<3; i++) props[8+i] = temp_axis[i];

/* end pp (02/17/90) */

       }
     }
   }

  for (i=0; i<NUMB_PROPS; i++)
       ME.EMSmassprop->mass_props[i] = props[i];

  ME.EMSmassprop->density = density;
  for (i=0; i<3; i++)
       ME.EMSmassprop->refer_pnt[i] = ref_pnt[i];

  for (i=0; i<9; i++)
       ME.EMSmassprop->glo_loc[i] = global_or[i];      

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMedit_mass_prop");
  return (status);
}

method EMupdate_props (IGRlong *EMmsg;
                       IGRdouble new_density)

{
  IGRlong stat_OM, i; 
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (ME.EMSmassprop->mp_valid)
     ME.EMSmassprop->mass_props[1] *= new_density/ME.EMSmassprop->density;

  for (i=5; i<11; i++)
     ME.EMSmassprop->mass_props[i] *= new_density/ME.EMSmassprop->density;

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMupdate_props");
  return (stat_OM);
}

method EMupdate_orient (IGRlong *EMmsg;
                        IGRdouble *new_orient)

{
  IGRlong stat_OM, i; 
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  for (i=0; i<9; i++)
     ME.EMSmassprop->glo_loc[i] = new_orient[i];
 
wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMupdate_orient");
  return (stat_OM);
}

method EMmpdisplay (IGRlong *EMmsg;
                    struct GRmd_env *my_env;
                    enum GRdpmode *display_mode)

{
  IGRlong stat_OM, msg; 
  IGRshort  mask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  IGRboolean         action;
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  action = (*display_mode == GRbd) ? TRUE : FALSE;

  if (! action)
   {
    stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                             &my_env->md_env.matrix_type,
                             my_env->md_env.matrix, 
                             display_mode, 
                             &my_env->md_id),
                      targetid = my_id);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);
   }

  stat_OM = om$send (msg = message GRvg.GRchgprops (&msg,
                           &action, &mask),
                     targetid = my_id);
  EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);

  if (action)
   {
    stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                             &my_env->md_env.matrix_type,
                             my_env->md_env.matrix, 
                             display_mode, 
                             &my_env->md_id),
                      targetid = my_id);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);
   }

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMmpdisplay");
  return (stat_OM);
}

method EMmpdelete (IGRlong *EMmsg;
                   struct GRmd_env *my_env)

{
  IGRlong stat_OM, msg; 
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  stat_OM = om$send(msg = message GRgraphics.GRdelete(&msg, my_env),
                    targetid = my_id);
  EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMmpdelete");
  return (stat_OM);
}

method EMstore_geometry (IGRlong *EMmsg;
                         IGRdouble *mp_geom)

{
  IGRlong stat_OM, i; 
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  for (i=0; i<9; i++)
       ME.EMSmassprop->my_geometry[i] = mp_geom[i];

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMstore_geometry");
  return (stat_OM);
}

method EMget_geometry (IGRlong *EMmsg;
                       IGRdouble *mp_geom)

{
  IGRlong stat_OM, i; 
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  for (i=0; i<9; i++)
       mp_geom[i] = ME.EMSmassprop->my_geometry[i];

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMget_geometry");
  return (stat_OM);
}

method EMget_orient (IGRlong      *EMmsg;
                     IGRlong      *orient)

{
  IGRlong stat_OM; 
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (me->mp_valid) *orient = me->axes_orient;
   
wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMget_orient");
  return (stat_OM);
}

method EMget_gloloc (IGRlong *EMmsg;
                     IGRdouble *glo_loc)

{
  IGRlong stat_OM, i; 
   
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  for (i=0; i<9; i++)
       glo_loc[i] = ME.EMSmassprop->glo_loc[i];

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMget_gloloc");
  return (stat_OM);
}

method EMload_prin_axes (IGRlong *EMmsg;
                         IGRdouble *mass_props)

{

  IGRint i, stat_OM;
  
  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  for (i=0; i<6; i++) me->p_axes[i] = mass_props[i+5];
  ME.EMSmassprop->operation_type = AREA_PROPERTIES;

wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMload_prin_axes");
  return (stat_OM);
}

end implementation EMSmassprop;
