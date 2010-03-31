/*

Name
  EMcreate_dimension_constraint

Abstract
  Creates a dimensional constraint (both 2D and 3D)
  
Synopsis
  long         *msg	o	return code (OUT)
  IGRushort    options  i 	SK_DIMCNSTR_NODISPLAY - no
                                display of any kind will be performed.
  struct GRmd_env *md_env	module environment  (IN)
  struct GRid     *dimid	GRid of the dimension handle (IN)
  struct GRid     *cnstrid 	GRid of the created constraint (OUT)
  IGRushort       *cnstr_type	type of the constraint  (OUT)

Description
    This function is the means of adding dimensional constraints in the system
    (both 2D and 3D).

Return Value
  EMS_S_Success		- all went well.
  EMS_I_BadElement	- measurement element is not parametric
  EMS_I_BadPlane	- incompatible dimensioning plane
  EMS_I_NotSupported	- dimension constriant not supported
  EMS_I_InvalidCase	- invalid connections found in the graph
  EMS_I_FullyConstrained  - Profile is fully constrained.
  EMS_I_NoSolution	- no solution found.
  EMS_I_Redundant	- conflicting constraints detected.
  EMS_I_NoStackMemory	- insufficient memory
  EMS_I_Cycle 		- cyclic dependency found
  
Notes
  Please access this function thru the macro sk$create_dimension_constraint 
  defined in SKmacros.h
  
Index

Keywords
  dimension, profile, constraint
  
History
  05/09/91 : Siki : The original file EFcreate_dimensional_constraint re-written to take
                    care of Oh! so many things.
  06/10/92 : Rajiv Agrawal : Changed the code to take care of measurement axis
                             constraint. 
  08/27/93 : Rajiv Agrawal : Added std doc header and implemented Satya's change for 
                             TR119301536 (symbology was messing up the constraint).
  12/3/93  : Satya  : TR11926180  Changed the code to avoid creation of
			    Driving Dimensions in case of non associative points
  01/10/94 : Rajiv Agrawal : Implemented RADIAL_DIAMETER, CIRCULAR_DIAMETER & LINEAR_DIAMETER
                             cases.  
  01/10/94 : Kapil Singh : Replaced expression.create by expression.modify
                           to prevent the overconstrained equation set problem.
  01/30/94 : Rajiv Agrawal : Included <alloca.h>.   
  03/09/94 : Satya         : Changed code to avoid creation of redundant 
		             assoc grounds. --- TR119307713  
  03/22/95 : Siki          : Removed the sleep and erase-hilite while displaying
                             conflicting constraints.
  06/07/95 : Satya         : The change made for TR119307713 being removed
		             due to TR# 119525542

 */

class implementation SKconstraint;

#include <alloca.h>
#include <math.h>
#include "OMmacros.h"
#include "godef.h"
#include "nddef.h"
#include "dpmacros.h"
#include "dimplan.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "dim.h"
#include "dimsrc.h"
#include "dimcomplex.h"
#include "diminfo.h"
#include "dimplcmacros.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "SKdef.h"
#include "DIdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "EMSasprops.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "asbox.h"

#define ORIGIN  0
#define MEASURE 1
#define AXIS	2
#define AXIS_1  0
#define AXIS_2  1

#define FIRST   0
#define SECOND  1

#define X 0
#define Y 1
#define Z 2

extern GRclassid OPP_EMSdatpln_class_id, OPP_EMAdatpln_class_id;
extern GRclassid OPP_SKconstraint_class_id, OPP_EMScnstr_class_id;
extern GRclassid OPP_SKifptpt_class_id, OPP_SKhvptpt_class_id;
extern GRclassid OPP_SKaxisptpt_class_id;
extern GRclassid OPP_SKrelang_class_id, OPP_SKfixang_class_id;
extern GRclassid OPP_SKaxisfixang_class_id;
extern GRclassid OPP_SKradial_class_id;
extern GRclassid OPP_EMSlndmcnstr_class_id, OPP_EMSangcnstr_class_id;
extern GRclassid OPP_EMSparamgm_class_id, OPP_EMSparampt_class_id;
extern GRclassid OPP_GRbspline_class_id;
extern GRclassid OPP_GRcoords_class_id;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from DMroot     import get_info;
from DMsrc      import DMgive_src_info;
from SKmgr      import SKgetornt, SKmergemgr;
from SKgeometry import SKgetmgr;
from EMScnstr   import EMinit, EMvalidate;
from expression import NDgive_value, modify;

EMcreate_dimension_constraint (msg, options, md_env, dimid,
                               cnstrid, cnstr_type)
IGRlong         *msg;
IGRushort       options;
struct GRmd_env *md_env;
struct GRid     *dimid, *cnstrid;
IGRushort       *cnstr_type;
{
  IGRboolean 		unidir, angdim, raddim, merged, is_goodpln, are_goodplns[3][2];
  IGRboolean 		vg_cnstr, is_valid_cnstr, skip_origin;
  IGRchar 		*moreinfo;
  IGRushort 		need_geomtype, grid_geomtype, grid_geomtypes[3][2];
  IGRushort 		cnstr_props, loc_opts;
  IGRshort 		cnstr_level;
  IGRint 		i, j, loc_i, loc_j;
  IGRint 		inx, tmpnum, count, num_grids[3], num_parids[3], tot_num_parids;
  IGRint 		num_conflict_cnstr;
  IGRlong 		val_msg_loc, msg_loc, stat_OM;
  GRobjid 		mgrobj, mgrobjs[3][2], geom_parids[4], parids[3][2], tot_parids[6];
  GRobjid 		tempobj, driven_mgr=NULL_OBJID, *conflict_cnstr;
  GRspacenum 		os;
  GRclassid 		cnstr_class, own_class;
  struct GRid 		*p_tmpid, tmpid, dim_src, dim_srcs[3][2], srcids[2];
  struct GRid 		grid, grids[3][2], refplnid;
  struct GRid 		*conflict_cnstr_grid, conflict_cnstr_grid_mem[3];
  struct diminfo 	diminfo;
  struct dim_src_info 	dim_src_info;
  struct EMSlndminfo 	lndminfo;
  struct EMSanginfo 	anginfo;
  struct GRsymbology 	symb;
  enum GRdpmode 	dpmode;
  OM_S_CHANSELECT 	chan_to_comps, chan_to_owner, chan_to_parent;
  OM_S_OBJECT_LINKAGE 	ownlink;
  IGRboolean 		SKisparskpln();
  IGRlong 		EMgetparvars(), SKdimsk_assocgrnds(), SKdimsk_vgpts();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  conflict_cnstr = NULL;
  conflict_cnstr_grid = NULL;

  cnstrid->objid = NULL_OBJID;
  cnstrid->osnum = dimid->osnum;
  *cnstr_type = NULL;

  unidir = FALSE;

  /*
   * Obtain information about the dimension object that is to be made
   * a constraint. Under some conditions, for example, the first backup after
   * placing a dimensional constraint, the dimension-placement command
   * continues to retain the dimension object. The constraint that
   * was placed continues to be intact. This condition implies that the
   * dimension has a constraint already owning it. This is tested for
   * and if found to exist, the constraint construction is assumed to
   * have already taken place.
   */

  stat_OM = om$send (msg = message DMroot.get_info ((int *) &msg_loc, md_env,
             &diminfo), targetid = dimid->objid, targetos = dimid->osnum,
             senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  EMmake_chanselect (GRconnector_to_owners, &chan_to_owner);
  count = 0;
  om$get_channel_objects (objid = dimid->objid, osnum = dimid->osnum,
                          p_chanselect = &chan_to_owner, 
                          count = (OMuint *)&count, size = 1, list = &ownlink);
  if (count == 1)
  {
    om$get_classid (objid = ownlink.S_objid, osnum = ownlink.osnum,
     p_classid = &own_class);

    if (om$is_ancestry_valid (subclassid = own_class,
         superclassid = OPP_SKconstraint_class_id) == OM_S_SUCCESS ||
        om$is_ancestry_valid (subclassid = own_class,
         superclassid = OPP_EMScnstr_class_id) == OM_S_SUCCESS)
      cnstrid->objid = ownlink.S_objid;
  }

  /*
   * Obtain information about the kind of constraint to be constructed
   * (if any) and other pieces of information necessary for the construction
   * of the constraint. 
   */
 
  switch (diminfo.dim_type)
  {
    case STACKED_LINEAR:
    case STRINGED_LINEAR:
    case SYMMETRICAL_DIAMETER:
    case LINEAR_DIAMETER:
    case STACKED_ANGULAR:
    case STRINGED_ANGULAR:

      if (diminfo.dim_type == STACKED_ANGULAR || 
          diminfo.dim_type == STRINGED_ANGULAR)
        angdim = TRUE;
      else
        angdim = FALSE;

      /*
       * Obtain the information about the parents and these parent's parameters
       * that drive or get driven by dimensions. 
       */

      for (i=ORIGIN; i<=MEASURE; i++)
      {
        if (i == ORIGIN)
        {
          loc_opts = NULL;
          need_geomtype = SK_ANYGEOM | EMS_PARAMPT | GR_BSPLINE | DM_SRC;
          need_geomtype |= angdim ? EMS_PARAMVC : NULL;
          p_tmpid = &diminfo.list[DIM_CPX_ORIG];
        }
        else
        {
          loc_opts = SK_DIMCNSTR_MASKONSEC;
          need_geomtype = SK_ANYGEOM | EMS_PARAMPT;
          need_geomtype |= angdim ? EMS_PARAMVC : NULL;
          p_tmpid = &diminfo.list[DIM_CPX_MEAS];
        }

        stat_OM = EMgetparvars (&msg_loc, loc_opts, md_env, p_tmpid,
                  need_geomtype,
                  &num_grids[i], grids[i], grid_geomtypes[i]);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        EMerr_hndlr (angdim ? (num_grids[i] < 1 || num_grids[i] > 2) : 
                               num_grids[i] != 1,
         *msg, EMS_I_BadElement, ret_end);

        dim_srcs[i][FIRST] = *p_tmpid;
      }
      
      /*
       * In case of non associative elements we avoid placement of angular dimension constraints
       * Fix for TR# 11926180      
       */	
      if(angdim)
      {
        if (num_grids[MEASURE] == 1)
          inx = FIRST;
        else
          inx = SECOND;
        need_geomtype = SK_ANYGEOM | EMS_PARAMPT | EMS_PARAMVC ;
        EMerr_hndlr (!(grid_geomtypes[MEASURE][inx] & need_geomtype), *msg, 
                    EMS_I_BadElement, ret_end);
      }
      /*
       * If the "driven" objects are sketch-elements, process somethings
       * specially. In this case, the restrictions and the pre-processing
       * is a lot more stringent. The measurement axis needs to be accounted
       * for and the dimensioning plane situation needs to be looked at
       * more closely. Note that in the angular dimensioning case, where the
       * "measure" set of objects number two, the second out of these is the
       * only driven one. This is the case of a point being driven w.r.t to
       * two other points or a line segment.
       *
       * If the measure-elements are not sketches then the constraint is
       * relatively straight-forward. The dim_src elements are abstracting
       * and collating information to the point where a relatively simple
       * constraint can be constructed.
       */

      if (num_grids[MEASURE] == 1)
        inx = FIRST;
      else
        inx = SECOND;

      if (grid_geomtypes[MEASURE][inx] & SK_ANYGEOM)
      {
        /*
         * A variational constraint is to be constructed.
         * Obtain the information on the measurement axis, treating it's
         * sources just like the origin/measure objects.
         */

        num_grids[AXIS] = 0;
        if (diminfo.lin_axis == ACT_X_AXIS || diminfo.lin_axis == ACT_Y_AXIS)
          for (i=AXIS_1; i<=AXIS_2; i++)
          {
            /*- OOOPS - you need to come of loop if  grid is NULL*/
            if (diminfo.meas_axis[i].objid == NULL_OBJID)
	      break;
	      
            need_geomtype = SK_ANYGEOM | EMS_ANYPARAM | GR_BSPLINE | DM_SRC;
            p_tmpid = &diminfo.meas_axis[i == AXIS_1 ? FIRST : SECOND];

            stat_OM = EMgetparvars ( &msg_loc, options, md_env, p_tmpid,
                                     need_geomtype,
                                     &tmpnum,
                                     &grids[AXIS][num_grids[AXIS]],
                                     &grid_geomtypes[AXIS][num_grids[AXIS]]);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
             ret_end);
            EMerr_hndlr (num_grids[i] != 1, *msg, EMS_I_BadElement, ret_end);
            dim_srcs[AXIS][num_grids[AXIS]] = *p_tmpid;

            num_grids[AXIS] += tmpnum;
          }

        /*
         * For all "sketch"-type parent-objects, obtain information about the
         * sketch-managers and their plane orientations, w.r.t. dimensioning
         * plane. A good dimension plane is one that is parallel to the 
         * sketch plane and has the X-vector direction as the same.
         */

        for (i=ORIGIN; i<=AXIS; i++)
          for (j=0; j<num_grids[i]; j++)
            if (grid_geomtypes[i][j] & SK_ANYGEOM)
            {
              om$send (msg = message SKgeometry.SKgetmgr (&msg_loc,
               &mgrobjs[i][j]), targetid = grids[i][j].objid,
               targetos = grids[i][j].osnum, senderid = NULL_OBJID);

              tmpid.objid = mgrobjs[i][j];
              tmpid.osnum = grids[i][j].osnum;
              are_goodplns[i][j] = SKisparskpln (&msg_loc,
                                    SK_PROCSKGR_NOPLNORIG,
                                    md_env, &tmpid,
                                    NULL, NULL, NULL,
                                    diminfo.plan_info.win_plan.matrix);
            }
            else
            {
              mgrobjs[i][j] = NULL_OBJID;
              are_goodplns[i][j] = FALSE;
            }

        /*
         * If measure-sketch object's plane is not parallel to the dimensioning
         * plane, the dimension can never be a driving one.
         */

        EMerr_hndlr (!are_goodplns[MEASURE][inx], *msg, EMS_I_BadPlane,
         ret_end);

        /* 
         * The dimensional constraint is going to be part of a variational
         * sketch. First check if any of the origin-sketches (if there are any
         * such sketches) or any of the axis-sketches (if there are any
         * such sketches) can be merged into the measure-sketch. If so, merge
         * them and recursively call this create-dimension function.
         */
        
        os = grids[MEASURE][inx].osnum;
        driven_mgr = mgrobjs[MEASURE][inx];

        merged = FALSE;
        for (i=ORIGIN; i<=AXIS; i++)
          for (j=0; j<num_grids[i]; j++)
            if (grid_geomtypes[i][j] & SK_ANYGEOM &&
                (mgrobjs[i][j] != driven_mgr &&
                 grids[i][j].osnum == os) &&
                are_goodplns[i][j])
            {
              stat_OM = om$send (msg = message SKmgr.SKmergemgr (&msg_loc,
                         SK_UPDATE_INFOERROR, md_env, mgrobjs[i][j]),
                         targetid = driven_mgr, targetos = os,
                         senderid = NULL_OBJID);
              EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
               ret_end);
            
              if (msg_loc == EMS_S_Success)
              {
                merged = TRUE;
                tempobj = mgrobjs[i][j];
                for (loc_i=ORIGIN; loc_i<=AXIS; loc_i++)
                  for (loc_j=0; loc_j<num_grids[loc_i]; loc_j++)
                    if (mgrobjs[loc_i][loc_j] == tempobj)
                      mgrobjs[loc_i][loc_j] = driven_mgr;
              }
            }

        if (merged)
        {
          EMcreate_dimension_constraint (msg, options, md_env, dimid,
                                         cnstrid, cnstr_type);
          goto ret_end;
        }

        /*
         * At this point the origin-objects/axis-objects may be part of the
         * measure-sketch or they may not be. If not then, the origin/axis
         * needs to be associatively grounded for the purpose of driving the 
         * measure-sketch. Grounded vg-points are introduced into the
         * measure sketch. These are returned as "parids" for the origin
         * element. 
         *
         * For all the other elements taking part in this constraint, viz,
         * those that belong to the measure-sketch, the corresponding
         * "parids" are returned through a simple lookup.
         */

        for (i=ORIGIN; i<=AXIS; i++)
        {
          num_parids[i] = 0;
          for (j=0; j<num_grids[i]; j++)
          {
            tmpid.objid = driven_mgr;
            tmpid.osnum = os;

            if (mgrobjs[i][j] != driven_mgr ||
                grids[i][j].osnum != os)
            {
              /*
               *  Avoid creation of more than one assoc_ground for a non assoc 
	       *  point.   TR# 119307713 -- SATYA -- 9th Jan 1995.
               */
              /*  Commenting out this fix as it leads to non placement of
	          some constraints -- Satya
              if((i != ORIGIN) && (grids[i][j].objid == grids[0][0].objid ||
                                 grids[i][j].objid == grids[0][1].objid))
                continue;
              else
              {
              */
                stat_OM = SKdimsk_assocgrnds (&msg_loc, NULL, md_env,
                          &dim_srcs[i][FIRST], j, &tmpid, &tmpnum,
                          &parids[i][num_parids[i]]);
                unidir = TRUE;
            }
            else
            {
              stat_OM = SKdimsk_vgpts (&msg_loc, NULL, md_env,
                         &dim_srcs[i][FIRST], j, &tmpnum,
                         &parids[i][num_parids[i]]);
            }
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
             ret_end);
            num_parids[i] += tmpnum;
          }
        }

        cnstr_props = NULL;
        skip_origin = FALSE;
        if (angdim)
        {
          /*
           * For every point defining this angular constraint we have obtained
           * a corresponding vg-point in the measure-sketch. A variational
           * angular constraint can be placed between these "parids". There
           * are three classes of angular constraints:
           * 1) Relative angle. The origin and the measure are geometric
           *    entities.
           * 2) Fixed angle. The origin is one of the two orthogonal
           *    axes.
           * 3) Fixed angle with measurement axis. The origin is one of the
           *    two measurement axes which are defined by geometry.
           */

          stat_OM = om$send (msg = message DMsrc.DMgive_src_info (
                             (int *) &msg_loc, md_env, &dim_src_info),
                     targetid = dim_srcs[ORIGIN][FIRST].objid,
                     targetos = dim_srcs[ORIGIN][FIRST].osnum,
                     senderid = NULL_OBJID);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);

          if (dim_src_info.type != DMaxis)
            cnstr_class = OPP_SKrelang_class_id;
          else
          {
            skip_origin = TRUE;
            if (IF_NULL_OBJID (diminfo.meas_axis[FIRST].objid))
              cnstr_class = OPP_SKfixang_class_id;
            else
              cnstr_class = OPP_SKaxisfixang_class_id;

            if (dim_src_info.var.dm_axis.axis == WIN_X_AXIS ||
                dim_src_info.var.dm_axis.axis == ACT_X_AXIS)
              cnstr_props |= SK_HORIZONTAL;
          }
        }
        else
        {
          /*
           * For every point defining this linear dimension constraint we have
           * obtained a corresponding vg-point in the measure-sketch. A
           * variational linear dimension constraint can now be placed between
           * these "parids". There are two classes of linear dimension
           * constraints:
           * 1) Horizontal/vertical distance. The measurement is the
           *    horizontal/vertical distance between the two points.
           * 2) Axis distance. The measurement along an axis (other than the
           *    current window) between two points.
           * Also, if the dimension object is displaying twice the measured
           * length (as in symmetrical-diameter), note this in the constraint
           * properties.
           */

          if (diminfo.lin_axis == WIN_X_AXIS || diminfo.lin_axis == WIN_Y_AXIS)
            cnstr_class = OPP_SKhvptpt_class_id;
          else
            cnstr_class = OPP_SKaxisptpt_class_id;

          if (diminfo.lin_axis == WIN_X_AXIS ||
              diminfo.lin_axis == ACT_X_AXIS)
            cnstr_props |= SK_HORIZONTAL;

          if (diminfo.dim_type == SYMMETRICAL_DIAMETER)
            cnstr_props |= SK_HALFVALUE;
        }

        tot_num_parids = 0;
        inx = 0;
        for (i=skip_origin?MEASURE:ORIGIN; i<=AXIS; i++)
        {          
          for (j=0; j<num_parids[i]; j++)
            tot_parids[inx++] = parids[i][j];
          tot_num_parids += num_parids[i];
        }
            
        if (IF_NULL_OBJID (cnstrid->objid))
        {
          stat_OM = om$construct (classid = cnstr_class, osnum = dimid->osnum,
                     msg = message SKconstraint.SKinit (&msg_loc,
                     SK_OPT_MARK_AS_NEWADD | SK_OPT_MARK_AS_USERADD |
                     SK_OPT_CONNECT_GEOMETRY,
                     md_env, tot_num_parids, tot_parids, cnstr_props,
                     &dimid->objid, (IGRchar *) &diminfo),
                     p_objid = &cnstrid->objid);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);
        }

        /*
         * Obtain the layer of the "driven" or "measure" sketch manager.
         * This is the layer in which the dimension will be placed when made
         * into a constraint.
         */

        stat_OM = om$send (msg = message GRvg.GRgetsymb (&msg_loc, &symb),
                   targetid = driven_mgr, targetos = os,
                   senderid = NULL_OBJID);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        cnstr_level = symb.level;

        vg_cnstr = TRUE;
      }
      else
      {
        /*
         * The constraint to be generated is not variational. This means that
         * either a parametric point is being driven or a parametric vector.
         */

        cnstr_props = NULL;
        skip_origin = FALSE;
        srcids[ORIGIN] = dim_srcs[ORIGIN][FIRST];
        srcids[MEASURE] = dim_srcs[MEASURE][FIRST];
        if (angdim)
        {
          stat_OM = om$send (msg = message DMsrc.DMgive_src_info (
                     (int *) &msg_loc, md_env, &dim_src_info),
                     targetid = dim_srcs[ORIGIN][FIRST].objid,
                     targetos = dim_srcs[ORIGIN][FIRST].osnum,
                     senderid = NULL_OBJID);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);

          if (dim_src_info.type == DMaxis)
          {
            skip_origin = TRUE;
            if (dim_src_info.var.dm_axis.axis == WIN_X_AXIS ||
                dim_src_info.var.dm_axis.axis == ACT_X_AXIS)
              cnstr_props |= EMScnstr_horizontal;
          }

          cnstr_class = OPP_EMSangcnstr_class_id;

          anginfo.dim = *dimid;
          anginfo.diminfo = diminfo;
          anginfo.name = NULL;

          moreinfo = (IGRchar *) &anginfo;
        }
        else
        {
          cnstr_class = OPP_EMSlndmcnstr_class_id;
          if (diminfo.dim_type == SYMMETRICAL_DIAMETER)
            cnstr_props |= EMScnstr_half_value;
        
          lndminfo.dim = *dimid;
          lndminfo.diminfo = diminfo;
          lndminfo.name = NULL;

          moreinfo = (IGRchar *) &lndminfo;
        }
        unidir = TRUE;

        if (IF_NULL_OBJID (cnstrid->objid))
        {
          stat_OM = om$construct (classid = cnstr_class, osnum = dimid->osnum,
                     msg = message EMScnstr.EMinit (&msg_loc,
                     EMScnstr_connect_geomhandle, md_env,
                     skip_origin ? 0 : 1, skip_origin ? NULL : &srcids[ORIGIN],
                     cnstr_props, moreinfo,
                     1, &srcids[MEASURE]), p_objid = &cnstrid->objid);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);
        }

        /*
         * Obtain the layer of the 3D object which is the parent of the 
         * parametric-geom object.  This is the layer in which 
         * the dimension will be placed when made into a constraint.
         * In case the symbology message fails, use the active layer.
         */
        gr$get_active_layer (buffer = &cnstr_level);
        EMmake_chanselect (NDfather_father, &chan_to_parent);
        stat_OM = om$send (msg = message GRvg.GRgetsymb (&msg_loc, &symb),
                   p_chanselect = &chan_to_parent, 
                   senderid = srcids[MEASURE].objid, 
                   targetos = srcids[MEASURE].osnum);
        if (stat_OM & msg_loc & 1)
          cnstr_level = symb.level;
        else
        {
          stat_OM = OM_S_SUCCESS;
          msg_loc = EMS_S_Success;
        }
        vg_cnstr = FALSE;
      }
        
        /*
         * In the case of linear dimensions, the expressions may have to be updated
         * if a intermediate point has been entered (the dimension no longer represents
         * the full length, but only part of it)
         */
        if (diminfo.dim_type == STRINGED_LINEAR || 
            diminfo.dim_type == STRINGED_ANGULAR)
        {
          OM_S_CHANSELECT     chan_to_children, chan_to_owners;
          OM_S_OBJECT_LINKAGE *children, *expressions;
          int                 i;
          OMuint              nb_children, nb_expressions;

          /*
           * Check if I have children
           */
          EMmake_chanselect ( NDchildren_children, &chan_to_children );
          nb_children = 0;
          om$get_channel_count ( objid = dimid->objid, osnum = dimid->osnum,
              p_chanselect = &chan_to_children, count = &nb_children );
          if (nb_children)
          {
            children = (OM_S_OBJECT_LINKAGE *)alloca ( nb_children * 
                sizeof ( OM_S_OBJECT_LINKAGE ) ); 
            om$get_channel_objects ( objid = dimid->objid, osnum = dimid->osnum,
                p_chanselect = &chan_to_children, count = &nb_children, 
                size = nb_children, list = children );
            for (i = 0; i < nb_children; i++)
            {
              /*
               * I do, check the expression -> value must be equal to the one
               * stored in the dimension.
               */
              stat_OM = om$send (msg = message DMroot.get_info ((int *) &msg_loc, 
                  md_env, &diminfo ), targetid = children [i].S_objid, 
                  targetos = children [i].osnum, senderid = NULL_OBJID );
              if ((stat_OM & 1) && (msg_loc & 1))
              {
                EMmake_chanselect ( GRconnector_to_owners, &chan_to_owners );
                nb_expressions = 0;
                om$get_channel_count ( objid = children [i].S_objid, 
                    osnum = children [i].osnum, p_chanselect = &chan_to_owners, 
                    count = &nb_expressions );
                if (nb_expressions)
                {
                  expressions = (OM_S_OBJECT_LINKAGE *)alloca ( nb_expressions * 
                      sizeof ( OM_S_OBJECT_LINKAGE ) ); 
                  om$get_channel_objects ( objid = children [i].S_objid, 
                      osnum = children [i].osnum, p_chanselect = &chan_to_owners, 
                      count = &nb_expressions, size = nb_expressions, 
                      list = expressions );
                  for (j = 0; j < nb_expressions; j++)
                  {
                    double val;
                    short  rc;
                    
                    stat_OM = om$send ( msg = message expression.NDgive_value ( &val ),
                        targetos = expressions [j].osnum, 
                        targetid = expressions [j].S_objid, senderid = NULL_OBJID );
                    if ((stat_OM & 1) && (fabs(diminfo.dim_value - val) > 1e-6))
                    {
                      char str_value [DI_PATH_MAX];
                      
                      sprintf ( str_value, "%g", diminfo.dim_value );
                      om$send ( msg = message expression.modify ( NULL, str_value, &rc ),
                          targetos = expressions [j].osnum, 
                          targetid = expressions [j].S_objid, senderid = NULL_OBJID );
                    }
                  }
                }                    
              }
            }
          }
        }
      break;

    case SINGLE_PARALLEL:
    case RADIAL:
    case RADIAL_DIAMETER:
    case CIRCULAR_DIAMETER:
      if (diminfo.dim_type == RADIAL || diminfo.dim_type == RADIAL_DIAMETER ||
          diminfo.dim_type == CIRCULAR_DIAMETER)
        {
        raddim = TRUE;
        need_geomtype = SK_ARC | SK_CIRCLE;
        }
      else
        {
        raddim = FALSE;
        need_geomtype = SK_LINE;
        }

      /*
       * Obtain the information about the parents and these parent's parameters
       * that drive or get driven by dimensions. Only sketch-profile geometry
       * can be driven with these constraints.
       */

      dim_src = diminfo.list[DIM_CPX_ORIG];
      stat_OM = EMgetparvars (&msg_loc, options, md_env, &dim_src,
                 need_geomtype, &count, &grid, &grid_geomtype);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr (count != 1, *msg, EMS_I_BadElement, ret_end);

      /*
       * Check if the dimensioning plane is parallel to the sketch-plane
       * If not, then stop processing as a driving dimension.
       */

      stat_OM = om$send (msg = message SKgeometry.SKgetmgr (&msg_loc,
                 &mgrobj), targetid = grid.objid, targetos = grid.osnum,
                 senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      tmpid.objid = mgrobj;
      tmpid.osnum = grid.osnum;
      is_goodpln = SKisparskpln (&msg_loc, NULL, md_env, &tmpid,
                    NULL, NULL, NULL,
                    diminfo.plan_info.win_plan.matrix);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr (!is_goodpln, *msg, EMS_I_BadPlane, ret_end);

      /*
       * Obtain the corresponding v.g.-points and construct the
       * constraint.
       */

      stat_OM = SKdimsk_vgpts (&msg_loc, NULL, md_env, &dim_src, NULL,
                               &count, geom_parids);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr (count < 2 || count > 4, *msg, EMS_I_InvalidCase, ret_end);

      cnstr_props = NULL;
      if (IF_NULL_OBJID (cnstrid->objid))
      {
        if (raddim) 
        {
          cnstr_class = OPP_SKradial_class_id;
          if (diminfo.dim_type == RADIAL_DIAMETER || 
              diminfo.dim_type == CIRCULAR_DIAMETER)
            cnstr_props |= SK_HALFVALUE;
        }
        else
          cnstr_class = OPP_SKifptpt_class_id;
        stat_OM = om$construct (classid = cnstr_class, osnum = dimid->osnum,
                                msg = message SKconstraint.SKinit (&msg_loc,
                                      SK_OPT_MARK_AS_NEWADD | SK_OPT_MARK_AS_USERADD |
                                      SK_OPT_CONNECT_GEOMETRY, md_env,
                                      2, geom_parids, cnstr_props, &dimid->objid,
                                      (IGRchar *) &diminfo), 
                                p_objid = &cnstrid->objid);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }

      /*
       * Obtain the layer of the "driven" or "measure" sketch manager.
       * This is the layer in which the dimension will be placed when made
       * into a constraint.
       */

      stat_OM = om$send (msg = message GRvg.GRgetsymb (&msg_loc, &symb),
                         targetid = mgrobj, targetos = grid.osnum,
                         senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      cnstr_level = symb.level;

      driven_mgr = mgrobj;
      vg_cnstr = TRUE;
      break;

    default:
      *msg = EMS_I_NotSupported;
      goto ret_end;
  }

  /*
   * Perform the validation for the constraint just constructed. It could fall
   * into one of two categories, each condition being treated separately:
   *
   * a) Valid dimensional constraint.
   *    Action: Connect the dimension geometry to the constraint as a
   *    component. Alter the parents of the dimension appropriately.
   *
   * b) The dimension constraint being added is redundant with one other
   *    constraint (actually, one out of a set of constraints). 
   *    Action: Delete the constraint created. Highlight the redundant
   *    set of constraints. 
   *    
   */

  if (vg_cnstr)
  {
    stat_OM = om$send (msg = message SKconstraint.SKvalidate 
                             (&val_msg_loc, unidir ? SK_UPDATE_CHKCYCLE : NULL, 
                             md_env, &is_valid_cnstr,
                             &num_conflict_cnstr, &conflict_cnstr),
                       targetid = cnstrid->objid, targetos = cnstrid->osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & val_msg_loc), *msg, EMS_E_Fail, ret_end);

    if (!is_valid_cnstr && num_conflict_cnstr)
    {
      conflict_cnstr_grid = (struct GRid *) om$malloc (size = 
                             num_conflict_cnstr * sizeof (struct GRid));
      EMerr_hndlr (!conflict_cnstr_grid, *msg, EMS_E_NoDynamicMemory, ret_end);

      for (i=0; i<num_conflict_cnstr; i++)
      {
        conflict_cnstr_grid[i].objid = conflict_cnstr[i];
        conflict_cnstr_grid[i].osnum = cnstrid->osnum;
      }
    }
  }
  else
  {
    conflict_cnstr_grid = conflict_cnstr_grid_mem;
    stat_OM = om$send (msg = message EMScnstr.EMvalidate (&val_msg_loc,
               unidir ? EMSsolve_checkcycle : NULL, md_env, &is_valid_cnstr,
               &num_conflict_cnstr, conflict_cnstr_grid),
               targetid = cnstrid->objid, targetos = cnstrid->osnum,
               senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  if (! is_valid_cnstr)
  {
    if (! (options & SK_DIMCNSTR_NODISPLAY))
    {
      dpmode = GRhd;
      for (i=0; i<num_conflict_cnstr; i++)
      {
        if (conflict_cnstr_grid[i].objid != cnstrid->objid ||
            conflict_cnstr_grid[i].osnum != cnstrid->osnum)
          om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
           &md_env->md_env.matrix_type, md_env->md_env.matrix, &dpmode,
           &md_env->md_id), targetid = conflict_cnstr_grid[i].objid,
           targetos = conflict_cnstr_grid[i].osnum, senderid = NULL_OBJID);
      }
    }

    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    om$send (msg = message Root.wild_disconnect (chan_to_comps),
             targetid = cnstrid->objid, targetos = cnstrid->osnum,
             senderid = NULL_OBJID);
    
    om$send (msg = message GRgraphics.GRdelete (&msg_loc, md_env),
             targetid = cnstrid->objid, targetos = cnstrid->osnum,
             senderid = NULL_OBJID);

    if (val_msg_loc == EMS_I_Cycle || val_msg_loc == EMS_I_NoSolution ||
         val_msg_loc == EMS_I_NoStackMemory)
      *msg = val_msg_loc;
    else
      *msg = EMS_I_Redundant;
  }
  else
  {
    int                 i, count;
    OMuint              size;
    OM_S_OBJECT_LINKAGE *list;
    GRclassid           classid;
    
    /*
     * Change the layer of the dimension to the layer of the driven entity 
     */
    stat_OM = om$send (msg = message GRvg.GRchglevel (&msg_loc, &cnstr_level),
                       targetid = dimid->objid, targetos = dimid->osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    
    /* 
     * We need to change the level of the DMsrc as well 
     */

    om$get_channel_count (osnum = dimid->osnum, objid = dimid->objid,
                          p_chanselect = &ND_father, count = &size);
    if (size > 0)
    {
      list = (OM_S_OBJECT_LINKAGE *) alloca ( size * 
              sizeof ( OM_S_OBJECT_LINKAGE ) );
      om$get_channel_objects ( p_chanselect = &ND_father, list = list,
                    size = size, count = (OMuint *)&count, osnum = dimid->osnum,
                    objid = dimid->objid );

      for (i = 0; i < count; i++)
      {
        extern GRclassid OPP_DMsrc_class_id;
                        
        om$get_classid ( osnum = list [i].osnum, objid = list [i].S_objid,
                         p_classid = &classid );
        if (classid == OPP_DMsrc_class_id)
        {
          stat_OM = om$send ( msg = message GRvg.GRchglevel ( &msg_loc,
                     &cnstr_level ),
                     targetid = list [i].S_objid, targetos = dimid->osnum,
                     senderid = NULL_OBJID );
          EMerr_hndlr ( EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
                        ret_end );
        }
      }
    }

    if (vg_cnstr)
    {
       struct GRid dim_plane, dim_ref_plane;
       
      /*    
       * Change the plane of the dimension to the reference plane
       * attached to the profile. In case of dimensions honoring measurement
       * axis, change the ref-plane driving the dimension plane driving the 
       * dimension to the profile's ref-plane.
       */

      EMmake_chanselect (NDfather_father, &chan_to_parent);
      refplnid.objid = NULL_OBJID;
      om$get_objid_at_index (objid = driven_mgr, osnum = cnstrid->osnum,
                      p_chanselect = &chan_to_parent, index = FIRST,
                      objidaddr = &refplnid.objid, osnumaddr = &refplnid.osnum);

      dim_plane.objid = NULL_OBJID;
      om$get_objid_at_index ( objid = dimid->objid, osnum = dimid->osnum,
                              p_chanselect = &chan_to_parent, index = FIRST, 
                              objidaddr = &dim_plane.objid, 
                              osnumaddr = &dim_plane.osnum);

      dm$change_ref_plane (inq0_chg1 = 0, ref_grid = &dim_ref_plane, 
                           plane_grid = &dim_plane, md_env = md_env);
      
      if (IF_NULL_OBJID (dim_ref_plane.objid))
      {
        if (!IF_NULL_OBJID (refplnid.objid) && dim_plane.objid != refplnid.objid)
           dm$change_plane (plane_grid = &refplnid, md_env = md_env,
                            dim_grid = dimid);
      }
      else
      {
        if (dim_ref_plane.objid != refplnid.objid)
           dm$change_ref_plane (inq0_chg1 = 1, ref_grid = &refplnid, 
                                plane_grid = &dim_plane, md_env = md_env);
           
      }
    }

    if (val_msg_loc == EMS_I_FullyConstrained)
      *msg = val_msg_loc;

    if (unidir)
      *cnstr_type = SK_DIMCNSTR_UNIDIR;
  }
                           
ret_end:
  if (conflict_cnstr)
    om$dealloc (ptr = conflict_cnstr);
  if (conflict_cnstr_grid && conflict_cnstr_grid != conflict_cnstr_grid_mem)
    om$dealloc (ptr = conflict_cnstr_grid);

  EMWRAPUP (*msg, stat_OM, "EMcreate_dimension_constraint");
  return (stat_OM);
}




/*
 * This function obtains the objects that are being listened to by a
 * given dimension "parent" object. The type of listened-to object expected
 * is input (Sketch geometry, 3D-parametric entities, or a GRbspline
 * object). For a non-zero output the listened-to objects must
 * satisfy the input requirements. The type of these listened-to objects are
 * returned. The space for all output must be provided by the caller
 * (maximum of 2 positions).
 */

#argsused
IGRlong EMgetparvars (msg, options, md_env, dim_src, need_geomtype,
                      num_parent_grids, parent_grids, ret_geomtype)
IGRlong *msg;
IGRushort options;
struct GRmd_env *md_env;
struct GRid *dim_src;
IGRushort need_geomtype;
IGRint *num_parent_grids;
struct GRid *parent_grids;
IGRushort *ret_geomtype;
{
  IGRboolean 		decompose=FALSE;
  IGRushort 		local_geomtype, local_need_geomtype[2];
  IGRint 		i, inx, local_num_parent_grids=0;
  IGRlong 		msg_loc, stat_OM;
  struct GRid 		*local_parent_grid;
  GRclassid 		dim_src_class, parent_class;
  struct dim_src_info 	dim_src_info;
  extern void 		SKgetgeomtype();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *num_parent_grids = 0;
  parent_grids[0].objid = NULL_OBJID;
  ret_geomtype[0] = NULL_GEOM;

  om$get_classid (objid = dim_src->objid, osnum = dim_src->osnum,
                  p_classid = &dim_src_class);

  /*
   * Check if this is a 3D-parametric type object. If so, format the output
   * and return.
   */

  if (om$is_ancestry_valid (subclassid = dim_src_class,
       superclassid = OPP_EMSparamgm_class_id) == OM_S_SUCCESS)
    {
    if (! (need_geomtype & EMS_ANYPARAM))
      goto ret_end;

    if (om$is_ancestry_valid (subclassid = dim_src_class,
         superclassid = OPP_EMSparampt_class_id) == OM_S_SUCCESS)
      local_geomtype = EMS_PARAMPT;
    else
      local_geomtype = EMS_PARAMVC;

    if (local_geomtype & need_geomtype)
      {
      *num_parent_grids = 1;
      *parent_grids = *dim_src;
      *ret_geomtype = local_geomtype;
      }
    }

  /*
   * Check to see if the dimparent is listening to a sketch element or
   * a GRbspline element. Only certain sources are acceptable. Out of
   * these cannot be further split into their defining elements, ie, we
   * have to view the source point as is and not look for it's parents.
   */

  else
    {
    stat_OM = om$send (msg = message DMsrc.DMgive_src_info ((int *) &msg_loc,
               md_env, &dim_src_info), targetid = dim_src->objid,
               targetos = dim_src->osnum, senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    switch (dim_src_info.type)
      {
      case DMkeypt:
      case DMkeyseg:
      case DMcenpt:
      case DMaxis:
      case DMradcen:
      case DMarc:
        decompose = TRUE;
        local_num_parent_grids = 1;
        local_need_geomtype[FIRST] = need_geomtype;
        msg_loc = EMS_S_Success;
        break;

      case DM2ptseg:
        decompose = TRUE;
        local_num_parent_grids = 2;
        local_need_geomtype[FIRST] = SK_ANYGEOM | GR_BSPLINE;
        local_need_geomtype[SECOND] = need_geomtype;
        msg_loc = EMS_S_Success;
        break;

      case DMintpt:
      case DMmidpt:
        decompose = FALSE;
        local_num_parent_grids = 1;
        local_need_geomtype[FIRST] = need_geomtype;
        msg_loc = EMS_S_Success;
        break;

      default:
        msg_loc = EMS_E_NotSupported;
      }
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_I_NotSupported, ret_end);

    inx = 0;
    for (i=0; i<local_num_parent_grids; i++)
      {
      local_parent_grid = &dim_src_info.parents[i];
      om$get_classid (objid = local_parent_grid->objid,
       osnum = local_parent_grid->osnum, p_classid = &parent_class);
       
      /*
       * Check to see if no-decomposition of the src_info is called for.
       * If so, return the src object as the grid.
       */

      if (!decompose)
        {
        if (!(local_need_geomtype[i] & DM_SRC))
          goto ret_end;

        parent_grids[*num_parent_grids] = *dim_src;
        ret_geomtype[*num_parent_grids] = DM_SRC;
        (*num_parent_grids)++;
        }

      /*
       * Check to see if the dim_src is listening to a sketch element
       */

      else if (om$is_ancestry_valid (subclassid = parent_class,
                superclassid = OPP_SKgeometry_class_id) == OM_S_SUCCESS)
        {
        if (!(local_need_geomtype[i] & SK_ANYGEOM))
          goto ret_end;

        SKgetgeomtype (local_parent_grid->objid, local_parent_grid->osnum, 
         &local_geomtype);
        EMerr_hndlr (!local_geomtype, *msg, EMS_E_InvalidCase, ret_end);

        if (local_geomtype & local_need_geomtype[i])
          {
          parent_grids[*num_parent_grids] = *local_parent_grid;
          ret_geomtype[*num_parent_grids] = local_geomtype;
          (*num_parent_grids)++;
          }
        }

      /*
       * Check to see if the dimparent is listening to a GRbspline element
       */
  
      else if (om$is_ancestry_valid (subclassid = parent_class,
                superclassid = OPP_GRbspline_class_id) == OM_S_SUCCESS)
        {
        if (!(local_need_geomtype[i] & GR_BSPLINE))
          goto ret_end;
    
        local_geomtype = GR_BSPLINE;
        if (local_geomtype & local_need_geomtype[i])
          {
          parent_grids[*num_parent_grids] = *local_parent_grid;
          ret_geomtype[*num_parent_grids] = local_geomtype;
          (*num_parent_grids)++;
          }
        }
      else if (om$is_ancestry_valid (subclassid = parent_class,
                superclassid = OPP_GRcoords_class_id) == OM_S_SUCCESS)
        {
         if (!(local_need_geomtype[i] & GR_BSPLINE))
          goto ret_end;

          local_geomtype = GR_BSPLINE;
    
          if (local_geomtype & local_need_geomtype[i])
          {
           parent_grids[*num_parent_grids] = *local_parent_grid;
           ret_geomtype[*num_parent_grids] = local_geomtype;
           (*num_parent_grids)++;
          }
        }

      /*
       * There are no other valid parent types to check against.Return
       * an error code.
       */

      else
        {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);}
      }
    }    

ret_end:
  return (stat_OM);
}


end implementation SKconstraint;
