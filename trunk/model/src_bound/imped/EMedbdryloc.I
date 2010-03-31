/* #################   APOGEE  COMPILED   ######################### */
/*
  DESCRIPTION

    This implementaton can be invoked stand-alone or by the loop of which
    the edge is a child. Depending on the option specified, the requisite
    locate operation is performed - primarily, whether this is a hit
    or miss, location (and possible creation) of the model-space counterpart,
    location of this edge itself.

  RETURN VALUE

    If the edge/curve was not accepted by the user, a message 
      - EMS_I_NotFound, is returned.
    If the accept/reject phase was interrupted by command-stacking, 
      - EMS_I_Interrupt, is returned.
    If the edge/curve was accepted
      - EMS_I_Found, is returned.

    On error, one of these error codes is returned:
      - EMS_E_Fail
      - EMS_E_NoDynamicMemory
      - EMS_E_EdgeError
      - EMS_E_CurveError

  BUGS

    EMSlcopt_uvelem option returns the correct objid/osnum of this edge. The
     rest of the data in the locate structure is junk.

  HISTORY

   Vidya  12/05/95  : Commenting Subhashish fix to enable location of edges
                      for dimensioning after PDD is run -TR 119528375.
   Vidya  08/22/95  :  If symbology overrides are set through PDD,the property
                       set is DE_HIDDEN, and also the global hidden flag check
                       needs to be done,inorder to not to locate for
                       dimensioning -TR 11921575
 
   Subha  06/22/94  :  Invisible symbology overrides placed on model should
                        not be locatable for dimensioning or other purposes.

    Sudha  06/04/93     modified to include BSprototype header files

    AMD :  02/18/92  :  Hilite the located edge with weight when edges
                        are being located directly.
    WBC :  05/06/91  :  If the located edge is in a reference file, create the
                        model-space counterpart and send to EMlocatecvbuffs.
                        Also take some special actions for self attached
                        reference files.
    WBC :  04/23/91  :  Now constructing the associative model-space
                        counterparts in the "active" module space instead of
                        the module space the edge is in (because of reference
                        files).
    AMD :  04/18/91  :  Added support for locating edges and vertices
                        directly.
    AIC :  04/09/91  :  Support EMED_NO_DISPLAY property.
    SA  :  05/10/90  :  Modified to process additional return codes
			from EMlocatecvbuffs() to handle odd behavior of
			action-handler when "auto-accept" is enabled during
			locate.
    PP  :  10/12/89  :  Modified arguments to EMedge_eligible.
    PP  :  09/20/89  :  Edge eligibility is determined by calling a
                        function to take advantage of locate control
                        interface.
    SS  :  06/21/89  :  Taking care of reference file attached edges. The
                        problem was that in EMlocatecvbuffs, transient OS
                        was not recognized as a reference file attachment
                        and the display would not be honored if this
                        edges level was off in that window for the master file.
    SS  :  12/06/88  :  Modified so that on model-space-element locate,
			if a model-space counterpart is present, it is
			used dierectly in the locate.
    SS  :  03/27/88  :  Creation

*/

class implementation EMSedge;

#include "EMS.h"
#include "msdef.h"
#include "emsdef.h"
#include "EMSlcdef.h"
#include "EMSobjmgrdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsedgedef.h"
#include "EMSaction.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "bsptcvgen.h"
#include "bsalloccv.h"

#include "grimport.h"
#include "dpmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "lcmacros.h"
#include "grerr.h"
#include "dpdef.h"
#include "DEso.h"
#include "DEsomacros.h"
#include "lcmsg.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern IGRint   EFrule_lines_on_off();
IGRint EMget_symb_override_region();


method EMbdrylocate (IGRlong *msg; struct EMSsfinfo *sfinfo;
                     struct EMSlcinput *lcin;
                     struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key;
                     struct EMSlcoutput *lcout)
{
  IGRboolean found, stopproc, refattach , noassoc_mscexists;
  IGRboolean (*user_eligfunc)();
  IGRushort options;
  IGRshort properties;
  IGRlong stat_OM, msg_loc, lcmsg, temp_msg, *cvlmsg;
  IGRlong sizebuffer, nbytes_ret;
  GRobjid mscobj;
  IGRint get = 1;
  struct GRmdenv_info *mdenv;
  struct GRmd_env module_env;
  struct IGRbsp_curve edcv_struct, *edcv;
  struct IGResbc esbc;
  struct IGRbsp_curve *bsp_point=NULL;
  struct GRid *edcvobj, edcvobj_mem;
  struct GRid my_GRid;
  IGRchar point_type;
  OM_S_CHANSELECT             chan_to_common_edge;
  OM_S_CHANSELECT             chan_to_comm_edge;
  OM_S_OBJECT_LINKAGE common_edge;
  OMuint counter;
  IGRlong sts;
  struct GRid curr_obj;
  extern IGRboolean locate_tangent_edges;


  void EMchglocobj(), EMchgstkobj();
  extern IGRboolean EMlocatecvbuffs(), EMhitcvbuff();
  extern IGRboolean EMedge_eligiblen();
  extern IGRboolean EMedge_curves_locatable();
  extern IGRlong GRcheckref(), EMremshobj();
  extern IGRlong EFlocate_action_handler();

  IGRboolean LocateVertex=FALSE, edge_hilite = FALSE;
  struct EMSaction_handler *do_not_locate=NULL;
  struct GRid  check_id;
  IGRboolean edge_flag = FALSE;

  *msg = EMS_I_NotFound;
  stat_OM = OM_S_SUCCESS;
  cvlmsg = &cvl->msg;
  *cvlmsg = MSSUCC;

  edcv_struct.poles = NULL;
  edcv_struct.knots = NULL;
  edcv_struct.weights = NULL;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  edcvobj = NULL;

  if(me->ed_props & EMED_NO_DISPLAY) goto ret_end;

  if(((me->ed_props & EMED_TANGENT) && !locate_tangent_edges) && 
      (me->ed_props & EMED_SEAM))
    if (! EFrule_lines_on_off(cvl->button.objid, cvl->button.osnum))
      goto ret_end;

  /*
   * Processing proceeds only if this edge is recognized as eligible.
   * If an eligibility checking function has been passed in, call it, else
   * call the default eligibility checker.
   */

  options = lcin->options;
  user_eligfunc = lcin->eligfunc;

  /* AMD
   This check has been added to filter out already located edges for
   the new locate_edge method. The parameters of the action handler
   have been used for this purpose. Following has been defined for the
   option field of struct EMSaction_handler.

       option == 6      edge locate.
       option == 7      vertex locate
  */

edge_process:
    
  if (cvl->action_handler == (int (*)())EFlocate_action_handler)
  {
   /* If my common edge or I are in the list being passed then exit */
   do_not_locate = (struct EMSaction_handler *) cvl->act_parms;
   stat_OM = EMmake_chanselect( EMSedge_to_common_edge, &chan_to_common_edge);
 
   if(do_not_locate->option == 8 && !edge_flag) {
        LocateVertex = TRUE;
	goto vertex_process;
   }
   else LocateVertex = FALSE;

   edge_hilite = TRUE;
   if((do_not_locate->option == LOCATE_EDGE && do_not_locate->num_objects) ||
	do_not_locate->option == 8)
    {

     OM_S_OBJECT_LINKAGE         comm_edge;
     OMuint count;
     IGRint i;        

     check_id.osnum = do_not_locate->objects.same_space.space_number;     
     for ( i=0; i<do_not_locate->num_objects; i++ )
      {
       check_id.objid = do_not_locate->objects.same_space.objid[i];

       stat_OM = om$get_channel_objects(
               object = me,
               p_chanselect = &chan_to_common_edge,
               list = &comm_edge,
               size = 1,
               count = &count);
       
        if(((my_id==check_id.objid)||(comm_edge.S_objid==check_id.objid))
           && (check_id.osnum == OM_Gw_current_OS))
           goto ret_end;
        }

      }

   if ( do_not_locate->option == LOCATE_VERTEX)
      LocateVertex = TRUE;
  }

  if (LocateVertex)
      goto vertex_process;

  if ((user_eligfunc ? 
       (*user_eligfunc) (my_id, cvl, lcin->eligfunc_args) : 
       EMedge_eligiblen (options, me->curve_type, me->ed_props, cvl->classes,
         &my_GRid)))
    {
    /*
     * Obtain the model-space geometry and call the appropriate function
     * that performs the required locate processing.
     */

    mdenv = &cvl->module.md_env;
    if (!lcin->more_info)
      {
      stat_OM = om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc,
                 mdenv, &sfinfo->id, sfinfo->geom, 0, MAXINT, FALSE, NULL, 
                 &edcv_struct), targetid = my_id);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
      edcv = &edcv_struct;
      }
    else
      edcv = (struct IGRbsp_curve *) lcin->more_info;

    /*
     * Invoke the function that checks to see if this edge was hit.
     * If there was no hit, exit.
     */

    found = EMhitcvbuff (&msg_loc, edcv, me->curve_type, cvl,
             lcin, lcout);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    if (!found)
      goto ret_end;

    if (options & EMSlcopt_hitormiss)
      {
       /* commenting subhashish fix to enable location of edges
        * for dimensioning after PDD is run --TR 119528375
        
         if(!(ME.EMSedge->ed_props & EMED_MSCEXISTS))
         {
           /* If MSC does'nt exist for the edge then get the other edge
              through the common edge channel and then get the MSC. 

           sts = EMmake_chanselect(EMSedge_to_common_edge, &chan_to_comm_edge);
           sts = om$get_channel_objects(
                 object = me,
                 p_chanselect = &chan_to_comm_edge,
                 list = &common_edge,
                 size = 1,
                 count = &counter);
           curr_obj.objid = common_edge.S_objid;
           curr_obj.osnum = common_edge.osnum;
        }
        else
        {
           curr_obj.objid = my_id;
           curr_obj.osnum = OM_Gw_current_OS;
        }
        edcvobj_mem.osnum = OM_Gw_current_OS;
        stat_OM = om$send (msg = message EMSboundary.EMgetxyzobj (&msg_loc,
                           EMSlcopt_existingmsc, NULL, NULL,NULL,
                                          NULL, NULL , edcvobj_mem.osnum,
                            &edcvobj_mem.objid), targetid = curr_obj.objid);

       if(!(stat_OM & 1) || (msg_loc != EMS_S_Success)
                           ||(edcvobj_mem.objid == NULL_OBJID))
         {
           *msg = EMS_I_Found;
           stat_OM = OM_I_STOP_SENDING;
         }
       else
         {
           stat_OM = om$send ( msg = message GRgraphics.GRgetprops(&msg_loc,
                                                           &properties),
                              targetid = edcvobj_mem.objid);

           get = EMget_symb_override_region( &msg_loc, cvl, edcvobj_mem.objid ,
                                    lcout->locobj.geom_parms.u, properties );
           if(get)
             {
                *msg = EMS_I_Found;
               stat_OM = OM_I_STOP_SENDING;
             }
           else
             {
               lcout->props &= ~EMSlcoutput_located;
               stat_OM = OM_I_STOP_SENDING;
               goto ret_end;
             }

         }
      */

       *msg = EMS_I_Found;
       stat_OM = OM_I_STOP_SENDING;

    }
    else if (EFedge_curves_locatable() &&
            (options & EMSlcopt_xyzelem || options & EMSlcopt_uvelem))
      {
      /*
       * Call the function that would invoke the action-handler and
       * select-handler for curve-buffers.  If this edge is in a reference
       * file attachment, construct the model-space counterpart and then pass
       * that to the function.  The generation of the MSC in the reference
       * file case is done so that the display mechanism (for accept/reject
       * can recognize this object as being in a reference file attachement
       * and can behave the way it behaves for such attachements).
       * The current module environment is sent to EMgetxyzobj because it
       * is used to get the geometry of the edge in the context the edge
       * exists in.
       */

      esbc.is_polydis = FALSE;
      esbc.is_curvedis = TRUE;

      sizebuffer = sizeof(struct GRmd_env);
      gr$get_module_env(msg = &msg_loc,
                        sizbuf = &sizebuffer,
                        buffer = &module_env,
                        nret = &nbytes_ret);

      GRcheckref(&temp_msg, &cvl->module.md_env.matrix_type,
                 cvl->module.md_env.matrix, NULL, &OM_Gw_current_OS);
      if (temp_msg == MSSUCC)
        refattach = TRUE;
      else
        refattach = FALSE;

      if (refattach ||
          (options & EMSlcopt_xyzelem &&
          ME.EMSedge->ed_props & EMED_MSCEXISTS))
        {
        edcvobj_mem.osnum = OM_Gw_current_OS;
        stat_OM = om$send (msg = message EMSboundary.EMgetxyzobj (&msg_loc,
                   NULL, &module_env.md_env, edcv,
                   &me->curve_type, &sfinfo->symb, &esbc, edcvobj_mem.osnum,
                   &edcvobj_mem.objid), targetid = my_id);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
        edcvobj = &edcvobj_mem;
        noassoc_mscexists = !(ME.EMSedge->ed_props & EMED_MSCEXISTS);
        }

      lcin->options |= EMSlcopt_skipgeomchk;

      if(edge_hilite) sfinfo->symb.display_attr.weight += 2;
 
      stopproc = EMlocatecvbuffs (&lcmsg, 1, edcv, edcvobj, &me->curve_type, 
                  &sfinfo->symb, &esbc, cvl,
                  range_key, lcin, lcout);
      lcin->options &= ~EMSlcopt_skipgeomchk;
      EMerr_hndlr (EMSerror (lcmsg), *msg, EMS_E_Fail, ret_end);
 
      if(edge_hilite) sfinfo->symb.display_attr.weight -= 2;

      /*
       * If user acceptance is detected, return the model-space
       * counterpart (which may have to be created if one did not exist, or
       * may have to be now associated to the edge if it wasn't so) or
       * return this edge id itself, whichever is indicated by the options.
       *
       * Added two more message keys. These can be returned when locate
       * is on "auto-accept" mode.
       * EMS_I_FoundOther: This is returned when the user accepts an
       *                   object from the stack (and not the one that has
       *                   been passed to the action-handler this time).
       * EMS_I_AutoStk   : This is returned when the action handler just 
       *                   puts the object on stack.
       * In both these case a model-space counterpart must be swapped for
       * the curve in question. -Ashok-
       */

      if (lcmsg == EMS_I_Found || lcmsg == EMS_I_FoundOther || 
	  lcmsg == EMS_I_Interrupt || lcmsg == EMS_I_AutoStk)
        {
        /*
         * The user has either accepted this curve or stacked the locate.
         * Process to change the located-object/locate-stack to reflect
         * an appropriate object.
         */

        if (options & EMSlcopt_xyzelem)
          {
          /*
           * At this point either an associated MSC exists or no MSC exists
           * at all.  If a MSC exists, get it otherwise create one.
           */

          stat_OM = om$send(msg = message EMSboundary.EMgetxyzobj (&msg_loc,
                                    NULL, &module_env.md_env, edcv,
        		            &me->curve_type, &sfinfo->symb, &esbc,
                                    OM_Gw_current_OS, &mscobj),
                            targetid = my_id);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

          if (lcmsg == EMS_I_Found || lcmsg == EMS_I_FoundOther)
            {
            /*
             * User has accepted this curve. In the GRlc_info structure,
             * replace the located-object id with the new one just obtained
             * and post it into the cvl-structure for return.
             *
	     * Modified to do the above only when the accepted object is
	     * myself (ie my counterpart). This check is required because
	     * a stacked object could have been accepted by the
             * user. -Ashok-
             */

	    if (lcmsg == EMS_I_Found)
	      {
              lcout->locobj.located_obj.objid = mscobj;
              lcout->locobj.located_obj.osnum = OM_Gw_current_OS;
              EMchglocobj (&msg_loc, cvl, 1, &lcout->locobj);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
	      }
            *msg = EMS_I_Found;
            }
          else
            {
            /*
             * The accept/reject is not yet complete. Replace the temporary
             * (shell) object in the locate-stack of the locate-argument
             * with the more permanent "mscobj". After this point control
             * does not return here but continues with the GRlocate message
             * of the "mscobj" if the command was interrupted. After that 
	     * point control is back with the command-object.
             */

            lcout->locobj.located_obj.objid = mscobj;
            lcout->locobj.located_obj.osnum = OM_Gw_current_OS;
            EMchgstkobj (&msg_loc, cvl, &lcout->locobj);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (lcmsg == EMS_I_Interrupt)
              *msg = EMS_I_Interrupt;
            }
          }
        else /* options & EMSlcopt_uvelem */
          {
          /*
           * The object to be returned as the located object is this
           * edge itself. So change the located-object in the cvl-structure
           * to reflect this. The entire GRlc_info structure has to be
           * initialized with uv-relevant information.
	   */
  
          if (lcmsg == EMS_I_Found || lcmsg == EMS_I_FoundOther)
            {
	    if (lcmsg == EMS_I_Found)
	      {
              lcout->locobj.located_obj.objid = my_id;
              lcout->locobj.located_obj.osnum = OM_Gw_current_OS;
              EMchglocobj (&msg_loc, cvl, 1, &lcout->locobj);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
	      }
            *msg = EMS_I_Found;
            }
          else
           /* This has been added to support the direct locate of 
              edges. If the command is stacked then the locate stack
              is cleared.  AMD   7/10/91 */ 
            {
            EMclearstack (&msg_loc, cvl);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (lcmsg == EMS_I_Interrupt)
              *msg = EMS_I_Interrupt;
            }
          }
        }

      if (stopproc)
        {
        /*
         * User input or the locate function call has determined that
         * no more processing needs to be done. Control should immediately
         * return to the initiator of this locate.
         */

        stat_OM = OM_I_STOP_SENDING;
        }
      }
    }
 
 /* AMD
    This part has been added for supporting direct locate of vertices
    and filtering out vertices already located in the locate_vertex 
    method.
 */
 
 vertex_process:
  if(LocateVertex && !edge_flag)
    {
     IGRshort order=0;
     IGRpoint stop_point;
     IGRpoint start_point;
     IGRint   num_edges = 0;
     GRobjid  *edges=NULL, eligible_edge[20],edgemax ;
     IGRboolean *is_rightend=NULL;
     IGRint     i, index = 0;
     IGRint      num_buff = 10;
     IGRushort  edge_options;
     
     mdenv = &cvl->module.md_env;

     /* Get all the non degenerate edges for this vertex */
     edge_options = EMSvtxedges_nodegenerate;
     stat_OM = om$send(msg = message  EMSedge.EMgetvtxedges(&msg_loc, 
                          edge_options, TRUE, num_buff,
                          &num_edges, &edges,
                          &is_rightend), 
                   targetid = my_id );
     if( !(1 & stat_OM))  goto ret_end; 

     /* Get the highest edge id which has its stop point at this
        vertex. This is the definition of a vertex. */

     for (i=0; i<num_edges; i++)
      {
       if( (is_rightend[i]))
        {
         eligible_edge[index] = edges[i];
         index ++;
        }
      }
/* fix for mlk */
      if(edges) om$dealloc(ptr = edges);
      if(is_rightend) om$dealloc(ptr = is_rightend);
 
     edgemax = eligible_edge[0]; 
     for (i=0; i<index; i++)
      {
       if (eligible_edge[i] > edgemax)
          edgemax = eligible_edge[i];
      }

     if(my_id != edgemax) {
      	if(do_not_locate->option == LOCATE_VERTEX) 
               goto ret_end;
     }

    /* Exit if this vertex has been located */
    check_id.osnum = do_not_locate->objects.same_space.space_number;     
    for ( i=0; i<do_not_locate->num_objects; i++ )
     {
       check_id.objid = do_not_locate->objects.same_space.objid[i];
       if(( my_id == check_id.objid ) && 
         ( check_id.osnum == OM_Gw_current_OS))
            goto ret_end;
      }   

     stat_OM = om$send( msg = message EMSedge.EMxyz_endpt( &msg_loc, NULL,
                        mdenv, NULL, NULL, start_point, 
                        stop_point, NULL ),  
               targetid = my_id );
     EMomerr_exit (stat_OM, ret_end);
     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

     /* Get the bspline curve for this point */
     order = 2;

     BSalloccv(2, 4, FALSE, 0, &bsp_point, &msg_loc);
     EMerr_hndlr (msg_loc!= BSSUCC, *msg, EMS_E_BSerror, ret_end);
     BSptcvgen ( stop_point, order, FALSE, bsp_point, &msg_loc) ;

     /* Invoke the function that checks to see if this point was hit */     

     found = EMhitcvbuff (&msg_loc, bsp_point, me->curve_type, cvl,
             lcin, lcout);
     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
     if (!found) {
      	if(do_not_locate->option == 8) {
		edge_flag = TRUE;
		if(bsp_point) BSfreecv(&msg_loc, bsp_point);
                bsp_point = NULL;
		goto edge_process;
  	}
	else 
      		goto ret_end;
    }

    if (options & EMSlcopt_hitormiss)
      {
      *msg = EMS_I_Found;
      stat_OM = OM_I_STOP_SENDING;
      }
    else if (EFedge_curves_locatable() &&
            (options & EMSlcopt_xyzelem || options & EMSlcopt_uvelem))
      {

      esbc.is_polydis = FALSE;
      esbc.is_curvedis = TRUE;

      sizebuffer = sizeof(struct GRmd_env);
      gr$get_module_env(msg = &msg_loc,
                        sizbuf = &sizebuffer,
                        buffer = &module_env,
                        nret = &nbytes_ret);

      GRcheckref (&msg_loc, &cvl->module.md_env.matrix_type,
       cvl->module.md_env.matrix, NULL, &OM_Gw_current_OS);
      if (msg_loc == MSSUCC)
        refattach = TRUE;
      else
        refattach = FALSE;

      if (refattach ||
          (options & EMSlcopt_xyzelem &&
           ME.EMSedge->ed_props & EMED_MSCEXISTS))
        {
        edcvobj_mem.osnum = OM_Gw_current_OS;
        stat_OM = om$send (msg = message EMSboundary.EMgetxyzobj (&msg_loc,
                   NULL, &module_env.md_env, bsp_point,
                   &me->curve_type, &sfinfo->symb, &esbc, edcvobj_mem.osnum,
                   &edcvobj_mem.objid), targetid = my_id);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
        edcvobj = &edcvobj_mem;
        noassoc_mscexists = !(ME.EMSedge->ed_props & EMED_MSCEXISTS);
        }

      lcin->options |= EMSlcopt_skipgeomchk;
 
     /* Point hilite to be done by increasing the weight */
      sfinfo->symb.display_attr.weight += 4;
      point_type= EMpoint;
      stopproc = EMlocatecvbuffs (&lcmsg, 1, bsp_point, edcvobj, &point_type, 
                  &sfinfo->symb, &esbc, cvl, range_key, lcin,
                  lcout);
      lcin->options &= ~EMSlcopt_skipgeomchk;
      EMerr_hndlr (EMSerror (lcmsg), *msg, EMS_E_Fail, ret_end);

      sfinfo->symb.display_attr.weight -= 4;

      if (lcmsg == EMS_I_Found || lcmsg == EMS_I_FoundOther || 
	  lcmsg == EMS_I_Interrupt || lcmsg == EMS_I_AutoStk)
        {
        if (options & EMSlcopt_xyzelem)
          {
          stat_OM = om$send (msg = message EMSboundary.EMgetxyzobj (&msg_loc,
                     EMSlcopt_touchmsc, &module_env.md_env, bsp_point,
		     &me->curve_type, &sfinfo->symb, &esbc, OM_Gw_current_OS,
                     &mscobj), targetid = my_id);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

 
          if (lcmsg == EMS_I_Found || lcmsg == EMS_I_FoundOther)
            {
	    if (lcmsg == EMS_I_Found)
	      {
              lcout->locobj.located_obj.objid = mscobj;
              lcout->locobj.located_obj.osnum = OM_Gw_current_OS;
              EMchglocobj (&msg_loc, cvl, 1, &lcout->locobj);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
	      }
            *msg = EMS_I_Found;
            }
          else
            {
            lcout->locobj.located_obj.objid = mscobj;
            lcout->locobj.located_obj.osnum = OM_Gw_current_OS;
            EMchgstkobj (&msg_loc, cvl, &lcout->locobj);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (lcmsg == EMS_I_Interrupt)
              *msg = EMS_I_Interrupt;
            }
          }
        else /* options & EMSlcopt_uvelem */
          {
          if (lcmsg == EMS_I_Found || lcmsg == EMS_I_FoundOther)
            {
	    if (lcmsg == EMS_I_Found)
	      {
              lcout->locobj.located_obj.objid = my_id;
              lcout->locobj.located_obj.osnum = OM_Gw_current_OS;
              EMchglocobj (&msg_loc, cvl, 1, &lcout->locobj);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
	      }
            *msg = EMS_I_Found;
            }
          else
            {
            EMclearstack (&msg_loc, cvl);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (lcmsg == EMS_I_Interrupt)
              *msg = EMS_I_Interrupt;
            }
          }
        }

      if (stopproc)
        {
        stat_OM = OM_I_STOP_SENDING;
        }
      }
    }

ret_end:
   /*fix for mlk */
  if(bsp_point) BSfreecv(&msg_loc, bsp_point);
    bsp_point = NULL;
  if (edcv_struct.poles)
    om$dealloc (ptr = edcv_struct.poles);
  if (edcv_struct.knots)
    om$dealloc (ptr = edcv_struct.knots);
  if (edcv_struct.weights)
    om$dealloc (ptr = edcv_struct.weights);
/*
  if (edcvobj && noassoc_mscexists)
    EMremshobj (&msg_loc, NULL, EMSshobj_sfbdry,
     edcvobj->osnum, edcvobj->objid);
*/
  EMWRAPUP (*msg, stat_OM, "EMSedge.EMbdrylocate");
  if (EMSerror (*msg))
    *cvlmsg = MSFAIL;
  return (stat_OM);
}



IGRint  EMget_symb_override_region( msg, cvl, my_grid, new_u, properties)

   IGRlong           *msg;
   struct GRlc_cvl   *cvl;
   GRobjid           my_grid;
   IGRshort          properties;
   IGRdouble         new_u;

{

    /* If the object has a symbology override then this function checks
       if the input data point lies within the override range. If the
       data point is within the range and the override is an invisible
       override then this function returns zero otherwise one.
    */

    IGRlong     OMmsg;                     /* OM return value              */
    IGRlong     msg1;                      /* local return message         */
    IGRint      eligible_flag;
    IGRdouble   old_u1,
                old_u2;
    struct IGRdisplay   old_display;
    struct GRid    go_grid,
                   window_grid;
    IGRint         old_type;
    IGRboolean     invis_on;
    OMuword save_id;


    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    cvl->msg = MSSUCC;
    eligible_flag = 1;

    if (cvl->attributes.type == GR_bl_loc)
    {                           /* bore line locate             */

       /* Is there is a SO on the object? */
       if ( properties & DEHAS_OVERRIDE )
       { /* YES - get the SO? */

          go_grid.objid = my_grid;
          go_grid.osnum = OM_Gw_current_OS;
          window_grid.objid = cvl->button.objid;
         /* corrected wrong setting of osnum to window object and md_id */
          window_grid.osnum = cvl->button.osnum;
         save_id = cvl->module.md_id.osnum;
         cvl->module.md_id.osnum=OM_Gw_current_OS;

          msg1 = de$retrieve_override (
                             msg         = &OMmsg,
                             p_type      = &old_type,
                             p_u1        = &old_u1,
                             p_u2        = &old_u2,
                             p_symbology = &old_display,
                             go_grid     = &go_grid,
                             u           =  new_u,
                             window_grid = &window_grid,
                             module      = &cvl->module );

         cvl->module.md_id.osnum=save_id;

         if ( 1 & OMmsg )
         { /* We are on the symbology override region */

           /* additional check needed to avoid invisible symbology
            * overrides to be located when set through PDD and
            * also check the global hidden flag is on/off -TR 11921575
            */
            if(old_type & DE_HIDDEN)
              {
               IGRboolean hidden_on;
               IGRlong status;
 
                  status = gr$get_hidden_so_on( msg    =  msg,
                                                buffer = &hidden_on );
               if(!hidden_on) eligible_flag = 0;
 
              }

            if ( old_type & DE_INVIS )
            { /* YES - do we accept or reject? */

                 msg1 = gr$get_invis_so_on( buffer = &invis_on );
                 if ( invis_on )
           eligible_flag = 0;

            }
         }
 OMmsg = OM_S_SUCCESS;
      }

   }

    return (eligible_flag);
}
end implementation EMSedge;


