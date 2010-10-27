/* $Id: ASindexpt1.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdassoc/ASindexpt1.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: ASindexpt1.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *      Initial import to CVS
 *
# Revision 1.3  2000/03/07  20:11:22  pinnacle
# Replaced: vdassoc/ASindexpt1.I for:  by impd252 for vds
#
# Revision 1.2  2000/03/03  21:41:10  pinnacle
# Replaced: vdassoc/ASindexpt1.I for:  by impd252 for vds
#
# Revision 1.1  2000/03/03  21:33:34  pinnacle
# Created: vdassoc/ASindexpt1.I by impd252 for vds
#
 *
 * History
 *	03/03/00	adz Protection from crash..
 */

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
       /* "pointBefore %lf %lf %lf\n",p1[0],p1[1],p1[2] */
	if (!p1){
		printf("pointBefore NULL \n");
	/*	VDdumpCurve( NULL, bc, "Index" ); */
	}
       if(inc_length != 0)
        {
         x2 = (length - cum_length)/inc_length;
         x1 = 1-x2;
         v_comb(x1,p1,x2,p2,point);
	}
       else {
		if( p1) v_equal(p1,point);
	   }
      }
      if( rc != BSSUCC ) return(OM_W_ABORT);
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

/* ----------------------------------------------------------------------
  compute the index point
------------------------------------------------------------------------ */

#ifdef	DEBUG

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
    track = TRUE;
    quel_cas = count -1;
   }
  else
   {
    /*" there is no track point */
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

#endif

end implementation ASindexpt;
