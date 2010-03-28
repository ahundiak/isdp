/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     FUCTION NAME  DPconv_pnt
 
     Abstract:	This method converts a data point from screen dit to
		world coordinate system.
-----
%SC%

	GRdyn_conv_pnt ( msg,pnt,dit_pnt,uor_pnt )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	*pnt	  IGRdouble	point to be converted to the WCS.
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

	*dit_pnt  IGRint	actual dit point

	*uor_pnt  IGRdouble	actual uor point
----
%MD%
     MODULES AND METHODS INVOKED:

     Modules:

     Methods:

-----
%RL%

     RELATIONS REFERENCED :
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:



-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/
 
class implementation IGEgragad;

#include <stdio.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "exdef.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "ex.h"

#include "msdef.h"
#include "msmacros.h"

#include "grmessage.h"
#include "execmsg.h"
#include "griodef.h"

#include "grcoordsys.h"
#include "csdef.h"
#include "exmacros.h"

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "bsparameters.h"
#include "bstypes.h"

/* prototype files */
%safe
#include "dpcvrtpnt.h"
#include "GRdpbfunc.h"

#include "maidmx.h"
#include "mainvmx.h"
#include "maptsxfor.h"
#include "mamulmx.h"
#include "maoptsxfo.h"
#include "bsxtractpar.h"
%endsafe

from  GRcoords import  GRcvt_to_wld_coords;
from  GRcsmgr  import  GRget_acs_info;


%safe
static IGRint (*DPadjust_pnt_function)() = NULL;
%endsafe

IGRint (*DPset_adjust_point_function( new_func ))()

   IGRint (*new_func)();

/*
NAME
	DPset_adjust_point_function

DESCRIPTION
	This function sets a function pointer to an "adjust point"
	function that is called whenver a point is converted.  This
	functionality was requested by DP/Studio.  The specification
	of the "adjust point" function is:

	IGRint adjust_point( IGRdouble orig_dit_pnt[3],
	                     IGRdouble locked_dit_pnt[3],
	                     IGRdouble locked_wld_pnt[3],
	                     IGRdouble vvol_viewport_scale,
	                     IGRshort  wld_to_viewport_type,
	                     IGRdouble wld_to_viewport[16],
	                     IGRdouble viewport_to_wld[16],
	                     IGRint levels[32],
	                     IGRdouble adjusted_dit_pnt[3],
	                     IGRdouble adjusted_wld_pnt[3] )

	orig_dit_pnt (IN) - the original dit point passed into the convert
                            point function
	locked_dit_pnt (IN) - the new dit point calculated by the convert
	                      point function as a result of grid lock; this
	                      parameter will be NULL if unit_lock was used
                              in the convert point function
	locked_wld_pnt (IN) - the world coord point calculateed by the
                              convert point function
	vvol_viewport_scale (IN) - the view volume to viewport scale for
                                   the window converting the point
	wld_to_viewport_type (IN) - the type of the world to viewport matrix
	                            for the window converting the point
	wld_to_viewport (IN) - the world to viewport matrix for the window
	                       converting the point
	viewport_to_wld (IN) - the viewport to world matrix for the window
	                       converting the point
	levels (IN) - the level mask for the window converting the point
	adjusted_dit_pnt (OUT) - the new dit point calculated by the adjust
	                         point function (only valid if the function
                                 returns TRUE)
	adjusted_wld_pnt (OUT) - the new world point calculated by the adjust
	                         point function (only valid if the function
                                 returns TRUE)

PARAMETERS
	new_func (IN) - the function pointer

GLOBALS USED
	DPadjust_pnt_function (static) - static space for function
                                         pointer

RETURN VALUES
	The previous value of the function pointer is returned.

HISTORY
	11/30/92    S.P. Rogers
	   Creation Date
*/

   {
   IGRint (*old_func)();

   old_func = DPadjust_pnt_function;
   DPadjust_pnt_function = new_func;
   return( old_func );
   }  /* DPset_adjust_point_function */


IGRint DPconv_pnt (	IGRlong			*msg,
			struct DPgra_gad 	*wn,
			IGRdouble 		*point, 
			IGRint			*dit_pnt,
			IGRboolean		*valid_point,
			GRspacenum		osnum )
{

    struct GRid   ActiveCoordinateGrid, CSmanagerGrid;

    IGRlong 	num_points;
    IGRlong 	status;
    IGRdouble	temp;
    IGRlong	one = 1;
    IGRshort	four = 4;
    IGRdouble 	tmp_point[3];
    IGRdouble 	global_origin[3];
    IGRdouble 	dit_gbl_org[3];
    IGRdouble 	grid_delta_x;
    IGRdouble 	grid_delta_y;	
    IGRdouble 	const_rot[16];	
    IGRdouble 	inv_rot[16];	
    IGRdouble 	tran_mtx[16];	
    IGRdouble 	tmp_mtx[16];	
    IGRdouble 	final_mtx[16];	
    IGRdouble 	const_org[3];	
    IGRdouble 	uor_per_grid_x;
    IGRdouble 	uor_per_grid_y;
    IGRboolean  used_grid = FALSE;
    struct GRunit_lock  unit_lock;
    IGRlong	i;    
    IGRlong	unit_msg;
    IGRchar	cs_type[MAX_CS_TYPE];
    OM_S_OBJID	mod_id;
    IGRboolean	used_unit_lock = FALSE;
    IGRdouble	orig_dit_pnt[3], locked_dit_pnt[3], adjusted_dit_pnt[3];
    IGRdouble	adjusted_wld_pnt[3];
	BSrc rc;
	IGRdouble dist_tol;
   


	*valid_point = TRUE;

	orig_dit_pnt[0] = point[0];
	orig_dit_pnt[1] = point[1];
	orig_dit_pnt[2] = point[2];

#ifndef IDRAW
	gr$get_unit_lock ( buffer =  (IGRchar *)&unit_lock);
#else
  	unit_lock.on_off = 0;

#endif /* IDRAW  */

	if ( (wn->flags & GRID_LOCK) || unit_lock.on_off )
	{ 
/*unit lock or grid lock is on we must get the active coord objid*/

    /* get the GRid of the GRcsmgr  */

	   ex$get_modid(mod_osnum = osnum,
			mod_id = &mod_id);

	   ex$get_super(mod_id = mod_id,
			mod_osnum = osnum,
			super_name = CoordSysMgr,
			create = TRUE,
			super_class = CoordSysMgrClass,
			super_id = &CSmanagerGrid.objid,
			super_osnum = &CSmanagerGrid.osnum);

	   gr$get_cs_type ( buffer = cs_type);


	   status = om$send(	msg = message GRcsmgr.GRget_acs_info( &unit_msg,
					NULL,NULL,NULL,NULL,NULL,NULL,NULL,
					&ActiveCoordinateGrid),
				senderid = NULL_OBJID,
				targetid = CSmanagerGrid.objid,
				targetos = CSmanagerGrid.osnum); 

	   if ( !status )
           {
#ifdef DEBUG
               printf ( "\nDPcvtpnt get active coodinate system." );
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
	}  

	if ( wn->flags & GRID_LOCK )
	{	/* need to snap to grid */
	   used_grid = TRUE;

	   if (!(wn->flags & VALID_ALT_INV))
	   {
	      

	      status = MAoptsxform(msg, &one, &wn->wld_viewport_type,
				(IGRdouble *)wn->wld_to_viewport,
				global_origin, dit_gbl_org);
	      if (!(status & 1))
	      {
	         goto finish;
	      }



	      grid_delta_x = (wn->uor_per_ref_x/wn->grid_per_ref_x) *
					wn->vvol_viewport_scale;

	      grid_delta_y = (wn->uor_per_ref_y/wn->grid_per_ref_y) *
					wn->vvol_viewport_scale;

	      temp = (dit_gbl_org[0]  - point[0] ) / grid_delta_x;
	      point[0] = dit_gbl_org[0]- (dpround(temp) * grid_delta_x);

	      temp = (dit_gbl_org[1] - point[1]) / grid_delta_y;
	      point[1] =  dit_gbl_org[1] - (dpround(temp) * grid_delta_y);

	   }
	   else
	   {


	      OM_BLOCK_MOVE( wn->construct_plane,
                          const_rot,
                          sizeof(IGRdouble)*16);

	   
	      const_org[0] = const_rot[3];
	      const_org[1] = const_rot[7];
	      const_org[2] = const_rot[11];

	      const_rot[3] = 0;
	      const_rot[7] = 0;
	      const_rot[11] = 0;

	      MAinvmx(msg,&four,const_rot,inv_rot);

	      MAidmx(msg,tran_mtx);

	      tran_mtx[3] = - (const_org[0]);
	      tran_mtx[7] = - (const_org[1]);
	      tran_mtx[11] = - (const_org[2]);

	      MAmulmx(msg, &four, &four, &four, const_rot, tran_mtx, tmp_mtx);

	      MAmulmx(msg, &four, &four, &four, tmp_mtx,
			(IGRdouble *)wn->alt_vwport_to_wld, final_mtx);

	      MAptsxform(msg, &one, final_mtx, point, point);

	      uor_per_grid_x = wn->uor_per_ref_x/wn->grid_per_ref_x;
	      uor_per_grid_y = wn->uor_per_ref_y/wn->grid_per_ref_y;

	      point[0] = dpround(point[0] /uor_per_grid_x);
	      point[0] *= uor_per_grid_x;

	      point[1] = dpround(point[1] /uor_per_grid_y);
	      point[1] *= uor_per_grid_y;

	      tran_mtx[3] = const_org[0];
	      tran_mtx[7] = const_org[1];
	      tran_mtx[11] = const_org[2];	

	      MAmulmx(msg,&four, &four, &four, (IGRdouble *)wn->wld_to_viewport,
			tran_mtx, tmp_mtx);

	      MAmulmx(msg,&four,&four,&four,tmp_mtx,inv_rot,final_mtx);
	
	      MAptsxform(msg,&one,final_mtx,point,point);
	   }

	}
			
	num_points = 1;
 
	locked_dit_pnt[0] = point[0];
	locked_dit_pnt[1] = point[1];
	locked_dit_pnt[2] = point[2];

	dit_pnt[0] = dpround(point[0]);
	dit_pnt[1] = dpround(point[1]);

	if (wn->flags & VALID_ALT_INV)
	{
	   status = MAptsxform ( msg, &num_points, (IGRdouble *)wn->alt_vwport_to_wld, 
				point, point);

/*
 * Removed the check to see if the point was outside view volume.
 * pp10/07/91
 */
	   if ((wn->flags & FRONT_CLIP) || (wn->flags & BACK_CLIP))
	   {
	      status = MAptsxform(msg, &num_points, (IGRdouble *)wn->wld_to_view,
				 point, tmp_point);


/*
	      if (wn->flags & FRONT_CLIP)
	      {
		 if (tmp_point[2] > wn->vw_volume[2])
		 {
		    *valid_point = TRUE;
		 }
		 else
		 {
		    *valid_point = FALSE;
		 }
	      }

	      if ((wn->flags & BACK_CLIP) && *valid_point)
	      {
		 if (tmp_point[2] < wn->vw_volume[5])
		 {
		    *valid_point = TRUE;
		 }
		 else
		 {
		    *valid_point = FALSE;
		 }
	      }
*/
	   }	

	}
	else
	{
	   status = MAptsxform ( msg, &num_points, (IGRdouble *)wn->viewport_to_wld, 
				point, point);
	}

	if ( !(status & 1) )
	{
#ifdef DEBUG
	    printf ( "\nGRwnscn2dgn> error in transformation." );
#endif
	}


        if ( !used_grid && *valid_point)  /*if grid lock off check unit lock*/
        {
           if ( unit_lock.on_off )
           {
                                   
	      used_unit_lock = TRUE;
              for ( i = 0 ; i < 3 ; ++i )
              {
                 point[i] = point[i] - global_origin[i];
                 point[i] = dpround(point[i] /unit_lock.round_off);
                 point[i] *= unit_lock.round_off;
                 point[i] += global_origin[i];
              }/*end for */
           }/*end unit lock*/
        }/*grid lock used*/

	/* Call the adjust point function, if defined         */
	/* This functionality added for DP/Studio on 11/30/92 */
	if ( DPadjust_pnt_function )
	{
	   if ( (*DPadjust_pnt_function)( orig_dit_pnt,
	                                  (used_unit_lock) ? NULL : locked_dit_pnt,
                                          point,
	                                  wn->vvol_viewport_scale,
	                                  wn->wld_viewport_type,
	                                  wn->wld_to_viewport,
	                                  wn->viewport_to_wld,
	                                  wn->levels,
	                                  adjusted_dit_pnt,
	                                  adjusted_wld_pnt ) )
	   {
           /* the point was adjusted => use new values */
	   dit_pnt[0] = dpround(adjusted_dit_pnt[0]);
	   dit_pnt[1] = dpround(adjusted_dit_pnt[1]);

           point[0] = adjusted_wld_pnt[0];
           point[1] = adjusted_wld_pnt[1];
           point[2] = adjusted_wld_pnt[2];
           }
	   
	}
	BSxtractpar( &rc, BSTOLLENVEC,  &dist_tol );
	if ( point[0]>-dist_tol && point[0]<dist_tol ) 
	{
		point[0]=0.0;
	}
	if ( point[1]>-dist_tol && point[1]<dist_tol ) 
	{
		point[1]=0.0;
	}
	if ( point[2]>-dist_tol && point[2]<dist_tol ) 
	{
		point[2]=0.0;
	}

finish:
    return ( status );
}

end implementation IGEgragad;
