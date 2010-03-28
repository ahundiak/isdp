class implementation ASkeyseg;

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

extern GRclassid OPP_GR3dlineseg_class_id;


/* compute the key segment */


AScompute_key_seg(msg,tol,bc,initial_u,project,nearest_p,other_p)
IGRlong *msg;            /* completion code   */
IGRdouble tol,	         /* tolerance         */
          initial_u;     /* initial parameter */
struct IGRbsp_curve *bc; /* curve definition */
IGRdouble *project,      /* initial point     */
          *nearest_p,    /* nearest vertex    */
           *other_p;     /* other vertex to make seg */

/*.compute_key_seg*/
{
  IGRdouble dmin;
  IGRdouble nearest_u;
  IGRint i,iv,other,incr;
  IGRint rc;
  IGRboolean rc1,found;
  

/*
   find nearest vertex 
*/

   dmin = 1.e+36;
   ASfind_nearest_vertex(bc,ANGL_VER|ONCV_VER,dmin,tol,project,nearest_p,
			 &iv,&dmin);
   if(dmin > 0.5e+36){ /*| nearest vertex fail */ return(OM_W_ABORT); }
   else              { /*" nearest is %d\n",iv*/ }

/* 
   find other vertex to create the segment
*/

   *msg = BSprptoncv(&rc,bc,&bc->poles[3*iv],&nearest_u,&rc1);
   /*"nearest_u %le\n",nearest_u */

   if(bc->phy_closed && (nearest_u < 1.e-8 || nearest_u > (1-1.e-8)) )
     { if( initial_u> 0.5 ) nearest_u = 1;
       else 		    nearest_u = 0;
     }

   if(initial_u < nearest_u) incr = -1;
   else 		     incr =  1;
   

   other = iv;
   found = FALSE;

   for (i=0;i<bc->num_poles-1;i++)
     {
      /*" check if there is an angle on %d\n",other */
      if(ASadjust_i(other+incr,&other,bc))
	{
         if(ASangle_on_vertex(bc,other)) {found = TRUE; break;}
	}
       else
	{
	 other = other - incr;
	 found = TRUE;
	 break;
	}
      }

   if(!found) {/*|angle on other vertex fail */ return(OM_W_ABORT);}

   ASvertex_position(bc,other,other_p);
   return(OM_S_SUCCESS);
  }



method NDplace( struct GRas *asso_lis;struct GRmd_env *md_env;
		IGRchar *go_cnst_lis )
{
  struct GRid *parent,go_object;
  OMuint count;
  IGRpoint track_point,project;
  double *nearest_p,*other_p;
  IGRdouble point_coor[6];
  IGRlong msg,status,rc,rc1;
  struct IGRbsp_curve *bc;
  IGRchar *ptr;
  IGRdouble *snap;
  IGRmatrix matrix,ref_mat;
  IGRshort mat_type;
  IGRdouble tol;
  struct ret_struct objdef,optdef;
  struct GRparms par;
  IGRint iroot,iref,itrack;

/* 
  control arguments
*/

  count = asso_lis->num_parents;
  parent = asso_lis->parents;
  if(count < 1 || count >3) return(OM_W_ABORT);

/*
   basic tolerance
*/
  BSEXTRACTPAR(&rc,BSTOLCHRDHT,tol);

/*
   get parent def other than support
   after initialization of default value
*/

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
      AStrans_mat(optdef.var.ref_st.t,ref_mat);
      if(iref) return(OM_W_ABORT);
      iref = 1;
     }
   else if(optdef.type&point_generic)
     {
      /*| There is a track point */
      v_equal(optdef.var.point_st.pt,track_point);
      if(itrack) return(OM_W_ABORT);
      itrack = 1;
     }
  }
  
/*
   When track point, compute from trackpoint
   when the graphic object already exist compute the key segment from it
   When it doesn't exist compute from snap point.
*/
 if(itrack)
  {
   /*| compute from track */
   snap = track_point;
  }
 else if( !(IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID )))
  {
   IGRdouble half = 0.5;
   /*| compute from graphic obj */
   status = as$any_give_structure(go_grid = asso_lis->go_objid,
				  mod_env = md_env,
                      		  inst =  &objdef );
   as$status(action = RET_STATUS);
   v_comb(half,objdef.var.line_st.p0,half,objdef.var.line_st.p1,track_point);
   snap = track_point;
  }
 else
  {
   /*| compute from snap */
   snap = (IGRdouble *) asso_lis->as_attr;
  }

/*^ pr_point("snap",snap); */



/* get geometry of support. project snap point on the curve */

    status = om$send(msg = message NDnode.ASreturn_go(&go_object,
						 &mat_type,matrix),
           	     targetid = parent[0].objid ,
           	     targetos = parent[0].osnum );
    if(!(status&1))
      {go_object = parent[0];
       mat_type = MAIDMX;
       MAidmx(&msg,matrix);
      }

/* project point on the curve */

    status = om$send(msg = message GRgraphics.GRptproject(&msg,
                                         		&mat_type, matrix,
	                                  		snap,project,&par),
            	    targetid = go_object.objid,
	            targetos = go_object.osnum);
    as$status(action = RET_STATUS);

/*^ pr_point("project",project); */



/* get abstract geometry */

  status = om$send(msg = message GRvg.GRgenabsg(&msg,&mat_type,matrix, &ptr),
		   targetid = go_object.objid, targetos = go_object.osnum);
  as$status(action = RET_STATUS);
  bc = (struct IGRbsp_curve *)ptr;
/*^ ASedit_bsp(*bc); */


   msg = BSprptoncv(&rc,bc,project,&par.u,&rc1);
   me->param = par.u;
   if(rc != BSSUCC)
	   {printf(" ASkeyseg.place can't compute parameter value\n");
	    return(OM_W_ABORT);}
/*"BSprptoncv --> %lf\n",par.u */


/* evaluate key seg */

 nearest_p = point_coor;
 other_p = &point_coor[3];
 status = AScompute_key_seg(&msg,tol,bc,me->param,project,nearest_p,other_p);
 as$status(action = RET_STATUS);


/* project if necessary in oxy plane */

   if(iref)
     {ASproject_in_xy(ref_mat,AS_IN_COL,nearest_p,nearest_p);
      ASproject_in_xy(ref_mat,AS_IN_COL,other_p,other_p);
     }

  if(go_cnst_lis != NULL)
   {
    struct IGRpolyline geom;

    /*| Construct the G.O */
    geom.num_points = 2;
    geom.points     = nearest_p;

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (char *) &geom;

    status = om$send(msg =message ASnode.ASconstruct_go
		   (asso_lis,md_env,go_cnst_lis,OPP_GR3dlineseg_class_id,TRUE),
		   targetid = my_id);
    as$status(action = RET_STATUS);
   }


/*
  we ask the graph manager to add the new ASkeyseg to the graph 
*/
  
  status = om$send(msg = message NDnode.NDconnect(asso_lis->num_parents,
				asso_lis->parents,NULL_GRID,ND_NEW),
		  targetid = my_id);
  as$status(action = RET_STATUS);


  return(OM_S_SUCCESS);

}/* place */

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count;struct GRid list[]; struct GRmd_env *md_env)
{
  IGRlong status,rc;
  IGRpoint project,track_point;
  IGRdouble *nearest_p,*other_p;
  struct GRid go_object;
  IGRchar *ptr;
  struct ret_struct optdef,my_def;
  struct IGRbsp_curve *bc;
  IGRmatrix matrix,ref_mat;
  IGRshort mat_type;
  IGRint iroot,itrack,iref;
  IGRdouble initial_u,tol;
  struct GRparms par;
  IGRboolean rc1;

  if(count<1 || count>3)
  {
    printf("Warning ASkeyseg has a bad parent number --> doesn't recompute \n");
    return(1);
  }

/*
   basic tolerance
*/
  BSEXTRACTPAR(&rc,BSTOLCHRDHT,tol);


/* get parent def other than support */
/* after initialization if not       */



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
      AStrans_mat(optdef.var.ref_st.t,ref_mat);
      if(iref) return(OM_S_SUCCESS);
      iref = 1;
     }
   else if(optdef.type&point_generic)
     {
      /*| There is a track point */
      v_equal(optdef.var.point_st.pt,track_point);
      if(itrack) return(OM_W_ABORT);
      itrack = 1;
     }
  }

/* get geometry of support. */

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
   When track point, compute from trackpoint
   If not compute from the parametric position stored by associative object
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

/*
   get definition of support suppose mod matrix is identity
*/

  status = om$send(msg = message GRvg.GRgenabsg(msg,&mat_type,matrix, &ptr),
		   targetid = go_object.objid, targetos = go_object.osnum);
  as$status(action = RET_STATUS);
  bc = (struct IGRbsp_curve *)ptr;
/*^ ASedit_bsp(*bc); */

  if(itrack)
   {
    *msg = BSprptoncv(&rc,bc,project,&initial_u,&rc1);
   }
  else
   {
    initial_u = me->param;
    *msg = BScveval(bc,initial_u,0,project,&rc);
   }

/* 
   compute the key segment
*/
 nearest_p = my_def.var.line_st.p0;
 other_p = my_def.var.line_st.p1;
 status = AScompute_key_seg(msg,tol,bc,initial_u,project,nearest_p,other_p);

 as$status(action = RET_VALUE, value = OM_S_SUCCESS);


 /*
   project in xy of referential id defined parent
 */

  

 if(iref)
  {
   ASproject_in_xy(ref_mat,AS_IN_COL,nearest_p,nearest_p);
   ASproject_in_xy(ref_mat,AS_IN_COL,other_p,other_p);
  }

/* update the graphic associated object */
 status = om$send(msg = message ASline.ASpostab(msg,md_env,&my_def),
                   targetid =  my_id);
 as$status();
 return(OM_S_SUCCESS);
}    /* end of compute_nod method */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  struct ret_struct my_def;
  IGRint status;
  IGRlong msg;
  IGRpoint snap;
  IGRdouble half = 0.5;

  /* Get the name of this object */

  as$printer_set_name(prefix="KEY_SEG",
		      name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and Symbology */

  as$printer_print_parents(count=&count);
  as$printer_print_symb();

  /* Print my position */

  status = om$send(msg =message NDnode.NDgive_structure(&msg,&my_def,md_env),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  v_comb(half,my_def.var.line_st.p0,half,my_def.var.line_st.p1,snap);
  fprintf(stream,"ptr[0]=%lf;ptr[1]=%lf;ptr[2]=%lf;\n",
	  snap[0],snap[1],snap[2]);

  /* Print the message */

  fprintf(stream,"send ASkeyseg.place(%d,list,ptr) to %s;\n\n",count,name);
  return(OM_S_SUCCESS);
}/* end print */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
    {
     *msg = MSSUCC;
     ex$message(buff=info->type,msgnumb=AS_I_AsKeySeg);
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
     geom_code[j]=line_generic | curve_generic;
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

 status = om$send( msg = message ASnode.ASget_opt_ind
                                        (1, index_track, index_ref, index_plan),
                   targetid = my_id );


 return(OM_S_SUCCESS);
}

end implementation ASkeyseg;
