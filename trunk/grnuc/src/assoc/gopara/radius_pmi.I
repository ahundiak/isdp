class implementation radius_pm;

#include <stdio.h>
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expression.h"
#include "ASmatrix.h"
#include "OMminimum.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "madef.h"

#include "gocmacros.h"

#define AS_DEBUG

struct expr_attr
  {
   IGRchar name[EXP_MAX_LEN];
   IGRchar syntax[EXP_MAX_LEN];
   IGRdouble value;
  };
   
double fabs ();

/*
   This function is used by the radius pm
   and by the point at center 
*/
   

int ASeval_radius(
  IGRint  count,            /* number of parents   */
  struct  GRid *list,       /* GRid of the parents */
  double *radius,           /* returned radius     */
  double *center,           /* point at center     */
  struct  GRmd_env *md_env) /* obsolete argument   */

/*.ASeval_radius */
{
  IGRchar 		*ptr;
  IGRlong 		msg,status;
  struct ret_struct 	rst;
  struct IGRbsp_curve 	*bc,bc_conic;

  IGRint		rc,iroot,iref,ipoint;  
  IGRpoint 		point,pointbis,dummy_pt,pt_on_curve,
			right_cent,left_cent;
  IGRdouble 		right_curv,left_curv,right_rad,left_rad,tol;
  IGRboolean 		boundary;
  struct GRid 		go_object;
  struct GRparms	par;
  IGRmatrix 		ref_mat,matrix;
  IGRshort		mat_type;

  IGRpoint 		conic_points[BSCIRCLE_NUM_POLES_MAX]; 
  IGRdouble 		conic_knots[BSCIRCLE_NUM_KNOTS_MAX];
  IGRdouble 		conic_weights[BSCIRCLE_NUM_POLES_MAX];
  IGRdouble *p1,*p2,*p3;
  IGRint iv;
  IGRdouble d,dummy_p;
  struct IGRline view_line;


  /* return the center of the circle if the curve is a circle without a ref.
     as parent */


  if( count < 3 )
  {
   status=om$send(msg      =  message NDnode.NDgive_structure
                                     (&msg, &rst, md_env),
	          senderid = NULL_OBJID,
		  targetid = list[0].objid,
		  targetos = list[0].osnum);
   as$status(action = RET_STATUS);
   if( rst.type & conic_generic )
     {
      *radius = rst.var.circle_st.rad;
      v_equal(rst.var.circle_st.cent_p,center);
      return(OM_S_SUCCESS);
     }
  }

/*
   Get geometry of the point where the center of curvature has to be evaluated
   and if defined the projection plane
*/  

  iref = 0; 
  ipoint = 0;
  for(iroot = 1;iroot < count; iroot++)
  {
    status = om$send(msg      = message NDnode.NDgive_structure
                                        (&msg,&rst,md_env),
                     senderid = NULL_OBJID,
                     targetid = list[iroot].objid,
                     targetos = list[iroot].osnum);
    as$status(action = RET_STATUS);
    if( rst.type & ref_generic )
    {
      /*| There is a coor. syst. as root */
      if(iref) return(OM_W_ABORT);
      iref = 1;
      AStrans_mat(rst.var.ref_st.t , ref_mat);
    }
    else if(rst.type & point_generic)
    {
      /*| There is a point */
      if(ipoint) return(OM_W_ABORT);
      ipoint = 1;
      v_equal(rst.var.point_st.pt,point);
    }
    else return(OM_W_ABORT);
  }

  /*"iref = %d ipoint = %d\n", iref, ipoint */

  if( !ipoint ) return(OM_W_ABORT);


  /* get definition of support */

  status = om$send(msg      = message NDnode.ASreturn_go
                                     (&go_object,&mat_type,matrix),
	           senderid = NULL_OBJID,
           	   targetid = list[0].objid ,
           	   targetos = list[0].osnum );

  if( !( status & 1 ) )
  {
    go_object = list[0];
    mat_type = MAIDMX;
    MAidmx(&msg,matrix);
  }

  /*" curve is %d %d\n",go_object.objid,go_object.osnum */

  /* project point on the support (or ln project if plane as parent) */

  par.leaf_id.objid = NULL_OBJID;
  if(iref)
    {
     view_line.point1 = point;
     view_line.point2 = pointbis;
     v_add(point,&ref_mat[8],pointbis);

     status = om$send(msg = message GRgraphics.GRlnproject
                                 (&msg,&mat_type,matrix,&view_line,
				  dummy_pt,pt_on_curve,&dummy_p,&par),
		senderid = NULL_OBJID,
                targetid = go_object.objid,
	        targetos = go_object.osnum);
    }
  else
    {
     status = om$send(msg = message GRgraphics.GRptproject
                                 (&msg,&mat_type,matrix,point,pt_on_curve,&par),
		senderid = NULL_OBJID,
                targetid = go_object.objid,
	        targetos = go_object.osnum);
    }
  as$status(action = RET_STATUS);


  /* use the leaf_id */
  if(IF_NULL_OBJID(par.leaf_id.objid))
  {
    /*  printf("WARNING GRptproject does not return leaf_id\n");  */
    par.leaf_id = go_object;
  }

  status=om$send(msg      =  message GRvg.GRgenabsg
                                     (&msg,&mat_type,matrix, &ptr),
	         senderid = NULL_OBJID,
		 targetid = par.leaf_id.objid,
		 targetos = par.leaf_id.osnum);
  as$status(action = RET_STATUS);

 
  bc = (struct IGRbsp_curve *)ptr;


  /* do I need to conver order 2 to order 3 */

   if(bc->order == 2)
   {
     BSEXTRACTPAR(&rc,BSTOLCHRDHT,tol);

     bc_conic.poles = (IGRdouble *)conic_points;
     bc_conic.knots = conic_knots;
     bc_conic.weights = conic_weights;

/*^ ASedit_bsp(*bc); */
     
     BSarcofpts(bc,pt_on_curve,tol,&bc_conic,&rc);

     if(rc != BSSUCC && bc->num_poles >=3)
      {
       /*| call nearest vertex */
       ASfind_nearest_vertex(bc,0,1.e+36,1.e+36,pt_on_curve,point,&iv,&d);

       /*"iv %d\n",iv */
       if(d<1.e+36)
         {
          p1 = bc->poles+3*iv;
          if(iv>0) { p2 = bc->poles+3*iv-3; /*|iv-1 */ }
              else { p2 = bc->poles+3*iv+6; /*|iv+2 */ }

          if(iv<bc->num_poles-1) { p3 = bc->poles+3*iv+3; /*|iv+1 */ }
              else { p3 = bc->poles+3*iv-6; /*|iv-2 */ }

          BScirc3pts(&rc,p1,p2,p3,&bc_conic);
         }
      }

     if(rc != BSSUCC)
     {
       /*| BSarcofpts fails */
       return(OM_W_ABORT);
     }
     else
     {
      /* Not necessary to compute the real parameter because circle.
         .5 will be ok */

       bc = &bc_conic;
       par.u = 0.5;
     }
   }

  /*
     If coordinate system project the curve onto plane 
  */

  if(iref)
  {
    BSprj_cv_pl(&rc,bc,&ref_mat[12],&ref_mat[8],&ref_mat[8],bc);
  }

   /* compute corresponding  radius of curvature and center point */

   BSrdcencrcv(&msg,bc,&par.u,&boundary,&right_curv,&left_curv,&right_rad,
               &left_rad,right_cent,left_cent);

   if(msg == BSSUCC)
   {
     /*"curve rad %lf\n",right_rad */
     *radius = right_rad;
     v_equal(right_cent,center);
     return(OM_S_SUCCESS);
   }
   else
   {
     /*| BSrdcencrcv fails */
     return(OM_W_ABORT);
   }
}


/*---------------------------------------------------------------------------*/
method NDcompute_node(IGRlong *msg;IGRint cn_type;
		      int count ; struct GRid parent[] ;
		      struct GRmd_env *md_env)
{
  int  		len1, len2;
  double      	value;
  char       	pm[EXP_MAX_LEN+1];
  IGRint 	st;
  double    point[3];
  double fabs();

  if(ASeval_radius(count, parent, &value, point, md_env ) != OM_S_SUCCESS)
    {
     printf("Warning, fail to evaluate radius parameter\n");
     return(OM_S_SUCCESS);
    }

  if(fabs(me->value-value) > 1.e-10)
   {
    /*| update value */
    sprintf(pm,"%-10.2lf", value);
    len1 = strlen( pm );
    len2 = strlen( me->pretty_print );
    if( len1 != len2 )
    {
      st = OM_SET_DIMENSION( me->pretty_print, (len1 + 1));
    }
    strcpy( me->pretty_print, pm);

    me->value = value;
    *msg = ND_COMP_SUCC;
    GR_NOTIFY_LISTENERS(msg,msg,GR_GEOM_MODIFIED);
   }
  else
   {
    /*| same value */
    *msg = ND_COMP_SAME;
   }

  return( OM_S_SUCCESS ) ;
} /* method compute_node */

/*---------------------------------------------------------------------------*/

method NDplace( struct GRas *asso_lis; struct GRmd_env *md_env; IGRchar *bspline)
{

  IGRdouble value;
  IGRint i;
  struct expr_attr ex_attr;
  struct GRid *parents,*context;
  IGRint status;
  IGRchar *save_ptr;
  double point[3];

  me->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  /* control arguments */
  if (   asso_lis->num_parents != 1 && asso_lis->num_parents != 2
      && asso_lis->num_parents != 3) return(OM_E_ABORT);

 /*| create the associative image of parents in sub class of source if needed */

   parents = asso_lis->parents;
   context = asso_lis->context;

  /*"nb of parents = %d\n", asso_lis->num_parents */

  /*^

   for(i=0;i<asso_lis->num_parents;i++)
   {
     printf(" objid%d= %d\n", i, parents[i].objid );
     if( context != NULL ) printf(" contextid%d= %d\n", i, context[i].objid );
   }

  */

  for(i=0 ; i<asso_lis->num_parents ; i++)
  {
    /*| dans la boucle for pour creer les sources */

    if(context != NULL)
      {
       status = as$make_source(go_grid = parents[i],
			       context_grid = context[i],
			       as_grid = &parents[i]);
       as$status(action = RET_STATUS);
      }
    else
      {
       status = as$make_source(go_grid = parents[i],
			       as_grid = &parents[i]);
       as$status(action = RET_STATUS);
      }
  }

  /*| compute the value of the radius_pm */
  if((ASeval_radius(asso_lis->num_parents,asso_lis->parents,
		      &value, point, md_env )) != OM_S_SUCCESS) 
    return(OM_E_ABORT);

/*" value %lf\n",value */

  /*| now expression.place */
  ex_attr.value = value;
  ex_attr.syntax[0] = 0;
  if(asso_lis->as_attr != NULL) strcpy(ex_attr.name,asso_lis->as_attr);
  else ex_attr.name[0] = 0;
  save_ptr = asso_lis->as_attr;
  asso_lis->as_attr = (IGRchar *) &ex_attr;

  status=om$send(msg = message expression.NDplace(asso_lis,md_env,bspline),
   		 mode = OM_e_wrt_message,
		 targetid = my_id);
  asso_lis->as_attr = save_ptr;
  as$status(action = RET_STATUS);

  /*| perform the add_node */
    status=om$send(msg = message NDnode.NDconnect
		  (asso_lis->num_parents,asso_lis->parents,NULL_GRID,ND_NEW),
		   targetid = my_id);
    as$status(action = RET_STATUS);
  return(OM_S_SUCCESS);
}


method NDmove_to_root (IGRlong *msg; struct GRid *src_grid;
                       struct GRmd_env *md_env )
  {
   IGRlong status;

   status = om$change_class(objid = my_id, classname = "expression",
                            sd_override = OM_K_change_class_sd_override );
   as$status(action = RET_STATUS);

   status = om$send(msg = message NDnode.NDdisconnect(0,NULL),
                    targetid = my_id);
   as$status(action = RET_STATUS);

   return( OM_S_SUCCESS ) ;
  }



/*---------------------------------------------------------------------------*/
#define MAX_CHAR 80
method NDprint(struct GRmd_env *md_env;FILE *stream)
{
  OMuint              count;               /* Number of parents               */
  char                my_name[EXP_MAX_LEN];/* Name of the expression          */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  struct GRid         my_grid;

  /* Get the name of this object */

  as$printer_set_name(prefix="RADIUS_PM",
		      name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents */
  as$printer_print_parents(count=&count);

  /* Print the message */

   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;
   asprinter_get_di_name(my_grid,my_name);


  as$printer_print_dir(dir_name=my_name);

  fprintf(stream,"send radius_pm.place(%d,list,\"%s\") to %s;\n\n",count,
    my_name, name);
  return(OM_S_SUCCESS);
}

end implementation radius_pm;
