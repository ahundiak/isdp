/*
  DESCRIPTION

    This method return the locus of this geometric constraint
    back to the caller. It is a vector in the world coordinate system.

  HISTORY

    DLB :  01/15/93  :  Check for NULL_OBJID parent returned indicating 
                        topology mismatch.
    SS  :  10/23/91  :  Creation
*/

class implementation EMSpervcnstr;

#include "OMmacros.h"

#define CURVE_PARENT  0
#define PLANE_PARENT  1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern OMuword OPP_ASsource_class_id;

method EMgetgeomlocus (IGRlong *msg; IGRushort opts;
                       IGRshort *mattyp; IGRmatrix mat;
                       struct EMSgeomdata *geomlocus)
{
  IGRboolean aflag=0;
  IGRshort parent_mattyp[2];
  OMuint num_parents;
  IGRint i;
  IGRlong msg_loc, stat_OM;
  IGRdouble *normal;
  IGRmatrix parent_mat[2];
  struct GRid parents[2];
  OM_S_CHANSELECT chan_to_father;
  OM_S_OBJECT_LINKAGE objlist[2];
  GRclassid classid;
  GRspacenum osn;
  struct GRmd_env rfenv;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  aflag = pwIsActivationOn();

  if(aflag)
  {
    pwGetActiveModuleEnv(&rfenv);
  }

  /*
   * Obtain my parent(s).
   */

  EMmake_chanselect (NDfather_father, &chan_to_father);
  stat_OM = om$get_channel_objects (object = me,
             p_chanselect = &chan_to_father, count = &num_parents, size = 2,
             list = objlist);
  EMerr_hndlr (EMSerror (stat_OM) || num_parents < 1 || num_parents > 2, *msg,
   EMS_E_InvalidCase, ret_end);

  for (i=0; i<num_parents; i++)
  {
    stat_OM = om$send (msg = message NDnode.ASreturn_go (&parents[i],
               &parent_mattyp[i], parent_mat[i]),
               targetid = objlist[i].S_objid, targetos = objlist[i].osnum);
    EMomerr_exit (stat_OM, ret_end);

    if(aflag)
    {
      if(!EFisAncestryValid( &msg_loc, objlist[i].S_objid, objlist[i].osnum,
                             OPP_ASsource_class_id, FALSE))
      {
        parent_mattyp[i] = rfenv.md_env.matrix_type;
        memcpy(parent_mat[i], rfenv.md_env.matrix, sizeof(IGRmatrix));
      }
    }
  }

  /*
   * Obtain the geometry of the parent and extract the vector from
   * it. If a normal cannot be defined, return with an error code.
   */

  normal = geomlocus->vector;

  /*DLB 1/15/93*/
  if (parents[CURVE_PARENT].objid == NULL_OBJID ||
      ((num_parents-1 == PLANE_PARENT) && 
       parents[PLANE_PARENT].objid == NULL_OBJID))
  {*msg = EMS_E_InvalidCase; goto ret_end;}
      
  EMget_obj_normal (&msg_loc, NULL, 
   &parent_mattyp[CURVE_PARENT], parent_mat[CURVE_PARENT],
   &parents[CURVE_PARENT], 
   &parent_mattyp[PLANE_PARENT], parent_mat[PLANE_PARENT],
   num_parents-1 == PLANE_PARENT ? &parents[PLANE_PARENT] : NULL,
   normal);
  EMerr_hndlr (EMSerror (msg_loc) || msg_loc == EMS_I_NotFound, *msg,
   EMS_E_InvalidCase, ret_end);

  /*
   * Output the normal computed above. Check if the direction is opposing
   * the existing child-vector. If so, reverse the direction of the
   * computed normal vector.
   */

  if (ME.EMScnstr->cnstr_props & EMScnstr_negative_axis)
    for (i=X; i<=Z; i++)
      normal[i] = -normal[i];

  geomlocus->geomtype = GEOMDATA_VECTOR;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpervlocus");
  return (stat_OM);
}

end implementation EMSpervcnstr;
