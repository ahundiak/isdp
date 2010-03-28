class implementation COpara;

#include "igrdef.h"
#include "igr.h"
#include "madef.h"
#include "godef.h"
#include "dpstruct.h"
#include "AS_status.h"
#include "dpmacros.h"
#include "bserr.h"
#include "ASmatrix.h"

#define  DEBUG 

struct dyn_arc 
{
         IGRboolean cntr_clk;
         IGRdouble start_axis[3];
	 IGRdouble normal[3];
         IGRdouble *view; 
         IGRdouble *sweep_p, *center_p;
  	 struct DPele_header *ele_buf;
		
}; 

#argsused
DYarc_p(arc_info,point,matrix,objects,num_objects,buffers,num_buffers,
        in_dummy1, in_dummy2, in_dummy3, out_dummy1, out_dummy2, out_dummy3 )


  struct dyn_arc *arc_info;
  struct EX_button *point;
  IGRdouble        *matrix;
  struct GRid **objects;
  IGRint *num_objects;
  struct DPele_header **buffers;
  IGRint *num_buffers;
  IGRchar                 **in_dummy1,**in_dummy2, **in_dummy3,
                     	  **out_dummy1, **out_dummy2, **out_dummy3;
/*.DYarc*/
{
  IGRdouble radius;
  IGRlong rc;
  IGRvector project, vrad, start_p;
  double one = 1;

  *num_buffers = 0;

  v_add(point,&matrix[8],vrad);
  BSxlnpl(&rc,arc_info->normal,arc_info->center_p,point,vrad,project);
  if(rc != BSSUCC) { return (TRUE); }

  v_sub(project,arc_info->center_p,vrad);

  radius = v_len(vrad);
  v_comb(one,arc_info->center_p,radius,arc_info->start_axis,start_p);

  BSac2ptctvc(start_p,arc_info->center_p,arc_info->sweep_p,arc_info->view,
	      arc_info->cntr_clk,arc_info->ele_buf->geometry.bspcurve,&rc);
  if(rc != BSSUCC) return(TRUE);

  *num_buffers = 1;
  *buffers = arc_info->ele_buf;

  return(1);
}

IGRint DYrbarc_p( pt1, pt2, pt3, cntr_clk, view , sym)

 struct ret_struct *pt1, *pt2, *pt3;
 IGRboolean cntr_clk;
 IGRdouble view[]; 
 struct IGRdisplay        *sym;

/*.DYrbarc_p*/
{
  struct dyn_arc  arc_info;
  struct DPele_header ele;
  struct IGResbc   attr;
  double length;
  IGRint DYarc_p();
  GRconic_declare( bspline, CirclePolesetc );

  GRconic_init( bspline, CirclePolesetc );

  dp$build_dis_buffer( buffer = &ele,
                       type = IGRBC,
                       display_att = sym,
                       ele_spec_att = &attr,
                       geometry = &bspline);
  ele.ele_spec_att.bspcurve->is_polydis = 0;
  ele.ele_spec_att.bspcurve->is_curvedis = 1;

  arc_info.ele_buf = &ele;

  arc_info.center_p = pt1->var.point_st.pt;
  arc_info.sweep_p  = pt3->var.point_st.pt;

  v_sub(pt2->var.point_st.pt,pt1->var.point_st.pt,arc_info.start_axis);
  length = v_len(arc_info.start_axis);

  if(length < 1.e-6) return(1);
  length = 1/length;
  v_scale(arc_info.start_axis,length,arc_info.start_axis);

  v_sub(pt3->var.point_st.pt,pt1->var.point_st.pt,arc_info.normal);
  v_cross(arc_info.start_axis,arc_info.normal,arc_info.normal);
  length = v_len(arc_info.normal);
  if(length < 1.e-6)
    {v_equal(view,arc_info.normal);}
  else
    {length = 1/length;
     v_scale(arc_info.normal,length,arc_info.normal);
    }


  arc_info.view = (IGRdouble *) view;
  arc_info.cntr_clk = cntr_clk;

  dp$dynamics(dyn_fun =  DYarc_p,
              information = &arc_info);
  return(1);
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                             ASarc_para_param
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ASarc_para_param(point1,point2,point3,cntr_clk,point,view_vect,first_view_vector,snap,param_val)

struct  ret_struct         *point1;
struct  ret_struct         *point2;
struct  ret_struct         *point3;
IGRboolean		cntr_clk;
IGRdouble               *point,*view_vect,*first_view_vector,*snap;
IGRdouble               *param_val;

/*. ASarc_para_parm */
{
  IGRlong       msg,rc;
  IGRdouble     v1[3],v2[3],vnorm[3],v[3],project[3];
  double len;

  /* Info for graphic object placement */
  if(cntr_clk) v_neg(first_view_vector,snap);
  else	       v_equal(first_view_vector,snap);

  /*| Compute the parameter */

  v_sub(point2->var.point_st.pt,point1->var.point_st.pt, v1);
  v_sub(point3->var.point_st.pt,point2->var.point_st.pt, v2);
  v_cross(v1,v2,vnorm);
  len = v_len(vnorm);
  if(len<1.e-4) v_equal(view_vect,vnorm);
  else  {len = 1/len;v_scale(vnorm,len,vnorm);}
 

  v_add(point,view_vect,v);
  BSxlnpl(&rc,vnorm,point1->var.point_st.pt,point,v,project);
  if(rc != BSSUCC)
    { return (OM_W_ABORT); }
  v_sub(project,point1->var.point_st.pt,v);
  MAlenvc(&msg, v, param_val );

  return( OM_S_SUCCESS );
}

end implementation COpara;

