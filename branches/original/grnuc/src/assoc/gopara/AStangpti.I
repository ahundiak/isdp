class implementation AStangpt;

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

extern GRclassid OPP_GR3dpoint_class_id;


/* -----------------------------------------------------------------
  AStangpt.place
  ----------------------------------------------------------------- */

method NDplace( struct GRas *asso_lis;struct GRmd_env *md_env;
		IGRchar *go_cnst_lis )
{
  struct GRid *parent,go_object;
  int count;
  IGRpoint point,w,w1,project,track_point;
  IGRlong msg,status,rc,rc1;
  IGRint iz;
  struct IGRbsp_curve *bc;
  IGRchar *ptr;
  IGRdouble *snap;
  IGRmatrix matrix,ref_mat;
  IGRshort mat_type;
  IGRdouble par1,dmin,dwork,tol;
  struct ret_struct objdef,optdef;
  struct GRparms par;
  IGRint iroot,iref,itrack;
  IGRdouble *direction;
  IGRint retained_direction = 0;
  double snap_point[16];

/* 
  control arguments
*/

  count = asso_lis->num_parents;
  parent = asso_lis->parents;

/*
   basic tolerance
*/
  BSEXTRACTPAR(&rc,BSTOLCHRDHT,tol);

  if(count < 1 || count >3) return(OM_W_ABORT);
  

/* get parent def other than support */
/* after initialization if not       */

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
   When there is a track point, compute tangent point nearest from track point.
   When the graphic object exists compute the tangent point from graphic object.
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
   if(msg != OM_S_SUCCESS){printf("AStangpt place error abort");return(msg);}
   snap = objdef.var.point_st.pt;
  }
 else
  {
   snap = (IGRdouble *) asso_lis->as_attr;
  }

   /*
    * If there is no associative attribute passed in, then use the snap point
    * and some arbitrary directions.  Since I do not know of a way to get the
    * proper view_rotation matrix here, I have hardwired some nos.
    * Fixes an abort (TR#119415563). - Rajiv Agrawal 01/11/94
    */
   if (!asso_lis->as_attr) 
   {
     double view_rot[6] = {1.,0.,0.,0.,0.,1.};
     
     v_equal (snap, snap_point);
     v_equal (view_rot, &snap_point[3]);
     v_equal (&view_rot[4], &snap_point[6]);
     asso_lis->as_attr = (IGRchar *) snap_point;
   }

/* get goemetry of curve and project point on it  */
/* The order used is important (project,genabsg,prptoncv) */


    status = om$send(msg = message NDnode.ASreturn_go(&go_object,
						 &mat_type,matrix),
           	     targetid = parent[0].objid ,
           	     targetos = parent[0].osnum );
    if(!(status&1))
      {go_object = parent[0];
       mat_type = MAIDMX;
       MAidmx(&msg,matrix);
      }

    status = om$send(msg = message GRgraphics.GRptproject(&msg,
                                         		&mat_type, matrix,
	                                  		snap,project,&par),
            	    targetid = go_object.objid,
	            targetos = go_object.osnum);
    as$status(action = RET_STATUS);


  status = om$send(msg = message GRvg.GRgenabsg(&msg,&mat_type,matrix, &ptr),
		   targetid = go_object.objid, targetos = go_object.osnum);
  as$status(action = RET_STATUS);
  bc = (struct IGRbsp_curve *)ptr;
/*^ ASedit_bsp(*bc); */


   msg = BSprptoncv(&rc,bc,project,&par.u,&rc1);
   me->param = par.u;
   if(rc != BSSUCC)
	   {printf(" AStangpt.place can't compute parameter value\n");
	    return(OM_W_ABORT);}
/*^
   printf("BSprptoncv --> %lf\n",par.u);
   pr_point("projection point",project);
*/

  dmin = 1.e+36;

/* 
   find the nearest tangency point to
   direction defined by the referantial, trying to use same buffer for
   direction and returned_line
*/

    for(iz=0;iz<2;iz++)
       {
 	if(iref)
  	 {
   	  direction =  &ref_mat[4*iz];
  	 }
 	else
  	 {
           direction = (IGRdouble *) asso_lis->as_attr+3*(iz+1); 
  	 }
	 /*^ pr_point("direction",direction); */
	 msg = AStangent(bc,direction,&me->param,&par1,w1,w);
         if(msg == MSSUCC)
           {
	    /*^ pr_point("after tangent",w1); */
	    v_sub(project,w1,w);
            dwork = w[0]*w[0] +  w[1]*w[1] +  w[2]*w[2];
     
            if(dwork<dmin)
             {
              dmin=dwork;
              retained_direction = iz;
              v_equal(w1,point);
             }
           }
       }
if(dmin<5.e+35)
  {
   /*^
   pr_point("after dmin",point);
   */
  }
 else
  {
   printf("tangent failed\n");
   return(OM_W_ABORT);
  }

 if(iref)
  {
   me->dir[0] = retained_direction;
  }
 else
  {
   v_equal((IGRdouble *) asso_lis->as_attr+3*(retained_direction+1),me->dir);
   /*^ pr_point("me->dir",me->dir); */
  }

 /*" AStangpt.place point a creer %lf %lf %lf\n",point[0],point[1],point[2] */

 if(go_cnst_lis != NULL)
  {
    struct IGRpolyline geom;

    /*| Construct the G.O */
    geom.num_points = 1;
    geom.points     = point;

    ((struct GRvg_construct *) go_cnst_lis)->geometry =(char *) &geom;

    status = om$send(msg =message ASnode.ASconstruct_go
		      (asso_lis,md_env,go_cnst_lis,OPP_GR3dpoint_class_id,TRUE),
		   targetid = my_id);
    as$status(action = RET_STATUS);
  }


/*
  we ask the graph manager to add the new AStangpt to the graph 
*/
  
  status = om$send(msg = message NDnode.NDconnect(asso_lis->num_parents,
				asso_lis->parents,NULL_GRID,ND_NEW),
		  targetid = my_id);
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);

}/* place */

/* ----------------------------------------------------------------------
  compute the tangpt point
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
  IGRint iz;
  struct IGRbsp_curve *bc;
  IGRmatrix matrix,ref_mat;
  IGRshort mat_type;
  IGRdouble par1;
  IGRdouble tol;
  IGRdouble initial_u;
  IGRint iroot,itrack,iref;
  struct GRparms par;
  IGRdouble *direction;

  if(count<1 || count>3)
  {
    printf("Warning AStangpt has a bad parent number --> doesn't recompute \n");
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

    BSEXTRACTPAR(&rc,BSTOLCHRDHT,tol);
    status = om$send(msg = message NDnode.ASreturn_go(&go_object,
						        &mat_type,matrix),
           	     targetid = list[0].objid ,
           	     targetos = list[0].osnum );
    if(!(status&1))
      {go_object = list[0];
       mat_type = MAIDMX;
       MAidmx(msg,matrix);
      }

/* 
   if track point porject on support
*/

   if(itrack)
     {
      status = om$send(msg = message GRgraphics.GRptproject(msg,
                                         		&mat_type, matrix,
	                                  	track_point,project,&par),
            	    targetid = go_object.objid,
	            targetos = go_object.osnum);
      as$status(action = RET_STATUS);
     }


  
  status = om$send(msg = message GRvg.GRgenabsg(msg,&mat_type,matrix, &ptr),
		   targetid = go_object.objid, targetos = go_object.osnum);
  as$status(action = RET_STATUS);
   bc = (struct IGRbsp_curve *)ptr;
/*^ ASedit_bsp(*bc); */

/* 
   compute the tangent point
*/

      if(iref)
	{
/*|dir from ref */
         iz = me->dir[0];
	 direction = &ref_mat[4*iz];
	}
      else
	{
/*| dir from instances */
	 direction = me->dir;
	}

      if(itrack)
       {
        *msg = BSprptoncv(&rc,bc,project,&initial_u,&rc1);
       }
      else
       {
        initial_u = me->param;
       }

/*^ 
    pr_point("direction",direction);
*/
    
      *msg = AStangent(bc,direction,&initial_u,&par1,point,w);
      if(*msg != MSSUCC)
        { printf("AStangent compute error. Previous solution will remain\n");
          return(OM_S_SUCCESS);}

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
  OMuint              icount;              /* Index for loop                  */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  struct ret_struct my_def,root_def;
  struct GRid my_root[3];
  IGRlong msg;
  IGRint status,iref;

  /* Get the name of this object */

  as$printer_set_name(prefix="TANG_PT",
		      name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and Symbology */

  as$printer_print_parents(count=&count,
			   list = my_root,
			   size = 3);
  as$printer_print_symb();

  /* Print my position */

  status = om$send(msg =message NDnode.NDgive_structure(&msg,&my_def,md_env),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  fprintf(stream,"ptr[0]=%lf;ptr[1]=%lf;ptr[2]=%lf;\n",
	    my_def.var.point_st.pt[0],my_def.var.point_st.pt[1],
            my_def.var.point_st.pt[2]);


  /* print the axes if no coordinate system as root */

  iref = 0;

  for(icount = 0; icount < count ; icount ++)
    { status = om$send(msg = message NDnode.NDgive_structure
						      (&msg,&root_def,md_env),
		       targetid = my_root[icount].objid,
		       targetos = my_root[icount].osnum);
      if(root_def.type & ref_generic) { iref = 1; break;}
    }

  if(iref == 0)
    {
     fprintf(stream,"ptr[3]=%lf;ptr[4]=%lf;ptr[5]=%lf;\n",
	          me->dir[0],me->dir[1],me->dir[2]);
     fprintf(stream,"ptr[6]=0.;ptr[7]=0.;ptr[8]=0.;\n");
    }

		       

  

  /* Print the message */

  fprintf(stream,"send AStangpt.place(%d,list,ptr) to %s;\n\n",count,name);
  return(OM_S_SUCCESS);
}/* end print */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
     *msg = MSSUCC;
     ex$message(buff=info->type,msgnumb=AS_I_TgtPt);
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
end implementation AStangpt;
