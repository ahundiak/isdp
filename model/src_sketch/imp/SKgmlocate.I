/*

Name
  GRlocate

Abstract
  Locate processing for a profile element.
  
Synopsis

Description

Return Value

Notes

Index

Keywords

History
  07/02/93 : Sudha  :   Modified for BSprototypes ansification
  08/17/93 : GMK    :    storing the originated object id in SKdumpt object
  08/26/93 : Rajiv Agrawal : Added move functionality using LC_MOVE_CMD flag.
  09/21/93 : Rajiv Agrawal : Decreased the TOL_ENLARGE_FACTOR from 5 to 2 as per
                             Mallik's investigation.  (TR#119222259)
  10/25/93 : GMK    : prevents to identify the SKcircle oncurve SKptvar (TR#11926152)
  12/23/93 : mrm    :   Clear the LC_EXTERN_CONSTRAINED bit in the owner_action
                        flag used for the Move command before exiting the
                        method (before resuming the rtree pass to locate other
                        objects) (TR119314512)

 */
class implementation SKgeometry;

#include "OMmacros.h"
#include "EMSlcdef.h"
#include "EMSlc.h"
#include "emsedgedef.h"
#include "bsptcvgen.h"
#include "grmacros.h"
#include "grwireframe.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#define FIRST  0
#define SECOND 1
#define LAST   MAXINT

#define START  0
#define STOP   1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_SKptvar_class_id, OPP_SKpoint_class_id;
extern GRclassid OPP_SKcircle_class_id;

from SKdumpt import SKput_origin_id;
from SKvariable import SKgetvar;

#define TOL_ENLARGE_FACTOR 1

method GRlocate (struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)
{
  IGRuchar 		cvtype;
  IGRboolean 		hit, stopproc;
  IGRint 		inx, j, stat_OM;
  OMuint 		num_geoms, num_pts;
  IGRlong 		*cvlmsg, msg_loc, tmp_msg_loc;
  IGRpoint 		endpts[2], poles_store[2];
  IGRdouble 		intol, knots_store[4];
  GRobjid 		ptobj, geomobj;
  GRspacenum 		dumos;
  GRclassid 		myclass;
  struct EMSlcinput 	lcin;
  struct EMSlcoutput 	lcout;
  struct GRmdenv_info 	*mdenv_info;
  struct IGRbsp_curve 	ptcv,*circle_geom = NULL;
  struct IGResbc 	esbc;
  struct GRsymbology 	symb;
  struct GRid 		tmp_grid, pt_grid, origin_id,my_grid;
  enum GRdpmode 	dpmode;
  OM_S_CHANSELECT 	chan_to_geoms, chan_to_pts;
  IGRboolean 		next_process = FALSE, geomobj_matched = FALSE;
  IGRboolean            aflag = 0;
  struct GRmd_env       display_env;

  void 			SKclearcvlstack();
  extern void 		EMchglocobj() ;
  extern IGRboolean 	SKptvar_eligible(), EMlocatecvbuffs(), EMhitcvbuff();
  

  cvlmsg = &cvl->msg;
  *cvlmsg = MSSUCC;
  stat_OM = OM_S_SUCCESS;

  if (cvl->attributes.obj_attr.owner_action & LC_MOVE_CMD)
    cvl->attributes.obj_attr.owner_action |= LC_EXTERN_CONSTRAINED;
    
  stat_OM = om$send (mode = OM_e_wrt_parent, 
                     msg = message SKgeometry.GRlocate (cvl, range_key), 
                     targetid = my_id);
  if (stat_OM == OM_I_STOP_SENDING)
    goto ret_end;
  
  if (SKptvar_eligible (cvl, ME.GRgraphics->properties, me->level, my_id))
  {
    symb.display_attr = ME.GRvg->display_attr;
    symb.level = me->level;
    esbc.is_polydis = FALSE;
    esbc.is_curvedis = TRUE;
    lcin.options = EMSlcopt_rangechk | EMSlcopt_skipgeomchk;
    lcin.eligfunc = NULL;
    lcin.eligfunc_args = NULL;
    lcin.more_info = NULL;
    ptcv.poles = (IGRdouble *) poles_store;
    ptcv.knots = knots_store;
    ptcv.weights = NULL;
    cvtype = SKprofile_vertex;
    mdenv_info = &cvl->module.md_env;
    EMmake_chanselect (SKgeometry_to_defpts, &chan_to_pts);
    EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);

    om$get_classid (object = me, p_classid = &myclass);
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    
    /*
     * if the class is SKcircle, select only the centre point
     */
    if ( myclass == OPP_SKcircle_class_id )
    {
      /*
       * get the centre point's SKptvar. For centre SKptvar index is always one
       */
      stat_OM = om$get_objid_at_index (object = me,
                 p_chanselect = &chan_to_pts,
                 index = 1,
                 objidaddr = &ptobj,
                 osnumaddr = &dumos);
      EMomerr_exit (stat_OM, ret_end);
      
      /*
       * get the circle geometry
       */
      gr$get_curve_geometry( msg	= &msg_loc, 
      			     object_id  = &my_grid,
   		             curve_struct= &circle_geom );
      EMerr_hndlr (EMSerror (msg_loc), *cvlmsg, EMS_E_Fail, ret_end);

      /*
       * test if hit is on the circle
       */
      intol = cvl->attributes.acc_tolerance;
      cvl->attributes.acc_tolerance *= TOL_ENLARGE_FACTOR;
      hit = EMhitcvbuff (&msg_loc, circle_geom, NULL, cvl, &lcin, &lcout);
      cvl->attributes.acc_tolerance = intol;
      EMerr_hndlr (EMSerror (msg_loc), *cvlmsg, EMS_E_Fail, ret_end);
      if (hit)
      {

        /*
         * get the centre point 
         */
        stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc, NULL,
                &mdenv_info->matrix_type,
                mdenv_info->matrix,
                endpts[START]), 
                targetid = ptobj, 
                targetos = dumos);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *cvlmsg, MSFAIL, ret_end);
      
        /*
         * generate curve geometry of the point
         */
        BSptcvgen (endpts[START], 2, FALSE, &ptcv, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *cvlmsg, MSFAIL, ret_end);
      
        geomobj = my_id;
        next_process = TRUE;
      }
    } 
    else
    {       
      stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc,
                &mdenv_info->matrix_type, mdenv_info->matrix,
                endpts[START], endpts[STOP]), targetid = my_id);


      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *cvlmsg, MSFAIL, ret_end);

      stat_OM = om$get_channel_count (object = me, 
                   p_chanselect = &chan_to_pts,
                   count = &num_pts);
      EMomerr_exit (stat_OM, ret_end);

      for (inx=START; inx<=(num_pts > 1 ? STOP : START); inx++)
      {
        stat_OM = om$get_objid_at_index (object = me,
                 p_chanselect = &chan_to_pts,
                 index = inx == START ? FIRST : (num_pts-1), 
                 objidaddr = &ptobj,
                 osnumaddr = &dumos);
        EMomerr_exit (stat_OM, ret_end);

        /*
         * In merged profiles, the point is not always the first guy on
         * the channel.
         */
        stat_OM = om$get_channel_count ( objid = ptobj, 
           p_chanselect = &chan_to_geoms, count = &num_geoms );


        EMomerr_exit ( stat_OM, ret_end );
      
        for (j = 0; j < num_geoms; j++)
        {
          stat_OM = om$get_objid_at_index ( objid = ptobj, 
              p_chanselect = &chan_to_geoms, index = j, objidaddr = &geomobj, 
              osnumaddr = &dumos );

 
          EMomerr_exit ( stat_OM, ret_end );

          if (IF_EQ_OBJID (geomobj, my_id))
          {
            
            geomobj_matched = TRUE;
            break;
          }
        }
        
        if (geomobj_matched) 
        {
            BSptcvgen (endpts[inx], 2, FALSE, &ptcv, &msg_loc);
            EMerr_hndlr (msg_loc != BSSUCC, *cvlmsg, MSFAIL, ret_end);
  
            intol = cvl->attributes.acc_tolerance;
            cvl->attributes.acc_tolerance *= TOL_ENLARGE_FACTOR;
            hit = EMhitcvbuff (&msg_loc, &ptcv, cvtype, cvl, &lcin, &lcout);
            cvl->attributes.acc_tolerance = intol;
            EMerr_hndlr (EMSerror (msg_loc), *cvlmsg, EMS_E_Fail, ret_end);
            if (!hit)
              continue;
  
            if (om$is_ancestry_valid (subclassid = myclass,
                superclassid = OPP_SKpoint_class_id) == OM_S_SUCCESS)
            {
              OMuint num_geoms;

              om$get_channel_count ( objid = ptobj, p_chanselect = &chan_to_geoms,
                                     count = &num_geoms );
              if (num_geoms > 1)
                om$get_objid_at_index ( objid = ptobj, p_chanselect = &chan_to_geoms, 
                    index = SECOND, objidaddr = &geomobj, osnumaddr = &dumos );
            }

            next_process = TRUE;
            break;
        }  
      }
    }
    
    if ( next_process )
    {    
     dpmode = GRhd;

     gr$get_module_env(buffer = &display_env);
     aflag = pwIsActivationOn();
 
      if(aflag)
      {   

          om$send (msg = message GRgraphics.GRdisplay 
                         (&msg_loc, &display_env.md_env.matrix_type, display_env.md_env.matrix, &dpmode,
                          &display_env.md_id), 
                   targetid = geomobj);
      }
      else
      {

          om$send (msg = message GRgraphics.GRdisplay 
                         (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix, &dpmode,
                          &cvl->module.md_id), 
                   targetid = geomobj);
      } 
          symb.display_attr.weight = 4;
          /*
           * creating shell object of a SKptvar as a point to display
           * The created shell is SKdumpt because of cvtype is SKprofile_vertex.
           */
          stat_OM = EFget_curve_shell_obj(&msg_loc, 1, &ptcv, &cvtype, &symb,
                                          &esbc, &cvl->module.md_env, &tmp_grid,
                                          &pt_grid);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *cvlmsg, MSFAIL, ret_end);
	  /*
	   * store the origin object id in SKdumpt instance
	   */
	  origin_id.objid = ptobj;
	  origin_id.osnum = OM_Gw_current_OS;           
          om$send( msg = message SKdumpt.SKput_origin_id( &msg_loc, &origin_id ),
          	   senderid = NULL_OBJID,
                   targetid = pt_grid.objid,
                   targetos = pt_grid.osnum );

          stopproc = EMlocatecvbuffs (&msg_loc, 1, &ptcv, &pt_grid, &cvtype,
                     &symb, &esbc, cvl, range_key, &lcin, &lcout);
          EMerr_hndlr (EMSerror (msg_loc), *cvlmsg, MSFAIL, ret_end);
  
 	  /*
 	   * to reuse the shell object 
 	   */
          lc$check_id ( rc = &tmp_msg_loc, 
                        objid = pt_grid.objid, 
                        osnum = pt_grid.osnum, 
                        mode = LC_DEL_CHECK);

          if (msg_loc == EMS_I_Found || msg_loc == EMS_I_Interrupt)
          {
            /*
             * The user has either accepted the point or stacked the locate.
             * In the GRlc_info structure, replace the located-object id with
             * the point's and post it into the cvl-structure for return.
             */
  
            lcout.locobj.located_obj.objid = ptobj;
            lcout.locobj.located_obj.osnum = OM_Gw_current_OS;
            EMchglocobj (&msg_loc, cvl, 1, &lcout.locobj);
            EMerr_hndlr (EMSerror (msg_loc), *cvlmsg, MSFAIL, ret_end);
  
            if (msg_loc == EMS_I_Interrupt)
            {
              /*
               * The accept/reject is not yet complete. After this point control
               * does not return here but continues with the GRlocate message
               * being sent to the "ptobj". Ptobj does not support this. So
               * empty stack and have the locate restart.
               */
  
              SKclearcvlstack (&msg_loc, cvl);
              EMerr_hndlr (EMSerror (msg_loc), *cvlmsg, MSFAIL, ret_end);
            }
          }
	  else
	  {
	    /*
	     * locate not found , unhighlight the object
	     */
            dpmode = GRhe;
            om$send (msg = message GRgraphics.GRdisplay (&msg_loc, 
                                         &mdenv_info->matrix_type,
					 mdenv_info->matrix, 
					 &dpmode,
             				 &cvl->module.md_id),
                     targetid = geomobj);
	  }
  
          if (stopproc)
          {
            /*
             * User input or the locate function call has determined that
             * no more processing needs to be done. Control should immediately
             * return to the initiator of this locate.
             */
  
            stat_OM = OM_I_STOP_SENDING;
            goto ret_end;
          }
      }
  }

ret_end:

  // Clear the LC_EXTERN_CONSTRAINED bit; otherwise it would be possible to
  // move associative solids by clicking on the profile, and rejecting it
  // to continue on to the solid.
  if (cvl->attributes.obj_attr.owner_action & LC_MOVE_CMD)
    cvl->attributes.obj_attr.owner_action &= ~LC_EXTERN_CONSTRAINED;

  if ( circle_geom )
  {
    gr$free_curve( curve_struct = circle_geom );
  }
  return (stat_OM);
}

IGRboolean SKptvar_eligible (cvl, grprops, grlevels, grobjid)
struct GRlc_cvl *cvl;
IGRshort grprops;
IGRshort grlevels;
GRobjid grobjid;
{
  IGRboolean eligible;
  IGRchar *eligclass_name;
  IGRshort idmattyp;
  IGRlong msg_loc, stat_OM, requested_props;
  IGRmatrix idmat;
  GRclassid eligclassid, grobjclass;
  OM_S_CLASSLIST eligclasslist;
  extern void EMidmatrix();
  extern IGRboolean EMclass_eligible();
  extern IGRlong GRloccheck();
  IGRboolean aflag = 0;
  

  eligible = cvl->module.md_id.osnum == OM_Gw_current_OS;
  if (!eligible)
    goto ret_end;

  aflag = pwIsActivationOn();
  if(aflag)
  {
   GRspacenum osn;
   osn = pwGetActiveOs();
   if(cvl->module.md_id.osnum != osn)
   {
    eligible = FALSE;
    goto ret_end;
   }
  }

  eligible = cvl->attributes.type == GR_bl_loc || 
              cvl->attributes.type == GR_pt_loc;
  if (!eligible)
    goto ret_end;

  eligible = EMclass_eligible (OPP_SKptvar_class_id, cvl->classes);
  if (!eligible)
    goto ret_end;

  eligclass_name = cvl->attributes.obj_attr.classes;
  if (eligclass_name)
    {
    stat_OM = om$get_classid (classname = eligclass_name,
               p_classid = &eligclassid);
    if (stat_OM == OM_S_SUCCESS)
      {
      eligclasslist.w_count = 1;
      eligclasslist.w_flags = OM_CLST_subclass;
      eligclasslist.p_classes = &eligclassid;
      eligible = EMclass_eligible (OPP_SKptvar_class_id, &eligclasslist);
      if (!eligible)
        goto ret_end;
      }
    }

  EMidmatrix (&msg_loc, &idmattyp, idmat);
  requested_props = cvl->attributes.obj_attr.properties |
                     LC_PLANAR_NON_PLANAR | LC_PHY_OPEN_CLOSED;
  stat_OM = GRloccheck (&msg_loc, &idmattyp, idmat, &grprops,
             &requested_props, &grlevels, cvl->levels, &grobjid);
  if (EMSerror (stat_OM) || msg_loc != MSSUCC)
    {
    eligible = FALSE;
    goto ret_end;
    }
  else
    eligible = TRUE;

  om$get_classid (objid = grobjid, p_classid = &grobjclass);
  if (om$is_ancestry_valid (subclassid = grobjclass,
       superclassid = OPP_SKpoint_class_id) == OM_S_SUCCESS)
    {
    eligible = !EMclass_eligible (OPP_SKpoint_class_id, cvl->classes);
    if (!eligible)
      goto ret_end;
    }

ret_end:
  return (eligible);
}

void SKclearcvlstack (msg, cvl)
IGRlong *msg;
struct GRlc_cvl *cvl;
{
  struct LC_action_args *act;
  struct GRlc_stack *stack;

  *msg = EMS_S_Success;

  act = (struct LC_action_args *) cvl->locate_args;
  stack = act->stack;
  stack->num_entries = 0;
  return;
}

end implementation SKgeometry;

