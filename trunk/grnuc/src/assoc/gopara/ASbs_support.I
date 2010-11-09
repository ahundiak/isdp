/*****************************************************************************/
/*      								     */
/*   This file gather the function to handle bspine			     */
/*   used by keypoint, tangent point               			     */
/*      								     */
/*****************************************************************************/

/*
    HISTORY

	Sudha	24 Oct 94	Fix TR# 119422104 TD/SSL - added BSprototyping

*/


class implementation ASnode;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "masubvc.h"
#include "malenvc.h"
#include "maidmx.h"
#include "madotvc.h"
#include "mabcueval.h"
#include "mabcu1der.h"
#include "bsprptoncv.h"
#include "bsmdstptcv.h"
#include "bsarcofpts.h"
#include "bsarclen.h"


#define AS_DEBUG

#define ONCV_VER 1
#define ANGL_VER 2

#define EPS 1.e-6


extern GRclassid OPP_GR3dpoint_class_id;

/*
   function to adjust parameter value when out of boundary
*/

ASadjust_u(u_enter,u_exit,bc)
   IGRdouble *u_enter;		/* entered u */
   IGRdouble *u_exit;		/* returned value */
   struct IGRbsp_curve *bc;	/* returned curve */
{
   *u_exit = *u_enter;
   if(*u_enter < 0)
     {
     if(bc->phy_closed){*u_exit += 1;return(1);}
                  else {*u_exit  = 0;return(0);}
     }

   else if(*u_enter >1)
     {
     if(bc->phy_closed) {*u_exit -= 1;return(1);}
                  else  {*u_exit  = 1;return(0);}
     }
     /*"ASadjust_u entry %lf exit %lf\n",*u_enter,*u_exit */

   return(MSSUCC);
}

/*
   function to adjust pole number  when out of boundary
*/

ASadjust_i(i_enter,i_exit,bc)
   IGRint  i_enter;		/* entered i */
   IGRint *i_exit;		/* returned value */
   struct IGRbsp_curve *bc;	/* returned curve */
/*.ASadjust_i*/
{
   /*"i_enter %d phy_closed %d\n",i_enter,bc->phy_closed*/
   *i_exit = i_enter;
   if(i_enter < 0)
     {
     if(bc->phy_closed)
	{if(bc->periodic){ *i_exit += bc->num_poles;}
	 else 	         { *i_exit = *i_exit+bc->num_poles-1;}
         goto success;
        }
     else
       {*i_exit  = 0;goto failure;}
     }

   else if(i_enter >= bc->num_poles)
     {
     if(bc->phy_closed)
       {if(bc->periodic){ *i_exit -= bc->num_poles;}
        else		{ *i_exit  = *i_exit-bc->num_poles+1;}
	goto success;
       }
     else
       {*i_exit  = bc->num_poles-1;goto failure;}
     }
   success :
   /*"i_exit %d\n",*i_exit */ return(1);
   failure :
   /*|adjust_i fails n*/ return(0);
}


/*
    function to find on a b_spline the point with tangent normal
    to a given vector
*/

AStangent(bc,normal,u_init,u_final,p_final,tangent)
   struct IGRbsp_curve *bc;    	/* b_spline curve */
   IGRvector normal;          	/* vector the curve is to be normal to */
   IGRdouble *u_init;		/* initial parameter value  */
   IGRdouble *u_final;		/* returned solution */
   IGRdouble *p_final;          /* corresponding point */
   IGRvector tangent;		/* corresponding tangent vector */

/*.AStangent*/
{

   IGRdouble u_max;		/* upper boundary for solution */
   IGRdouble u_min;		/* lower boundary for solution */
   IGRdouble u_inc;		/* increment to find the boundary */
   IGRdouble u_inc_prog;	/* increment variation rate   */
   IGRdouble u_sol,u;		/* parameter used for compute */

   IGRvector t;			/* tangent at working point  */
   
   IGRdouble p_max,		/* dot product at upper boundary */
             p_min,		/* dot product at lower boundary */
             p,			/* dot product working value     */
             len,               /* length tangent vector or dist to snap   */
	     lenmin;		/* minimal dist to snap */

   IGRint i,ib,isign,i_max=100;	/* loop index and limit         */
   IGRint inear;		/* pole index where dist to p_init minimal */
   IGRint icalc,imin,imax;	/* current previous and next pole	*/
   IGRdouble tol=1.e-6;         /* tolerence on dot product solution        */
   IGRlong rc,msg;

    
   double  conic_points[3*BSCIRCLE_NUM_POLES_MAX]; /* space to store         */
   IGRdouble conic_knots[BSCIRCLE_NUM_KNOTS_MAX]; /* equivallent conic      */
   IGRdouble conic_weights[BSCIRCLE_NUM_POLES_MAX];
   struct IGRbsp_curve bc_conic,*bc_calc;

   IGRshort option = 0;
   IGRdouble h;

   IGRdouble fabs();
  
   
/* if order 2 curve  
   - find nearest vertex of initial point
   - find nearest vertex where dot product change sign
   - transform to order 3 near these vertex
   - find tangency as usual 
*/

/*"initial u %lf\n",*u_init */
   if(bc->order <3)
     {

/* initial point */

   MAbcueval(&msg,bc,&option,u_init,p_final,&h);
/*"u_init %lf\np_final %lf %lf %lf\n",*u_init,p_final[0],p_final[1],p_final[2]*/

/* nearest vertex */

      lenmin = 1.e+36;
      ASfind_nearest_vertex(bc,0,lenmin,lenmin,p_final,t,&inear,&lenmin);
      if(lenmin > 0.5e+36) return (MSFAIL);

/* nearest vertex where dot product change sign */

    /*"inear %d\n",inear */
      p_min = 1; 
      p_max = 1;
      for(ib=0 ; ib<bc->num_poles ; ib++)
	 {
      for(isign=-1;isign<2;isign=isign+2)
	 {
	  i=inear+isign*ib;
	  if(!ASadjust_i(i,&icalc,bc)) continue;
	  i=i-1;
	  if(!ASadjust_i(i,&imin,bc)) continue;
	  i=i+2;
	  if(!ASadjust_i(i,&imax,bc)) continue;

          MAsubvc(&msg,bc->poles+3*icalc,bc->poles+3*imin,t);
   	  MAdotvc(&msg,normal,t,&p_min);
          MAsubvc(&msg,bc->poles+3*imax,bc->poles+3*icalc,t);
   	  MAdotvc(&msg,normal,t,&p_max);
	  /*"p_min %lf p_max %lf\n",p_min,p_max */
	  if(p_min*p_max <= 0) goto tang_ok;
	 } }
      return(MSFAIL);
      tang_ok :

      
  /*"icalc %d\n",icalc */

/* now conver to order 3 and compute the new u_initial value */
/* KLUDE visible edge don't return PLANAR */


      bc->planar = TRUE;
      BSEXTRACTPAR(&rc,BSTOLCHRDHT,tol);

     /*"rc %d\ntol %lf",rc,tol */


     bc_conic.poles = conic_points;
     bc_conic.knots = conic_knots;
     bc_conic.weights = conic_weights;
     
     BSarcofpts(bc,bc->poles+3*icalc,tol,&bc_conic,&rc);

/*^
  printf("result\n");
  ASedit_bsp(bc_conic);
*/

     if(rc != BSSUCC)  return(MSFAIL);

      bc_calc = &bc_conic;
      u_sol = 0.5;     /* en attendant mieux */
	 
     }    /* end transform to order 3 */

   else {bc_calc = bc;u_sol=*u_init;}


/* find boundary to solution */

   u_max = u_sol;
   u_inc = 0.01;  
   u_inc_prog = 1.25;

   MAbcu1derivative(&msg,bc_calc,&u_max,t);
   if(msg != MSSUCC) return (MSFAIL);
   MAdotvc(&msg,normal,t,&p_max);

   while(u_inc < 1)
      {
       u_inc *= u_inc_prog;

       /* lower boundary */

       u_min = u_sol - u_inc;
       ASadjust_u(&u_min,&u,bc_calc);
       MAbcu1derivative(&msg,bc_calc,&u,t);
       if(msg != MSSUCC) return (MSFAIL);

       MAdotvc(&msg,normal,t,&p_min);
       if(p_min*p_max <0) break;

       /* upper boundary */

       u_max = u_sol + u_inc;
       ASadjust_u(&u_max,&u,bc_calc);
       MAbcu1derivative(&msg,bc_calc,&u,t);
       if(msg != MSSUCC) return (MSFAIL);

       MAdotvc(&msg,normal,t,&p_max);
       if(p_min*p_max <0) break;
      }

   if(p_min*p_max >0) return(MSFAIL);

/*"boundary solution %lf -> dot %lf, %lf -> dot %lf\n",u_min,u_max,p_min,p_max*/
   


/* I'm now sure that there is a solution. Find it by dichotomy */
   

   if(p_min>p_max)
     { p=p_max; p_max=p_min; p_min=p;
       u=u_max; u_max=u_min; u_min=u;}
     
   p_min -= 1 ; p_max += 1;   /* to avoid 0 divide */

   for(i=0;i<i_max;i++)
     {
       /* new value to try */

       u_sol = (0.9*p_max/(p_max-p_min) + 0.05) * u_min 
             + (0.9*p_min/(p_min-p_max) + 0.05) * u_max;

       ASadjust_u(&u_sol,&u,bc_calc);
       MAbcu1derivative(&msg,bc_calc,&u,t);

       if(msg != MSSUCC) return (MSFAIL);
       MAdotvc(&msg,normal,t,&p);
       MAlenvc(&msg,t,&len);

       /* what to do now */
       if(fabs(p)<tol*len)break;       /* ok */
       if(p<0)               /* change lower boundary */
         {u_min = u_sol ; p_min = p;}
       else		     /* change upper boundary */
         {u_max = u_sol ; p_max = p;}
     }

   if(fabs(p)>tol*len) return(MSFAIL);

   /* all is ok boy. Return the solution */

   *u_final = u;
   *tangent = t[0];
   *(tangent+1) = t[1];
   *(tangent+2) = t[2];
   MAbcueval(&msg,bc_calc,&option,u_final,p_final,&h);
/*"returned u %lf\n",u_final */
   return(MSSUCC);
}

/* --------------------------------------------------
 function to compute the position of a vertex
   -------------------------------------------------- */

ASvertex_position(bc,iv,point)
struct IGRbsp_curve *bc; /* curve definition */
IGRint iv; 	 	 /* vertex number    */
IGRdouble *point;        /* vertex position  */
/*.vertex_position*/
{
 IGRdouble scal;

 /*"vertex %d\n",iv*/

 if(bc->rational)
  {
   scal = 1/bc->weights[iv];
   v_scale(bc->poles+3*iv,scal,point);
  }
 else 
  {
   v_equal(bc->poles+3*iv,point);
  }
 /*^pr_point("position",point); */
 return(1);
}


/* --------------------------------------------------
 function used to know if there is an angle on a vertex
   -------------------------------------------------- */

ASangle_on_vertex(bc,iv)
struct IGRbsp_curve *bc; /* curve definition */
IGRint iv; 	 	 /* vertex number    */
/*.angle_on_vertex*/
{
 IGRint imin,imax;
 IGRlong msg,rc;
 IGRdouble parms,cs,ss;
 IGRboolean on_curve;
 IGRpoint point,segmin,segmax,segnor;
 IGRdouble fabs();


 ASvertex_position(bc,iv,point);

  /*" vertex %d position %lf %lf %lf\n",iv,point[0],point[1],point[2] */

  /*| Is the vertex on the curve */
      msg = BSprptoncv(&rc,bc,point,&parms,&on_curve);
      if(!on_curve) {/*|no */ goto failure;}

  /*| is there an angle on this vertex */
    if(!ASadjust_i(iv-1,&imin,bc)) {/*| begin point */ goto success;}

    if(!ASadjust_i(iv+1,&imax,bc)) {/*| end point */ goto success;}
 
     ASvertex_position(bc,imin,segmin);
     msg = BSprptoncv(&rc,bc,segmin,&parms,&on_curve);
     if(!on_curve){/*| after point not on curve */ goto failure;}

     ASvertex_position(bc,imax,segmax);
     msg = BSprptoncv(&rc,bc,segmax,&parms,&on_curve);
     if(!on_curve){/*| after point not on curve */ goto failure;}
     /*"imin %d iv %d imax %d\n",imin,iv,imax */
     v_sub(point,segmin,segmin);
     v_sub(segmax,point,segmax);
     cs = v_dot(segmin,segmax);
     v_cross(segmin,segmax,segnor);
     ss = v_len(segnor);
 
     /*"cs %lf ss %lf\n",cs,ss */

     if(  (fabs(cs)    > 1.e-8)
        &&(fabs(ss/cs) < 1.e-4))  goto failure;
     else			  goto success;

failure : /*" no angle on %d\n",iv */ return (FALSE);

success : /*"angle on %d\n",iv */ return (TRUE);
}


/* --------------------------------------------------
 function used to get the nearest vertex from a point
   -------------------------------------------------- */

#argsused
  ASfind_nearest_vertex(bc,test,max_distance,tol,point,
			vertex_point,vertex_num,distance)
  struct IGRbsp_curve *bc; /* curve definition */
  IGRint test;             /* test if 					      */
			   /*    ANGL_VER : there is an angle on this vertex  */
			   /*    ONCV_VER : the vertex is on the curve 	      */
 
  IGRdouble max_distance;  /* max distance to search vertex from point 	      */
  IGRdouble tol;           /* tolerance to define if vertex is on the curve   */
  
  IGRpoint point,          /* point to compute nearest vertex from            */
           vertex_point;   /* obtain vertex point			      */
  IGRint *vertex_num;      /* vertex number				      */
  IGRdouble *distance;     /* obtained distance from point to vertex          */
/*.find_nearest*/
{

  IGRlong rc,msg;
  IGRint iv;
  IGRdouble dwork,w_point[3],w_vect[3];
  IGRdouble parms;
  IGRboolean on_curve;

/*"test %d\n",test */


/* specific for points */

  if(bc->num_poles == 1 || (bc->num_poles<3 && bc->phy_closed))
    {
     v_sub(point,bc->poles,w_vect);
     dwork = w_vect[0]*w_vect[0] + w_vect[1]*w_vect[1] + w_vect[2]*w_vect[2];
     if(dwork < max_distance)
       {
        *distance = dwork;
        *vertex_num = 0;
	v_equal(bc->poles,vertex_point);
       }
    }

/* curve */
  else
    {
     for(iv=0 ; iv<bc->num_poles ; iv++)
        {
	  ASvertex_position(bc,iv,w_point);

	  v_sub(point,w_point,w_vect);

          dwork=w_vect[0]*w_vect[0] + w_vect[1]*w_vect[1] + w_vect[2]*w_vect[2];
     
          if(dwork >= max_distance) continue;

  /* is the vertex on the curve */
	  if(test&ONCV_VER)
            {
	     /*"test %d on cv\n",iv */
 	     msg = BSprptoncv(&rc,bc,w_point,&parms,&on_curve);
	     if(!on_curve) continue;
	    }

  /* is there an angle on this vertex */
	  if(test&ANGL_VER)
	    {
	     /*"test %d is angle\n",iv */
	     if(!ASangle_on_vertex(bc,iv)) continue;
	    }
	       
		
 	  /*"vertex %d is eligible\n", iv */

           max_distance=dwork;
	   *distance = dwork;
	   *vertex_num = iv;
	   v_equal(w_point,vertex_point);
	  } /* loop on vertex */
      }
 return 1;
}

   

/* --------------------------------
 function used to edit a b_spline
   -------------------------------- */

  ASedit_bsp(bs)
  struct IGRbsp_curve bs;
{
  IGRint i;
  printf("order %d periodic %d non_uniform %d num_poles %d \n",
  bs.order, bs.periodic, bs.non_uniform, bs.num_poles);
  printf("num_knots %d rational %d planar %d phy_closed %d num_boundaries %d\n",
  bs.num_knots, bs.rational, bs.planar, bs.phy_closed, bs.num_boundaries);
	
  for(i=0;i<bs.num_poles;i++)
  printf("poles%d %lf %lf %lf\n", i,
	 *(bs.poles+3*i), *(bs.poles+3*i+1), *(bs.poles+3*i+2) );

  printf("knots\n");
  for(i=0;i<bs.num_knots;i++) printf(" %lf", *(bs.knots+i));
  printf("\n");

  if(bs.rational)
    {
     printf("weights"); 
     for(i=0;i<bs.num_poles;i++)
        printf(" %lf",*(bs.weights+i));
     printf("\n");
    }
 return 1;
}

/* -----------------------------------------------------------------
 function used to project a point in the xy plane of a referential
   ----------------------------------------------------------------- */
   ASproject_in_xy(t,line,from_pt,to_pt)
   IGRdouble *t;        /* ref matrix       */
   IGRint line;         /* 1 : matrix store by line */
			/* 0 : matrix store by colomn */
   IGRpoint  from_pt,   /* point to project */
             to_pt;     /* result           */
/*.ASproject_in_xy*/
  {
   IGRpoint w;
   IGRdouble scal;
   IGRdouble one = 1;

/*^ pr_point("from_pt",from_pt); 
    pr_mat("matrix",4,4,t);      */

if(line&AS_IN_LINE)
 {
   /*| matrix by line */
   if(!(line&AS_VECTOR))
     {
      w[0] = from_pt[0] - t[3];
      w[1] = from_pt[1] - t[7];
      w[2] = from_pt[2] - t[11];
     }
   else
     {
      v_equal(from_pt,w);
     }


   scal = w[0]*t[2] + w[1]*t[6] + w[2]*t[10];

   to_pt[0] = from_pt[0] - scal*t[2];
   to_pt[1] = from_pt[1] - scal*t[6];
   to_pt[2] = from_pt[2] - scal*t[10];
 }

else if(line&AS_IN_COL)
 {
   /*| matrix by colomn */
  if(!(line&AS_VECTOR)) v_sub(from_pt,&t[12],w);
  else			v_equal(from_pt,w);

  scal = -v_dot(w,&t[8]);
  v_comb(one,from_pt,scal,&t[8],to_pt);
 }

else printf("ASproject_in_xy invalid argument\n");
/*^ pr_point("to_pt",to_pt); */

return(1);
}

/* -----------------------------------------------------------------
 function used to compute the length of a curve.
 A specific compute for b_spline order is implemented because math
 lib is much to slow in this case --> impact on dimensioning to 
 visible edges
   ----------------------------------------------------------------- */

AStotlen(rc,bc,len)
IGRlong *rc;
struct IGRbsp_curve *bc;
IGRdouble *len;
/*.AStotlen */
 {
  int i;
  double *p1,*p2;
  double v[3];
  double length;
  IGRboolean bsstat;
  double zero = 0,
	 un   = 1,
	 half_par;


  if(bc->order > 2)
   {
    half_par = 0.5;
    BSarclen(rc, &bsstat, bc, &zero, &un, &half_par, len);
   }
  else
   {
    length = 0;
    p1 = bc->poles;
    p2 = p1+3;
    for(i=0;i<bc->num_poles-1;i++)
      {
       v_sub(p2,p1,v);
       length += v_len(v);
       p1 = p2;
       p2 += 3;
       }
    *rc = BSSUCC;
    *len = length;
   }
  return 1;
 }

ASarclen(rc,bsstat,bc,par1,par2,par,len)
IGRlong *rc;
IGRboolean *bsstat;
struct IGRbsp_curve *bc;
IGRdouble *par1,*par2,*par,*len;
/*.ASarclen */
 {
  int i;
  double *p1,*p2;
  double v[3];
  double length,fact,inc_len;
  double loc_par1,loc_par2;
  double pol_par1,pol_par2,pol_inc;
  int before,intern;

  if(bc->order > 2)
   {
    BSarclen(rc, bsstat, bc, par1, par2, par, len);
   }
  else
   {
    if((*par - *par1)*(*par - *par2) < EPS)
     {
      before = 1;
      intern = 1;
      if(*par1 < *par2) { loc_par1 = *par1; loc_par2 = *par2; }
      else 	        { loc_par1 = *par2; loc_par2 = *par1; }
     }
    else
     {
      intern = 0;
      before = 0;
      if(*par1 < *par2) { loc_par1 = *par1; loc_par2 = *par1; }
      else 	        { loc_par1 = *par1; loc_par2 = *par2; }
     }

/*" par1 %lf par2 %lf par %lf\n",loc_par1,loc_par2,*par */

    length = 0;
    pol_inc = 1./(bc->num_poles-1);

    p2 = bc->poles;
    pol_par2 = 0.;
  
    for(i=0;i<bc->num_poles-1;i++)
      {
       p1 = p2;
       p2 += 3;
       pol_par1 = pol_par2;
       pol_par2 = pol_par1 + pol_inc;
       /*" segment %d %d par %lf %lf\n",i,i+1,pol_par1,pol_par2 */
       fact =1;
       if(before)
        {
	 /*| before */
	 if( pol_par2 < loc_par1 ) continue;
         before = 0;
	 fact = fact - (bc->num_poles-1) * (loc_par1 - pol_par1);
	 /*"first to measure fact = %lf\n",fact */
        }

	/*| during */
        v_sub(p2,p1,v);
        inc_len = v_len(v);
	/*"inc_len %lf\n",inc_len */
	if ( pol_par2 > loc_par2)
         {
	  fact = fact - (bc->num_poles-1) * (pol_par2 - loc_par2);
	  length += fact*inc_len;
	  /*" last to measure  fact = %lf\n",fact */
	  if(intern) break;
	  else before = 1;
	 }
	else
         {
          length += fact*inc_len;
	 }
        /*" work len %lf\n",length */
       }
    *rc = BSSUCC;
    *len = length;
   /*"return len = %lf\n",*len */
   }
  return 1;
 }

/*
   These functions return the abstract geometry of an associative object 
   ASgenabsg : prevoius version without indexing
   ASgetabsg : new version. Must be called using as$getabsg
*/

ASgenabsg(obj,bc)
struct GRid *obj;
char **bc;
{
return (ASgetabsg(obj,-1,bc));
}

ASgetabsg(obj,index,bc)
struct GRid *obj;
int index;
char **bc;
{
 IGRlong status,msg;
 struct GRid go_object;
 IGRshort matrix_type;
 IGRdouble matrix[16];
 

  status = om$send(msg = message NDnode.ASreturn_go(&go_object,
                                                 &matrix_type,matrix),
                   senderid = NULL_OBJID,
                   targetid = obj->objid ,
                   targetos = obj->osnum );
  if(!(status&1))
         {go_object = *obj;
          matrix_type = MAIDMX;
          MAidmx(&msg,matrix);
         }
  if(index>-1)
   {
    status = om$get_objid_at_index(objid = go_object.objid,
				   osnum = go_object.osnum,
                                   p_chanselect = &AS_to_comp,
                                   index = index,
                                   objidaddr = &go_object.objid,
                                   osnumaddr = &go_object.osnum);
    as$status(action = RET_STATUS);
   }

  status = om$send(msg = message GRvg.GRgenabsg(&msg,&matrix_type,matrix,bc),
                   senderid = NULL_OBJID,
                   targetid = go_object.objid,
                   targetos = go_object.osnum);
  as$status(action = RET_STATUS);

  if(msg != MSSUCC && msg != MAIDGENRAT) status = OM_W_ABORT;

  return(status);
}

%safe
int ASnp_for_min_dist = 80;
%endsafe

ASmdstptcv(
struct IGRbsp_curve *bc,
double *pt_init,
double *par,
double *pt_res,
double *dist,
long   *rc)
/*.ASmdstptcv*/
{
 int i,imin = 0,inext;
 double *pole,*nearest_pole;
 double len,lenmin,dot,one=1.;
 double vect[3],vertex[3],project[3],nearest[3];
 double sqrt();

/*
   If there is more than ASnp_for_min_dist poles does an aproximative projection
*/

 if(bc->num_poles <ASnp_for_min_dist || bc->order>2)
  {
   BSmdstptcv(bc,pt_init,par,pt_res,dist,rc);
  }
 else
  {
   lenmin = 1.e+30;
   pole = bc->poles;
   for(i=0;i<bc->num_poles;i++)
     {v_sub(pole,pt_init,vect);
      len = vect[0]*vect[0] + vect[1]*vect[1] + vect[2]*vect[2];
      if(len<lenmin) {lenmin = len; imin = i;}
      pole += 3;
     }

   nearest_pole = &bc->poles[3*imin]; 
   v_equal(nearest_pole,nearest);

   /*get the projections on the adjacent segments */

   v_sub(pt_init,nearest_pole,vect);
     /*^pr_point("vect",vect); */
   for(i=-1 ; i<2 ; i+=2)
    {
     if(!ASadjust_i(imin+i,&inext,bc)) {/*|end point of linestring*/ continue;}
     /*" projection on %d %d\n",imin,inext */

     v_sub(&bc->poles[inext],nearest_pole,vertex);
     len = v_len(vertex);
     if(len < 1.e-10) continue;
     /*^pr_point("vertex",vertex); */
     dot = v_dot(vertex,vect)/len;
     /*" dot %lf\n",dot */
     if(dot<0 || dot >1) {/*| projection is not on segment */ continue;}
     v_comb(one,nearest_pole,dot,vertex,project);
     /*^pr_point("project",project); */
     v_sub(pt_init,project,vertex);
     /*^pr_point("vector",project); */
     len=vertex[0]*vertex[0] + vertex[1]*vertex[1] + vertex[2]*vertex[2];
     /*" len %lf lenmin %lf\n",len,lenmin */
     if(len<lenmin) {/*|min on vertex*/lenmin = len; v_equal(project,nearest);}
    }


   /* not done before, pt_init and pt_rest could be store at the same place */     
   v_equal(nearest,pt_res); 
   *dist = sqrt(lenmin);
   *rc = BSSUCC;
  }
 return 1;
}
 
end implementation ASnode;
