class implementation ASkeypt;

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
#include "ASmsg.h"
#include "msmacros.h"

#define AS_DEBUG

#define ONCV_VER 1
#define ANGL_VER 2

extern GRclassid OPP_GR3dpoint_class_id;

/* -----------------------------------------------------------------
  ASkeypt.place
  compute me->key and key_point from snap point 
  projection in xoy plane if referentiel as 2th parent
  ----------------------------------------------------------------- */

method NDplace( struct GRas *asso_lis;struct GRmd_env *md_env;
		IGRchar *go_cnst_lis )
{
  struct GRid *parent,go_object;
  int count;
  IGRpoint point,project,track_point;
  IGRlong msg,status,rc,rc1;
  struct IGRbsp_curve *bc;
  IGRchar *ptr;
  IGRdouble *snap;
  IGRmatrix matrix,ref_mat;
  IGRshort mat_type;
  struct ret_struct objdef,optdef;
  struct GRparms par;
  IGRint iroot,iref,itrack;
  struct IGRline boreline;
  IGRpoint boreline_pt2;


/* 
  control arguments
*/

  count = asso_lis->num_parents;
  parent = asso_lis->parents;

  if(count < 1 || count >3) return(OM_W_ABORT);
  

/* get parent def other than support */
/* after initialization if not       */

  MAidmx(&msg,ref_mat);
  itrack = 0;
  iref = 0;

  for(iroot = 1;iroot < asso_lis->num_parents; iroot++)
  {
   status = om$send(msg = message NDnode.NDgive_structure(&msg,&optdef,md_env),
                    targetid = parent[iroot].objid,
                    targetos = parent[iroot].osnum);
   as$status(action = RET_STATUS);
   if(optdef.type&ref_generic)
     {
      /*| There is a coor. syst. as root */
      if(iref == 1) return(OM_W_ABORT);
      iref = 1;
      AStrans_mat(optdef.var.ref_st.t,ref_mat);
     }
   else if(optdef.type&point_generic)
     {
      /*| There is a track point */
      if(itrack == 1) return(OM_W_ABORT);
      itrack = 1;
      v_equal(optdef.var.point_st.pt,track_point);
     }
    else return(OM_W_ABORT);
  }

/*
   When there is a track point, compute keypoint nearest from track point.
   When the graphic object exists compute the key point graphic object.
   Else computes nearest from snap point 
*/
 if(itrack)
  {
   snap = track_point;
  }
 else if( !(IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID )))
  {
   msg = ASany_give_struct( asso_lis->go_objid.objid,asso_lis->go_objid.osnum,
                      md_env, &objdef );
   if(msg != OM_S_SUCCESS){printf("ASkeypt place error abort");return(msg);}
   snap = objdef.var.point_st.pt;
  }
 else
 {
  snap = (IGRdouble *) asso_lis->as_attr;
 }


/* If keypoint is on a text create a box point instead */

   status = om$send(msg = message NDnode.NDgive_structure(&msg,&optdef,md_env),
                    targetid = parent[0].objid,
                    targetos = parent[0].osnum);
   as$status(action = RET_STATUS);
   if(optdef.type&lbs_generic)
     {
      IGRdouble dmin,dummy_par,xbar[3],xbar_cnst[3],dummy_pt[3];
      IGRchar *save;
      OM_S_OBJID mi;

      /*| point at keypoint on text, change class to ASboxpt */

      /* find solution nearest from accept point */
      dmin = 1.e+32;
      for(xbar[0] = 0.; xbar[0]<1.1; xbar[0] += 0.5)
	 { for(xbar[1] = 0.; xbar[1]<1.1 ; xbar[1] += 0.5)
	 { /*"xbar %lf %lf\n",xbar[0],xbar[1] */
	   ASbox_pt_eval(&optdef,xbar,dummy_pt);
	   /*^ pr_point("res",dummy_pt); */
	   v_sub(dummy_pt,snap,dummy_pt);
	   dummy_par = v_len(dummy_pt);
	   if(dummy_par<dmin)
	     {xbar_cnst[0]= xbar[0];xbar_cnst[1]=xbar[1];
	      dmin = dummy_par;
	     }
	  }
	  }

        /*| Change the class from ASkeypt to ASboxpt */
	status = om$change_class(objid = my_id, classname = "ASboxpt",
				 sd_override = OM_K_change_class_sd_override );
        as$status(action = RET_STATUS);

	save = asso_lis->as_attr;
	asso_lis->as_attr = (IGRchar *) xbar_cnst;
	mi = my_id;
        /*^ {
    	      char class_name[OM_K_MAXCLASS_LEN];
    	      om$get_classname(objid = mi, classname = class_name);
    	      printf("new class %s\n",class_name);
             }
	 */
        /* Cannot use targetid = my_id because it does not work */
        status = om$send(msg = message NDnode.NDplace(asso_lis,
						       md_env,go_cnst_lis),
			  targetid = mi);
        as$status(action = RET_STATUS);

	asso_lis->as_attr = save;
	return (status);
       }
/* end  Modif jla 04-january-1989 */


/* get geometry of curve and project point on it  */

    status = om$send(msg = message NDnode.ASreturn_go(&go_object,
						 &mat_type,matrix),
           	     targetid = parent[0].objid ,
           	     targetos = parent[0].osnum );
    if(!(status&1))
      {go_object = parent[0];
       mat_type = MAIDMX;
       MAidmx(&msg,matrix);
      }

/* modif jla 07-march-89 to make it consistant with regular keypoint  */

/*
   project the point on the curve to define the leaf_id.
*/
   

   par.leaf_id.objid = NULL_OBJID;
   status = om$send(msg = message GRgraphics.GRptproject(&msg,
                                         		&mat_type, matrix,
	                                  		snap,project,&par),
            	    targetid = go_object.objid,
	            targetos = go_object.osnum);
   as$status(action = RET_STATUS);

/*"go_object %d leaf %d par.u %lf\n",go_object.objid,par.leaf_id.objid,par.u */

   if(IF_NULL_OBJID(par.leaf_id.objid))
     {
      printf("warning keypoint placement, GRptproject returns null_objid\n");
      par.leaf_id = go_object;
     }

/*
   compute parameter value on the curve. This parameter will be used by 
   following evaluation 
*/

  me->key = -5;
  if(!IF_EQ_OBJID(par.leaf_id.objid,go_object.objid))
    {
     /*| Keypoint on composite */
     status = om$send(msg = message GRvg.GRgenabsg(&msg,&mat_type,matrix, &ptr),
		   targetid = go_object.objid, targetos = go_object.osnum);
     as$status(action = RET_STATUS);
     bc = (struct IGRbsp_curve *)ptr;
     /*^ ASedit_bsp(*bc); */
      msg = BSprptoncv(&rc,bc,project,&me->param,&rc1);
/*"me->param %lf\n",me->param*/
      if(rc != BSSUCC)
	   {printf(" ASkeypt.place can't compute parameter value\n");
	    return(OM_W_ABORT);}
    }
   else
    {
     me->param = par.u;
    }

/* find nearest keypoint from projection */

   v_add(snap,&ref_mat[8],boreline_pt2);
   boreline.point1 =  snap;
   boreline.point2 =  boreline_pt2;
     
/*^ pr_point("p1",boreline.point1);
    pr_point("p2",boreline.point2);
*/
   status = om$send(msg = message GRvg.GRkeypoint(&msg,&mat_type,matrix,
						  &boreline,point,
						  &par),
            	    targetid = par.leaf_id.objid,
	            targetos = par.leaf_id.osnum);
   as$status(action = RET_STATUS);


/* Make sure that is the correct key point when tehr is no coordinate system */

 if(!iref)
  {
   double point_bis[3],w[3];
   double len,len_bis;
   struct GRparms par_bis;
   v_add(snap,&ref_mat[4],boreline_pt2);
   boreline.point1 =  snap;
   boreline.point2 =  boreline_pt2;
     
/*^ pr_point("p1",boreline.point1);
    pr_point("p2",boreline.point2);
*/
   status = om$send(msg = message GRvg.GRkeypoint(&msg,&mat_type,matrix,
						  &boreline,point_bis,
						  &par_bis),
            	    targetid = par.leaf_id.objid,
	            targetos = par.leaf_id.osnum);

/*^ pr_point("point",point);
    pr_point("point_bis",point_bis);
*/
   v_sub(point,snap,w);
   len= v_len(w); 

   v_sub(point_bis,snap,w);
   len_bis = v_len(w); 

   if(len>len_bis)
    {v_equal(point_bis,point);
     par = par_bis;
    }
  }
 


/*
   If there is a coordinate system as root, project the keypoint 
   in its xy plane
*/
 if(iref)
   ASproject_in_xy(ref_mat,AS_IN_COL,point,point);

 /*" ASkeypt.place point a creer %lf %lf %lf\n",point[0],point[1],point[2] */

 if(go_cnst_lis != NULL)
  {
    struct IGRpolyline geom;

    /*| Construct the G.O */
    geom.num_points = 1;
    geom.points     = point;

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (char *) &geom;

    status = om$send(msg =message ASnode.ASconstruct_go
		      (asso_lis,md_env,go_cnst_lis,OPP_GR3dpoint_class_id,TRUE),
		   targetid = my_id);
    as$status(action = RET_STATUS);
  }


/*
  we ask the graph manager to add the new ASkeypt to the graph 
*/
  
  status = om$send(msg = message NDnode.NDconnect(asso_lis->num_parents,
				asso_lis->parents,NULL_GRID,ND_NEW),
		  targetid = my_id);
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);

}/* place */


/* ----------------------------------------------------------------------
  compute the keypt point
------------------------------------------------------------------------ */
method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count;struct GRid list[];
		      struct GRmd_env *md_env)
{
  IGRlong status,rc,rc1;
  struct IGRpolyline polyline;
  struct GRpost_info post_info;
  IGRpoint track_point,point,w,project;
  OM_S_OBJID newobjid;
  struct GRid go_object;

  IGRchar *ptr;
  struct ret_struct optdef;
  IGRint iv,iz;
  struct IGRbsp_curve *bc;
  IGRmatrix matrix,ref_mat;
  IGRshort mat_type;
  IGRdouble par1;
  IGRdouble scal2;
  IGRdouble tol;
  IGRdouble distance,initial_u;
  IGRint iroot,itrack,iref;
  struct GRparms par;
  struct IGRline boreline;
  IGRpoint boreline_pt2;

  if(count<1 || count>3)
  {
    printf("Warning ASkeypt has a bad parent number --> doesn't recompute \n");
    return(1);
  }
  
/* get parent def other than support */
/* after initialization if not       */

  MAidmx(msg,ref_mat);
  itrack = 0;
  iref = 0;

  for(iroot = 1;iroot < count; iroot++)
  {
   status = om$send(msg = message NDnode.NDgive_structure(msg,&optdef,md_env),
                    targetid = list[iroot].objid,
                    targetos = list[iroot].osnum);
   as$status(action = RET_STATUS);
   if(optdef.type&ref_generic)
     {
      /*| There is a coor. syst. as root */
      if(iref == 1) return(OM_S_SUCCESS);
      iref = 1;
      AStrans_mat(optdef.var.ref_st.t,ref_mat);
     }
   else if(optdef.type&point_generic)
     {
      /*| There is a track point */
      if(itrack == 1) return(OM_S_SUCCESS);
      itrack = 1;
      v_equal(optdef.var.point_st.pt,track_point);
     }
    else return(OM_S_SUCCESS);
  }

/*
   get definition of support 
*/

    status = om$send(msg = message NDnode.ASreturn_go(&go_object,
						        &mat_type,matrix),
           	     targetid = list[0].objid ,
           	     targetos = list[0].osnum );
    if(!(status&1))
      {go_object = list[0];
       mat_type = MAIDMX;
       MAidmx(msg,matrix);
      }
  status = om$send(msg = message GRvg.GRgenabsg(msg,&mat_type,matrix, &ptr),
		   targetid = go_object.objid, targetos = go_object.osnum);
  as$status(action = RET_STATUS);
   bc = (struct IGRbsp_curve *)ptr;
/*^ ASedit_bsp(*bc); */

/* 
   compute the key point in the different case
*/

/******** part to support key point created before 1.2 *************/
/**/ 
/**/ /* convert start and end point before 1.2 to regular vertex */
/**/ 
/**/   if(me->key == -3){ me->key = 0;   /*| convert  start point */ }
/**/ 
/**/   if(me->key == -4) { me->key = bc->num_poles-1; /*| convert end point */ }
/**/ 
/**/ 
/**/ /* vertex of line string */
/**/ 
/**/    if(me->key >= 0)      
/**/     {
/**/      if(itrack)
/**/        {
/**/         BSEXTRACTPAR(&rc,BSTOLCHRDHT,tol);
/**/         ASfind_nearest_vertex(bc,0,1.e+36,tol,
/**/ 			      track_point,point,&iv,&distance);
/**/ 	if(distance >0.5e+35) return(OM_S_SUCCESS);
/**/        }
/**/      else
/**/        {
/**/ 	IGRint ipole;
/**/         if(me->key < bc->num_poles) ipole = me->key;
/**/ 	else 			    ipole = bc->num_poles-1;
/**/ 
/**/         if(bc->rational)
/**/           {
/**/ 	   scal2 = 1/bc->weights[ipole];
/**/            v_scale(bc->poles+3*ipole,scal2,point);
/**/           }
/**/          else 
/**/           {
/**/            v_equal(bc->poles+3*ipole,point);
/**/           }
/**/         }
/**/      }
/**/ 
/**/ /* tangent to b_spline */
/**/ 
/**/    else if(me->key > -3)
/**/      {
/**/       iz=-me->key-1;
/**/       if(itrack)
/**/        {
/**/         *msg = BSprptoncv(&rc,bc,track_point,&initial_u,&rc1);
/**/        }
/**/       else
/**/        {
/**/         initial_u = me->param;
/**/        }
/**/     
/**/       *msg = AStangent(bc,&ref_mat[4*iz],&initial_u,&par1,point,w);
/**/       if(*msg != MSSUCC)
/**/        { printf("ASkeypoint compute error. Previous solution remains\n");
/**/          return(OM_S_SUCCESS);}
/**/      }
/**/ 
/****************** end of before 1.2 supprt *********/

   else if(me->key == -5)
     {

      if(!itrack)
	{
	 *msg = BScveval(bc,me->param,0,track_point,&rc);

/*^ printf("param %lf\n",me->param);
    pr_point("track",track_point);
*/
        }

      par.leaf_id.objid = NULL_OBJID;
      status = om$send(msg = message GRgraphics.GRptproject(msg,
                                         	&mat_type, matrix,
	                                  	track_point,project,&par),
            	    targetid = go_object.objid,
	            targetos = go_object.osnum);
      as$status(action = RET_STATUS);

/*"go_object %d leaf %d par.u %lf\n",go_object.objid,par.leaf_id.objid,par.u */

      if(IF_NULL_OBJID(par.leaf_id.objid))
        {
         printf("warning keypoint placement, GRptproject returns null_objid\n");
         par.leaf_id = go_object;
        }

      if(iref)
        {
         v_add(track_point,&ref_mat[8],boreline_pt2);
        }
      else
        {
         v_equal(track_point,boreline_pt2);
         boreline_pt2[2] += 1;
        }

      boreline.point1 =  track_point;
      boreline.point2 =  boreline_pt2;
     
     
/*^ pr_point("p1",boreline.point1);
    pr_point("p2",boreline.point2);
*/
      status = om$send(msg = message GRvg.GRkeypoint(msg,&mat_type,matrix,
						  &boreline,point,
						  &par),
            	    targetid = par.leaf_id.objid,
	            targetos = par.leaf_id.osnum);
      as$status(action = RET_STATUS);
/*"param %lf\n",par.u*/

/* Make sure that is the correct key point when tehr is no coordinate system */

 if(!iref)
  {
   double point_bis[3],w[3];
   double len,len_bis;
   struct GRparms par_bis;
   boreline_pt2[2] -=  1;
   boreline_pt2[1] +=  1;
     
/*^ pr_point("p1",boreline.point1);
    pr_point("p2",boreline.point2);
*/
   status = om$send(msg = message GRvg.GRkeypoint(msg,&mat_type,matrix,
						  &boreline,point_bis,
						  &par_bis),
            	    targetid = par.leaf_id.objid,
	            targetos = par.leaf_id.osnum);

/*^ pr_point("point",point);
    pr_point("point_bis",point_bis);
*/
   v_sub(point,track_point,w);
   len= v_len(w); 

   v_sub(point_bis,track_point,w);
   len_bis = v_len(w); 

   if(len>len_bis)
    {v_equal(point_bis,point);
     par = par_bis;
    }
  }
 
 }
		    


/*
   project in xy of referential id defined parent
*/

 if(iref)
   ASproject_in_xy(ref_mat,AS_IN_COL,point,point);


 polyline.num_points = 1;
 polyline.points = point;
 post_info.construct_flag = FALSE;

 status = om$send(msg=message GRlinear.GRputpolyline(msg,md_env,
					  &post_info,&polyline, &newobjid),
		  p_chanselect = &AS_to_comp );
 as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
}    /* end of compute_nod method */

/*
   GRxform override. Allow the user to change the barycentric coordinate
*/


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  struct ret_struct my_def;
  IGRlong msg;
  IGRint status;

  /* Get the name of this object */

  as$printer_set_name(prefix="KEY_PT",
		      name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and Symbology */

  as$printer_print_parents(count=&count);
  as$printer_print_symb();

  /* Print my position */

  status = om$send(msg =message NDnode.NDgive_structure(&msg,&my_def,md_env),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  fprintf(stream,"ptr[0]=%lf;ptr[1]=%lf;ptr[2]=%lf;\n",
	    my_def.var.point_st.pt[0],my_def.var.point_st.pt[1],
            my_def.var.point_st.pt[2]);

  /* Print the message */

  fprintf(stream,"send ASkeypt.place(%d,list,ptr) to %s;\n\n",count,name);
  return(OM_S_SUCCESS);
}/* end print */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
    {
     *msg = MSSUCC;
     ex$message(buff=info->type,msgnumb=AS_I_KeyPt);
     return(OM_S_SUCCESS);
    }



method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
IGRint i, j;
IGRlong status;
 
 *nb_tot = 3;
 if( ifrom < 0 ) ifrom = 0;
 if( ito  < ifrom ) { *nb_return = 0; return(OM_S_SUCCESS); }
 if( ito  > *nb_tot - 1 ) ito = *nb_tot - 1;
 *nb_return = ito - ifrom + 1;
 
 for( i = ifrom, j = 0; i <= ito ; i++, j++ )
 {
  switch( i )
  {
   case 0 : 
     geom_code[j]=line_generic | conic_generic | point_generic | curve_generic;
     option_code[j] = 1;
     break;

   case 1 :
     geom_code[j]   = point_generic | ref_generic;
     option_code[j] =  2;/* optional track_point or plan */
     break;

   case 2 :
     geom_code[j]   = point_generic | ref_generic;
     option_code[j] =  2;/* optional track_point or plan */
     break;

  } /*  end switch  */
 }

 /*  track point or ref ? */
   
 *index_ref   = -1;  /* no ref.        */
 *index_track = -1;  /* no track point */
 *index_plan  = -1;  /* no plan        */

 /*| look for the index of the optional root */

 status = om$send( msg = message ASnode.ASget_opt_ind
					(1, index_track, index_ref, index_plan),
	           targetid = my_id );
 return(OM_S_SUCCESS);
}
end implementation ASkeypt;
