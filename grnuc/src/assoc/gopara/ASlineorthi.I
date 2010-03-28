class implementation ASlineorth;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "ASmsg.h"
#include "msmacros.h"

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int ortho_line __((struct ret_struct *rootdef, IGRint num, 
                          struct GRid *root_grid, IGRdouble *unit_vect));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



#define EPSILON 1.0e-10
#define AS_DEBUG

extern GRclassid OPP_GR3dlineseg_class_id;

 
/* compute the unitar vector of the  ortho line. Be carreful, this vector
   will not be compute if impossible. Default value must be given by the 
   caller
*/

 static ortho_line(rootdef, num, root_grid, unit_vect)
 struct ret_struct  *rootdef;         /* definition of roots                 */
 IGRint num;                          /* number of roots		     */
 struct GRid *root_grid;	      /* grid of roots			     */
 IGRdouble *unit_vect;		      /* unitar vector of ortho_line	     */
 /*.ortho_line*/
 {
  double w1[3],w2[3],d;
  IGRint success = 0;
  IGRint status;
  IGRlong msg;
  struct IGRplane plane;
  struct GRid go_grid;
  IGRshort go_mat_type;
  IGRmatrix go_mat;


   switch (num)
    {
     case 2 :
      if(rootdef[1].type & ref_generic)
       {
        /*| line parallel to vz of the c.s. */
        unit_vect[0] = rootdef[1].var.ref_st.t[2];
        unit_vect[1] = rootdef[1].var.ref_st.t[6];
        unit_vect[2] = rootdef[1].var.ref_st.t[10];
	success = 1;
       }
      else
       {
	status = om$send(msg = message NDnode.ASreturn_go
						(&go_grid,&go_mat_type,go_mat),
			 senderid = NULL_OBJID,
			 targetid = root_grid[1].objid,
			 targetos = root_grid[1].osnum);
        as$status(action = RET_STATUS);
	
        plane.point  = w1;
        plane.normal = w2;
	status = om$send(msg = message GRvg.GRdetplane
					(&msg,&go_mat_type,go_mat,&plane),
			 senderid = NULL_OBJID,
			 targetid = go_grid.objid,
			 targetos = go_grid.osnum);
        as$status(action = RET_STATUS);

	if(msg == MSSUCC)
         {
          /*| line normal to the curve */  
	  v_equal(plane.normal,unit_vect);
	  success = 1;
         }
	else
	 {
	  printf("the curve is not planar\n");
	 }
						
       }
      break;

    case 3:
        
     /*| the plane is defined by the three points */ 
     if(rootdef[1].type & point_generic && rootdef[2].type & point_generic) 
	{
         v_sub(rootdef[1].var.point_st.pt,rootdef[0].var.point_st.pt,w1);
         v_sub(rootdef[2].var.point_st.pt,rootdef[0].var.point_st.pt,w2);
         v_cross(w1,w2,w2);
         d=v_len(w2);
         if(d !=0){ d=1./d; v_scale(w2,d,unit_vect);}
	 success = 1;
	}
    }


    if( success == 0)
    {
     printf("ASlineortho case not implemented: %d\n", num );
     return(OM_W_ABORT);
    }

 /*"ortho_line unit_vect %lf %lf %lf\n",unit_vect[0],unit_vect[1],unit_vect[2]*/
  return(OM_S_SUCCESS);
 }
   
/*
  ASlineorth.NDplace
  Non interactive placement of a ASlineorth
*/

method NDplace(struct GRas *asso_lis;struct GRmd_env *md_env;
	       IGRchar *go_cnst_lis)
 {
  
  IGRdouble *snap = NULL;
  struct ret_struct  linedef, rootdef[3];

  IGRint i;
  IGRdouble one=1,k1,k2;
  IGRpoint w;
  IGRlong msg,status;
  IGRdouble xx;
  IGRdouble fabs(), BSdistptpt();

  /*"num_parents = %d",asso_lis->num_parents*/

  /* control arguments number */
  if(asso_lis->num_parents != 2 && asso_lis->num_parents != 3) return(OM_W_ABORT); 


  /* root definition */
 
  for(i=0 ; i<asso_lis->num_parents ; i++)
   {
    status=om$send(msg=message NDnode.NDgive_structure
						 (&msg,&rootdef[i],md_env) ,
            targetid = asso_lis->parents[i].objid,
            targetos = asso_lis->parents[i].osnum );
    as$status(action = RET_STATUS);
   }

  if(!(rootdef[0].type & point_generic))
   { 
    /*|ASlineortho  origine wrong type */
    return(OM_W_ABORT);
   }


/*
   placement point : This point can be the placement point define by the user
   or a point on the already existing graphic object when this object is 
   transform to ortholine (transform to assoc)
*/

    
  if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
     {
      snap = (IGRdouble *) asso_lis->as_attr;
      linedef.var.line_st.v0[0] = 1;
      linedef.var.line_st.v0[1] = 0;
      linedef.var.line_st.v0[2] = 0;
      v_equal(snap,linedef.var.line_st.p1);
      k1 = -1; k2 = 2;
      v_comb(k1,snap,k2,rootdef[0].var.point_st.pt,linedef.var.line_st.p0);
     }
  else
     {
      status = as$any_give_structure( go_grid = asso_lis->go_objid,
                         	      mod_env = md_env,
				      inst    = &linedef );
      as$status(action = RET_STATUS);
     }

  /* compute now the ortho line */

  status = ortho_line( rootdef, asso_lis->num_parents, asso_lis->parents, 
		       linedef.var.line_st.v0);
  if(!status) return (OM_W_ABORT);

  /* compute p0,p1 and extend */

  v_sub(linedef.var.line_st.p0,rootdef[0].var.point_st.pt,w);
  xx = v_dot(w,linedef.var.line_st.v0);
  if(fabs(xx) < EPSILON && IF_NULL_OBJID(asso_lis->go_objid.objid))
   {
     double dist;

     /*| take the distance between the snap point and the ref point */
     dist = BSdistptpt(&msg,snap,rootdef[0].var.point_st.pt);
     if(fabs(dist) > fabs(xx)) xx = dist;
   }
  ME.ASline->d0 = -xx;
  v_comb(one,rootdef[0].var.point_st.pt,xx,linedef.var.line_st.v0,
        linedef.var.line_st.p0);

  v_sub(linedef.var.line_st.p1,rootdef[0].var.point_st.pt,w);
  ME.ASline->d1 = v_dot(w,linedef.var.line_st.v0);
  if(fabs(ME.ASline->d1) < EPSILON && IF_NULL_OBJID(asso_lis->go_objid.objid))
   {
     if( fabs(ME.ASline->d0) > fabs(ME.ASline->d1)) ME.ASline->d1 = ME.ASline->d0;
   }
  v_comb(one,rootdef[0].var.point_st.pt,ME.ASline->d1,linedef.var.line_st.v0,
        linedef.var.line_st.p1);

  /*"d0: %lf, d1: %lf\n",ME.ASline->d0, ME.ASline->d1*/
  /*------------------------------------------------------------------
  conversion to the b_spline format for the go associated object
  and construct the graphic object
  --------------------------------------------------------------------*/

  if(go_cnst_lis != NULL)
   {
    struct IGRpolyline geom;
    IGRdouble pt_geom[6];

    /*| Construct the G.O */
    geom.num_points = 2;
    geom.points     = pt_geom;
    for(i=0;i<3;i++)
     {
      pt_geom[i]   = linedef.var.line_st.p0[i];
      pt_geom[i+3] = linedef.var.line_st.p1[i];
     }

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (char *) &geom;

    status=om$send(msg=message ASnode.ASconstruct_go
		    (asso_lis,md_env,go_cnst_lis,OPP_GR3dlineseg_class_id,TRUE),
             	   targetid = my_id );
    as$status(action = RET_STATUS);
  }


/*
    add in NDnode tree
*/

    status = om$send
               (msg     = message NDnode.NDconnect(asso_lis->num_parents,
                                                   asso_lis->parents,
                                                   NULL_GRID,ND_NEW),
                targetid = my_id);
    as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
 }/* NDplace */


/*
  compute_node

    compute an ortho line

*/

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count;struct GRid list[];struct GRmd_env *md_env)

{
  struct ret_struct  rootdef[3],linedef;
  IGRint i,status ;


  if( count!= 2 && count != 3) return(OM_S_SUCCESS); 

  /* my previous def was */
  status = om$send( msg = message NDnode.NDgive_structure(msg,&linedef,md_env),
            	    targetid = my_id );
  as$status(action = RET_STATUS);


  /* root definition */

  for(i=0 ; i<count ; i++)
   {
    status=om$send(msg=message NDnode.NDgive_structure
						     (msg,&rootdef[i],md_env),
                   targetid = list[i].objid,
                   targetos = list[i].osnum);
    as$status(action = RET_STATUS);
   }

  if(!(rootdef[0].type&point_generic))
         {printf("ASlineorth compute NDnode parent line error");return(1);}

  /* compute now the ortho line */
  status = ortho_line(rootdef,count,list,linedef.var.line_st.v0);
  if(!status) return (OM_S_SUCCESS); /*return without modifying the ortholine*/

  v_equal(rootdef[0].var.point_st.pt,linedef.var.line_st.p0);
  v_equal(rootdef[0].var.point_st.pt,linedef.var.line_st.p1);

  /* update the graphic associated object */
  status = om$send( msg = message ASline.ASpostab(msg,md_env,&linedef),
 	   senderid = my_id, targetid = my_id );
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
}  /* NDcompute_node */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDprint                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  OMuint              icount;              /* Index for loop                  */
  struct ret_struct   my_def;              /* Definitions of the object       */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  IGRlong status,msg;

  /* Get the structure of the class */

  status = om$send( msg = message NDnode.NDgive_structure(&msg,&my_def,md_env),
           	    targetid = my_id );
  as$status(action = RET_STATUS);


  /* Get the name of this object */

  as$printer_set_name(prefix="ORTHO_LINE",
		      name=name);

  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and Symbology */

  as$printer_print_parents(count=&count);
  as$printer_print_symb();

  /* Print the instances (snap point) for line lenght */

  for (icount=0; icount<3 ; icount++)
      fprintf(stream,"ptr[%d]=%lf;\n",icount,my_def.var.line_st.p1[icount]);

  /* Print the message */

  fprintf(stream,"send ASlineorth.place(%d,list,ptr) to %s;\n",count,name);

  /* Is there also extend to print */

  if(me->d0 != me->d1)
    {
     ASprint_line_ext(stream, me->d0-me->d1,0. ,name);
    }

  fprintf(stream,"\n");
   
  return(OM_S_SUCCESS);
}/* end NDprint */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
     *msg = MSSUCC;
     ex$message( buff=info->type,
		 msgnumb=AS_I_OrtLn);
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
     geom_code[j]   = point_generic;;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 1 :
    {
     geom_code[j]   = point_generic | ref_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 2 :
    {
     geom_code[j]   = point_generic;
     option_code[j] =  1;
     break;
    }
  } /*  end switch  */

 /*  track point or ref ? */
 *index_track = -1;  /* no track point */
 *index_ref   = -1;  /* no ref         */
 *index_plan  = -1;  /* no plan        */
   
 return(OM_S_SUCCESS);
}


end implementation ASlineorth;
