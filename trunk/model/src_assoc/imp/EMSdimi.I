class implementation EMSdim;

#include "OMmacros.h"
#include "dimmacros.h"
#include "msdef.h"
#include <stdio.h>
#include "dimsrc.h"
#include "dimplan.h"
#include "ma.h"
#include "bserr.h"
#include "marptsxfo.h"
#include "maoptsxfo.h"
#include "maidmx.h"
#include "mabcueval.h"
#include "mabctoar.h"
#include "maarendpt.h"
#include "ma3protmx.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscrossp.h"
#include "EMSprop.h"

#define X 0
#define Y 1
#define Z 2

#define FIRST  0
#define SECOND 1

extern GRclassid OPP_EMSparamvc_class_id, OPP_EMSparampt_class_id,
                 OPP_ASsourcein_class_id;

from EMSparamgm import EMgetgeom, EMgeomhandle;
from EMSdpr import EMget_dpr_props;
/* 	
    History

    Tapadia 	30/03/93  Fix made to display the axis parameter of holes
			  (TR 119301839)

    Sudha   06/01/93    modified to handle BSprototype headers
*/

method EMautodim ( IGRlong         * msg;
                   struct GRmd_env * mod_env )
{
    IGRlong               msg_loc, om_msg = OM_S_SUCCESS;
    OM_S_CHANSELECT       chansel;
    IGRint                num_parents = 0, i;
    OM_S_OBJECT_LINKAGE * objects = NULL;
    struct GRid         * parents;

    *msg = EMS_S_Success;
    EMmake_chanselect (NDfather_father, &chansel);
    om$get_channel_count (object = me, p_chanselect = &chansel, 
                          count = (OMuint *)&num_parents);

    if (num_parents)
    {
        objects = (OM_p_OBJECT_LINKAGE)alloca(num_parents * sizeof(OM_S_OBJECT_LINKAGE));
        parents = (struct GRid *)alloca(num_parents * sizeof(struct GRid));
        om$get_channel_objects ( object = me, 
                                 p_chanselect = &chansel,
                                 count = (OMuint *)&num_parents,
                                 size = num_parents,
                                 list = objects );

        for (i=0; i<num_parents; i++) 
        {
            parents[i].objid = objects[i].S_objid;
            parents[i].osnum = objects[i].osnum;
        }
    }

    om_msg = om$send ( msg = message EMSdim.EMdim ( msg,
                                                    mod_env,
                                                    NULL,
                                                    me->type,
                                                    me->info,
                                                    num_parents,
                                                    parents ),
                       targetid = my_id );
    

    if (om_msg == OM_W_REJECTED_METHOD) om_msg = OM_S_SUCCESS;

    EMerr_hndlr (!(1&om_msg), *msg, EMS_E_Fail, ret_end);

    /*
     * Create the geometry handles for any geometric-constraints
     * that may have gotten created
     */

    for (i=0; i<num_parents; i++) 
    {
	om$send (msg = message EMSparamgm.EMgeomhandle (&msg_loc, NULL,
							  mod_env),
	targetid = parents[i].objid, targetos = parents[i].osnum);
    }

ret_end:

  EMWRAPUP (*msg, om_msg, "EMSdim.EMautodim");
  return (om_msg);
}

method EMautodimparam ( IGRlong            * msg; 
                        IGRushort            opts;
                        IGRshort           * mattyp;
                        IGRmatrix            mat;
                        GRobjid              paramobj; 
                        struct IGRplane    * dim_plane;
                        IGRdouble          * dim_plane_xaxis;
                        struct EMSgeomdata * dim_geom;
                        IGRint             * dim_type )
{
    IGRlong               om_msg = OM_S_SUCCESS;
    OM_S_CHANSELECT       chansel;
    IGRint                num_parents = 0, i, index = -1;
    OM_S_OBJECT_LINKAGE * objects = NULL;
    struct GRid         * parents;

    *msg = EMS_S_Success;

    EMmake_chanselect (NDfather_father, &chansel);
    om$get_channel_count (object = me, p_chanselect = &chansel,
                          count = (OMuint *)&num_parents);
    if (num_parents)
    {
        objects = (OM_p_OBJECT_LINKAGE)alloca(num_parents * sizeof(OM_S_OBJECT_LINKAGE));
        parents = (struct GRid *)alloca(num_parents * sizeof(struct GRid));
        om$get_channel_objects ( object = me, 
                                 p_chanselect = &chansel,
                                 count = (OMuint *)&num_parents,
                                 size = num_parents,
                                 list = objects );

        for (i=0; i<num_parents; i++)
        {
            parents[i].osnum = objects[i].osnum;
            if ((parents[i].objid = objects[i].S_objid) == paramobj)
                  index = i;
        }

        if (index != -1)
        {
            struct GRmd_env mod_env;

            mod_env.md_env.matrix_type = *mattyp;
            memcpy (mod_env.md_env.matrix, mat, 16 * sizeof(IGRdouble));

            om_msg = om$send ( msg = message EMSdim.EMdimparam 
                                                         ( msg,
                                                           &mod_env,
                                                           opts,
                                                           me->type,
                                                           me->info,
                                                           num_parents,
                                                           parents,
                                                           index,
                                                           dim_plane,
                                                           dim_plane_xaxis,
                                                           dim_geom,
                                                           dim_type ),
                               targetid = my_id );

            EMerr_hndlr (!(1&om_msg), *msg, EMS_E_Fail, ret_end);
        }
        else *msg = EMS_E_Fail;
    }
    else *msg = EMS_E_Fail;

ret_end:

  EMWRAPUP (*msg, om_msg, "EMSdim.EMautodimparam");
  return (om_msg);
}

method EMdimparam (IGRlong *msg; struct GRmd_env *mod_env;
                   IGRushort options;
                   IGRint type; IGRchar *info;
                   IGRint num_parents; struct GRid *parents;
                   IGRint index; 
                   struct IGRplane *dim_plane; IGRdouble *dim_plane_xaxis;
                   struct EMSgeomdata *dim_geom; IGRint *dim_type)
{
  IGRboolean is_world=TRUE, found;
  IGRlong i, j, ptinx, msg_loc, stat_OM;
  IGRdouble *dptr, *vec, *pt, ht, d;
  IGRpoint origpt, vecpt, boundpts[2];
  GRrange range;
  GRclassid parclass;
  struct IGRline vecline;
  struct EMSgeomdata vcgeom, ptgeom;
  struct DMenv_param dmenv_param;
  IGRint pt_index;
  IGRushort dpr_props;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * The default dimensioning plane returned is the plane of the top view.
   */

  if (dim_plane)
    {
    dptr = dim_plane->point;
    dptr[X] = dptr[Y] = dptr[Z] = 0.0;
    dptr = dim_plane->normal;
    dptr[X] = dptr[Y] = 0.0; dptr[Z] = 1.0;
    }

  /*
   * The default dimensioning x-axis is X-axis of the top view (which is
   * also the world-coordinate X-axis).
   */

  if (dim_plane_xaxis)
    {
    dptr = dim_plane_xaxis;
    dptr[X] = 1.0; dptr[Y] = dptr[Z] = 0.0;
    }

  /*
   * The default dimensioning geometry is decided based on the type of
   * parameter that is requesting the geometry.
   * EMSparamvc: The parameter list is scanned for an EMSparampt object.
   *             If found, it's value is coupled with the vector's value
   *             and a line segment constructed that spans atleast the range
   *             box.
   * EMSparampt: The point is returned
   *             in model space.
   * EMSparamvl: A line segment parallel to world X-axis starting at my range
   *             boxes center for index=0 and for every subsequent index the
   *             starting point being displaced by the active dimensioning text
   *             height in the X/Y/Z direction.
   */

  if (dim_geom)
    {
    stat_OM = om$send (msg = message GRgraphics.GRgetrang (&msg_loc, 
               &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
               &is_world, range), targetid = my_id);
    if (EMSerror (msg_loc & stat_OM))
      {
      range[0] = range[1] = range[2] = 0.0;
      range[3] = range[4] = range[5] = 10.0;
      }

    om$get_classid (objid = parents[index].objid, osnum = parents[index].osnum,
     p_classid = &parclass);
    if (om$is_ancestry_valid (subclassid = parclass, 
         superclassid = OPP_EMSparamvc_class_id) == OM_S_SUCCESS)
      {
      stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
                 &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
                 &vcgeom), targetid = parents[index].objid,
                 targetos = parents[index].osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      vec = vcgeom.vector;

      found = FALSE;
      for (ptinx=0; ptinx<num_parents; ptinx++)
        {
        om$get_classid (objid = parents[ptinx].objid, osnum = parents[ptinx].osnum,
         p_classid = &parclass);
        if (om$is_ancestry_valid (subclassid = parclass, 
             superclassid = OPP_EMSparampt_class_id) == OM_S_SUCCESS)
          {
          found = TRUE;
	  /* Added to fix TR 119301839 - Tapadia. This value is later used to
	  extract the center point of the first hole */
	  pt_index = ptinx;
          break;
          }
        }

      stat_OM = om$send(msg = message EMSdpr. EMget_dpr_props(
						&msg_loc, &dpr_props),
			targetid = my_id);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      if (found)
        {
        stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
                   &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
                   &ptgeom), targetid = parents[pt_index].objid,
                   targetos = parents[pt_index].osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        pt = ptgeom.point;
        }
      else if( dpr_props & EMS_PATTERN_FEATURE)
	{
	  struct ret_struct info_struct;

	  pt = ptgeom.point;
	  stat_OM =
	  om$send (msg = message NDnode.NDgive_structure(
                                                     &msg_loc,
                                                     &info_struct,
                                                     mod_env),
		   targetid = parents[0].objid,
		   targetos = parents[0].osnum);
	  EMerr_hndlr (EMSerror (stat_OM& msg_loc), *msg, EMS_E_Fail, ret_end);
	  pt[0] = info_struct.var.point_st.pt[0];
	  pt[1] = info_struct.var.point_st.pt[1];
	  pt[2] = info_struct.var.point_st.pt[2];
	}
      else
        {
        pt = ptgeom.point;
        for (j=X; j<=Z; j++)
          pt[j] = range[j] + (range[3+j] - range[j]) / 2.0;
        }

      vecline.point1 = pt;
      for (j=X; j<=Z; j++)
        vecpt[j] = pt[j] + vec[j];
      vecline.point2 = vecpt;
      EMget_bounded_line (range, &vecline, boundpts, &msg_loc);

      dim_geom->geomtype = GEOMDATA_LINE;
      dptr = dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
      OM_BLOCK_MOVE (boundpts[FIRST], dptr, sizeof (IGRpoint));
      dptr = dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
      OM_BLOCK_MOVE (boundpts[SECOND], dptr, sizeof (IGRpoint));
      }

    else if (om$is_ancestry_valid (subclassid = parclass, 
              superclassid = OPP_EMSparampt_class_id) == OM_S_SUCCESS)
      {
      stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
                 &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
                 dim_geom), targetid = parents[index].objid,
                 targetos = parents[index].osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }

    else
      {
      stat_OM = dm$get_dim_param (type = DM_ENV_PARAM, p_data = &dmenv_param);
      EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
      ht = 1.1 * dmenv_param.txt_heig;

      dim_geom->geomtype = GEOMDATA_LINE;
      dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
      dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
      for (i=X; i<=Z; i++)
        {
        d = range[i+3] - range[i];
        origpt[i] = range[i] + d/2.0 + ht * index;
        }
      dptr = dim_geom->line.line_pt1;
      OM_BLOCK_MOVE (origpt, dptr, sizeof (IGRpoint));
      dptr = dim_geom->line.line_pt2;
      OM_BLOCK_MOVE (origpt, dptr, sizeof (IGRpoint));
      dptr[X] += 20 * ht;
      }
    }

  /*
   * The dimension type is single-parallel;
   */

  if (dim_type)
    *dim_type = SINGLE_PARALLEL;

ret_end:
    EMWRAPUP (*msg, stat_OM, "EMSdim.EMdimparam");
    return (stat_OM);
}

extern OMuword OPP_EMSparamvl_class_id;

method EMdeautodim ( IGRlong         * msg;
                     struct GRmd_env * mod_env )
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRint          i, count;
    OMuword         osnum, classid;
    OM_S_OBJID      objid;
    OM_S_CHANSELECT father_chansel, owner_chansel;

    EMmake_chanselect (NDfather_father, &father_chansel);
    EMmake_chanselect (GRcmpowner_to_components, &owner_chansel);

    om$get_channel_count ( object = me, 
                           p_chanselect = &father_chansel, 
                           count = (OMuint *)&count );

    for (i=0; i<count; ++i)
    {
        om$get_objid_at_index ( object = me,
                                p_chanselect = &father_chansel,
                                index = i,
                                objidaddr = &objid,
                                osnumaddr = &osnum );

        om$get_classid ( objid = objid,
                         osnum = osnum,
                         p_classid = &classid );

        if (om$is_ancestry_valid (superclassid = OPP_EMSparamvl_class_id,
                                  subclassid = classid) == OM_S_SUCCESS)
        {
            om$send ( msg = message GRgraphics.GRdelete (msg, mod_env),
                      targetid = objid,
                      targetos = osnum );
        }
    }

    EMWRAPUP (*msg, om_msg, "EMSdim.EMdeautodim");

    return (om_msg);

}

/*
 * METHOD:
 *  
 *  DMgive_structure, give_axis, and give_plane
 *
 * DESCRIPTION:
 *
 *  These are override on the dim_src and dim_plan necessary to implement
 *  autodimensioning for associative surfaces and solids.
 *
 * HISTORY:
 *
 *  jhw    Creation         06/22/91
 *  Tapadia 08/09/91  Support for TEXT_WITH_LEADER
 *  Sudha   06/14/94  Purify fix , initialize str ptdist vector.
 */

method DMgive_structure ( IGRint                * msg;
                          IGRint                  type;
                          IGRboolean              inq0_set1;
                          struct dim_ret_struct * str;
                          struct GRmd_env       * md_env )
{
    IGRlong         om_msg = OM_S_SUCCESS, msg_loc;
    struct GRid     assoc_id, dim_id, param_id;
    struct IGRarc   arc;
    IGRdouble       points[6];
    IGRshort        option = 0;
    IGRdouble       parm = 0.5;
    IGRshort        temp_mat_type;
    IGRmatrix       temp_mat;
    IGRlong one     = 1;

    temp_mat_type = MAIDMX;
    MAidmx((IGRlong *)msg,temp_mat);

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    dim_id.objid   = sender_id;
    dim_id.osnum   = sender_os;

    om_msg = EFget_active_parameter (&assoc_id, &dim_id, &param_id);

    if (om_msg & 1)
    {
        struct EMSgeomdata dim_geom;
        IGRint             dim_type;        

        om_msg = om$send ( msg = message EMSdim.EMautodimparam
                                            ( (IGRlong *)msg,
                                              NULL,
                                              &temp_mat_type,
                                              temp_mat,
                                              param_id.objid,
                                              NULL,
                                              NULL,
                                              &dim_geom,
                                              &dim_type ),
                           targetid = my_id );

        if (om_msg & *msg & 1)
        {
            switch (dim_type)
            {
                case SINGLE_PARALLEL:

                    if (dim_geom.geomtype == GEOMDATA_LINE)
                    {
                        str->type = DMkeyseg;
                        str->var.dm_keyseg.u_par = 0.0;

                        memcpy (str->var.dm_keyseg.line, 
                              dim_geom.line.line_pt1, sizeof(IGRpoint));
                        memcpy (&str->var.dm_keyseg.line[3], 
                              dim_geom.line.line_pt2, sizeof(IGRpoint));

                        MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                                       md_env->md_env.matrix,
                                       str->var.dm_keyseg.line,
                                       str->var.dm_keyseg.line);
                        if (!(1&*msg)) goto ret_end;

                        MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                                       md_env->md_env.matrix,
                                       &str->var.dm_keyseg.line[3],
                                       &str->var.dm_keyseg.line[3]);
                        if (!(1&*msg)) goto ret_end;
                    }
                    else *msg = EMS_E_Fail;
                    break;

                case STACKED_LINEAR:
                case LINEAR_DIAMETER:

                    if (dim_geom.geomtype == GEOMDATA_LINE)
                    {
                        str->type =DMkeypt;
                        str->var.dm_keypt.u_par = 0.0;
                        memcpy ( str->var.dm_keypt.point,
                                 (type & ORIG_INFO) ?
                                 dim_geom.line.line_pt1 : 
                                    dim_geom.line.line_pt2,
                                 sizeof(IGRpoint));

                        MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                                       md_env->md_env.matrix,
                                       str->var.dm_keypt.point,
                                       str->var.dm_keypt.point);
                        if (!(1&*msg)) goto ret_end;
                    }
                    else *msg = EMS_E_Fail;
                    break;

                case RADIAL:

                    if (dim_geom.geomtype == GEOMDATA_CURVE)
                    {
                      struct IGRbsp_curve *cv;

                        str->type = DMradcen;
                        str->var.dm_radcen.u_par = 0.5;

                        cv=dim_geom.curve;

                        if (cv->rational)
                         MArptsxform(&msg_loc, &cv->num_poles, &cv->rational,
                           cv->weights, 
                           md_env->md_env.matrix,
                           cv->poles,
                           cv->poles);
                        else
                         MAoptsxform(&msg_loc, &cv->num_poles, 
                           &md_env->md_env.matrix_type,
                            md_env->md_env.matrix,
                           cv->poles, cv->poles);
                        if (!(1&msg_loc))
                        {
                          *msg = EMS_E_Fail;
                          goto ret_end;
                        }

                        MAbctoar (&msg_loc, cv, &arc);
                        memcpy (str->var.dm_radcen.center, 
                            arc.origin, sizeof(IGRpoint));
                        memcpy (&str->var.dm_radcen.radius, 
                            &arc.prim_axis, sizeof(IGRdouble));
                        MAbcueval(&msg_loc, cv, &option, &parm, 
                                  str->var.dm_radcen.point, NULL);
                        str->var.dm_radcen.on_curve = TRUE;

                    }
                    else *msg = EMS_E_Fail;
                    break;

                case SINGLE_ARC_LENGTH:
                case SINGLE_ARC_ANGLE:

                    if (dim_geom.geomtype == GEOMDATA_CURVE)
                    {
                        str->type = DMarc;
                        MAbctoar (&msg_loc, dim_geom.curve, &arc);
                        memcpy (str->var.dm_arc.center, arc.origin, sizeof(IGRpoint));
                        MAarendpts (&msg_loc, &arc, points);
                        memcpy (str->var.dm_arc.start_pt, points, sizeof(IGRpoint));
                        memcpy (str->var.dm_arc.end_pt, &points[3], sizeof(IGRpoint));

                        MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                                       md_env->md_env.matrix,
                                       str->var.dm_arc.center,
                                       str->var.dm_arc.center);
                        if (!(1&*msg)) goto ret_end;

                        MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                                       md_env->md_env.matrix,
                                       str->var.dm_arc.start_pt,
                                       str->var.dm_arc.start_pt);
                        if (!(1&*msg)) goto ret_end;

                        MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                                       md_env->md_env.matrix,
                                       str->var.dm_arc.end_pt,
                                       str->var.dm_arc.end_pt);
                        if (!(1&*msg)) goto ret_end;
                    }
                    else *msg = EMS_E_Fail;
                    break;


                case TEXT_WITH_LEADER:
                    if (dim_geom.geomtype == GEOMDATA_POINT) 
                    {
                        str->type = DMptdist;
                        str->var.dm_ptdist.u_par = 0.0;

			/* Purify fix - initialize dim return structure vec */
			str->var.dm_ptdist.vec[0] = 0.0;
			str->var.dm_ptdist.vec[1] = 0.0;
			str->var.dm_ptdist.vec[2] = 0.0;

                        MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                                       md_env->md_env.matrix,
                                       dim_geom.point,
                                       dim_geom.point);
                        if (!(1&*msg)) goto ret_end;

                        memcpy (str->var.dm_ptdist.point,dim_geom.point,
				sizeof(IGRpoint));
		    }
		    break;


                case STACKED_ANGULAR:
                case STRINGED_ANGULAR:
                    if (dim_geom.geomtype == GEOMDATA_LINE)
                    {
                        str->type = DMkeyseg;
                        str->var.dm_keyseg.u_par = (type & ORIG_INFO) ? 0.0 : 1.0;
                        memcpy (str->var.dm_keyseg.line, dim_geom.line.line_pt1, sizeof(IGRpoint));
                        memcpy (&str->var.dm_keyseg.line[3], dim_geom.line.line_pt2, sizeof(IGRpoint));

                        MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                                       md_env->md_env.matrix,
                                       str->var.dm_keyseg.line,
                                       str->var.dm_keyseg.line);
                        if (!(1&*msg)) goto ret_end;

                        MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                                       md_env->md_env.matrix,
                                       &str->var.dm_keyseg.line[3],
                                       &str->var.dm_keyseg.line[3]);
                        if (!(1&*msg)) goto ret_end;
                    }
                    break;

                case STRINGED_LINEAR:
                case SYMMETRICAL_DIAMETER:
                case CIRCULAR_DIAMETER:
                case RADIAL_DIAMETER:
                case COORDINATE:
                case CENTER_LINE:
                case CHAMFER:
                case TEXT_WITH_BALLOON:
                case LEADER_LINE:
                case FEATURE_CONTROL_FRAME:
                case DATUM_FRAME:
                default:
                    printf("Unsupported type in DMgive_structure\n");
                    *msg = EMS_E_Fail;
                    break;
            }
        }
    }

 ret_end:

    return (om_msg);
}



/* Tapadia - 10/15/91 - Creation. This doesn't modify the attach point but
prevents from erroring out. Maybe sometime later will have to change it to 
return the new mofified point */

method DMmodify(IGRint          * msg;
              	struct GRmd_env * md_env;	
		IGRint key;
		IGRboolean ptdist;
		struct IGRline *boreline )
{
    return (OM_S_SUCCESS);
}

method give_plane ( IGRint          * msg;
                    IGRmatrix         matrix;
                    struct GRmd_env * md_env )
{
    IGRlong         om_msg = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    IGRint          i, count;
    IGRpoint        origpt, xpt, ypt;
    IGRpoint        neworigpt, newxpt, newypt;
    IGRvector       zaxis, xaxis, yaxis;
    IGRvector	    std_x, std_y, std_z;
    IGRdouble       dist1, dist2, scale_fac;
    struct IGRplane dim_plane;
    struct GRid     assoc_id, dim_id, param_id, tmp_grid;
    OMuword         classid;
    OM_S_CHANSELECT father_chansel;
    IGRmatrix temp_mat;
    IGRshort temp_mat_type;
    IGRdouble	    dotx, doty, dotz;
    extern IGRdouble fabs();
    *msg = EMS_S_Success;

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    dim_id.objid   = sender_id;
    dim_id.osnum   = sender_os;

    /* find if the dimension object's first child is an ASsourcein object and
     * if it is, assume this dimension object has a counterpart dimension;
     * further assume we get this counterpart by sending ASreturn_go to the
     * last element on this dimension's father channel
     */

    EMmake_chanselect (NDfather_father, &father_chansel);

    om$get_objid_at_index ( objid = sender_id,
                            osnum = sender_os,
                            p_chanselect = &father_chansel,
                            index = DIM_ROOT_PLAN,
                            objidaddr = &tmp_grid.objid,
                            osnumaddr = &tmp_grid.osnum );

    om$get_classid ( objid = tmp_grid.objid,
                     osnum = tmp_grid.osnum,
                     p_classid = &classid );

    if (classid == OPP_ASsourcein_class_id)
    {
        om$get_channel_count ( objid = sender_id, 
                               osnum = sender_os,
                               p_chanselect = &father_chansel, 
                               count = (OMuint *)&count );

        if (count)
        {
            count--;

	    om_msg = om$send(msg = message NDnode.ASreturn_go(
   				&tmp_grid,
				&temp_mat_type,
				temp_mat),
                            senderid = sender_id,
                            targetos = sender_os,
		            p_chanselect = &father_chansel,
		            from = count,
		            to = count);
            EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

            dim_id = tmp_grid;
        }
    }

    om_msg = EFget_active_parameter (&assoc_id, &dim_id, &param_id);

    if (om_msg & 1)
    {
      IGRlong one = 1,rc;
        /*
         * Obtain the dimension plane.
         */
        dim_plane.point = origpt;
        dim_plane.normal = zaxis;

        temp_mat_type = MAIDMX;
        MAidmx((IGRlong *)msg,temp_mat);

        om_msg = om$send ( msg = message EMSdim.EMautodimparam
                                            ( (IGRlong *)msg,
                                              NULL,
                                              &temp_mat_type,
                                              temp_mat,
                                              param_id.objid,
                                              &dim_plane,
                                              xaxis,
                                              NULL,
                                              NULL ),
                           targetid = my_id );
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
 
        /*
         * From the origin point, x-axis and the z-axis, compute 
         * dimension plane's transformation matrix.
         */

	/***********************************************************
		give_plane returns only the window matrix, the
		measurment axis is filled by give_axis message.

		Check whether the vector is orthogonal if so from
		the normal get the closest standard normal(x, y,
		and z from top view) from that find out the proper
		xaxis. use this zaxis and xaxis to determine the plane.

		I don't know how we can do in nor-orthogonal cases
		and you might have to do some optimization of this code.
	************************************************************/

	BSnorvec(&rc, zaxis);

	if ((fabs(zaxis[0]) > 0.998)
	||  (fabs(zaxis[1]) > 0.998)
	||  (fabs(zaxis[2]) > 0.998))
	{
		std_x[0] = std_y[1] = std_z[2] = 1.0;
		std_x[1] = std_x[2] = 0.0;
		std_y[0] = std_y[2] = 0.0;
		std_z[0] = std_z[1] = 0.0;

		dotx = BSdotp(&msg_loc, zaxis, std_x);
		doty = BSdotp(&msg_loc, zaxis, std_y);
		dotz = BSdotp(&msg_loc, zaxis, std_z);

		if (fabs(dotx) > 0.998)
		{
			/*Right or left view*/

			if (dotx > 0.)
			{
				for(i=0; i<3; i++)
					xaxis[i] = std_y[i];
			}
			else
			{
				for(i=0; i<3; i++)
					xaxis[i] = -std_y[i];
			}
		}

		if (fabs(doty) > 0.998)
		{
			/* Front or back view*/

			if (doty > 0.)
			{
				for(i=0; i<3; i++)
					xaxis[i] = -std_x[i];
			}
			else
			{
				for(i=0; i<3; i++)
					xaxis[i] = std_x[i];
			}
		}

		if (fabs(dotz) > 0.998)
		{
			/* Top or Bottom view*/

			if (dotz > 0.)
			{
				for(i=0; i<3; i++)
					xaxis[i] = std_x[i];
			}
			else
			{
				for(i=0; i<3; i++)
					xaxis[i] = -std_x[i];
			}
		}
	}


	/***********************************************************/

        BScrossp (&msg_loc, zaxis, xaxis, yaxis);
        BSnorvec (&msg_loc, yaxis);

        for (i=0; i<3; i++)
        {
            xpt[i] = origpt[i] + xaxis[i];
            ypt[i] = origpt[i] + yaxis[i];
        }

        if (md_env->md_env.matrix_type != MAIDMX)
        {
         MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                    md_env->md_env.matrix,
                    origpt,
                    neworigpt);
         if (!(1&*msg)) goto ret_end;

         MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                    md_env->md_env.matrix,
                    xpt,
                    newxpt);
         if (!(1&*msg)) goto ret_end;

         MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                    md_env->md_env.matrix,
                    ypt,
                    newypt);
         if (!(1&*msg)) goto ret_end;
         dist1 = BSdistptpt(&msg_loc, origpt, xpt);
         dist2 = BSdistptpt(&msg_loc, neworigpt, newxpt);
         scale_fac = dist2/dist1;

         MA3protmx (&msg_loc, neworigpt, newxpt, newypt, matrix);
         EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

         for (i=0;i<3;i++)
         {
          matrix[i] *= scale_fac;
          matrix[4+i] *= scale_fac;
          matrix[8+i] *= scale_fac;
         }
        }
        else
        {
         scale_fac = 1.0;
         MA3protmx (&msg_loc, origpt, xpt, ypt, matrix);
         EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
       }

ret_end:

    return (om_msg);
}

method give_axis  ( IGRint          * msg;
                    IGRvector         axis;
                    struct GRmd_env * md_env )
{
    IGRlong         om_msg = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    IGRint          i, count;
    IGRpoint        origpt, xpt;
    IGRpoint        neworigpt, newxpt;
    IGRvector       zaxis, xaxis;
    struct IGRplane dim_plane;
    struct GRid     assoc_id, dim_id, param_id, tmp_grid;
    OMuword         classid;
    OM_S_CHANSELECT father_chansel;
    IGRmatrix temp_mat;
    IGRshort temp_mat_type;

    *msg = EMS_S_Success;

	/*************************************************************
		This message was returning NO_AXIS before, now it is
		modified to return the measurement axis since the
		"give_plane" message returns only window plane
	**************************************************************/

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    dim_id.objid   = sender_id;
    dim_id.osnum   = sender_os;

    /* find if the dimension object's first child is an ASsourcein object and
     * if it is, assume this dimension object has a counterpart dimension;
     * further assume we get this counterpart by sending ASreturn_go to the
     * last element on this dimension's father channel
     */

    EMmake_chanselect (NDfather_father, &father_chansel);

    om$get_objid_at_index ( objid = sender_id,
                            osnum = sender_os,
                            p_chanselect = &father_chansel,
                            index = DIM_ROOT_PLAN,
                            objidaddr = &tmp_grid.objid,
                            osnumaddr = &tmp_grid.osnum );

    om$get_classid ( objid = tmp_grid.objid,
                     osnum = tmp_grid.osnum,
                     p_classid = &classid );

    if (classid == OPP_ASsourcein_class_id)
    {
        om$get_channel_count ( objid = sender_id, 
                               osnum = sender_os,
                               p_chanselect = &father_chansel, 
                               count = (OMuint *)&count );

        if (count)
        {
            count--;

	    om_msg = om$send(msg = message NDnode.ASreturn_go(
   				&tmp_grid,
				&temp_mat_type,
				temp_mat),
                            senderid = sender_id,
                            targetos = sender_os,
		            p_chanselect = &father_chansel,
		            from = count,
		            to = count);
            EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

            dim_id = tmp_grid;
        }
    }

    om_msg = EFget_active_parameter (&assoc_id, &dim_id, &param_id);

    if (om_msg & 1)
    {
      IGRlong one = 1;
        /*
         * Obtain the dimension plane.
         */
        dim_plane.point = origpt;
        dim_plane.normal = zaxis;

        temp_mat_type = MAIDMX;
        MAidmx((IGRlong *)msg,temp_mat);

        om_msg = om$send ( msg = message EMSdim.EMautodimparam
                                            ( (IGRlong *)msg,
                                              NULL,
                                              &temp_mat_type,
                                              temp_mat,
                                              param_id.objid,
                                              &dim_plane,
                                              xaxis,
                                              NULL,
                                              NULL ),
                           targetid = my_id );
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
 
        for (i=0; i<3; i++)
            xpt[i] = origpt[i] + xaxis[i];

        if (md_env->md_env.matrix_type != MAIDMX)
        {
         MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                    md_env->md_env.matrix,
                    origpt,
                    neworigpt);
         if (!(1&*msg)) goto ret_end;

         MAoptsxform((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                    md_env->md_env.matrix,
                    xpt,
                    newxpt);
         if (!(1&*msg)) goto ret_end;

	 BSmkvec(&msg_loc, axis, neworigpt, newxpt);
	 BSnorvec(&msg_loc, axis);
        }
        else
        {
	 BSmkvec(&msg_loc, axis, origpt, xpt);
	 BSnorvec(&msg_loc, axis);
        }
       }


ret_end:

    return (om_msg);
}

method EMassoc_autodimparam (   IGRlong		   *msg; 
				IGRushort           opts;
                        	IGRshort	   *mattyp; 
                        	IGRmatrix	    mat;
	                        GRobjid		    paramobj; 
        	                struct IGRplane    *dim_plane;
                	        IGRdouble 	   *dim_plane_xaxis;
                        	struct EMSgeomdata *dim_geom;
	                        IGRint		   *dim_type )
	                        
{
    IGRlong om_msg = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    om_msg = om$send ( msg = message EMSdim.EMautodimparam
                                            ( msg,
                                              opts,
                                              mattyp,
                                              mat,
                                              paramobj,
                                              dim_plane,
                                              dim_plane_xaxis,
                                              dim_geom,
                                              dim_type ),
                           targetid = my_id );
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
ret_end:
  EMWRAPUP (*msg, om_msg, "EMSdim.EMassoc_autodimparam");
  return (om_msg);        
}

method EMassoc_dimparam (IGRlong *msg; struct GRmd_env *mod_env;
                   IGRushort options;
                   IGRint type; IGRchar *info;
                   IGRint num_parents; struct GRid *parents;
                   IGRint index; 
                   struct IGRplane *dim_plane; IGRdouble *dim_plane_xaxis;
                   struct EMSgeomdata *dim_geom; IGRint *dim_type)
{
    IGRlong om_msg = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    om_msg = om$send ( msg = message EMSdim.EMdimparam 
                                              ( msg,
                                                mod_env,
                                                options,
                                                me->type,
                                                me->info,
                                                num_parents,
                                                parents,
                                                index,
                                                dim_plane,
                                                dim_plane_xaxis,
                                                dim_geom,
                                                dim_type ),
                               targetid = my_id );  
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
ret_end:
  EMWRAPUP (*msg, om_msg, "EMSdim.EMassoc_dimparam");
  return (om_msg);        
}
 
end implementation EMSdim;
