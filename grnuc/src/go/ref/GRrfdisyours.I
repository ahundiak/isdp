/*
Name
	GRdisyourself - sends to the appropriate methods to
		    display a graphics object.
Synopsis
	
     	GRdisyourself ( msg, type, matrix, mode, alt_symb, dp_info,key)

	long                  *msg	Completion code
	short                 *type  	type of the matrix
	IGRmatrix             *matrix   environment transformation matrix
	GRdpmode              *mode	the display mode
	struct IGRaltdisplay  *alt_symb an overriding symbology
       	struct DP_information *dp_info	special display information
    	OM_p_KEY_DESC         key	range key information

Description

	This method gathers the pertinent information to display
	a graphics object.  The range information is computed to
	do a pass through the R-tree of the reference file 
	object space to display the objects in the reference
	file space.  If there is a clipping polygon it is also
	displayed.  If the attachment object is to be displayed,
	only the box defining its boundaries is displayed.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS     03/27/86 	Design date.
	ashok	11/16/90	Modified so that viewport clip range is not
				changed if view happens to be perspective.
				Also scan_range is obtained from instance
				data if view is perspective
	henry   12/05/91	Support GRHIDDEN_OFF flag
        jack    06/25/92        Added support for tangent edge suppression.
        Gang    07/07/93      Added support for Shrink/Wrap of clipping polygon.
*/

class implementation GRreffile;

#include "grimport.h"
#include "godef.h"
#include "msdef.h"
#include "OMindex.h"
#include "refpriv.h"
#include "madef.h"
#include "gocmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "refdef.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grdpb.h"
#include <alloca.h>
#include "detaildef.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"

%safe
IGRboolean DPdlist_in_fold_dynamics = FALSE;
%endsafe
IGRboolean GRexpansion_valid ();
extern void GRdv_tangent_edge_display();
extern int GRupdshwrclip();

from GRdvattach import GRget_put_orientation;

method  GRdisyourself ( long *msg; short *mx_type; IGRmatrix matrix; 
	enum GRdpmode *mode; struct IGRaltdisplay *alt_symb; 
	struct DP_information *dp_info;	OM_p_KEY_DESC key )
{
  enum GRdpmode        local_mode;  /* local mode for clip poly  */
  char                 *ptr;
  char unsigned        wght, style;
  short                is_skew, props;
  IGRushort            color;
  IGRboolean           update_flag;
  long                 OMmsg, OMmsg1;
  long                 msg1;
  int                  i;
  int                  dimension;
  int                  old_levels [32];  /* saved levels from dp_info  */
  double               tolerance;
  double               old_range [6],    /* saved range from dp_info   */
                       poly_range [6],   /* clip polygon range         */
                       scan_range [6],
                       shwr_range[6],
                       *scan_range_ptr = NULL;
  struct GRmd_env      dummy_env,new_env;
  struct IGRaltdisplay local_symb;
  OM_S_MESSAGE         display_msg;   /* structs for make message  */
  OM_S_CHANSELECT      chan,          /* channel to polygon    */
                       owner_chan;    /* channel to drawing view attachment */
  GRspacenum           osnum;
  OMuint               chan_count=0;
  OM_S_OBJECT_LINKAGE *list=NULL;
  IGRint               cntr;
  OMuword              classid;
  IGRint               get_flag,
                       orient,
                       inquire_only,
                       turn_on = 1,
                       result;
  struct GRid          ref_id;
  int                  old_is_update;



  struct display_args_struct  /* arguments for display method  */
  {
    long                  *msg;
    short                 *mx_type;
    double                *matrix;
    enum GRdpmode         *mode;
    struct IGRaltdisplay  *alt_symb;
    struct DP_information *dp_info;
    OM_p_KEY_DESC         key;
  } display_args;

  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  result = 0;
  inquire_only=0;

  if ( ( (me->properties & GRIS_DISPLAYABLE) || (*mode == GRhdo) ||
      (*mode == GRhhdo) || (*mode == GRheo) ||
      (*mode == GRbdheo) || (*mode == GRbeheo))
      &&
      (DPlevel_on(me->level,dp_info))
      && ( GRexpansion_valid() ))

  {

    if((me->properties & GRIS_DISPLAYABLE) && 
       (me->ref_properties & GRRF_SHRINK_WRAP) && *mode == GRbd)
     {
        ref_id.objid = my_id;
        ref_id.osnum = OM_Gw_current_OS;

       OMmsg = ex$del_function(fun = GRupdshwrclip, mode = EX_START_FUNC);
       OMmsg = ex$add_function(fun = GRupdshwrclip, mode = EX_START_FUNC);   
     }

    owner_chan.type = OM_e_addr;
    owner_chan.u_sel.addr = &me->to_owners;

    /* check if there is a drawing view attachment connected to me */
    om$get_channel_count( object = me,
                          p_chanselect = &owner_chan,
                          count = &chan_count );
    if(chan_count > 0)
      {
       /* allocate memory for the list of objects */      
       list = (OM_S_OBJECT_LINKAGE *) alloca(sizeof(OM_S_OBJECT_LINKAGE) *
                                                    chan_count);

       /* get the drawing view attachment object */
       OMmsg = om$get_channel_objects( object = me,
                                       p_chanselect = &owner_chan,
                                       size = chan_count,
                                       list = list,
                                       count = &chan_count);
       if(! (1 & OMmsg )) goto wrapup;

       for(cntr=0;cntr<chan_count;cntr++)
        {
         OMmsg = om$get_classid(osnum = list[cntr].osnum,
                                objid = list[cntr].S_objid,
                                p_classid = &classid );
       if(! (1 & OMmsg )) goto wrapup; 

         if( classid == OPP_GRdvattach_class_id )
          {
           /* the tangent edge display flag (bit) is in the orientation
              int for the drawing view attachment.
            */  
           orient = 0;
           get_flag = 1;
           OMmsg = om$send(msg = message GRdvattach.GRget_put_orientation
                                         (msg, 
                                          get_flag,
                                         &orient),
                            senderid = my_id,
                            targetos = list[cntr].osnum,
                            targetid = list[cntr].S_objid );
           if(! (1 & OMmsg & *msg)) goto wrapup;
            
           /* toggle the tangent edge display flag */
           if(orient & GR_DV_TAN_ED_DIS_OFF_CURRENT)  /* if display is off */
            {
             turn_on=0;
             /* turn static variable off(edge display methods will
                access it.)
              */  
             GRdv_tangent_edge_display(inquire_only,
                                       turn_on,
                                      &result);
            } /* if the display for the drawing view is off */
            
          } /* if we found the GRdvattach object */
          
        } /* looping through the channel objects */
        
        
      } /* if( chan_count > 0 ) */


    /* display clipping polygon */
    chan.type = OM_e_addr;
    chan.u_sel.addr = &me->to_clip;


    /* determine if this request should be sent to the graphics objects
       in the reference file or if it is meant for the  attachment cube or both.
       For a highlight request, we do not want to highlight all the
       elements in the reference file so a highlight request is
       trapped and only sent to the clipping polygon.
       If it is a fit operation, we consider the objects in the file
       only if the clipping polygon is not displayed.
    */

    if (DPis_fit ( dp_info) )
    {
      om$send ( msg = message GRvg.GRgetprops ( msg, &props ),
          p_chanselect = &chan );
      if (props & GRIS_DISPLAYABLE)
        /* terminate if the polygon is displayable */
        goto wrapup;
    }
    else
    {
      /* If it is not an update or a fit request, draw the clipping polygon. */
      if (!dp_info->is_update)
      {
        /* check to see if message came from the clipping polygon */
        OMmsg = om$is_objid_on_channel (
            objid_c = my_id,
            p_chanselect = &chan,
            objid = sender_id );

        if (OMmsg == OM_W_NOTONCHAN)
        {
          if ((*mode == GRbeheo) || (*mode == GRbdheo))
            local_mode = GRheo;
          else
            local_mode = *mode;
        if(!(me->ref_properties & GRRF_SHRINK_WRAP))
         {
          OMmsg = om$send (
              msg = message GRgraphics.GRdisyourself
              ( msg, mx_type, matrix, &local_mode, alt_symb, dp_info,key ),
              p_chanselect = &chan );
         }
        }
      }
    }
    
    if (OMmsg == OM_I_STOP_SENDING)
      goto wrapup;

    /* check to be sure a file is attached and the reference file object 
       is not just an empty window. */
    dimension = om$dimension_of ( varray = me->filename );
    OMmsg1 = om$os_name_to_number ( osname = me->osname, p_osnum = &osnum );
    if (dimension && (OMmsg1 & 1))
    {
      if (1 & (OMmsg = om$make_message ( classname = "GRgraphics",
          methodname = "GRdisyourself",
          size = sizeof ( struct display_args_struct),
          p_arglist = &display_args,
          p_msg = &display_msg )))
      {
        is_skew = me->ref_properties & GRIS_SKEW;

        /* load the arguments to the display method */
        display_args.msg = msg;
        display_args.mx_type = &new_env.md_env.matrix_type;
        display_args.matrix = new_env.md_env.matrix;
        display_args.mode = mode;
        display_args.key = 0;
        display_args.dp_info = dp_info;
        dummy_env.md_env.matrix_type = *mx_type;
        for (i = 0; i < 16; i++)
          dummy_env.md_env.matrix [i] = matrix [i];

        /* set up symbology structure for overriding symbology */
        if (alt_symb || (me->ref_properties & GROVERRIDE_SYMBOLOGY))
        {
          local_symb.color = 0;
          local_symb.weight = 0;
          local_symb.style = 0;
          display_args.alt_symb = &local_symb;
        }
        else
          display_args.alt_symb = 0;

        if (alt_symb)
          local_symb = *alt_symb;
        if (me->ref_properties & GROVERRIDE_SYMBOLOGY)
        {
           if ((me->display_attr.color != ((unsigned short)-1)) && (! local_symb.color))
          {
            local_symb.color = &color;
            color = me->display_attr.color;
          }
          
          if ((me->display_attr.weight != ((unsigned char) -1)) && (! local_symb.weight))
          {
            local_symb.weight = &wght;
            wght = me->display_attr.weight;
          }
          
          if ((me->display_attr.style != ((unsigned char) -1)) && (! local_symb.style))
          {
            local_symb.style = &style;
            style = me->display_attr.style;
          }

          /* if the local_symb is all zeroes, then there really isn't
             an override, the GROVERRIDE_SYMBOLOGY bit probably shouldn't
             have been set.
           */  
          if (!local_symb.color && !local_symb.weight && !local_symb.style)
            display_args.alt_symb = 0;
       }

        om$send(msg = message GRreffile.GRgetenvironment ( msg, &dummy_env, &new_env ),
            targetid = my_id);

        GRgetabsg(&msg1,mx_type,matrix,&ptr,i);
        if (1 & msg1)
        {
          MAcpextents ( &msg1, ptr, poly_range, &poly_range [3] );
          if (1 & msg1)
          {
            if (!DPis_fit ( dp_info ))
            {
            if(!(me->ref_properties & GRRF_SHRINK_WRAP))
              dp$inter_clip_range        
                  ( msg = &msg1,
                  old_range = old_range,
                  range = poly_range,
                  dp_info = dp_info );
              if (1 & msg1)
              {
                GRgetupdrng ( msg,dp_info, &new_env.md_env.matrix_type,
                    new_env.md_env.matrix,scan_range);

                scan_range_ptr = scan_range;

                /* If view is perspective then do not change the viewport clipping range.
                   Also do not use the scan_range returned by GRgetupdrng() because it is
                   incorrectly computed for perspective view. Instead use the "range" stored
                   in my instance data.  */
                if(dp_info->gragad->flags & IS_PERSP)
                {
                if(!(me->ref_properties & GRRF_SHRINK_WRAP))
                  dp$reset_clip_range (
                     msg = &msg1,
                     old_range = old_range,
                     dp_info = dp_info );

                  scan_range_ptr = me->range;   
                }
              }
            }
            else
              scan_range_ptr = me->range;

            if (1 & msg1)
            {
              /* alter levels for reffile */
              DPset_levels ( old_levels, me->dp_levels, dp_info );

              /* since all objects in the range are being drawn set is_update flag */
              update_flag = dp_info->is_update;
              dp_info->is_update = 1;
              tolerance = 0.0;
              if (1 & *msg)
              {
                IGRboolean hidden_so_flag, hidden_so_off = 0;

                /* check if we have hidden symbology off */
                if (me->ref_properties & GRHIDDEN_OFF)
                {
                  /* Yes, copy the current hidden symbology */
                  gr$get_hidden_so_on ( msg = msg, buffer = &hidden_so_flag );
                  gr$put_hidden_so_on ( msg = msg, buffer = &hidden_so_off );
                }
               if(me->ref_properties & GRRF_SHRINK_WRAP)
                 {
                   shwr_range[0] = shwr_range[1] = shwr_range[2] = 
                                            (double)(GRDGNLIMITS_MIN_D + 1.0);
                   shwr_range[3] = shwr_range[4] = shwr_range[5] = 
                                            (double)(GRDGNLIMITS_MAX_D - 1.0);
                   scan_range_ptr = shwr_range;
                 }
              
                /* Kludge for setting the matrix right in fold dynamics */
                if ( DPdlist_in_fold_dynamics )
                {
                   old_is_update = dp_info->is_update;
                   dp_info->is_update = 0;
                }
                DPdlist_enter_reference_file( dp_info, 
                                              new_env.md_env.matrix_type,
                                              new_env.md_env.matrix );
            

                OMmsg = GRrefdisplaypass ( &msg1, mx_type, matrix,
                    &new_env,&display_msg, &is_skew,
                    me->vw_origin,
                    me->vw_rotation,NULL,NULL,ptr,
                    me->vw_volume,
                    me->master_to_ref_matrix,
                    scan_range_ptr, &tolerance, &my_id,
                    &OM_Gw_current_OS );

                DPdlist_exit_reference_file( dp_info, mx_type, matrix );
                if ( DPdlist_in_fold_dynamics )
                {
                   dp_info->is_update = old_is_update;
                }

                if (me->ref_properties & GRHIDDEN_OFF)
                  /* restore hidden symbology flag */
                  gr$put_hidden_so_on ( msg = msg, buffer = &hidden_so_flag );
              }
              
              /* restore is_update flag */
              dp_info->is_update = update_flag;

              /* Do not reset clip-range if view is perspective */
              if (!(DPis_fit(dp_info)) && !(dp_info->gragad->flags & IS_PERSP) )
                if(!(me->ref_properties & GRRF_SHRINK_WRAP))
                dp$reset_clip_range (
                    msg = &msg1,
                    old_range = old_range,
                    dp_info = dp_info );

              DPreset_levels ( old_levels, dp_info );
            }
            else  
              /* not in this window */
              goto wrapup;
          }
          else
          {
            *msg = MSFAIL;
            OMmsg = OM_E_ABORT;
          }
        }
        else
        {
          *msg = MSFAIL;
          OMmsg = OM_E_ABORT;
        }
      }
      else
        *msg = MSFAIL;

      if((me->properties & GRIS_DISPLAYABLE) && 
         (me->ref_properties & GRRF_SHRINK_WRAP) && *mode == GRbd)
       {
         GRrfaddshwr(&ref_id);
       }
    }

    GR_NOTIFY_LISTENERS ( msg, &OMmsg, GR_DISPLAYED );
  }

wrapup:

  if(chan_count > 0)
    if(turn_on == 0) 
     {
      /* reset the static tangent edge display variable */
      turn_on = 1;
      GRdv_tangent_edge_display(inquire_only,
                                turn_on,
                               &result);
     }
          
  return OMmsg;
}

end implementation GRreffile;
