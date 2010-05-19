/* $Id: VDdrw_plan.I,v 1.1.1.1 2001/01/04 21:09:22 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdspace/imp / VDdrw_plan.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrw_plan.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:22  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1999/04/09  19:55:14  pinnacle
# Replaced: vdspace/imp/VDdrw_plan.I for:  by mdong for vds
#
# Revision 1.2  1999/02/12  19:14:18  pinnacle
# Replaced: vdspace/imp/VDdrw_plan.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/03/18  11:04:30  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/31/99	Ming		TR179801899
 *
 * -------------------------------------------------------------------*/

class implementation ASnode;

#include <math.h>
#include <string.h>
#include "bserr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "cotxmacros.h"
extern GRclassid  OPP_GR3dlineseg_class_id;
extern double v_dot(),v_len();

VDextract_plane(obj_id,  drawing_elements,
                 nb_drawing_elem,
                 level, lbs,
                 from_env,to_env)

struct GRid *obj_id, **drawing_elements;
int    *nb_drawing_elem;
int *level;
struct IGRlbsys *lbs;
struct GRmd_env *from_env,*to_env;
{

  long status,loc_msg;
  long NumberOfBytes,BytesReceived;
  double point[3],normal[3],dot,p1[3],p2[3],v1[3],v2[3],p[6],l1;
  struct GRid plane;
  struct IGRplane def_plane;
  struct GRdpb_text_symb text_symb;
  struct GRsymbology his_symb;
  struct GRid *line;
  int axe;
  /* double v_dot(),v_len(); */
  char name[180],*text;
  short text_len;
  short cur_level;
  double         x_normal[4], y_normal[4], z_normal[4], x[3], y[3], z[3];
  double         x_dir[4], y_dir[4], z_dir[4];
  double         norm[4][3];
  double         tmp_value, p3[3], p4[3];
  long           bs_rc;
  int	         i, normal_index, dir_index, range_index;
  double         p1_p[3], p2_p[3], p3_p[3], p4_p[3];
  double         point_p[3];
  double         p1_inte[3], p2_inte[3], p3_inte[3], p4_inte[3];
  IGRdouble	 p_min[3], p_max[3];
  IGRvector	 vec1, vec2, vec_norm;
  IGRint	 y_flag;


/* init */

   /*
   ** TR179801899 by Ming
   */
   x[0] = x_dir[0] = 1.0;
   x[1] = x_dir[1] = 0.0;
   x[2] = x_dir[2] = 0.0;
   y[0] = y_dir[0] = 0.0;
   y[1] = y_dir[1] = 1.0;
   y[2] = y_dir[2] = 0.0;
   z[0] = z_dir[0] = 0.0;
   z[1] = z_dir[1] = 0.0;
   z[2] = z_dir[2] = 1.0;
   x_dir[3] = y_dir[3] = z_dir[3] = 0.0;
   y_flag = FALSE;

   NumberOfBytes = sizeof(text_symb);
   gr$get_text_symb( msg    = &loc_msg,
                   sizbuf = &NumberOfBytes,
                   buffer = &text_symb,
                   nret   = &BytesReceived );

   *nb_drawing_elem= 0;
   *drawing_elements = NULL;

   if(lbs == NULL) return OM_S_SUCCESS;
  
  NumberOfBytes = sizeof(IGRshort);
  gr$get_active_level(msg     = &loc_msg,
		      sizbuf  = &NumberOfBytes,
		      buffer  = &cur_level,
		      nret    = &BytesReceived);


/* NB SUPPOSE THAT DRAWING VUE IS NOT ROTATED */

     p1[0] = p2[0] =  lbs->matrix[3]  + lbs->diag_pt1[0]; 
     p1[1] = p2[1] =  lbs->matrix[7]  + lbs->diag_pt1[1]; 
     p1[2] = p2[2] =  lbs->matrix[11]; 

     if(p1[0] < -0.5*GRDGNLIMITS_MAX_D || p1[0] > 0.5*GRDGNLIMITS_MAX_D ||
        p1[1] < -0.5*GRDGNLIMITS_MAX_D || p1[1] > 0.5*GRDGNLIMITS_MAX_D ||
        p1[2] < -0.5*GRDGNLIMITS_MAX_D || p1[2] > 0.5*GRDGNLIMITS_MAX_D)
        return OM_S_SUCCESS;

/* get plane  definition */

  status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,
					"plane",&plane,NULL,NULL),
		   senderid = NULL_OBJID,
		   targetos = obj_id->osnum,
		   targetid = obj_id->objid);

  if(!(status&loc_msg&1)) return OM_W_ABORT;

  status = om$send(msg = message GRvg.GRgetsymb(&loc_msg,&his_symb),
		    senderid = NULL_OBJID,
		    targetos = plane.osnum,
		    targetid = plane.objid);
  if(!(status&loc_msg&1)) return OM_W_ABORT;

  status = om$send(msg = message GRvg.GRgetname(&loc_msg,name),
		    senderid = NULL_OBJID,
		    targetos = obj_id->osnum,
		    targetid = obj_id->objid);
  if(status&loc_msg&1)
   {
     text = strrchr(name,':');
     if(text) text++;
     else text = name;
     text_len = strlen(text);
   }
  else text = NULL;

  def_plane.point = point;
  def_plane.normal = normal;
  status = om$send(msg = message GRvg.GRdetplane(&loc_msg,
						&from_env->md_env.matrix_type,
						 from_env->md_env.matrix,
						&def_plane),
		  senderid = NULL_OBJID,
		  targetos = plane.osnum,
		  targetid = plane.objid);
  if(!(status&loc_msg&1))
  {
    status =
    om$send(msg      = message GRvg.GRdetplane(&loc_msg,
					       &from_env->md_env.matrix_type,
					       from_env->md_env.matrix,
					       &def_plane),
	    senderid = NULL_OBJID,
	    targetos = plane.osnum,
	    targetid = plane.objid);
    if(!(status&loc_msg&1)) return OM_S_SUCCESS;
  }

/* search with which boundary of the drawing window the normal of the plane
   is parallel to and verify the range */ 

   dot = normal[0]*lbs->matrix[0] +
         normal[1]*lbs->matrix[4] +
         normal[2]*lbs->matrix[8] ;

   if(fabs(dot)> .99)
    {
     /* axis x */
     axe = 0;
    }

   else
   {
    dot = normal[0]*lbs->matrix[1] +
          normal[1]*lbs->matrix[5] +
          normal[2]*lbs->matrix[9] ;

    if(fabs(dot)> .99)
     {
      /* axis y */
      axe = 1;
     }
    else
    {
     dot = normal[0]*lbs->matrix[2] +
           normal[1]*lbs->matrix[6] +
           normal[2]*lbs->matrix[10] ;
     if(fabs(dot)> .99)
     {
      /* axis z */
       axe = 2;
     }
     /* commented by Ming in TR179801899
     else return OM_S_SUCCESS;
     */
     /*
     ** TR179801899 by Ming
     */
     else axe = 3;
    }
   }

/* create geometry in drawing */
    
 if(axe == 2)
 {
  /* Only place text if the plane correspond to the origin of the drawing view*/
  if( (point[2] - lbs->matrix[11]) * (point[2] - lbs->matrix[11]) < 1.e-6 ) 
   {
    p2[0] = p2[0]   + 0.5 * (lbs->diag_pt2[0] - lbs->diag_pt1[0]);
    p2[1] = p2[1]   + lbs->diag_pt2[1] - lbs->diag_pt1[1];
    text_symb.Active_just = 7 ;

    *drawing_elements=(struct GRid *)  om$malloc(size = 1*sizeof(struct GRid));
    line = *drawing_elements;
    co$place_text(msg = &loc_msg,
                text_string = text,
                text_length = &text_len,
                rot_matrix = to_env->md_env.matrix,
		ActiveDisplay = &his_symb.display_attr,
		ActiveLevel = cur_level,
                TextSymb = &text_symb,
                origin = p2,
                buffer = line);
    *nb_drawing_elem = 1;
   }
 }
 /*
 ** TR179801899 by Ming
 */
 else if( axe == 3 )
 {
   BSmult_mats( 4, 4, from_env->md_env.matrix, FALSE, 4, 1, 
		x_dir, FALSE, x_normal, &bs_rc );
   BSmult_mats( 4, 4, from_env->md_env.matrix, FALSE, 4, 1, 
		y_dir, FALSE, y_normal, &bs_rc );
   BSmult_mats( 4, 4, from_env->md_env.matrix, FALSE, 4, 1, 
		z_dir, FALSE, z_normal, &bs_rc );

   for( i = 0 ; i < 2 ; i++ )
   {
     norm[0][i] = x_normal[i];
     norm[1][i] = y_normal[i];
     norm[2][i] = z_normal[i];
   }
   norm[0][2] = norm[1][2] = norm[2][2] = 0;
   norm[3][0] = 1.0;
   norm[3][1] = 0.0;
   norm[3][2] = 0.0;

   BSnorvec( &bs_rc, norm[0] );
   BSnorvec( &bs_rc, norm[1] );
   BSnorvec( &bs_rc, norm[2] );

   normal[2] = 0;
   BSnorvec( &bs_rc, normal );

   tmp_value = fabs( v_dot(normal, norm[0]) );
   normal_index = 0;
   if( fabs(v_dot(normal, norm[1])) > tmp_value )
   {
     tmp_value = fabs( v_dot(normal, norm[1]) );
     normal_index = 1;
   }
   if( fabs(v_dot(normal, norm[2])) > tmp_value )
   {
     tmp_value = fabs( v_dot(normal, norm[2]) );
     normal_index = 2;
   }

   vec1[0] = 0.0;
   vec1[1] = 1.0;
   vec1[2] = 0.0;
   tmp_value = fabs( v_dot(normal, vec1) );

   if( tmp_value > 0.99 ) y_flag = TRUE;

   tmp_value = 1.0;
   if( y_flag ) dir_index = 3;
   else
   {
     for( i = 0 ; i < 3 ; i++ )
     {
       if( i == normal_index ) continue;
       if( fabs(v_dot(norm[i],vec1)) <= tmp_value )
       {
         tmp_value = fabs( v_dot(norm[i],vec1) );
	 dir_index = i;
       }
     }
   }

   p1[0] = lbs->matrix[3] + lbs->diag_pt1[0];
   p1[1] = lbs->matrix[7] + lbs->diag_pt1[1];
   p1[2] = 0.0;
   p2[0] = lbs->matrix[3] + lbs->diag_pt2[0];
   p2[1] = p1[1];
   p2[2] = p1[2];
   p3[0] = lbs->matrix[3] + lbs->diag_pt2[0];
   p3[1] = lbs->matrix[7] + lbs->diag_pt2[1];
   p3[2] = 0.0;
   p4[0] = lbs->matrix[3] + lbs->diag_pt1[0];
   p4[1] = p3[1];
   p4[2] = p3[2];

   p1_p[0] = p1[0] + norm[dir_index][0];
   p1_p[1] = p1[1] + norm[dir_index][1];
   p1_p[2] = 0.0;
   p2_p[0] = p2[0] + norm[dir_index][0];
   p2_p[1] = p2[1] + norm[dir_index][1];
   p2_p[2] = 0.0;
   p3_p[0] = p3[0] + norm[dir_index][0];
   p3_p[1] = p3[1] + norm[dir_index][1];
   p3_p[2] = 0.0;
   p4_p[0] = p4[0] + norm[dir_index][0];
   p4_p[1] = p4[1] + norm[dir_index][1];
   p4_p[2] = 0.0;

   point[2] = 0.0;
   point_p[0] = point[0] + norm[normal_index][0];
   point_p[1] = point[1] + norm[normal_index][1];
   point_p[2] = 0.0;

   vec1[0] = point[0] - point_p[0];
   vec1[1] = point[1] - point_p[1];
   vec1[2] = 0.0;
   vec2[0] = 0.0;
   vec2[1] = 0.0;
   vec2[2] = 1.0;

   BSnorvec( &bs_rc, vec1 );
   BSnorvec( &bs_rc, vec2 );
   BScrossp( &bs_rc, vec1, vec2, vec_norm );
   BSnorvec( &bs_rc, vec_norm );

   BSxlnpl( &bs_rc, vec_norm, point, p1, p1_p, p1_inte );
   if( bs_rc != BSSUCC ) return OM_S_SUCCESS;

   BSxlnpl( &bs_rc, vec_norm, point, p2, p2_p, p2_inte );
   if( bs_rc != BSSUCC ) return OM_S_SUCCESS;

   BSxlnpl( &bs_rc, vec_norm, point, p3, p3_p, p3_inte );
   if( bs_rc != BSSUCC ) return OM_S_SUCCESS;

   BSxlnpl( &bs_rc, vec_norm, point, p4, p4_p, p4_inte );
   if( bs_rc != BSSUCC ) return OM_S_SUCCESS;

   p_min[0] = p1_inte[0];
   p_min[1] = p1_inte[1];
   p_min[2] = p1_inte[2];
   p_max[0] = p1_inte[0];
   p_max[1] = p1_inte[1];
   p_max[2] = p1_inte[2];

   if( fabs(p3_inte[0]-p1_inte[0]) > fabs(p3_inte[1]-p1_inte[1]) ) 
     range_index = 0;
   else
     range_index = 1;

   if( p2_inte[range_index] < p_min[range_index] )
   {
    p_min[0] = p2_inte[0];
    p_min[1] = p2_inte[1];
    p_min[2] = p2_inte[2];
   }

   if( p3_inte[range_index] < p_min[range_index] )
   {
    p_min[0] = p3_inte[0];
    p_min[1] = p3_inte[1];
    p_min[2] = p3_inte[2];
   }

   if( p4_inte[range_index] < p_min[range_index] )
   {
    p_min[0] = p4_inte[0];
    p_min[1] = p4_inte[1];
    p_min[2] = p4_inte[2];
   }

   if( p2_inte[range_index] > p_max[range_index] )
   {
    p_max[0] = p2_inte[0];
    p_max[1] = p2_inte[1];
    p_max[2] = p2_inte[2];
   }

   if( p3_inte[range_index] > p_max[range_index] )
   {
    p_max[0] = p3_inte[0];
    p_max[1] = p3_inte[1];
    p_max[2] = p3_inte[2];
   }

   if( p4_inte[range_index] > p_max[range_index] )
   {
    p_max[0] = p4_inte[0];
    p_max[1] = p4_inte[1];
    p_max[2] = p4_inte[2];
   }
   if( (point[range_index] < p_min[range_index]) ||
       (point[range_index] > p_max[range_index]) )
     return OM_S_SUCCESS;
   p[0] = point[0];
   p[1] = point[1];
   p[2] = point[2];
   p[3] = p[0] + norm[dir_index][0]*2*text_symb.Active_width;
   p[4] = p[1] + norm[dir_index][1]*2*text_symb.Active_width;
   p[5] = 0.0;
  
   *drawing_elements = (struct GRid *)  om$malloc(size = 2*sizeof(struct GRid));
   line = *drawing_elements;
   *nb_drawing_elem = 1;

   /*
   ** construct linestring
   */
   {
     struct IGRpolyline line_def;
     struct GRvg_construct cnst_lis; 

     line_def.num_points = 2;
     line_def.points = p;
     cnst_lis.msg = &loc_msg; 
     cnst_lis.env_info = to_env;
     cnst_lis.display = &his_symb.display_attr;
     cnst_lis.geometry = (char *) &line_def;
     cnst_lis.newflag = FALSE;
     cnst_lis.level = cur_level;
     cnst_lis.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
     cnst_lis.class_attr = NULL;
     cnst_lis.name = NULL;

     line->osnum = to_env->md_id.osnum;
     status =
     om$construct( classid = OPP_GR3dlineseg_class_id,
		   osnum   = to_env->md_id.osnum,
		   p_objid = &line->objid,
		   msg     = message GRgraphics.GRaltconstruct(&cnst_lis) );
   }

   /*
   ** construct text
   */
   if( text )
   {
     text_symb.Active_just = 9;

     co$place_text( msg           = &loc_msg,
                    text_string   = text,
                    text_length   = &text_len,
                    rot_matrix    = to_env->md_env.matrix,
		    ActiveDisplay = &his_symb.display_attr,
		    ActiveLevel   = cur_level,
                    TextSymb      = &text_symb,
                    origin        = p,
                    buffer        = line+1 );
     *nb_drawing_elem = 2;
   }
 }
 else
 {
   p2[axe] = p2[axe]   + lbs->diag_pt2[axe] - lbs->diag_pt1[axe];

   /* Verify now that the plane is in the clipping polygone */

   v_sub(p2,p1,v1);
   v_sub(point,p1,v2);
   l1 = v_len(v1);
   if(l1<1.e-3) return OM_S_SUCCESS;
   dot = v_dot(v1,v2)/(l1*l1);
   if(dot<=0 || dot >= 1) return OM_S_SUCCESS;
   v_comb(1.,p1,dot,v1,p);
  
   if(axe) p[0] +=    text_symb.Active_width;
   else    p[1] += 0.5*text_symb.Active_height;

   v_equal(p,p+3);
   p[4-axe] += 2*text_symb.Active_width;


   *drawing_elements = (struct GRid *)  om$malloc(size = 2*sizeof(struct GRid));
   line = *drawing_elements;
   *nb_drawing_elem = 1;

/* construct linestring */
  {
   struct IGRpolyline line_def;
   struct GRvg_construct cnst_lis; 
    line_def.num_points = 2;
    line_def.points = p;
    cnst_lis.msg = &loc_msg; 
    cnst_lis.env_info = to_env;
    cnst_lis.display = &his_symb.display_attr;
    cnst_lis.geometry = (char *) &line_def;
    cnst_lis.newflag = FALSE;
    cnst_lis.level = cur_level;
    cnst_lis.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
    cnst_lis.class_attr = NULL;
    cnst_lis.name = NULL;

   line->osnum = to_env->md_id.osnum;
   status = om$construct(classid = OPP_GR3dlineseg_class_id,
			 osnum = to_env->md_id.osnum,
			 p_objid = &line->objid,
			 msg = message GRgraphics.GRaltconstruct(&cnst_lis));
  }

  /* construct text */
   if (text)
    {
     if(axe) text_symb.Active_just = 12;
     else    text_symb.Active_just = 9;

     co$place_text(msg = &loc_msg,
                text_string = text,
                text_length = &text_len,
                rot_matrix = to_env->md_env.matrix,
		ActiveDisplay = &his_symb.display_attr,
		ActiveLevel = cur_level,
                TextSymb = &text_symb,
                origin = p,
                buffer = line+1);
     *nb_drawing_elem = 2;
  }
 }
 
  return 1;
}
end implementation ASnode;
