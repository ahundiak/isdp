/* $Id: ASextbspi.I,v 1.2 2001/01/18 19:22:50 ramarao Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vdassoc/ASextbspi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: ASextbspi.I,v $
 * Revision 1.2  2001/01/18 19:22:50  ramarao
 * Merged Service Pack Files to 262 pload.
 *
 * Revision 1.1  2001/01/18 19:08:53  ramarao
 * Merged Service Pack Files to 262 pload.
 *
# Revision 1.1  2000/10/31  17:12:20  pinnacle
# Created: vds/vdassoc/ASextbspi.I by jpulapar for Service Pack
#
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 10/31/00  Jayadev   GRvg.GRgenabsg failing inisde ASextract_cv 
 *
 ***************************************************************************/
class implementation ASextbsp;

#define MAX_SEG 10
#define EPS 1.0e-10          /* Valeur pour eviter un bug d'ems           */
#define EPS2 1.0e-20

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "msdef.h"
#include "grerr.h"
#include "asbox.h"
#include "grownmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "ASmsg.h"
#include "msmacros.h"

#define   AS_DEBUG   1           /* For debug preprocessor                    */

from GRlinear import    GRputpolyline;
	    
ASextract_cv(bsp_to_split,p0,p1,md_env,result)
struct GRid bsp_to_split;
IGRdouble *p0,*p1;
struct GRmd_env *md_env;
struct GRid *result;
/*.ASextract_cv*/
{
IGRint i;
IGRshort nb_obj;
IGRlong status,msg,rc;
IGRdouble dist,dist0,dist1; 
IGRdouble BSdistptpts();
OM_S_OBJID obj1,obj2;
IGRpoint point0,point1,proj_pt[2],tmp_pt,extend_point;
IGRdouble *split_point[2];
IGRdouble total_parm[2],total_tmp;
struct GRparms proj_parm[2],tmp_parm;
struct    GRprops   props;     /* Properties of the support                 */
struct IGRbsp_curve *bc = NULL;
double fabs();
double eps;


   BSEXTRACTPAR(&msg,BSTOLLENVEC,eps);

/* project the split point on the curve */
/* All this mess to make it work on composite .... */

/*"curve %d %d\n",bsp_to_split.objid,bsp_to_split.osnum*/
  split_point[0] = p0;
  split_point[1] = p1;

  status = om$send(msg = message GRvg.GRgenabsg(&msg,
                                                &md_env->md_env.matrix_type,
                                                md_env->md_env.matrix, 
						(char **) &bc),
                   senderid = NULL_OBJID,
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);
  // check the return status and the geometry pointer 
  if((!(status&1)) || (bc == NULL))
  {
    status = OM_W_ABORT;
    return status;
  }
  for(i=0 ; i<2 ; i++)
   {
    BSmdstptcv(bc, split_point[i], &total_parm[i], proj_pt[i], &dist, &rc);
/*^ pr_point("split_point[i]",split_point[i]); 
    printf("param %lf dist %lf\n",total_parm[i],dist);
    pr_point("proj_pt[i]",proj_pt[i]); 
*/
    
    if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }
   }


  for(i=0 ; i<2 ; i++)
   {
    v_equal(proj_pt[i],tmp_pt);
    status = om$send (msg      = message GRgraphics.GRptproject(&msg,
                                    &md_env->md_env.matrix_type,
                                     md_env->md_env.matrix,
                                     tmp_pt, proj_pt[i], &proj_parm[i]),
	          senderid = NULL_OBJID,
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);
     as$status(action = RET_STATUS);
    }


 /* Special treatment when the result has a null length */

 if(fabs(total_parm[0]-total_parm[1]) < EPS)
  {
   double w[3];
   v_sub(p1,p0,w);
   dist = v_len(w);
   /*"dist %lf eps %lf\n", dist,eps */
   if(dist<eps)
    {
     struct GRpost_info post_info;
     struct IGRpolyline polyline;
     OM_S_OBJID save_md;

     /*| Null length extraction */

     polyline.num_points = 1;
     polyline.points = &proj_pt[0][0];
     post_info.construct_flag = TRUE;

     /* to keep symbology properties ... */

     if(md_env->md_id.objid != NULL_OBJID)
      {
       status = om$send(msg = message GRgraphics.GRremwrng(&msg,md_env),
                      targetos = bsp_to_split.osnum,
                      targetid = bsp_to_split.objid,
		      senderid = NULL_OBJID);
       as$status();
      }

     status = om$change_class(objid = bsp_to_split.objid,
			      osnum = bsp_to_split.osnum,
			    classname = "GR3dlineseg");
     as$status();
     if(status&1)
      {
       save_md = md_env->md_id.objid;
       md_env->md_id.objid = NULL_OBJID;
       status = om$send(msg = message GRlinear.GRputpolyline(&msg,md_env,
                                    &post_info, &polyline,&result->objid),
                      targetos = bsp_to_split.osnum,
                      targetid = bsp_to_split.objid,
		      senderid = NULL_OBJID);
       md_env->md_id.objid = save_md;

       /*bsp_t_split %d reuls %d\n",bsp_to_split.objid,result->objid */
       /*"md_env %d\n",md_env->md_id.objid*/
       /*"msg %d \n",msg */
       result->osnum = bsp_to_split.osnum;
       GRabsg_del_all();
       as$status();
       if(md_env->md_id.objid != NULL_OBJID)
       {
        status = om$send(msg = message GRgraphics.GRaddwrng(&msg,md_env),
                      targetos = result->osnum,
                      targetid = result->objid,
		      senderid = NULL_OBJID);
        as$status();
       }
      }
     return(status);
    }
  }
  /* Get the type of the curve and reorder the split point on open curve */

  status = om$send (msg  = message GRvg.GRgeomprops(&msg,
                                   &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix, &props),
	      senderid = NULL_OBJID,
              targetos = bsp_to_split.osnum,
              targetid = bsp_to_split.objid);
  as$status(action = RET_STATUS);

  if(!props.closed)
    {
     double w[3];
     status = om$send(msg    = message GRbspline.GRendpts(&msg,
                                       &(md_env->md_env.matrix_type),
					 md_env->md_env.matrix,
                                        point0, point1),
	                 senderid = NULL_OBJID,
                         targetos = bsp_to_split.osnum,
                         targetid = bsp_to_split.objid);
     as$status();
     v_sub(p0,point1,w);
     dist0 = v_len(w);

     v_sub(p1,point1,w);
     dist1 = v_len(w);

     if( dist0 < eps ||
	(total_parm[1] < total_parm[0] && dist1 > eps))
       {
        total_tmp = total_parm[1];
	tmp_parm = proj_parm[1];
	proj_parm[1] = proj_parm[0]; total_parm[1] = total_parm[0];
	proj_parm[0] = tmp_parm; total_parm[0] = total_tmp;

        split_point[0] = p1;
        split_point[1] = p0;

	v_equal(proj_pt[1],tmp_pt);
	v_equal(proj_pt[0],proj_pt[1]);
	v_equal(tmp_pt,proj_pt[0]);
       }
    }
  
  /* split or extend  on first point */

  if(props.closed || (total_parm[0] > EPS && total_parm[0] < 1-EPS))
    {
      /*| split + delete on first point */
      /* We don't use extend on open curves because does only the extend on */
      /* the last segment if several					    */

      status = om$send (msg  = message GRcurve.GRsplit
                                         (&msg,md_env,
                                          proj_pt[0],
                                          &proj_parm[0], &obj1,
                                          &obj2, &nb_obj),
	          senderid = NULL_OBJID,
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);
         if(status&1 && nb_obj ==1)
          {
           bsp_to_split.objid= obj1;
	   bsp_to_split.osnum = md_env->md_id.osnum;
          }
        else if(status&1 && nb_obj == 2)
	  {
	   bsp_to_split.objid = obj2;
	   bsp_to_split.osnum = md_env->md_id.osnum;
           status = om$send( msg = message GRgraphics.GRdelete(&msg, md_env),
			   senderid = NULL_OBJID,
			   targetid = obj1,
			   targetos = md_env->md_id.osnum);
	    as$status();
          }
	else
	  {     
	   status = OM_S_SUCCESS;
           /* commented out to support zero radius fillet jla 18-sep-90 */
           /* return (OM_W_ABORT); */
          }

    }
  else
   {
    /*| extend if necessary first extremity to the external of the curve */
     dist = BSdistptpts(&msg,point0,split_point[0]);
    /*"dist %le eps %le\n",dist,EPS */
     if(dist > EPS2)
       {
        /*| Extend the begining of the B_spline */
         status = om$send(msg    = message GRbspline.GRptextend(&msg,
                                               md_env, point0,
                                               split_point[0],
                                               extend_point),
	          	       senderid = NULL_OBJID,
                               targetos = bsp_to_split.osnum,
                               targetid = bsp_to_split.objid);
         as$status();
        }
    }

      /*"1er split --> %d \n",bsp_to_split.objid */

 /* Now split or extend on the second point */

  if(props.closed || (total_parm[1] > EPS && total_parm[1] < 1-EPS))
    {
      /*| split and delete on second end point */
      /* same remark than for the first extend or split */
      status = om$send (msg      = message GRgraphics.GRptproject(&msg,
                                     &(md_env->md_env.matrix_type),
                                     md_env->md_env.matrix,
                                     proj_pt[1],
                                     tmp_pt, &proj_parm[1]),
	          senderid = NULL_OBJID,
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);
      as$status(action = RET_STATUS);

      status = om$send (msg  = message GRcurve.GRsplit
                                         (&msg,md_env,
                                          tmp_pt,
                                          &proj_parm[1], &obj1,
                                          &obj2, &nb_obj),
	          senderid = NULL_OBJID,
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);
       if(!(status&1) || nb_obj<1) 
         {nb_obj = 1;
          obj1 = bsp_to_split.objid;
          status = OM_S_SUCCESS;}
      /*"2eme -->nb %d %d %d\n",nb_obj,obj1,obj2 */

      if(nb_obj == 2)
        {
	 /*| delete 2 */
         status = om$send( msg = message GRgraphics.GRdelete(&msg,
						    md_env),
			   senderid = NULL_OBJID,
			   targetid = obj2,
			   targetos = md_env->md_id.osnum);
	 as$status();
	}

      bsp_to_split.objid= obj1;

     /*"bsp_to_split after split %d\n",bsp_to_split.objid*/
    }
   else
    {
     /*| extend if necessary end of th B_spline */
     dist = BSdistptpts(&msg,point1,split_point[1]);
    /*"dist %le eps %le\n",dist,EPS */
     if (dist  > EPS2)
      {
        /*| Extend the end of the B_spline */
        status = om$send(msg    = message GRbspline.GRptextend(&msg,
                                                md_env, point1,
                                                split_point[1],
                                                extend_point),
	          	     senderid = NULL_OBJID,
                             targetos = bsp_to_split.osnum,
                             targetid = bsp_to_split.objid);
        as$status();
      }
    }

  /*" bsp_to_plit %d %d\n",bsp_to_split.objid,bsp_to_split.osnum */

  *result = bsp_to_split;

  /*" return bsp_to_plit %d %d\n",result->objid,result->osnum */
  return(status);
 }
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation ASextbsp;
