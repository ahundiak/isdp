/* #######################    APOGEE COMPILED   ######################## */
/*
  Name
  GRgenerate_crosshatch
 
             Algorithm for Generating Cross Hatching in I/Draft



   Extract the view rotation, world to view matrix, and view plane
      from the window the crosshatch will be generated in.
    
   Inquire the size of the bspline geometry we wish to xhatch.

   Malloc enough space for the bspline geometry.

   Extract the bspline geometry from the element.

   Construct a projection matrix from the view plane.

   Project 1st pole in curve to view plane, we will use that
    point as a origin to start.

   If curve is rational, unweight origin.

   Construct a world to local matrix.

   Construct rotation matrix.

   Construct local coord. system by multipling the projection matrix by the
    rotation matrix .

   Translate the poles of our element to the local coord. system.

   Translate the origin to the local coord. system.

   Generate a matrix to rotate points back to world coordinate system.

   Compute range of element.

   Generate a list of horizonal lines to be used as the cross hatching pattern
   For efficiency the lines are not computed and saved.  Only the first point of
   each line needs to be saved.  These points are saved in a local points
   list.
 

   For every point in our local points list
      
     {
        Compute intersection points of element and plane. The plane is
        defined by the current point in our points list and a normal vector.
        These intersections are computed by calling BSpl_cv_int.

        All the intersection points are stored in a local line buffer.
        First, we must check and make sure the buffer is large enough
        to store all the intersection points.  If it is not we will
        increase it.

     }

   For each hole on the notify channel

     {

        Inquire the size of the bspline geometry we wish use as a hole.

        Malloc enough space for the bspline geometry.

        Extract the bspline geometry from the element.

        Translate the poles of the curve to local coordinate system.

        Compute range of hole.

        If the hole lies inside the element to cross hatch.

          {
             For each line in local lines buffer.
              
               {
                 If the current line is within the range of the hole.

                    {
                        Compute intersection point of line and hole.
                        These intersections are computed by calling BSpl_cv_int.

                        Check and make sure the buffer is large enough to 
                        store all the lines.  If it is not increase it.

                        Insert new lines into local lines buffer.
                    }
               }
          }
          
     }


     
   Build contruction list for om$construct.

   Extract active properties from dpb.

   For num lines in local lines buffer
      
     {

       Transform points from local coord. system back to world coord. system.
     
       Construct line segment.

       Connect line segment to cross hatching graphic group.

     }

   Deallocat any memory we malloced.
  
 */
/*  */
/****************************************************************************

Sp.Balamurugan   06/26/96   Rewritten the function GRxh_insert_pts_buffer()

where the different holes are classified and accordingly the construction 

points are added to the buffer.(TR # 11925418)

***************************************************************************/

class implementation GRconnector;

#include "coimport.h"
#include "codebug.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "madef.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "msdef.h"
#include "maerr.h"
#include "exdef.h"
#include "bstypes.h"
#include "bsmalloc.h"
#include "grownmacros.h"
#include "grxhatch.h"
#include "bserr.h"
#include "bsparameters.h"

%safe
#include <math.h>
%endsafe
/*#define    _m_debug(aaa);   aaa*/
#define    NUM_INT_PTS         201
#define    NUM_INT_PAR         101
#define    NUM_XH_LINES       1000
#define    XH_LIN_INC         1000

#define    LEFT_OVERLAP          1
#define    HOLE_INSIDE           2
#define    RIGHT_OVERLAP         3
#define    LINE_INSIDE_HOLE      4
#define    HOLE_OUTSIDE          5
#define   _xh_check_mem(ptr,msg) if(ptr==NULL) {msg=MSFAIL;return(OM_E_ABORT);}
from GRvg       import  GRgetsize, GRgetgeom;
from GRowner    import  GRget_number_components, GRget_components;
from GRowner    import  GRadd_components;

extern IGRboolean       BSpl_cv_int();
extern IGRboolean       MA3protmx();
extern IGRboolean       MAcubepy();
extern IGRboolean       MAgrotmx ();
extern IGRboolean       MAlswcmx();
extern IGRboolean       MAmulmx();
extern IGRboolean       MApapromx ();
extern IGRboolean       MArptsxform ();
extern IGRboolean       MAtrnmx();
extern IGRboolean       MAwclsmx();
extern int              DPsetinqgragad();

/*  */
/* GRxhpoint_compare - utility routine, used to sort points */
int GRxhpoint_compare(point1,point2)
     IGRdouble        *point1,*point2;	
{
  IGRint  return_code = 0;
  if(point1[0] > point2[0]) return_code = 1;
  if(point1[0] < point2[0]) return_code = -1;
  if(point1[0] == point2[0]) return_code = 0;
  _m_debug(
           printf("\n GRxhpoint_compare: pt1 = %f  pt2 = %f ret_code = %d \n",
                      point1[0], point2[0], return_code); );
  return(return_code);
}


#argsused
IGRint     GRgenerate_crosshatch(msg,
                                 elem_to_xhatch,
                                 num_boundaries,
                                 boundary_elems,
				 window_grid,
				 xh_gg,
				 xhatch_id,
                                 xhatch_color,
                                 xhatch_spacing,
                                 xhatch_angle,
		                 xhatch_pattern,
                                 act_origin,
				 module_info,
                                 associative_flag)
     
     IGRlong                     *msg;
     struct GRid                 *elem_to_xhatch; /* element that is being
                                                     crosshatched */
     IGRint                      num_boundaries;
     struct GRid                 *boundary_elems; /* array of boundary
                                                     elements */
     struct GRid                 *window_grid;
     struct GRid                 *xh_gg; /* graphic group to be
					    filled with lines     */
     struct GRid                  xhatch_id;      /* xhatch object's id     */
     IGRshort                     xhatch_color;
     IGRdouble                    xhatch_spacing;
     IGRdouble                    xhatch_angle;
     struct GRxhatchpat          *xhatch_pattern; /* pattern to xhatch with */
     IGRdouble                   *act_origin;
     struct GRmd_env             *module_info;
     IGRboolean                   associative_flag;
     
{
  IGRlong                      return_size1,return_size2,return_size3;
  IGRlong                      status;
  IGRlong                      which_err;
  IGRlong                      size;
  IGRint                       i,j;
  IGRint                       cur_line;
  IGRdouble                    range[6];      
  IGRdouble                    prim_ele_range[6];      
  IGRdouble                    origin[3];      
  IGRdouble                    negative_angle;
  IGRdouble                    basis_tolerance = 0.0;
  IGRdouble                    chord_height_tolerance;
  IGRmatrix                    wtv_matrix, project_matrix, rotation_matrix;
  IGRmatrix                    tmat, xmat, rev_mat, l_to_wmx, w_to_lmx,tmp1;
  IGRpoint                     x_point, y_point;
  IGRpoint                     new_origin;
  struct var_list              var_list[4];
  struct GRid                  line;
  struct IGRbsp_curve         *element_bsp = NULL, *hole_bsp = NULL;
  struct IGRbsp_curve         *xhatch_bsp = NULL;
  struct IGRcv_prism           element_prism ;
  struct IGRpolyline           xhatch_polyline;
  struct MAplane               viewplane;
  struct GRvg_construct        ConstructList;
  IGRpoint                     point_on_plane;
  IGRvector                    view_vector;
  IGRshort                     dim = 4;
  /*  */
  IGRlong                      index = 0;
  IGRlong                      one = 1, two = 2;
  struct IGRpolyline           xhatch_line;  
  IGRpoint                     int_pts[NUM_INT_PTS];
  IGRdouble                    par0[NUM_INT_PAR];
  IGRdouble                    over1[NUM_INT_PAR], over2[NUM_INT_PAR];
  IGRdouble                   *xpar0=NULL, *xover1=NULL, *xover2=NULL;
  IGRpoint                    *xint_pts=NULL;
  IGRint                       nint, n_seg;
  BSrc                         rc;
  IGRlong                      num_bytes, num_bytes_ret;
  IGRlong                      flag = 1;
  IGRvector                    normal;
  IGRboolean                   allocated_pts = FALSE;
  struct GRid                 *comp_obj = NULL;
  IGRpoint                     array_pts[NUM_XH_LINES*2];
  IGRpoint                    *xarray_pts=NULL;
  IGRint                       num_lines = 0;
  IGRint                       tmp_num_lines;
  IGRint                       num_lines_alloc;
  IGRdouble                    points[6];
  IGRboolean                   xarray_allocated = FALSE;
  IGRdouble                    angle;
  IGRdouble                    spacing;
  IGRdouble                    offset;
  IGRlong                      pass_count;
  IGRlong                      line_count;
  IGRlong                      line_num;
  IGRboolean                   bret;
  struct GRid                  active_owner;
  IGRboolean                   active_owner_exist;
  

  GRls_declare(xhatch_curve,poles);
  GRls_init(xhatch_curve,poles);
  
  status = OM_S_SUCCESS;
  *msg = MSSUCC;
  active_owner_exist = FALSE;
  active_owner.objid = NULL_OBJID;
  active_owner.osnum = OM_Gw_current_OS;

  if(associative_flag)
    {
      status = gr$get_active_owner(msg = &rc,
				   active_owner = &active_owner);
      if((status==OM_S_SUCCESS) && (rc==MSSUCC) )
	{         
	  status = gr$clear_active_owner(msg = &rc,
					 mod_id = &module_info->md_id);
	  active_owner_exist = ((status==OM_S_SUCCESS) && (rc==MSSUCC)) ?
	    TRUE : FALSE;
	}
      else
	{
	  active_owner_exist = FALSE;
	}
    }

  xhatch_polyline.points = NULL;  
  
  /*  load the view origin as the point on the view plane, and get the
   *  view rotation for later use in creating the prism. Also get the
   *  view-to-world matrix, and the viewplane, for later               */
  
  viewplane.point = point_on_plane;
  viewplane.normal = view_vector;
  
  var_list[0].var = VIEW_ROTATION;
  var_list[0].var_ptr = (IGRchar *) element_prism.matrix;
  var_list[0].num_bytes = sizeof (IGRdouble) * 16;
  var_list[0].bytes_returned = &return_size1;
  
  var_list[1].var = WLD_TO_VIEW;
  var_list[1].var_ptr = (IGRchar *) wtv_matrix;   
  var_list[1].num_bytes = sizeof (IGRdouble) * 16;
  var_list[1].bytes_returned = &return_size2;
  
  var_list[2].var = VIEW_PLANE;
  var_list[2].var_ptr = (IGRchar *) &viewplane;
  var_list[2].num_bytes = sizeof ( struct IGRplane );
  var_list[2].bytes_returned = &return_size3;
  
  var_list[3].var = END_PARAM;
  
  status = dp$inq_set_gragad(msg          = msg,
			     osnum        = window_grid->osnum,
			     gragad_objid = window_grid->objid,
			     which_error  = &which_err,
			     var_list     = var_list );

  if(status == OM_E_NOSUCHOBJ ||  status == OM_E_NO_OBJECT_SPACE)
    {
      status = om$send(msg = message Root.delete(FALSE),
		       senderid = NULL_OBJID,
		       targetos = xhatch_id.osnum,	
		       targetid = xhatch_id.objid);
      return(1);
    }

  /* getting the basis tolerance and chord height tolerance in case GRgetsize
   * or GRgetgeom fails - when calling GRgetsize and GRgetgeom the first time
   * the current basis tolerance is used and if this succeeds, we continue;
   * otherwise we set basis tolerance to twice the chord height tolerance
   * and call GRgetsize and GRgetgeom again because the current element may
   * have been produced by a surface - surface intersection, which may have
   * gaps as large as twice chord height tolerance which would cause GRgetsize
   * and GRgetgeom to fail with the "normal" basis tolerance since they call
   * EFmerge_curve which checks to make sure elements are within basis
   * tolerance; the basis tolerance will be set back to its original value at
   * the end of this function
   */

  BSEXTRACTPAR(&status, BSTOLBASIS, basis_tolerance);
  BSEXTRACTPAR(&status, BSTOLCHRDHT, chord_height_tolerance);
  chord_height_tolerance *= 2;

  i = 0;

  do
  {
    /* Get geometry of wireframe element */
    status = om$send(msg = message GRvg.GRgetsize(msg,
  					     &module_info->md_env.matrix_type,
						module_info->md_env.matrix,
						&size),
  		     senderid = NULL_OBJID,
		     targetos = elem_to_xhatch->osnum,	
		     targetid = elem_to_xhatch->objid);

    if (1 & status & *msg)
    {
      if(size<0) 
      {
        status = OM_E_NODYNMEM;
        *msg = MSFAIL;
        goto quit;
      };

      element_bsp = (struct IGRbsp_curve *) om$malloc( size = size);

      if (element_bsp == NULL)
      {
        status = OM_E_NODYNMEM;
        *msg = MSFAIL;
        goto quit;
      };

      status = om$send(msg = message GRvg.GRgetgeom(msg,
					      &module_info->md_env.matrix_type,
						module_info->md_env.matrix,
						(IGRchar *) element_bsp),
		       senderid = NULL_OBJID,
		       targetos = elem_to_xhatch->osnum,
		       targetid = elem_to_xhatch->objid);
    }

    if ((i == 0) &&
        !(1 & status & *msg))
      BSchgdeppar(chord_height_tolerance, &rc);

    i++;
  }
  while ((i < 2) &&
         !(1 & status & *msg));

  _m_check2q(status,*msg);

  if (i == 2)
    BSchgdeppar(basis_tolerance, &rc);

  /* construct matrix for projection to viewplane */
  bret = MApapromx (msg, view_vector,  &viewplane, project_matrix);    
  _m_check_boolq(bret);
  
  /* project 1st pole to viewplane and use that as a origin */
  bret = MArptsxform (msg, &one, &element_bsp->rational, element_bsp->weights,
		      project_matrix, element_bsp->poles, origin);
  _m_check_boolq(bret);

  
  /* unweight curve, if rational*/
  if(element_bsp->rational)
    {
      origin [0] = origin[0] / element_bsp->weights[0];
      origin [1] = origin[1] / element_bsp->weights[0];
      origin [2] = origin[2] / element_bsp->weights[0];
    }
  
  x_point[0] = origin[0] + element_prism.matrix[0];
  x_point[1] = origin[1] + element_prism.matrix[1];
  x_point[2] = origin[2] + element_prism.matrix[2];
  
  y_point[0] = origin[0] + element_prism.matrix[4];
  y_point[1] = origin[1] + element_prism.matrix[5];
  y_point[2] = origin[2] + element_prism.matrix[6];
  
  /* construct a world-to-local matrix */
  bret = MA3protmx(msg, origin, x_point, y_point,tmat);
  _m_check_boolq(bret);
  bret = MAtrnmx(msg, &dim, tmat, tmat);
  _m_check_boolq(bret);
  bret = MAwclsmx(msg, origin, tmat, w_to_lmx);
  _m_check_boolq(bret);

  for(pass_count = 0; pass_count < xhatch_pattern->num_angles; pass_count++)
    {
      angle = xhatch_angle + xhatch_pattern->pass[pass_count].angle;  
      negative_angle = angle * (-1); 
      
      bret = MAgrotmx(msg, view_vector, act_origin, &negative_angle, 
		      rotation_matrix);
      _m_check_boolq(bret);

      
      /* multiply project matrix by rotation matrix*/
      bret = MAmulmx(msg, &dim, &dim, &dim, project_matrix, 
		     rotation_matrix, tmp1);
      _m_check_boolq(bret);

      /*  */  

      /*
	multiply world to local matrix by temp matrix , this yeilds the
	transformation matrix we need for our local coord. sys.
      */
      bret = MAmulmx(msg, &dim, &dim, &dim, w_to_lmx, tmp1, xmat);
      _m_check_boolq(bret);
  
      /* translate the poles of the curve to our local coord. system  */
      bret = MArptsxform (msg,
			  &element_bsp->num_poles,
			  &element_bsp->rational,
			  element_bsp->weights,
			  xmat,
			  element_bsp->poles,
			  element_bsp->poles);
      _m_check_boolq(bret);

      /* translate the origin to our local coord. system */
      bret = MAptsxform (msg,
			 &one, 
			 xmat,
			 act_origin, 
			 new_origin);
      _m_check_boolq(bret);
      
      /* generate matrix to rotate polyline back to original position */
      bret = MAgrotmx (msg, view_vector, act_origin, &angle, rotation_matrix);
      _m_check_boolq(bret);
      bret = MAlswcmx(msg,origin,tmat,l_to_wmx);
      _m_check_boolq(bret);
      bret = MAmulmx(msg,&dim, &dim, &dim, rotation_matrix, l_to_wmx, rev_mat);
      _m_check_boolq(bret);
      bret = MAcubepy(msg,element_bsp,&prim_ele_range[0], &prim_ele_range[3]);
      _m_check_boolq(bret);
      for(line_count=0; line_count<xhatch_pattern->pass[pass_count].num_lines;
          line_count++ )
	{
	  num_lines = 0;
	  spacing = xhatch_spacing;

          offset = spacing *
        xhatch_pattern->pass[pass_count].lines[line_count].perp_dist_next_line;
          status = GRxh_gen_horiz_points(msg,
					 &spacing,
					 new_origin, 
					 prim_ele_range, 
                                         offset,
					&xhatch_polyline);

          _m_debug(printf("GRxh_gen_horiz_points # points = %d\n",
                           xhatch_polyline.num_points););
	  { int num_points;
          num_points = 0;
          _m_debug(for(num_points=1; num_points<xhatch_polyline.num_points*3;
                       num_points=num_points+3)
		   { 
		    printf("GRxh_gen_horiz_points point[%d] = %f\n",num_points,
                             xhatch_polyline.points[num_points]);
		   })
	  }

	  _m_check2q( status, *msg );
	  
	  normal[0] = 0.0;
	  normal[1] = 1.0;
	  normal[2] = 0.0;
	  /* make sure the curve is not larger than what we allocated for */
	  /*  */
	  if(element_bsp->num_poles > (NUM_INT_PTS/2))
	    {
	      allocated_pts = TRUE;
              if(element_bsp->num_poles<0) 
                {
                 status = OM_E_NODYNMEM;
                 *msg = MSFAIL;
                  goto quit;
                };
	      xint_pts = (IGRpoint *)om$malloc(size = (sizeof(IGRpoint)) * 
					       (element_bsp->num_poles * 2) );
	      if(xint_pts == NULL) 
                {
                 status = OM_E_NODYNMEM;
                 *msg = MSFAIL;
                  goto quit;
                };

	      xpar0 = (IGRdouble *)om$malloc(
			 size = (sizeof(IGRdouble)) * element_bsp->num_poles);
	      if(xpar0 == NULL)
                {
                 status = OM_E_NODYNMEM;
                 *msg = MSFAIL;
                  goto quit;
                };

	      xover1 = (IGRdouble *)om$malloc(
		         size = (sizeof(IGRdouble)) * element_bsp->num_poles);
	      if(xover1 == NULL)
                {
                 status = OM_E_NODYNMEM;
                 *msg = MSFAIL;
                  goto quit;
                };

	      xover2 = (IGRdouble *)om$malloc(
                   size = (sizeof(IGRdouble)) * element_bsp->num_poles);
	      if(xover2 == NULL)
                {
                 status = OM_E_NODYNMEM;
                 *msg = MSFAIL;
                  goto quit;
                };

	    }
	  else  /* else use static variables */
	    {
	      xint_pts = (IGRpoint *) &int_pts[0][0];
	      xpar0 = &par0[0];
	      xover1 = &over1[0];
	      xover2 = &over2[0];
	    }  
      
	  /* clip lines against outside boundary */
	  num_lines_alloc = NUM_XH_LINES;
	  xarray_pts = (IGRpoint *) &array_pts[0][0];
	  for(i=0; i<xhatch_polyline.num_points; i++)
	    {
	      _m_debug(printf("\n\nBSpl_cv_int: pt[%d] = (%f,%f,%f)\n",i,
			      xhatch_polyline.points[(i*3)],
			      xhatch_polyline.points[(i*3)+1],
			      xhatch_polyline.points[(i*3)+2]););
	      bret = BSpl_cv_int(&rc,element_bsp,
				 &xhatch_polyline.points[(i*3)], 
				 normal, &nint,xint_pts, xpar0, 
				 &n_seg, xover1, xover2);

	      _m_debug(printf("BSpl_cv_int: # intersects = %d\n",nint););
              { int num_points;
              num_points = 0;
	      _m_debug(for(num_points=0; num_points<nint;num_points++)
		       { 
		      printf("BSpl_cv_int: point[%d] = %f,%f,%f\n",num_points,
			       xint_pts[num_points][0],xint_pts[num_points][1],
			       xint_pts[num_points][2]);
		     })
	      }
		_m_check_boolq(bret);
	      if( (num_lines + (IGRint) nint/2) >= num_lines_alloc)
		{
		  status = GRxh_inc_pts_buffer(&num_lines_alloc, &xarray_pts, 
					       &xarray_allocated);
		  _m_checkq(status);
		}
	      /*  */
	      /* store all intersection pts. into our points buffer */
	      /* order points in our array */
	      qsort( (char *) xint_pts,
		    nint,
		    sizeof(IGRpoint),
		    (int (*)())GRxhpoint_compare);
	      
	      for(j=0,line_num=0; j<(nint-1); j=j+2,line_num++)
		{
		  _m_debug(printf("adding int pts[%d] (%f,%f,%f)\n",j,
				  xint_pts[j][0],xint_pts[j][1],
				  xint_pts[j][2]););
		  _m_debug(printf("adding int pts[%d] (%f,%f,%f)\n",j+1,
				  xint_pts[j+1][0],xint_pts[j+1][1],
				  xint_pts[j+1][2]););
		  xarray_pts[((num_lines+line_num)*2)][0] = xint_pts[j][0];
		  xarray_pts[((num_lines+line_num)*2)][1] = xint_pts[j][1];
		  xarray_pts[((num_lines+line_num)*2)][2] = xint_pts[j][2];
		  xarray_pts[((num_lines+line_num)*2)+1][0] = xint_pts[j+1][0];
		  xarray_pts[((num_lines+line_num)*2)+1][1] = xint_pts[j+1][1];
		  xarray_pts[((num_lines+line_num)*2)+1][2] = xint_pts[j+1][2];
		}
	      num_lines = num_lines + (IGRint) nint/2;
	    }	
           for (i = 0; i < num_boundaries; i++)
	    {
              j = 0;

              do
              {
	        status = om$send(msg = message GRvg.GRgetsize( msg,
					      &module_info->md_env.matrix_type,
					       module_info->md_env.matrix,
					      &size),
			         senderid = NULL_OBJID,
			         targetid = boundary_elems[i].objid, 
			         targetos = boundary_elems[i].osnum);

                if (1 & status & *msg)
                {
                  if(size < 0)
		  {
		    status = OM_E_NODYNMEM;
		    *msg = MSFAIL;
		    goto quit;
		  };
	          hole_bsp = (struct IGRbsp_curve *) om$malloc(size = size);

	          if(hole_bsp == NULL)
	  	  {
		    status = OM_E_NODYNMEM;
		    *msg = MSFAIL;
		    goto quit;
		  };

	  
	          status = om$send(msg = message GRvg.GRgetgeom( msg,
					      &module_info->md_env.matrix_type,
						    module_info->md_env.matrix,
						    (IGRchar *) hole_bsp),
			           senderid = NULL_OBJID,
			           targetid = boundary_elems[i].objid,
			           targetos = boundary_elems[i].osnum);
                }

                if ((j == 0) &&
                    !(1 & status & *msg))
                  BSchgdeppar(chord_height_tolerance, &rc);

                j++;
              }
              while ((j < 2) &&
                     !(1 & status & *msg));

              _m_check2q(status,*msg);

              if (j == 2)
                BSchgdeppar(basis_tolerance, &rc);

	      /*translate the poles of the curve to our local coord. system  */
	      bret = MArptsxform (msg,
				  &hole_bsp->num_poles,
				  &hole_bsp->rational,
				  hole_bsp->weights,
				  xmat,
				  hole_bsp->poles,
				  hole_bsp->poles);
	      _m_check_boolq(bret);
	      
	      /* make sure that the hole is inside the primary element, if it 
		 is not then we don't have to process it */
	      bret =MAcubepy(msg, hole_bsp, &range[0], &range[3]);
	      _m_check_boolq(bret);
	      if(prim_ele_range[0] <= range[0] && 
                 prim_ele_range[1] <= range[1])
		{
		  /* clip against hole    */
		  if(allocated_pts)
		    {
        	      allocated_pts = FALSE;
		      if(xint_pts) om$dealloc(ptr = xint_pts);
		      if(xpar0) om$dealloc(ptr = xpar0); 
		      if(xover1) om$dealloc(ptr = xover1);
		      if(xover2) om$dealloc(ptr = xover2);
		    }
	  
	  /*make sure the curve is not larger than what we allocated for */
		  if(hole_bsp->num_poles > (NUM_INT_PTS/2))
		    {
		      /* if curve is larger than static declared variables we 
			 will malloc what we need
			 */
		      if(hole_bsp->num_poles <0)
		      {
			status = OM_E_NODYNMEM;
			*msg = MSFAIL;
			goto quit;
		      };

		      allocated_pts = TRUE;
		      xint_pts = 
			(IGRpoint *)om$malloc(size = (sizeof(IGRpoint)) * 
					      (hole_bsp->num_poles * 2) );
		      if(xint_pts == NULL) 
		      {
			status = OM_E_NODYNMEM;
			*msg = MSFAIL;
			goto quit;
		      };

		      xpar0 = 
			(IGRdouble *)om$malloc(size = (sizeof(IGRdouble)) * 
					       hole_bsp->num_poles);
		      if(xpar0 == NULL) 
		      {
			status = OM_E_NODYNMEM;
			*msg = MSFAIL;
			goto quit;
		      };


		      xover1 = 
			(IGRdouble *)om$malloc(size = (sizeof(IGRdouble)) * 
					       hole_bsp->num_poles);
		      if(xover1 == NULL) 
		      {
			status = OM_E_NODYNMEM;
			*msg = MSFAIL;
			goto quit;
		      };


		      xover2 = 
			(IGRdouble *)om$malloc(size = (sizeof(IGRdouble)) * 
					       hole_bsp->num_poles);
		      if(xover2 == NULL) 
		      {
			status = OM_E_NODYNMEM;
			*msg = MSFAIL;
			goto quit;
		      };

		    }
		  else  /* use static declared variables */
		    {
		      xint_pts = (IGRpoint *) &int_pts[0][0];
		      xpar0 = &par0[0];
		      xover1 = &over1[0];
		      xover2 = &over2[0];
		    }
		  /*  */	  
		  /* loop thru our buffer of intersection pts. and compute 
                     their intersection against the hole we have found
		     */
		  j = num_lines;
		  for(cur_line=0; cur_line<j; cur_line++)
		    { 
	               /* see if the current line is within the range of hole 
			 we are working on. If it is not skip this line and 
			 go to the next.
			 */
	      if((xarray_pts[cur_line*2][1] >= range[1]) &&
			 (xarray_pts[cur_line*2][1] <= range[4]))
			{
			  /* compute intersection points */
			  bret = BSpl_cv_int(&rc, hole_bsp, 
					     &xarray_pts[cur_line*2][0], 
					     normal, 
					     &nint, xint_pts, xpar0, &n_seg, 
					     xover1, xover2);

			  /* make sure our local buffer is large enough, 
                             if not increase it    */
			  if(((num_lines + (IGRint) nint/2)-1) >= 
			     num_lines_alloc)
			    {
			      status = GRxh_inc_pts_buffer(&num_lines_alloc, 
							   &xarray_pts, 
							   &xarray_allocated);
			      _m_checkq(status);
			    }
			  /* if any intersection points exist added them to 
			     buffer 
			   */
			  if(nint > 0)                         
			    {  qsort( (char *) xint_pts,
                    nint,
                    sizeof(IGRpoint),
                    (int (*)())GRxhpoint_compare);

                              tmp_num_lines = num_lines;
			      status = GRxh_insert_pts_buffer(&num_lines, 
							      cur_line, 
							      nint, xint_pts, 
							      xarray_pts);
			      _m_checkq(status);

                              /* if the number of lines has been decremented
                               * this indicates that that last line in
                               * xarray_pts has been moved to the current
                               * position (overwriting the current line); if
                               * the line moved into the current position was
                               * one of the original lines being intersected
                               * with the current hole boundary (was not
                               * generated by GRxh_insert_pts_buffer) we
                               * must decrement the index cur_line so that this
                               * line will be processed; also need to decrement
                               * loop range j to prevent processing past the
                               * end of the array
                               */

                              if ((num_lines < tmp_num_lines) &&
                                  (tmp_num_lines == j))
                              {
                                 cur_line--;
                                 j--;
                              }
			    }
			}    /* end in range if */
		    } /* end for, num of lines */
		  if(hole_bsp) om$dealloc(ptr = hole_bsp);    
		}  /* end if hole inside prim. element */
	    } /*end process of all holes (for stmt) */
	  xhatch_line.num_points = 2;
	  xhatch_line.points = &points[0];
	  line.osnum = xhatch_id.osnum;
      
	  /*  */
	  /* init. varables for construct */
	  ConstructList.msg          = msg;
	  ConstructList.env_info     = module_info;
	  ConstructList.display = 
	    &xhatch_pattern->pass[pass_count].lines[line_count].line_symbology;
	  ConstructList.geometry     = (IGRchar *) &xhatch_line;
	  ConstructList.newflag      = FALSE;
	  ConstructList.level = xhatch_pattern->level; 
	  ConstructList.class_attr   = NULL;
	  ConstructList.name         = NULL;
  
	  /* extract active properties from dpb */
	  num_bytes = sizeof(IGRshort);
	  gr$get_active_prop(msg = msg,
			     sizbuf = &num_bytes,
			     buffer = &ConstructList.properties,
			     nret = &num_bytes_ret );
	  /* construct all lines we have in our buffer */
	  _m_debug( for(i=0; i<num_lines; i++)
		   {
		     printf("bef %d (%f,%f,%f) (%f,%f,%f)\n",i,
			    xarray_pts[i*2][0],xarray_pts[i*2][1],
			    xarray_pts[i*2][2],xarray_pts[(i*2)+1][0],
			    xarray_pts[(i*2)+1][1],xarray_pts[(i*2)+1][2]);
		   });

	  for(i=0; i<num_lines; i++)
	    {
	      xhatch_line.points[0] = xarray_pts[i*2][0];
	      xhatch_line.points[1] = xarray_pts[i*2][1];
	      xhatch_line.points[2] = xarray_pts[i*2][2];
	      xhatch_line.points[3] = xarray_pts[(i*2)+1][0];
	      xhatch_line.points[4] = xarray_pts[(i*2)+1][1];
	      xhatch_line.points[5] = xarray_pts[(i*2)+1][2];

	      bret = MAptsxform(msg,
				&two,
				rev_mat,
				xhatch_line.points,
				xhatch_line.points);
	      _m_check_boolq(bret);

	      status = om$construct(msg = message GRgraphics.GRaltconstruct(
							      &ConstructList),
				    osnum     = line.osnum,
				    classname = "GR3dlinestr",
				    p_objid   = &line.objid);

               /*  */
	      /* connect newly constructed object to our graphics group*/
	      status = om$send(msg = message GRconnector.GRflexconn(msg,
								    &flag,
								    xh_gg,
								    &index,
								    &index ),
			       senderid = NULL_OBJID,
			       targetid = line.objid,
			       targetos = line.osnum );
	      _m_check2q(status,*msg);	  
	    } /* end contructing all the line segs. (for stmt) */
	  _m_debug( for(i=0; i<num_lines; i++)
		   {
		     printf("aft %d (%f,%f,%f) (%f,%f,%f)\n",i,
			    xarray_pts[i*2][0],xarray_pts[i*2][1],
			    xarray_pts[i*2][2],xarray_pts[(i*2)+1][0],
			    xarray_pts[(i*2)+1][1],xarray_pts[(i*2)+1][2]);
		   });

	}
      /* trans. the poles of the curve back to original coord. system  */
      bret = MArptsxform (msg,
			  &element_bsp->num_poles,
			  &element_bsp->rational,
			  element_bsp->weights,
			  rev_mat,
			  element_bsp->poles,
			  element_bsp->poles);
      _m_check_boolq(bret);
      
    }

 quit:
  /* clean up any memory we allocated */
  if(comp_obj) om$dealloc(ptr = comp_obj);    
  if(element_bsp) om$dealloc(ptr = element_bsp);    
  if(xhatch_bsp) om$dealloc(ptr = xhatch_bsp);    
  if(xhatch_polyline.points) om$dealloc(ptr = xhatch_polyline.points);    
  if(allocated_pts)
    {
      if(xint_pts) om$dealloc(ptr = xint_pts);
      if(xpar0) om$dealloc(ptr = xpar0); 
      if(xover1) om$dealloc(ptr = xover1);
      if(xover2) om$dealloc(ptr = xover2);
    }

  if(active_owner_exist)
    {
      gr$put_active_owner(msg = &rc,
                          mod_id = &module_info->md_id,
                          active_owner = &active_owner);
    }

  if (basis_tolerance > 0.0)
    BSchgdeppar(basis_tolerance, &rc);

  return (status);
}
/*  */
   
IGRint  GRxh_inc_pts_buffer(num_lines_alloc, xarray_pts, 
                              xarray_allocated)

IGRint              *num_lines_alloc;
IGRpoint            **xarray_pts;
IGRboolean          *xarray_allocated;
{
  IGRpoint       *xtmp_pts = NULL;
  IGRpoint       *indirect_pt;
  IGRint          i;
  IGRlong         status;
  
  indirect_pt = *xarray_pts;
   _m_debug(
            printf("\nGRxh_inc_pts_buffer num lines alloc = %d \n",
                    *num_lines_alloc); );
  /* compute how much memory we need and malloc it */
  xtmp_pts = (IGRpoint *)om$malloc(size = (sizeof(IGRpoint)) * 
			       ((*num_lines_alloc*2) + (XH_LIN_INC*2) ));
  if(xtmp_pts == NULL) return(OM_E_NODYNMEM);

  if(xtmp_pts) /* verify memory was allocated */
    {
      status = OM_S_SUCCESS;
      /* transfer points from old buffer to new buffer */
      for(i=0; i<(*num_lines_alloc*2); i++)
       {
         xtmp_pts[i][0] = indirect_pt[i][0];
         xtmp_pts[i][1] = indirect_pt[i][1];
         xtmp_pts[i][2] = indirect_pt[i][2];
       }

     /* if old buffer was alloacted by us we must free it up */
     if(*xarray_allocated) om$dealloc(ptr = indirect_pt);    
     *xarray_pts = xtmp_pts;    /* assign ptr. to new buffer */
     *num_lines_alloc =  *num_lines_alloc + XH_LIN_INC;
     /* let calling routine know that we allocated the menory they requested*/
     *xarray_allocated = TRUE; 
    }
  else
   {
      status = OM_E_ABORT;
   } 
  return(status);
}

/*  */
IGRint  GRxh_insert_pts_buffer(num_lines, cur_line_num, nint, 
                               xint_pts, xarray_pts)

IGRint    	    *num_lines;
IGRint               cur_line_num;
IGRint               nint;
IGRpoint            *xint_pts;
IGRpoint            *xarray_pts;	
{
  IGRdouble            newxint_pts[100][3];
  IGRint               i,a,b;
  IGRshort             location_of_hole = 0;
  IGRdouble            tmpx, tmpy, tmpz;
  IGRdouble            startx,endx;
  IGRdouble            maxx,minx;


  startx = xarray_pts[(cur_line_num*2)][0];
  endx = xarray_pts[(cur_line_num*2)+1][0];
  minx = xint_pts[0][0];
  maxx = xint_pts[nint-1][0];

  for(i=0; i<nint; i++)
    {
      if(xint_pts[i][0] < minx) minx=xint_pts[i][0];
      if(xint_pts[i][0] > maxx) maxx=xint_pts[i][0];
    }
/***************************************************************************
 Sp.Balamurugan (06/26/96) 

   Here the special case of right overlap with a no. of intersections is 
treated as a hole inside case with the appropriate no. of intersections
and with the corresponding intersection points(i.e.,)those between startx 
and endx(TR # 11925418)
****************************************************************************/

if(minx < startx)  
    {   
      location_of_hole = RIGHT_OVERLAP;
       if(maxx<=endx){
                        location_of_hole=HOLE_INSIDE;
                       a=0; 
                       for(b=0;b<nint;b++){
                       if(xint_pts[b][0]>startx){ 
                        newxint_pts[a][0]=xint_pts[b][0];
                        newxint_pts[a][1]=xint_pts[b][1];
                        newxint_pts[a][2]=xint_pts[b][2];
                         a++;
                                                }
                                           }
                         nint=a;
                        for(a=0;a<nint;a++){
                         xint_pts[a][0]=newxint_pts[a][0];
                         xint_pts[a][1]=newxint_pts[a][1];
                         xint_pts[a][2]=newxint_pts[a][2];
                                           }

                       }
if(nint==1)location_of_hole=RIGHT_OVERLAP;
}
/***************************************************************************
 Sp.Balamurugan (06/26/96)   
 
   Here the special case of left overlap with a no. of intersections is 
treated as a hole inside case with the appropriate no. of intersections
and with the corresponding intersection points(i.e.,)those between startx 
and endx(TR # 11925418)
****************************************************************************/
  if(maxx > endx)
    {
      location_of_hole = LEFT_OVERLAP;
      if(minx>=startx){a=0;
                        for(b=0;b<nint;b++){
                           if(xint_pts[b][0]<endx){
                              a++;
                         location_of_hole=HOLE_INSIDE;                          }
                                            }
                         nint=a; 
                      } 
if(nint==1)location_of_hole=LEFT_OVERLAP;
}

  if( (startx <= minx) && (endx >= maxx) ) 
    {
      location_of_hole = HOLE_INSIDE;
     }
/***************************************************************************
 Sp.Balamurugan (06/26/96)   
 
   Here the special case of  line inside hole with a no. of intersections is 
treated as a hole inside case with the appropriate no. of intersections
and with the corresponding intersection points(i.e.,)those between startx 
and endx(for TR # 11925418)
****************************************************************************/
  if( (startx > minx) && (endx < maxx) ) 
    {
      location_of_hole = LINE_INSIDE_HOLE;
      a=0;
      for(b=0;b<nint;b++){
                 if(xint_pts[b][0]>=startx && xint_pts[b][0]<=endx){
                         xint_pts[a][0]=xint_pts[b][0];
                        xint_pts[a][1]=xint_pts[b][1];
                        xint_pts[a][2]=xint_pts[b][2];
                         a++;
                         location_of_hole=HOLE_INSIDE;                                                                                            }
                         }                    
                   if(a>0){ nint=a;}
                   else{location_of_hole=HOLE_OUTSIDE;}
    }
/*  */
  if( ((minx <= startx)  && (maxx <= startx)) || 
      ((minx >= endx)  && (maxx >= endx)) )
    { 
      location_of_hole = HOLE_OUTSIDE;
    }
  /*order intersection points */
  qsort( (char *) xint_pts,
                  nint,
                  sizeof(IGRpoint),
                  (int (*)())GRxhpoint_compare);
  _m_debug(
	   printf("\nGRxh_insert_pts_buffer: startx = %f, endx = %f \n",
                   startx,endx);
	   printf("GRxh_insert_pts_buffer: maxx = %f, minx = %f \n",
                   maxx,minx);
	   printf("GRxh_insert_pts_buffer: #int = %d \n",nint);
	   for(i=0; i<nint; i++)
	   {
	     printf("GRxh_insert_pts_buffer: xint_pt[%d] %f,%f,%f \n",
		    i,xint_pts[i][0], xint_pts[i][1], xint_pts[i][2]);
	   });

  switch(location_of_hole)
    {
    case LEFT_OVERLAP:
      {
        _m_debug_str("GRxh_insert_pts_buffer: LEFT_OVERLAP.");
	xarray_pts[(cur_line_num*2)+1][0] = minx;        
	break;
      }

    case HOLE_INSIDE:
      {
        _m_debug_str("GRxh_insert_pts_buffer: HOLE_INSIDE.");

        if (nint > 1)  /* don't do anything for tangent point */
        {
            /* store last postion of current line */
            tmpx = xarray_pts[(cur_line_num*2)+1][0];
	    tmpy = xarray_pts[(cur_line_num*2)+1][1];
            tmpz = xarray_pts[(cur_line_num*2)+1][2];

            /* first avail. point in array */
            xarray_pts[(cur_line_num*2)+1][0] = xint_pts[0][0];
    	    xarray_pts[(cur_line_num*2)+1][1] = xint_pts[0][1];
    	    xarray_pts[(cur_line_num*2)+1][2] = xint_pts[0][2];
/*  */
    	    for(i=1; i<nint;  i=i+2)
	    {
	        xarray_pts[*num_lines * 2][0] = xint_pts[i][0];
	        xarray_pts[*num_lines * 2][1] = xint_pts[i][1];
	        xarray_pts[*num_lines * 2][2] = xint_pts[i][2];

                if(i <= nint-1)
                {
	            xarray_pts[(*num_lines*2)+1][0] = xint_pts[i+1][0];
	            xarray_pts[(*num_lines*2)+1][1] = xint_pts[i+1][1];
	            xarray_pts[(*num_lines*2)+1][2] = xint_pts[i+1][2];
                }

   	        *num_lines = *num_lines + 1;
	    }
         if(nint!=3){  
       	    xarray_pts[((*num_lines-1)*2)+1][0] = tmpx;
	    xarray_pts[((*num_lines-1)*2)+1][1] = tmpy;
    	    xarray_pts[((*num_lines-1)*2)+1][2] = tmpz;
       } 
}
	break;
      }

    case RIGHT_OVERLAP:
      {
        _m_debug_str("GRxh_insert_pts_buffer: RIGHT_OVERLAP");
	xarray_pts[(cur_line_num*2)][0] = maxx;
	break;
      }

    case HOLE_OUTSIDE:
      {
        _m_debug_str("GRxh_insert_pts_buffer: HOLE_OUTSIDE");
	break;
      }

    case LINE_INSIDE_HOLE:
      {
        _m_debug_str("GRxh_insert_pts_buffer: LINE_INSIDE_HOLE");
        if(cur_line_num < (*num_lines-1) )
         {
   	   xarray_pts[(cur_line_num*2)][0] = xarray_pts[(*num_lines-1)*2][0];
	   xarray_pts[(cur_line_num*2)][1] = xarray_pts[(*num_lines-1)*2][1];
	   xarray_pts[(cur_line_num*2)][2] = xarray_pts[(*num_lines-1)*2][2];

	   xarray_pts[(cur_line_num*2)+1][0] = 
                 xarray_pts[((*num_lines-1)*2)+1][0];
	   xarray_pts[(cur_line_num*2)+1][1] = 
                 xarray_pts[((*num_lines-1)*2)+1][1];
	   xarray_pts[(cur_line_num*2)+1][2] = 
                 xarray_pts[((*num_lines-1)*2)+1][2];
         }
        *num_lines = *num_lines - 1;
	break;
      }
    }
  
  return(1);
}

end implementation GRconnector;

