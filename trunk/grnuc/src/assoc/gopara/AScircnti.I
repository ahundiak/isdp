/*-------------------------------
  AScircnt
  ch :14-juillet-86
--------------------------------*/



class implementation AScircnt;

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
 

/*       ----  AScircnt.NDplace  ----
  
     This method is used to place a no interactive circle which is centered
  around a point. The view vector is need when no directed vector is
  associed with the center point.

*/
method NDplace( struct GRas *asso_lis; struct GRmd_env *md_env; IGRchar *go_cnst_lis )
 {
  OMuint count;
  struct GRid *parent;
  IGRdouble *view_vect;
  struct ret_struct obj_struct, objdef, plandef;
  IGRdouble param_val;
  IGRdouble *origin;
  IGRdouble radius;
  IGRvector vv, vpz;
  IGRlong   msg, status;           /* Status returned by om                   */
  IGRint    i;
  IGRboolean exist;
  IGRdouble BSdotp();

  count = asso_lis->num_parents;
  parent = asso_lis->parents;

  if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
   {
    view_vect = (IGRdouble *) asso_lis->as_attr;
    exist = FALSE;
   }
  else
   {
    /*"le GOexist deja: ( %d, %d )\n",asso_lis->go_objid.objid,asso_lis->go_objid.osnum*/

    status = as$any_give_structure(go_grid = asso_lis->go_objid,
                       		   mod_env = md_env,
				   inst    = &objdef );
    as$status(action = RET_STATUS);
    vv[0] = objdef.var.circle_st.mat[2]; 
    vv[1] = objdef.var.circle_st.mat[6]; 
    vv[2] = objdef.var.circle_st.mat[10]; 
    view_vect = vv;
    exist = TRUE;
   }

  /*"count: %d, parents: %d, %d\n",count,parent->objid,(parent+1)->objid    */
  /*"view_vector: %lf, %lf, %lf\n",*view_vect,*(view_vect+1),*(view_vect+2) */

  if( count != 2 && count != 3 ) return(OM_W_ABORT);

  status = om$send(msg = message NDnode.NDgive_structure
						(&msg,&obj_struct,md_env),
              targetid = parent->objid);
  as$status(action = RET_STATUS);
  if(obj_struct.type != double_type) return OM_W_ABORT;
  param_val = obj_struct.var.root_pm_st.value;
  /*"valeur du parametre: %lf\n", param_val */

  status = om$send(msg = message NDnode.NDgive_structure
						(&msg,&obj_struct,md_env),
              targetid = (parent+1)->objid);
  as$status(action = RET_STATUS);

  origin = obj_struct.var.point_st.pt;
  if( param_val > 0 ) radius =  param_val;
  else		      radius = -param_val;

  me->r_signe = 1;
  if( count == 3 )
  {
   /*| depend d'un plan */
   status = om$send( msg = message NDnode.NDgive_structure
						      (&msg, &plandef, md_env), 
    	    targetid = (parent+2)->objid );
   as$status(action = RET_STATUS);

   /*| on se place dans plan */
   for(i=0;i<3;i++) vpz[i] = plandef.var.ref_st.t[4*i+2];

   /*| avoid to inverse the vz of an existing circle */
   if( BSdotp( &msg, vpz, view_vect ) > 0 ) me->r_signe = 1; /* same side */
   else					    me->r_signe = 0; /* opposite */

   view_vect[0] = plandef.var.ref_st.t[2];
   view_vect[1] = plandef.var.ref_st.t[6];
   view_vect[2] = plandef.var.ref_st.t[10];
   if(me->r_signe == 0) { for(i=0;i<3;i++) view_vect[i] = -view_vect[i]; }
   /*"r_signe: %d\n", me->r_signe */
   /*^pr_point("vz: ",view_vect); */
  }

 if(go_cnst_lis != NULL)
  {
   struct  IGRarc  geom;
   IGRint  ASconic_trans();
  
   /*| Prepare the geometry to construct the G.O */
   if( !ASconic_trans( &geom, origin, NULL, NULL, radius, view_vect, 3 ))
    {
      printf("AScircnt.place: Error in ASconic_trans\n");
      return(OM_W_ABORT);
    }
   if(count == 3)
    {
     /*| text the plane of the coord. system */
     for(i=0;i<9;i=i+4)
      {
       geom.rot_matrix[i]   = plandef.var.ref_st.t[i];
       geom.rot_matrix[i+1] = plandef.var.ref_st.t[i+1];
       geom.rot_matrix[i+2] = plandef.var.ref_st.t[i+2];
      }
     if(me->r_signe == 0) 
      { 
       for(i=0;i<9;i=i+4) 
        {
         geom.rot_matrix[i+1] = -geom.rot_matrix[i+1];
         geom.rot_matrix[i+2] = -geom.rot_matrix[i+2];
        }
      }
    }
   ((struct GRvg_construct *)go_cnst_lis)->geometry = (char *) &geom;
   status = om$send( msg = message ASnode.ASconstruct_go
		  (asso_lis, md_env, go_cnst_lis, OPP_GR3dcircle_class_id,TRUE),
                     targetid = my_id);
   as$status();
  }

  /*| add to the graph */
  status = om$send
             (msg      = message NDnode.NDconnect(asso_lis->num_parents,
                                 asso_lis->parents,NULL_GRID, ND_NEW),
              targetid = my_id);
  as$status();
 
  return(OM_S_SUCCESS);  
 }   /*           ----  end NDplace  ----                */




/*            ---- AScircnt.NDcompute_node ----

       This method calculates the new instance of the parallel circle

*/
method NDcompute_node (IGRlong *msg; IGRint cn_type;
		       int count; struct GRid *list;
		       struct GRmd_env *md_env )
{
 GRobjid newobjid;
 struct ret_struct obj_struct, cir_struct, plandef;
 IGRdouble param_val;
 struct GRpost_info post_info;
 IGRlong status;              /* Status returned by om                   */
 IGRint  i;
 struct  IGRarc  geom;
 IGRint  ASconic_trans();

 /*" count= %d\n", count */
 if( count != 2  && count != 3 ) return(OM_S_SUCCESS);
 
  status = om$send (msg = message NDnode.NDgive_structure
						(msg,&cir_struct,md_env),
              targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send(msg = message NDnode.NDgive_structure
						(msg,&obj_struct,md_env),
              targetid = list[0].objid);
  as$status(action = RET_STATUS);
  if(obj_struct.type != double_type) return OM_W_ABORT;
  param_val = obj_struct.var.root_pm_st.value;

  status = om$send(msg = message NDnode.NDgive_structure
						(msg,&obj_struct,md_env),
              targetid = list[1].objid,
              targetos = list[1].osnum);
  as$status(action = RET_STATUS);

  /*| Prepare the geometry to modify the G.O */
  geom.prim_axis = param_val;
  geom.sec_axis  = param_val;
  geom.start_angle = 0;
  geom.sweep_angle = 6.283185;
  for(i=0; i<3; i++) 
   {
    geom.origin[i]         = obj_struct.var.point_st.pt[i];
    geom.rot_matrix[3+4*i] = obj_struct.var.point_st.pt[i];
    geom.rot_matrix[12+i]  = 0;
   }
  geom.rot_matrix[15] = 1;
  if( count == 3 )
   {
    /*| Depends on a coord. system */
    status = om$send( msg = message NDnode.NDgive_structure
						        (msg, &plandef, md_env),
    	     targetid = list[2].objid,
    	     targetos = list[2].osnum);
   as$status(action = RET_STATUS);

    for(i=0;i<9;i=i+4)
     {
      geom.rot_matrix[i]   = plandef.var.ref_st.t[i];
      geom.rot_matrix[i+1] = plandef.var.ref_st.t[i+1];
      geom.rot_matrix[i+2] = plandef.var.ref_st.t[i+2];
     }
    if(me->r_signe == 0) 
     { 
      /*| invert vz and vy */
      for(i=0;i<9;i=i+4) 
       {
        geom.rot_matrix[i+1] = -geom.rot_matrix[i+1];
        geom.rot_matrix[i+2] = -geom.rot_matrix[i+2];
       }
     }
   }
  else
   {
    /*| Take the old matrix */
    for(i=0;i<9;i=i+4)
     {
      geom.rot_matrix[i]   = cir_struct.var.circle_st.mat[i];
      geom.rot_matrix[i+1] = cir_struct.var.circle_st.mat[i+1];
      geom.rot_matrix[i+2] = cir_struct.var.circle_st.mat[i+2];
     }
   }
 /*"vz: %lf, %lf, %lf\n",geom.rot_matrix[2],geom.rot_matrix[6],geom.rot_matrix[10]*/

 post_info.construct_flag = FALSE;
 status = om$send( msg = message GRconic.GRputarc( msg, md_env, &post_info,
                   &geom, &newobjid),
                   p_chanselect = &AS_to_comp);
 as$status();
 return(OM_S_SUCCESS);
}   /*   end NDcompute_node    */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDprint                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  int                 count;               /* Number of parents               */
  struct ret_struct   my_def;              /* Definitions of the object       */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  IGRlong             msg,status;          /* Status returned by om           */

  /* Get the structure of the class */

  status = om$send (msg = message NDnode.NDgive_structure(&msg,&my_def,md_env),
              targetid = my_id);
  as$status();

  /* Get the name of this object */

  as$printer_set_name( prefix="CENT_CIRCLE",
		       name= name );
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and  Symbology */

  as$printer_print_parents(count=&count);
  as$printer_print_symb();

  /* Print the instances (view vector) */
  /*"ptr[0]=%lf;\n",my_def.var.circle_st.mat[2]*/
  /*"ptr[1]=%lf;\n",my_def.var.circle_st.mat[6]*/
  /*"ptr[2]=%lf;\n",my_def.var.circle_st.mat[10]*/

  fprintf(stream,"ptr[0]=%lf;\n",my_def.var.circle_st.mat[2]);
  fprintf(stream,"ptr[1]=%lf;\n",my_def.var.circle_st.mat[6]);
  fprintf(stream,"ptr[2]=%lf;\n",my_def.var.circle_st.mat[10]);

  /* Print the message */

    fprintf(stream,"send AScircnt.place(%d,list,ptr) to %s;",count,name);
    fprintf(stream,"/* axis X %lf %lf %lf */\n\n",
                my_def.var.circle_st.mat[0],
                my_def.var.circle_st.mat[4],
                my_def.var.circle_st.mat[8]);


  return(OM_S_SUCCESS);
}/* end NDprint */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
    *msg = MSSUCC;
    ex$message (buff=info->type,msgnumb=AS_I_CtParCr);
    return(OM_S_SUCCESS);
}

method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
 IGRint i, j;
  IGRlong    status;              /* Status returned by om                   */
 
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
     geom_code[j]   = ref_generic;
     option_code[j] = 2;/* optional plane or ref */
     break;
    }
  } /*  end switch  */

 status = om$send( msg = message ASnode.ASget_opt_ind( 2,
                   index_track, index_ref, index_plan ), targetid = my_id);
 as$status();
 return(OM_S_SUCCESS);
}


end implementation AScircnt;

