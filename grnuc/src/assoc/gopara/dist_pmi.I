class implementation dist_pm;



#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expression.h"
#include "ASmatrix.h"
#include "nddef.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"

#include "gocmacros.h"

#define AS_DEBUG

#define EPSILON 0.00000000000000000001	/* something very tiny */
/* #define DEBUG    off */

struct expr_attr
  {
   IGRchar name[EXP_MAX_LEN];
   IGRchar syntax[EXP_MAX_LEN];
   IGRdouble value;
  };
   



double dsqr ( double x )
/* just to take the square of x */
{
  return ( x * x );
}




double fabs ();

double give_points_distance ( p1, p2 )
                              struct ret_struct p1, p2;
/* this function computes and returns the euclidian distance between
   p1 and p2 */
/*.give_point_distance*/
{
  double dist;


  dist = dsqr (p1.var.point_st.pt[0] - p2.var.point_st.pt[0]) +
         dsqr (p1.var.point_st.pt[1] - p2.var.point_st.pt[1]) +
         dsqr (p1.var.point_st.pt[2] - p2.var.point_st.pt[2]);

  if (fabs ( dist ) < EPSILON)
      dist = 0.0;
  else
      {
       /*" avant sqrt dist %lf\n",dist */
        dist = sqrt ( dist );
       /*" apres sqrt dist %lf\n",dist */
      }


  return ( dist );
}



double give_point_line_distance ( p1, l2 )
                                  struct ret_struct p1, l2;
/* this function computes and returns the distance between 
   the point p1 and the line l2 */
{
  double dist, v1, v2, v3;

#define u1 l2.var.line_st.v0[0] 
#define u2 l2.var.line_st.v0[1]
#define u3 l2.var.line_st.v0[2]
#define r1 l2.var.line_st.p0[0] 
#define r2 l2.var.line_st.p0[1]
#define r3 l2.var.line_st.p0[2]
#define q1 p1.var.point_st.pt[0]
#define q2 p1.var.point_st.pt[1]
#define q3 p1.var.point_st.pt[2]


  v1 = q1 - r1; 
  v2 = q2 - r2;
  v3 = q3 - r3;

  dist = dsqr ( u2 * v3 - u3 * v2 ) + dsqr ( u3 * v1 - u1 * v3) +
         dsqr ( u1 * v2 - u2 * v1 );

  if (fabs ( dist ) < EPSILON)
     dist = 0.0;
  else
     dist = sqrt ( dist );

#undef u1
#undef u2
#undef u3
#undef r1
#undef r2
#undef r3
#undef q1
#undef q2
#undef q3

  return ( dist );
}


double give_lines_distance ( l1, l2 )
                             struct ret_struct l1, l2;
/* this function computes the euclidian distance between the
   lines l1 and l2 */
{
  double norme, dist, c1, c2, c3;

#define v1  l1.var.line_st.v0[0]
#define v2  l1.var.line_st.v0[1]
#define v3  l1.var.line_st.v0[2]
#define u1  l2.var.line_st.v0[0]
#define u2  l2.var.line_st.v0[1]
#define u3  l2.var.line_st.v0[2]
#define pp1  l1.var.point_st.pt[0]
#define pp2  l1.var.point_st.pt[1]
#define pp3  l1.var.point_st.pt[2]
#define q1  l2.var.point_st.pt[0] 
#define q2  l2.var.point_st.pt[1]
#define q3  l2.var.point_st.pt[2] 


  /* first check if the lines are not parallel */
  c1 = u2 * v3 - u3 * v2;
  c2 = u3 * v1 - u1 * v3;
  c3 = u1 * v2 - u2 * v1;

  norme = dsqr ( c1 ) + dsqr ( c2 ) + dsqr ( c3 );

  if (fabs ( norme ) < EPSILON)
  {
    l1.type = point_generic;
    v_equal(l1.var.line_st.p0,l1.var.point_st.pt);
    dist = give_point_line_distance ( l1, l2 );
  }
  else
     /* check if the lines intersect */
     if (line_prox_line ( l1.var.line_st.p0, l1.var.line_st.p1,
                          l2.var.line_st.p0, l2.var.line_st.p1,
                          &dist, &dist ))
        dist = 0.0;
     else
        /* compute the distance */
        dist = (c1 * (q1 - pp1) + c2 * (q2 - pp2) + c3 * (q3 - pp3)) / norme;

#undef u1
#undef u2
#undef u3
#undef v1
#undef v2
#undef v3
#undef pp1
#undef pp2
#undef pp3
#undef q1
#undef q2
#undef q3

  return ( dist );
}



int give_distance (
  struct GRid id1,
  struct GRid id2,
  double *ptr_dist,
	struct GRmd_env *md_env)
/* this function computes the distance between the objects id1 & id2 */
/*.give_distance */
{
  struct ret_struct rst1, rst2;
  int typ1, typ2, return_status = 1;
  IGRlong msg,status;


  /* the allowed classes are : point_generic
                               line_generic
  */

/*"id1 %d %d id2 %d %d\n",id1.objid,id1.osnum,id2.objid,id2.osnum */

  status = om$send( msg = message NDnode.NDgive_structure (&msg, &rst1,md_env ),
		    senderid = NULL_OBJID,
		    targetid = id1.objid,
		    targetos = id1.osnum);
  as$status(action = RET_STATUS);

  typ1 = rst1.type;

/*"typ1 %d\n",typ1 */

  status = om$send( msg = message NDnode.NDgive_structure (&msg, &rst2,md_env ),
		    senderid = NULL_OBJID,
		    targetid = id2.objid,
		    targetos = id2.osnum);
  as$status(action = RET_STATUS);

  typ2 = rst2.type;

/*"typ2 %d\n",typ2 */

     if (typ1 & point_generic)
      {
        if (typ2 & point_generic)
            *ptr_dist = give_points_distance ( rst1, rst2 );
        else if (typ2 & line_generic)
            *ptr_dist = give_point_line_distance ( rst1, rst2 );
        else
           return_status = 0;
      }
  else
      {
        if (typ2 & line_generic)
           *ptr_dist = give_lines_distance ( rst1, rst2 );
        else if (typ2 & point_generic)
           *ptr_dist = give_point_line_distance ( rst2, rst1 );
	else
           return_status = 0;
      }



  return ( return_status );
}

/*----------------------------------------------------------------------------*/
method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count; struct GRid parent[]; struct GRmd_env *md_env)

{
         int  len1             , len2 ;
  double      value                      ;
  char        pm[EXP_MAX_LEN+1]          ;
  IGRint st;
  double fabs();

  

/* Evaluate yourself because somebody you depended upon has been modified...
   ---------------------------------------------------------------------------*/


  if (count != 2) return(0);
  st = give_distance ( parent[0], parent[1], &value, md_env );
  if (st    != 1) return(0);


  if(fabs(me->value-value) > 1.e-10)
   {
    /*| update value */
    sprintf(pm,"%-10.2lf",value);
    len1 = strlen( pm );
    len2 = strlen( me->pretty_print )   ;
    if( len1 != len2 )
    {
     st = OM_SET_DIMENSION( me->pretty_print, (len1 + 1)) ;
    }

    strcpy( me->pretty_print, pm ) ;

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


method NDplace(struct GRas *asso_lis; struct GRmd_env *md_env;
	       IGRchar *go_cnst_lis)
{

  IGRdouble value;
  IGRint st,i;
  struct expr_attr ex_attr;
  struct GRid *parent,*context;
  IGRlong status;
  IGRchar *save_ptr;

  me->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

/* control arguments */

  if (asso_lis->num_parents != 2) return(OM_W_ABORT);

/*^
   printf("md_id %d %d\n",md_env->md_id.objid,md_env->md_id.osnum);
   printf("matrix_type %d \n",md_env->md_env.matrix_type);
*/


/* create the associative image of parents in sub class of source if needed */

	parent  = asso_lis->parents;
        context = asso_lis->context;
	for(i=0 ; i<asso_lis->num_parents ; i++)
	 {
          if(context != NULL)
            {
             status = as$make_source(go_grid = parent[i],
			             context_grid = context[i],
			             as_grid = &parent[i]);
             as$status(action = RET_STATUS);
            }
          else
            {
             status = as$make_source(go_grid = parent[i],
			             as_grid = &parent[i]);
             as$status(action = RET_STATUS);
            }
	 }

/* compute the value of the dist_pm */

  st = give_distance ( asso_lis->parents[0], asso_lis->parents[1],
		       &value, md_env );
  if (st    != 1) return(0);

/*"value : %lf\n",value */

/*| now expression.place */


  ex_attr.value = value;
  ex_attr.syntax[0] = 0;
  if( asso_lis->as_attr != NULL) strcpy(ex_attr.name,asso_lis->as_attr);
  else ex_attr.name[0] = 0;
  save_ptr = asso_lis->as_attr;
  asso_lis->as_attr = (IGRchar *) &ex_attr;

  status=om$send(msg =message expression.NDplace(asso_lis,md_env,go_cnst_lis),
		 mode = OM_e_wrt_message,
                 targetid = my_id);
 asso_lis->as_attr = save_ptr;
  as$status(action = RET_STATUS);


/* perform the add_node */

  status=om$send(msg =  message NDnode.NDconnect
				(asso_lis->num_parents,asso_lis->parents,
				 NULL_GRID,ND_NEW),
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
   return OM_S_SUCCESS;
  }

 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  char                my_name[EXP_MAX_LEN];/* Name of the expression          */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  struct GRid my_grid;

  /* Get the name of this object */

  as$printer_set_name(prefix="DIST_PM",
		      name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents */
  as$printer_print_parents(count=&count);

  /* Print the message */
   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;
   asprinter_get_di_name(my_grid,my_name);
  fprintf(stream,"send dist_pm.place(%d,list,\"%s\") to %s;\n\n",count,
    my_name, name);
  return(1);
}/* end print */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


end implementation dist_pm;
