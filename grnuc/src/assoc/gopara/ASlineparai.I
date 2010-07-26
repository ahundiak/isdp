/*\  parallel line implementation file

     CHANGE HISTORY:

     jla  04-Mar-86   : exec0 design
     jla     jul 86   : ige implementation
     jla  28 oct 86   : associative implementation
     jla  08 sep 89   : function ASlinepara_get_parent 
			correct behaviour if plane in root list
\*/


class implementation ASlinepara;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ASmsg.h"
#include "msmacros.h"

#define  AS_DEBUG 1
#define  UNIT_DISTANCE 1

double fabs();
extern GRclassid OPP_GR3dlineseg_class_id;

/* Get and control the geometry of the parents */

ASlinepara_get_parents(num_p,list,
		       dist,line_def,track_pt,vnorm,track,plane,md_env) 
IGRint num_p;
struct GRid *list;
IGRdouble *dist;
struct ret_struct *line_def;
IGRdouble *track_pt,*vnorm;
IGRboolean *track,*plane;
struct GRmd_env *md_env;
/*.ASlinepara_get_parents*/
{
 IGRlong msg,status;
 IGRint i,ii;
 double *matrix = NULL;
 struct ret_struct obj_def[2];

 if(num_p<2 || num_p>4) return(OM_W_ABORT);

 /* is there a track point or a plane */

 *track=0;*plane=0;
 for(ii=0,i=2;i<num_p;i++,ii++)
   {
    status = om$send(msg = message NDnode.NDgive_structure
                                                 (&msg,&obj_def[ii],md_env) ,
		     senderid = NULL_OBJID,
                     targetid = list[i].objid,
                     targetos = list[i].osnum);
    as$status(action = RET_STATUS);

    if(obj_def[ii].type &  point_generic)
       {if(*track){printf("two track point for a parallel line\n");
                  return(OM_W_ABORT);}
        *track=i;v_equal(obj_def[ii].var.point_st.pt,track_pt);}

    else if(obj_def[ii].type & ref_generic)
       {if(*plane){printf("two plane for a parallel line\n");
                   return(OM_W_ABORT);}
        *plane=i;
        vnorm[0]=obj_def[ii].var.ref_st.t[2];
        vnorm[1]=obj_def[ii].var.ref_st.t[6];
        vnorm[2]=obj_def[ii].var.ref_st.t[10];
	matrix  =obj_def[ii].var.ref_st.t;
       }
   }

/* value of the parameter */

    status = om$send(msg = message NDnode.NDgive_structure
                                                         (&msg,line_def,md_env),
		     senderid = NULL_OBJID,
                     targetid =  list[0].objid ,
                     targetos =  list[0].osnum );
    as$status(action = RET_STATUS);
    if(line_def->type != double_type) return OM_W_ABORT;
    *dist = line_def->var.root_pm_st.value / UNIT_DISTANCE;

/* data of the parent line */

    status = om$send(msg = message NDnode.NDgive_structure
                                                         (&msg,line_def,md_env),
		     senderid = NULL_OBJID,
                     targetid = list[1].objid,
                     targetos = list[1].osnum);
    as$status(action = RET_STATUS);
    if(!(line_def->type&line_generic)) return(OM_W_ABORT);

/* If there is a plane as parent project the line in this plane */

    if(*plane)
      {
       ASproject_in_xy(matrix,AS_IN_LINE,line_def->var.line_st.p0,
					 line_def->var.line_st.p0);
       ASproject_in_xy(matrix,AS_IN_LINE,line_def->var.line_st.p1,
					 line_def->var.line_st.p1);
       ASproject_in_xy(matrix,AS_IN_LINE | AS_VECTOR,line_def->var.line_st.v0,
					 	     line_def->var.line_st.v0);
       if(*track)
       ASproject_in_xy(matrix,AS_IN_LINE,track_pt,track_pt);
      }
 
    return(OM_S_SUCCESS);
}

 

/****************************************************************************
  ASlinepara.place
  Non interactive placement of a ASlinepara
*****************************************************************************/

method NDplace(struct GRas *asso_lis;struct GRmd_env *md_env; 
		IGRchar *go_cnst_lis)
 {
  
IGRdouble *snap,w[3],track_pt[3];
IGRdouble workpoints[6];
IGRpoint vnorm,vtrans;
struct ret_struct line_def,my_def;

IGRdouble dist,length,scal,xx;
IGRint num_p;
IGRdouble one=1.;
IGRlong status;
IGRboolean track,plane;
struct GRid *list;

/*
   placement point : This point can be the placement point define by the user
   or a point of the already existing graphic object when this object is 
   transform to paraline
*/
    list = asso_lis->parents;
    num_p = asso_lis->num_parents;
    
    if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
     {
      snap = (IGRdouble *) asso_lis->as_attr;
     }
    else
     {
      status = as$any_give_structure(go_grid = asso_lis->go_objid,
                         	     mod_env = md_env,
				     inst    = &my_def );
      as$status(action = RET_STATUS);
      snap = my_def.var.line_st.p0;
     }


/* Get and control the geometry of the parents */

ASlinepara_get_parents(num_p,list,
		       &dist,&line_def,track_pt,vnorm,&track,&plane,md_env);


/*
    definition of the vector to go from original line to parallel. 
    This vector is defined by an external plane or by the snap point.
    Has to be in the good orientation depending upon snap point.
*/

  v_sub(snap,line_def.var.line_st.p0,w);
  if (plane)   
       { 
	v_cross(vnorm,line_def.var.line_st.v0,vtrans);
        length = v_len(vtrans);
        if(length == 0.)
               {printf("ASlinepara place error, plane not defined\n");
	        return(OM_W_ABORT);}
        scal = v_dot(w,vtrans);
        if(scal*dist < 0) length=-length;
       }

  else
       {
	scal = -v_dot(w,line_def.var.line_st.v0);
	v_comb(one,w,scal,line_def.var.line_st.v0,vtrans);
        length = v_len(vtrans);
        if (length == 0.) 
            {
 printf("Warning\n"); 
 printf("The plane where the parallel line is suppose to be is not defined\n");
 printf("(the placement point is on the original line).\n");
 printf("Default initialization : plane defined by original line and ");

	     if(line_def.var.line_st.v0[1]>0.1 || line_def.var.line_st.v0[2]>0.1)
               {
	        printf("x axes\n");
	        vtrans[0] = 1; vtrans[1] = 0; vtrans[2] = 0; length = 1;
	       }
	     else
               {
	        printf("y axes\n");
	        vtrans[0] = 0; vtrans[1] = 1; vtrans[2] = 0; length = 1;
	       }
	    }

	if(dist<0) v_neg(vtrans,vtrans);
	}


     

/* position of the line */

    v_equal(vtrans,me->vt);
    xx=dist/length;
    v_scale(vtrans,xx,vtrans);
    v_add (line_def.var.line_st.p0,vtrans,workpoints);
    v_add (line_def.var.line_st.p1,vtrans,&(workpoints[3]));

     


/* length of the line and extend value if any */

  v_sub( &(workpoints[3]), workpoints, vtrans );

  if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
    {
     me->d0=0.;
     me->d1=0.;
    }
  else
   {
    v_sub( my_def.var.line_st.p0, workpoints, vtrans );
    xx = v_dot( line_def.var.line_st.v0, vtrans );
    me->d0 = -xx;
    v_scale(line_def.var.line_st.v0, xx, vtrans);
    v_add(workpoints, vtrans, workpoints );

    v_sub( my_def.var.line_st.p1, &(workpoints[3]), vtrans );
    me->d1 = v_dot( line_def.var.line_st.v0, vtrans );
    v_scale(line_def.var.line_st.v0, me->d1, vtrans);
    v_add( &(workpoints[3]), vtrans, &(workpoints[3]) );
   }

/* Definition of me->flag

    value         with track point     with plane    with nothing

      0            same side for d>0   doesn't reverse vtrans after compute
      1            opposite side       reverse vtrans after compute

If there is a plane we need to reverse vtrans when positive value of
distance is negative vnorm*v0 direction.
If there si no plane and that the recompute uses my old me->v0 instead of
original_line->v0, we need to reverse vtrans if line and parallel are in
opposite direction, due to extend

*/


   if(track)
     {
      v_sub(workpoints,line_def.var.line_st.p0,w);
      v_sub(track_pt,line_def.var.line_st.p0,vtrans);
      scal = dist*v_dot(w,vtrans);
      me->flag = (scal<0);  /* 1 if opposite side */
     }
    else if (plane)
      {
       me->flag = (length <0);
      }
    else if (!IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
      {
       v_sub(&workpoints[3],workpoints,w);
       xx=v_dot(w,line_def.var.line_st.v0);
       me->flag = (xx <0 );
      }
    else 
      {
       me->flag = 0;
      }
  if(go_cnst_lis != NULL)
   {
    struct IGRpolyline geom;

    /*| Construct the G.O */
    geom.num_points = 2;
    geom.points     = workpoints;

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (char *) &geom;

    status = om$send(msg = message ASnode.ASconstruct_go
		    (asso_lis,md_env,go_cnst_lis,OPP_GR3dlineseg_class_id,TRUE),
	    	     targetid = my_id);
    as$status(action = RET_STATUS);
   }


/*
    add in node tree
*/

     status=om$send(msg = message NDnode.NDconnect
					      (num_p,list,NULL_GRID,ND_NEW),
            	   targetid =  my_id);
    as$status(action = RET_STATUS);
    return(OM_S_SUCCESS);


 }/* place */


/**************************************************************************
  compute_node

    compute a para line at a given distance (parameter) of  
    an other line (parent line)                          
    this line may have one or two parents. The first is the line
    it has to be parallel to, the second if defined gives the location
    plane

***************************************************************************/

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count;struct GRid list[];struct GRmd_env *md_env)

{
IGRpoint vnorm,vtrans,track_pt,w;
struct ret_struct line_def,my_def;
IGRdouble dist,length,scal;
IGRlong status;
IGRboolean track,plane;

/* Get and control the geometry of the parents */

ASlinepara_get_parents(count,list,
		       &dist,&line_def,track_pt,vnorm,&track,&plane,md_env);

/* previous position if no plane */

 if(!plane)
   {
    status = om$send(msg = message NDnode.NDgive_structure(msg,&my_def,md_env),
	    	     targetid = my_id);
    as$status(action = RET_STATUS);
    v_cross(my_def.var.line_st.v0,me->vt,vnorm);
   }

/*
   translation to go from original line to parallel
   Store it in my instances
*/

   v_cross(vnorm, line_def.var.line_st.v0, vtrans);
   length = v_len(vtrans);
   if(length == 0.)
      {
       v_equal(me->vt , vtrans);
       length = v_len(vtrans);
       if(length == 0) {printf("error in plane definition for parallel line\n");
			return(OM_S_SUCCESS);}
      }

/*  Do I need to reverse this vector ?
    Necessary if
    - track point position doesn't agree
    - vnorm, v0, vtrans is not direct cross product
*/

   if(track)
     {
      v_sub(track_pt,line_def.var.line_st.p0,w);
      scal = v_dot(vtrans,w);
      if( (scal>0) == (me->flag&1)) length = -length;
     }
   else if (plane)
     {
      if(me->flag&1) length = -length;
     }
   else if(me->flag&1) v_neg(vtrans,vtrans);


/* new position of the line */

    v_equal(vtrans,me->vt);
    dist=dist/length;
    v_scale(vtrans,dist,vtrans);
    v_equal(line_def.var.line_st.v0,my_def.var.line_st.v0);
    v_add  (line_def.var.line_st.p0,vtrans,my_def.var.line_st.p0);
    v_add  (line_def.var.line_st.p1,vtrans,my_def.var.line_st.p1);


/* update the graphic associated object */
 status = om$send(msg = message ASline.ASpostab(msg,md_env,&my_def),
 		   targetid =  my_id);
 as$status();

 return(status);

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  struct ret_struct  my_def;              /* Definitions of the object       */
  struct ret_struct  ori_def;             /* Original line definitions       */
  IGRlong             msg;                 /* Returned message from om        */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  IGRpoint snap;		 	   /* placement point 	              */
  IGRvector           w;		   /* for extend computation	      */
  IGRdouble length,my_len;
  IGRint count,icount;
  IGRint status;
  struct GRid list[2];                     /* I want 2 parents returned by    */
					   /* print_parents 		      */

  /*| Get the structure of the class */

  status = om$send(msg = message NDnode.NDgive_structure(&msg,&my_def,md_env),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  /*| Get the name of this object and return if already printed */

  as$printer_set_name(prefix = "PARA_LINE",
		      name   = name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

    /* Print the parents and the symbology */

    as$printer_print_parents(list = list,
			     size = 2,
			     count = &count);
			     
    as$printer_print_symb();

    /*| Print the instances (snap point) */
    /* But be carreful to not print a point on the original line
       PPL will not be able to remake the construction */

    v_equal(my_def.var.line_st.p0,snap);

    v_sub(my_def.var.line_st.p0,my_def.var.line_st.p1,w);
    my_len = v_len(w);

    status=om$send(msg = message NDnode.NDgive_structure(&msg,&ori_def,md_env),
	       targetid = list[1].objid);
    as$status(action = RET_STATUS);
    v_dist_line(snap,ori_def.var.line_st.p0,ori_def.var.line_st.v0,
		&length,w);
    length = v_len(w);
    if (length < 1.e-6 + 1.e-6*my_len) 
       {v_add(snap,me->vt,snap);
	/*|change snap */
       }
   

    for (icount=0; icount<3 ; icount++)
      fprintf(stream,"ptr[%d]=%lf;\n",icount,snap[icount]);

    /* Print the message */

    fprintf(stream,"send ASlinepara.place(%d,list,ptr) to %s;\n",count,name);

   /* Is there also extend to print */

    if(me->d0 !=0 || me->d1 !=0)
      {
         ASprint_line_ext(stream, me->d0, me->d1,name);
      }

  fprintf(stream,"\n");
  return(1);
}/* end print */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
    {
     *msg = MSSUCC;
     ex$message(buff=info->type,msgnumb=AS_I_ParLn);
     return(OM_S_SUCCESS);
    }


method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return,
			  *nb_tot )
{
IGRint i, j;
 
 *nb_tot = 4;
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
     geom_code[j]   = line_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 2 :
    {
     geom_code[j]   = point_generic | ref_generic;
     option_code[j] =  2;/* optional track_point or plan */
     break;
    }
   
   case 3 :
    {
     geom_code[j]   = point_generic | ref_generic;
     option_code[j] =  2;/* optional track_point or plan */
     break;
    }
  } /*  end switch  */

 *index_track = -1;
 *index_ref   = -1;  
 *index_plan  = -1;

 /*| look for the index of the optional root */

 om$send( msg = message ASnode.ASget_opt_ind( 2,
	  index_track, index_ref, index_plan ), targetid = my_id );

 return(OM_S_SUCCESS);
}

/*
   change my internal flag.
   Used by ASline.GRdisextend when the line change direction
*/

method change_flag()
{
 me->flag = 1 - me->flag;
 return(OM_S_SUCCESS);
}

method ACcompute_node( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *prop,*size_inst,*no_go;
			   char *inst_save)
{
int siz_inst,status;
 siz_inst=sizeof(me->vt);

 OM_BLOCK_MOVE(  inst_save,me->vt, 
		siz_inst);
 status = om$send(msg =  message NDnode.NDcompute_node (msg,cn_type ,
					count,list, 
					md_env),
  		   targetid =my_id ); 
 as$status( );

 if (!( (me->state) & ND_OUT_OF_RT)&& *no_go != -1 )
      {*no_go += 1;}

 OM_BLOCK_MOVE( me->vt, inst_save,
		siz_inst);
 *size_inst += siz_inst ;
 return (1) ;
}
/*
 - d0, d1 are the extends of my ends points, positive to external.
   When I store them in my instances, they become relative to the orientation
   of my original line.

 - my orientation is used with my internal flag to determine the side
   of the original line, if no track point nor plane. If the extends change
   my orientation I have to also change the flag.
*/
 


method ASlinext(IGRdouble d0,d1; struct GRmd_env *md_env)
{
 struct GRid *list;
 IGRint count;
 struct ret_struct my_def,par_def;
 IGRpoint p0,p1,w;
 IGRdouble scal,xx, one=1.;
 IGRlong msg,status;
 IGRlong cn_type;

/*"linext of parallel %d %lf %lf\n",my_id,d0,d1 */

 count = 0;
 status = om$send(msg = message NDnode.NDget_objects (ND_ROOT|ND_IN_BUF,
						      NULL,0,&list,0,2,&count),
                  targetid = my_id);
 as$status(action = RET_STATUS);
/*"count %d\n",count */

 status = om$send(msg = message NDnode.NDgive_structure(&msg,&my_def,md_env),
                      targetid = my_id);
 as$status(action = RET_STATUS);

 status = om$send(msg = message NDnode.NDgive_structure(&msg,&par_def,md_env),
                      targetid = list[1].objid,
                      targetos = list[1].osnum);
 as$status(action = RET_STATUS);

 scal = v_dot(my_def.var.line_st.v0,par_def.var.line_st.v0);

 if(scal>0)
   {
    /*| parallel same orientation */
    me->d0 += d0;
    me->d1 += d1;
   }
 
 else
   {
    /*| parallel opposite orientation */
    me->d0 -= d0;
    me->d1 -= d1;
   }

/* update the element */

  cn_type = 0;
  status = om$send(msg = message NDnode.NDs_compute_node(&msg,cn_type,md_env),
	           targetid = my_id);
  as$status();

/* changes if necessary internal flag 
   NOTE : IT HAS TO BE DONE AFTER ELEMENT UPDATE */

 v_comb(one,par_def.var.line_st.p1,me->d1,par_def.var.line_st.v0,p1);
 xx = -me->d0;
 v_comb(one,par_def.var.line_st.p0,xx,par_def.var.line_st.v0,p0);
 v_sub(p1,p0,w);

 scal = v_dot(my_def.var.line_st.v0,w);

 /*"scal %lf\n",scal*/
 if(scal<0)
   {
    /*| parallel changes sign */
    if(count<3)
        {
	 /*| change flag */
         status = om$send(msg = message ASlinepara.change_flag(),
                                 targetid = my_id);
         as$status(action = RET_STATUS);
        }
     }
  else
   {
    /*| parallel does not change sign */
   }
  return(OM_S_SUCCESS);
}
  


end implementation ASlinepara;
