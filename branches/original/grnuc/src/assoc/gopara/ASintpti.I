/*\  intersection point. implementation file

HISTORY
     sf           feb-86  : Design date (exec0)
     sf           jul-86  : conversion to ems
     jla       03-nov-86  : associative implementation
     jla       05-oct-87  : intersection with lbsys
     scw       24-jun-92  : added static ANSI C prototypes

\*/

class implementation ASintpt;



#include "OMmacros.h"
#include "ASmatrix.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "bserr.h"
#include "AS_status.h"
#include "ASmsg.h"
#include "msmacros.h"

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int get_extended_geom __((struct GRid *obj, IGRchar **geometry));
static int cmp_int_cv_cv __((struct GRid *obj0, struct GRid *obj1, 
                             double *pt_init, double *pt_res));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe

#define AS_DEBUG 1

#define  LINE    0
#define  CIRCLE  1
#define  LBSYS   2
#define  OTHER   4

#define  FIRST   4

#define  LINE_LINE     0
#define  LINE_CIRCLE   1
#define  LINE_LBSYS    2
#define  CIRCLE_CIRCLE 5
#define  CIRCLE_LBSYS  6

#define FIRST_REAL  0x02  /* first intersection returned by cmp_int* is real */
#define SECOND_REAL 0x04  /* second intersection returned by cmp_int* is real */
#define FIRST_APP   0x08  /* first intersection is min distance point */
#define SECOND_APP  0x10  /* first intersection is min distance point */

#define EPSILON 1.e-10

double fabs();

extern GRclassid OPP_GR3dpoint_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                         find_inter_case function

  find the intersection case and put the object in the right order to
  obtain line_line, line_circle, circle_circle, line_lbs, circle_lbs
  intersection

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

find_inter_case (in0,in1,out0,out1,obj0,obj1)

struct ret_struct  	*in0,*in1,**out0,**out1;
struct GRid 		*obj0,*obj1;
{
  IGRint 	type,type0,type1;
  struct GRid 	prov;

  /* first identify the type of the object */

  type = in0->type;
       if (type & line_generic ) type0 = LINE;
  else if (type & conic_generic) type0 = CIRCLE;
  else if (type & lbs_generic  ) type0 = LBSYS;
  else 				 type0 = OTHER;

  type = in1->type;
       if (type & line_generic ) type1 = LINE;
  else if (type & conic_generic) type1 = CIRCLE;
  else if (type & lbs_generic  ) type1 = LBSYS;
  else 				 type1 = OTHER;

/* now put it in the good order and return intersection case */

  if(type1 >= type0)
    {
     *out0 = in0; *out1 = in1;
     return(FIRST*type0 + type1);
    }
  else
    {
     *out0 = in1; *out1 = in0; 
     prov = *obj1; *obj1 = *obj0; *obj0 = prov;
     return(FIRST*type1 + type0);
    }
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                         cmp_int_line_line function

   find intersection between line defined by point p0 vector v0
			 and line defined by point p1 vector v1
   If the 2 lines are parallel return an arbitrary point far enought 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

cmp_int_line_line(p0,v0,p1,v1,int_pt)

IGRdouble *p0,*v0,*p1,*v1,*int_pt;
{
    IGRdouble t0,t1,w[3];
    static IGRdouble half = 0.5;

    if(!line_prox_line(p0,v0,p1,v1,&t0,&t1)) {t0 = 1.e+4; t1 = 1.e+4;}
    
    /* now compute 0.5*(p0+t0*v0 + p1+t1*v1) */

    t0 = t0*0.5; t1 = t1*0.5;
    v_comb(half,p0,t0,v0,int_pt);
    v_comb(half,p1,t1,v1,w);
    v_add(int_pt,w,int_pt);

    return(1);

}
    
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                        cmp_int_line_circle function

                intersection point between a line and a circle

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
   
cmp_int_line_circle(p0,v0,circle_st,res1,angle1,res2,angle2)

IGRdouble *p0,*v0;
struct circle_data *circle_st;
IGRdouble *res1,*angle1,*res2,*angle2;
/*.cmp_int_line_cir */
{
  IGRpoint pa,pb,va,pl,vtrans;
  IGRdouble  circle3mat[9];
  IGRdouble rad, *cent;
  IGRdouble ln,linter;
  IGRdouble atan2(),modulo();
 

  rad = circle_st->rad;
  cent = circle_st->cent_p;
  /*"rad %lf\n",rad */
  /*^ pr_point("cent",cent);
      pr_point("p0",p0);
      pr_point("v0",v0);
  */

  /*  go to 3 3 matrix   */
  mat4_3(circle_st->mat,circle3mat);


  /* convert from world to local coord of the circle */
  v_sub(p0,cent,pa);
  mt_mul_v( circle3mat, pa, pa );
  mt_mul_v( circle3mat, v0, va );

  /*
  we use a quicker method if the line and the circle are 
  in the same plane
  */

  /*^ pr_point("pa",pa);
      pr_point("va",va);
  */

  if((fabs(pa[2]) <= 0.001* rad) && (fabs(va[2]) <= 0.001))
  {
    /*| same plane */
    v_identity(pb);
    point_on_line( pa, va, pb , pl); 
    ln = v_len(pl);
    ln = rad*rad - ln*ln;

    if (ln < 0.)
     {
      linter=0.;
     }
    else
     {
      linter = sqrt(ln);
      v_scale(va,linter,vtrans);
      v_add(pl,vtrans,res1);
      v_sub(pl,vtrans,res2);
     }

   /* calculate the corresponding angle */
  
      *angle1 = atan2(res1[1],res1[0]);
      modulo(angle1,2*PI);
      *angle2 = atan2(res2[1],res2[0]);
      modulo(angle2,2*PI);

   /* pass to global coordinate */
 
     m_mul_v(circle3mat,res1,res1);
     v_add(cent,res1,res1);
     
     m_mul_v(circle3mat,res2,res2);
     v_add(cent,res2,res2);
     if(ln>0) return (FIRST_REAL | SECOND_REAL);
         else return (FIRST_APP  | SECOND_APP);
  }
 else
  {
    /*| --> 3d */
    return(FIRST_APP | SECOND_APP);
  }
 
}   /*   end cmp_intersection line circle   */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                         cmp_int_line_lbs function

    find the intersection point between a line and a box
    If flag = 0 return the nearest from init_pt in result
    If flag = 1 return the farest

    other is the other intersection point

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  
cmp_int_line_lbs(p0,p00,lbs_def,init_pt,flag,result,other)

IGRdouble *p0,*p00,*init_pt,*result,*other;
IGRint flag;
struct lbs_data *lbs_def;
/*.cmp_int_line_lbs*/
{
  IGRint iside,i,j,it;
  IGRdouble v0[3],p1[3],*v1 = NULL,inter[6],axex[3],axey[3],w[3];
  IGRdouble t0,t1;
  IGRdouble half = 0.5;


/* vector on line. Its lenght is the lenght of the line */

  v_sub(p00,p0,v0);

/* compute in global coordinate origine and axex axey of the box */


     j=0;
     for(i=0;i<3;i++,j=j+4)
        { axex[i] = lbs_def->matrix[j] *
		     (lbs_def->diag_pt2[0] - lbs_def->diag_pt1[0]);
          axey[i] = lbs_def->matrix[j+1] *
     		     (lbs_def->diag_pt2[1] - lbs_def->diag_pt1[1]);
          p1[i] = lbs_def->matrix[j+3] +
         	  lbs_def->matrix[j]   * lbs_def->diag_pt1[0] +
         	  lbs_def->matrix[j+1] * lbs_def->diag_pt1[1];
        }
  

/* Loop on the side. I need for each initial point and vector */

 it = 0;
 for(iside=0;iside<4;iside++)
  {

   switch (iside)
      {
      case 0 : v1=axex; break;
      case 1 : v1=axey; break;
      case 2 : v_neg (axex,axex);v1=axex; break;
      case 3 : v_neg (axey,axey);v1=axey; break;
     }
 
/* Try to find an intersection point on each edge */ 

   if(line_prox_line(p0,v0,p1,v1,&t0,&t1))
      {
/* JLA 19 June 89 to have intersection on the extension if the line */
/*       if(t0<1 && t0>0 && t1<1 && t1>0) JLA 12-June-89 */
       if(t1<1 && t1>0)

	  {
	   t0 *= 0.5; t1 *= 0.5;
	   v_comb(half,p0,t0,v0,w);
	   v_comb(half,p1,t1,v1,inter+it);
	   v_add(inter+it,w,inter+it);
	   it += 3;
 	   if( it == 6) break;
	  }
      }
     
/* origine for next vector */
   v_add(p1,v1,p1);

 }

/* now determine witch one is to be used */

/* There is 2 points */

  if (it == 6)
     {
      v_sub(inter,init_pt,w);
      t0 = v_len(w);
      v_sub(inter+3,init_pt,w);
      t1 = v_len(w);
     
      if ((t0>t1) == flag)   /* return the nearest */
         {v_equal(inter,result);v_equal(inter+3,other);}
      else
         {v_equal(inter+3,result);v_equal(inter,other);}
      }

/* only one */
  else if (it ==3)
      { v_equal(inter,result); v_equal(result,other); }

/* not at all need to return a default value */
  else 
     { v_comb(half,p0,half,p00,result); v_equal(result,other); }

 return 1;
     
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                         cmp_int_circle_lbs function

                    Intersection between an arc and a lbsys

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  
cmp_int_circle_lbs(cir_def,lbs_def,res1,res_an1,res2,res_an2)

struct circle_data *cir_def;
struct lbs_data *lbs_def;
IGRdouble *res1,*res_an1,*res2,*res_an2;
/*.cmp_int_circle_lbs*/
{
  IGRint code,iside,i,j,it;
  IGRdouble p1[3],*v1 = NULL,unitx[3],unity[3],w1[3],w2[3];
  IGRdouble lenx,leny,len = 0.0;
  IGRpoint inter1,inter2;
  IGRdouble angle1,angle2;
  IGRdouble scal;
  IGRdouble one=1;
  IGRdouble sin(),cos(),modulo();

/* compute in global coordinate origine and axex axey of the box */


     j=0;
     for(i=0;i<3;i++,j=j+4)
        { unitx[i] = lbs_def->matrix[j];
          unity[i] = lbs_def->matrix[j+1];
          p1[i]   = lbs_def->matrix[j+3] +
         	    lbs_def->matrix[j]   * lbs_def->diag_pt1[0] +
         	    lbs_def->matrix[j+1] * lbs_def->diag_pt1[1];
        }
     lenx = (lbs_def->diag_pt2[0] - lbs_def->diag_pt1[0]);
     leny = (lbs_def->diag_pt2[1] - lbs_def->diag_pt1[1]);

/* Initialise angle value */

   *res_an1 =  1.e+10;
   *res_an2 = -1.e+10;

  

/* Loop on the side. I need for each initial point and vector */

 it = 0;
 for(iside=0;iside<4;iside++)
  {

   switch (iside)
      {
      case 0 : v1=unitx;len =  lenx; break;
      case 1 : v1=unity;len =  leny; break;
      case 2 : v1=unitx;len = -lenx; break;
      case 3 : v1=unity;len = -leny; break;
     }

  /* compute intersection */

 /*^
  pr_point("p1",p1);
  pr_point("v1",v1);
 */
     code = cmp_int_line_circle(p1,v1,cir_def,inter1,&angle1,inter2,&angle2);
     angle1 = angle1-cir_def->start_angle;
     modulo(&angle1,2*PI);

     angle2 = angle2-cir_def->start_angle;
     modulo(&angle2,2*PI);

/*"angle1 %lf angle2 %lf\n",angle1,angle2 */

  /* Is intersection inside the arc */

/******* JLA 19 June 89 to have intersection on the extension of the arc ****/
/*     if(code & FIRST_REAL)
/*        {
/*    if(angle1>cir_def->sweep_angle) code = code & ~FIRST_REAL;
/*        }
/*
/*      if(code & SECOND_REAL)
/*        {
/*    if(angle2>cir_def->sweep_angle) code = code & ~SECOND_REAL;
/*        }
/*****  end modif *****************/


  /* Are the intersections inside the edge */

     if(code & FIRST_REAL)
       {
        v_sub(p1,inter1,w1);
	v_comb(one,p1,len,v1,w2);v_sub(w2,inter1,w2);
	scal = v_dot(w1,w2);
	if(scal < 0 )
	  {
	   /*|inside box */
           if(angle1<*res_an1) {*res_an1 = angle1; v_equal(inter1,res1);}
           if(angle1>*res_an2) {*res_an2 = angle1; v_equal(inter1,res2);}
	  }
       }

     if(code & SECOND_REAL)
       {
        v_sub(p1,inter2,w1);
	v_comb(one,p1,len,v1,w2);v_sub(w2,inter2,w2);
	scal = v_dot(w1,w2);
	if(scal < 0 )
	  {
	   /*|inside box */
           if(angle2<*res_an1) {*res_an1 = angle2; v_equal(inter2,res1);}
           if(angle2>*res_an2) {*res_an2 = angle2; v_equal(inter2,res2);}
	  }
       }

   v_comb(one,p1,len,v1,p1);
  }

/* compute defaut solution */

   if(*res_an1 > 0.5e+10)
     {
      *res_an1 =0.5*cir_def->sweep_angle;
      res2[0] = cir_def->rad*cos(*res_an1+cir_def->start_angle);
      res2[1] = cir_def->rad*sin(*res_an1+cir_def->start_angle);

      for(i=0,j=0;i<3;i++,j++)
         res1[i] = cir_def->mat[j++]*res2[0] + cir_def->mat[j++]*res2[1]
		   + cir_def->mat[++j]; 
      v_equal(res1,res2);
      *res_an2 = *res_an1;
     }

 return 1;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                         choice_circle_lbsys function

   between point0,angle1 and point1,angle1
   choice of solution for circle lbsys intersection depending on in_flag
   in_flag                solution
      0            nearest fron near_point
      1            farest fron near_point
      2		   first on arc
      3		   second on arc
   res is pointer to this solution. nb_res is its index (0 or 1)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  
choice_circle_lbsys(in_flag,near_point,point0,angle0,point1,angle1, nb_res)
  
IGRint in_flag;
IGRdouble *near_point,*point0,*point1;
IGRdouble angle0,angle1;
IGRint *nb_res;

{
   IGRdouble w[3],d0,d1;

    
   if(in_flag<2)           /* test proximity with near_point */
     {
      v_sub(point0,near_point,w);d0 = w[0]*w[0] + w[1]*w[1] + w[2]*w[2];
      v_sub(point1,near_point,w);d1 = w[0]*w[0] + w[1]*w[1] + w[2]*w[2];
      *nb_res = ((d0<d1) == in_flag);
     }


   else			   /* take first or second point on arc */
     {
      in_flag = in_flag-2;
      *nb_res =( (angle0<angle1) == in_flag);
     }


   return 1;
  }

/*
   return the extended geometry of an element 
   It is up to the caller to free corresponding memry 
*/



static get_extended_geom(obj,geometry)
struct GRid *obj;
IGRchar **geometry;
{
 struct GRmdenv_info env;
 IGRlong size;
 IGRlong status,msg;
 struct GRid object;
 struct IGRbsp_curve *bs;

  *geometry = NULL;
  status = om$send(msg = message NDnode.ASreturn_go(&object,
						 &env.matrix_type,env.matrix),
		   senderid = NULL_OBJID,
           	   targetid = obj->objid ,
           	   targetos = obj->osnum );
  as$status(action = RET_STATUS);
   

  status = om$send(msg      = message GRvg.GRgetexsize
                                        (&msg,&(env.matrix_type),env.matrix,
                   	                 &size),
		   senderid = NULL_OBJID,
           	   targetid = object.objid ,
           	   targetos = object.osnum );
  as$status(action = RET_STATUS);

  *geometry = (char *)malloc(size);
  if(*geometry == NULL)
    {
     printf("ASintpt Error in dynamic allocation\n");
     return(OM_W_ABORT);
    }
  /*| call GRgetgeom */
  status= om$send(msg      = message GRvg.GRgetexgeom
                                       (&msg,&(env.matrix_type),env.matrix, 
	                                *geometry),
		  senderid = NULL_OBJID,
           	  targetid = object.objid ,
           	  targetos = object.osnum );
  as$status(action = RET_STATUS);

  /* extended linear element .... because not done int GRextgeom */

  bs = (struct IGRbsp_curve *) *geometry;
  if( bs->order == 2 && bs->num_poles >= 2 && !bs->phy_closed)
    {
     double fac1 =  51, /* to multiply the first and last segment by 50       */
	    fac2 = -50;
     double pt_save[3];/* to not multiply by 2500 2 poles linestring          */
     double *p1,*p2;
     v_equal(bs->poles+3*bs->num_poles-6,pt_save);
     p1 = bs->poles; p2 = p1+3;
     v_comb(fac1,p1,fac2,p2,p1);
     p1 = &(bs->poles[3*bs->num_poles-3]);
     v_comb(fac1,p1,fac2,pt_save,p1);
    }
 
  return (OM_S_SUCCESS);
 }




/* intersection between 2 curves with extends */

static cmp_int_cv_cv(obj0,obj1,pt_init,pt_res)
  struct GRid *obj0,*obj1;
  double *pt_init,*pt_res;

   {
    IGRlong status;
    IGRint              i,num;
    IGRlong		rc;
    IGRchar		*geometry0,*geometry1;
    IGRdouble		*par1, *par2, dist;
    IGRpoint 		*pt1, *pt2;
    IGRboolean 		BSmdistcvcv();

    /* 
      modif momo : 13-01-89 
      compute intersection with BSmdistcvcv function instead of GR2objisect 
      modif jla 17-Aug-89 : get extend geom instead of regular geom
    */

    status = get_extended_geom(obj0,&geometry0);
    as$status(action = RET_STATUS);

    status = get_extended_geom(obj1,&geometry1);
    as$status(action = RET_STATUS);
    
    /*| call BSmdistcvcv */

    pt1  = NULL;
    pt2  = NULL;
    par1 = NULL;
    par2 = NULL;

    BSmdistcvcv(geometry0,geometry1,&num,&par1,&par2,&pt1,&pt2,&dist,&rc);

    if( rc != BSSUCC )
    {
      printf("ASintpt : Input curves had infinitely many points at witch\n");
      printf("          the minimum distance occurred\n");
      return(OM_W_ABORT);
    }

    if( num == 0 )
    {
      printf("ASintpt Error in BSmdistcvcv function ==> num = 0 \n");
      return(OM_W_ABORT);
    }

    if( num > 1 )
    {
      IGRdouble	dist1, dist_min;
      IGRint	nb,indice_dist_min;

      /*" number of solutions : %d\n", num */

      /* initialisation */
      indice_dist_min = 0;
      dist_min = 0.;
      for( i=0;i<3;i++ )
      {
        dist_min=dist_min+(pt_init[i]-pt1[0][i])*(pt_init[i]-pt1[0][i]);
      }
      /* calcul de la distance mini au snap_pt */
      for( nb=1; nb<num; nb++ )
      {
        dist1=0.;
        for(i=0;i<3;i++)dist1=dist1+(pt_init[i]-pt1[nb][i])*(pt_init[i]-pt1[nb][i]);
        if( dist1 < dist_min )
        {
           indice_dist_min = nb;
           dist_min = dist1;
        }
      }

      v_equal( pt1[indice_dist_min], pt_res );
    }
    else for( i=0;i<3;i++ ) pt_res[i] = (pt1[0][i] + pt2[0][i])/2. ;

    /*| free of allocate memory */

    if( pt1      != NULL ) free( pt1 );
    if( pt2      != NULL ) free( pt2 );
    if( par1     != NULL ) free( par1 );
    if( par2     != NULL ) free( par2 );
    if( geometry0 != NULL ) free( geometry0 );
    if( geometry1 != NULL ) free( geometry1 );
    return(OM_S_SUCCESS);
     
    /* end of modif : momo 13-01-89 */

   }

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
                             ASintpt.place method

                     this method  does a non-interactive place

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  
method NDplace(struct GRas *asso_lis; struct GRmd_env *md_env;
               IGRchar *go_cnst_lis )
{
  IGRint 		inter_of,count;
  IGRlong 		msg,status;
  IGRpoint 		work_pt;
  IGRdouble 		*snap_pt;
  IGRdouble 		d1,d2;
  struct GRid 		*tab,obj0,obj1;
  struct ret_struct  	pardef0,pardef1,pardef2,objdef,*intdef0,*intdef1;

  count  = asso_lis->num_parents;
  tab    = asso_lis->parents;

  /*"nb parents %d\n%d %d , %d %d\n",count,tab->objid,tab->osnum,(tab+1)->objid,(tab+1)->osnum*/

  if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
      snap_pt = (IGRdouble *) asso_lis->as_attr;
  else
   {
    status = as$any_give_structure(go_grid = asso_lis->go_objid,
                       		   mod_env = md_env,
				   inst    = &objdef );
    as$status(action = RET_STATUS);
    snap_pt = objdef.var.point_st.pt;
   }

  if((count!= 2)&&(count!=3)) return(OM_W_ABORT);

  /*| parent definition. Take it in good order and compute case */
  status = om$send( msg = message NDnode.NDgive_structure(&msg,&pardef0,md_env),
          	    targetid = tab[0].objid, targetos = tab[0].osnum);
  as$status(action = RET_STATUS);

  status = om$send( msg = message NDnode.NDgive_structure(&msg,&pardef1,md_env),
                    targetid = tab[1].objid, targetos = tab[1].osnum);
  as$status(action = RET_STATUS);

  obj0 = tab[0]; obj1 = tab[1];
  inter_of = find_inter_case (&pardef0,&pardef1,&intdef0,&intdef1,&obj0,&obj1);

  /*  we use the track point for the orientation */
//  if (inter_of!=LINE_LINE)
//  {
    /*
  is there an active track_point
  ME.ASintpt->orient is used to distinguish the chosen solution if
  there is no track point
     for the place we call the computing function with
         -1 if there is an active trackpoint
         -2 if not
     in return we get :
          0 or 1 to distinguish the solution
*/
    ME.ASintpt->orient = -2;
    if (count==3)
    {
      status=om$send(msg=message NDnode.NDgive_structure(&msg,&pardef2,md_env),
          	       targetid = tab[2].objid ,
          	       targetos = tab[2].osnum);
      as$status(action = RET_STATUS);

      if (pardef2.type & point_generic)
      {
        v_equal(pardef2.var.point_st.pt,snap_pt);
        ME.ASintpt->orient = -1;
      }
    }
//  } /* if not line line */

  /*------------------------------------------------------------------
   compute the intersection of the two object
  --------------------------------------------------------------------*/

  switch (inter_of)
  {

  case LINE_LINE :

    cmp_int_line_line(intdef0->var.line_st.p0,intdef0->var.line_st.v0,
        	      intdef1->var.line_st.p0, intdef1->var.line_st.v0,
        	      work_pt);
    break;

  case LINE_CIRCLE :

    {
     IGRint iii;
     iii = ME.ASintpt->orient;
    if (cmp_intersection_line_circle(intdef0->var.line_st.p0, 
        intdef0->var.line_st.p1, intdef1->var.circle_st, snap_pt, 
	work_pt,&iii) == 0)  return(OM_W_ABORT);
     ME.ASintpt->orient = iii;
    break;
   }


  case CIRCLE_CIRCLE :

    {
     IGRint iii;
     iii = ME.ASintpt->orient;
    if (cmp_intersection_circle_circle(intdef0->var.circle_st, 
        intdef1->var.circle_st, snap_pt, work_pt, &iii) == 0)return(OM_W_ABORT);
     ME.ASintpt->orient = iii;
    break;
   }
  case LINE_LBSYS :
    {
     IGRdouble other[3],*ref,w[3];
     cmp_int_line_lbs(intdef0->var.line_st.p0,intdef0->var.line_st.p1,
		     &intdef1->var.lb_st,snap_pt,0,work_pt,other);

     /* initialize me->orient

             value     with track point     whitout
              0        nearest              first on line
              1        farest               second on line
     */

     if(count == 3) ref = pardef2.var.point_st.pt;
              else  ref = intdef0->var.line_st.p0;
     v_sub(work_pt,ref,w); d1 = v_len(w);
     v_sub(other,ref,w);   d2 = v_len(w);
     me->orient = (d2<d1);
     break;
    }

  case CIRCLE_LBSYS :
    {
     IGRdouble other[3],*ref,w[3],angle1,angle2;
     IGRint ret_sol;
     cmp_int_circle_lbs(&intdef0->var.circle_st,&intdef1->var.lb_st,
			work_pt,&angle1,other,&angle2);

     choice_circle_lbsys(0,snap_pt,work_pt,angle1,other,angle2,&ret_sol);
     

     /* initialize me->orient

             value     with track point     whitout
              0        nearest              first on arc
              1        farest               second on arc
     */

     if(count == 3)
		  {ref = pardef2.var.point_st.pt;
     		   v_sub(work_pt,ref,w); d1 = v_len(w);
     		   v_sub(other,ref,w);   d2 = v_len(w);
     		   me->orient = ((d2>d1) == ret_sol);
		  }
     else me->orient = ret_sol;

     if(ret_sol == 1) v_equal(other,work_pt);

     break;
    }

  default :
     status = cmp_int_cv_cv(&obj0,&obj1,snap_pt,work_pt);
     as$status(action = RET_STATUS);

  } /* end of while */

/* create the corresponding graphic point */

 if(go_cnst_lis != NULL)
   {
    struct IGRpolyline geom;

    /*| Construct the G.O */
    geom.num_points = 1;
    geom.points     = work_pt;

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (char *) &geom;

    status = om$send( msg = message ASnode.ASconstruct_go
		     (asso_lis,md_env,go_cnst_lis, OPP_GR3dpoint_class_id,TRUE),
	              targetid = my_id ); 
    as$status(action = RET_STATUS);

  }

  /*------------------------------------------------------------------
  we ask the graph manager to add the new ASintpt to the graph 
  --------------------------------------------------------------------*/

  status = om$send( msg = message NDnode.NDconnect( asso_lis->num_parents,
  		    asso_lis->parents, NULL_GRID, ND_NEW ),
		    targetid = my_id);
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);

} /* place */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
                             ASintpt.compute method

           re_compute the intersection point after a parent change

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      IGRint count; struct GRid list[]; struct GRmd_env *md_env)
{
  IGRint 		inter_of;
  IGRlong 		status;
  IGRpoint   		work_pt;
  IGRdouble 		*init_pt;
  struct GRid 		obj0,obj1;
  struct ret_struct  	pardef0,pardef1,pardef2,*intdef0,*intdef1;
  double one =1, hundred = -100;

  if((count!=2) && (count!=3))
  {
    printf("ASintpt.compute_node bad parent number \n");
    return(OM_W_ABORT);
  }

/* take track point definition if any  */

  if(count==3)
   {
    status = om$send(msg = message NDnode.NDgive_structure(msg,&pardef2,md_env),
             	     targetid = list[2].objid, targetos = list[2].osnum );
    as$status(action = RET_STATUS);
    if (!(pardef2.type & point_generic))
     { printf("ASintpt.compute_node : wrong type for the orienting point");
      return(OM_W_ABORT); }
   }
  else
   {
    status = om$send(msg = message NDnode.NDgive_structure(msg,&pardef2,md_env),
             targetid = my_id );
    as$status(action = RET_STATUS);
    }
  init_pt = pardef2.var.point_st.pt;

  /*| parent definition. Take it in good order and compute case */

    status = om$send(msg = message NDnode.NDgive_structure(msg,&pardef0,md_env),
           targetid = list[0].objid ,
           targetos = list[0].osnum );
    as$status(action = RET_STATUS);

    status = om$send(msg = message NDnode.NDgive_structure(msg,&pardef1,md_env),
           targetid = list[1].objid ,
           targetos = list[1].osnum );
    as$status(action = RET_STATUS);

 
  obj0 = list[0]; obj1 = list[1];
  inter_of = find_inter_case (&pardef0,&pardef1,&intdef0,&intdef1,&obj0,&obj1);


/*    compute the intersection of the two entities    */

  switch (inter_of)
  {
  case (LINE_LINE) :
  /*| line_line */

   cmp_int_line_line (intdef0->var.line_st.p0,intdef0->var.line_st.v0,
		      intdef1->var.line_st.p0,intdef1->var.line_st.v0,
		      work_pt);
    break;

  case (LINE_CIRCLE) :
  /*| line_circle */

    {
     IGRint iii;
     iii = ME.ASintpt->orient;
     if(! cmp_intersection_line_circle(intdef0->var.line_st.p0,
	 		intdef0->var.line_st.p1, intdef1->var.circle_st, 
			init_pt, work_pt, &iii) )
	{printf("intersection error \n");
	 printf("previous solution will remain\n");
	 return(OM_S_SUCCESS);
	}
     ME.ASintpt->orient = iii;
    }
    break;

  case (CIRCLE_CIRCLE) :

  /*| circle_circle */
    {
     IGRint iii;
     iii = ME.ASintpt->orient;
    if(! cmp_intersection_circle_circle(intdef0->var.circle_st, 
        		intdef1->var.circle_st, init_pt, work_pt, &iii) )
	{printf("intersection error \n");
	 printf("previous solution will remain\n");
	 return(OM_S_SUCCESS);
	}
     ME.ASintpt->orient = iii;
     break;
    }
  case LINE_LBSYS :
  /*| line_lbsys */
    {
     IGRdouble other[3],ref[3];
     
     if(count == 3) v_equal(init_pt,ref);
     else           v_comb(one,intdef0->var.line_st.p0,
		       hundred,intdef0->var.line_st.v0,ref);
     cmp_int_line_lbs(intdef0->var.line_st.p0,intdef0->var.line_st.p1,
		     &intdef1->var.lb_st,ref,me->orient,work_pt,other);
     break;
    }

  case CIRCLE_LBSYS :
  /*| circle_lbsys */
    {
     IGRdouble other[3],angle1,angle2;
     IGRint ret_sol,flag;
     
     cmp_int_circle_lbs(&intdef0->var.circle_st,&intdef1->var.lb_st,
			work_pt,&angle1,other,&angle2);
     if(count == 2) flag = me->orient+2;   /* test on angle */
            else    flag = me->orient;     /* test on distance */
     choice_circle_lbsys(flag,pardef2.var.point_st.pt,work_pt,angle1,
			 other,angle2,&ret_sol);
     if(ret_sol == 1) v_equal(other,work_pt);
     break;
    }
  
  default :
     status = cmp_int_cv_cv(&obj0,&obj1,init_pt,work_pt);
     if(!(status&1))
	{printf("intersection error \n");
	 printf("previous solution will remain\n");
	 return(OM_S_SUCCESS);
	}

  } /* end of while */


/* update the graphic associated object */

  {
    struct GRpost_info post_info;
    GRobjid newobjid;
    struct IGRpolyline polyline;

    polyline.num_points = 1;
    polyline.points = work_pt;
    post_info.construct_flag = FALSE;

    status = om$send(msg          = message GRlinear.GRputpolyline
				            (msg,md_env,&post_info,&polyline,
                                             &newobjid),
	             p_chanselect = &AS_to_comp );
    as$status(action = RET_STATUS);
 }

 return(OM_S_SUCCESS);

}    /* end of compute_nod method */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
                             ASintpt.NDprint method

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */

method NDprint( struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  OMuint              icount;              /* Index for loop                  */
  struct ret_struct   my_def,ret1,ret2;    /* Definitions of the object       */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  IGRlong msg;
  int orient1,orient2;
 
  struct GRid parent_list[3];

  /* Get the structure of the class */

  om$send( msg = message NDnode.NDgive_structure(&msg, &my_def, md_env),
           targetid = my_id );

  /* Get the name of this object */
  as$printer_set_name(prefix="INT_POINT",name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and symbology */
  as$printer_print_parents(count=&count,
			   list = parent_list,
			   size = 3);
  as$printer_print_symb();
  

  /* Print the instances (snap point) and message */

  for (icount=0; icount<3 ; icount++)
      fprintf(stream,"ptr[%d]=%lf;\n",icount,my_def.var.point_st.pt[icount]);

  fprintf(stream,"send ASintpt.place(%d,list,ptr) to %s;",count,name);
  /* SGAO flag now */
  orient1 = 0;
  orient2 = 0;

   om$send( msg = message NDnode.NDgive_structure(&msg, &ret1, md_env),
            targetid = parent_list[0].objid );
   om$send( msg = message NDnode.NDgive_structure(&msg, &ret2, md_env),
            targetid = parent_list[1].objid );
   if(ret1.type & ret2.type & line_generic) {}
   else if(ret1.type & line_generic)  orient1 = 1 - me->orient;
   else if(ret2.type & line_generic) orient2 = 1 - me->orient;
   else if(ret1.type &conic_generic) orient1 = 1 - me->orient;

   fprintf(stream," /* REVERSE : %d %d */\n\n",orient1,orient2);

  return(OM_S_SUCCESS);
}/* end print */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
                             ASintpt.GRgetobjinfo method

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
    {
     *msg = MSSUCC;
     ex$message (buff=info->type,msgnumb=AS_I_IntPt);
     return(OM_S_SUCCESS);
    }

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
                             ASintpt.ASpossible_parent method

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
IGRint i, j;
 
 *nb_tot = 3;
 if( ifrom < 0 ) ifrom = 0;
 if( ito  < ifrom ) { *nb_return = 0; return(OM_S_SUCCESS); }
 if( ito  > *nb_tot - 1 ) ito = *nb_tot - 1;
 *nb_return = ito - ifrom + 1;
 
 for( i = ifrom, j = 0; i <= ito ; i++, j++ )
  switch( i )
  {
   case 0 : 
    {
     geom_code[j]   = ~0;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 1 :
    {
     geom_code[j]   = ~0;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 2 :
    {
     geom_code[j]   = point_generic;
     option_code[j] = 2;/* optional track_point */
     break;
    }
  } /*  end switch  */

 *index_track = -1;  /* no track point */
 *index_ref   = -1;  /* no ref. */
 *index_plan  = -1;  /* no plan        */

 /*| look for the index of the optional root */
 om$send( msg = message ASnode.ASget_opt_ind( 2,
	  index_track, index_ref, index_plan ), targetid = my_id );

 return(OM_S_SUCCESS);
}


end implementation ASintpt;
