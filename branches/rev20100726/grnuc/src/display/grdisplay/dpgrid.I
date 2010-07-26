/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

        MODULE NAME - DPgrid 
 
        Abstract: This method draws regular grid

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *wn         struct DPwindow        window structure

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg           IGRlong      MSSUCC -- successful completion


-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

        HT  04/28/86  : Creation date.
        TF  08/11/94  : Code was referencing mypnts[1].y when it
                        should have been referencing mypnts[0].y
                        Tim Fox
--
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/
class implementation IGEgragad;

#include <stdlib.h>
#include <stdio.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMerrordef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "msdef.h"
#include "griodef.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "exmacros.h"
#include "igewinmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

#include "wl.h"

#include "igecolordef.h"

/* prototype files */
%safe
#include "dpgrid.h"
#include "GRdpbfunc.h"

#include "maoptsxfo.h"
%endsafe


from  GRcoords import  GRcvt_to_wld_coords;
from  GRcsmgr  import  GRget_acs_info;


IGRint  DPgrid (msg,wn, win_no, min_x, min_y, max_x, max_y)

    IGRlong             *msg;
    struct DPgra_gad    *wn;
    IGRint              win_no;
    IGRint              min_x;
    IGRint              min_y;
    IGRint              max_x;
    IGRint              max_y;

     {

   IGRlong             status = OM_S_SUCCESS;
   IGRdouble           xstart,ystart;
   IGRdouble           global_origin[3];
   IGRdouble           dit_gbl_org[3];
   IGRdouble           grid_delta_x;   /* distance between 2 grid dot/ref in dits */
   IGRdouble           grid_delta_y;
   IGRdouble           temp,ytemp,xtemp;
   IGRlong             one = 1;

   struct GRid         ActiveCoordinateGrid, CSmanagerGrid;
   struct GRunit_lock  unit_lock;
   IGRint              size;
   IGRlong             unit_msg;
   IGRchar             cs_type[MAX_CS_TYPE];
   OM_S_OBJID          mod_id;

   struct WLpoint	mypnts[2];
   WLcolorref		color_ref;

        *msg = MSSUCC;

/* adjust area that needs to be updated because of floating point error */

	min_x--;
	min_y--;
	max_x++;
	max_y++;
#ifndef IDRAW
	size = sizeof (struct GRunit_lock);

	gr$get_unit_lock ( buffer = (IGRchar *)&unit_lock);
#endif

#if defined( ENV5 )
    unit_lock.on_off = 0;
#endif

    /* get the GRid of the GRcsmgr  */

	   ex$get_modid(mod_osnum = OM_Gw_current_OS,
			mod_id = &mod_id);

	   ex$get_super(mod_id = mod_id,
			mod_osnum = OM_Gw_current_OS,
			super_name = CoordSysMgr,
			create = TRUE,
			super_class = CoordSysMgrClass,
			super_id = &CSmanagerGrid.objid,
			super_osnum = &CSmanagerGrid.osnum);
 


	   size = MAX_CS_TYPE;
	   gr$get_cs_type ( buffer = (IGRchar *)cs_type);
	   status = om$send(	msg = message GRcsmgr.GRget_acs_info( &unit_msg,
					NULL,NULL,NULL,NULL,NULL,NULL,NULL,
					&ActiveCoordinateGrid),
				senderid = NULL_OBJID,
				targetid = CSmanagerGrid.objid,
				targetos = CSmanagerGrid.osnum); 

	   if ( !status )
           {
#ifdef DEBUG
               printf ( "\nDPgrid get active coodinate system." );
#endif
           }



       /*
        *  ----------------------------------------------------
        *     Convert the rectangular xyz coordinates 0,0,0
        *            to the Active Coordiante Sytems 
        *  ----------------------------------------------------
        */

	global_origin[0] = 0.0;
	global_origin[1] = 0.0;
	global_origin[2] = 0.0;


          status = om$send( 
                       senderid = NULL_OBJID,
                       msg = message GRcoords.GRcvt_to_wld_coords(
                                               &unit_msg,
                                               cs_type,
					       1,
                                               global_origin,
                                               global_origin ),


                       targetos = ActiveCoordinateGrid.osnum,
                       targetid = ActiveCoordinateGrid.objid );
           if ( !status )
           {
#ifdef DEBUG
               printf ( "\nDPcvtpnt get world coordinate point." );
#endif
           }


        if(!(status = MAoptsxform(msg,&one,&wn->wld_viewport_type,
                        	  (IGRdouble *)wn->wld_to_viewport,
				  global_origin, dit_gbl_org)))
        {
           goto wrapup;
        }

	if ( wn->flags & GRID_ON )
	{
           WLpack_index_colorref( IGE_LOGICAL_HILITE, &color_ref, FALSE );
	}
	else
	{
           WLpack_index_colorref( IGE_LOGICAL_BACKGROUND, &color_ref, FALSE );
	}

	WLset_active_symbology( win_no, color_ref, DP_SOLID_LINE_STYLE, 0xFFFF, 0,
	          WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_STYLE | WL_SYMB_CHANGE_WEIGHT );

        grid_delta_x = (wn->uor_per_ref_x/wn->grid_per_ref_x) *
                                        wn->vvol_viewport_scale;

        grid_delta_y = (wn->uor_per_ref_y/wn->grid_per_ref_y) *
                                        wn->vvol_viewport_scale;

        if ((grid_delta_x >= MIN_GRID_DELTA) && 
             (grid_delta_y >= MIN_GRID_DELTA) )
        {
                WLhide_cursor( win_no, TRUE );

                temp = (dit_gbl_org[0] - min_x) / grid_delta_x;
                xstart = (dit_gbl_org[0] - min_x) - ((IGRint)(temp) *
                         grid_delta_x);
		
		if (xstart < 0)
		{
		   xstart = min_x + (grid_delta_x + xstart);
		}
		else
		{
		   xstart += min_x;
		}

                
                temp = (dit_gbl_org[1]- min_y) /grid_delta_y;
                ystart = (dit_gbl_org[1] - min_y) - ((IGRint)(temp) *
                         grid_delta_y);

		if (ystart < 0)
		{
		   ystart = min_y + (grid_delta_y + ystart);
		}
		else
		{
		   ystart += min_y;
		}


                ytemp = ystart;
#ifdef DEBUG
                printf ( "\nxstart = %f\nystart = %f", xstart, ystart );
#endif
                while ( ytemp <= (IGRdouble) max_y )
                {
                        xtemp = xstart;
                        while ( (xtemp <= (IGRdouble) max_x ) )
                        {
			    mypnts[0].x = (xtemp + 0.5);
                            mypnts[0].y = (ytemp + 0.5);
	                    WLdraw_2D_point_string( win_no, 1, mypnts );
                            xtemp += grid_delta_x;
                        }
                        ytemp += grid_delta_y;
                }

                WLshow_cursor( win_no );
                WLflush( win_no );
        }

        grid_delta_x *= wn->grid_per_ref_x;
        grid_delta_y *= wn->grid_per_ref_y;

        if ((grid_delta_x >= MIN_REF_DELTA) && 
            (grid_delta_y >= MIN_REF_DELTA) )
        {
                WLhide_cursor( win_no, TRUE );


                temp = (dit_gbl_org[0] - min_x)  / grid_delta_x;
                xstart = (dit_gbl_org[0] - min_x) - 
				((IGRint) temp * grid_delta_x);

		if (xstart < 0)
		{
		   xstart = min_x + (grid_delta_x + xstart);
		}
		else
		{
		   xstart += min_x;
		}

                
                if ((xstart - grid_delta_x + 3) > (IGRdouble) min_x) 
                {
                          xstart -= grid_delta_x;
                }
                temp = (dit_gbl_org[1] - min_y) / grid_delta_y;
                ystart = (dit_gbl_org[1] - min_y) - 
				((IGRint) temp * grid_delta_y);

		if (ystart < 0)
		{
		   ystart = min_y + (grid_delta_y + ystart);
		}
		else
		{
		   ystart += min_y;
		}



                if ((ystart - grid_delta_y + 3) > (IGRdouble) min_y ) 
                {
                        ystart -= grid_delta_y;
                }       
                ytemp = ystart;
#ifdef DEBUG
                printf ( "\nxstart = %f\nystart = %f", xstart, ystart );
#endif
                while ( ytemp - 3.0 <= (IGRdouble) max_y)
                {
                        xtemp = xstart;
                        while ( xtemp - 3.0 <= (IGRdouble) max_x)
                        {
                           mypnts[0].x = (xtemp + 0.5) + 3;
                           mypnts[0].y = (ytemp + 0.5);
                           mypnts[1].x = (xtemp + 0.5) - 3;
                           mypnts[1].y = (ytemp + 0.5);
	                   WLdraw_2D_line_string( win_no, 2, mypnts );

                           mypnts[0].x = (xtemp + 0.5);
                           mypnts[0].y = (ytemp + 0.5) + 3;
                           mypnts[1].x = (xtemp + 0.5);
                           mypnts[1].y = (ytemp + 0.5) - 3;
	                   WLdraw_2D_line_string( win_no, 2, mypnts );

                           xtemp += grid_delta_x;
                        }
                        ytemp += grid_delta_y;
                }
                WLshow_cursor( win_no );
                WLflush( win_no );
             }
wrapup:

        return (status);

       }

end implementation IGEgragad;
