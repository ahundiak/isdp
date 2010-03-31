class implementation ECdraw;

#include <alloca.h>
#include "OMprimitives.h"
#include "exmacros.h"
#include "exdef.h"
#include "grmacros.h"
#include "lcmacros.h"
#include "OMmacros.h"
#include "msdef.h"
#include "ECmsg.h"
#include "emsdef.h"
#include "nddef.h"

#define FIRST  0
#define LAST   1

#define MODIFY_SEGMENT 1
#define MODIFY_VERTEX  2

#define NUM_STATIC 5

extern GRclassid OPP_SKline_class_id, OPP_SKarc_class_id, OPP_SKpoint_class_id, 
                 OPP_SKptvar_class_id, OPP_GRbspline_class_id;
                 

from GRcurve    import GRendpts;
from GRgraphics import GRdisplay, GRdelete, GRchgprops;
from SKgeometry import SKgetmgr;
from NDnode     import NDget_objects, NDchange_connect;
from SKconstraint import SKgetmajconstrs;
from SKmgr	import GRremove_components;
from SKvariable import SKgetvar, SKputvar;
from GRvg       import GRgetsymb, GRputsymb;
/*

Name
  ECdraw.modify_profile

Abstract
  Command object to modify profile segment or a vertex.
  
Synopsis

Description
  This command allows the user to pick a profile segment or a vertex and
  replace it with another profile.  We support only vertices that occur
  at a line-line junction due to rubber-banding limitations.
  
Return Value
  EMS_I_NoLocation - If no object was located.
  
Notes

Index

Keywords
  profile

History
  05/31/93 : Rajiv Agrawal : created
  12/23/93 : Rajiv Agrawal : Disallow modify segment mode selected thru vertex for cases
                             other than lines and arcs.
  02/03/94 : G M K 	   : TR#119416588 : commented the GRendpts calls, these will give wrong
  			     points when the adjacent line segments are connected reversly.
  			     The SKgetvars calls are used to get the correct end points.
 */

method modify_profile(long *msg; int *response; char *response_data)
{
  IGRshort 		action, props;
  OMuint		count; 
  int			i, inx;
  long          	msg_loc, stat_OM;
  long			eventsize;
  long                  display_flag, locate_mask, accept_mask;
  long                  object_was_located;
  struct GRid 		eleid;
  GRclassid             rclass[1], eliclass[3], objclass;  
  IGRpoint		endpts[2];  
  enum GRdpmode		dpmode;
  struct GRmd_env       *md_env;
  struct GRlc_locate    attributes;
  struct GRevent        *accept_event, *locate_event;
  OM_S_CLASSLIST        rtree_classes, elig_classes;
  OM_S_CHANSELECT 	chan_to_defpts;
  OM_S_OBJECT_LINKAGE 	ptlist[4]; 
  OM_S_CHANSELECT  	chan_to_geom;
  extern IGRdouble 	BSdistptpt();
 
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  /*
   * Locate line/arc segment or a profile vertex.
   */
  locate_event = &ME.ECelements->locev;
  accept_event = &ME.ECelements->accev; 
  elig_classes.w_count = 3;
  eliclass[0] = OPP_SKline_class_id;
  eliclass[1] = OPP_SKarc_class_id;
  eliclass[2] = OPP_SKptvar_class_id;
  elig_classes.p_classes = eliclass;
  elig_classes.w_flags = OM_CLST_subclass;

  eventsize = sizeof (struct GRevent);
  display_flag = ALL_WINDOWS | ELEM_HILIGHT;
  locate_mask = GRm_DATA | GRm_BACK_UP;
  accept_mask = GRm_DATA;
  attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
  attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                            LC_NO_REF_HEADER | LC_REF_OBJECTS;
  rtree_classes.w_count = 1;
  rclass[0] = OPP_GRbspline_class_id;
  rtree_classes.w_flags = OM_CLST_subclass;
  rtree_classes.p_classes = rclass;

  lc$locate ( rc = &object_was_located,
              event1 = locate_event, 
              event2 = accept_event, 
              mask1 = locate_mask, 
              mask2 = accept_mask,
              eventsize= &eventsize, 
              display_flag = display_flag,
              response = response, 
              response_data = response_data, 
              locate_key = EMS_P_IdentifyProfileSegmentorVertex, 
              acc_key = EMS_P_AcceptReject,
              relocate_key = EMS_P_LinePointNotFound, 
              attributes = &attributes,
              stack = &ME.ECelements->locate_stack, 
              rtree_classes = &rtree_classes, 
              eligible_classes = &elig_classes);

  if (!object_was_located)
  {
    *msg = EMS_I_NoLocation;
    goto ret_end;
  }
  
  md_env = &accept_event->located_object[0].module_info;
  eleid = accept_event->located_object[0].located_obj;
/* printf("element %d located\n", eleid.objid);  */
  om$get_classid (objid = eleid.objid, osnum = eleid.osnum,
                  p_classid = &objclass);

  if (om$is_ancestry_valid (subclassid = objclass,
                            superclassid = OPP_SKgeometry_class_id) == OM_S_SUCCESS)
  {
     ME.ECdraw->modify_state = MODIFY_SEGMENT;
  }
  else if (om$is_ancestry_valid (subclassid = objclass,
                                 superclassid = OPP_SKptvar_class_id) == OM_S_SUCCESS)
  {
    ME.ECdraw->modify_state = MODIFY_VERTEX;
  }
  else
  {
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end); 
  }
   
  /*
   * Set the current reference plane to that of the profile ... TO BE DONE
  struct GRid active_plane, sketch_plane;
  ems$get_active_datum_plane( msg = &msg_loc, datpln = &active_plane);
  sk$get_reference_plane ( msg = &msg_loc, datpln = &sketch_plane);
  
  if (active_plane.objid != sketch_plane.objid)
    ems$set_active_datum_plane (msg = &msg_loc, datpln = &sketch_plane);
   */
    
  
/*printf("going into mode %d\n", ME.ECdraw->modify_state);*/

  ME.ECdraw->modseg[0] = eleid;
  ME.ECdraw->modseg[1].objid = NULL_OBJID;
  ME.ECdraw->modseg_gmtype[1] = NULL;
   
  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geom);
  
  if (ME.ECdraw->modify_state == MODIFY_VERTEX)
  {
    /*
     * If a SKptvar was located, find the first segment connected to it
     */
    stat_OM = om$get_channel_objects (objid = eleid.objid, osnum = eleid.osnum,
                                      p_chanselect = &chan_to_geom, 
                                      count = &count, size = 4,
                                      list = ptlist);
/*printf("vertex connected to %d geom\n", count);*/
    EMerr_hndlr ( !(stat_OM & 1) || (count < 1 || count > 2), stat_OM, OM_E_ABORT, ret_end );

    ME.ECdraw->modseg[0].objid = ptlist[0].S_objid;
    ME.ECdraw->modseg[0].osnum = ptlist[0].osnum;
    SKgetgeomtype (ME.ECdraw->modseg[0].objid, ME.ECdraw->modseg[0].osnum,
                   &ME.ECdraw->modseg_gmtype[0]);
   
    /*
     * store the second segment if it exists.  if not switch to segment mode.
     */
    if (count == 1) 
    {
      if (ME.ECdraw->modseg_gmtype[0] & SK_LINE || ME.ECdraw->modseg_gmtype[0] & SK_ARC)
        ME.ECdraw->modify_state = MODIFY_SEGMENT;
      else
      {
        dp$erase_hilite ( msg = &msg_loc);
        ex$message( msgnumb = EMS_S_NotYetSupported);
        *msg = EMS_I_NoLocation;
        goto ret_end;
      }
    }
    else 
    { 
      ME.ECdraw->modseg[1].objid = ptlist[1].S_objid;
      ME.ECdraw->modseg[1].osnum = ptlist[1].osnum;
      SKgetgeomtype (ME.ECdraw->modseg[1].objid, ME.ECdraw->modseg[1].osnum,
                     &ME.ECdraw->modseg_gmtype[1]);
      /*
       * Currently we support only line-line junctions for the vertex mode.
       * Somehow we should disallow the locate of other junctions ... but till
       * then we send out an error message.
       */
      if (ME.ECdraw->modseg_gmtype[0] != SK_LINE || 
          ME.ECdraw->modseg_gmtype[1] != SK_LINE)
      {
        dp$erase_hilite ( msg = &msg_loc);
        ex$message( msgnumb = EMS_S_NotYetSupported);
        *msg = EMS_I_NoLocation;
        goto ret_end;
      }
      /*
       * In this case, we need to store the endpt of the adjacent segment
       * that will be displayed in dynamics.
       *
       *==GRendpts will be wrong when the adjacent line segments are in opposite directions.==
       *  commented by -- GMK 02/03/94
      stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc, &md_env->md_env.matrix_type,
                           md_env->md_env.matrix, endpts[FIRST], endpts[LAST]),
                         targetid = ME.ECdraw->modseg[1].objid, 
                         targetos = ME.ECdraw->modseg[1].osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
       *
       */
  
      /*
       * get the endpoint of second segment -- GMK 02/03/94
       */
      EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
      count = 0;
      stat_OM = om$get_channel_objects (objid = ME.ECdraw->modseg[1].objid, 
                                    osnum = ME.ECdraw->modseg[1].osnum,
                                    p_chanselect = &chan_to_defpts, 
                                    count = &count, size = 4,
                                    list = ptlist);
      EMerr_hndlr ( EMSerror ( stat_OM), stat_OM, OM_E_ABORT, ret_end );
      
      if ( eleid.objid == ptlist[0].S_objid )
      {
        inx = 1;
      }
      else
      {
        inx = 0; 
      }

      stat_OM = om$send ( msg = message SKvariable.SKgetvar
                                (&msg_loc, NULL, &md_env->md_env.matrix_type,
                                 md_env->md_env.matrix, endpts[LAST]),
                          targetid = ptlist[inx].S_objid, targetos = ptlist[inx].osnum );
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
      
      OM_BLOCK_MOVE (endpts[LAST], ME.ECdraw->dyn_point, sizeof (IGRpoint));
    }
  }

  /*
   * store the object ids of the first and last SKptvar of the segment being
   * replaced in case the user snaps to the end to end modification.
   */
  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  count = 0;
  stat_OM = om$get_channel_objects (objid = ME.ECdraw->modseg[0].objid, 
                                    osnum = ME.ECdraw->modseg[0].osnum,
                                    p_chanselect = &chan_to_defpts, 
                                    count = &count, size = 4,
                                    list = ptlist);
  EMerr_hndlr ( EMSerror ( stat_OM), stat_OM, OM_E_ABORT, ret_end );

  if (count)
  {
    if ( ME.ECdraw->modify_state == MODIFY_SEGMENT )
    {
      ME.ECdraw->vertex[0] = ptlist[0].S_objid;
      ME.ECdraw->vertex[1] = ptlist[count-1].S_objid;
    }
    else
    {    
      if ( eleid.objid == ptlist[0].S_objid )
      {
        ME.ECdraw->vertex[1] = ptlist[0].S_objid;
        ME.ECdraw->vertex[0] = ptlist[count-1].S_objid;
      }
      else
      {
        ME.ECdraw->vertex[0] = ptlist[0].S_objid;
        ME.ECdraw->vertex[1] = ptlist[count-1].S_objid;
      }
    }
/*printf("segment is connected to %d and %d vertices\n", ME.ECdraw->vertex[0], ME.ECdraw->vertex[1]);*/
  }

  /*
   * Find the endpoints of the located segment.
   * 
   *==GRendpts will be wrong when the adjacent line segments are in opposite directions.==
   *  commented by -- GMK 02/03/94
  stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc, &md_env->md_env.matrix_type,
                           md_env->md_env.matrix, endpts[FIRST], endpts[LAST]),
                     targetid = ME.ECdraw->modseg[0].objid, 
                     targetos = ME.ECdraw->modseg[0].osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
   *
   * 
   */
  
  for ( inx=FIRST; inx<=LAST; inx++)
  {
    stat_OM = om$send ( msg = message SKvariable.SKgetvar
                                (&msg_loc, NULL, &md_env->md_env.matrix_type,
                                 md_env->md_env.matrix, endpts[inx]),
                          targetid = ME.ECdraw->vertex[inx], targetos = ME.ECdraw->modseg[0].osnum  );
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
  }
  
  inx = FIRST;
  if (ME.ECdraw->modify_state == MODIFY_SEGMENT) 
  {
    /*
     * if we are in modify segment mode, figure out which endpoint to start
     * rubber-banding from.  swap depending on the locate pt.  Always vertex[0]
     * is where the modification begins.  
     */
    if (BSdistptpt (&msg_loc, endpts[FIRST], &locate_event->event.button.x) <
        BSdistptpt (&msg_loc, endpts[LAST], &locate_event->event.button.x))
    {
      GRobjid tempid;
/*printf("swapping being done\n");*/
      inx = LAST;
      tempid = ME.ECdraw->vertex[0];
      ME.ECdraw->vertex[0] = ME.ECdraw->vertex[1];
      ME.ECdraw->vertex[1] = tempid;
    }
    /*
     * Find the id of the next segment connected to vertex[1].  This will be
     * required to end the profile modification.
     */
    stat_OM = om$get_channel_count ( objid = ME.ECdraw->vertex[1], 
                                     osnum = eleid.osnum,
                                     p_chanselect = &chan_to_geom,
                                     count = &count );
    EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
    if (count > 1)
    {
      stat_OM = om$get_channel_objects ( objid = ME.ECdraw->vertex[1], osnum = 
                                         eleid.osnum,
                                         p_chanselect = &chan_to_geom, 
                                         list = ptlist, size = 4, count = &count);
      EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
      for (i=0; i<count; i++)
      {
        if (ptlist[i].S_objid != ME.ECdraw->modseg[0].objid)
        {
          ME.ECdraw->modseg[1].objid = ptlist[i].S_objid;
          ME.ECdraw->modseg[1].osnum = ptlist[i].osnum;
          break;
        }
      }
    }
  }

  /*
   * Simulate an event as if the first point was selected by the user.
   */
  accept_event->response = EX_DATA;
  OM_BLOCK_MOVE (endpts[inx], &accept_event->event.button.x, sizeof(IGRpoint));
  stat_OM = ex$putque (msg = &msg_loc, response = &accept_event->response,
                       byte = &eventsize, buffer = (char *)&accept_event->event);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

  /*
   * Hide the segment that is being modified.  Make it non-locatable also.
   */
  dpmode = GRbe;
  stat_OM = om$send (msg = message GRgraphics.GRdisplay 
                           (&msg_loc, &md_env->md_env.matrix_type,
                            md_env->md_env.matrix, &dpmode, &md_env->md_id),
                     targetid = ME.ECdraw->modseg[0].objid, 
                     targetos = ME.ECdraw->modseg[0].osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
  
  action = 0;
  props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  stat_OM = om$send  ( msg = message GRgraphics.GRchgprops 
                             (&msg_loc, &action, &props), 
                       targetid = ME.ECdraw->modseg[0].objid, 
                       targetos = ME.ECdraw->modseg[0].osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
  
  if (ME.ECdraw->modify_state == MODIFY_VERTEX)
  {
    /*
     * In case of vertex modification, hide and make the second segment non-locatable
     * also.
     */
    stat_OM = om$send (msg = message GRgraphics.GRdisplay 
                             (&msg_loc, &md_env->md_env.matrix_type,
                              md_env->md_env.matrix, &dpmode, &md_env->md_id),
                       targetid = ME.ECdraw->modseg[1].objid, 
                       targetos = ME.ECdraw->modseg[1].osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
    stat_OM = om$send  (msg = message GRgraphics.GRchgprops 
                              (&msg_loc, &action, &props), 
                        targetid = ME.ECdraw->modseg[1].objid, 
                        targetos = ME.ECdraw->modseg[1].osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
  }
    
ret_end:
  EMWRAPUP (*msg, stat_OM, "ECdraw.modify_profile");
  return stat_OM;   
}

/*

Name
  ECdraw.do_modification
Abstract
  Method to merge the new profile in place of the old segment.
  
Synopsis

Description

Return Value

Notes

Index

Keywords
  profile, merge

History
  05/31/93 : Rajiv Agrawal : created

 */

method do_modification (
long 		*msg		/* return code				OUT  	*/;
struct GRid 	new_skmgr	/* the profile id that is being added 	IN	*/; 
IGRboolean	end_merge	/* whether second merge is done		IN	*/)
{
  IGRshort 		action, props;
  OMuint		num_var,comp_count;
  long 			stat_OM, msg_loc;
  int 			i,j,num_children = 0, obj_count;
  int 			num_major_constrs;
  struct GRid     	old_skmgr, firstpt, mergept, lastpt, first_seg, *children;
  struct GRid 		modseg,obj_id /* segment being replaced by new_skmgr */;
  struct GRmd_env	*env;
  GRspacenum 		fileos;
  GRobjid		*vertex		/* defining SKptvar objids of modseg */;
  OM_S_CHANSELECT 	chan_to_vars, chan_to_geom, chan_to_constr;
  OM_S_CHANSELECT 	chan_to_comps;
  GRobjid 		*major_constrs, major_constrs_mem[NUM_STATIC];
  enum GRdpmode		dpmode;
  struct GRobj_env 	objects[1];
  struct GRsymbology    symb,symb_pt;
  OM_S_OBJECT_LINKAGE 	comp_ptlist[10];
  GRclassid             objclass;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  env = &ME.ECelements->active_md_env;
  modseg = ME.ECdraw->modseg[0];
  vertex = ME.ECdraw->vertex;
  fileos = modseg.osnum;
  
  /*
   * in case of vertex modification, always merge at the end.  Turn locatability
   * back on for the second segment.
   */
  if (ME.ECdraw->modify_state == MODIFY_VERTEX) 
  {
    end_merge = TRUE;
    action = 1;
    props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    stat_OM = om$send  ( msg = message GRgraphics.GRchgprops 
                               (&msg_loc, &action, &props), 
                         targetid = ME.ECdraw->modseg[1].objid, 
                         targetos = ME.ECdraw->modseg[1].osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
  }
  
  /*
   * find the first point of the new skmgr that is being added.
   */
  EMmake_chanselect (SKmgr_to_vars, &chan_to_vars);
  stat_OM = om$get_objid_at_index ( objid = new_skmgr.objid, osnum = new_skmgr.osnum, 
                                    p_chanselect = &chan_to_vars,
                                    index = FIRST,
                                    objidaddr = &firstpt.objid, 
                                    osnumaddr = &firstpt.osnum );
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
/*printf("first point of the new skmgr = %d\n", firstpt.objid);*/
  if (end_merge)
  {
    /*
     * find the end of the new skmgr.
     */
    stat_OM = om$get_channel_count ( objid = new_skmgr.objid, osnum = new_skmgr.osnum, 
                                     p_chanselect = &chan_to_vars,
        			     count = &num_var );
    EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
    
    stat_OM = om$get_objid_at_index ( objid = new_skmgr.objid, osnum = new_skmgr.osnum, 
                                      p_chanselect = &chan_to_vars,
                                      index = num_var-1,
                                      objidaddr = &lastpt.objid, 
                                      osnumaddr = &lastpt.osnum );
    EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
/*printf("last point of the new skmgr = %d\n", lastpt.objid);*/
  }
  
  /*
   * find the first seg of the new profile.
   */
  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geom);
  stat_OM = om$get_objid_at_index ( objid = firstpt.objid, osnum = firstpt.osnum,
                                    p_chanselect = &chan_to_geom,
                                    index = FIRST, 
                                    objidaddr = &first_seg.objid, 
                                    osnumaddr = &first_seg.osnum );
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
  
  /*
   * move the old tag of modseg to the first segment of the new skmgr.
   */
  stat_OM = om$remove_tag (objid = first_seg.objid, osnum = first_seg.osnum);
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
  stat_OM = om$move_tag (osnum = modseg.osnum,
                         old_objid = modseg.objid, 
                         new_objid = first_seg.objid);
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
  
  /*
   * Delete any dimensions attached to the modified segment.  These are connected
   * thru DMsrc children.  We don't want these to get moved to the new segment.
   */
  stat_OM = SKdelete_dimensions(&msg_loc, env, modseg);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
  
  /*
   * transfer the children of modseg to the first segment of the new skmgr.
   */
  stat_OM = om$send (msg = message NDnode.NDget_objects (ND_CHILDREN,
                           NULL, 0, NULL, 0, MAXINT, &num_children), 
                     targetid = modseg.objid, targetos = modseg.osnum,
                     senderid = NULL_OBJID);
  EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
  if (num_children)
  {
         
    children = (struct GRid *) alloca (num_children*sizeof(struct GRid));
    stat_OM = om$send (msg = message NDnode.NDget_objects (ND_CHILDREN,
                             children, num_children, NULL, 0, MAXINT, &num_children), 
                       targetid = modseg.objid, 
                       targetos = modseg.osnum,
                       senderid = NULL_OBJID);
    EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );

    for (i = 0; i < num_children; i++)
    {
      stat_OM = om$send ( msg = message NDnode.NDchange_connect ( 1, &modseg, &first_seg ),
                          targetos = children [i].osnum, 
                          targetid = children [i].objid, 
                          senderid = NULL_OBJID );
      EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
    }
  }

  /*
   * Delete all the constraints acting on the modified vertex.
   */
  
  if (ME.ECdraw->modify_state == MODIFY_VERTEX)
  {
    EMmake_chanselect (SKvariable_to_constraints, &chan_to_constr);
    num_major_constrs = 0;
    major_constrs = major_constrs_mem;
    stat_OM = om$send (msg = message SKconstraint.SKgetmajconstrs (&msg_loc,
                             NULL, NUM_STATIC, &num_major_constrs, &major_constrs),
                       p_chanselect = &chan_to_constr,
                       targetos = fileos,
                       senderid = ME.ECdraw->vertex[1]);
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  
    dpmode = GRbehe;
    for (i=0; i<num_major_constrs; i++)
    {
      stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                               &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                               &env->md_id), 
                         targetid = major_constrs[i], targetos = fileos);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  
      stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc, env), 
                         targetid = major_constrs[i], targetos = fileos);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
    }
  
    if (major_constrs && major_constrs != major_constrs_mem)
      om$dealloc (ptr = major_constrs);
  }

  stat_OM = om$send (msg = message GRvg.GRgetsymb (&msg_loc, &symb), 
                     targetid = modseg.objid, 
                     targetos = modseg.osnum);

  /*
   * delete the modified segment.
   */ 
  stat_OM = om$send ( msg = message SKgeometry.SKgetmgr (&msg_loc, &old_skmgr.objid),
                      targetid = modseg.objid, 
                      targetos = modseg.osnum);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  old_skmgr.osnum = fileos;
  obj_count = 1;
  objects[0].obj_id = modseg;
  objects[0].mod_env = *env;
  stat_OM = om$send (msg = message SKmgr.GRremove_components 
                           ( &msg_loc, env, &obj_count, objects ),
                     targetid = old_skmgr.objid, 
                     targetos = old_skmgr.osnum);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

  /*
   * Inherit symbology of the old profile.
   */
  stat_OM = om$send (msg = message GRvg.GRputsymb (&msg_loc, &symb),
                     targetid = new_skmgr.objid, 
                     targetos = new_skmgr.osnum);

   /*
      For a "point" the minimum weight should be 3
      Fix for TR# 119526452
   */
                     
        EMmake_chanselect(GRcmpowner_to_components,&chan_to_comps); 
  
        stat_OM = om$get_channel_objects (objid = new_skmgr.objid, 
                                    osnum = new_skmgr.osnum,
                                    p_chanselect = &chan_to_comps, 
                                    count = &comp_count, size = 10,
                                    list = comp_ptlist);                   
                                    
          for(j=0;j<comp_count;j++)
          {
           if(om$get_classid (objid = comp_ptlist[j].S_objid, osnum = new_skmgr.osnum,
                  p_classid = &objclass) & 1)
           {
             if(objclass== OPP_SKpoint_class_id) 
             {
               obj_id.objid= comp_ptlist[j].S_objid;
               obj_id.osnum= new_skmgr.osnum;
               memcpy(&symb_pt,&symb,sizeof(struct GRsymbology));

               if(symb.display_attr.weight<3)
                  symb_pt.display_attr.weight=3;

               gr$put_symbology(object_id=&obj_id , symb=&symb_pt);
             }
           }        
          }                                    
  
     
  
  dpmode = GRbd;
  stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                           &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                           &env->md_id), 
                     targetid = new_skmgr.objid, targetos = new_skmgr.osnum);

  /*
   * stitch the profiles.  Take care of the fact that the first point of
   * the modified profile will get deleted if vertex[0] was the first or the last
   * point.
   */
  mergept.objid = vertex[0];  
  mergept.osnum = firstpt.osnum;
  if (om$is_objid_valid( osnum = mergept.osnum, objid = mergept.objid) == OM_S_SUCCESS) 
  {
    stat_OM = SKmerge_curves (&msg_loc, &mergept, &firstpt);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
/*printf("first merge successful\n");*/
  }
  if (end_merge)
  {
    mergept.objid = vertex[1];  
    mergept.osnum = lastpt.osnum;
    if (ME.ECdraw->modify_state == MODIFY_VERTEX)
    {
      double var[3];
      /*
       * make the values of the lastpt and mergept same.
       */
      stat_OM = om$send ( msg = message SKvariable.SKgetvar
                                (&msg_loc, NULL, NULL, NULL, var),
                          targetid = lastpt.objid, targetos = lastpt.osnum );
      stat_OM = om$send ( msg = message SKvariable.SKputvar
                                (&msg_loc, NULL, NULL, NULL, var),
                          targetid = mergept.objid, targetos = mergept.osnum );
          
    }
    if (om$is_objid_valid( osnum = mergept.osnum, objid = mergept.objid) == OM_S_SUCCESS) 
    {
      stat_OM = SKmerge_curves (&msg_loc, &mergept, &lastpt);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                            &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                            &env->md_id), 
                       targetid = old_skmgr.objid, targetos = old_skmgr.osnum);
    
/*printf("last merge successful\n");*/
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "ECdraw.do_modification");
  return stat_OM;   
}

end implementation ECdraw;
