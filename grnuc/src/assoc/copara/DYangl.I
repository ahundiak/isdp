/*

    Abstract:  DYrblineangl sets up the "additional information" needed 
               by PDdynamics when dynamically displaying a angl line.

     CHANGE HISTORY:

     jla    jul-86 - Created.
     jla 03-nov.86 - Associative implementation
-----*/

class implementation COpara;

#include  "AS_status.h"
#include  "bserr.h"
#include  "igrdef.h"
#include  "igr.h"
#include  "dpstruct.h"
#include  "dpmacros.h"
#include "OMmacros.h"
#include "ASmatrix.h"
#include "bserr.h"

#define AS_DEBUG
#define UNIT_ANGLE 57.29577951     /* convertion radian -->print in degre */


from NDnode import NDgive_structure;
from GRvg import GRgenabsg;
from GRgraphics import GRptproject;


struct angl_line_header
     {  struct DPele_header *absg;   /* abst. geometry */
         IGRpoint v0;                /* unit vector on the line  */
	 IGRpoint vnorm;             /* vector normal to the li - angli   */
         IGRpoint fix;               /* fix point */
         IGRdouble cs;               /* angle in radian */
         IGRdouble ss;               /* angle in radian */
         IGRint def_mode;            /* definition mode */
      }; 

IGRint DYrblineangl(param_id,  line_def, line_id, line_env, point_def, display)

    struct GRid *param_id;
    struct ret_struct *line_def;
    struct GRid *line_id;
    struct GRmd_env *line_env;
    struct ret_struct *point_def;
    struct IGRdisplay     *display;

/*.DYrblineangl*/
{
    struct       DPele_header   header;
    struct       IGRpolyline   polyline;
    IGRdouble                  pt_buffer[6];
    struct angl_line_header info_angl;
    IGRdouble eps,length;
    IGRpoint work;
    IGRint DYlineangl();
    IGRdouble alpha,cos(),sin();
    IGRlong status,msg;
    struct ret_struct alpha_struct;

    /* buffer to display the line */

    polyline.num_points = 2;
    polyline.points = pt_buffer;

    dp$build_dis_buffer(buffer = &header,
			type = IGRPY,
			display_att = display,
			geometry = (struct IGRpolyline *) &polyline);

    info_angl.absg = &header;

    /* parents information */
    /* line */
    if(!(line_def->type & line_generic))
    	ASlineangl_vor(point_def,line_def,*line_id,line_env);
    v_equal(line_def->var.line_st.v0,info_angl.v0);

    info_angl.def_mode = 0;
    v_sub(line_def->var.line_st.p0,line_def->var.line_st.p1,work);
    eps =  v_len(work);
    eps = 1.e-6 + 1.e-6 * eps;

    /*| point information */
    v_equal(point_def->var.point_st.pt,info_angl.fix);
    
    /*| normal to the plane where the 2 lines are */

      v_sub(point_def->var.point_st.pt,line_def->var.line_st.p0,work);
      v_cross(info_angl.v0,work,info_angl.vnorm);

      length = v_len(info_angl.vnorm);

      if(length <  eps)
         {
          info_angl.def_mode += 1;
	 }
      else
	{
	 length = 1/length;
	 v_scale(info_angl.vnorm,length,info_angl.vnorm);
	}

    /*| share parameter if any */
    if(!IF_EQ_OBJID(param_id->objid,NULL_OBJID))
       {
	status = om$send(msg = message NDnode.NDgive_structure
					(&msg,&alpha_struct,line_env),
		         senderid = NULL_OBJID,
			 targetid = param_id->objid,
			 targetos = param_id->osnum);
        as$status(action = RET_STATUS);
	if(alpha_struct.type != double_type) return OM_W_ABORT;

        alpha     = alpha_struct.var.root_pm_st.value / UNIT_ANGLE;
	info_angl.cs = cos(alpha);
	info_angl.ss = sin(alpha);
        info_angl.def_mode += 2;
       }

    /*"def_mode %d\n",info_angl.def_mode */
   
    /*|  Invoke dynamics  */
    dp$dynamics( dyn_fun = DYlineangl, information = &info_angl );
 
    return ( TRUE );
}

#argsused
IGRint DYlineangl( info_angl,
                  point,
		  matrix,
                  objects,
                  num_objects,
                  buffer,
                  num_buffers,
                  in_dummy1,
                  in_dummy2,
                  in_dummy3,
                  out_dummy1,
                  out_dummy2,
                  out_dummy3 )

    struct   angl_line_header    *info_angl;
    struct   EX_button       *point;
    IGRdouble                *matrix;
    struct   GRid           **objects;
    IGRint                   *num_objects;
    struct   DPele_header   **buffer;
    IGRint                   *num_buffers;
    IGRchar                 **in_dummy1,**in_dummy2, **in_dummy3,
                     	    **out_dummy1, **out_dummy2, **out_dummy3;

/*.DY*/
{
    IGRint status,rc;     /* return status (TRUE or FALSE) */
    IGRdouble one = 1.;
    IGRdouble length,sign_rot,scal,ssb;
    double *vnorm;
    double project[3],pb[3],vtrans[3];

    status = TRUE;


/* Get vector normal to the lines plane */

  if(info_angl->def_mode&1) vnorm = &matrix[8];
  else			    vnorm = info_angl->vnorm;

  /* Get definition point in the right plane */

  v_add(point,&matrix[8],pb);
    
  BSxlnpl(&rc,vnorm,info_angl->fix,point,pb,project);
  if(rc != BSSUCC) {*num_buffers = 0;  return (TRUE); }
  v_sub(project,info_angl->fix,pb);


  length = v_len(pb);
  if(length <1.e-4)
    {
     *num_buffers = 0;
     return(status);
    }

/* Compute the line at angle */

  if(info_angl->def_mode&2)
   {
     /*| old param */
    scal = -v_dot(pb,info_angl->v0);
    v_comb(one,pb,scal,info_angl->v0,vtrans);
    ssb = v_len(vtrans);
/*^pr_point(vtrans); */
    if(ssb <1.e-4) { *num_buffers = 0; return(status); }

    sign_rot = info_angl->ss * v_dot(pb,vtrans)*
	       info_angl->cs * v_dot(pb,info_angl->v0);

    if(sign_rot < 0.) ssb = -info_angl->ss/ssb;
    else 	      ssb =  info_angl->ss/ssb;
    
    v_comb(info_angl->cs,info_angl->v0,ssb,vtrans,pb);
    v_comb(one,info_angl->fix,length,pb,
             &(info_angl->absg->geometry.polyline->points[3]));
    length = - length;
    v_comb(one,info_angl->fix,length,pb,
             &(info_angl->absg->geometry.polyline->points[0]));
   }
  else
   {
    /* new param */
    v_add(info_angl->fix,pb,
                  &(info_angl->absg->geometry.polyline->points[3]));
    v_sub(info_angl->fix,pb,
                  &(info_angl->absg->geometry.polyline->points[0]));
   }


    *buffer = info_angl->absg;
    *num_buffers = 1;
    return( status );
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                             line_angl_para                                   

         compute the angle between the 2 lines and create the parameter

   The plane where the original line and the angle line are is needed. It is
   defined by the 2 local vectors  parent_line.v0 , vtrans and by the normal
   vector vnorm. This plane can by defined by different ways :

     - by the original line and the fixe point if this point is not on the line
     - else by the orignal line and the normal associated with the fixe point 
       if this normal and the line are not colinear (or nul..). 
     - else the plane is not defined and error message.
   
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ASline_angl_param(line_def,line_id,line_env,point_def,
		   point,view_vect,snap,angle)

struct ret_struct 	*line_def;
struct GRid		*line_id;		
struct GRmd_env		*line_env;
struct ret_struct 	*point_def;
IGRdouble		*point,*view_vect,*snap;
IGRdouble  		*angle;

/*.ASline_angl_param */
{

  IGRint      	rc,status;    /* routine return status */
  IGRdouble   	v[3],w_normal[3],*normal;         
  IGRdouble   	length,cs;
  IGRdouble 	acos(); 

  /* find origine and vector to be used to compute the angle */

  if(!(line_def->type & line_generic))
    {
     status = ASlineangl_vor(point_def,line_def,*line_id,line_env);
     if(!(status&1)) { return (OM_W_ABORT);}
    }
  v_sub(line_def->var.line_st.p0,point_def->var.point_st.pt,w_normal);
  v_cross(line_def->var.line_st.v0,w_normal,w_normal);
  length = v_len(w_normal);
  
  if(length < 1.e-4)
    { normal = view_vect;}
  else
    { normal = w_normal;}
 

  /* Get definition point in the right plane */

  v_add(point,view_vect,v);
  BSxlnpl(&rc,normal,point_def->var.point_st.pt,point,v,snap);
  if(rc != BSSUCC) {  return (OM_W_ABORT); }
  v_sub(snap,point_def->var.point_st.pt,v);

  /* Compute the angle in this plane */

  length = v_len(v);

  cs = v_dot(line_def->var.line_st.v0,v);
  *angle = acos(cs/length);
  *angle = *angle * UNIT_ANGLE;
	
  return( OM_S_SUCCESS );
}

end implementation COpara;
