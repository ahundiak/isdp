class implementation Root;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpstruct.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "igrdef.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dimdef.h"
#include "dim.h"
#include "dimmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "SKdef.h"
#include "SKinc.h"

extern GRclassid OPP_GRcompcurve_class_id, OPP_GR3dcircle_class_id;
extern GRclassid OPP_GR3dlineseg_class_id, OPP_GR3dcirarc_class_id;
extern GRclassid OPP_GR3dpoint_class_id, OPP_GRbcsubbc_class_id;
extern GRclassid OPP_SKcompcurve_class_id;
extern GRclassid OPP_SKpoint_class_id, OPP_SKline_class_id;
extern GRclassid OPP_SKarc_class_id, OPP_SKcircle_class_id;
extern GRclassid OPP_SKbspline_class_id;
extern GRclassid OPP_SKptvar_class_id;

from DMroot 	import get_dim_type;
from GRgraphics import GRdisplay;
from GRconnector import GRrigidconn;
from SKgeometry import SKconnect_to_pt; 
from SKmgr      import SKconnect_to_ptvar;
from SKvariable import SKputvar;
from SKexplicit import SKexplicit_clean_up;

void SKgetgeomtype (geomobj, os, type)
GRobjid geomobj;
GRspacenum os;
IGRushort *type;
{
  GRclassid classid;

  *type = NULL_GEOM;

  om$get_classid (objid = geomobj, osnum = os, p_classid = &classid);
  if (om$is_ancestry_valid (subclassid = classid,
       superclassid = OPP_SKpoint_class_id) == OM_S_SUCCESS)
    *type = SK_POINT;
  else if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_SKline_class_id) == OM_S_SUCCESS)
    *type = SK_LINE;
  else if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS)
    *type = SK_ARC;
  else if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_SKcircle_class_id) == OM_S_SUCCESS)
    *type = SK_CIRCLE;
  else if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_SKbspline_class_id) == OM_S_SUCCESS)
    *type = SK_BSPLINE;
  else if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_SKcompcurve_class_id) == OM_S_SUCCESS)
    *type = SK_COMPCURVE;

  return;
}


IGRboolean SKgetskclass (grclassid, skclassid, skclass_name)
GRclassid grclassid, *skclassid;
IGRchar *skclass_name;
{
  IGRboolean stat_func;
  IGRlong stat_OM;
  GRclassid loc_skclassid;
  
  stat_func = TRUE;

  if (om$is_ancestry_valid (subclassid = grclassid, 
       superclassid = OPP_GRcompcurve_class_id) == OM_S_SUCCESS)
    loc_skclassid = OPP_SKcompcurve_class_id;
  else if (om$is_ancestry_valid (subclassid = grclassid, 
            superclassid = OPP_GR3dlineseg_class_id) == OM_S_SUCCESS)
    loc_skclassid = OPP_SKline_class_id;
  else if (om$is_ancestry_valid (subclassid = grclassid, 
            superclassid = OPP_GR3dcirarc_class_id) == OM_S_SUCCESS)
    loc_skclassid = OPP_SKarc_class_id;
  else if (om$is_ancestry_valid (subclassid = grclassid, 
            superclassid = OPP_GR3dcircle_class_id) == OM_S_SUCCESS)
    loc_skclassid = OPP_SKcircle_class_id;
  else if (om$is_ancestry_valid (subclassid = grclassid, 
            superclassid = OPP_GR3dpoint_class_id) == OM_S_SUCCESS)
    loc_skclassid = OPP_SKpoint_class_id;
  else if (om$is_ancestry_valid (subclassid = grclassid, 
            superclassid = OPP_GRbcsubbc_class_id) == OM_S_SUCCESS)
    loc_skclassid = OPP_SKbspline_class_id;
  else
    stat_func = FALSE;

  if (stat_func)
    {
    if (skclassid)
      *skclassid = loc_skclassid;
    if (skclass_name)
      {
      stat_OM = om$get_classname (classid = loc_skclassid,
                classname = skclass_name);
      if (EMSerror (stat_OM))
        stat_func = FALSE;
      }
    }

  return (stat_func);
}

/*

Name
  SKgetgrclass

Abstract

Synopsis

Description
    It gives equivalent  GRclassid for SKclassid and its classname.

Return Value
    TRUE, if success
Notes

Index

Keywords

History
  11/03/93 : G Mallikarjuna : created

 */

IGRboolean SKgetgrclass (skclassid, grclassid, grclass_name)
GRclassid skclassid, *grclassid;
IGRchar *grclass_name;
{
  IGRboolean stat_func;
  IGRlong stat_OM;
  GRclassid loc_grclassid;

  stat_func = TRUE;

  if (om$is_ancestry_valid (subclassid = skclassid,
       superclassid = OPP_SKcompcurve_class_id) == OM_S_SUCCESS)
    loc_grclassid = OPP_GRcompcurve_class_id;
  else if (om$is_ancestry_valid (subclassid = skclassid,
            superclassid = OPP_SKline_class_id) == OM_S_SUCCESS)
    loc_grclassid = OPP_GR3dlineseg_class_id;
  else if (om$is_ancestry_valid (subclassid = skclassid,
            superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS)
    loc_grclassid = OPP_GR3dcirarc_class_id;
  else if (om$is_ancestry_valid (subclassid = skclassid,
            superclassid = OPP_SKcircle_class_id) == OM_S_SUCCESS)
    loc_grclassid = OPP_GR3dcircle_class_id;
  else if (om$is_ancestry_valid (subclassid = skclassid,
            superclassid = OPP_SKpoint_class_id) == OM_S_SUCCESS)
    loc_grclassid = OPP_GR3dpoint_class_id;
  else if (om$is_ancestry_valid (subclassid = skclassid,
            superclassid = OPP_SKbspline_class_id) == OM_S_SUCCESS)
    loc_grclassid = OPP_GRbcsubbc_class_id;
  else
    stat_func = FALSE;

  if (stat_func)
    {
    if (grclassid)
      *grclassid = loc_grclassid;
    if (grclass_name)
      {
      stat_OM = om$get_classname (classid = loc_grclassid,
                classname = grclass_name);
      if (EMSerror (stat_OM))
        stat_func = FALSE;
      }
    }

  return (stat_func);
}


/*
  DESCRIPTION

    This function determines the included geometry that is driven by
    the pair of input points. Two SKptvars will always vector to a unique
    geometry since only end-point continuity is permitted. Therefore a
    pair is always required. EXCEPTION: In the case the geometry class
    desired is SKpoint, only on ptid is required and only the first
    element in the 2-element array (ptid_pair) is looked at.

  HISTORY

    SS  :  10/09/91  : Creation
*/

#define FIRST  0
#define SECOND 1

#argsused
void SKget_included_geom (msg, opts, ptid_pair, geomclass, geomid)
IGRlong  *msg;
IGRushort opts;
GRobjid  *ptid_pair;
GRclassid geomclass;
GRobjid  *geomid;
{
  IGRint i, j, inxlim, counts[2];
  OMuint count;
  IGRlong stat_OM;
  GRobjid obj, geomlist[2][3];
  GRspacenum dumos;
  GRclassid objclass;
  OM_S_CHANSELECT chan_to_geoms; 

  *msg = EMS_I_NotFound;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
  inxlim = geomclass == OPP_SKpoint_class_id ? FIRST : SECOND;
  for (i=FIRST; i<=inxlim; i++)
    {
    count = 0;
    om$get_channel_count (objid = ptid_pair[i], p_chanselect = &chan_to_geoms,
     count = &count);
    if (!count)
      goto ret_end;

    counts[i] = 0;
    for (j=0; j<count; j++)
      {
      om$get_objid_at_index (objid = ptid_pair[i],
       p_chanselect = &chan_to_geoms, index = j, objidaddr = &obj,
       osnumaddr = &dumos);

      om$get_classid (objid = obj, p_classid = &objclass);
      if (om$is_ancestry_valid (subclassid = objclass,
           superclassid = geomclass) == OM_S_SUCCESS)
        {
        geomlist[i][counts[i]] = obj;
        counts[i]++;
        }
      }
    }

  *geomid = NULL_OBJID;
  if (inxlim == SECOND)
    {
    for (i=0; i<counts[FIRST]; i++)
      for (j=0; j<counts[SECOND]; j++)
        if (geomlist[FIRST][i] == geomlist[SECOND][j])
          *geomid = geomlist[FIRST][i];
    }
  else
    *geomid = geomlist[FIRST][FIRST];

  if (!IF_NULL_OBJID (*geomid))  
    *msg = EMS_I_Found;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMget_included_geom");
  return;
}


/*

Name
  EMcnvt_db_dim_units

Abstract

Synopsis
  long 		*msg	  (OUT)	   return message
  struct GRid 	*expid	  (IN)	   expression id
  double 	*val	  (IN/OUT) value of the expression to be converted.
  char 		*valtype  (IN)     type of the value
                                   GRIO_DISTANCE - linear value
                                   GRIO_ANGLE    - angular value
                                   NULL          - use the type of owned dimension to make
  				                   the decision.
  IGRboolean 	revcnv	  (IN)	   FALSE ==> convert from database to the dimension units
  				   TRUE ==> convert from dimension to the database units.

Description
    This function first determines if the input expression has a dimension
    as a geometric handle. If so, it converts the value passed in (assuming
    that it is in data-base units) into the units of the dimension (or
    vice-versa if the flag - revcnv is set to TRUE).

Return Value

Notes
  1. If there is no dimension handle owned by the expression, this routine will do nothing.
  2. The internal database units for angular dimensions are always RADIANS.
     The profile system uses DEGREES for angular dimensions.

Index

Keywords
  dimension, units
  
History
  01/31/91 : SS	           : Creation
  06/08/93 : Rajiv Agrawal : Added option of passing NULL valtype.  In this case,
  			     the dim_type of the dimension is used to find out whether
  			     the dimension is linear or angular.

 11/05/93 : Satya          : Now TEXT_WITH_LEADER with value_type DIM_ANGLE
                             is also considered as an angular dimension
                             TR -- 119307898

 */

#define MAINTAIN_DATA_BASE_UNITS -1

void EMcnvt_db_dim_units (msg, expid, val, valtype, revcnv)
long 		    *msg;
struct GRid *expid;
IGRdouble 	*val;
char 		    *valtype;
IGRboolean 	 revcnv;
{
  IGRchar 		unit_alias[GRIO_MAX_ALIAS_SIZE], 
  			working_unit_alias[GRIO_MAX_ALIAS_SIZE];
  OMuint		is_dimobj;
  IGRint 		db_type;
  IGRlong 		stat_func, msg_loc;
  struct DMenv_param 	dm_env_param;
  OM_S_CHANSELECT 	chan_to_comps;
  OM_S_OBJECT_LINKAGE 	dimobj;
  short			dim_type;
  char			*loc_valtype;
  struct  DMsenv_param  par_senv;
  IGRint                status;
  

  *msg = EMS_S_Success;
  stat_func = TRUE;

  /*
   * find the dimension handle that is owned by the expression.  If none exists,
   * we quit.
   */
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  is_dimobj = 0;
  stat_func = om$get_channel_objects (objid = expid->objid, osnum = expid->osnum,
                                      p_chanselect = &chan_to_comps, count = &is_dimobj, 
                                      size = 1, list = &dimobj);
  unit_alias[0] = NULL;
  if (is_dimobj)
  {
    dm_env_param.pri_unit = MAINTAIN_DATA_BASE_UNITS;
    dm_env_param.ang_unit = MAINTAIN_DATA_BASE_UNITS;
    dm$get_dim_param (type = DM_ENV_PARAM, dim_objid = dimobj.S_objid,
                      dim_osnum = dimobj.osnum, p_data = &dm_env_param);

    db_type = GRIO_UNITS_ARE_UNKNOWN;
    co$unit_database_type (osnum = expid->osnum, db_type = &db_type);

    /*
     * find valtype if the caller didn't pass it in
     */
    if (!valtype)
    {
      stat_func = om$send (msg = message DMroot.get_dim_type (&dim_type),
                           targetid = dimobj.S_objid,
                           targetos = dimobj.osnum,
                           senderid = NULL_OBJID);
      EMerr_hndlr ( EMSerror ( stat_func ), stat_func, OM_E_ABORT, ret_end );
      /*
       * Set the valtype depending on the type of the dimension.
       * Treat TEXT_WITH_LEADER(value_type == DIM_ANGLE) as angular dimension
       */
       status = dm$get_dim_param(type = DM_SENV_PARAM,
                                 dim_objid = dimobj.S_objid,
                                 dim_osnum = dimobj.osnum,
                                 p_data = (char *)&par_senv);
      EMerr_hndlr ( EMSerror ( status ), status, OM_E_ABORT, ret_end );
      if (dim_type == STACKED_ANGULAR || dim_type == STRINGED_ANGULAR ||
           dim_type == SINGLE_ARC_ANGLE || (dim_type == TEXT_WITH_LEADER &&
           par_senv.value_type == DIM_ANGLE))
        loc_valtype = GRIO_ANGLE;
      else
        loc_valtype = GRIO_DISTANCE;
    }
    else
      loc_valtype = valtype;

    if (strcmp (loc_valtype, GRIO_DISTANCE) == MATCH)
    {
      if (db_type == GRIO_UNITS_ARE_ENGLISH)
        strcpy(working_unit_alias, EMS_UNIT_INCHES);
      else
        strcpy(working_unit_alias, EMS_UNIT_MILLIMETERS);
        
      switch (dm_env_param.pri_unit)
      {
        case MEA_UNIT_FEET_INCHES:
          strcpy (unit_alias, EMS_UNIT_FEET);
          break;
        case MEA_UNIT_METERS:
          strcpy (unit_alias, EMS_UNIT_METERS);
          break;
        case MEA_UNIT_MM:
          if (db_type != GRIO_UNITS_ARE_METRIC)
            strcpy (unit_alias, EMS_UNIT_MILLIMETERS);
          break;
        case MEA_UNIT_INCHES:
          if (db_type != GRIO_UNITS_ARE_ENGLISH)
            strcpy (unit_alias, EMS_UNIT_INCHES);
      }
    }
    else if (strcmp (loc_valtype, GRIO_ANGLE) == MATCH)
    {
      strcpy (working_unit_alias, EMS_UNIT_DEGREES);
      switch (dm_env_param.ang_unit)
      {
        case ANG_UNIT_RAD:
          strcpy (unit_alias, EMS_UNIT_RADIANS);
          break;
      }
    }

    if (strlen (unit_alias))
    {
      stat_func = co$cvt_value_to_value (msg = &msg_loc, 
                       unit_type = loc_valtype,
                       osnum = expid->osnum, 
                       alias_to_cvt_from = revcnv ? unit_alias : working_unit_alias,
                       alias_to_cvt_to = revcnv ? working_unit_alias : unit_alias,
                       num_vals = 1, 
                       values_in = val, 
                       values_out = val);
      EMerr_hndlr (EMSerror (stat_func & msg_loc), *msg, EMS_E_Fail, ret_end);
      
      *msg = EMS_I_Modified;
    }
  }

ret_end:
  EMWRAPUP (*msg, stat_func, "EMcnvt_db_dim_units");
  return;
}

/*

Name
  SKcreate_skpoint

Abstract
  Create a skpoint at a given location and attach it to the owning geometry and SKmgr.
  
Synopsis

Description
  Create a SKpoint object with proper connections to the SKmgr and the SKgeometry.
  This is used in the when an arc or a bspline is converted to a profile element.
  
Return Value

Notes

Index

Keywords

History
  10/27/93 : Rajiv Agrawal : created

 */

#argsused
SKcreate_skpoint(long *msg, IGRushort opts, struct GRmd_env *md_env, 
                 short *matrix_type,
                 double *matrix,
                 struct GRvg_construct *const_list, 
                 int geom_index, int mgr_index,
                 GRobjid geomid, struct GRid *mgr_grid,
                 IGRpoint point_value,
                 GRobjid *sk_pt)
{
  IGRboolean            stat;
  int 			stat_OM;
  long 			msg_loc, owner_index;
  GRobjid               pt_id;
  enum GRdpmode         display_mode = GRbd;
  extern IGRboolean	EFplace_line_string();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  stat_OM = om$construct (classid = OPP_SKptvar_class_id,
                          p_objid = sk_pt, 
                          obj_osnum = mgr_grid->osnum,
                          osnum = mgr_grid->osnum);
  EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message SKgeometry.SKconnect_to_pt
                           (&msg_loc, NULL, *sk_pt, 0, geom_index), 
                     targetid = geomid, 
                     targetos = mgr_grid->osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
  
  stat_OM = om$send (msg = message SKmgr.SKconnect_to_ptvar
                          (&msg_loc, *sk_pt, NULL, 0, mgr_index),
                     targetid = mgr_grid->objid, targetos = mgr_grid->osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

  stat_OM = om$send (msg = message SKvariable.SKputvar
                          (&msg_loc, NULL, matrix_type, matrix, point_value),
                     targetid = *sk_pt, targetos = mgr_grid->osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

  stat = EFplace_line_string (geomid, const_list, 1, point_value, &pt_id, &msg_loc);
  EMerr_hndlr (!stat || !(1&msg_loc),*msg,EMS_E_Fail,ret_end);

  stat_OM = om$change_class (osnum = mgr_grid->osnum,
                             objid = pt_id,
                             classname = "SKpoint");
  EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);

  stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                          &md_env->md_env.matrix_type,
                          md_env->md_env.matrix, &display_mode, 
                          &md_env->md_id),
                     targetid = pt_id, targetos = mgr_grid->osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

  owner_index = NULL;
  stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                           mgr_grid, &owner_index),
                     targetid = pt_id, targetos = mgr_grid->osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
  /*
   * Connect the SKptvar to the newly created SKpoint.
   */
  stat_OM = om$send (msg = message SKgeometry.SKconnect_to_pt
                           (&msg_loc, NULL, *sk_pt, 0, 0), 
                     targetid = pt_id, targetos = mgr_grid->osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKcreate_skpoint" );
  return stat_OM;
}


/*

Name
  SKexp_dim_clean

Abstract

Synopsis

Description
    In case of reference files the dimensions attached are deleted when
    the reference file is deleted/detached.

Return Value
Notes

Index

Keywords

History
   01/09/95   ----  Satya ----- Created

 */


void SKexp_dim_clean(msg,dim_id,dim_os,md_env)
IGRlong 	*msg;
GRobjid		dim_id;
struct GRmd_env	*md_env;
GRspacenum	dim_os;
{

	IGRlong	msg_loc;
	OM_S_CHANSELECT	chan_to_owners;
	EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);

  	*msg = EMS_S_Success;
	om$send( msg = message SKexplicit.SKexplicit_clean_up( &msg_loc,md_env),
		       p_chanselect = &chan_to_owners,
		       from = 0, to = 0,
		       senderid = dim_id,
		       targetos = dim_os);
	return;
}
end implementation Root;

