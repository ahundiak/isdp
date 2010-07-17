/* $Id: VRppdynamic.I,v 1.2 2002/04/10 20:33:30 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch / VRppdynamic.I
 *
 * Description:
 *	dynamic display of a pipe segment.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRppdynamic.I,v $
 *	Revision 1.2  2002/04/10 20:33:30  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/04/10  14:59:48  pinnacle
# Replaced: vrsketch/VRppdynamic.I for:  by lawaddel for route
#
# Revision 1.3  1998/03/20  21:24:02  pinnacle
# Replaced: vrsketch/VRppdynamic.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/19  15:10:04  pinnacle
# Replaced: vrsketch/VRppdynamic.I for:  by r240_int for route240
#
 *
 * History:
 *	02/11/89	momo	Design Date
 *	01/15/96	tlb	Add prototypes, 
 *				Change VRline_params,  VRlinedyn to static
 *	03/06/98	law	TR179700988 - prevent sketching from wrong end
 *				of nozzle.
 *      04/09/98        law     TR179702549 - fixed wrongway dynamics.
 *      04/08/02        law     TR5649-standardize tolerance with VRGetTol
 *************************************************************************/

class implementation Root;

#include <math.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "gr.h"
#include "igr.h"
#include "bsparameters.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "VRsketchdef.h"
#include "VRMath.h"
#include "bsvalues.h"
#include "bserr.h"
#include "AS_status.h"
#include "vrtools_pto.h"
#include "bscrossp.h"
#include "bsmkvec.h"
#include "bsdotp.h"

#define AS_DEBUG


static struct VRline_params 
{
  IGRint		  	action;
  IGRdouble	          	*prev_pt;
  IGRdouble	           	*first_pt;
  IGRdouble	           	*Z_Window;
  IGRint		   	NbOfImpDirection;
  IGRdouble		   	*imp_direct;
  IGRdouble		   	angle;
  IGRboolean		   	*angle_flag;
  IGRboolean	           	*orthogonal_sketch;
  IGRboolean		   	is_connect;
  struct  	DPele_header    *header_line;
  IGRint			CompType; /* Added for TR179600988 */
  IGRdouble			*cmpmatrix;
};

from	 GRcoords 	import 	GRcvt_to_lcl_coords;
from 	 GRcoords 	import 	GRcvt_to_wld_coords;

from 	VRGeneric 	import 	VRGetSysType;

/*************************************************************************/

static
IGRint VRlinedyn( VRinfo,point,matrix,objects,num_objects,buffers,num_buffers,
                  dummy_in1,dummy_in2,dummy_in3,dummy_out1,dummy_out2,
                  dummy_out3 )

struct 		VRline_params	*VRinfo;
struct 		EX_button      	*point;
IGRdouble                   	*matrix;
struct 		GRid           	**objects;
IGRint                     	*num_objects;
struct 		DPele_header  	**buffers;
IGRint                       	*num_buffers;
IGRchar                      	*dummy_in1;
IGRchar                      	*dummy_in2;
IGRchar                      	*dummy_in3;
IGRchar                      	**dummy_out1;
IGRchar                      	**dummy_out2;
IGRchar                      	**dummy_out3;

/*.VRlinedyn */
{
  IGRint	i;         	/* loop index                   */
  IGRint	status;    	/* return code                  */
  IGRint	IsValidPoint;	/* return code                  */
  IGRdouble     projpt[3]; 	/* projection of the next point */
  IGRdouble	vector0[3], vector1[3], vector2[3], normal[3];
  IGRdouble 	free_angle, VRcompute_angle();
  IGRdouble	unite;
  IGRdouble dVectDotProd;       /* TR179702549 */
  IGRmatrix     ref_matrix;
  IGRlong	rc,retcode;

  unite = M_PI / 180;

  VRinfo->Z_Window[0] = matrix[8];
  VRinfo->Z_Window[1] = matrix[9];
  VRinfo->Z_Window[2] = matrix[10];

  VRinfo->header_line->dis_att->weight = 0;
  VRinfo->header_line->dis_att->style = 0;

  if( *VRinfo->orthogonal_sketch )
  {
    	VRget_project_pt( VRinfo->first_pt, &point->x, projpt, &matrix[8],
                      	  (VRinfo->is_connect) ? VRinfo->imp_direct : NULL );

        /* TR179600988 sketch one way from nozzle */
        /** Note that the nozzle test is in the orthogonal section */
        if(VRinfo->CompType == IS_NOZZLE)
        {

            BSmkvec( &retcode, vector1, VRinfo->first_pt, projpt );

            vector0[0] = VRinfo->cmpmatrix[0];
            vector0[1] = VRinfo->cmpmatrix[4];
            vector0[2] = VRinfo->cmpmatrix[8];

            dVectDotProd = BSdotp(&retcode, vector0,vector1 );

            /* If the dot product of the two vectors is positive then they're heading
            the same direction. */
            if( dVectDotProd < VRGetTol(VR_DOTPROD_TOL) )
            {
               for(i=0; i<3; i++ )
               {
                  projpt[i] = VRinfo->first_pt[i];
               }
               point->x = VRinfo->first_pt[0];
               point->y = VRinfo->first_pt[1];
               point->z = VRinfo->first_pt[2];
            }
        }
  }
  else
  {
    	projpt[0] = point->x;
    	projpt[1] = point->y;
    	projpt[2] = point->z;

    	if (( VRinfo->first_pt[0] == VRinfo->prev_pt[0] ) &&
	    ( VRinfo->first_pt[1] == VRinfo->prev_pt[1] ) &&
	    ( VRinfo->first_pt[2] == VRinfo->prev_pt[2]))
	{  	
        	VRinfo->prev_pt[0] = VRinfo->first_pt[0] - VRinfo->imp_direct[0];
		VRinfo->prev_pt[1] = VRinfo->first_pt[1] - VRinfo->imp_direct[1];
      		VRinfo->prev_pt[2] = VRinfo->first_pt[2] - VRinfo->imp_direct[2];
  	}

   	if ( *VRinfo->angle_flag == TRUE )
   	{ 
   		VRskdisplay_angle
			( VRinfo->angle, VRinfo->prev_pt, VRinfo->first_pt, projpt, VRinfo->Z_Window );

      		VRinfo->header_line->dis_att->weight = 1;
      		VRinfo->header_line->dis_att->style  = 3;
   	}
   	else
   	{
   		for (i =0; i<3; i++)
     		{
     			vector1[i] = VRinfo->first_pt[i] - VRinfo->prev_pt[i];
     			vector2[i] = projpt[i] - VRinfo->first_pt[i];
     		}

   		if( vector1[0] || vector1[1] || vector1[2] )
   		{
   			BScrossp ( &rc, vector1, vector2, normal);
   			free_angle = VRcompute_angle(vector1,vector2,normal);
   			if (free_angle <= unite)
     		  	{
     			  	free_angle = 0;
     			  	VRskdisplay_angle
					( free_angle, VRinfo->prev_pt, VRinfo->first_pt,
					  projpt, VRinfo->Z_Window
                       		        ); 
     				VRinfo->header_line->dis_att->weight = 1;
     				VRinfo->header_line->dis_att->style = 3;
     			}

   			if((free_angle <= ((M_PI/2) + unite)) && (free_angle >= ((M_PI/2) - unite)))
     			{
     				free_angle = M_PI/2;
     				VRskdisplay_angle
				(free_angle,VRinfo->prev_pt,VRinfo->first_pt,projpt,VRinfo->Z_Window);

     				VRinfo->header_line->dis_att->weight = 1;
     				VRinfo->header_line->dis_att->style = 3;
     			}    
   		}
  	}
  }
  status = VRis_next_pt_valid( VRinfo->action,
			       &IsValidPoint,
                               VRinfo->prev_pt,
                               VRinfo->first_pt,
                               projpt,
			       VRinfo->NbOfImpDirection,			
                               VRinfo->imp_direct );
  if( status & IS_A_VALID_POINT & IsValidPoint )
  {
     /* ADDED FOR TR179702549 */
     if((VRinfo->CompType != IS_NOZZLE) && (VRinfo->CompType != FREE_SPACE) &&
        (VRinfo->CompType != IS_PIPE) && (VRinfo->CompType != IS_UNDEFINED) &&
        (VRinfo->CompType != IS_DANGLING))
     {
        BSmkvec( &retcode, vector1, VRinfo->first_pt, projpt );

        vector0[0] = VRinfo->imp_direct[0];
        vector0[1] = VRinfo->imp_direct[1];
        vector0[2] = VRinfo->imp_direct[2];
        dVectDotProd = BSdotp(&retcode, vector0,vector1 );
        /* If the dot product of the two vectors is positive then they're
           heading the same direction. */
        for(i=0; i<3; i++ )
        {
           VRinfo->header_line->geometry.polyline->points[i]   =
                                                           VRinfo->first_pt[i];
           if( dVectDotProd < VRGetTol(VR_DOTPROD_TOL) )
           {
              VRinfo->header_line->geometry.polyline->points[i+3] =
                                                            VRinfo->first_pt[i];
           }
           else
           {
              VRinfo->header_line->geometry.polyline->points[i+3] = projpt[i];
           }
        }
     }
     else
     {
        for(i=0; i<3; i++ )
        {
           VRinfo->header_line->geometry.polyline->points[i]   =
                                                       VRinfo->first_pt[i];
           VRinfo->header_line->geometry.polyline->points[i+3] = projpt[i];
        }
     }
  }
  else
  {
    *num_buffers = 0;
    return(TRUE);
  }
    
  *buffers     = VRinfo->header_line;
  *num_buffers = 1;

  return(TRUE);
}

/****************************************************************************/

IGRlong VRrblinear( action, prev_pt, first_pt, Z_Window, NbOfImpDirection,
                    imp_direct, orthogonal_sketch, display ,angle, angle_flag,
                    is_connect,CompType,cmpmatrix )
                    
IGRint			action;		   /* TRUE : accept extend	    */
IGRdouble		*prev_pt;          /* previous pt                   */
IGRdouble		*first_pt;         /* first pt                      */
IGRdouble		*Z_Window;         /* Z view window axis            */
IGRint			NbOfImpDirection;  /* number of imposed direction   */
IGRdouble		*imp_direct;       /* imposed direction ( nozzle )  */
IGRdouble		angle;             /* angle for skewed mode         */
IGRboolean		angle_flag;        /* to know if an angle has been  */
					   /* given for the skewed mode     */
IGRboolean		orthogonal_sketch; /* TRUE if orthogonal sketch     */
struct IGRdisplay       *display;          /* Active symbologies            */
IGRboolean		is_connect;
IGRlong			CompType;          /* Added for TR179600988 */
IGRdouble		*cmpmatrix;	   /* Added for TR179600988 */
{
  IGRdouble                  	pt_buffer[6]; /* polyline end points        */
  struct       	IGRpolyline     polyline;     /* polyline to display        */
  struct 	DPele_header	element;      /* element header to display  */
  struct 	VRline_params	VRinfo;       /* argument for dunamic macro */
  struct 	IGRdisplay      Display;      /* Active symbologies         */


  /* struct will be modified in the sketch mode */  
  Display = *display;

  polyline.num_points = 2;
  polyline.points     = pt_buffer;
 
  dp$build_dis_buffer(buffer      = &element,
		      type        = IGRPY,
		      display_att = &Display,
		      geometry    = ( struct IGRpolyline *) &polyline );

  VRinfo.header_line       	= &element;
  VRinfo.action			= action;
  VRinfo.prev_pt           	= prev_pt;
  VRinfo.first_pt          	= first_pt;
  VRinfo.Z_Window	   	= Z_Window;
  VRinfo.NbOfImpDirection  	= NbOfImpDirection;
  VRinfo.imp_direct        	= imp_direct;
  VRinfo.orthogonal_sketch 	= &orthogonal_sketch;
  VRinfo.angle		   	= angle;
  VRinfo.angle_flag	   	= &angle_flag;
  VRinfo.is_connect        	= is_connect;
  VRinfo.CompType		= CompType; /* TR179600988 */
  VRinfo.cmpmatrix		= cmpmatrix;
  dp$dynamics( dyn_fun = VRlinedyn, information = &VRinfo );

  return OM_S_SUCCESS;
}


end implementation Root;
