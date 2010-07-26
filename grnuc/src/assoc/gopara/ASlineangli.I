/*\  ASlineangl implementation file
     CHANGE HISTORY:

     jla  04-Mar-86   : exec0 design
     jla     jul 86   : ige implementation
     jla  28 oct 86   : associative implementation
\*/

class implementation ASlineangl;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "nddef.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "bserr.h"
#include "ASmsg.h"
#include "msmacros.h"


#define AS_DEBUG 1
#define UNIT_ANGLE 57.29577951

extern GRclassid OPP_GR3dlineseg_class_id;


/*
   This function is used by place and compute method to find
   the axis origin of the angle line
   (will be the position of the angle line for angle = 0)
   This axes could be defined by 
   - an original line
   - the x axis of a coordinate system
   - the tangent to a curve at the projection of the fix point */

ASlineangl_vor(pointdef,linedef,line_grid,md_env)
struct ret_struct *pointdef,*linedef;
struct GRid line_grid;
struct GRmd_env *md_env;
/*._vor*/
{
 struct GRid go_object;
 IGRmatrix matrix;
 IGRshort mat_type;
 IGRchar *ptr;
 struct IGRbsp_curve *bc;
 struct GRparms par;
 IGRpoint project;
 IGRdouble tangent2[6], *tangent;
 struct ret_struct refdef;
 IGRint i;
 long status,msg;
 IGRdouble length;
 IGRlong rc;

 /* get the structure of the parent */

/*" line_grid %d %d\n",line_grid.objid,line_grid.osnum */

 status = as$any_give_structure( go_grid = line_grid,
                         	 mod_env = md_env,
				 inst    = linedef );

/*| If this parent is a line --> nothing special */

 if(linedef->type&line_generic) return (OM_S_SUCCESS);

/*| If this parent is a coordinate system --> take x_axis */

 if(linedef->type&ref_generic)
   {

    refdef=*linedef;
    for(i=0;i<3;i++)
	{
         linedef->var.line_st.v0[i] = refdef.var.ref_st.t[4*i];
         linedef->var.line_st.p0[i] = refdef.var.ref_st.t[4*i+3];
        }
   }

/* This parent is a general curve */

 else
   {
    /*| get the graphic object and its environnement */
    status = om$send(msg = message NDnode.ASreturn_go(&go_object,
                                                 &mat_type,matrix),
		     senderid = NULL_OBJID,
                     targetid = line_grid.objid ,
                     targetos = line_grid.osnum );
    if(!(status&1))
         {go_object = line_grid;
	  mat_type = md_env->md_env.matrix_type;
	  for(i=0;i<16;i++) matrix[i] = md_env->md_env.matrix[i];
         }

    /*|project the fixe point on the curve */

    status=om$send(msg = message GRvg.GRgenabsg(&msg,&mat_type,matrix, &ptr),
		   senderid = NULL_OBJID,
                   targetid = go_object.objid,
                   targetos = go_object.osnum);
    as$status(action = RET_STATUS);
    bc = (struct IGRbsp_curve *)ptr;

    BSmdstptcv(bc, pointdef->var.point_st.pt, &par.u, project, &length, &rc);
    if(rc != BSSUCC)
     {
      printf(" line at angle  can't compute parameter value\n");
      par.u = 0.5;  
     }
 
   /*| compute tangent at projection point */
  
    tangent = &tangent2[3];
    BScveval(bc, par.u, 1, tangent2, &rc);
    if(rc != BSSUCC){printf("ASlinangl can't evaluate tangent to curve \n");
		         return(OM_W_ABORT);}
    length = v_len(tangent);
    if(length !=0) {length = 1./length;
		    v_scale(tangent,length,linedef->var.line_st.v0);}
    v_equal(project,linedef->var.line_st.p0);
   }
 return(OM_S_SUCCESS);

}
/* Get and control the geometry of the parents */

ASlineangl_get_parents(num_p,list,
		       angle,linedef,pointdef,track_pt,vnorm,track,plane,md_env) 
IGRint num_p;
struct GRid *list;
IGRdouble *angle;
struct ret_struct *linedef,*pointdef;
IGRdouble *track_pt,*vnorm;
IGRboolean *track,*plane;
struct GRmd_env *md_env;
/*.ASget_parents*/
{
 IGRlong msg,status;
 IGRint i,ii;
 double *matrix = NULL;
 struct ret_struct obj_def[2];
 double length;

 if(num_p<3 || num_p>5) return(OM_W_ABORT);

 /*| is there a track point or a plane */

 *track=0;*plane=0;
 for(ii=0,i=3;i<num_p;i++,ii++)
   {
    status = om$send(msg = message NDnode.NDgive_structure
                                                 (&msg,&obj_def[ii],md_env) ,
		     senderid = NULL_OBJID,
                     targetid = list[i].objid,
                     targetos = list[i].osnum);
    as$status(action = RET_STATUS);

    if(obj_def[ii].type &  point_generic)
       {if(*track){printf("two track point for a parallel line");
                  return(OM_W_ABORT);}
        *track=i;v_equal(obj_def[ii].var.point_st.pt,track_pt);}

    else if(obj_def[ii].type & ref_generic)
       {if(*plane){printf("two plane for a parallel line");return(OM_W_ABORT);}
        *plane=i;
        vnorm[0]=obj_def[ii].var.ref_st.t[2];
        vnorm[1]=obj_def[ii].var.ref_st.t[6];
        vnorm[2]=obj_def[ii].var.ref_st.t[10];
	matrix  =obj_def[ii].var.ref_st.t;
       }
   }

/*| value of the parameter */

    status = om$send(msg = message NDnode.NDgive_structure
                                                         (&msg,pointdef,md_env),
		     senderid = NULL_OBJID,
                     targetid =  list[0].objid ,
                     targetos =  list[0].osnum );
    as$status(action = RET_STATUS);
    if(pointdef->type != double_type) return OM_W_ABORT;
    *angle = pointdef->var.root_pm_st.value / UNIT_ANGLE;


/*| data of the fix point */

    status = om$send(msg = message NDnode.NDgive_structure
                                                         (&msg,pointdef,md_env),
		     senderid = NULL_OBJID,
                     targetid = list[2].objid,
                     targetos = list[2].osnum);
    as$status(action = RET_STATUS);
    if(!(pointdef->type&point_generic)) return(OM_W_ABORT);

/*| data of the origin line */

   status = ASlineangl_vor(pointdef,linedef,list[1],md_env);
   as$status(action = RET_STATUS);


/*| If there is a plane as parent project the line in this plane */

    if(*plane)
      {
       /*| geometry projected */
       ASproject_in_xy(matrix,AS_IN_LINE,linedef->var.line_st.p0,
					 linedef->var.line_st.p0);
       ASproject_in_xy(matrix,AS_IN_LINE,linedef->var.line_st.p1,
					 linedef->var.line_st.p1);
       ASproject_in_xy(matrix,AS_IN_LINE | AS_VECTOR,linedef->var.line_st.v0,
					 	     linedef->var.line_st.v0);
       length = v_len(linedef->var.line_st.v0);
       if(length < 1.e-4) return (OM_W_ABORT);
       length = 1/length;
       v_scale(linedef->var.line_st.v0,length,linedef->var.line_st.v0);
       ASproject_in_xy(matrix,AS_IN_LINE,pointdef->var.point_st.pt,
					 pointdef->var.point_st.pt);
       if(*track)
       ASproject_in_xy(matrix,AS_IN_LINE,track_pt,track_pt);
      }
    return(OM_S_SUCCESS);
}


method NDplace(struct GRas *asso_lis; struct GRmd_env *md_env;
	       IGRchar *go_cnst_lis)

{
 IGRdouble *snap;
 IGRdouble workpoints[6],xx;
 IGRpoint work,vtrans,v0,vnorm;
 struct ret_struct linedef,pointdef, objdef;
 IGRdouble track_pt[3];
 IGRdouble length,angle,cs,ss,initial_length,eps,test,sign_rot,sin(),cos(),
	   d0,d1;
 IGRdouble one=1.;
 IGRlong status;
 IGRboolean track,plane;

    /* 
       pointer to the placement point. This placement point is define by the
       user or is taken in the instance of the graphic object if this object
       already exist (transform to assoc). The farest point from fix point
       is taken
     */

    if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
     {
      snap = (IGRdouble *) asso_lis->as_attr;
     }
    else
     {
      status = as$any_give_structure( go_grid = asso_lis->go_objid,
                         	      mod_env = md_env,
				      inst    = &objdef );
      as$status();
      v_sub(objdef.var.line_st.p0,pointdef.var.point_st.pt,work);
      d0 = v_len(work);
      v_sub(objdef.var.line_st.p1,pointdef.var.point_st.pt,work);
      d1 = v_len(work);
      if(d0>d1) {snap = objdef.var.line_st.p0;}
          else  {snap = objdef.var.line_st.p1;}
     }

/* geometry of the parents */
    ASlineangl_get_parents(asso_lis->num_parents,asso_lis->parents,
		 &angle,&linedef,&pointdef,track_pt,vnorm,&track,&plane,md_env);


    cs = cos(angle);
    ss = sin(angle);

/*
   The plane where the original line and the angle line are is defined by
   the 2 local vectors  parent_line.v0 , vtrans and by the normal vector 
   vnorm. This plane can by defined by different ways :

     - if a plane is in the parent list by this plane
     - by the original line and the fixe point if this point is not on the line
     - else by the original line and the second definition point (snap point)
       if this point is not on the line.
     - else the plane is not defined and an error message.
   
*/

    v_sub(pointdef.var.point_st.pt,snap,work);
    initial_length = v_len(work);
    eps = 1.e-8 + 1.e-8*initial_length;

    if(plane)
      {  /*| the plane is a parent */
	v_cross(vnorm, linedef.var.line_st.v0,vtrans);
    	length = v_len(vtrans);
	if(length<eps){printf("line at angle invalid plane definition\n");
		       return(OM_W_ABORT);}
        length = 1./length;
        v_scale(vtrans,length,vtrans);
      }
    else
      {
        v_dist_line(pointdef.var.point_st.pt,
		linedef.var.line_st.p0,linedef.var.line_st.v0,
		&length,vtrans);

        if(length < eps) 
	 {
	    /*| initial plane taken */
            v_dist_line(snap,
		        linedef.var.line_st.p0,linedef.var.line_st.v0,
		        &length,vtrans);
	
	    if(length < eps)
	     {
 printf("Warning\n");
 printf("The plane where the line at angle is suppose to be is not defined\n");
 printf("(the fix point and the placement point are on the original line).\n");
 printf("Default initialization : plane defined by original line and ");

             if(linedef.var.line_st.v0[1]>0.1 || linedef.var.line_st.v0[2]>0.1)
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
	   }
       length = 1./length;
       v_scale(vtrans,length,vtrans);
     }


/* The initial position of the angle line is the closest to the snap point */

    v_cross(linedef.var.line_st.v0,vtrans,me->vnorm);
    v_sub(snap,pointdef.var.point_st.pt,work);
    sign_rot = ss*cs*v_dot(work,vtrans)
		    *v_dot(work,linedef.var.line_st.v0);
    if(sign_rot < 0.) 
		{
		 v_neg(vtrans,vtrans);
		 me->flag = 1;
		}
	   else  me->flag = 0;

    v_comb(cs,linedef.var.line_st.v0,ss,vtrans,v0);



/* Is there a track_point ? In this case the choice between the 2 possible
   position of the ASlineangl will depend on its position.
*/

  if (track)
       {
	v_sub(track_pt,pointdef.var.point_st.pt,
              track_pt);
	test = cs * ss * v_dot(track_pt,linedef.var.line_st.v0)
	               * v_dot(track_pt,vtrans);
	if(test < 0.) me->flag = 1;
		 else me->flag = 0;
       }


/* extend of the line. Extend are positive to outside of line */


if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
    {
     me->d0= initial_length;
     me->d1= initial_length;
    }
else
   {

    v_sub( objdef.var.line_st.p0, pointdef.var.point_st.pt, work );
    me->d0 = -v_dot( v0, work );

    v_sub( objdef.var.line_st.p1, pointdef.var.point_st.pt, work );
    me->d1 = v_dot( v0, work );
   }

   xx = -me->d0;
   v_comb(one,pointdef.var.point_st.pt,xx,v0,workpoints);
   v_comb(one,pointdef.var.point_st.pt,me->d1,v0,workpoints+3);

 if(go_cnst_lis != NULL)
   {
    struct IGRpolyline geom;

    /*| Construct the G.O */
    geom.num_points = 2;
    geom.points     = workpoints;

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (char *) &geom;

    status = om$send(msg = message ASnode.ASconstruct_go
		   (asso_lis,md_env,go_cnst_lis, OPP_GR3dlineseg_class_id,TRUE),
	    	     targetid = my_id);
  }


/*
   add to node tree 
*/

    status = om$send(msg = message NDnode.NDconnect( asso_lis->num_parents,
					asso_lis->parents,NULL_GRID,ND_NEW) ,
		     targetid = my_id);
    as$status(action = RET_STATUS);


    return(OM_S_SUCCESS);

 }/* place */



/*
  compute_node

    compute a ASlineangl at a given angle (parameter) of  
    an other line (parent line). This line may have 3 or 4 parents.
    The first is the parameter, value of the angle.
    The second is the original line.
    The third is the fixe point.
    The forth if defined is the "track point".

*/

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count;struct GRid list[];
		      struct GRmd_env *md_env)

{
IGRpoint vnorm,vtrans,v0;
struct ret_struct linedef,pointdef;
IGRdouble track_pt[3];
IGRdouble  length,angle,cos(),sin(),fabs(),cs,ss,initial_length,eps,scal,test;
IGRlong status;
IGRboolean plane,track;


/* initial length of the line */

    initial_length = fabs(me->d1 + me->d0);
    eps = 1.e-8 + 1.e-8 * initial_length;


/* geometry of the parents */
    ASlineangl_get_parents(count,list,
		 &angle,&linedef,&pointdef,track_pt,vnorm,&track,&plane,md_env);

    cs = cos(angle);
    ss = sin(angle);

/*
   plane definition 
   The plane where the original line and the angle line are is defined by
   the 2 local vectors  parent_line.v0 , vtrans and by the normal vector 
   vnorm. This plane can by defined by different ways :

     - by the original line and the parent plane
     - if no plane as parent by the original line and the fix point if this
        point is not on the line
     - if the point is on the line by the original line and the last plane
        normal. 
*/
 
/* is there a track point or a plane */

    if(plane)
      {  /*| the plane is a parent */
	v_cross(vnorm, linedef.var.line_st.v0,vtrans);
    	length = v_len(vtrans);
	if(length<eps)
	 {if(fabs(angle)>1.e-3) printf
				   ("line at angle invalid plane definition\n");
          /* why not vx *? */
	  vtrans[0]=1;vtrans[1]=0;vtrans[2]=0;length=1;}
        v_scale(vtrans,length,vtrans);
      }
    else
      {
       v_dist_line(pointdef.var.point_st.pt,
		   linedef.var.line_st.p0,linedef.var.line_st.v0,
		   &length,vtrans);
       length = v_len(vtrans);
       if(length < eps) 
        { /*| initial plane taken */

	  v_cross(me->vnorm, linedef.var.line_st.v0,vtrans);
    	  length = v_len(vtrans);

	  if(length < eps)
	    {
	     if(fabs(angle)>1.e-3) printf
			  ("ASlineangl.compute_node error plane undefined \n");
	         /* why not vx *? */
	     vtrans[0]=1;vtrans[1]=0;vtrans[2]=0;length=1;
	     }
	}

       v_cross(linedef.var.line_st.v0,vtrans,vnorm);

       scal = v_dot(me->vnorm,vnorm);
       length = (scal >= 0.) ? 1./length : -1./length;
       v_scale(vtrans,length,vtrans);

       length = (scal >= 0.) ? 1. : -1.;
       v_scale(vnorm,length,me->vnorm);
       /* be carefull vnorm is not an unitar vector. */
      }


/* Is there a track_point ? In this case the choice between the 2 possible
   position of the ASlineangl depends on its position.
*/

  if (track)
       {
	v_sub(track_pt,pointdef.var.point_st.pt,
	      track_pt);
	test = cs * ss * v_dot(track_pt,linedef.var.line_st.v0)
	               * v_dot(track_pt,vtrans);
        if(test < 0.) v_neg(vtrans,vtrans);
       }


    if(me->flag &1) v_neg(vtrans,vtrans);
    v_comb(cs,linedef.var.line_st.v0,ss,vtrans,v0);

/* update the graphic associated object */


 v_equal(v0,linedef.var.line_st.v0);
 v_equal(pointdef.var.point_st.pt,linedef.var.line_st.p0);
 v_equal(pointdef.var.point_st.pt,linedef.var.line_st.p1);
 status = om$send(msg = message ASline.ASpostab(msg,md_env,&linedef),
 		   targetid = my_id);
 as$status(action = RET_STATUS);

 
 return(OM_S_SUCCESS);

}  /* compute_node */


/*
   ASlineangl.print
	This method prints the definition of the line
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  OMuint              icount;              /* Index for loop                  */
  struct ret_struct  my_def;              /* Definitions of the object       */
  struct ret_struct  ori_def;             /* Definitions of the object       */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  struct GRid list[2];
  IGRdouble dist,snap[3],w[3],fabs(),len,len_prov,one=1;
  IGRint status;
  IGRlong msg;

  /* Get the structure of the class */

  status = om$send(msg = message NDnode.NDgive_structure(&msg,&my_def,md_env),
		   targetid = my_id);
  as$status(action = RET_STATUS);


  /* Get the name of this object */

  as$printer_set_name(prefix="ANGL_LINE",
		      name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and symbology */

  as$printer_print_parents(list = list,
			   size = 2,
			   count = &count);
  as$printer_print_symb();

  /* Print the instances (snap point) */
  /* Use a point on the negative side of the line, p0 if possible */
  /* Control that the point is not on the original line           */


     if(me->d0 >1.e-6 ) len = me->d0;
else if(me->d1 >1.e-6 ) len = me->d1;
else if(me->d0 <1.e-6 ) len = -me->d0;
else if(me->d1 <1.e-6 ) len = -me->d1;
else                    len = 10;  

len_prov = -len + me->d0;

v_comb(one,my_def.var.line_st.p0,len_prov,my_def.var.line_st.v0,snap);

status = om$send(msg = message NDnode.NDgive_structure(&msg,&ori_def,md_env),
	         targetid = list[1].objid);
as$status(action = RET_STATUS);

v_dist_line(snap,ori_def.var.line_st.p0,ori_def.var.line_st.v0,&dist,w);

if (dist < 1.e-6 + 1.e-6*fabs(me->d0+me->d1)) 
       {len = 2*len;
	len_prov = -len + me->d0;
	v_comb(one,my_def.var.line_st.p0,len_prov,my_def.var.line_st.v0,snap);
       }
   

  for (icount=0; icount<3 ; icount++)
      fprintf(stream,"ptr[%d]=%lf;\n",icount,snap[icount]);

  /* Print the message */
     fprintf(stream,"send ASlineangl.place(%d,list,ptr) to %s;\n",count,name);

   /* Is there also extend to print.  */

    if(me->d0 != len || me->d1 != len )
      {
       ASprint_line_ext(stream, me->d0-len,me->d1-len ,name);
      }
    fprintf(stream,"\n");

  return(OM_S_SUCCESS);
}/* end print */


method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
    {
     *msg = MSSUCC;
     ex$message(buff=info->type,msgnumb=AS_I_LnAtAng);
     return(OM_S_SUCCESS);
    }


method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
IGRint i, j;
 
 *nb_tot = 5;
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
     geom_code[j]   = point_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 3 :
    {
     geom_code[j]   = point_generic | ref_generic;
     option_code[j] = 2;/* optional track point or plane or coord. system */
     break;
    }

   case 4 :
    {
     geom_code[j]   = point_generic | ref_generic;
     option_code[j] = 2;/* optional track point or plane or coord. system */
     break;
    }

  } /*  end switch  */

 *index_ref    = -1; 
 *index_plan   = -1; 
 *index_track  = -1; 

 /*| look for the index of the optional root */
 om$send( msg = message ASnode.ASget_opt_ind( 3,
          index_track, index_ref, index_plan ), targetid = my_id );

 return(OM_S_SUCCESS);
}

method ACcompute_node( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *prop,*size_inst,*no_go;
			   char *inst_save)
{
int siz_inst,status;
 siz_inst=sizeof(me->vnorm);
 OM_BLOCK_MOVE(  inst_save,me->vnorm, 
		siz_inst);
 status = om$send(msg =  message NDnode.NDcompute_node (msg,cn_type ,
					count,list, 
					md_env),
  		   targetid =my_id ); 
 as$status( );

 if (!( (me->state) & ND_OUT_OF_RT)&& *no_go != -1 )
      {*no_go += 1;}

 OM_BLOCK_MOVE( me->vnorm, inst_save,
		siz_inst);
 *size_inst += siz_inst ;
 return (1) ;
}
end implementation ASlineangl;
