/*

    Abstract:  DYrblinepara sets up the "additional information" needed 
               by PDdynamics when dynamically displaying a para line.


     CHANGE HISTORY:

     jla    jul-86   - Created.
     jla 03-nov-86   - Associative implementation
     jla 08-sep-89   - remove track point defining plane
		       use the view vector
-----*/

class implementation COpara;


#include "AS_status.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "OMmacros.h"
#include "ASmatrix.h"
#define AS_DEBUG

double fabs();
from NDnode import NDgive_structure;

struct para_line_header
     {  struct DPele_header *absg;   /* abst. geometry */
	struct ret_struct *line_def; /* original line geometry */
        IGRdouble d;                 /* distance */
        IGRint def_mode;             /* definition mode */
      }; 

IGRint DYrblinepara(  param_id, line_def,  display, md_env )

    struct GRid *param_id;
    struct ret_struct *line_def;
    struct IGRdisplay     *display;
    struct GRmd_env *md_env;

/*.DYrblinepara*/
{
    struct       DPele_header   header;
    struct       IGRpolyline    polyline;
    IGRdouble                  pt_buffer[6];
    struct para_line_header info_para;
    IGRint DYlinepara();
    IGRint status;
    IGRlong msg;
    struct ret_struct param_struct;

    polyline.num_points = 2;
    polyline.points = pt_buffer;

    dp$build_dis_buffer(buffer = &header,
			type = IGRPY,
			display_att = display,
			geometry = (struct IGRpolyline *) &polyline);

    info_para.absg = &header;

    /* parents information */
    /* line */

    info_para.line_def = line_def;

    /* share parameter  if any */

    if(!IF_EQ_OBJID(param_id->objid,NULL_OBJID))
       {
	status = om$send(msg = message NDnode.NDgive_structure
			    			    (&msg,&param_struct,md_env),
		         senderid = NULL_OBJID,
			 targetid = param_id->objid,
			 targetos = param_id->osnum);
	as$status(action = RET_STATUS);
	if(param_struct.type != double_type) return OM_W_ABORT;
        info_para.def_mode = 1;
	info_para.d = param_struct.var.root_pm_st.value;
       }
     else
       {
        info_para.def_mode = 0;
       }
   
    /*  Invoke dynamics  */

    dp$dynamics( dyn_fun = DYlinepara, information = &info_para );
    return ( TRUE );
}

t_vector(
  double *in,
  double *p0,
  double *v0,
  double *norm,
  double *out)
/*.placement_point*/
{
 double tmp[3];
 double len,scal;
 double one =1;

  v_sub(in,p0,out);

  v_cross(v0,norm,tmp);
  len = v_len(tmp);

  if(len<1.e-4)
    {
     /*| view vector and line are parallel */
     scal = -v_dot(out,v0);
     v_comb(one,out,scal,v0,out);
    }
  else
    {
     /*| view vector and line are not parallel */
     scal = v_dot(out,tmp)/(len*len);
     v_scale(tmp,scal,out);
    }
 return 1;
}

#argsused
IGRint DYlinepara( info_para,
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

    struct   para_line_header    *info_para;
    struct   EX_button       *point;
    IGRdouble                *matrix;
    struct   GRid           **objects;
    IGRint                   *num_objects;
    struct   DPele_header   **buffer;
    IGRint                   *num_buffers;
    IGRchar                 **in_dummy1,**in_dummy2, **in_dummy3,
                     	    **out_dummy1, **out_dummy2, **out_dummy3;

{
    IGRpoint vtrans;
    double length;

/* compute vector from line to placement point perpendicular to view vector */

t_vector((double *) point,info_para->line_def->var.line_st.p0,
	       info_para->line_def->var.line_st.v0,&matrix[8],vtrans);

    if(info_para->def_mode == 1)
     {
      length = v_len(vtrans);
      if(length != 0.)
	{
	 length=info_para->d/length;
	 v_scale(vtrans,length,vtrans);
	}
      else
	{
         *num_buffers = 0;
         return( TRUE );
	}
     }

/* end of the different cases */

    v_add(info_para->line_def->var.line_st.p0,vtrans,
                  info_para->absg->geometry.polyline->points);

    v_add(info_para->line_def->var.line_st.p1,vtrans,
                  &(info_para->absg->geometry.polyline->points[3]));

    /* set up buffered element */

    *buffer = info_para->absg;
    *num_buffers = 1;
    return( TRUE );
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 line_para_param
 Compute parameter value to place parallel line from a point
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ASline_para_param(line_def,pt2,view_v,snap,dist)
struct ret_struct 	*line_def;
IGRdouble		*pt2,*view_v,*snap;
IGRdouble  		*dist;

/*.ASline_para_param */
{

  IGRdouble 	v[3];                

  
  t_vector(pt2,line_def->var.line_st.p0,line_def->var.line_st.v0,view_v,v);

  *dist = v_len( v );
  v_add(line_def->var.line_st.p0,v,snap);
  return( OM_S_SUCCESS );

} /* end of ASline_para_param */
 
end implementation COpara;
