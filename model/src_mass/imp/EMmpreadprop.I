/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

/*
    gupta : creation : 07/24/89

*/

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "madef.h"
#include "emsmacros.h"
#include "EMSmsgdef.h"
#include "csdef.h"
#include "emsmass.h"
#include "maoptsxfo.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bsmkvec.h"

from GRlinear import GRgetpolyline;
extern OMuword OPP_GRpoint_class_id;


method EMreadprop (IGRlong                *EMmsg;
                   struct GRmd_env        *my_env;
                   IGRint                 *option;
                   IGRint                 *prop_type;
                   IGRdouble              *prop;
                   IGRdouble              *ref_pnt;
                   IGRdouble              *glo_loc;
                   IGRdouble              *p_axes;
                   IGRdouble              *density)

/* *******************************************************************

History:
 ??/??/?? : Gupta : Creation
 02/17/90 : pp    : In cases when the  matrix was not an identity matrix
                    the principal axes for area properties were not
                    being returned. Made changes to effect the same to
                    be returned.
 06/28/93 : Sudha : Modified for BSprototype ansification


   ******************************************************************* */
{

IGRlong            stat_OM, i;
IGRlong            msg;
OMuint             chan_count;
IGRboolean         validity;
OM_S_CHANSELECT    to_object;

stat_OM = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;



stat_OM = om$make_chanselect (channame = "EMSmassprop.to_object",
                              p_chanselect = &to_object);
if (! (1 & stat_OM)) goto wrapup;

chan_count = 0;
stat_OM = om$get_channel_count(object = me,
                               p_chanselect = &to_object,
                               count = &chan_count);
if (! (1 & stat_OM)) goto wrapup;

*option = me->operation_type;

*prop_type = me->axes_orient;

if (me->operation_type == MASS_PROPERTIES)
    *density = me->density;
else
    *density = 0.0;

  if( !ME.EMSmassprop->mp_valid)
   {
    stat_OM = om$send(msg = message EMSmassprop.EMmprecalc( EMmsg),
                      targetid = my_id);
    EMerr_hndlr(!(1 & stat_OM & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
    me->mp_valid = TRUE;
   }

if ((my_env->md_env.matrix_type != MAIDMX) && (chan_count))
 {
  stat_OM = om$send (msg = message EMSmassprop.EMrefxform (&msg, my_env,
                           &my_env->md_env.matrix_type,
                           my_env->md_env.matrix, ref_pnt, prop, 
                           glo_loc, &validity),
                     targetid = my_id);
  if (! (1 & stat_OM & msg)) goto wrapup;
  if (! validity) goto evaluate;

/* begin pp */

/* In case of reference files the principal axes were not returned */

  if (me->operation_type == AREA_PROPERTIES)
   {
      IGRdouble temp_axis[3];
      IGRdouble trans_zero_vect[3];
      IGRdouble cent_point[3];
      IGRlong status;
      IGRdouble *matrix;
      IGRshort *matrix_type;
      static IGRdouble zero_vect[3] = {0.0, 0.0, 0.0};

      matrix = my_env->md_env.matrix;
      matrix_type = &my_env->md_env.matrix_type;
 
      i = 1;
      status = MAoptsxform(&msg, &i, matrix_type, matrix,
                           zero_vect, trans_zero_vect);
      if (! (1 & status & msg)) goto wrapup;

      status = MAoptsxform(&msg, &i, matrix_type, matrix,
                           &me->p_axes[0], cent_point);
      if (! (1 & status & msg)) goto wrapup;

      status = BSmkvec(&msg,temp_axis,trans_zero_vect,cent_point);
      if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}
      
      status = BSnorvec(&msg, temp_axis);
      if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}

      for (i=0; i<3; i++) p_axes[i] = temp_axis[i];
 
      i = 1;

      status = MAoptsxform(&msg, &i, matrix_type, matrix,
                           &me->p_axes[3], cent_point);
      if (! (1 & status & msg)) goto wrapup;

      status = BSmkvec(&msg,temp_axis,trans_zero_vect,cent_point);
      if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}
      
      status = BSnorvec(&msg, temp_axis);
      if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}

      for (i=0; i<3; i++) p_axes[3+i] = temp_axis[i];
   }


/* end pp (02/17/90) */

  if ((*prop_type == PRINCIPAL) &&
      (me->operation_type == MASS_PROPERTIES))
   {
    for (i=8; i<11; i++) prop[i] = 0.0;
   }
 }
else
 {
  evaluate:
  for (i=0; i<9; i++) glo_loc[i] = me->glo_loc[i];

  for (i=0; i<8; i++) prop[i] = me->mass_props[i];

  if((*prop_type != PRINCIPAL) || (me->operation_type != MASS_PROPERTIES))
   {
    for (i=8; i<11; i++) prop[i] = me->mass_props[i];
   }
  else
   {
    for (i=8; i<11; i++) prop[i] = 0.0;
   }

  for (i=11; i<NUMB_PROPS; i++)
       prop[i] = me->mass_props[i];
	
  if (me->operation_type == AREA_PROPERTIES)
   {
    for (i=0; i<6; i++) p_axes[i] = me->p_axes[i];
   }

  if ((*prop_type == GENERAL) || (me->operation_type != MASS_PROPERTIES))
   {
    for (i=0; i<3; i++) ref_pnt[i] = me->refer_pnt[i];
   }
  else
   {
    for (i=0; i<3; i++) ref_pnt[i] = me->mass_props[2+i];
   }
 }

/*
 * If chan_count is true then it means that this designator does not
 * correspond to an accumulated property.
 */


 if (me->operation_type == MASS_PROPERTIES) 
 {
  if (chan_count)
  {
   prop[16] = prop[2];
   prop[17] = prop[3];
   prop[18] = prop[4];
   prop[19] = 0.01234; /* Signal that we are returning center of volume */
  }
  else
  {
    OM_S_CHANSELECT to_comps;
    OMuint comp_count=0;
    IGRlong msg_loc,status;

    EMmake_chanselect (GRcmpowner_to_components, &to_comps);

    status = om$get_channel_count(objid = my_id,
                                  p_chanselect = &to_comps,
                                  count = &comp_count);
    if (comp_count == 8) /* We are storing the centroid of volume */
    {
     struct GRid cent;
     IGRint action;
     struct IGRpolyline py;
     IGRdouble ptsbuff[6];

     py.points = ptsbuff;

     cent.objid = NULL_OBJID;
     status = om$get_objid_at_index(objid=my_id,
                                    index = 7,
                                    objidaddr = &cent.objid,
                                    osnumaddr = &cent.osnum,
                                    p_chanselect = &to_comps);
     if (cent.objid != NULL_OBJID)
     {
      if (EFisAncestryValid(EMmsg, cent.objid, cent.osnum, 
                          OPP_GRpoint_class_id, FALSE))
      {
       status = om$send (msg = message GRlinear.GRgetpolyline(&msg_loc,
                         &my_env->md_env.matrix_type, 
                         my_env->md_env.matrix, 
                         &action,
                         &py),
                        targetid = cent.objid,
                        targetos = cent.osnum);
       EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

       prop[16] = ptsbuff[0];
       prop[17] = ptsbuff[1];
       prop[18] = ptsbuff[2];
       prop[19] = 0.01234;
      }
     }
    }
    
  }
 }
 
wrapup:
  EMWRAPUP (stat_OM, *EMmsg, "EMSmassprop.EMreadprop");
  return (stat_OM);
}	

end implementation EMSmassprop;
