
/*\ Index point implementation file 

     CHANGE HISTORY:

     S.Frezefond  jul 86   : conversion to ems
     S.Frezefond  mar 86   : exec0 design date
     C.Heraud     Oct 86   : Modif. for the assoc.
     jla          Mar 87   : Support implementation
     jla          May 87   : override xform. specific on circle compute.
				index_pt and index_bar function
     Sudha	24Oct 94   : Fix TR# 119422104 TD/SSL - added BSprototyping

\*/

class implementation ASindexpt;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "bserr.h"
#include "ASmsg.h"
#include "msmacros.h"
#include "masubvc.h"
#include "mamulmx.h"
#include "bsptsdlcv.h"
#include "bscveval.h"

#define AS_DEBUG

double cos(),sin();


extern IGRboolean ASbroadcast_in_progress;

extern GRclassid OPP_GR3dpoint_class_id;

/*
   This method compute the barycentric coor. knowing the point coordinate.
   Used by place if graphic object already exist or by GRxform to change
   barycentric coor.
*/

method  ASindex_bary(IGRint quel_cas; struct GRmd_env *md_env;
		     struct ret_struct *pardef; struct GRid *parent;
		     IGRdouble *pt_init, *pt_track, *xbary, *pt_res)
 {
  IGRpoint pt1,pt2;        /* projection of begin and end point */
  double par1,par2,par;    /* corresponding parameter           */
  IGRpoint v,v1;
  IGRlong msg;
  IGRdouble length;
  IGRdouble zero = 0., un = 1;
  IGRint status;
  IGRlong rc;
  IGRboolean bsstat;
  struct IGRbsp_curve *bc;
  IGRdouble dist, half_par;

   /*"index_bary quel_ca: %d\n", quel_cas */
   switch (quel_cas)
    {

     case 1 :                  /* on general b_spline */

      status = ASgenabsg(parent,&bc);
      as$status(action = RET_STATUS);

      AStotlen(&rc,bc,&length);
      if( rc != BSSUCC ) { /*| Error in BSarclen */ return(OM_W_ABORT); }
      /*"totlen %lf\n",length */

      ASmdstptcv(bc, pt_init, &par, pt_res, &dist, &rc);
      if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }

      half_par = 0.5 * par;
      ASarclen(&rc, &bsstat, bc, &zero, &par, &half_par, xbary);
      if( rc != BSSUCC ) { /*| Error 2 in BSarclen */ return(OM_W_ABORT); }
      /*"point len %lf\n",*xbary */

      if(length != 0) *xbary = *xbary / length;
	      else    *xbary = 0;
      break;

     case 32 :                  /* point between two points */

        MAsubvc( &msg, pardef[1].var.point_st.pt, pardef[0].var.point_st.pt, v);
        length = v_len( v );
        if( length == 0 )
	       {*xbary=0.; v_equal(pardef[0].var.point_st.pt,pt_res); break; }

        MAsubvc( &msg, pt_init, pardef[0].var.point_st.pt, v1 );
 	*xbary = v_dot( v1, v ) / (length * length) ;
	v_comb(un,pardef[0].var.point_st.pt,*xbary,v,pt_res);
	break;

  case 3 :/*| point on curve between two points */

      status = ASgenabsg(parent,&bc);
      as$status(action = RET_STATUS);

      ASmdstptcv(bc, pt_init, &par, pt_res, &dist, &rc);
      if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }

      ASmdstptcv(bc, pardef[1].var.point_st.pt, &par1, pt1, &dist, &rc);
      if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }

      ASmdstptcv(bc, pardef[2].var.point_st.pt, &par2, pt2, &dist, &rc);
      if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }

      half_par = 0.5 * (par1 + par2);
      ASarclen(&rc, &bsstat, bc, &par1, &par2, &half_par, &length);
      if( rc != BSSUCC ) { /*| Error 2 in BSarclen */ return(OM_W_ABORT); }

      half_par = 0.5 * (par1 + par);
      ASarclen(&rc, &bsstat, bc, &par1, &par, &half_par, xbary);
      if( rc != BSSUCC ) { /*| Error 2 in BSarclen */ return(OM_W_ABORT); }

      /*"length1: %lf, length2: %lf\n", length, *xbary */
      if(length != 0) *xbary = *xbary / length;
                else  *xbary = 0;
      if(par1 < par2 && par < par1) *xbary = - *xbary;
      if(par1 > par2 && par > par1) *xbary = - *xbary;
      /*"xbary %lf\n",*xbary */
            
      break;

     case 11 :/* point on a line */

        MAsubvc( &msg, pardef[0].var.line_st.p1, pardef[0].var.line_st.p0, v);
        length = v_len( v );
        if( length == 0 )
		 {*xbary = 0;v_equal(pardef[0].var.line_st.p0,pt_res); break;}
        MAsubvc( &msg, pt_init, pardef[0].var.line_st.p0, v1 );
 	*xbary = v_dot( v1, v ) / (length * length) ;
	v_comb(un,pardef[0].var.line_st.p0,*xbary,v,pt_res);
	break;

    case 13 : /* point on a line between 2 points */

/* project start and end point on support */
        point_on_line(pardef[0].var.line_st.p0,
                      pardef[0].var.line_st.v0,
                      pardef[1].var.point_st.pt,pt1);

        point_on_line(pardef[0].var.line_st.p0,
                      pardef[0].var.line_st.v0,
                      pardef[2].var.point_st.pt,pt2);

/* now compute baryfact */
        MAsubvc( &msg, pt2, pt1, v);
        length = v_len( v );
        if( length == 0 ) {*xbary = 0; v_equal(pt1,pt_res);break;}
        MAsubvc( &msg, pt_init, pt1, v1 );
 	*xbary = v_dot( v1, v ) / (length * length) ;
	v_comb(un,pt1,*xbary,v,pt_res);
	break;

   case 21 :  /* point on circle or arc */
	
   {
    IGRdouble pc1[4];
    IGRdouble mat[9];
    IGRshort four =4,one =1;

    mat4_3( pardef[0].var.circle_st.mat, mat );
    point_on_circle(pardef[0].var.circle_st.cent_p, pardef[0].var.circle_st.rad,
                     mat, pt_init ,pc1);

    mes_angle( pardef[0].var.circle_st.rad, pc1, pc1, (IGRshort) 0,
                xbary, xbary, &length );

    if(pardef[0].type != arc_type) length = 2*PI;
    else length = pardef[0].var.circle_st.sweep_angle;

    if(length ==0) *xbary=0;
	     else  *xbary = *xbary/length;

    pc1[3] = 1;
    MAmulmx(&msg, &four, &four, &one, pardef[0].var.circle_st.mat, pc1, pt_res);
    break;
   }

        
   case 23 :  /* point on circle with limits */
   {
    IGRshort four =4,one =1;
    IGRdouble pc1[4],a1,a2;
    IGRdouble mat[9];
    mat4_3( pardef[0].var.circle_st.mat, mat );
    point_on_circle(pardef[0].var.circle_st.cent_p, pardef[0].var.circle_st.rad,
                     mat, pardef[1].var.point_st.pt ,pt1);
    point_on_circle(pardef[0].var.circle_st.cent_p, pardef[0].var.circle_st.rad,
                     mat, pardef[2].var.point_st.pt ,pt2);

    point_on_circle(pardef[0].var.circle_st.cent_p, pardef[0].var.circle_st.rad,
                     mat, pt_init ,pc1);

     mes_angle( pardef[0].var.circle_st.rad, pt1, pt2, (IGRshort) 0,
                &a1, &a2, &length );
     mes_angle( pardef[0].var.circle_st.rad,  pt1, pc1, (IGRshort) 0,
                &a1, &a2, xbary );
     if(length == 0) *xbary=0;
               else  *xbary =  *xbary / length;

    pc1[3]=1;
    MAmulmx( &msg, &four, &four, &one, pardef[0].var.circle_st.mat, pc1,pt_res);
    break;
   }

   case 31 :
   case 33 : /*point on point */
    v_equal(pardef[0].var.point_st.pt,pt_res);
    *xbary = 0;
    break;

    default :
       printf("index point case not implemented\n");
       return(OM_W_ABORT);

     } /* end switch */
     return(OM_S_SUCCESS);
}


/*
   Compute the index point from the barycentric coordinate
*/

#argsused
int ASindex_point(quel_cas,md_env,pardef,parent,xbary,point)
    IGRint quel_cas;
    struct GRmd_env *md_env;
    struct ret_struct  *pardef;
    struct GRid *parent;
    IGRdouble xbary;
    IGRdouble point[];

 {
  IGRpoint dir_pt[1] ,pt1,pt2;   /* start and end point                      */
  double   dir_par,par1,par2;   /* corresponding parameter                  */
  IGRpoint v;
  IGRdouble bary_m_1;
  IGRlong msg;
  IGRdouble length, dist;
  IGRdouble zero = 0., un = 1.;
  IGRint status;
  IGRlong rc;
  struct IGRbsp_curve *bc;
  IGRdouble half_par;
  IGRboolean bsstat;

/*"index_point quel_ca: %d\n", quel_cas */
switch (quel_cas)
 {
  case 1 :                          /* point on support without limits   */

      status = ASgenabsg(parent,&bc);
      as$status(action = RET_STATUS);

      AStotlen(&rc,bc,&length);

      length = xbary * length;
      /*"point at %lf of start\n",length */

      /*| Compute direction point */
      BScveval( bc, 0.05, 0, dir_pt, &rc );
      if( rc != BSSUCC ) return(OM_W_ABORT);

   if(bc->order > 2)     /* waiting fix in math lib */
     {
      BSptsdlcv(&rc, bc, &zero, dir_pt[0], &length, point);
     }
   else
     {
      int i;
      double *p1,*p2;
      double v[3],x1,x2;
      double cum_length,inc_length = 0.0;
      cum_length = 0;
      p1 = bc->poles;
      p2 = p1+3;
      for(i=0;i<bc->num_poles-1;i++)
        {
	 v_sub(p2,p1,v);
	 inc_length = v_len(v);
	 if(inc_length + cum_length  > length) break;
	 cum_length += inc_length;
	 p1 = p2; 
	 p2 += 3;
	}
       if(inc_length != 0)
        {
         x2 = (length - cum_length)/inc_length;
         x1 = 1-x2;
         v_comb(x1,p1,x2,p2,point);
	}
       else v_equal(p1,point);
      }
      if( rc != BSSUCC ) return(OM_W_ABORT);
      /*"point %lf %lf %lf\n",point[0],point[1],point[2]*/
      break;

/* point between two points */
  case 32 :
      bary_m_1 = 1. - xbary;
      v_comb(bary_m_1,pardef[0].var.point_st.pt,
             xbary,pardef[1].var.point_st.pt, point);
      break;

  case 3 :/*| point on curve (consider as open) between two points */

      status = ASgenabsg(parent,&bc);
      as$status(action = RET_STATUS);

      ASmdstptcv(bc, pardef[1].var.point_st.pt, &par1, pt1, &dist, &rc);
      if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }

      ASmdstptcv(bc, pardef[2].var.point_st.pt, &par2, pt2, &dist, &rc);
      if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }

      half_par = 0.5 * (par1 + par2);
      ASarclen(&rc, &bsstat, bc, &par1, &par2, &half_par, &length);
      if( rc != BSSUCC ) { /*| Error 2 in BSarclen */ return(OM_W_ABORT); }

      /*| Compute direction point */
      if(xbary < 0)
       {
        xbary = -xbary;
        if(par1 < par2)
         {
          dir_par = 0.5 * par1;
         }
        else
         {
          dir_par = 0.5 * (par1 + 1.);
         }
        }
       else  dir_par = 0.5 * (par1 + par2);
      /*"par1: %lf, par2: %lf, dir_par: %lf\n", par1, par2, dir_par */

      length = xbary * length;
      BScveval( bc, dir_par, 0, dir_pt, &rc );
      if( rc != BSSUCC ) return(OM_W_ABORT);
	
      /*"length: %lf\n", length */
      BSptsdlcv(&rc, bc, &par1, dir_pt[0], &length, point);
      if( rc != BSSUCC ) return(OM_W_ABORT);
      /*"point %lf %lf %lf\n",point[0],point[1],point[2]*/
      break;


  case 11 :      /* point on line */
      bary_m_1 = 1. - xbary;
      v_comb(bary_m_1,pardef[0].var.line_st.p0,
             xbary,pardef[0].var.line_st.p1, point);
      break;


  case 13 :      /* point on line between limits */

/* project start and end point on support */
	v_sub(pardef[1].var.point_st.pt , pardef[0].var.line_st.p0 , v);
	length = v_dot(pardef[0].var.line_st.v0 , v);
	v_comb(un,pardef[0].var.line_st.p0,length,pardef[0].var.line_st.v0,pt1);
	
	v_sub(pardef[2].var.point_st.pt , pardef[0].var.line_st.p0 , v);
	length = v_dot(pardef[0].var.line_st.v0 , v);
	v_comb(un,pardef[0].var.line_st.p0,length,pardef[0].var.line_st.v0,pt2);

        bary_m_1 = 1. - xbary;
        v_comb(bary_m_1,pt1, xbary,pt2, point);
        break;


  case 21 :      /* point on circle  */
   {
    IGRdouble pc1[4];
    IGRshort four=4, one=1;

    if(pardef[0].type != arc_type)
      {xbary = xbary*2*PI;}
    else
      {xbary = xbary*pardef[0].var.circle_st.sweep_angle;}
    pc1[0] = pardef[0].var.circle_st.rad * cos(xbary);
    pc1[1] = pardef[0].var.circle_st.rad * sin(xbary);
    pc1[2] = 0; pc1[3] = 1;
    MAmulmx( &msg, &four, &four, &one, pardef[0].var.circle_st.mat, pc1, point);
    break;
   }

  case 23 :      /* point on circle with limits */
   {
    IGRshort four =4,one =1;
    IGRdouble pc1[4],a1,a2;
    IGRdouble mat[9];
    mat4_3( pardef[0].var.circle_st.mat, mat );
    point_on_circle(pardef[0].var.circle_st.cent_p, pardef[0].var.circle_st.rad,
                     mat, pardef[1].var.point_st.pt ,pt1);
    point_on_circle(pardef[0].var.circle_st.cent_p, pardef[0].var.circle_st.rad,
                     mat, pardef[2].var.point_st.pt ,pt2);

     mes_angle( pardef[0].var.circle_st.rad, pt1, pt2, (IGRshort) 0,
                &a1, &a2, &length );
    xbary =  a1 + xbary * length;

    pc1[0] = pardef[0].var.circle_st.rad * cos(xbary);
    pc1[1] = pardef[0].var.circle_st.rad * sin(xbary);
    pc1[2] = 0; pc1[3] = 1;
    MAmulmx( &msg, &four, &four, &one, pardef[0].var.circle_st.mat, pc1, point);
    break;
   }

   case 31 :
   case 33 : /*point on point */
    v_equal(pardef[0].var.point_st.pt,point);
    break;

  default :
      printf(" indexpoint case not implemented \n");
      return(OM_W_ABORT);


  }  /* end switch on parents number */

  return(OM_S_SUCCESS);
}

/*
-----------------------------------------------------------------
  ASindexpt.place
-----------------------------------------------------------------
*/

method NDplace(struct GRas *asso_lis;struct GRmd_env *md_env;
	       IGRchar *go_cnst_lis)
{
  struct GRid *parent;
  OMuint count;
  IGRdouble point[4]; /* be carreful index_point uses a 4 double point */
  IGRdouble *snap;
  struct ret_struct  pardef[4], objdef;
  IGRint icount;
  IGRint quel_cas;
  IGRlong msg,status;
  IGRboolean track;
  double pt_track[3];
  
  count = asso_lis->num_parents;
  parent = asso_lis->parents;

  if(count<1 || count>4)return(OM_W_ABORT);

/*
   get parent definition and identify the compute case 
*/

  for(icount = 0 ; icount<count ; icount++)
    {
     status = om$send(msg = message NDnode.NDgive_structure
						  (&msg,&pardef[icount],md_env),
		      targetid = (parent+icount)->objid,
		      targetos = (parent+icount)->osnum);
     as$status(action = RET_STATUS);
    }
  if( count == 4 || ( count == 3 && (pardef[0].type & point_generic) )
          || ( count == 2 && (pardef[0].type & ~point_generic) ) )
   {
    /*| there is a track point */
    track = TRUE;
    quel_cas = count -1;
   }
  else
   {
    /*| there is no track point */
    track = FALSE;
    quel_cas = count;
   }
 
  if(pardef[0].type & line_generic) quel_cas = quel_cas + 10;
							 /* specific on line*/

  else if(pardef[0].type & conic_generic) quel_cas = quel_cas +20;
							 /* specific on circle*/
  else if(pardef[0].type & point_generic) quel_cas = quel_cas +30;
							 /* specific on point*/


/*
   when the graphic object already exist compute the projection and the 
   barycentric coordinate
*/

 if( !(IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID )))
  {
   status = as$any_give_structure(go_grid = asso_lis->go_objid,
                       		   mod_env = md_env,
				   inst    = &objdef );
   as$status(action = RET_STATUS);
   if(track) v_equal(pardef[count-1].var.point_st.pt,pt_track);
   else      v_equal(objdef.var.point_st.pt,pt_track);

   status = om$send(msg = message ASindexpt.ASindex_bary
					(quel_cas,md_env,
					pardef,parent,objdef.var.point_st.pt,
					pt_track,
   					&me->bary_fact,point),
		    targetid = my_id);
   if(status != OM_S_SUCCESS)
			   {printf("ASindexpt place error abort");return(msg);}
  }

/* 
   When the graphic object doesn't exist compute the point from the bary
   coordinate
*/

 else
  {
   me->bary_fact = *((IGRdouble *)asso_lis->as_attr);


/* rustine pour pouvoir placer un index point correspondant a un snap point */
/* jla 20-07-87 */

   if(me->bary_fact > 1.e+10)
     {
      snap =(IGRdouble *)asso_lis->as_attr + 1;
      if(track) v_equal(pardef[count-1].var.point_st.pt,pt_track);
      else      v_equal(snap,pt_track);

      status = om$send(msg = message ASindexpt.ASindex_bary
					    (quel_cas,md_env,
					     pardef,parent,snap,
					     pt_track,
      		       			     &me->bary_fact,point),
		       targetid = my_id);
      if(status != OM_S_SUCCESS)
			      {printf("ASindexpt place error \n");return(msg);}
     }

   else
     {
      msg = ASindex_point(quel_cas,md_env,pardef,parent,me->bary_fact,
		     point);

      if(msg != OM_S_SUCCESS){printf("ASindexpt place error \n");return(msg);}
     }
  }

 if(go_cnst_lis != NULL)
  {
    struct IGRpolyline geom;
    /*| Construct the G.O */
    geom.num_points = 1;
    geom.points     = point;

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (IGRchar *) &geom;

    status = om$send(msg = message ASnode.ASconstruct_go
		      (asso_lis,md_env,go_cnst_lis,OPP_GR3dpoint_class_id,TRUE),
		     targetid = my_id);
    as$status(action = RET_STATUS);
  }


/*
  we ask the graph manager to add the new ASindexpt to the graph 

*/

  status = om$send(msg = message NDnode.NDconnect
	          (asso_lis->num_parents,asso_lis->parents,NULL_GRID,ND_NEW),
            	     targetid = my_id);
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);

}/* place */


/* ----------------------------------------------------------------------
  compute the index point
------------------------------------------------------------------------ */
method NDcompute_node(IGRlong *msg;IGRint cn_type;
		      int count;struct GRid list[];struct GRmd_env *md_env)
{
  struct ret_struct  pardef[4],
		     objdef;
  IGRint icount;
  IGRdouble point[4];   /* be carrefull index_point uses a 4 double point */
  IGRint status;
  IGRboolean track;
  double pt_track[3];
  int quel_cas;

  if(count<1 || count>4)
  {
    printf("ASindexpt.compute_node bad parent number \n");
    return(0);
  }

  /*" obj %d, bary %lf\n",my_id,me->bary_fact */

  for (icount=0 ; icount<count ; icount++)
    {
     status = om$send(msg = message NDnode.NDgive_structure 
						 (msg,&pardef[icount],md_env),
	    	      targetid = list[icount].objid,
	    	      targetos = list[icount].osnum);
     as$status(action = RET_STATUS);
    }
  if( count == 4 || ( count == 3 && (pardef[0].type & point_generic) )
          || ( count == 2 && (pardef[0].type & ~point_generic) ) )
   {
    /*| there is a track point */
    track = TRUE;
    quel_cas = count -1;
   }
  else
   {
    /*| there is no track point */
    track = FALSE;
    quel_cas = count;
   }

  if(pardef[0].type & line_generic) quel_cas = quel_cas + 10;
							 /* specific on line*/
  else if(pardef[0].type & conic_generic) quel_cas = quel_cas + 20;
							 /* specific on circle*/
  else if(pardef[0].type & point_generic) quel_cas = quel_cas + 30;
							 /* specific on point*/

  /*
     compute graphic point from barycentric coordinate (regular compute)
     or barycentric coordinate from graphic object. It's the case when
     the index point has received an GRxform or GRmodify message
  */

  if( (cn_type&ND_COMP_TYPE) != ND_COMP_XF)
    {
     /*| graphic object from barycentric coordinate */
     status = ASindex_point(quel_cas,md_env,pardef,list,me->bary_fact,point);
    }
  else
    {
     /*| barycentric coordinate from graphic object */
     status = om$send(msg = message NDnode.NDgive_structure
							(msg,&objdef,md_env),
		      targetid = my_id);
     as$status(action = RET_STATUS);
     if(track) v_equal(pardef[count-1].var.point_st.pt,pt_track);
     else      v_equal(objdef.var.point_st.pt,pt_track);

     status = om$send(msg = message ASindexpt.ASindex_bary
					(quel_cas,md_env,
					 pardef,list,
				         objdef.var.point_st.pt,
				         pt_track,
   			 		 &me->bary_fact,point),
		      targetid = my_id);
    }
    

  if(status != OM_S_SUCCESS)
		{printf("compute_node error. index point not updated");
		 return(OM_S_SUCCESS);}

{
 struct GRpost_info post_info;
 GRobjid newobjid;
 struct IGRpolyline polyline;

 polyline.num_points = 1;
 polyline.points = point;
 post_info.construct_flag = FALSE;

 status = om$send(msg=message GRlinear.GRputpolyline
                                   (msg,md_env,&post_info,&polyline,&newobjid),
                  p_chanselect = &AS_to_comp );
 as$status(action = RET_STATUS);
 }

  

  return(OM_S_SUCCESS);
}    /* end of compute_nod method */

/*
   Does the xform on the graphic object
   Notify the graph manager that the element and its dependency 
   need to be recompute. New value of barycentric coordinate 
   will then be obtained from graphic object
*/

method GRxform(IGRlong *msg; struct GRmd_env *md_env; 
	       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *new_objid)
{

  IGRint status;
  struct GRid my_grid;
  IGRint cn_type;

 /*"obj %d\n",my_id*/

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

  /* send message to graphic object */

  status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
  as$status();
		   

  /* do the wait batch */

  if(!ASbroadcast_in_progress)
   {
    cn_type = ND_COMP_XF;
    nd$wait_batch(type = GR_GEOM_POSTED,
		  l_object  = &my_grid,  l_obj_info = &cn_type,
		  nb_obj    = 1);
   }

    *new_objid = my_id;
 return(status);
}

/*
   GRmodify override. Allow the user to change the barycentric coordinate
*/

method GRmodify(IGRlong *msg; struct GRmd_env *md_env;
	        struct GRparms *parms; 
		IGRpoint point; struct IGRline *boreline;
		GRobjid *new_objid)
{
  IGRint status;
  struct GRid my_grid;
  IGRint cn_type;


 /*"obj %d\n",my_id*/

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

  /* send message to graphic object */


  status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
  as$status();

    /* tell it */

  if(!ASbroadcast_in_progress)
   {
    cn_type = ND_COMP_XF;
    nd$wait_batch(type = GR_GEOM_POSTED,
		  l_object  = &my_grid,  l_obj_info = &cn_type,
		  nb_obj    = 1);
   }

   *new_objid = my_id;
  
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

  fprintf(stream,"send ASindexpt.place(%d,list,ptr) to %s;\n\n",count,name);
  return(1);
}/* end print */


method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
    *msg = MSSUCC;
    ex$message (buff=info->type,msgnumb=AS_I_EqPt);
    return(OM_S_SUCCESS);
}


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
     geom_code[j]   = ~0x0;
     option_code[j] = 1;
     break;
    }
   
   case 1 :
    {
     geom_code[j]   = point_generic;
     option_code[j] = 1;
     break;
    }
   
   case 2 :
    {
     geom_code[j]   = point_generic;
     option_code[j] = 1;
     break;
    }
  } /*  end switch  */

 /*  track point or ref ? */
   
 *index_ref   = -1;  /* no ref.        */
 *index_track = -1;  /* no track point */
 *index_plan  = -1;  /* no plane       */        

 return(OM_S_SUCCESS);
}


method ACcompute_node( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *prop,*size_inst,*no_go;
			   char *inst_save)
{
int siz_inst,status;
 siz_inst=sizeof(me->bary_fact);
 OM_BLOCK_MOVE(  inst_save,&me->bary_fact, 
		siz_inst);

 status = om$send(msg =  message NDnode.NDcompute_node (msg,cn_type ,
					count,list, 
					md_env),
  		   targetid =my_id ); 
 as$status( );

 if (!( (me->state) & ND_OUT_OF_RT)&& *no_go != -1 )
      {*no_go += 1;}

 OM_BLOCK_MOVE( &me->bary_fact, inst_save,
		siz_inst);
 
 *size_inst += siz_inst ;
 return(1);
}


end implementation ASindexpt;
