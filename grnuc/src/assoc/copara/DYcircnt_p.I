/*---- 
     Abstract: this routine sets up data for rubber banding for
                  a circle.
---*/

class implementation COpara;


#include "igrdef.h"
#include "igr.h"
#include "madef.h"
#include "godef.h"
#include "dpstruct.h"
#include "AS_status.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "ASmatrix.h"
#include "bserr.h"

from NDnode import NDgive_structure;

IGRboolean  MAcrrcconstr();
double fabs();

struct DYcircnt_params {
    IGRdouble              *center;
    IGRdouble               param_val, rad_prt;
    IGRvector               nc;
    IGRchar                 def_mode;
    struct DPele_header    *circle;
};

#define AS_DEBUG
#define EPSILON 1.0e-10   



IGRint DYcircnt_p(param_id,  obj_struct, view_vect, display, md_env )

    struct GRid             *param_id;   /* parameter (if != NULL)    */
    struct ret_struct       *obj_struct; /* struct. of ref. circle    */
    IGRdouble               *view_vect;  /* view vector of the window */
    struct IGRdisplay       *display;    /* Active symbologies        */
    struct GRmd_env 	    *md_env;

{
    struct DPele_header       element;
    struct DYcircnt_params    DYinfo;
    struct IGResbc            attr;
    IGRint                    i;
    IGRint                    DYccntdyn();
    IGRlong                   status,msg;
    struct ret_struct 	      param_struct;

    GRconic_declare( bspline, CirclePolesetc );
    GRconic_init( bspline, CirclePolesetc );

    dp$build_dis_buffer( buffer = &element,
                         type = IGRBC,
                         display_att = display,
                         ele_spec_att = &attr,
                         geometry = &bspline);
    element.ele_spec_att.bspcurve->is_polydis = 0;
    element.ele_spec_att.bspcurve->is_curvedis = 1;

    if(obj_struct->type & point_generic)
     {
      DYinfo.center = obj_struct->var.point_st.pt;
      for(i=0;i<3;i++) DYinfo.nc[i] = view_vect[i];
      DYinfo.rad_prt = 0;
     }
    else
     {
      DYinfo.center = obj_struct->var.circle_st.cent_p;
      for(i=0;i<3;i++) DYinfo.nc[i] = obj_struct->var.circle_st.mat[2+4*i];
      DYinfo.rad_prt = obj_struct->var.circle_st.rad;
     }

    DYinfo.circle = &element;

    DYinfo.def_mode = 0;
    if(!IF_EQ_OBJID( param_id->objid, NULL_OBJID ))
     {
     status = om$send (msg  = message NDnode.NDgive_structure
					(&msg,&param_struct,md_env),
                 senderid =  NULL_OBJID,
                 targetid = param_id->objid,
                 targetos = param_id->osnum);
     as$status(action = RET_STATUS);
     if(param_struct.type != double_type) return OM_W_ABORT;
     DYinfo.param_val = param_struct.var.root_pm_st.value;
     DYinfo.def_mode = 1;
     }

    dp$dynamics( 
                dyn_fun = DYccntdyn,
                information = &DYinfo );
 return 1;
}

#argsused
IGRint DYccntdyn( 
                DYinfo,
                point,
                matrix,
                objects,
                num_objects,
                buffers,
                 num_buffers,
                in_dummy1,
                in_dummy2,
                in_dummy3,
                out_dummy1,
                out_dummy2,
                out_dummy3 )

        struct DYcircnt_params  *DYinfo;
        struct EX_button        *point;
        IGRdouble               *matrix;
        struct GRid             **objects;
        IGRint                  *num_objects;
        struct DPele_header     **buffers;
        IGRint                  *num_buffers;

        IGRchar                 **in_dummy1,**in_dummy2, **in_dummy3,
                     	        **out_dummy1, **out_dummy2, **out_dummy3;
   {
    IGRvector v,project;
    IGRdouble radius, rad;
    IGRlong status,msg,rc;

    v_add(point,&matrix[8],v);
    BSxlnpl(&rc,DYinfo->nc,DYinfo->center,point,v,project);
    if(rc != BSSUCC)
      {
       v_add(point,DYinfo->nc,v);
       BSxlnpl(&rc,DYinfo->nc,DYinfo->center,point,v,project);
      }
    if(rc != BSSUCC)
      { *num_buffers = 0; return (TRUE); }
    v_sub(project,DYinfo->center,v);

    rad = v_len(v);

    if( DYinfo->def_mode == 0 )
     {
      radius = rad;
     }
    else
     {
      if( rad > fabs(DYinfo->rad_prt)) 
             radius =  fabs(DYinfo->rad_prt) + fabs(DYinfo->param_val);
      else   radius =  fabs(fabs(DYinfo->rad_prt) - fabs(DYinfo->param_val));
     }

    /*
     *  call MAcrrcconstr to create a bspline circle
     */

    status = MAcrrcconstr( &msg, &radius, DYinfo->center, DYinfo->nc,
                           DYinfo->circle->geometry.bspcurve );

    *buffers = DYinfo->circle;
    *num_buffers = 1;

    return( status && (msg&1) );
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                             AScircle_param
   
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

AScircle_param(obj_struct,point,view_vect,first_view_vect,snap,param_val)

struct ret_struct	*obj_struct;
IGRdouble		*point,*view_vect,*first_view_vect,*snap;
IGRdouble		*param_val;

/*.AScircle_param */
{
  IGRdouble 	*center,*normal;
  IGRdouble     w_normal[3],v[3];
  IGRlong rc;


/*| Get normal vector to use */

 if(obj_struct->type&point_generic)
  {
   center = obj_struct->var.point_st.pt;
   normal = first_view_vect; 
  }
  else
  {
   center = obj_struct->var.circle_st.cent_p;
   w_normal[0] = obj_struct->var.circle_st.mat[2];
   w_normal[1] = obj_struct->var.circle_st.mat[6];
   w_normal[2] = obj_struct->var.circle_st.mat[10];
   normal = w_normal;
  }


/* Get point in the circle plane and measure radius */

  v_add(point,view_vect,v);
  BSxlnpl(&rc,normal,center,point,v,snap);
  if(rc != BSSUCC)
    {
     v_add(point,normal,v);
     BSxlnpl(&rc,normal,center,point,v,snap);
    }
  if(rc != BSSUCC) { return (OM_W_ABORT); }

  v_sub(snap,center,v);

  *param_val = v_len(v);

  if(obj_struct->type&conic_generic)
  {
    *param_val = fabs( *param_val - fabs(obj_struct->var.circle_st.rad) );
  }

  return(OM_S_SUCCESS );
}

end implementation COpara;
