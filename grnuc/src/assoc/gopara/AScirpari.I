/*-------------------------------
  AScirpar
  ch :14-juillet-86
--------------------------------*/


class implementation AScirpar;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"

#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ASmsg.h"
#include "msmacros.h"

#define AS_DEBUG 1

extern GRclassid  OPP_GR3dcircle_class_id;
 
 
IGRdouble fabs();

 /*           ----  AScirpar.NDplace  ----                   */

method NDplace( struct GRas *asso_lis;struct GRmd_env *md_env; IGRchar *go_cnst_lis )
{
 OMuint count;
 struct GRid  *parent;
 struct ret_struct obj_struct,objdef;
 IGRdouble param_val;
 IGRlong msg,status;
 IGRpoint  pt_c;
 IGRdouble radius, rad, *snap_pt = NULL, *origin, *rad_root;
 IGRvector vv, vrad, v;
 IGRint i;
 IGRboolean MAcrrcconstr();
 IGRboolean MAsubvc();
 IGRboolean MAcrossvc();
 IGRboolean MAlenvc();

 count = asso_lis->num_parents;
 parent = asso_lis->parents;
 if( count != 2 ) return(OM_W_ABORT);

 if( !(IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID )))
  {
   /*"le GO exist: ( %d, %d )\n",asso_lis->go_objid.objid,asso_lis->go_objid.osnum */

   status = as$any_give_structure(go_grid = asso_lis->go_objid,
                       		  mod_env = md_env,
				  inst    = &objdef );
   as$status(action = RET_STATUS);
   pt_c[0] = objdef.var.circle_st.cent_p[0] + objdef.var.circle_st.rad;
   pt_c[1] = objdef.var.circle_st.cent_p[1];
   pt_c[2] = objdef.var.circle_st.cent_p[2];
   asso_lis->as_attr = (IGRchar *) pt_c;
  }

 if( asso_lis->as_attr != NULL )
  {
   snap_pt   = (IGRdouble *) asso_lis->as_attr;
  }

  /*"count: %d, parents: %d, %d\n",count,parent->objid,(parent+1)->objid */
 status=om$send( msg = message NDnode.NDgive_structure(&msg,&obj_struct,md_env),
	  targetid = parent[0].objid,
	  targetos = parent[0].osnum );
 as$status(action = RET_STATUS);
 if(obj_struct.type != double_type) return OM_W_ABORT;
 param_val = obj_struct.var.root_pm_st.value;


 status=om$send( msg = message NDnode.NDgive_structure(&msg,&obj_struct,md_env),
	  targetid = parent[1].objid,
	  targetos = parent[1].osnum );
 as$status(action = RET_STATUS);


/*
    convertion of this object into b_spline forme. Initialization
    of its IGE data.
*/

 origin = obj_struct.var.circle_st.cent_p;
 rad_root = &obj_struct.var.circle_st.rad;

 vv[0] = obj_struct.var.circle_st.mat[2];
 vv[1] = obj_struct.var.circle_st.mat[6];
 vv[2] = obj_struct.var.circle_st.mat[10];

 if( asso_lis->as_attr != NULL )
  {
   MAsubvc( &msg,  origin, snap_pt, v );
   MAcrossvc( &msg, vv, v, vrad );
   MAlenvc( &msg, vrad, &rad );
   if( rad > fabs(*rad_root))
     {
      /*|  outside  */
      radius = fabs(*rad_root) + fabs(param_val);
      if( param_val >= 0 ) me->p_signe =  1;
      else 		   me->p_signe = -1;
     }
   else
     {
      /*|  inside  */
      if( param_val >= 0 ) me->p_signe = -1;
      else 		   me->p_signe =  1;
      radius = fabs(*rad_root) - fabs(param_val);
     }
  }
 else
  {
   me->p_signe = 1;
   radius = *rad_root + param_val;
  }


 if(go_cnst_lis != NULL)
  {
   struct  IGRarc  geom;
  
   /*| Prepare the geometry to construct the G.O */
   geom.prim_axis = radius;
   geom.sec_axis  = radius;
   geom.start_angle = 0;
   geom.sweep_angle = 6.283185;
   for(i=0;i<3 ;i++) geom.origin[i]     = origin[i];
   for(i=0;i<16;i++) geom.rot_matrix[i] = obj_struct.var.circle_st.mat[i];

   ((struct GRvg_construct *)go_cnst_lis)->geometry = (char *) &geom;
   /*| contruct the graphic object */
   status = om$send( msg = message ASnode.ASconstruct_go
		 ( asso_lis, md_env, go_cnst_lis, OPP_GR3dcircle_class_id,TRUE),
                     targetid = my_id);
   as$status();
  }

  status = om$send
             (msg      = message NDnode.NDconnect
                                 (asso_lis->num_parents,
                                  asso_lis->parents,NULL_GRID,ND_NEW),
	      targetid = my_id);
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
}    /*              ---- NDplace ----          */




/*            ---- AScirpar.NDcompute_node ----

       This method calculates the new instance of the parallel circle

*/
method NDcompute_node (IGRlong *msg;IGRint cn_type;
		       int count; struct GRid *list; struct GRmd_env *md_env )
{
 GRobjid newobjid;
 struct ret_struct obj_struct; 
 IGRdouble param_val, radius;
 IGRvector vv;
 struct GRpost_info post_info;
 IGRlong    status;              /* Status returned by om                   */
 struct  IGRarc  geom;
 IGRint i;


 /*"count= %d\n", count */

 if( count != 2 ) return(OM_W_ABORT);

 status=om$send(msg = message NDnode.NDgive_structure(msg,&obj_struct,md_env), 
	  targetid = list[0].objid,
	  targetos = list[0].osnum );
 as$status(action = RET_STATUS);
 if(obj_struct.type != double_type) return OM_W_ABORT;
 param_val = obj_struct.var.root_pm_st.value;


 status=om$send(msg = message NDnode.NDgive_structure(msg,&obj_struct,md_env), 
	  targetid = list[1].objid,
	  targetos = list[1].osnum );
 as$status(action = RET_STATUS);


 radius = fabs(obj_struct.var.circle_st.rad) + (IGRdouble) me->p_signe * param_val;

 vv[0] = obj_struct.var.circle_st.mat[2];
 vv[1] = obj_struct.var.circle_st.mat[6];
 vv[2] = obj_struct.var.circle_st.mat[10];
 /*^pr_point("vz: ",vv); */
  
 /*| Prepare the geometry to modify the G.O */
 geom.prim_axis = radius;
 geom.sec_axis  = radius;
 geom.start_angle = 0;
 geom.sweep_angle = 6.283185;
 for(i=0; i<3 ; i++) geom.origin[i]     = obj_struct.var.circle_st.cent_p[i];
 for(i=0; i<16; i++) geom.rot_matrix[i] = obj_struct.var.circle_st.mat[i]; 

 post_info.construct_flag = FALSE;

 status = om$send( msg = message GRconic.GRputarc( msg, md_env, &post_info,
                   &geom, &newobjid),
                   p_chanselect = &AS_to_comp);
 as$status();

 return(OM_S_SUCCESS);
}   /*   end NDcompute_node    */


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

  IGRshort un = 1, trois = 3;
  IGRpoint pt,v;
  IGRdouble mat[9];
  IGRlong    msg,status;           /* Status returned by om                   */

  /*| Get the structure of the class */

  status = om$send
             (msg      = message NDnode.NDgive_structure(&msg,&my_def,md_env),
              targetid = my_id);
  as$status();

  /*| Get the name of this object */

  as$printer_set_name(prefix="PARA_CIRCLE",name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and the Symbology */

  as$printer_print_parents(count=&count);
  as$printer_print_symb();

    /*| Print the snap point (point on circle)*/
    pt[0] = my_def.var.circle_st.rad;
    pt[1] = 0;
    pt[2] = 0;
    /*  translate the point from world to local coord  */
    mat4_3( my_def.var.circle_st.mat, mat );
    MAmulmx( &msg, &trois, &trois, &un, mat, pt, v );
    MAaddvc( &msg, v, my_def.var.circle_st.cent_p, pt );  

    for(icount=0;icount<3;icount++)
    fprintf(stream,"ptr[%d]=%lf;\n",icount,pt[icount]);

    /*| Print the message */
    fprintf(stream,"send AScirpar.place(%d,list,ptr) to %s;\n\n",count,name);
  return(OM_S_SUCCESS);
}/* end NDprint */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
     *msg = MSSUCC;
     ex$message(buff=info->type,msgnumb=AS_I_CncCr);
     return(OM_S_SUCCESS);
}

method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
 IGRint i, j;

 *nb_tot = 2;
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
     geom_code[j]   = conic_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
//   case 2 :
//    {
//     geom_code[j]   = ref_generic;
//     option_code[j] = 2;/* optional */
//     break;
//    }
  } /*  end switch  */

 *index_ref   = -1;
 *index_track = -1;
 *index_plan  = -1;  

 /*| look for the index of the optional root */
// status = om$send( msg = message ASnode.ASget_opt_ind( 2,
//	  index_track, index_ref, index_plan ), targetid = my_id );

 return(OM_S_SUCCESS);
}


end implementation AScirpar;
