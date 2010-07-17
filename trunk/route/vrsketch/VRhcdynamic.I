/* $Id: VRhcdynamic.I,v 1.2 2002/04/10 20:33:30 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch / VRhcdynamic.I
 *
 * Description:
 *	dynamic display of a pipe segment.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRhcdynamic.I,v $
 *	Revision 1.2  2002/04/10 20:33:30  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1999/05/05  07:52:24  pinnacle
# Replaced: vrsketch/VRhcdynamic.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/04/10  15:00:02  pinnacle
# Replaced: vrsketch/VRhcdynamic.I for:  by lawaddel for route
#
# Revision 1.3  1998/03/20  21:24:20  pinnacle
# Replaced: vrsketch/VRhcdynamic.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/19  15:09:52  pinnacle
# Replaced: vrsketch/VRhcdynamic.I for:  by r240_int for route240
#
 *
 * History:
 *	02/11/89	momo	Design Date
 *	01/15/96	tlb	Add prototypes, 
 *				Change VRhvline_params,  VRhvlinedyn to static
 *      03/05/98        law     TR179600988 sketch one way from nozzle
 *      04/09/98        law     TR179702549 sketch filters  for direction
 *      05/04/99    Reddy       Doble value comparision corrected
 *      04/08/02    law         TR5649-standardize tolerance with VRGetTol
 *************************************************************************/

class implementation VRsketch;


#include <math.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igewindow.h"
#include "igrdef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "OMmacros.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "VRsketchdef.h"
#include "VRMath.h"
#include "bsparameters.h"
#include "bsmkvec.h"
#include "bsdotp.h"


#include "bsvalues.h"
#include "bserr.h"
#include "vrtools_pto.h"
#include "bscrossp.h"

#define AS_DEBUG
#define WIDTH_SIZE 40
#define DEPTH_SIZE 20


    /* TR179600988 sketch one way from nozzle- added CompType */
static struct VRhvline_params 
{
  IGRint			action;
  IGRdouble	          	*prev_pt;
  IGRdouble	          	*first_pt;
  IGRdouble		  	*Z_Window;
  IGRint		  	NbOfImpDirection;
  IGRdouble		  	*imp_direct;
  IGRdouble		  	angle;
  IGRboolean		  	*angle_flag;
  IGRdouble	          	*matrix;
  IGRboolean              	*twist_orient;
  IGRboolean		  	*orthogonal_sketch;
  IGRboolean		  	is_connect;
  struct 	DPele_header     header[5];
  IGRint			CompType;
  IGRdouble                     *cmpmatrix;
};




/*************************************************************************/

static
IGRint VRhvlinedyn( VRinfo,point,matrix,objects,num_objects,buffers,num_buffers,
                    dummy_in1,dummy_in2,dummy_in3,dummy_out1,dummy_out2,
                    dummy_out3 )

struct 		VRhvline_params	*VRinfo;
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

/*.VRhvlinedyn */
{
  IGRint			i;           /* loop index                   */
  IGRint			IsValidPoint;/* return code used to know if  */
                                             /* next point is valid and to   */
               			             /* detect an extend             */
  IGRlong			status;      /* return code                  */
  IGRlong			sts;         /* return code                  */
  IGRlong 			which_error; /* used to inquire scale        */
  IGRlong			bytes_returned;
                                             /* used to inquire scale        */
  IGRdouble     		projpt[3];   /* projection of the next point */
  IGRdouble    			vy[3];       /* used to display W & D        */
  IGRdouble     		vz[3];       /* used to display W & D        */
  IGRdouble     		vx0[3];      /* used to display W & D        */
  IGRdouble     		*v_width;    /* used to display W & D        */
  IGRdouble     		*v_depth;    /* used to display W & D        */
  IGRdouble     		view_scale;  /* used to display W & D        */
  IGRdouble     		width_size;  /* used to display width        */
  IGRdouble     		depth_size;  /* used to display depth        */
  IGRdouble     		arrow_head;  /* used to display heads of tee */
  struct 	win_var_list	var_list[2]; /* used to inquire scale value  */

  IGRdouble	vector0[3],vector1[3], vector2[3], normal[3];
  IGRdouble 	free_angle, VRcompute_angle();
  IGRdouble	unite;
  IGRlong	rc,retcode;
  IGRdouble dVectDotProd;  /* Moved for TR179702549  */

  unite = M_PI / 180;

  /*"VRinfo->orthogonal_sketch = %d\n", *VRinfo->orthogonal_sketch */
  /*"VRinfo->twist_orient      = %d\n", *VRinfo->twist_orient      */

  VRinfo->Z_Window[0] = matrix[8];  
  VRinfo->Z_Window[1] = matrix[9];  
  VRinfo->Z_Window[2] = matrix[10];

  VRinfo->header->dis_att->weight = 0;
  VRinfo->header->dis_att->style = 0;

  if( *VRinfo->orthogonal_sketch )
  {
    /* TR179600988 sketch one way from nozzle */
    	/* project curser on X, Y or Z axis of active CS */
    	VRget_project_pt( VRinfo->first_pt, &point->x, projpt, &matrix[8],
                          (VRinfo->is_connect) ? VRinfo->imp_direct : NULL );

    if(VRinfo->CompType == IS_NOZZLE)
    {

       BSmkvec( &retcode, vector1, VRinfo->first_pt, projpt );

       vector0[0] = VRinfo->cmpmatrix[0];
       vector0[1] = VRinfo->cmpmatrix[4];
       vector0[2] = VRinfo->cmpmatrix[8];

       dVectDotProd = BSdotp(&retcode, vector0,vector1 );

       /* If the dot product of the two vectors is positive then they're h+
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


	/*BILLA  Double value comparison problem */
	if( ( fabs( VRinfo->first_pt[0] - VRinfo->prev_pt[0] ) < VRGetTol(VR_DIST_TOL) ) &&
	    ( fabs( VRinfo->first_pt[1] - VRinfo->prev_pt[1] ) < VRGetTol(VR_DIST_TOL) ) &&
	    ( fabs( VRinfo->first_pt[2] - VRinfo->prev_pt[2] ) < VRGetTol(VR_DIST_TOL) ) )
	{  	
        	VRinfo->prev_pt[0] = VRinfo->first_pt[0] - VRinfo->imp_direct[0];
		VRinfo->prev_pt[1] = VRinfo->first_pt[1] - VRinfo->imp_direct[1];
      		VRinfo->prev_pt[2] = VRinfo->first_pt[2] - VRinfo->imp_direct[2];
  	}

  	if ( *VRinfo->angle_flag == TRUE )
   	{ 
   		VRskdisplay_angle( VRinfo->angle, VRinfo->prev_pt, VRinfo->first_pt, projpt,
			    	   VRinfo->Z_Window);
      		VRinfo->header->dis_att->weight = 1;
      		VRinfo->header->dis_att->style = 3;
   	}
   	else
   	{
   		for (i =0; i<3; i++)
     		{
     			vector1[i] = VRinfo->first_pt[i] - VRinfo->prev_pt[i];
     			vector2[i] = projpt[i] - VRinfo->first_pt[i];
     		}
  
   		if( vector1[0] || vector1[1]|| vector1[2] )
   		{

  			 BScrossp ( &rc, vector1, vector2, normal);
  
   			free_angle = VRcompute_angle(vector1,vector2,normal);
   			if (free_angle <= unite)
     			{
     				free_angle = 0;
     				VRskdisplay_angle( free_angle, VRinfo->prev_pt, 
						   VRinfo->first_pt, projpt, VRinfo->Z_Window); 
     				VRinfo->header->dis_att->weight = 1;
     				VRinfo->header->dis_att->style = 3;
     			}

   			if ((free_angle <= ((M_PI/2) + unite)) && (free_angle >= ((M_PI/2) - unite)))
     			{
     				free_angle = M_PI/2;
     				VRskdisplay_angle( free_angle, VRinfo->prev_pt, VRinfo->first_pt,
						    projpt, VRinfo->Z_Window);
     				VRinfo->header->dis_att->weight = 1;
     				VRinfo->header->dis_att->style = 3;
     			}
    		}    
   	}
  }

  /* test if is a valid point */
  status = VRis_next_pt_valid( 	VRinfo->action,
			       	&IsValidPoint,
                               	VRinfo->prev_pt,
                               	VRinfo->first_pt,
                               	projpt,
			       	VRinfo->NbOfImpDirection,
                               	VRinfo->imp_direct );

  if( status & IS_A_VALID_POINT & IsValidPoint )
  {
    /* valid point ==> set polyline for segment and section axis */
    /* ADDED FOR TR179702549 */
    if((VRinfo->CompType != IS_NOZZLE) && (VRinfo->CompType != IS_PIPE) &&
       (VRinfo->CompType != IS_DANGLING) && (VRinfo->CompType != FREE_SPACE) &&
       (VRinfo->CompType != IS_UNDEFINED))


    {
        BSmkvec( &retcode, vector1, VRinfo->first_pt, projpt );

        vector0[0] = VRinfo->imp_direct[0];
        vector0[1] = VRinfo->imp_direct[1];
        vector0[2] = VRinfo->imp_direct[2];
        dVectDotProd = BSdotp(&retcode, vector0,vector1 );
        /* If the dot product of the two vectors is positive then they're
        heading the same direction. */
        if( dVectDotProd < VRGetTol(VR_DOTPROD_TOL) )
        {
          for(i=0;i<3;i++)
          {
             projpt[i]=VRinfo->first_pt[i];
          }
        }
    }
    for(i=0; i<3; i++ )
    {
      VRinfo->header[0].geometry.polyline->points[i]   = VRinfo->first_pt[i];
      VRinfo->header[1].geometry.polyline->points[i]   = projpt[i];
      VRinfo->header[2].geometry.polyline->points[i]   = projpt[i];

      VRinfo->header[0].geometry.polyline->points[i+3] = projpt[i];
      VRinfo->header[1].geometry.polyline->points[i+3] = projpt[i];
      VRinfo->header[2].geometry.polyline->points[i+3] = projpt[i];

      /* to display W & D */
      vx0[i] = projpt[i] - VRinfo->first_pt[i];
    }

    /*"projpt = %f %f %f\n", projpt[0], projpt[1], projpt[2] */
    /*"fst_pt = %f %f %f\n", VRinfo->first_pt[0], VRinfo->first_pt[1], VRinfo->first_pt[2] */
    /*"vx0    = %f %f %f\n", vx0[0], vx0[1], vx0[2] */
    /* get orientation of section */
    status = make_ref
             ( &sts, vx0, &VRinfo->matrix[3], &VRinfo->matrix[6], vy, vz );
    as$status( action = RET_STATUS );
 
    if( sts == MSFAIL ) return OM_S_SUCCESS;

    /* inquire the window scale */
    var_list[0].var            = VVOL_VIEWPORT_SCALE;
    var_list[0].var_ptr        = ( char *) &view_scale;  
    var_list[0].num_bytes      = sizeof( IGRdouble );
    var_list[0].bytes_returned = &bytes_returned;

    var_list[1].var = END_PARAM;

    status = dp$inq_set_gragad ( msg          = &sts,
  			         osnum        = point->osnum,
			         gragad_objid = point->objid,
  			         which_error  = &which_error,
  			         var_list     = var_list );
    as$status( action = RET_STATUS );

    width_size = WIDTH_SIZE / view_scale;
    depth_size = DEPTH_SIZE / view_scale;
    arrow_head = depth_size / 2;

    if( *VRinfo->twist_orient )
    {
      v_width = vz;
      v_depth = vy;
    }
    else
    {
      v_width = vy;
      v_depth = vz;
    }

    /* section must be displayed with independant scale */
    for( i=0; i<3; i++ )
    {
      VRinfo->header[1].geometry.polyline->points[i]   -= width_size*v_width[i];
      VRinfo->header[1].geometry.polyline->points[i+3] += width_size*v_width[i];
      VRinfo->header[2].geometry.polyline->points[i]   -= depth_size*v_depth[i];
      VRinfo->header[2].geometry.polyline->points[i+3] += depth_size*v_depth[i];

      VRinfo->header[3].geometry.polyline->points[i]   = 
         VRinfo->header[1].geometry.polyline->points[i+3] - arrow_head * v_depth[i];

      VRinfo->header[3].geometry.polyline->points[i+3] = 
         VRinfo->header[1].geometry.polyline->points[i+3] + arrow_head * v_depth[i];

      VRinfo->header[4].geometry.polyline->points[i]   = 
         VRinfo->header[2].geometry.polyline->points[i+3] - arrow_head * v_width[i];

      VRinfo->header[4].geometry.polyline->points[i+3] = 
         VRinfo->header[2].geometry.polyline->points[i+3] + arrow_head * v_width[i];
    }    
  }
  else
  {
    *num_buffers = 0;
    return(TRUE);
  }
    
  *buffers     = VRinfo->header;
  *num_buffers = 5;

  return(TRUE);
}

/****************************************************************************/

IGRlong VRhvlinear( action, prev_pt, first_pt, Z_Window, NbOfImpDirection,
                    imp_direct, matrix, twist_orient, orthogonal_sketch,
                    display, angle, angle_flag, is_connect, CompType,cmpmatrix )

IGRint			action;		   /* TRUE : accept extend	    */
IGRdouble		*prev_pt;          /* previous pt                   */
IGRdouble		*first_pt;         /* first pt                      */
IGRdouble		*Z_Window;         /* Z view window                 */
IGRint			NbOfImpDirection;  /* number of imposed direction   */
IGRdouble		*imp_direct;       /* imposed direction ( nozzle )  */
IGRdouble		*matrix;           /* section orientation matrix    */
IGRdouble		angle;             /* angle for skewed mode         */
IGRboolean		angle_flag;        /* to know if an angle has been  */
					   /* given for the skewed mode     */
IGRboolean		twist_orient;      /* twist orientation             */
IGRboolean		orthogonal_sketch; /* TRUE if orthogonal_sketch     */
struct IGRdisplay       *display;          /* Active display                */
IGRboolean		is_connect;
IGRint			CompType;          /* added for TR179600988         */
IGRdouble		*cmpmatrix;        /* added for TR179600988         */

/*.VRhvlinear */
{
  IGRdouble                  	pt_buffer[30];/* polyline end points        */
  struct	IGRdisplay	display1;     /* to display W & D           */
  struct	IGRdisplay	display2;     /* to display W & D           */
  struct       	IGRpolyline     polyline;     /* polyline to display        */
  struct       	IGRpolyline     polyline1;    /* polyline to display Width  */
  struct       	IGRpolyline     polyline2;    /* polyline to display Depth  */
  struct       	IGRpolyline     polyline3;    /* polyline to display Width  */
  struct       	IGRpolyline     polyline4;    /* polyline to display Depth  */
  struct 	VRhvline_params	VRinfo;       /* argument for dunamic macro */

  /*"orthogonal_sketch = %d\n", orthogonal_sketch */

  polyline.num_points  = 2;
  polyline1.num_points = 2;
  polyline2.num_points = 2;
  polyline3.num_points = 2;
  polyline4.num_points = 2;

  polyline.points      = pt_buffer;
  polyline1.points     = &pt_buffer[6];
  polyline2.points     = &pt_buffer[12];
  polyline3.points     = &pt_buffer[18];
  polyline4.points     = &pt_buffer[24];

  display1 = *display;
  display2 = *display;
  display1.style = 3;

  dp$build_dis_buffer(buffer      = &VRinfo.header[0],
		      type        = IGRPY,
		      display_att = &display2,
		      geometry    = ( struct IGRpolyline *) &polyline );

  dp$build_dis_buffer(buffer      = &VRinfo.header[1],
		      type        = IGRPY,
		      display_att = &display1,
		      geometry    = ( struct IGRpolyline *) &polyline1 );

  dp$build_dis_buffer(buffer      = &VRinfo.header[2],
		      type        = IGRPY,
		      display_att = &display1,
		      geometry    = ( struct IGRpolyline *) &polyline2 );

  dp$build_dis_buffer(buffer      = &VRinfo.header[3],
		      type        = IGRPY,
		      display_att = &display2,
		      geometry    = ( struct IGRpolyline *) &polyline3 );

  dp$build_dis_buffer(buffer      = &VRinfo.header[4],
		      type        = IGRPY,
		      display_att = &display2,
		      geometry    = ( struct IGRpolyline *) &polyline4 );

  VRinfo.action			= action;
  VRinfo.prev_pt           	= prev_pt;
  VRinfo.first_pt          	= first_pt;
  VRinfo.Z_Window          	= Z_Window;
  VRinfo.NbOfImpDirection  	= NbOfImpDirection;
  VRinfo.imp_direct        	= imp_direct;
  VRinfo.matrix            	= matrix;
  VRinfo.twist_orient      	= &twist_orient;
  VRinfo.orthogonal_sketch 	= &orthogonal_sketch;
  VRinfo.angle		   	= angle;
  VRinfo.angle_flag	   	= &angle_flag;
  VRinfo.is_connect        	= is_connect;
  VRinfo.CompType		= CompType; /* Added for TR179600988 */
  VRinfo.cmpmatrix		= cmpmatrix;

  dp$dynamics( dyn_fun = VRhvlinedyn, information = &VRinfo );

  return OM_S_SUCCESS;
}


end implementation VRsketch;

