/*-----
%GP% CODE CLASSIFICATION
----
%HD%

    MODULE NAME : DPdiselem

    Abstract    : This module contains the routine to display an
      		  elements that are formatted into DPabsele structure.
----
%SC%

    VALUE = DPdiselem(msg, buffer, mode, dp_info);
----
%EN%

    ON ENTRY:

        NAME	     DATA TYPE		DESCRIPTION
      ----------   ----------------    ------------------------------
        *msg	     IGRint		pointer to the return message
        *buffer	     struct DPele_header	pointer to the buffer
        *mode	     enum GRdpmode	pointer to the display mode
        *dp_info     struct DP_information    pointer to special struct
----
%EX%

    ON EXIT:

        NAME	     DATA TYPE		DESCRIPTION
      ----------   ----------------    ------------------------------
        msg	     IGRlong		completion code
                                        - MSSUCC	: successful
                                        - DPBADMODE	: bad display mode
                                        - DPBADELETYP   : bad element type
        VALUE	     IGRboolean		return code
                                        - TRUE		: successful
                                        - FALSE		: failure
----
%MD%

   MODULES INVOKED: DPbcstrk
                    DPbsqstrk
                    DPpsstrk
                    DPtxstrk
                    DPfixelem
                    DPsetdsp
----
%NB%

   NOTES:
----
%CH%

   CHANGE HISTORY:

        ht JAN-09-86 : Creation date
----
%PD%

   -------------------------------------------------------------------------
                   P R O G R A M    D E S C R I P T I O N
   -------------------------------------------------------------------------


----*/


#include "grimport.h"
#include "wl.h"

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igrdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "dperr.h"
#include "msdef.h"
#include "igecolordef.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "dl.h"

/* prototypes */
#include "dpbcstrk.h"
#include "dppsstrk.h"
#include "dppystrk.h"
#include "dpbsqstrk.h"
#include "dprngcheck.h"
#include "exproto.h"
#include "dpdiselem.h"

#if defined ( X11 )
#include "FSX.h"
#else
#include "FS.h"
#endif
#include "FSOutl.h"
#include "FSBmap.h"
#include "dpfont.h"
#include "dptxstrk.h"

#ifdef TIMING_TEST

extern long dpdiselem_time;
extern long num_polys;
extern long num_2_bsplines;
extern long num_3_bsplines;
extern long num_bspline_surfs;
extern long num_texts;
extern long num_point_sets;

#endif

#if defined( X11 )
extern Display *EXdisplay;
#endif

extern IGRboolean DPdlist_feedback_in_progress;
extern IGRboolean dynamics_in_progress;
static IGRint DPstop_highlight = TRUE;

static WLuint8 DPsemi_solid[8] = 
{ 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA };
 
void DPset_blendarea(
   IGRint win_no,
   IGRint pattern )

{
   if ( pattern == DPSOLID_PATTERN )
   {
      WLset_blendarea( win_no, NULL, TRUE );
   }
   else
   {
      WLset_blendarea( win_no, DPsemi_solid, TRUE );
   }

}  /* DPset_blendarea */

void DPset_texture(
   IGRint win_no,
   IGRint pattern )

{
   if ( pattern == DPSOLID_PATTERN )
   {
      WLset_blendarea( win_no, NULL, FALSE );
   }
   else
   {
      WLset_blendarea( win_no, DPsemi_solid, FALSE );
   }

}  /* DPset_texture */

void DPenable_stop_highlight(
   void )
{
   DPstop_highlight = TRUE;
}  /* DPenable_stop_highlight */

void DPdisable_stop_highlight(
   void )

{
   DPstop_highlight = FALSE;
}  /* DPdisable_stop_highlight */

IGRint DPdiselem( msg, buffer, mode, dp_info )

   IGRint *msg; /* pointer to the return message */
   struct DPele_header *buffer; /* pointer to the buffer	 */
   enum GRdpmode *mode; /* pointer to the display mode  */
   struct DP_information *dp_info;      /* pointer to structure         */

{
   struct IGRdisplay temp_attr;
   IGRint win_no;
   IGRshort type;       /* type of matrix		 */
   IGRdouble depths[2];
   IGRint gpipe_id;
   IGRboolean clip = TRUE;
   IGRint stroke = TRUE;
   IGRint texture;
   int draw_opt;
   IGRint blend;
#if defined( ENV5 )
   IGRint events;
   IGRint button_win, x, y, button, trans, timetag;
#elif defined( X11 )
   XEvent ev;
   enum GRdpmode temp_mode;
#endif

#ifdef TIMING_TEST

   long beg_time, end_time;

   beg_time = clock(  );

#endif

   *msg = MSSUCC;

   if ( dp_info->is_update || ( *mode == GRhd ) || ( *mode == GRhdo ) ||
        ( *mode == GRhhd ) || ( *mode == GRhhdo ) )
   {
      if ( IGEstop(  ) )
      {
         *msg = DPSTOPDRAW;
         goto wrapup;
      }
   }

#if defined( X11 )
   /* erase hilite before doing half-hilite so it looks right */
   if ( ( *mode == GRhhd ) || ( *mode == GRhhdo ) )
   {
      temp_mode = GRhe;
      DPdiselem( msg, buffer, &temp_mode, dp_info );
   }
#endif

/*
 * Change to check for termination of highlight even if update is
 * set.  This is necessary for reference files to terminate the
 * highlight request of objects in a reference file.  (MAS 03/20/89)
 */

   /* added dynamics_in_progress test for WL/DL conversion - S.P. Rogers */
   if ( ( !dynamics_in_progress ) &&
        ( ( *mode == GRhd ) || ( *mode == GRhdo ) ||
          ( *mode == GRhhd ) || ( *mode == GRhhdo ) ) )
   {
#if defined( ENV5 )
      EX_inq_events( &events );
      if ( events & BUTTON_EVENT )
      {
         EX_inq_button_data( &button_win, &x, &y, &button, &trans, &timetag );
         if ( EX_is_button_defined( button, trans ) )
         {
            *msg = DPSTOPDRAW;
            goto wrapup;
         }
         EX_get_button_data( &button_win, &x, &y, &button, &trans, &timetag );
      }
#elif defined( X11 )
      if ( JNL_XCheckMaskEvent( EXdisplay, ButtonPressMask, &ev ) )

      {
         JNL_XPutBackEvent( EXdisplay, &ev );
         *msg = DPSTOPDRAW;
         goto wrapup;
      }
#endif

   }

   if ( buffer->level )
   {
      if ( *buffer->level != 0 )
      {
         stroke = ( ( 1 << ( *buffer->level % 32 ) ) &
                    dp_info->gragad->levels[*buffer->level / 32] );
      }
   }

/* accumulate fit ranges if this is a fit request  */
   if ( stroke && dp_info->is_fit )
   {
      if ( buffer->range )
      {
         if ( buffer->range[0] < dp_info->fit_range[0] )
         {
            dp_info->fit_range[0] = buffer->range[0];
         }

         if ( buffer->range[3] > dp_info->fit_range[3] )
         {
            dp_info->fit_range[3] = buffer->range[3];
         }


         if ( buffer->range[1] < dp_info->fit_range[1] )
         {
            dp_info->fit_range[1] = buffer->range[1];
         }

         if ( buffer->range[4] > dp_info->fit_range[4] )
         {
            dp_info->fit_range[4] = buffer->range[4];
         }

         if ( buffer->range[2] < dp_info->fit_range[2] )
         {
            dp_info->fit_range[2] = buffer->range[2];
         }

         if ( buffer->range[5] > dp_info->fit_range[5] )
         {
            dp_info->fit_range[5] = buffer->range[5];
         }


      } /* end of if (stroke)  */

      stroke = FALSE;

   }    /* end of if (dp_info->is_fit ....)  */

   if ( (stroke) && (buffer->dis_att->color == DP_INVISIBLE_COLOR) )
   {
      stroke = FALSE;
   }

   if ( stroke )
   {

      win_no = dp_info->win_no;
      gpipe_id = dp_info->gragad->gpipe_id;
      type = dp_info->gragad->wld_viewport_type;

      temp_attr = *buffer->dis_att;

      if ( dp_info->is_update &&
           buffer->range &&
           ( !( dp_info->gragad->flags & ( IS_PERSP | DPVIEW_DYNAMICS ) ) ) )
      {
         if ( ( buffer->type != IGRPY ) &&
              ( buffer->type != IGRPS ) &&
              ( ( buffer->type != IGRBC ) ||
                ( buffer->geometry.bspcurve->order != 2 ) ||
                ( buffer->geometry.bspcurve->num_boundaries != 0 ) ) )
         {
            WLuint32 color_ref;

            WLpack_index_colorref( buffer->dis_att->color, &color_ref, FALSE );
            WLset_active_symbology( win_no, color_ref, 0, 0, 0, WL_SYMB_CHANGE_COLOR );

            stroke = DPrngcheck( (IGRlong *)msg, dp_info->gragad, win_no, buffer->range,
                                 &clip );
         }
      }

      if ( dp_info->is_hidden_line && stroke )
      {
         ( *dp_info->hl_tiler ) ( buffer, mode, gpipe_id, &temp_attr, dp_info->gragad,
                                  dp_info->hline_info );
      }
      else if ( stroke )
      {
         /* set DL drawing options based on mode */
         draw_opt = 0;
         blend = 0xFFFFFFFF;
         texture = DPSOLID_PATTERN;
         switch ( *mode )
         {
            case GRbd :
               draw_opt = DL_OPT_BASE_DRAW | DL_OPT_HILITE_NOOP;
               break;
            case GRbe :
               draw_opt = DL_OPT_BASE_ERASE | DL_OPT_HILITE_NOOP;
               break;
            case GRhd : case GRhdo :
               draw_opt = DL_OPT_BASE_NOOP | DL_OPT_HILITE_DRAW;
               texture = DPSEMISOLID_PATTERN;
               break;
            case GRhhd : case GRhhdo:
               draw_opt = DL_OPT_BASE_NOOP | DL_OPT_HILITE_DRAW;
               blend = 0xAAAAAAAA;
               texture = DPSEMISOLID_PATTERN;
               break;
            case GRhe : case GRheo :
               draw_opt = DL_OPT_BASE_NOOP | DL_OPT_HILITE_ERASE;
               break;
            case GRbdhd :
               draw_opt = DL_OPT_BASE_DRAW | DL_OPT_HILITE_DRAW;
               break;
            case GRbehe : case GRbeheo :
               draw_opt = DL_OPT_BASE_ERASE | DL_OPT_HILITE_ERASE;
               break;
            case GRbdhe : case GRbdheo :
               draw_opt = DL_OPT_BASE_DRAW | DL_OPT_HILITE_ERASE;
               break;
            case GRbehd :
               draw_opt = DL_OPT_BASE_ERASE | DL_OPT_HILITE_DRAW;
               break;
         }

         if ( ! DPdlist_feedback_in_progress )
         {
            if ( (buffer->flags & DPPOLY_FILL) && (texture == DPSEMISOLID_PATTERN) )
            {
               /* texture the hilite drawing of filled objects */
               WLset_blendarea( dp_info->win_no, DPsemi_solid, FALSE );
            }
            else
            {
               WLset_blendarea( dp_info->win_no, NULL, FALSE );
            }
         }

         if ( !clip )
         {
            draw_opt |= DL_OPT_DONT_CLIP;
         }

	if( DEget_localplot())
	{
		draw_opt |= DL_OPT_LOCPLOT_MODE;
	}

         /* process the element depending on the element type */
         switch ( buffer->type )
         {
            case IGRBC:     /* B-spline curve */

#ifdef TIMING_TEST
               if ( buffer->geometry.bspcurve->order == 2 )
               {
                  num_2_bsplines++;
               }
               else
               {
                  num_3_bsplines++;
               }
#endif

               DPbcstrk( msg, buffer->geometry.bspcurve,
                         buffer->ele_spec_att.bspcurve,
                         &temp_attr, gpipe_id,
                         win_no, dp_info->gragad->flags,
                         buffer->flags, buffer->u_bound_att,
                         buffer->u_num_bound_att,
                         buffer->u_bound_att_indices,
                         blend, draw_opt );

               break;

            case IGRQS:

#ifdef TIMING_TEST
               num_bspline_surfs++;
#endif

               DPbsqstrk( msg, buffer->geometry.bspsurf,
                          buffer->ele_spec_att.bsqsurf,
                          &temp_attr, gpipe_id,
                          win_no, dp_info->gragad->flags,
                          blend, draw_opt );

               break;

            case IGRPS:     /* point set */

#ifdef TIMING_TEST
               num_point_sets++;
#endif

               depths[0] = dp_info->gragad->dit_clip_range[2];
               depths[1] = dp_info->gragad->dit_clip_range[5];

               DPpsstrk( msg, buffer->geometry.point_set,
                         buffer->ele_spec_att.ptset,
                         &temp_attr,
                         gpipe_id, win_no,
                         (IGRdouble *) dp_info->gragad->wld_to_viewport,
                         type, dp_info->gragad->flags, depths, draw_opt );
               break;


            case IGRPY:     /* polyline	 */

#ifdef TIMING_TEST
               num_polys++;
#endif

               DPpystrk( msg, buffer->geometry.polyline,
                         buffer->ele_spec_att.ptset,
                         &temp_attr,
                         gpipe_id, dp_info->gragad->flags,
                         buffer->flags, blend, draw_opt );
               break;

            case IGRLB:     /* Text */

#ifdef TIMING_TEST
               num_texts++;
#endif

               temp_attr.style = 0;
               DPtxstrk( msg, buffer->geometry.lbsys,
                         buffer->ele_spec_att.text,
                         &temp_attr, win_no,
                         gpipe_id, dp_info->gragad->fnt_os_ptr,
                         dp_info->gragad->flags, buffer->flags,
                         dp_info->gragad->vvol_viewport_scale,
                         0, NULL, NULL, draw_opt );


               break;

            case IGRRG:     /* Raster */

               RSstroke( msg, buffer->geometry.lbsys,
                         buffer->ele_spec_att.raster,
                         &win_no, &type,
                         dp_info->gragad->wld_to_viewport,
                         dp_info->gragad->dit_clip_range );

               break;

            default:        /* Unrecognized element */
               *msg = DPBADELETYP;
               return ( FALSE );

            }   /* end of switch (buffer->type) */

	
      } /* end of else if (...is_hidden_line)  */

   }    /* end of if (stroke) */


wrapup:
#ifdef  TIMING_TEST

   end_time = clock();
   dpdiselem_time += ( end_time - beg_time );
#endif

   return ( TRUE );

}  /* DPdiselem */
