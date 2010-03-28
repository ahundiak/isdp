class implementation GRbspline;
   

#include "wl.h"
#include "dl.h"
#include "DPdlist.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "msdef.h"

extern struct GRid DPdlist_wf_fb_gragad;
extern IGRdouble *DPdlist_fb_buffer;
extern int DPdlist_wf_fb_pipe_id;
extern IGRboolean DPdlist_feedback_in_progress;


from GRviewdyn import DPdisplay_for_dlist;


method GRadd_to_display_list( 
   IGRlong *msg; 
   IGRboolean is_hidden_line )

/*
NAME
   GRadd_to_display_list
 
DESCRIPTION
   This is an override of the GRadd_to_display_list defined in GRgraphics.
   This method adds the element to the display list.
 
 
GLOBALS USED
   none
 
RETURN VALUES
   OM_S_SUCCESS - Success
   OM_E_ERROR - Failure
 
HISTORY
   08/02/93  Shridar Subramanian
      Initial specification and design and implementation
*/


{
   IGRdouble *points;
   IGRuint num_points;
   int qsize;
   unsigned short ele_flags;
   int sts;
   IGRdouble *elem_ptr, *start_ptr, *dest_ptr, *next_elem_ptr;
   int current_size;
   int flag;
   OMuword class_id;
   struct IGResbc curve_attr;

   *msg = MSSUCC;
   sts = OM_S_SUCCESS;
   DPdlist_feedback_in_progress = TRUE;

   /* display curve to get its strokes in the feedback buffer */
   sts = om$send( msg = message GRviewdyn.DPdisplay_for_dlist( msg, my_id, 
                                                               OM_Gw_current_OS ),
                  targetid = DPdlist_wf_fb_gragad.objid,
                  targetos = DPdlist_wf_fb_gragad.osnum,
                  senderid = NULL_OBJID );

   if ( !(1 & sts & *msg) )
   {
      goto wrapup;
   }

   if ( ((WLuint16 *)DPdlist_fb_buffer)[0] == 0 )
   {
      /* nothing added to feedback buffer */
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }

   sts = DPdlist_set_element_flags( my_id, OM_Gw_current_OS, &ele_flags );
   if ( !(1 & sts) )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }

   sts = om$send( msg = message GRvg.GRgetattr( msg, (IGRchar *)&curve_attr ),
                  targetid = my_id );
   if ( !(1 & sts & *msg) )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }

   if ( curve_attr.is_polydis )
   {
      ele_flags |= DP_DLIST_ELE_DISPLAY_POLYGON;
   }
                 
   flag = FALSE;

   sts = om$get_classid( osnum = OM_Gw_current_OS, objid = my_id,
                           p_classid = &class_id );

   sts = om$is_ancestry_valid( subclassid = class_id,
                               superclassname = "GAcurve" );
 
   if ( sts == OM_S_SUCCESS )
   {
      HSdlist_is_msc( my_id, OM_Gw_current_OS, &flag );
   }

   if ( (flag) )
   {
      /* curve is a model space counterpart */
      ele_flags |= DP_DLIST_ELE_IS_MSC;
   }

   /* If the curve is filled the add a polygon instead of lines */
   /* Only one polygon can be added.                            */
   if ( ( (WLuint16 *) DPdlist_fb_buffer)[0] == DL_FB_BSC_PXYZ )
   {
      ele_flags |= DP_DLIST_ELE_FILLED;
      start_ptr =  &DPdlist_fb_buffer[1];
      points = &start_ptr[2];
      num_points = ( ( int * ) start_ptr)[2] / 3;

      sts = DPdlist_add_polygon( my_id, OM_Gw_current_OS, ele_flags, 
                                 me->display_attr.color, 
                                 me->display_attr.style, 
                                 me->display_attr.weight,
                                 me->level, 
                                 num_points, points );
      if ( !(1 & sts) )
      {
         *msg = MSFAIL;
         sts = OM_E_ERROR;
         goto wrapup;
      }

   }
   else if ( ( (WLuint16 *) DPdlist_fb_buffer)[0] == DL_FB_BSC_LXYZ )
   {
      elem_ptr = start_ptr = &DPdlist_fb_buffer[2];
      points = &start_ptr[1]; 
      dest_ptr = points + ( ( int * )elem_ptr)[1] ;
      qsize = ( ( int * ) DPdlist_fb_buffer )[1] ;
      num_points = 0;
      while ( qsize )
      {
         /* Increment the number of points */
         num_points += ( ( ( int * )elem_ptr)[1] )/3;
         current_size =  ( ( int * )elem_ptr)[1];
         next_elem_ptr = elem_ptr + 2 + ( ( int * )elem_ptr)[1];

         if ( elem_ptr != start_ptr )
         {
            /* Move the points together */

            memcpy( dest_ptr, &elem_ptr[1], ( ( int * )elem_ptr)[1] * 8 );
            dest_ptr +=current_size;
         }

         qsize -= ( current_size + 2 );
         elem_ptr = next_elem_ptr;
      
      }
   
      sts = DPdlist_add_curve( my_id, OM_Gw_current_OS, ele_flags, 
                               me->display_attr.color,                         
                               me->display_attr.style, 
                               me->display_attr.weight,
                               me->level, 
                               num_points, points );
      if ( !(1 & sts) )
      {
         *msg = MSFAIL;
         sts = OM_E_ERROR;
         goto wrapup;
      }
   }
   else if ( ( (WLuint16 *) DPdlist_fb_buffer)[0] == DL_FB_LXYZ )
   {
      num_points =( ( int * ) DPdlist_fb_buffer)[1] /3;
      points = &DPdlist_fb_buffer[1];
      sts = DPdlist_add_curve( my_id, OM_Gw_current_OS, ele_flags, 
                               me->display_attr.color,
                               me->display_attr.style, 
                               me->display_attr.weight,
                               me->level, 
                               num_points, points );
      if ( !(1 & sts) )
      {
         *msg = MSFAIL;
         sts = OM_E_ERROR;
         goto wrapup;
      }

   }
   else
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }


wrapup:
   DLreset_feedback( DPdlist_wf_fb_pipe_id );
   ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
   ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;


   DPdlist_feedback_in_progress = FALSE;

   return( sts );

} /* GRadd_to_display_list */

end implementation GRbspline;
