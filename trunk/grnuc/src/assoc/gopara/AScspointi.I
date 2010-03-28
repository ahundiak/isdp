/*-------------------------------
  AScspoint
  momo :15-novembre -88
--------------------------------*/



class implementation AScspoint;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"

#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "madef.h"
#include "ndmacros.h"
#include "ASmsg.h"
#include "msmacros.h"

#define CARTESIAN   0
#define CYLINDRICAL 1
#define SPHERICAL   2

#define AS_DEBUG 1

extern GRclassid  OPP_GR3dpoint_class_id;
 
IGRdouble cos(), sin();


/*                  ----  AScspoint.NDplace  ----                            */

method NDplace( struct GRas *asso_lis; struct GRmd_env *md_env; IGRchar *go_cnst_lis )
 {
  IGRint                i;
  IGRlong               rc;
  OMuint 		count;
  struct GRid 		*parent;
  IGRlong   		msg, status;
  struct ret_struct 	obj_struct, objdef;
  IGRpoint		origin, old_work_pt, nw_work_pt;
  IGRdouble 		rotate[9], scale, param1, param2, param3;

  count = asso_lis->num_parents;
  parent = asso_lis->parents;

  if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
  {
     me->cs_type = (char) *asso_lis->as_attr;
     /*" int cs_type : %d\n", (int)me->cs_type */
  }
  else
  {
    /*"le GOexist deja: ( %d, %d )\n",asso_lis->go_objid.objid,
                                      asso_lis->go_objid.osnum*/

    status = as$any_give_structure(go_grid = asso_lis->go_objid,
                       		   mod_env = md_env,
				   inst    = &objdef );
    as$status(action = RET_STATUS);
    me->cs_type = (char)CARTESIAN;
  }

  /*"count: %d, parents: %d, %d, %d, %d\n",count,
                                           parent->objid,
                                           (parent+1)->objid,
                                           (parent+2)->objid,
                                           (parent+3)->objid */

  if( count != 4 ) return(OM_W_ABORT);

  status = om$send( msg = message NDnode.NDgive_structure( &msg, &obj_struct,
                                                           md_env),
                    targetid = parent->objid);
  as$status(action = RET_STATUS);
  if(obj_struct.type != double_type) return OM_W_ABORT;
  param1 = obj_struct.var.root_pm_st.value;

  status = om$send( msg = message NDnode.NDgive_structure( &msg, &obj_struct,
                                                           md_env),
                    targetid = (parent+1)->objid);
  as$status(action = RET_STATUS);
  if(obj_struct.type != double_type) return OM_W_ABORT;
  param2 = obj_struct.var.root_pm_st.value;

  status = om$send( msg = message NDnode.NDgive_structure( &msg, &obj_struct,
                                                           md_env),
                    targetid = (parent+2)->objid);
  as$status(action = RET_STATUS);
  if(obj_struct.type != double_type) return OM_W_ABORT;
  param3 = obj_struct.var.root_pm_st.value;

  status = om$send( msg = message NDnode.NDgive_structure( &msg,
                                                           &obj_struct,
                                                           md_env),
                    targetid = (parent+3)->objid);
  as$status(action = RET_STATUS);

  if(!(obj_struct.type & ref_generic)) 
   {
    printf("Bad root for the AScspoint\n");
    return(OM_W_ABORT);
   }

  /*"valeur du parametre: %lf\n", param1 */
  /*"valeur du parametre: %lf\n", param2 */
  /*"valeur du parametre: %lf\n", param3 */

  /*^pr_mat("coord syst", 4, 4, obj_struct.var.ref_st.t);*/

  if(go_cnst_lis != NULL)
  {
   struct  IGRpolyline geom;
  
   /*| Prepare the geometry to construct the G.O */
 
   origin[0] = obj_struct.var.ref_st.t[3];
   origin[1] = obj_struct.var.ref_st.t[7];
   origin[2] = obj_struct.var.ref_st.t[11];

   /*^ pr_point("origin: ",origin); */

   for(i=0;i<3;i++)
   {
     rotate[i]   = obj_struct.var.ref_st.t[i*4];
     rotate[i+3] = obj_struct.var.ref_st.t[1+i*4];
     rotate[i+6] = obj_struct.var.ref_st.t[2+i*4];
   }

   scale = obj_struct.var.ref_st.t[15];

   switch( (int)me->cs_type )
   {
     case CARTESIAN   : /*" the type of parameters is CARTESIAN\n" */
                        nw_work_pt[0] = param1;
                        nw_work_pt[1] = param2;
                        nw_work_pt[2] = param3;
                        break;

     case CYLINDRICAL : /*" the type of parameters is CYLINDRICAL\n" */
                        param1 = param1 * PI / 180.0;  
                        nw_work_pt[0] = param2 * cos(param1);
                        nw_work_pt[1] = param2 * sin( param1 );
                        nw_work_pt[2] = param3;
                        break;

     case SPHERICAL   : /*" the type of parameters is SPHERICAL\n" */
                        param1 = param1 * PI / 180.0;  
                        param2 = param2 * PI / 180.0;  
                        nw_work_pt[0] = param3 * cos(param1) * cos(param2);
                        nw_work_pt[1] = param3 * sin(param1) * cos(param2);
                        nw_work_pt[2] = param3 * sin(param2);
                        break;

     default          : printf(" type not correct\n");
                        return(OM_W_ABORT);

   }

   /*^ pr_point("local: ",nw_work_pt); */

   /* compute the corresponding point in the word cordinate system */   
   BSptnwtold( &rc, origin, rotate, &scale, nw_work_pt, old_work_pt );

   /*^pr_point("world: ", old_work_pt); */

   geom.num_points = 1;
   geom.points     = old_work_pt;

   /*| Construct the G.O */
   ((struct GRvg_construct *)go_cnst_lis)->geometry = (char *) &geom;

   status = om$send( msg      = message ASnode.ASconstruct_go
		( asso_lis, md_env, go_cnst_lis , OPP_GR3dpoint_class_id,TRUE),
                     targetid = my_id);

   as$status();

  }

  /*| add to the graph */
  status = om$send( msg      = message NDnode.NDconnect( asso_lis->num_parents,
                                                         asso_lis->parents,
                                                         NULL_GRID,
                                                         ND_NEW),
                    targetid = my_id);

  as$status();
 
  return(OM_S_SUCCESS);  

 }   /*           ----  end NDplace  ----                */


/*============================================================================*/

/*            ---- AScircnt.NDcompute_node ----

       This method calculates the new instance of the cspoint

*/

method NDcompute_node (IGRlong *msg; IGRint cn_type;
		       int count; struct GRid *list;
		       struct GRmd_env *md_env )
{
 IGRint			i;
 IGRlong 		rc;
 struct IGRpolyline	geom;
 IGRlong 		status;              
 GRobjid 		newobjid;
 struct GRpost_info 	post_info;
 struct ret_struct 	obj_struct;
 IGRpoint		origin, old_work_pt, nw_work_pt;
 IGRdouble 		rotate[9], scale, param1, param2, param3;

 /*" count= %d\n", count */
 if( count != 4 ) return(OM_W_ABORT);


  status = om$send( msg = message NDnode.NDgive_structure( msg, &obj_struct,
                                                           md_env),
                    targetid = list[0].objid);
  as$status(action = RET_STATUS);
  if(obj_struct.type != double_type) return OM_W_ABORT;
  param1 = obj_struct.var.root_pm_st.value;

  status = om$send( msg = message NDnode.NDgive_structure( msg, &obj_struct,
                                                           md_env),
                    targetid = list[1].objid);
  as$status(action = RET_STATUS);
  if(obj_struct.type != double_type) return OM_W_ABORT;
  param2 = obj_struct.var.root_pm_st.value;

  status = om$send( msg = message NDnode.NDgive_structure( msg, &obj_struct,
                                                           md_env),
                    targetid = list[2].objid);
  as$status(action = RET_STATUS);
  if(obj_struct.type != double_type) return OM_W_ABORT;
  param3 = obj_struct.var.root_pm_st.value;

  status = om$send( msg      = message NDnode.NDgive_structure( msg,
                                                                &obj_struct,
                                                                md_env),
                    targetid = list[3].objid,
                    targetos = list[3].osnum);
  as$status(action = RET_STATUS);

  /*"valeur du parametre: %lf\n", param1 */
  /*"valeur du parametre: %lf\n", param2 */
  /*"valeur du parametre: %lf\n", param3 */
  
  /*^pr_mat("coord syst", 4, 4, obj_struct.var.ref_st.t);*/

  /*| Prepare the geometry to modify the G.O */
 
  origin[0] = obj_struct.var.ref_st.t[3];
  origin[1] = obj_struct.var.ref_st.t[7];
  origin[2] = obj_struct.var.ref_st.t[11];

  for(i=0;i<3;i++)
   {
     rotate[i]   = obj_struct.var.ref_st.t[i*4];
     rotate[i+3] = obj_struct.var.ref_st.t[1+i*4];
     rotate[i+6] = obj_struct.var.ref_st.t[2+i*4];
   }

  scale = obj_struct.var.ref_st.t[15];

  switch( (int)me->cs_type )
  {

    case CARTESIAN   : /*" the type of parameters is CARTESIAN\n" */
                       nw_work_pt[0] = param1;
                       nw_work_pt[1] = param2;
                       nw_work_pt[2] = param3;
                       break;

    case CYLINDRICAL : /*" the type of parameters is CYLINDRICAL\n" */
                       param1 = param1 * PI / 180.0;  
                       nw_work_pt[0] = param2 * cos(param1);
                       nw_work_pt[1] = param2 * sin( param1 );
                       nw_work_pt[2] = param3;
                       break;

    case SPHERICAL   : /*" the type of parameters is SPHERICAL\n" */
                       param1 = param1 * PI / 180.0;  
                       param2 = param2 * PI / 180.0;  
                       nw_work_pt[0] = param3 * cos(param1) * cos(param2);
                       nw_work_pt[1] = param3 * sin(param1) * cos(param2);
                       nw_work_pt[2] = param3 * sin(param2);
                       break;

    default          : printf("AScspoint: type not correct\n");
                       return(OM_W_ABORT);

  }

   /*^ pr_point("local: ",nw_work_pt); */

  /* compute the corresponding point in the word cordinate system */   
  BSptnwtold( &rc, origin, rotate, &scale, nw_work_pt, old_work_pt );

   /*^ pr_point("global : ",old_work_pt); */

  geom.num_points = 1;
  geom.points     = old_work_pt;

  post_info.construct_flag = FALSE;

  status=om$send( msg          = message GRlinear.GRputpolyline( msg,
                                                                 md_env,
                                                                 &post_info,
                                                                 &geom,
                                                                 &newobjid),
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

  as$printer_set_name( prefix="CS_POINT",
		       name= name );
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and  Symbology */

  as$printer_print_parents(count=&count);
  as$printer_print_symb();

  /* Print the message */
  fprintf(stream,"str[0]=%d;",me->cs_type);
  fprintf(stream,"send AScspoint.place(%d,list,str) to %s;\n\n",count,name);

  return(OM_S_SUCCESS);

}/* end NDprint */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
     *msg = MSSUCC;
     ex$message(buff=info->type,msgnumb=AS_I_PtCooSys);
     return(OM_S_SUCCESS);
}

method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
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
     geom_code[j]   = parameter_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }

   case 2 :
    {
     geom_code[j]   = parameter_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }

   case 3 :
    {
     geom_code[j]   = ref_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
  } /*  end switch  */

 *index_track = -1;
 *index_ref   = -1;
 *index_plan  = -1;

 return(OM_S_SUCCESS);

}


end implementation AScspoint;

