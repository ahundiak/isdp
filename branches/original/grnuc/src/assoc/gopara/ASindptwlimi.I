class implementation ASindptwlim;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "bserr.h"
#include "AS_debug.h"

#define AS_DEBUG
#define EPS 1.e-5

double cos(),sin(),fabs();

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                       extend_place function


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ASindex_bary(IGRint quel_cas; struct GRmd_env *md_env;
                   struct ret_struct *pardef; struct GRid *parent;
                   IGRpoint pt_init,pt_track; IGRdouble *xbary; IGRpoint pt_res)
 {

  IGRint 			side;
  IGRshort 			num_par;
  IGRlong 			msg,rc,status;
  struct    IGRbsp_curve 	*bc;
  IGRdouble par1  ,par2  ,par , half_par;
  IGRdouble pt1[6],pt2[6],v1[3],v[3],int_pt[3];
  IGRdouble *tg1,*tg2,tgn[3];
  IGRboolean bsstat;
  double length;
  double dist,dist1,dist2;
  double len1,len2;
  double un = 1.;
  double half = 0.5;


  status = OM_S_SUCCESS;

  /*"quel_cas: %d\n", quel_cas */

   switch (quel_cas)
   {

    case 1 : 	      /* on general b_spline */
    case 3 :

    /* Length of the curve */

      status = ASgenabsg(parent,&bc);
      as$status(action = RET_STATUS);

      if(quel_cas == 1)
        {

         AStotlen(&rc,bc,&length);
         if( rc != BSSUCC ) { /*| Error in BSarclen */ return(OM_W_ABORT); }
	 par1 = 0;
         par2 = 1;
        }
      else
        {
         ASmdstptcv(bc, pardef[1].var.point_st.pt, &par1, pt1, &dist, &rc);
         if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }

         ASmdstptcv(bc, pardef[2].var.point_st.pt, &par2, pt2, &dist, &rc);
         if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }

         half_par = 0.5 * (par1 + par2);
         ASarclen(&rc, &bsstat, bc, &par1, &par2, &half_par, &length);
         if( rc != BSSUCC ) { /*| Error 2 in BSarclen */ return(OM_W_ABORT); }
        }


      /* Project point on the curve */

/*^ASedit_bsp(*bc);*/
      /* Special treatment for linestring to avoid problem with discontinuity */
      if(bc->order == 2 && bc->num_poles > 3)
       {
	struct IGRbsp_curve bcc;
        double pt_work[3];
	double *kk,
	       inc,sum,
	       half = 0.5;
	int i;

        bcc = *bc;
        bcc.order = 3;
        if(bc->phy_closed)
 	  {
	   /* add an additional pole at the mid side of the first segment */
           bcc.num_poles = bcc.num_poles+1;
	   bcc.poles = (double *)
			 om$malloc(size = 3*bcc.num_poles*sizeof(double));
	   OM_BLOCK_MOVE(bc->poles,bcc.poles,3*bc->num_poles*sizeof(double));
	   v_comb(half,bc->poles,half,bc->poles+3,bcc.poles);
	   v_equal(bcc.poles,bcc.poles+3*bc->num_poles);
          }
	bcc.num_knots = bcc.num_poles+3;
        bcc.knots = (double *)
			 om$malloc(size = (bcc.num_poles+3)*sizeof(double));
        inc = 1./(bcc.num_poles-2);
	sum = inc;
	kk = bcc.knots;
        for(i= 0 ; i<3 ; i++) {*kk = 0; kk +=1;}
        for(i= 0 ; i<bcc.num_poles-3 ; i++,sum+=inc) {*kk = sum; kk +=1;}
        for(i= 0 ; i<3 ; i++) {*kk = 1; kk +=1;}
        
/*^ASedit_bsp(bcc);*/
        BSperpa( &rc, &bcc, pt_init, pt_track, &num_par, &par, &side );
        if( rc == BSSUCC && num_par > 0 )
	 { 
          BScveval(&bcc, par, 0, pt_work, &rc);
	  /*^ pr_point("perpa success -->",pt_work); */
	 }
	else
	 { 
          v_equal(pt_init,pt_work);
	 }
        ASmdstptcv(bc, pt_work, &par, pt_res, &dist, &rc);
	/*^ pr_point("mdstptcv -->",pt_res); */

	om$dealloc(ptr = bcc.knots);
	if (bc->phy_closed) om$dealloc(ptr = bcc.poles);
       }
      else
       {

        BSperpa( &rc, bc, pt_init, pt_track, &num_par, &par, &side );
        if( rc == BSSUCC && num_par > 0 )
	 { 
          BScveval(bc, par, 0, pt_res, &rc);
         }
        else
         {
          ASmdstptcv(bc, pt_init, &par, pt_res, &dist, &rc);
         }
       }

      if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }

      half_par = 0.5 * (par1 + par);
      ASarclen(&rc, &bsstat, bc, &par1, &par, &half_par, xbary);
      if( rc != BSSUCC ) { /*| Error 2 in BSarclen */ return(OM_W_ABORT); }
      /*"xbary %lf len %lf\n",*xbary,length */

      if(length != 0) *xbary = *xbary / length;
              else    *xbary = 0;

      if(*xbary > EPS && *xbary < 1-EPS && (par-par1)*(par-par2) < 0)
        {
          break;
        }

      /*
         The placement point can not be projected on the curve    
         --> chose one of the end points 
      */
      
      /* end points and corresponding normal vector and interstion between the
         normal vector */

      BScveval(bc, par1, 1, pt1, &rc);
      BScveval(bc, par2, 1, pt2, &rc);
      tg1 = &pt1[3];
      tg2 = &pt2[3];

      v_cross(tg1,tg2,tgn);
      v_cross(tg1,tgn,tg1);
      v_cross(tg2,tgn,tg2);
      len1 = v_len(tg1);
      len2 = v_len(tg2);

      if(   line_prox_line(pt1,tg1,pt2,tg2,&dist1,&dist2) == 0
	 || len1 == 0
	 || len2 == 0)
       {
	v_sub(pt1,pt_init,v);
	dist1 = v_len(v);
	v_sub(pt2,pt_init,v);
	dist2 = v_len(v);
       }
      else
       {
        dist1 = dist1*0.5; dist2 = dist2*0.5;
        v_comb(half,pt1  ,dist1,tg1,int_pt);
        v_comb(un ,int_pt,half ,pt2,int_pt);
        v_comb(un ,int_pt,dist2,tg2,int_pt);
  
        v_sub(pt_init,int_pt,v);
        dist1 = fabs(v_dot(tg1,v)/len1);
        dist2 = fabs(v_dot(tg2,v)/len2);
       }
      if(dist1 > dist2)
        { *xbary = 0; v_equal(pt1,pt_res);}
      else
        { *xbary = 1; v_equal(pt2,pt_res);}
      break;

    case 32 :        /* point between two points */
      status = om$send(msg = message ASindexpt.ASindex_bary
					       (quel_cas, md_env,
                     			       pardef, parent,
                     			       pt_init,pt_track, xbary, pt_res),
		       targetid = my_id,
		       mode = OM_e_wrt_message);
      as$status(action = RET_STATUS);

      if     (*xbary < 0) {*xbary=0; v_equal(pardef[0].var.point_st.pt,pt_res);}
      else if(*xbary > 1) {*xbary=1; v_equal(pardef[1].var.point_st.pt,pt_res);}
      break;

  case 11 :      /*| point on a line */
      status = om$send(msg = message ASindexpt.ASindex_bary
					       (quel_cas, md_env,
                     			       pardef, parent,
                     			       pt_init,pt_track, xbary, pt_res),
		       targetid = my_id,
		       mode = OM_e_wrt_message);

      if      (*xbary < 0) {*xbary=0; v_equal(pardef[0].var.line_st.p0,pt_res);}
      else if (*xbary > 1) {*xbary=1; v_equal(pardef[0].var.line_st.p1,pt_res);}
    break;

  case 13 :     /*| point on a line between 2 points */

  /* project end point on the line */
      point_on_line(pardef[0].var.line_st.p0, 
		    pardef[0].var.line_st.v0,
		    pardef[1].var.point_st.pt,pt1);

      point_on_line(pardef[0].var.line_st.p0, 
		    pardef[0].var.line_st.v0,
		    pardef[2].var.point_st.pt,pt2);

/*^ pr_point("pt1",pt1);
    pr_point("pt2",pt2);
*/

/* now compute baryfact */
      v_sub( pt2, pt1, v);
      length = v_len( v );
      if( length == 0 ) {*xbary = 0; v_equal(pt1,pt_res);break;}
      v_sub( pt_init, pt1, v1 );
      *xbary = v_dot( v1, v ) / (length * length) ;
      if     (*xbary < 0) *xbary = 0;
      else if(*xbary > 1) *xbary = 1;
      v_comb(un,pt1,*xbary,v,pt_res);
/*^ pr_point("pt_res",pt_res);*/
      break;

  case 21 :  /*| point on circle or arc */
  case 23 :
    {        
    IGRdouble pc1[4],pc2[4];
    IGRdouble mat[9];
    IGRshort four =4,one =1;
    double angle;
    double start_angle;
    double dummy,a_track;

    mat4_3( pardef[0].var.circle_st.mat, mat );

    if(quel_cas == 21)
      {
       start_angle = 0;
       if(pardef[0].type != arc_type) length = 2*PI;
       else length = pardef[0].var.circle_st.sweep_angle;
      }
    else
      {
       point_on_circle(pardef[0].var.circle_st.cent_p,
		       pardef[0].var.circle_st.rad, mat,
		       pardef[1].var.point_st.pt ,pt1);
       point_on_circle(pardef[0].var.circle_st.cent_p,
		       pardef[0].var.circle_st.rad, mat,
		       pardef[2].var.point_st.pt ,pt2);

       mes_angle( pardef[0].var.circle_st.rad, pt1, pt2, (IGRshort) 0,
                  &start_angle, &dummy, &length );

      }
    point_on_circle(pardef[0].var.circle_st.cent_p,
		    pardef[0].var.circle_st.rad, mat,
		    pt_init ,pc1);
    point_on_circle(pardef[0].var.circle_st.cent_p,
		    pardef[0].var.circle_st.rad, mat,
		    pt_track ,pc2);
   mes_angle( pardef[0].var.circle_st.rad, pc1, pc2, (IGRshort) 0,
                xbary, &a_track, &dummy );
   if(fabs(dummy) > PI/2 && fabs(dummy) < 3*PI/2)
     {
      *xbary -= PI;
      pc1[0] = pardef[0].var.circle_st.rad * cos(*xbary);
      pc1[1] = pardef[0].var.circle_st.rad * sin(*xbary);
     }
   *xbary -= start_angle;
   if(*xbary < 0) *xbary += 2*PI;

/*" length %lf, xbary %lf\n",length,*xbary */ 

    if(length ==0) *xbary=0;
    else if(*xbary < length)
        {
         /*| Projection point is on the curve */
         *xbary = *xbary/length;
	}

    else
        {
         /*| Projection point is not on the curve */
         if(*xbary > PI) *xbary -= PI;

	 if(*xbary < length)
	   { /*| Take other projection*/
	     angle = *xbary; *xbary = *xbary/length;}

	 else if(*xbary > start_angle + 0.5*(PI + length)  )
	   { /*| Take start point */
	     *xbary = 0; angle = start_angle;}
	 else 
	   { /*| Take end point */
	     *xbary = 1; angle = start_angle + length;}

/*" angle %lf xbary %lf\n",length,*xbary */

         pc1[0] = pardef[0].var.circle_st.rad * cos(angle);
         pc1[1] = pardef[0].var.circle_st.rad * sin(angle);
	}
    pc1[2] = 0; pc1[3] = 1;
    MAmulmx(&msg, &four, &four, &one, pardef[0].var.circle_st.mat, pc1, pt_res);
   }

   break;
        
   default : break;
       
 } /* end switch */

 return(OM_S_SUCCESS);


}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  char                name[MAX_CHAR];      /* Name of the object to print     */

  /* Get the name of this object */

  as$printer_set_name(prefix="INDEX_POINT",
		      name=name);

  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and Symbology */

  as$printer_print_parents(count = &count);
  as$printer_print_symb();

  /* Print the instances (barycentric coefficient) */

  fprintf(stream,"ptr[0]=%lf;\n",me->bary_fact);

  /* Print the message */

  fprintf(stream,"send ASindptwlim.place(%d,list,ptr) to %s;\n\n",count,name);
  return(1);
}/* end print */

end implementation ASindptwlim;
