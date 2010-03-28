/*
    Abstract:  DYrbonlnpt sets up the "additional information" needed 
               by PDdynamics when dynamically displaying a point on
               a line or on circle.

     CHANGE HISTORY:

     S.Frezefond 21-jul-86 : designed
     jla         03-nov-86 : Associative implementation
     C.H         25-jan-86 : modifications and add the circle case
-----*/

class implementation COpara;

#include  "AS_status.h"
#include  "dpdef.h"
#include  "dpmacros.h"
#include  "madef.h"
#include  "igrdef.h"
#include  "igr.h"
#include  "dpstruct.h"
#include "OMmacros.h"
#include "ASmatrix.h"
#include "bserr.h"

#define AS_DEBUG

IGRdouble fabs(), cos(), sin();
IGRint point_on_circle(), point_on_line(), mes_angle();
IGRboolean mat4_3();

from NDnode     import NDgive_structure;
from GRvg       import GRgenabsg;
from GRgraphics import GRptproject;
from GRcurve    import GRarclength;

struct online_point_header
{
  struct DPele_header *absg;        /* abst. geometry */
  IGRpoint p0,v0,p2;    /* point parent line, unit vector
                                          and  vector in defining the plane*/
  IGRdouble cent_p[3], rad, mat[9];
  IGRdouble d;              /* distance */
  IGRint def_mode;          /* definition mode */
  struct GRparms ref_par;
  IGRdouble length; 
  struct IGRbsp_curve *bc;
};

IGRint DYrbonlnpt(param_obj,linedef,l_grid,l_env,
		  pointdef, display, md_env)

struct GRid        *param_obj;
struct ret_struct *linedef;
struct GRid *l_grid ;
struct GRmd_env     *l_env;
struct ret_struct *pointdef;
struct IGRdisplay  *display;
struct GRmd_env *md_env;
{
  struct       DPele_header   header;
  struct       IGRpointset   pointset;
  IGRdouble                  pt_buffer[3];
  struct online_point_header info_para;
  IGRdouble length;
  IGRint DYonlnpt();
  IGRlong status, msg;
  IGRboolean dyn_on, inquire = 1;
  struct ret_struct param_struct;

  /*|  If dynamics is off then exit */
  DPdynflags(&msg, &inquire, &dyn_on, NULL);
  if(!dyn_on) return(1);

  pointset.num_points = 1;
  pointset.points = pt_buffer;

  /*
   *  Fill in header information
   */

  dp$build_dis_buffer ( buffer      = &header,
                        type        = IGRPS,   /*   type is point set  */
			display_att = display,
			geometry    = &pointset );

  if( linedef->type & conic_generic )
   {  /* cercle  */
    mat4_3( linedef->var.circle_st.mat, info_para.mat );
    v_equal(linedef->var.circle_st.cent_p, info_para.cent_p );
    info_para.rad = linedef->var.circle_st.rad;
    point_on_circle( info_para.cent_p, info_para.rad, info_para.mat,
                     pointdef->var.point_st.pt, info_para.p2);
    info_para.def_mode = 20;
   }
  else if( linedef->type & line_generic )
   {  /* line */
    v_equal(linedef->var.line_st.p0,info_para.p0);
    v_equal(linedef->var.line_st.v0,info_para.v0);
    point_on_line(linedef->var.line_st.p0,linedef->var.line_st.v0,
                   pointdef->var.point_st.pt,info_para.p2);
    info_para.def_mode = 10;
   }
  else
   {
    /* bspline */
    IGRpoint ref_pj;
    IGRlong rc;

    status = om$send(msg = message GRvg.GRgenabsg(&msg,
				       &l_env->md_env.matrix_type,
    				        l_env->md_env.matrix, (IGRchar **)&info_para.bc),
                     senderid = NULL_OBJID,
		     targetid = l_grid->objid,
		     targetos = l_grid->osnum);
    as$status(action = RET_STATUS);

    BSmdstptcv(info_para.bc, pointdef->var.point_st.pt, &info_para.ref_par.u, ref_pj, &length, &rc);
    if( rc != BSSUCC ) return(OM_W_ABORT);
		     
    info_para.def_mode = 30;
   }


  /* share parameter  if any */

  if(!IF_EQ_OBJID(param_obj->objid,NULL_OBJID))
  {
  /*| we are in share parameter mode : give structure*/

    status = om$send (msg      = message NDnode.NDgive_structure
					(&msg,&param_struct,md_env),
                senderid = NULL_OBJID,
		targetid = param_obj->objid,
                targetos = param_obj->osnum);
    as$status(action = RET_STATUS);
    if(param_struct.type != double_type) return OM_W_ABORT;

    info_para.d = param_struct.var.root_pm_st.value;
    info_para.def_mode += 1;
  }

  info_para.absg = &header;

  /*  Invoke dynamics  */

  dp$dynamics( dyn_fun = DYonlnpt, information = &info_para );

 
  return ( TRUE );
}

#argsused
IGRint DYonlnpt( info_para,
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

struct   online_point_header    *info_para;
/*struct   EX_button       *point;*/
IGRpoint                  point;
IGRdouble                *matrix;
struct   GRid           **objects;
IGRint                   *num_objects;
struct   DPele_header   **buffer;
IGRint                   *num_buffers;
IGRchar                 **in_dummy1,**in_dummy2, **in_dummy3,
                     	**out_dummy1, **out_dummy2, **out_dummy3;

{
  IGRint status;     /* return status (TRUE or FALSE) */
  IGRshort un = 1, trois = 3;
  IGRpoint vtrans, vunit_trans, v;
  IGRlong msg, rc;
  IGRdouble dist, scal, pb[3];
  IGRdouble teta_point, teta_p2, diff, teta_ref, diff_ref, teta;

  status = TRUE;

  if( info_para->def_mode == 10 || info_para->def_mode == 11 )
  {
    /*  line case  */
    
      v_sub(point,info_para->p2,pb);
      scal = v_dot(pb, info_para->v0);
      v_scale( info_para->v0, scal, vtrans );
      dist = fabs(1. / scal);
      v_scale( vtrans, dist, vunit_trans);

     /* switch betwheen the different possible definition mode */


     switch (info_para->def_mode - 10)
      {

       /* new param */
        case 0 :
        break;

      /* old param */
        case 1 :
        dist = fabs(info_para->d);
        v_scale(vunit_trans, dist, vtrans);
        break;

       }  /* switch end */

      v_add(info_para->p2,vtrans, info_para->absg->geometry.point_set->points);
     }
    else if( info_para->def_mode == 20 || info_para->def_mode == 21 )
     {
      /*  circle case */

      point_on_circle( info_para->cent_p, info_para->rad, info_para->mat,
                       point, pb );                        
      mes_angle( info_para->rad, info_para->p2, pb, (IGRshort) 0, 
                 &teta_p2, &teta_point, &diff );
      modulo( &diff, 2*PI ); 
      switch (info_para->def_mode - 20)
      {

       /* new param */
        case 0 :
          break;

      /* old param */
        case 1 :
	 if( info_para->rad == 0 ) dist = 0;
	 else	 dist = fabs(info_para->d / info_para->rad);
	 modulo( &dist, 2*PI );

         if( (dist < PI && diff < PI) ||
             (dist > PI && diff > PI) )    
	    {
              diff = dist;
            }
	   else
	    {
	      diff = -dist;
	    }
         break;

       }  

      mes_angle( info_para->rad, info_para->p2, info_para->p2, (IGRshort) 0, 
                 &teta_ref, &teta_p2, &diff_ref );

      teta = teta_ref + diff;

      pb[0] = info_para->rad * cos(teta);
      pb[1] = info_para->rad * sin(teta);
      pb[2] = 0;

      MAmulmx( &msg, &trois, &trois, &un, info_para->mat, pb, v );
      MAaddvc( &msg,v,info_para->cent_p,info_para->absg->geometry.point_set->points );  

     }  
    else if( info_para->def_mode == 30 || info_para->def_mode == 31 )
     {
      IGRpoint pt_pj, dir_pt;
      struct GRparms pt_par, dir_par; 
      IGRdouble length;


      /*| bspline case */
      BSmdstptcv(info_para->bc, point, &pt_par.u, pt_pj, &length, &rc);
      if( rc != BSSUCC ) return(OM_W_ABORT);

     switch (info_para->def_mode - 30)
      {

       /* new param */
        case 0 :
          v_equal( pt_pj, info_para->absg->geometry.point_set->points );
        break;

      /* old param */
        case 1 :
    
        dir_par.u = (info_para->ref_par.u + pt_par.u)/2.;
        /*"ref_par: %lf, dir_par: %lf, pt_par: %lf\n", info_para->ref_par.u, dir_par.u, pt_par */

        BScveval( info_para->bc, dir_par.u, 0, dir_pt, &rc );
        if( rc != BSSUCC ) return(OM_W_ABORT);
           
        length = fabs(info_para->d);
        /*"length; %lf\n", length */

        BSptsdlcv(&rc, info_para->bc, &info_para->ref_par.u, dir_pt, &length, 
                  info_para->absg->geometry.point_set->points);
        if( rc != BSSUCC ) return(OM_W_ABORT);
        break;

       }  /* switch end */
     }  /* end if */
 
  *buffer = info_para->absg;
  *num_buffers = 1;

  return(1);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                             ASpointon_param
   
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#argsused
ASpointon_param(curve_def,curve_id,curve_env,point_def,pt2,view_vect,snap,param_val)

struct 	ret_struct	*curve_def;
struct	GRid		*curve_id;
struct  GRmd_env        *curve_env;
struct 	ret_struct	*point_def;
IGRdouble               *pt2,*view_vect,*snap;
IGRdouble		*param_val;

/*.ASpointon_param */
{
  IGRint	i; 
  IGRlong 	msg,status;
  IGRdouble 	v[3];

  IGRint 	point_on_line();
  IGRint 	point_on_circle();
  IGRint 	mes_angle();
  IGRboolean 	mat4_3();

  v_equal(pt2,snap);
  
		
  /*| We have a new parameter we create it */
    
  if( curve_def->type & conic_generic)
  {
    IGRdouble rad, *cent_p;
    IGRdouble mat[9], proj_ref[3], proj_pt[3];
    IGRdouble teta_pt, teta_ref;

    /*| Point on circle */

    mat4_3( curve_def->var.circle_st.mat, mat);
    rad = curve_def->var.circle_st.rad;
    cent_p = curve_def->var.circle_st.cent_p;
    point_on_circle(cent_p, rad, mat, point_def->var.point_st.pt, proj_ref);
    point_on_circle(cent_p, rad, mat, pt2, proj_pt);
    mes_angle(rad, proj_pt, proj_ref, (IGRshort)0, &teta_pt, &teta_ref,
              param_val);

    /*"teta_pt: %lf, teta_ref: %lf, param_val: %lf\n",teta_pt,teta_ref,*param_val*/
    if( *param_val >  PI) *param_val = *param_val - 2*PI;
    if( *param_val < -PI) *param_val = *param_val + 2*PI;
    *param_val = *param_val * rad;
  }
  else if( curve_def->type & line_generic)                   
  {
    IGRdouble BSdotp();
    /*| Point on line */
    v_sub(pt2,point_def->var.point_st.pt,v);
    *param_val = BSdotp( &msg, curve_def->var.line_st.v0, v );
  }
  else 
  {
    IGRpoint 	ref_pj, pt_pj, mid_pt;
    struct GRparms ref_par, pt_par, mid_par; 

    /*| Point on bspline */

    status = om$send(msg      = message GRgraphics.GRptproject
                                     (&msg,&curve_env->md_env.matrix_type,
                                      curve_env->md_env.matrix,
		                      point_def->var.point_st.pt, ref_pj,
                                      &ref_par),
                          senderid = NULL_OBJID,
		          targetid = curve_id->objid,
                          targetos = curve_id->osnum);
    as$status();

    status = om$send(msg      = message GRgraphics.GRptproject
                                     (&msg,&curve_env->md_env.matrix_type,
                                      curve_env->md_env.matrix,
	                              pt2,pt_pj,&pt_par),
                          senderid = NULL_OBJID,
	                  targetid = curve_id->objid,
                          targetos = curve_id->osnum);
    as$status();

    mid_par.u = 0.5 * (ref_par.u + pt_par.u);
    for(i=0;i<3;i++) mid_pt[i] = (ref_pj[i] + pt_pj[i]) / 2.;

    status = om$send(msg      = message GRcurve.GRarclength
                                     (&msg,&curve_env->md_env.matrix_type,
                                      curve_env->md_env.matrix, 
		                      ref_pj, ref_pj, pt_pj, &ref_par, 
                                      &mid_par, &pt_par, param_val),
                          senderid = NULL_OBJID,
		          targetid = curve_id->objid,
                          targetos = curve_id->osnum);
    as$status();
    }

  return(OM_S_SUCCESS);
}

end implementation COpara;
