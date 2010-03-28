/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     IGEgragad
        METHOD NAME:    movicon

        Abstract:
                This method will handle window move icon .
                (move window, stretch window, stretch and move window)
-----
%SC%

        VALUE = movicon (*msg, *win_no,*flag,*minx,*miny,*maxx,*maxy)

-----
%EN%

        ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
      *win_no      IGRint        pointer to logical window number
      *flag        IGRint        flag = 0 move, 1 stretch, 2 stretch+move
      *minx        IGRint
      *miny        IGRint
      *maxx        IGRint
      *maxy        IGRint

-----
%EX%

        ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg         IGRlong         return condition code
-----
%RL%

        RELATIONS REFERENCED:


-----
%NB%

        NOTES:

-----
%CH%

        CHANGE HISTORY

        HT   04/29/86  : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
         This method will update window size information in instance
         data and send update message to self.
----*/
/*EH*/


class implementation IGEgragad;

#include <stdio.h>

#include "grimport.h"
#include "wl.h"
#include "dl.h"

#include "dpmacros.h"

/* prototype files */
#include "maptsxfor.h"
#include "DPcal.h"

method movicon(
   IGRlong *msg;
   IGRint *win_no;
   IGRint *flag;
   IGRint *minx;
   IGRint *miny;
   IGRint *maxx;
   IGRint *maxy )

   {

   IGRlong status;
   IGRdouble temp[16];
   IGRint new_flag;
   IGRint old_x_min;
   IGRint old_y_min;
   IGRint old_x_max;
   IGRint old_y_max;
   IGRlong num_points = 2;
   OM_S_CHANSELECT chandef;


   status = OM_S_SUCCESS;


#if defined( ENV5 )
/* take changed vs bit out to see what happened  */
   if ( wn_changed_vs( *flag ) )
   {
      if ( ME.IGEgragad->gragad.flags & IS_ACTIVE )
      {
         ME.IGEgragad->gragad.flags ^= DPLEFT_SCREEN;
      }

      /* logical window number has changed => store */
      /* new one and tell DL about it               */
      me->win_no = *win_no;

      DLupdate_windowing_data( me->gragad.gpipe_id, me->win_no );
   }
   new_flag = *flag & ~WN_CHANGED_VS;
#else
   new_flag = *flag;
#endif


   switch ( new_flag )       /* */
   {
      case 0:     /* move only  */
      case 3:     /* move only but tools do not have the memory map */
                  /* can not redraw automatically                   */

         /* was off screen, was covered , is covered of changed screens */
         if ( new_flag == 3 )
         {

#if defined( ENV5 )
            status = dp$gen_update( msg = msg,
                                    osnum = OM_Gw_current_OS,
                                    objid = my_id );
            if ( !( 1 & status ) )
            {
#ifdef DEBUG
               om$report_error( sts = status );
               printf( "Error: in wn move icon send to IGEgragad.DPupdate\n" );
#endif
               goto wrapup;
            }
#endif

         }
                   break;

      case 1:       /* stretch only */

         ME.IGEgragad->gragad.dit_clip_range[0] = ( *maxx - *minx ) *
            ME.IGEgadget->min_x_indep;
         ME.IGEgragad->gragad.dit_clip_range[1] = ( *maxy - *miny ) *
            ME.IGEgadget->min_y_indep;

         ME.IGEgragad->gragad.dit_clip_range[3] = ( *maxx - *minx ) *
            ME.IGEgadget->max_x_indep;
         ME.IGEgragad->gragad.dit_clip_range[4] = ( *maxy - *miny ) *
            ME.IGEgadget->max_y_indep;

         chandef.type = OM_e_name;
         chandef.u_sel.name = "to_parent";

         om$send( msg = message IGEgadget.dep_extents( msg, &old_x_min,
                                    &old_y_min, &old_x_max, &old_y_max ),
                  p_chanselect = &chandef );

         /* get new window min max relative to old window */

         temp[0] = ( ( ( *maxx - *minx ) * ME.IGEgadget->min_x_indep ) + *minx ) -
            ( ( ( old_x_max - old_x_min ) * ME.IGEgadget->min_x_indep ) + old_x_min );

         temp[1] = ( ( ( *maxy - *miny ) * ME.IGEgadget->min_y_indep ) + *miny ) -
            ( ( ( old_y_max - old_y_min ) * ME.IGEgadget->min_y_indep ) + old_y_min );

         temp[2] = ME.IGEgragad->gragad.act_z_screen;

         temp[3] = ( ( ( *maxx - *minx ) * ME.IGEgadget->max_x_indep ) + *minx ) -
            ( ( ( old_x_max - old_x_min ) * ME.IGEgadget->min_x_indep ) + old_x_min );

         temp[4] = ( ( ( *maxy - *miny ) * ME.IGEgadget->max_y_indep ) + *miny ) -
            ( ( ( old_y_max - old_y_min ) * ME.IGEgadget->min_y_indep ) + old_y_min );


         temp[5] = ME.IGEgragad->gragad.act_z_screen;

         if ( !MAptsxform( msg, &num_points, (IGRdouble *) ME.IGEgragad->gragad.viewport_to_wld, temp, temp ) )
         {
            goto wrapup;
         }

         if ( !MAptsxform( msg, &num_points, (IGRdouble *) ME.IGEgragad->gragad.wld_to_view, temp, temp ) )
         {
            goto wrapup;
         }

         /* update view volume note:   view volume is LL to UR */
         ME.IGEgragad->gragad.vw_volume[0] = temp[0];
         ME.IGEgragad->gragad.vw_volume[1] = temp[4];

         ME.IGEgragad->gragad.vw_volume[3] = temp[3];
         ME.IGEgragad->gragad.vw_volume[4] = temp[1];

         ME.IGEgadget->min_x_dep = ( *maxx - *minx ) * ME.IGEgadget->min_x_indep;
         ME.IGEgadget->min_y_dep = ( *maxy - *miny ) * ME.IGEgadget->min_y_indep;
         ME.IGEgadget->max_x_dep = ( *maxx - *minx ) * ME.IGEgadget->max_x_indep;
         ME.IGEgadget->max_y_dep = ( *maxy - *miny ) * ME.IGEgadget->max_y_indep;

         /* update vvol to viewport scale and all matrices */
         status = dp$calc_gragad_info( msg = msg,
                                       osnum = OM_Gw_current_OS,
                                       gragad_objid = my_id );

         if ( !( 1 & status ) )
         {
#ifdef DEBUG
            om$report_error( sts = status );
            printf( "Error: in wn move icon send to GRwn.GRwncal\n" );
#endif
            goto wrapup;
         }

         /* update */
#if defined( ENV5 )
         status = dp$gen_update( msg = msg,
                                 osnum = OM_Gw_current_OS,
                                 objid = my_id );
         if ( !( 1 & status ) )
         {
#ifdef DEBUG
            om$report_error( sts = status );
            printf( "Error: in wn move icon send to GRwn.GRupdate\n" );
#endif
            goto wrapup;
         }
#endif

         break;

      case 2:       /* stretch and move */

         ME.IGEgadget->min_x_dep = ( *maxx - *minx ) *
            ME.IGEgadget->min_x_indep;

         ME.IGEgadget->min_y_dep = ( *maxy - *miny ) *
            ME.IGEgadget->min_y_indep;

         ME.IGEgadget->max_x_dep = ( *maxx - *minx ) *
            ME.IGEgadget->max_x_indep;

         ME.IGEgadget->max_y_dep = ( *maxy - *miny ) *
            ME.IGEgadget->max_y_indep;

         /* update vvol to viewport scale and all matrices */
         status = dp$calc_gragad_info( msg = msg,
                                       osnum = OM_Gw_current_OS,
                                       gragad_objid = my_id );

         if ( !( 1 & status ) )
         {
#ifdef DEBUG
            om$report_error( sts = status );
            printf( "Error: in wn move icon send to GRwn.DPcal\n" );
#endif
            goto wrapup;
         }

         /* update */
#if defined( ENV5 )
         status = dp$gen_update( msg = msg,
                                 osnum = OM_Gw_current_OS,
                                 objid = my_id );
         if ( !( 1 & status ) )
         {
#ifdef DEBUG
            om$report_error( sts = status );
            printf( "Error: in wn move icon send to GRwn.DPupdate\n" );
#endif
            goto wrapup;
         }
#endif

         break;

      default:
         break;
   }

wrapup:
   return ( status );

   }

end implementation IGEgragad;
