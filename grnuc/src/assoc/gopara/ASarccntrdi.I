/*-------------------------------
  ASarccntrd
  ch :28-Octobre-86
--------------------------------*/



class implementation ASarccntrd;

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

static int ASget_parent __((int count, struct GRid *list, double *param_val, 
                            double *cent_p, double *start_p, double *sweep_p, 
                            double *track_p, double *norm, int *track, 
                            int *plane, struct GRmd_env *md_env));
static int ASget_plane __((int plane, IGRdouble *view_vect, IGRdouble *cent_p, 
                           IGRdouble *start_p, IGRdouble *sweep_p, 
                           IGRdouble *norm, IGRdouble *matrix));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



extern GRclassid OPP_GR3dcirarc_class_id;

#define AS_DEBUG 1

IGRdouble point_angle();
double fabs();


/*
   Get the parents of the associative arc 
*/
static ASget_parent(
  int    count,
  struct GRid *list,
  double *param_val,
  double *cent_p,
  double *start_p,
  double *sweep_p,
  double *track_p,
  double *norm,
  int    *track,
  int    *plane,
  struct GRmd_env *md_env)
/*.ASget_parent*/
 {
  struct ret_struct opt_def[2],point_def;
  IGRlong status,msg;
  double *matrix = NULL;
  double *point[3];
  int ii,i;
  
 /* control number of parents */
 if(count<4 || count >6) return(OM_W_ABORT);

 /* get optionnal parents */

 *track = 0; *plane = 0;
 for(ii=0,i=4;i<count;i++,ii++)
   {
    status = om$send(msg = message NDnode.NDgive_structure
                                                 (&msg,&opt_def[ii],md_env) ,
                     senderid = NULL_OBJID,
                     targetid = list[i].objid,
                     targetos = list[i].osnum);
    as$status(action = RET_STATUS);

    if(opt_def[ii].type &  point_generic)
       {if(*track){printf("two track point !!!\n");
                  return(OM_W_ABORT);}
        *track=i;v_equal(opt_def[ii].var.point_st.pt,track_p);}

    else if(opt_def[ii].type & ref_generic)
       {if(*plane){printf("two plane !!!!\n");
                   return(OM_W_ABORT);}
        *plane=i;
        norm[0]=opt_def[ii].var.ref_st.t[2];
        norm[1]=opt_def[ii].var.ref_st.t[6];
        norm[2]=opt_def[ii].var.ref_st.t[10];
        matrix =opt_def[ii].var.ref_st.t;
       }
   }

   if(*plane && *track) ASproject_in_xy(matrix,AS_IN_LINE,track_p,track_p);

/*
   value of the parameter

  SURPRISING BUT THE SIGN OF THE PARAMETER DOES NOT AFFECT THE ARC.
  ITS THE WAY IT HAS BEEN CODED, AND TO NOT BREAK COMPATIBILITY IT HAS
  TO BE MAINTAINED
*/

    status = om$send(msg = message NDnode.NDgive_structure
                                                       (&msg,&point_def,md_env),
                     senderid = NULL_OBJID,
                     targetid = list[0].objid,
                     targetos = list[0].osnum);
    as$status(action = RET_STATUS);
    if(point_def.type != double_type) return(OM_W_ABORT);
    *param_val = fabs(point_def.var.root_pm_st.value);
    *param_val = fabs(*param_val);
  

/* data of the definition point */

   point[0] = cent_p;
   point[1] = start_p;
   point[2] = sweep_p;

   for(i=0;i<3;i++)
      {
       status = om$send(msg = message NDnode.NDgive_structure
                                                       (&msg,&point_def,md_env),
                     senderid = NULL_OBJID,
                     targetid = list[i+1].objid,
                     targetos = list[i+1].osnum);
       as$status(action = RET_STATUS);
       if(!(point_def.type&point_generic)) return(OM_W_ABORT);
       if(*plane)
	 {
          ASproject_in_xy(matrix,AS_IN_LINE,point_def.var.point_st.pt, point[i]);
	 }
       else
	 {
	  v_equal(point_def.var.point_st.pt,point[i]);
	 }
      }
   /*^pr_point("cent_p",cent_p);
      pr_point("start_p",start_p);
      pr_point("sweep_p",sweep_p);
      if(*track) pr_point("track_p",sweep_p);
      if(*plane) pr_point("norm",norm);
   */
      
   return (OM_S_SUCCESS);
  }

/*
   Get the plane of the associative arc 
*/

static ASget_plane(plane,view_vect,cent_p,start_p,sweep_p,norm,matrix)
int plane;
IGRdouble
 *view_vect,                 /* IN  view vector or normal to previous position*/
 *cent_p,*start_p,*sweep_p,  /* IN  definition point 			      */
 *norm,			     /* OUT normal to new position		      */
 *matrix;                    /* OUT placement matrix		 	      */
/*.ASget_plane*/
{
 double v1[3],v2[3],vz[3],xpt[3],ypt[3];
 double kk;
 IGRlong msg,status;
 short num;


 MAsubvc( &msg, start_p, cent_p, v1 );

 if(plane) 
  {
   /*| the plane is explicitly defined in the parent list */
   /* and the points are already projected in the plane   */
   MAcrossvc( &msg, view_vect, v1, v2 );
   MAaddvc(&msg,cent_p,v2,ypt);

   status = MA3protmx( &msg, cent_p, start_p, ypt, matrix );
   v_equal(view_vect,norm);
  }
 else
  { 
   /*| The plane has to be computed from the definition point */

   MAsubvc( &msg, sweep_p, cent_p, v2 );
   MAcrossvc( &msg, v1, v2, vz );
   MAdotvc( &msg,vz,vz,&kk);

   if( fabs(kk) < 1.e-10 )
     {
      /*| cas degenere */
      MAcrossvc( &msg, view_vect, v1, ypt );
      MAlenvc( &msg, ypt, &kk);
      if( fabs(kk) > 1.e-8)
       {
	/*| take start point and view vector to define the plane */
	v_equal(start_p,xpt);
        MAaddvc( &msg, cent_p, ypt, ypt);
       }
      else
       {
	/*| take end point and view vector to define the plane */
        MAcrossvc( &msg, v2, view_vect, xpt );
        MAlenvc( &msg, xpt, &kk);
        if( fabs(kk) < 1.e-8) return(OM_W_ABORT);
        MAaddvc( &msg, cent_p, xpt, xpt);
	v_equal(sweep_p,ypt);
       }
     }
    else 
    {
     MAdotvc( &msg,view_vect,vz,&kk);
     if(kk<0)
     {
      v_equal(start_p,xpt);
      MAsubvc(&msg,cent_p,v2,ypt);
     }
     else
     {
      v_equal(start_p,xpt);
      v_equal(sweep_p,ypt);
     }
    }
    status = MA3protmx( &msg, cent_p, xpt, ypt, matrix );
    /*" 3protmx status %d msg %d\n", status,msg */
    if( msg == MASDGENRAT )
      {
       printf("Degenerate case\n");
       return(OM_W_ABORT);
      }
    v_equal(&matrix[8],norm);
   }

  /*| transpose the matrix */
  num = 4;
  MAtrnmx( &msg, &num, matrix, matrix );

  /*^ pr_point("norm",norm);
      pr_mat("mat",4,4,matrix);
  */

  return(OM_S_SUCCESS);
}

/*       ----  ASarccntrd.NDplace  ----
  
     This method is used to place a no interactive circle which is centered
  around a point. The snap point is not used

*/

method NDplace( struct GRas *asso_lis; struct GRmd_env *md_env;
	        IGRchar *go_cnst_lis )
 {
  OMuint count;
  struct GRid *parent;
  IGRdouble *view_vect;
  struct ret_struct objdef;
  IGRpoint cent_p, start_p, sweep_p, track_p, norm, vv;
  struct IGRarc arc;
  IGRdouble  t_angle;
  IGRlong    msg,status;          /* Status returned by om                   */
  int track,plane;
  double dot_pro;
 
  count = asso_lis->num_parents;
  parent = asso_lis->parents;

  if(IF_EQ_OBJID( (parent+1)->objid, (parent+2)->objid ) && 
     IF_EQ_OBJID( (parent+1)->objid, (parent+3)->objid )) return(OM_W_ABORT);

  /* Use placement vector or instances of already existing element */

  if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
   {
    view_vect = (IGRdouble *) asso_lis->as_attr;
   }
  else
   {
    status = as$any_give_structure(go_grid = asso_lis->go_objid,
                       		   mod_env = md_env,
				   inst    = &objdef );
    as$status(action = RET_STATUS);
    vv[0] = objdef.var.circle_st.mat[2]; 
    vv[1] = objdef.var.circle_st.mat[6]; 
    vv[2] = objdef.var.circle_st.mat[10]; 
    view_vect = vv;
   }

  /* get parent value and control type */

  status = ASget_parent(count,parent,
		    &arc.prim_axis,cent_p,start_p,sweep_p,
		    track_p,norm,&track,&plane,md_env);
  if(!(status&1)) return(OM_W_ABORT);

  /* Do I need to reverse the orientation of the plane ? */

  if(plane)
    {
     if(!track)
      {
       MAdotvc( &msg, view_vect, norm, &dot_pro );
       if(dot_pro < 0)
         {
	  me->orient_f = 0;
	  v_neg(norm,norm);
         }
       else
         {
	  me->orient_f = 1;
         }
      }
     view_vect = norm;
    }

  /* Get the plane of the associative arc */
  
  status =
        ASget_plane(plane,view_vect,cent_p,start_p,sweep_p,norm,arc.rot_matrix);
  if(!(status&1)) return(OM_W_ABORT);

  /*|  init of the arc   */

  arc.sec_axis = arc.prim_axis;
  v_equal(cent_p,arc.origin);

  /*| Compute angle between the points  */
  arc.sweep_angle = point_angle(cent_p, start_p, sweep_p, norm);
  arc.start_angle = 0;

  /*"sweep_angle: %lf\n", arc.sweep_angle */

  if( track )
    {
      /*| project the track point on the arc's plane and compute the angle */
      MAsubvc(&msg,track_p,cent_p,track_p);
      ASproject_in_xy( arc.rot_matrix, AS_VECTOR|AS_IN_LINE, track_p, track_p );
      MAaddvc(&msg,track_p,cent_p,track_p);
      t_angle = point_angle(cent_p, start_p, track_p, norm);
      /*" There is a track point, track angle: %lf\n", t_angle */

      if( t_angle > arc.sweep_angle ) me->orient_f = 0;
      else 		              me->orient_f = 1;
     }

  /*"me->orient_f %d\n",me->orient_f */

  if(go_cnst_lis != NULL)
  {
   /*| graphic object computed and created */

   ((struct GRvg_construct *)go_cnst_lis)->geometry = (char *) &arc;
   status = om$send
            (msg      = message ASnode.ASconstruct_go
                     (asso_lis,md_env,go_cnst_lis,OPP_GR3dcirarc_class_id,TRUE),
             targetid = my_id);
   as$status(action = RET_STATUS);
 }

  /*| Add to the graph */
  status = om$send
             (msg       = message NDnode.NDconnect(asso_lis->num_parents,
                                  asso_lis->parents,NULL_GRID,ND_NEW),
             targetid = my_id);
  as$status(action = RET_STATUS);

 return(OM_S_SUCCESS);
 }   /*           ----  end NDplace  ----                */


/*            ---- ASarccntrd.compute_node ----

       This method calculates the new instance of the parallel circle

*/
method NDcompute_node(IGRlong *msg;IGRint cn_type;
		      int count; struct GRid *parent; struct GRmd_env *md_env)
{
  GRobjid newobjid;
  struct ret_struct cir_struct;
  struct IGRarc arc;
  IGRpoint cent_p, start_p, sweep_p, track_p, norm, view_vect;
  IGRdouble  t_angle;
  struct GRpost_info post_info;
  IGRlong    status;              /* Status returned by om                   */
  int track,plane;

  /* get parent value and control type */

  status = ASget_parent(count,parent,
		    &arc.prim_axis,cent_p,start_p,sweep_p,
		    track_p,view_vect,&track,&plane,md_env);
  if(!(status&1)) return(OM_W_ABORT);

  v_equal(cent_p,arc.origin);
  arc.sec_axis  = arc.prim_axis;

  /*   we choice the view vector as vz of the rotate matrix  */

  if(plane)
   {
    /*| Do I need to reverse orientation of the plane ? */

    if(!track && !me->orient_f)
     {
      /*| yes */
      v_neg(view_vect,view_vect);
     }
   }
   else
   {
    /*| get previous matrix of the arc */
    status=om$send(msg = message NDnode.NDgive_structure
						       (msg,&cir_struct,md_env),
                    targetid = my_id);
    as$status(action = RET_STATUS);
    view_vect[0] = cir_struct.var.circle_st.mat[2];
    view_vect[1] = cir_struct.var.circle_st.mat[6];
    view_vect[2] = cir_struct.var.circle_st.mat[10];
   }

  /* Get the plane of the associative arc */
  
   status =
       ASget_plane(plane,view_vect,cent_p,start_p,sweep_p,norm,arc.rot_matrix);
   if(!(status&1)) return(OM_S_SUCCESS);

   /*^pr_point("norm",norm); */
   arc.sweep_angle = point_angle(cent_p, start_p, sweep_p, norm);
   arc.start_angle = 0;

    /*| determination of angle between the points  */
   if( track )
     {

      /*| project the track point on the arc's plane and compute the angle */
      MAsubvc(msg,track_p,cent_p,track_p);
      ASproject_in_xy( arc.rot_matrix, AS_VECTOR|AS_IN_LINE, track_p, track_p );
      MAaddvc(msg,track_p,cent_p,track_p);
      t_angle = point_angle(cent_p, start_p, track_p, norm);
      /*"track angle: %lf\n", t_angle */

      if ( (t_angle <= arc.sweep_angle ) != me->orient_f)
       {
         arc.sweep_angle = PI + PI - arc.sweep_angle;
         arc.rot_matrix[1] = -arc.rot_matrix[1];
         arc.rot_matrix[2] = -arc.rot_matrix[2];
         arc.rot_matrix[5] = -arc.rot_matrix[5];
         arc.rot_matrix[6] = -arc.rot_matrix[6];
         arc.rot_matrix[9] = -arc.rot_matrix[9];
         arc.rot_matrix[10] = -arc.rot_matrix[10];
       }
     }

 /*"start_angle: %lf, sweep_angle: %lf\n",arc.start_angle,arc.sweep_angle */
  
 post_info.construct_flag = FALSE;

 status = om$send( msg = message GRconic.GRputarc( msg, md_env, &post_info,
                   &arc, &newobjid),
                   p_chanselect = &AS_to_comp);
 as$status();
 return(1);
}   /*   end NDcompute_node    */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDprint                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  struct ret_struct   my_def;              /* Definitions of the object       */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  IGRlong    msg,status;              /* Status returned by om                   */

  /* Get the structure of the class */

  status = om$send
             (msg      = message NDnode.NDgive_structure(&msg,&my_def,md_env),
              targetid = my_id);
  as$status(action = RET_STATUS);

  /* Get the name of this object */

  as$printer_set_name(prefix = "ARC_BY_PT",
		      name =  name );
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* print the parents names and symbology */

   as$printer_print_parents(count=&count);
   as$printer_print_symb();

    /*| Print the instances (snap point) */

    fprintf(stream,"ptr[0]=%lf;\n",my_def.var.circle_st.mat[2]);
    fprintf(stream,"ptr[1]=%lf;\n",my_def.var.circle_st.mat[6]);
    fprintf(stream,"ptr[2]=%lf;\n",my_def.var.circle_st.mat[10]);

    /*| Print the message */

    fprintf(stream,"send ASarccntrd.place(%d,list,ptr) to %s;\n\n",count,name);
  return(1);
}/* end NDprint */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
   *msg = MSSUCC;
   ex$message ( buff    = info->type,
	        msgnumb = AS_I_CtParArc);
   return(OM_S_SUCCESS);
}


method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
 IGRint i, j;
 
 *nb_tot = 6;
 if( ifrom < 0 ) ifrom = 0;
 if( ito  < ifrom ) { *nb_return = 0; return(OM_S_SUCCESS); }
 if( ito  > *nb_tot - 1 ) ito = *nb_tot - 1;
 *nb_return = ito - ifrom + 1;
 
 for( i = ifrom, j = 0; i <= ito ; i++, j++ )
  switch( i )
  {
   case 0 : 
    {
     geom_code[j]   = parameter_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 1 :
    {
     geom_code[j]   = point_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 2 :
    {
     geom_code[j]   = point_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 3 :
    {
     geom_code[j]   = point_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 4 :
    {
     geom_code[j]   = point_generic | ref_generic;
     option_code[j] = 2;/* optional track_point */
     break;
    }

   case 5 :
    {
     geom_code[j]   = point_generic | ref_generic;
     option_code[j] = 2;/* optional track_point */
     break;
    }
  } /*  end switch  */

   /*| look for the index of the optional root */
   om$send( msg = message ASnode.ASget_opt_ind( 4, index_track, index_ref, 
            index_plan ), targetid = my_id );

 return(OM_S_SUCCESS);
}


end implementation ASarccntrd;
