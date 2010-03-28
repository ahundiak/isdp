class implementation angl_pm;



#include "OMmacros.h"
#include "expression.h"
#include "ASmatrix.h"
#include "madef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"

#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"

#include "gocmacros.h"



#define AS_DEBUG 1
#define UNIT_ANGLE 57.29577951     /* convertion radian -->print in degre */



struct expr_attr
  {
   IGRchar name[EXP_MAX_LEN];
   IGRchar syntax[EXP_MAX_LEN];
   IGRdouble value;
  };
   
/* ----------------------------------------------------------------------- 
 *  This function computes the angle between the points defined by pt0, 
 *  pt1 and pt2. Pt0 is the centered point and the angle is defined in a
 *  counterclockwise sense using the perpendicular vector vz.
 *  ANGLE DEFINED MODULUS 2PI
 * ------------------------------------------------------------------------*/
  IGRdouble point_angle(pt0, pt1, pt2, vz)
  IGRdouble *pt0, *pt1, *pt2;
  IGRdouble *vz;
  /*.point_anle*/
  {
   IGRdouble msg;
   IGRdouble kz,cs,ss,len,angle,atan2();
   IGRvector v1, v2, normal;

   MAsubvc( &msg, pt1, pt0, v1);
   MAlenvc( &msg, v1, &len);
   if( len == 0 ) return(0);
   len = 1./len;
   MAscalvc( &msg, &len, v1, v1);

   MAsubvc( &msg, pt2, pt0, v2);
   MAlenvc( &msg, v2, &len);
   if( len == 0 ) return(0);
   len = 1./len;
   MAscalvc( &msg, &len, v2, v2);

   MAdotvc( &msg, v1, v2, &cs);
   MAcrossvc( &msg, v1, v2, normal);
   MAlenvc( &msg, normal, &ss);
   /*"cs = %lf ,ss = %lf\n",cs ,ss */
   angle = atan2(ss,cs);

   /* angle modulo 2PI */

   MAdotvc( &msg, normal, vz, &kz); /* kz < 0 => take the conplementary angle*/
   if( kz < 0 ) angle = 2*PI - angle;
   modulo( &angle, 2*PI ); 
   return(angle);
  } /* point_angle */



/* ----------------------------------------------------------------------- 
 *  This function computes the angle between the lines defined by line1
 *  and line2. The angle is defined in a counterclockwise sense using the 
 *  perpendicular vector vz.
 *  ANGLE DEFINED MODULO PI
 * ------------------------------------------------------------------------*/

  IGRdouble line_angle(line1, line2, vz)
  struct ret_struct *line1,*line2;
  IGRdouble *vz;
  /*.line_angle*/
  {
   IGRdouble cs,ss,msg,angle,atan2(),kz;
   IGRpoint normal;
   IGRdouble *v1, *v2;

   v1 = line1->var.line_st.v0;
   v2 = line2->var.line_st.v0;

   MAdotvc( &msg, v1, v2, &cs);
   MAcrossvc( &msg, v1, v2, normal);
   MAlenvc( &msg, normal, &ss);
   /*"cs = %lf ,ss = %lf\n",cs ,ss */
   angle = atan2(ss,cs);

/* angle or PI - angle depending upon vz value */


   MAdotvc( &msg, normal, vz, &kz); /* kz < 0 => take the conplementary angle*/

   if (kz < 0) angle = 2*PI - angle;
   modulo( &angle, 2*PI ); 

   return(angle);
  } /* line_angle */


method NDplace(struct GRas *asso_lis; struct GRmd_env *md_env;
	       IGRchar *go_cnst_lis)

 {
  IGRlong msg;
  IGRdouble value, cs;
  IGRint i,j,plan;
  struct ret_struct rs[4];
  struct expr_attr ex_attr;
  struct angl_attr_def
   {
      IGRchar name[EXP_MAX_LEN];
      IGRvector vz;
   };
  struct angl_attr_def *angl_attr;
  IGRvector vv;
  IGRvector vx, vy, vzz;
  IGRdouble *vz = NULL;
  IGRdouble fabs();
  IGRint status;
  struct GRid *parents,*context;

  me->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  parents = asso_lis->parents;
  context = asso_lis->context;
  angl_attr = (struct angl_attr_def *) asso_lis->as_attr;

  for(i=0 ; i<asso_lis->num_parents ; i++)
   {
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

  for( i = 0 ; i < asso_lis->num_parents ; i++ )
   {
    status = om$send(msg=message NDnode.NDgive_structure(&msg,&(rs[i]),md_env),
             targetid = parents[i].objid,
             targetos = parents[i].osnum);
   }

  plan = 0;
  me->axe = 0;
  if( !(rs[0].type & conic_generic))
   {
    if( rs[asso_lis->num_parents - 1].type & ref_generic    )
     {
      vv[0] = rs[asso_lis->num_parents - 1].var.ref_st.t[2];
      vv[1] = rs[asso_lis->num_parents - 1].var.ref_st.t[6];
      vv[2] = rs[asso_lis->num_parents - 1].var.ref_st.t[10];
      vz = vv;
      plan = 1;
     }
    else
     {
      vz = angl_attr->vz;
     }
    /*^pr_point("vz",vz); */

     /* store infomation about orientaion (store the max orientation)
      *  1 --> x, 2 --> -x,
      *  3 --> y, 4 --> -y,
      *  5 --> z, 6 --> -z 
      * -----------------------------------------	*/

     if(fabs(vz[0]) > fabs(vz[1]) && fabs(vz[0]) > fabs(vz[2]))
      {
          if( vz[0] >= 0 ) me->axe = 1;
          else	           me->axe = 2;
      }
     else if(fabs(vz[1]) > fabs(vz[0]) && fabs(vz[1]) > fabs(vz[2]))
      {
          if( vz[1] >= 0 ) me->axe = 3;
          else	           me->axe = 4;
      }
     else if( vz[2] >= 0 ) me->axe = 5;
          else     	   me->axe = 6;
     /*" axe: %d\n", me->axe */
    } /* end if( asso_lis->num_parents > 1 ) */


/* compute the value of the pm */

   switch (asso_lis->num_parents - plan)
    {
     case 1 :	    /* the angle is a arc angle */

       	    /*| case 1 */
	    value = rs[0].var.circle_st.sweep_angle -
	            rs[0].var.circle_st.start_angle;

            for( i=0; i<3; i++ )
             {
	      j=i*4;
	      vx[i]  = rs[0].var.circle_st.mat[j];
	      vy[i]  = rs[0].var.circle_st.mat[j+1];
	      vzz[i] = rs[0].var.circle_st.mat[j+2];
	     }
            MAcrossvc( &msg, vx, vy, vv);
	    MAdotvc( &msg, vzz, vv, &cs);
	    if( cs < 0. )
             {
	      /*| Cas inverse */
	      value = PI + PI - value;
             }
            modulo( &value, 2*PI ); 

            break;


     case 2 :    /* the angle is between 2 lines */

   	    /*| case 2 */

	    if(!(rs[0].type & line_generic) || !(rs[1].type & line_generic))
	                      {printf("parent error \n");return(OM_W_ABORT);}

            value = line_angle(&(rs[0]), &(rs[1]), vz);
	    break;

     case 3 :            /* the angle is between 2 lines */
     
   	    /*| case 3 */

	    if(!(rs[0].type & point_generic) || !(rs[1].type & point_generic) ||
	       !(rs[2].type & point_generic)) 
                  {printf("parent error \n");return(OM_W_ABORT);}

            value = point_angle( rs[0].var.point_st.pt, rs[1].var.point_st.pt,
				 rs[2].var.point_st.pt, vz);
	    break;

    } /* end switch */

   value = value * UNIT_ANGLE;
   /*"value = %lf\n",value */

/* now expression.place */
if(angl_attr->name != NULL) strcpy(ex_attr.name, angl_attr->name);
else ex_attr.name[0] = 0;
ex_attr.value = value;
ex_attr.syntax[0] = 0;
asso_lis->as_attr = (IGRchar *) &ex_attr;
status = om$send( mode = OM_e_wrt_message,
	 	msg = message expression.NDplace(asso_lis,md_env,go_cnst_lis),
		targetid = my_id);
as$status(action = RET_STATUS);

/* KLUDGE on reaffecte le pointeur */
asso_lis->as_attr = (IGRchar *) angl_attr;

/* perform the add_node */

    status=om$send(msg = message NDnode.NDconnect
		 (asso_lis->num_parents,parents,NULL_GRID,ND_NEW),
		   targetid = my_id);

  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
}


/*----------------------------------------------------------------------------*/
method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count; struct GRid parent[] ;struct GRmd_env *md_env)

{
  IGRint  len1, len2;
  double  value, cs;
  char    pm[EXP_MAX_LEN+1];
  IGRint  plan;
  struct ret_struct rs[4];
  IGRint i, j; 
  IGRvector vx, vy, vzz, vv;
  IGRvector vz;
  IGRint status;
  double fabs();

  for( i = 0 ; i < count ; i++ )
    {
     status = om$send( msg = message NDnode.NDgive_structure
							 (msg,&(rs[i]),md_env),
              targetid = parent[i].objid,
              targetos = parent[i].osnum);
     as$status(action = RET_STATUS);
    }


  plan = 0;
  if( rs[count - 1].type & ref_generic )
   {
    /*| plane as root */
    vz[0] = rs[count - 1].var.ref_st.t[2];
    vz[1] = rs[count - 1].var.ref_st.t[6];
    vz[2] = rs[count - 1].var.ref_st.t[10];
    plan = 1;
    }
   else 
    {
     /* restore infomation about orientaion (store the max orientation)
      *  1 --> x, 2 --> -x,
      *  3 --> y, 4 --> -y,
      *  5 --> z, 6 --> -z 
      * -----------------------------------------	*/
     for(i=0; i<3; i++) vz[i] = 0;
     switch (me->axe)
      {
       case 0 :              break;
       case 1 :  vz[0] =  1; break;
       case 2 :  vz[0] = -1; break;
       case 3 :  vz[1] =  1; break;
       case 4 :  vz[1] = -1; break;
       case 5 :  vz[2] =  1; break;
       case 6 :  vz[2] = -1; break;
       default : 
        /*| bad stored info. about the orientation */
        return(1);
       } /* end switch */
     } /* end if plane */
   /*^pr_point("vz",vz);*/
   switch (count - plan)
    {
     case 1 :	    /* the angle is a arc angle */

       	    /*| case 1 */
	    value = rs[0].var.circle_st.sweep_angle -
	            rs[0].var.circle_st.start_angle;

            for( i=0; i<3; i++ )
             {
	      j=i*4;
	      vx[i]  = rs[0].var.circle_st.mat[j];
	      vy[i]  = rs[0].var.circle_st.mat[j+1];
	      vzz[i] = rs[0].var.circle_st.mat[j+2];
	     }
            MAcrossvc( msg, vx, vy, vv);
	    MAdotvc( msg, vzz, vv, &cs);
	    if( cs < 0. )
             {
	      /*| cas inverse */
	      value = PI + PI - value;
             }
            modulo( &value, 2*PI ); 

            break;


     case 2 :    /* the angle is between 2 lines */

   	    /*| case 2 */

	    if(!(rs[0].type & line_generic) || !(rs[1].type & line_generic))
                  {printf("parent error \n");return(1);}

            value = line_angle(&(rs[0]), &(rs[1]), vz);
	    break;

     case 3 :            /* the angle is between 2 lines */
     
   	    /*| case 3 */

	    if(!(rs[0].type & point_generic) || !(rs[1].type & point_generic) ||
	       !(rs[2].type & point_generic)) 
                  {printf("parent error \n");return(1);}

            value = point_angle( rs[0].var.point_st.pt, rs[1].var.point_st.pt, 
	    			 rs[2].var.point_st.pt, vz);
	    break;

    } /* end switch */

   value = value * UNIT_ANGLE;
  /*"value = %lf\n",value */

  if(fabs(me->value-value) > 1.e-10)
   {
    /*| update value */
    sprintf(pm,"%-10.2lf",value);

    len1 = strlen( pm )                 ;
    len2 = strlen( me->pretty_print )   ;
    if( len1 != len2 )
    {
     OMuint new_size;
     new_size = len1+1;
     OM_SET_DIMENSION( me->pretty_print, new_size) ;
    }

    strcpy( me->pretty_print, pm ) ;
    me->value = value;
    *msg = ND_COMP_SUCC;
    GR_NOTIFY_LISTENERS(&status,msg,GR_GEOM_MODIFIED);
   }
  else
   {
    /*| same value */
    *msg = ND_COMP_SAME;
   }

  return( OM_S_SUCCESS ) ;

} /* method compute_node */


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
  char                name[EXP_MAX_LEN];   /* Name of the object              */
  struct GRid my_grid;
  struct
   {
    IGRchar name[EXP_MAX_LEN];		   /* Name of the expression          */
    IGRvector vz;			   /* Normal vector		      */
   }  angl_attr;
  IGRint	      i;

  /* Get the name of this object */

  as$printer_set_name(prefix="ANGL_PM",
		      name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents */

  as$printer_print_parents(count=&count);

  /* Print the message */
   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;
   asprinter_get_di_name(my_grid,angl_attr.name);

  as$printer_print_dir(dir_name=angl_attr.name);

   for(i=0; i<3; i++) angl_attr.vz[i] = 0;
   switch (me->axe)
    {
     case 0 :
             break;

     case 1 : 
	     angl_attr.vz[0] =  1;      
	     break;
     case 2 :
	     angl_attr.vz[0] = -1;      
	     break;
     case 3 :
	     angl_attr.vz[1] =  1;      
	     break;
     case 4 :
	     angl_attr.vz[1] = -1;      
	     break;
     case 5 :
	     angl_attr.vz[2] =  1;      
	     break;
     case 6 :
	     angl_attr.vz[2] = -1;      
	     break;
     default :
             /*| bad stored info. about the orientation */
	     return(1);
	     
    } /* end switch */
    fprintf(stream,"angl_attr.vz[0] = %lf;\n", angl_attr.vz[0]);
    fprintf(stream,"angl_attr.vz[1] = %lf;\n", angl_attr.vz[1]);
    fprintf(stream,"angl_attr.vz[2] = %lf;\n", angl_attr.vz[2]);

    fprintf(stream,"strcpy(angl_attr.name, \"%s\");\n", angl_attr.name);

    fprintf(stream,"send angl_pm.place(%d,list,&angl_attr) to %s;\n\n",count,name);
  return(1);
}/* end print */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


method  NDattach_to_cs(IGRlong *msg; struct GRid cs_grid,contents;
                       struct GRid *as_grid; struct GRmd_env *md_env)
{
IGRlong status;
IGRint count;
struct GRid my_grid,*my_root,old_cs;
struct ret_struct rst;


/*| Look for a possible cycle in the graph   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  if(nd$dep_exist( l_root = &my_grid,  nb_root = 1,
                   l_tip  = &cs_grid,  nb_tip = 1 )) return (OM_S_SUCCESS);


/* Am I already attached to a coor sys ?*/

   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
					NULL,0,&my_root,0,OM_K_MAXINT,&count),
		    targetid = my_id);

 
   old_cs = my_root[count-1];
   status = om$send( msg = message NDnode.NDgive_structure
							 (msg,&rst,md_env),
              targetid = old_cs.objid,
              targetos = old_cs.osnum);
   as$status(action = RET_STATUS);


   if(rst.type & ref_generic)
    {
     status = om$send(msg = message NDnode.NDdisconnect
						  (1,&old_cs),
		      targetid = my_id);
     as$status();
    }

  

 status = om$send(msg = message NDnode.NDconnect(1,&cs_grid,NULL_GRID,ND_ADD),
		  targetid = my_id);
 as$status();

 as_grid->objid = my_id;
 as_grid->osnum = OM_Gw_current_OS;
 *msg = MSSUCC;
 return(OM_S_SUCCESS);
  
}


method  NDdetach_from_cs(IGRlong *msg; struct GRid cs_grid,contents;
                       struct GRid *as_grid; struct GRmd_env *md_env)
{
IGRlong status;
IGRint count;
struct GRid *my_root;
struct ret_struct rst;


  /* I don't change objid */
   as_grid->objid = my_id;
   as_grid->osnum = OM_Gw_current_OS;
   *msg = MSSUCC;

  /* get my roots  and detach from last one if it is the coor sys */

   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
					NULL,0,&my_root,0,OM_K_MAXINT,&count),
		    targetid = my_id);
   as$status(action = RET_STATUS);

   if( count == 0 ) return(OM_S_SUCCESS);

   status = om$send( msg = message NDnode.NDgive_structure
							 (msg,&rst,md_env),
              targetid = my_root[count-1].objid,
              targetos = my_root[count-1].osnum);
   as$status(action = RET_STATUS);
   if(!(rst.type & ref_generic)) return OM_S_SUCCESS;

   if(!IF_NULL_OBJID(cs_grid.objid)
    &&
      !IF_EQ_OBJID(cs_grid.objid,my_root[count-1].objid)) return(OM_S_SUCCESS);
      
       
  /* disconnect the source object from the AScontents */

     status = om$send( msg = message NDnode.NDdisconnect( 1, my_root+count-1 ),
                       targetid = my_id);
     as$status();

     return(OM_S_SUCCESS);
}

end implementation angl_pm;
