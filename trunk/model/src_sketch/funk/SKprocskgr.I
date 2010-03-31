class implementation SKmgr;

#include <alloca.h>
#include <math.h>
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "parametric.h"
#include "asmacros.h"
#include "griodef.h"
#include "dimdef.h"
#include "dimsrc.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSasopts.h"

#include "ma.h"
#include "maptpldis.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  	0
#define SECOND 	1
#define LAST   	MAXINT
#define INVALID	-1

#define MAX_DEF_PTS	5

#define X 0
#define Y 1
#define Z 2

from DMsrc 	import DMgive_src_info;
from SKgeometry import SKgetmgr;
from SKvariable import SKgetmgr;
from SKasptgrnd import SKinit_assocpt_ground;
from GRcurve 	import GRendpts;
from SKvariable import SKgetvar;

extern GRclassid OPP_SKptvar_class_id, OPP_SKpoint_class_id;
extern GRclassid OPP_SKarc_class_id, OPP_SKcircle_class_id;
extern GRclassid OPP_DMsrc_class_id;

/*

Name
  SKprocess_sketch_graphics

Abstract

Synopsis

Description

Return Value
    The following return codes are possible:
    EMS_S_Success, EMS_I_Assoc - if all went well. If the code is
                                  set to FoundOther, then an association to
                                  an element outside the indicated sketch
                                  has been made.
    EMS_I_BadPlane - If processing stopped because plane mismatched
                      and this interruption was requested.
    EMS_I_Merge - If processing stopped because of a merge of sketches
                   took place and this interruption was requested.
    EMS_E_Fail - Other failure

Notes

Index

Keywords

History
 ??????   : Siki   : creation
 10/28/92 : RA 	   : Changed the number of assoc_grounds created for an arc from 3 to 2.
 07/02/93 : Sudha  : Modified for BSprototypes ansification
 10/28/93 : Rajiv Agrawal : Removed checking for parallel planes to merge. Handled now 
                            in the SKmergemgr code. (TR#119310913)

 */

IGRlong SKprocess_sketch_graphics (
    IGRlong 		*msg,
    IGRushort 		options,
    struct GRmd_env 	*md_env,
    struct GRid 	*skelem_id,
    IGRmatrix 		chkplnmat,
    struct GRevent 	*pt_event,
    IGRint 		num_graph_ids,
    struct GRid 	*graph_ids,
    IGRint 		*num_graph_skpts,
    GRobjid 		*graph_skpts )
{
  IGRboolean 		merged, is_goodpln;
  IGRint 		i, tmpnum;
  IGRlong 		msg_loc, stat_OM;
  GRobjid 		driven_mgr, *p_objs;
  GRspacenum 		driven_os;
  struct GRid 		tmpid, *graph_mgrs, skptid, driven_grid;
  extern IGRboolean 	SKisparskpln();
  extern void 		SKprocess_sketch_event();
  extern long 		SKndsk_assocgrnds(), SKndsk_vgpts();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the sketch manager for the primary sketch-element
   */

  driven_mgr = NULL_OBJID;
  om$send (msg = message SKgeometry.SKgetmgr (&msg_loc, &driven_mgr),
   targetid = skelem_id->objid, targetos = skelem_id->osnum,
   senderid = NULL_OBJID);

  if (IF_NULL_OBJID (driven_mgr))
    om$send (msg = message SKvariable.SKgetmgr (&msg_loc, &driven_mgr),
     targetid = skelem_id->objid, targetos = skelem_id->osnum,
     senderid = NULL_OBJID);
  
  EMerr_hndlr (IF_NULL_OBJID (driven_mgr), *msg, EMS_E_InvalidArg, ret_end);
  driven_os = skelem_id->osnum;
  driven_grid.objid = driven_mgr;
  driven_grid.osnum = driven_os;

  /*
   * If the option is to proceed only if the primary sketch's plane
   * matches the input plane, then perform the check here.
   */

  if (chkplnmat)
  {
    tmpid.objid = driven_mgr;
    tmpid.osnum = driven_os;
    is_goodpln = SKisparskpln (&msg_loc, NULL, md_env, &tmpid,
                  NULL, NULL, NULL, chkplnmat);
    EMerr_hndlr (!is_goodpln, *msg, EMS_I_BadPlane, ret_end);
  }

  /*
   * If a pt_event is input (means that a single vg-point is to be finally
   * returned), some special handling is necessary. The processing is
   * done such that the event outputs an SKptvar belonging to the 
   * primary sketch (could be an associatively grounded point).
   */

  if (pt_event)
  {
    tmpid.objid = driven_mgr;
    tmpid.osnum = driven_os;
    SKprocess_sketch_event (&msg_loc, options, md_env, &tmpid, pt_event,
     &skptid.objid);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    EMerr_hndlr (msg_loc == EMS_I_Cycle, *msg, msg_loc, ret_end);
    if (msg_loc == EMS_I_Assoc)
      *msg = msg_loc;
    skptid.osnum = driven_os;

    num_graph_ids = 1;
    graph_ids = &skptid;
  }

  /*
   * Obtain the sketch-managers for each of the graphics objects. If
   * there is none (element does not belong to a sketch), store NULL_OBJID.
   */
  graph_mgrs = (struct GRid *) alloca (num_graph_ids * sizeof (struct GRid));
  EMerr_hndlr (!graph_mgrs, *msg, EMS_E_NoStackMemory, ret_end);

  for (i=0; i<num_graph_ids; i++)
  {
    graph_mgrs[i].objid = NULL_OBJID;
    graph_mgrs[i].osnum = graph_ids[i].osnum;

    om$send (msg = message SKgeometry.SKgetmgr (&msg_loc, &graph_mgrs[i].objid), 
             targetid = graph_ids[i].objid,
             targetos = graph_ids[i].osnum, senderid = NULL_OBJID);

    if (graph_mgrs[i].objid == NULL_OBJID)
      om$send (msg = message SKvariable.SKgetmgr (&msg_loc, &graph_mgrs[i].objid), 
               targetid = graph_ids[i].objid,
               targetos = graph_ids[i].osnum, senderid = NULL_OBJID);
  }

  if (options & SK_PROCSKGR_MERGESK)
  {
    merged = FALSE;
    for (i = 0; i < num_graph_ids; i++)
      if (!IF_NULL_OBJID (graph_mgrs[i].objid) &&
          (graph_mgrs[i].objid != driven_mgr &&
           graph_mgrs[i].osnum == driven_os))
      {
        /*
         * Make sure there are no dependencies. The graph says you are dependent upon
         * yourself, so test for that first. We need to make that check only when we merge
         * the profiles.
         */
        stat_OM = om$send (msg = message SKmgr.SKmergemgr ( &msg_loc,
                  SK_UPDATE_INFOERROR | SK_UPDATE_DONOTPOST, md_env, graph_mgrs[i].objid ),
                  targetid = driven_mgr, targetos = driven_os,
                  senderid = NULL_OBJID);
        EMerr_hndlr ( EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end );

        if (msg_loc == EMS_S_Success)
        {
          if (nd$dep_exist ( l_root = &driven_grid, nb_root = 1, 
                             l_tip = &graph_mgrs [i], nb_tip = 1) || 
              nd$dep_exist ( l_tip = &driven_grid, nb_tip = 1, 
                             l_root = &graph_mgrs [i], nb_root = 1))
          {
            *msg = EMS_I_Cycle;
            goto ret_end;
          }

          stat_OM = om$send (msg = message SKmgr.SKmergemgr (&msg_loc,
                    SK_UPDATE_INFOERROR, md_env, graph_mgrs[i].objid),
                    targetid = driven_mgr, targetos = driven_os,
                    senderid = NULL_OBJID);
          EMerr_hndlr ( EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end );
            
          if (msg_loc == EMS_S_Success)
          {
            graph_mgrs[i].objid = driven_mgr;
            merged = TRUE;
          }
        }
      }

    EMerr_hndlr ( options & SK_PROCSKGR_MERGERETURN && merged, *msg, EMS_I_Merge, ret_end );
  }  

  /*
   * Return the variational-geometry point-variables corresponding to
   * the points in the graphic-objects. If the graphic-object does not
   * belong to this sketch-manager then an associative ground point is
   * generated within this sketch and is returned
   */

  *num_graph_skpts = 0;
  for (i=0; i<num_graph_ids; i++)
  {
    tmpid.objid = driven_mgr;
    tmpid.osnum = driven_os;

    p_objs = &graph_skpts[*num_graph_skpts];
    if (graph_mgrs[i].objid != driven_mgr ||
        graph_mgrs[i].osnum != driven_os)
    {
      stat_OM = SKndsk_assocgrnds (&msg_loc, options, md_env,
                 &graph_ids[i], &tmpid, &tmpnum, &p_objs);
      *msg = EMS_I_Assoc;
    }          
    else
    {
      stat_OM = SKndsk_vgpts (&msg_loc, options, md_env,
                 &graph_ids[i], &tmpnum, &p_objs);
    }
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    (*num_graph_skpts) += tmpnum;
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKprocess_sketch_graphics");
  return (stat_OM);
}



void SKprocess_sketch_event (msg, opts, md_env, skid, pt_event, sk_eventpt)
IGRlong *msg;
IGRushort opts;
struct GRmd_env *md_env;
struct GRid *skid;
struct GRevent *pt_event;
GRobjid *sk_eventpt;
{
  IGRint inx, count;
  IGRlong msg_loc, stat_OM;
  IGRpoint endpts[2];
  GRclassid ptclass;
  struct GRid ptid, cnstr_grid;
  OM_S_CHANSELECT chan_to_defpts;
  OM_S_OBJECT_LINKAGE ptlist[4];
  long SKndsk_assocgrnds();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (!pt_event->num_id, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * If the pt_event object is already a sketch-point in this object
   * space, or points to a sketch-element in this object space, return this.
   */

  if (pt_event->subtype == GRst_REGULAR)
  {
    ptid = pt_event->located_object[0].located_obj;
    om$get_classid (objid = ptid.objid, osnum = ptid.osnum,
     p_classid = &ptclass);
    if (om$is_ancestry_valid (subclassid = ptclass, 
         superclassid = OPP_SKptvar_class_id) == OM_S_SUCCESS)
    {
      *sk_eventpt = ptid.objid;
      goto ret_end;
    }
    else if (om$is_ancestry_valid (subclassid = ptclass, 
              superclassid = OPP_SKpoint_class_id) == OM_S_SUCCESS)
    {
      EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
      count = 0;
      om$get_channel_objects (objid = ptid.objid, osnum = ptid.osnum,
       p_chanselect = &chan_to_defpts, count = (OMuint *)&count, size = 4,
       list = ptlist);
      if (count)
      {
        *sk_eventpt = ptlist[0].S_objid;
        goto ret_end;
      }
    }
  }

  else if (pt_event->subtype == GRst_KEYPOINT ||
           pt_event->subtype == GRst_CENTER)
  {
    ptid = pt_event->located_object[0].located_obj;
    if (ptid.osnum == skid->osnum)
    {
      om$get_classid (objid = ptid.objid, osnum = ptid.osnum,
       p_classid = &ptclass);
      if ((pt_event->subtype == GRst_KEYPOINT &&
           om$is_ancestry_valid (subclassid = ptclass, 
            superclassid = OPP_SKgeometry_class_id) == OM_S_SUCCESS) ||
          (pt_event->subtype == GRst_CENTER &&
           (om$is_ancestry_valid (subclassid = ptclass, 
             superclassid = OPP_SKarc_class_id) == OM_S_SUCCESS ||
            om$is_ancestry_valid (subclassid = ptclass, 
             superclassid = OPP_SKcircle_class_id) == OM_S_SUCCESS)))
        {
        if (pt_event->subtype == GRst_KEYPOINT)
        {
          stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc,
                     &md_env->md_env.matrix_type, md_env->md_env.matrix,
                     endpts[FIRST], endpts[SECOND]), targetid = ptid.objid,
                     targetos = ptid.osnum, senderid = NULL_OBJID);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);

          if (BSdistptpt (&msg_loc, endpts[FIRST], &pt_event->event.button.x) <
              BSdistptpt (&msg_loc, endpts[SECOND], &pt_event->event.button.x))
            inx = FIRST;
          else 
            inx = LAST;
        }
        else if (pt_event->subtype == GRst_CENTER)     /* center of arc/circle */
          inx = SECOND;

        EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
        count = 0;
        om$get_channel_objects (objid = ptid.objid, osnum = ptid.osnum,
                                p_chanselect = &chan_to_defpts, 
                                count = (OMuint *)&count, size = 4,
                                list = ptlist);
        if (count)
        {
          if (inx == FIRST)
            *sk_eventpt = ptlist[FIRST].S_objid;
          else if (inx == SECOND)
            *sk_eventpt = ptlist[SECOND].S_objid;
          else   
            *sk_eventpt = ptlist[count-1].S_objid;
          goto ret_end;
        }
      }
    }
  }

  /*
   * In all other cases an associative ground pt is constructed which
   * listens to the event.
   */

  *msg = EMS_I_Assoc;
  EMasptcnstr (&msg_loc, 
               opts & SK_PROCSKGR_CHKCYCLE ? EMScnstr_check_cycle : NULL,
               md_env, pt_event, 0, NULL, &cnstr_grid.objid);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NotSupported, *msg, EMS_E_NotSupported, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_Cycle, *msg, msg_loc, ret_end);
  cnstr_grid.osnum = md_env->md_id.osnum;

  stat_OM = SKndsk_assocgrnds (&msg_loc, opts, md_env, &cnstr_grid, skid,
                               &count, &sk_eventpt);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
  if (msg_loc == EMS_I_Cycle)
  {
    om$send (msg = message GRgraphics.GRdelete (&msg_loc, md_env),
     targetid = cnstr_grid.objid, targetos = cnstr_grid.osnum,
     senderid = NULL_OBJID);

    *msg = EMS_I_Cycle;
    goto ret_end;
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKprocess_sketch_event");
  return;
}



IGRlong SKndsk_assocgrnds (msg, options, md_env, grobj, mgrid, 
                           num_vgpts, vgpts)
IGRlong *msg;
IGRushort options;
struct GRmd_env *md_env;
struct GRid *grobj, *mgrid;
IGRint *num_vgpts;
GRobjid **vgpts;
{
  IGRboolean found;
  IGRushort loc_opts;
  IGRint i, j, startinx, inxlim;
  OMuint geom_count, var_count, index;
  IGRlong msg_loc, stat_OM;
  GRobjid grmgr;
  GRclassid class;
  struct GRid ndid, dumid, loc_grobj, cnstrid[MAX_DEF_PTS];
  struct ret_struct ret_struct;
  OM_S_OBJECT_LINKAGE geom_list[2];
  OM_S_CHANSELECT chan_to_defpts, chan_to_geoms;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *num_vgpts = 0;

  om$get_classid (objid = grobj->objid, osnum = grobj->osnum,
                  p_classid = &class);
  if (om$is_ancestry_valid (subclassid = class,
       superclassid = OPP_SKptvar_class_id) == OM_S_SUCCESS)
  {
    grmgr = NULL_OBJID;
    om$send (msg = message SKvariable.SKgetmgr (&msg_loc, &grmgr),
     targetid = grobj->objid, targetos = grobj->osnum, senderid = NULL_OBJID);
    if (grmgr == mgrid->objid && grobj->osnum == mgrid->osnum)
      {
      *num_vgpts = 1;

      if (! *vgpts)
        *vgpts = (GRobjid *) om$malloc (size = sizeof (GRobjid));
      EMerr_hndlr (!*vgpts, *msg, EMS_E_NoDynamicMemory, ret_end);
      (*vgpts)[FIRST] = grobj->objid;
   
      goto ret_end;
      }

    geom_count = 0;
    EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
    om$get_channel_objects (objid = grobj->objid, osnum = grobj->osnum,
     p_chanselect = &chan_to_geoms, count = &geom_count, size = 2,
     list = geom_list);
   
    EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
    found = FALSE;
    for (i=0; i<geom_count; i++)
      {
      var_count = 0;
      om$get_channel_count (objid = geom_list[i].S_objid,
       osnum = grobj->osnum, p_chanselect = &chan_to_defpts,
       count = &var_count);

      om$get_index (osnum_c = grobj->osnum, objid_c = geom_list[i].S_objid,
       p_chanselect = &chan_to_defpts, objid = grobj->objid,
       osnum2 = grobj->osnum, indexaddr = &index);

      if (index == 0 || index == var_count-1)
        {
        found = TRUE;
        break;
        }
      }
    EMerr_hndlr (!found, *msg, EMS_E_Fail, ret_end);

    loc_grobj.objid = geom_list[i].S_objid;
    loc_grobj.osnum = grobj->osnum;

    dumid.objid = NULL_OBJID;
    stat_OM = as$make_source (go_grid = loc_grobj, context_grid = dumid,
               as_os = md_env->md_id.osnum, as_grid = &ndid);
    EMomerr_exit (stat_OM, ret_end);
  
    startinx = index;
    inxlim = 1;
  }
  else
  {
    loc_grobj = *grobj;

    dumid.objid = NULL_OBJID;
    stat_OM = as$make_source (go_grid = loc_grobj, context_grid = dumid,
               as_os = md_env->md_id.osnum, as_grid = &ndid);
    EMomerr_exit (stat_OM, ret_end);
  
    stat_OM = om$send (msg = message NDnode.NDgive_structure (&msg_loc,
               &ret_struct, md_env), targetid = ndid.objid,
               targetos = ndid.osnum, senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    startinx = 0;             
    if (ret_struct.type == point_generic)
      inxlim = 1;
    else if (ret_struct.type == line_generic)
      inxlim = 2;
    else if (ret_struct.type == circle_type)
      inxlim = 2;
    else if (ret_struct.type == arc_type)
      inxlim = 2;
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_NotSupported, ret_end);}
  }

  if (! *vgpts)
    *vgpts = (GRobjid *) om$malloc (size = inxlim * sizeof (GRobjid));
  EMerr_hndlr (!*vgpts, *msg, EMS_E_NoDynamicMemory, ret_end);

  loc_opts = SK_OPT_MARK_AS_NEWADD | SK_OPT_MARK_AS_USERADD |
              (options & SK_PROCSKGR_GRAPHHANDLE ? 
               (SK_OPT_CREATE_GEOMETRY | SK_OPT_DISPLAY_GEOMETRY) : NULL);
  for (i=startinx, j=0; i<startinx+inxlim; i++, j++)
  {
    (*vgpts)[j] = NULL_OBJID;
    stat_OM = om$construct (classid = OPP_SKasptgrnd_class_id,
               osnum = mgrid->osnum,
               msg = message SKasptgrnd.SKinit_assocpt_ground
               (&msg_loc, loc_opts,
               md_env, &ndid, i, mgrid->objid, NULL, &(*vgpts)[j]),
               p_objid = &cnstrid[j].objid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    (*num_vgpts)++;
  }

  if (options & SK_PROCSKGR_CHKCYCLE &&
      nd$dep_exist (l_root = mgrid, nb_root = 1, 
       l_tip = &ndid, nb_tip = 1))
  {
    for (i=0; i<inxlim; i++)
    {
      enum GRdpmode 	dpmode;
      /*
       * erase the display before deleting the constrids
       * TR # 119315111        - GMK   01/06/93
       */
      dpmode = GRbe;
      om$send (msg = message GRgraphics.GRdisplay
                              (&msg_loc, &md_env->md_env.matrix_type,
                               md_env->md_env.matrix, &dpmode, &md_env->md_id),
               targetid = cnstrid[i].objid, targetos = mgrid->osnum,
               senderid = NULL_OBJID);

      om$send (msg = message GRgraphics.GRdelete (&msg_loc, md_env),
               targetid = cnstrid[i].objid, targetos = mgrid->osnum,
               senderid = NULL_OBJID);
    }
    *msg = EMS_I_Cycle;
    goto ret_end;
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKndsk_assocgrnds");
  return (stat_OM);
}


#argsused
IGRlong SKndsk_vgpts (msg, options, md_env, grid,
                      num_vgpts, vgpts)
IGRlong *msg;
IGRushort options;
struct GRmd_env *md_env;
struct GRid *grid;
IGRint *num_vgpts;
GRobjid **vgpts;
{
  IGRint i;
  OMuint count;
  IGRlong stat_OM;
  GRclassid class;
  OM_S_CHANSELECT chan_to_defpts;
  OM_S_OBJECT_LINKAGE *objlist, objlist_mem;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  om$get_classid (objid = grid->objid, osnum = grid->osnum,
   p_classid = &class);
  if (om$is_ancestry_valid (subclassid = class,
       superclassid = OPP_SKgeometry_class_id) == OM_S_SUCCESS)
    {
    EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
    stat_OM = om$get_channel_count (objid = grid->objid, osnum = grid->osnum,
               p_chanselect = &chan_to_defpts, count = &count);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_InvalidCase, ret_end);
  
    objlist = (OM_p_OBJECT_LINKAGE) alloca (count *
               sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!objlist, *msg, EMS_E_NoStackMemory, ret_end);
  
    stat_OM = om$get_channel_objects (objid = grid->objid, osnum = grid->osnum,
               p_chanselect = &chan_to_defpts, count = &count, size = count,
               list = objlist);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_InvalidCase, ret_end);
    }
  else
    {
    objlist = &objlist_mem;
    objlist->S_objid = grid->objid;
    count = 1;
    }

  if (! *vgpts)
    *vgpts = (GRobjid *) om$malloc (size = count * sizeof (GRobjid));
  EMerr_hndlr (!*vgpts, *msg, EMS_E_NoDynamicMemory, ret_end);

  for (i=0; i<count; i++)
    (*vgpts)[i] = objlist[i].S_objid;
  *num_vgpts = count;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKndsk_vgpts");
  return (stat_OM);
}



/*
 * This function checks to see if a plane (specified by a 4 X 4 transformation
 * matrix) is parallel to the plane of a sketch-mgr and also oriented in the
 * same way, ie, the same x-axis vector. The sketch manager is input as a GRid
 * along with the module-environment.
 */

#argsused
IGRboolean SKisparskpln (msg, opts, md_env, skmgr,
                         pln_orig, pln_zaxis, pln_xaxis,
                         plnmat)
IGRlong *msg;
IGRushort opts;
struct GRmd_env *md_env;
struct GRid *skmgr;
IGRdouble *pln_orig, *pln_zaxis, *pln_xaxis;
IGRdouble *plnmat;
{
  IGRboolean same_plane;
  IGRlong msg_loc, stat_OM;
  IGRdouble dotp, crossp, coltol, dottol, lentol, mdist;
  IGRpoint sk_origpt, loc_pln_origpt;
  IGRvector sk_xaxis, sk_zaxis, loc_pln_xaxis, loc_pln_zaxis, cross_vec;
  struct IGRplane sk_plane;
  IGRboolean aflag;
  IGRlong sts = 1;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  aflag = pwIsActivationOn();

  same_plane = FALSE;

  /*
   * Obtain the xaxis, zaxis and the origin of the manager
   */

  stat_OM = om$send (msg = message SKmgr.SKgetornt (&msg_loc, sk_origpt,
             sk_xaxis, sk_zaxis), targetid = skmgr->objid,
             targetos = skmgr->osnum, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

 if(aflag)
  {
    /*
     * SKgetornt gets the axis vectors in ref-space. consciously transform them
     * to model space.
     */
    sts = RFtransform( md_env->md_env.matrix, md_env->md_env.matrix_type, 
                       FALSE, sk_xaxis, NULL, sk_zaxis, sk_origpt); 
    EMerr_hndlr (!(1&sts), *msg, EMS_E_Fail, ret_end);
  }

  /*
   * Obtain the xaxis, zaxis and the origin of the input plane
   */

  if (pln_xaxis)
    OM_BLOCK_MOVE (pln_xaxis, loc_pln_xaxis, sizeof (IGRvector));
  else
    OM_BLOCK_MOVE (&plnmat[0], loc_pln_xaxis, sizeof (IGRvector));
  BSnorvec (&msg_loc, loc_pln_xaxis);

  if (pln_zaxis)
    OM_BLOCK_MOVE (pln_zaxis, loc_pln_zaxis, sizeof (IGRvector));
  else
    OM_BLOCK_MOVE (&plnmat[8], loc_pln_zaxis, sizeof (IGRvector));
  BSnorvec (&msg_loc, loc_pln_zaxis);

  if (pln_orig)
    OM_BLOCK_MOVE (pln_orig, loc_pln_origpt, sizeof (IGRpoint));
  else
  {
    loc_pln_origpt[X] = plnmat[XORIG_PLANEMAT_INX];
    loc_pln_origpt[Y] = plnmat[YORIG_PLANEMAT_INX];
    loc_pln_origpt[Z] = plnmat[ZORIG_PLANEMAT_INX];
  }

  /*
   * Determine the cross-product between the sketch's z-axis and the
   * input plane's z-axis. If the cross-product is greater than cross-tol,
   * the two planes are not parallel. Return.
   */

  BScrossp (&msg_loc, sk_zaxis, loc_pln_zaxis, cross_vec);
  crossp = BSlenvec (&msg_loc, cross_vec);
  BSEXTRACTPAR (&msg_loc, BSTOLCOLLINVEC, coltol);
  if (crossp > coltol)
  {
    goto ret_end;
  }

  /*
   * Determine the dot-product between the sketch's x-axis and the
   * input plane's x-axis. If the dot-product is not within tolerance of
   * unity, the two planes do not have the same x-orientation. Return.
   */

  dotp = BSdotp (&msg_loc, sk_xaxis, loc_pln_xaxis);
  dottol = coltol;
  if (fabs (1.0 - dotp) > dottol)
  {
    goto ret_end;
  }

  /*
   * The two planes are the same in parallelness and orientation.
   * They may not be the same in depth. Unless inhibited, check this. Only
   * if same depth, these two planes are regarded as same.
   */

  if (!(opts & SK_PROCSKGR_NOPLNORIG))
  {
    sk_plane.point = sk_origpt;
    sk_plane.normal = sk_zaxis;
    MAptpldis (&msg_loc, loc_pln_origpt, &sk_plane, &mdist);
    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
    if (mdist <= lentol)
      same_plane = TRUE;
  }
  else
    same_plane = TRUE;

ret_end:
  if (EMSerror (stat_OM))
    *msg = EMS_E_Fail;
  return (same_plane);
}



/*
 * This function creates SKasptgrnd constraints for the points indicated
 * by a DMsrc object. The max size needed to return the vgpt-ids is
 * currently, 2.
 */
#argsused
IGRlong SKdimsk_assocgrnds (msg, opts, md_env, dim_src, parent_inx, mgrid,
                            num_vgpts, vgpts)
IGRlong *msg;
IGRushort opts;
struct GRmd_env *md_env;
struct GRid *dim_src;
IGRint parent_inx;
struct GRid *mgrid;
IGRint *num_vgpts;
GRobjid *vgpts;
{
  IGRboolean negdir;
  IGRint i, ni, j, inx, startinx, inxlim;
  OMuint count;
  IGRlong msg_loc, stat_OM;
  GRobjid dumobj;
  struct GRid parent, context, loc_dim_src;
  struct dim_src_info dim_src_info;
  struct GRas assoc_info;
  struct src_attr src_attr;
  OM_S_CHANSELECT chan_to_parents;
  OM_S_OBJECT_LINKAGE dim_parents[2];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
 
  *num_vgpts = 0;

  stat_OM = om$send (msg = message DMsrc.DMgive_src_info (
                           (int *) &msg_loc, md_env, &dim_src_info), 
                     targetid = dim_src->objid,
                     targetos = dim_src->osnum, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
           
  negdir = FALSE;
  switch (dim_src_info.type)
  {
    case DMkeypt:
    case DMaxis:
    case DMintpt:
    case DMmidpt:
    case DMcenpt:
      startinx = 0;
      inxlim = 0;
      loc_dim_src = *dim_src;
      break;

    case DMkeyseg:
      startinx = 0;
      inxlim = 1;
      loc_dim_src = *dim_src;
      negdir = dim_src_info.var.dm_keyseg.u_par < 0.5 ? FALSE : TRUE;
      break;

    case DM2ptseg:
      EMmake_chanselect (NDfather_father, &chan_to_parents);
      count = 0;
      om$get_channel_objects (objid = dim_src->objid, osnum = dim_src->osnum,
       p_chanselect = &chan_to_parents, count = &count, size = 2,
       list = dim_parents);
      if (count == 2)
        {
        parent.objid = dim_parents[parent_inx].S_objid;
        parent.osnum = dim_src->osnum;
        context.objid = NULL_OBJID;

        assoc_info.num_parents = 1;
        assoc_info.parents = &parent;
        assoc_info.context = &context;
        src_attr.type = DMkeypt;
        inx = parent_inx == FIRST ? 0 : 3;
        src_attr.attr = (IGRdouble *) &dim_src_info.var.dm_2ptseg.line[inx];
        assoc_info.as_attr = (IGRchar *) &src_attr;
  
        stat_OM = om$construct (classid = OPP_DMsrc_class_id,
                   osnum = dim_src->osnum,
                   msg = message NDnode.NDplace (&assoc_info, md_env, NULL),
                   p_objid =  &loc_dim_src.objid); 
        EMomerr_exit (stat_OM, ret_end);
        loc_dim_src.osnum = dim_src->osnum;

        stat_OM = om$send (msg = message NDnode.NDs_compute_node (&msg_loc,
                   NULL, md_env), targetid = loc_dim_src.objid,
                   targetos = loc_dim_src.osnum, senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);

        stat_OM = om$send (msg = message NDnode.NDchg_state (ND_DEL_NO_CH,
                   ND_DEL_NO_CH), targetid = loc_dim_src.objid,
                   targetos = loc_dim_src.osnum, senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);

        startinx = 0;
        inxlim = 0;
        }
      else
        {
        startinx = parent_inx;
        inxlim = startinx;
        loc_dim_src = *dim_src;
        }
      break;

    default:
      *msg = EMS_E_NotSupported;
      goto ret_end;
  }

  for (i=startinx, ni=inxlim, j=0; i<=inxlim; i++, ni--, j++)
  {
    vgpts[j] = NULL_OBJID;
    stat_OM = om$construct (classid = OPP_SKasptgrnd_class_id,
               osnum = mgrid->osnum,
               msg = message SKasptgrnd.SKinit_assocpt_ground
               (&msg_loc, SK_OPT_MARK_AS_NEWADD | SK_OPT_MARK_AS_USERADD,
               md_env,
               &loc_dim_src, negdir ? ni : i,
               mgrid->objid, NULL, &vgpts[j]),
               p_objid = &dumobj);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    (*num_vgpts)++;
  }

ret_end:
  return (stat_OM);
}


/*

Name
  SKdimsk_vgpts

Abstract

Synopsis

Description
 This function return SKptvars corresponding to the points indicated
 by a DMsrc object.

Return Value

Notes
 The max size needed to return the vgpt-ids is currently, 4.

Index

Keywords

History
  09/28/93 : Rajiv Agrawal : converted to std header and incorporated change 
             suggested by Satya so that we are always in sync with the dimension
             handle.  Now we find the closest SKptvar to the DMkeypt.  (TR#11924807)

 */
#argsused
IGRlong SKdimsk_vgpts ( IGRlong *msg, 
                        IGRushort opts, 
                        struct GRmd_env *md_env, 
                        struct GRid *dim_src,
                        IGRint parent_inx,
                        IGRint *num_vgpts,
                        GRobjid *vgpts )
{
  OMuint 		num_pts;
  int 			i, j, inx, start_parent_inx, parent_inx_lim, type;
  int 			start_pt_inx, pt_inx_lim;
  long 			msg_loc, stat_OM;
  double 		u, dist, min_dist;
  struct GRid 		parentid;
  struct dim_src_info 	dim_src_info;
  OM_S_OBJECT_LINKAGE 	vgpts_list[4];
  OM_S_CHANSELECT 	chan_to_defpts;
  IGRpoint      	point,dim_point;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
 
  *num_vgpts = 0;

  stat_OM = om$send (msg = message DMsrc.DMgive_src_info (
                           (int *) &msg_loc, md_env, &dim_src_info), 
                     targetid = dim_src->objid,
                     targetos = dim_src->osnum, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
           
  type = dim_src_info.type;
  switch (type)
  {
    case DMkeypt:
    case DMaxis:
    case DMkeyseg:
    case DMarc:
    case DMradcen:
    case DMcenpt:         /** addition for centpoint **/
      start_parent_inx = 0;
      parent_inx_lim = 0;
      break;

    case DM2ptseg:
      start_parent_inx = parent_inx;
      parent_inx_lim = start_parent_inx;
      break;

    default:
      *msg = EMS_E_NotSupported;
      goto ret_end;
  }

  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  inx = 0;
  for (i=start_parent_inx; i<=parent_inx_lim; i++)
  {
    parentid = dim_src_info.parents[i];

    num_pts = 0;
    om$get_channel_objects (objid = parentid.objid, osnum = parentid.osnum,
                            p_chanselect = &chan_to_defpts, count = &num_pts, 
                            size = 4,
                            list = vgpts_list);
    EMerr_hndlr (!num_pts, *msg, EMS_E_InvalidCase, ret_end);

    switch (type)
    {
      case DMaxis:
        start_pt_inx = dim_src_info.var.dm_axis.u_par < 0.5 ? 0 : num_pts-1;
        pt_inx_lim = start_pt_inx;
        break;
          
      case DMkeyseg:
        start_pt_inx = 0;
        pt_inx_lim = 1;
        break;

      case DMarc:
      case DMradcen:
        start_pt_inx = 0;
        pt_inx_lim = num_pts-1;
        break;

      default:
        /*
         * Find the SKptvar closest to the dimensioning keypt.
         */
        if (type == DMkeypt) 
        {
          u = dim_src_info.var.dm_keypt.u_par;
          OM_BLOCK_MOVE (dim_src_info.var.dm_keypt.point, dim_point, sizeof(IGRpoint));
        }
        else
        {
	  if (i == FIRST) 
	  {
	    OM_BLOCK_MOVE (dim_src_info.var.dm_2ptseg.line, dim_point, sizeof(IGRpoint));
            u = dim_src_info.var.dm_2ptseg.u_par1;
	  }
	  else 
	  {
	    OM_BLOCK_MOVE (&dim_src_info.var.dm_2ptseg.line[3], dim_point, sizeof(IGRpoint));
            u = dim_src_info.var.dm_2ptseg.u_par2;
	  }
        }

        start_pt_inx = u < 0.5 ? 0 : num_pts-1;
        min_dist = MAXFLOAT;
        for ( j = 0; j < num_pts; j++)
        {
          stat_OM = om$send (msg = message SKvariable.SKgetvar 
                                   (&msg_loc, NULL, &md_env->md_env.matrix_type, 
                                    md_env->md_env.matrix, point),
                             targetid = vgpts_list[j].S_objid,
                             targetos = vgpts_list[j].osnum,
                             senderid = NULL_OBJID);
          EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
          
          dist = BSdistptpt (&msg_loc, dim_point, point); 
          if(min_dist > dist)
          {
            min_dist = dist;
            start_pt_inx = j;
          }
        }
        
        pt_inx_lim = start_pt_inx;
        break;
    }

    for (j=start_pt_inx; j<=pt_inx_lim; j++)
    {
      vgpts[inx++] = vgpts_list[j].S_objid;
      (*num_vgpts)++;
    }
  }

ret_end:
  return (stat_OM);
}

end implementation SKmgr;

