class implementation ASnode;
/*
   Ch    dec 87 :  update for the 1.1 release

   This is the implementation file for all the messages declared in
   ASnode.S.

*/


#include "AS_status.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "grerr.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"
#include "ndmacros.h"
#include "griodef.h"


#define AS_DEBUG 1

  /*
    construct and connect the graphic image of an associative
  */
method ASconstruct_go( struct GRas *asso_lis; struct GRmd_env *md_env;
		       IGRchar *go_cnst_lis; GRclassid go_classid;
		       IGRboolean altconstruct)
{
 long status,msg;
 IGRlong index;
 struct GRid my_grid;
    
 /*| construct the graphic object */
 if(altconstruct)
  {
   /*| graphic object construct with GRaltconstruct */
   status = om$construct( msg = message GRgraphics.GRaltconstruct
					((struct GRvg_construct *)go_cnst_lis),
                        classid = go_classid,
                        p_objid = &(asso_lis->go_objid.objid));
  }
 else
  {
   /*| graphic object construct with GRconstruct */
   status = om$construct( msg = message GRgraphics.GRconstruct
					((struct GRvg_construct *)go_cnst_lis),
                        classid = go_classid,
                        p_objid = &(asso_lis->go_objid.objid));
  }
 as$status(action = RET_STATUS);
 asso_lis->go_objid.osnum = OM_Gw_current_OS;

 /*"go construct: %d, %d\n",asso_lis->go_objid.objid,asso_lis->go_objid.osnum */
 
  /*| connect together the graphic and the associative object */
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  index = 0;
  status = om$send( msg = message GRconnector.GRrigidconn( &msg, &my_grid,
  	            &index ), targetid = asso_lis->go_objid.objid,
		    targetos = asso_lis->go_objid.osnum );
  as$status(action = RET_STATUS);
 if( msg == MSSUCC ) return(OM_S_SUCCESS);
 if( msg == GRRIGIDEXISTS ) printf("Il existe deja un rigid owner\n");
 if( msg == GRNOCONNECT )   printf("Erreur du aux flexibles owners\n");
 if( msg == MSFAIL) 	       printf("error in the GRrigidconn\n");
 return(OM_W_ABORT);
}

method ASpossible_parent( IGRint ifrom,ito, *geom_code, *option_code,
		    *track_point, *ref, *plan, *nb_return, *nb_tot)  
{
 return(OM_W_ABORT);
}

		
 method ASget_opt_ind( IGRint index0, *index_track, *index_ref, *index_plan)
 {
  struct GRid *list;
  IGRint index, count, i;
  struct ret_struct obj_def;
  IGRlong msg;

  *index_track = -1;
  *index_ref   = -1;
  *index_plan  = -1;

  /*"index0= %d\n", index0 */
  om$send( msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF, NULL,
           0, &list, index0, OM_K_MAXINT, &count ), targetid = my_id );

  /*"number of roots returned: %d\n", count */
  for( i = 0, index = index0; index < count; index++, i++ )
   {
    /*"index: %d, objid: %d\n", index, list[i].objid*/
    om$send( msg = message NDnode.NDgive_structure(&msg, &obj_def, NULL ),
             targetid = list[i].objid, targetos = list[i].osnum );

    if( obj_def.type & point_generic )
     {
      /*| the root is a track point */
      *index_track = index;
     }
    else if( obj_def.type & ref_generic )
     {
      /*| the root is a ref */
      *index_ref = index;
     }
    else
     {
      /*| bad object */
      return(OM_W_ABORT);
     }
   } /* end for */

 /*"index track: %d, ref: %d, plan: %d\n",*index_track,*index_ref,*index_plan*/

 return(OM_S_SUCCESS);
}


method ASadd_opt( struct GRid opt; IGRint flag; struct GRmd_env *md_env )
{
 IGRint *geom_code, *option_code, nb_return, nb_tot, i, opt_flag;
#define MAX_DIM 5
 IGRint tab1[MAX_DIM], tab2[MAX_DIM];
 struct GRid go_grid, *list, my_grid;
 struct GRid context[MAX_DIM], roots[MAX_DIM], *p_roots, *p_context;
 struct GRas assoc_lis;
 IGRlong status,msg;
 IGRint nb_parents;
 IGRint *index_opt = NULL, index_point, index_ref, index_plan, test_flag = 0;
 IGRint cp_type;
 IGRboolean roots_alloc ;
 OM_S_CHANSELECT *to_father,*to_children;
 struct GRid clone_grid;


  geom_code   = tab1;
  option_code = tab2;
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  if( !IF_NULL_OBJID( opt.objid ))
   {
    struct ret_struct struct_node;     

    /*"opt: ( %d, %d )\n", opt.objid, opt.osnum */

    as$make_source( go_grid = opt, as_grid = &opt);

    status=om$send(msg=message NDnode.NDgive_structure(&msg,&struct_node,md_env), 
             targetid = opt.objid, targetos = opt.osnum );
     as$status(action = RET_STATUS);
    if( struct_node.type & point_generic )
     {
      /*| the root is a track point */
      test_flag = point_generic;
      index_opt = &index_point;
     }
    else if( struct_node.type & ref_generic )
     {
      /*| the root is a ref */
      test_flag = ref_generic;
      index_opt = &index_ref;
     }
    else
     {
      /*| bad object */
      return(OM_S_SUCCESS);
     }

    /*| Look for a possible cycle in the graph   */
    
    if(nd$dep_exist( l_root = &my_grid,  nb_root = 1, 
                     l_tip  = &opt,  nb_tip = 1 ))
     {
      /*| There is a cycle */
      return(OM_S_SUCCESS);
     }
    /*| There is no cycle */
   }
  status = om$send( msg = message ASnode.ASpossible_parent( 0, MAX_DIM-1, geom_code, 
           option_code, &index_point, &index_ref, &index_plan, &nb_return, 
           &nb_tot ), targetid = my_id );
  as$status(action = RET_STATUS);

  if( nb_tot > MAX_DIM )
   { 
    geom_code   = (IGRint *) om$malloc( size = nb_tot * sizeof(IGRint));
    option_code = (IGRint *) om$malloc( size = nb_tot * sizeof(IGRint));
    if( geom_code == 0 || option_code == 0 ) return( OM_S_SUCCESS );

    status=om$send(msg = message ASnode.ASpossible_parent( 0, nb_tot, geom_code,
	     option_code, &index_point, &index_ref, &index_plan, &nb_return, 
	     &nb_tot ), targetid = my_id );
    as$status(action = RET_STATUS);
   }

  for(i=0;i<nb_return;i++) 
    {
     /*"i: %d, geom_code: %d, option_code:%d\n",i,geom_code[i],option_code[i]*/
    }
  /*"index point: %d, ref: %d, plan: %d\n",index_point,index_ref,index_plan */
  if( IF_NULL_OBJID( opt.objid ))
    {
     /*| when suppress we used flag to know the type  */
     if( flag == 1 )
     {
      /*| track_point */
      test_flag = point_generic;
      index_opt = &index_point;
     }
    else if( flag == 0 )
     {
      /*| ref. */
      test_flag = ref_generic;
      index_opt = &index_ref;
      }
   else
     {
      /*| bad object */
      return(OM_S_SUCCESS);
      }
    } 
  /*" test_flag: %d\n",test_flag */
  opt_flag = 0;
  for( i = 0; i < nb_return; i++ ) 
    if(geom_code[i] & test_flag && option_code[i] == 2) opt_flag = 1;

  if( nb_tot > MAX_DIM )
   { 
    om$dealloc(ptr = geom_code); 
    om$dealloc(ptr = option_code);
    }

  if( opt_flag == 0 ) 
      {
       /*| object without possible option (ref., plan, track point)*/
       return( OM_S_SUCCESS );
      }
  /*| possible root */

  if(IF_NULL_OBJID(opt.objid) && (*index_opt) == -1 )
         return(OM_S_SUCCESS);/* suppress a no existant root */

  /*  We ask to the parents, we disconnect the object and reconnect with or
   *  without the new root (ref. or track point). 
   */

  status = om$send(msg= message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
				 NULL, 0, &list, 0, OM_K_MAXINT, &nb_parents),
                   targetid = my_id );
  as$status( action = RET_STATUS );
  /*"nb_parents: %d\n", nb_parents */

  if(nb_parents < MAX_DIM)
   {
    p_roots = roots;
    p_context = context;
    roots_alloc = FALSE;
   }
  else
   {
    /*" Dynamic space allocation of: %d\n", nb_parents+1 */
    p_roots = (struct GRid *) om$malloc(size = 2 * (nb_parents+1) * sizeof(struct GRid));
    if(p_roots == NULL)
     {
      printf("Error in dynamic space allocation in ASadd_opt\n");
      return(OM_W_ABORT);
     }
    p_context = &p_roots[nb_parents+1];
    roots_alloc = TRUE;
   }

  /*| test if the root is not already a root */
  for( i = 0 ; i < nb_parents ; i++ )
   {
    if( IF_EQ_OBJID( opt.objid, list[i].objid ))
     {
      if(roots_alloc)
       {
        /*| Dealloc of p_roots */
        om$dealloc(ptr = p_roots);
       }
      return(OM_S_SUCCESS);
     }
    p_roots[i] = list[i];
    p_context[i].objid = NULL_OBJID; /* Il faudrait retouver le context */
   }

/*
  status=om$send(msg = message NDnode.NDdisconnect( 0, NULL), targetid = my_id);
  as$status( action = RET_STATUS );
*/
       status = NDget_channel( &to_father, &to_children );
       as$status();

       status = om$construct(p_objid = &clone_grid.objid,
                             classid = OPP_NDnodein_class_id);
       as$status(action = RET_STATUS);

       clone_grid.osnum = OM_Gw_current_OS;
       status = om$send(msg = message Root.move_chan(*to_father, my_id,
                                                     OM_Gw_current_OS,
                                                     *to_father),
                        targetid = clone_grid.objid);
       as$status(action = RET_STATUS);


/*^
  for( i = 0 ; i < nb_parents; i++ )
       printf("parents: ( %d, %d )\n",p_roots[i].objid,p_roots[i].osnum);
*/
  if(!IF_NULL_OBJID(opt.objid))
   {
    /*" opt: ( %d, %d )\n", opt.objid, opt.osnum */

    if( *index_opt == -1 )
     {
      *index_opt = nb_parents;
      nb_parents +=1;
     }

    /*"index_opt: %d\n", *index_opt */
    p_roots[*index_opt] = opt;
    p_context[*index_opt].objid = NULL_OBJID;
   }
  else nb_parents -= 1; /*  ATTENTION A LA MARCHE  */

  /*" nb_parents: %d\n", nb_parents */
  
  {
   
    /*| We find the graphic object linked with the associative object and
        we deconnect the associative source object to its graphic object */

   status = om$send(msg = message NDnode.ASreturn_go( &go_grid,NULL,NULL),
		    targetid = my_id);
   as$status(action = RET_STATUS);
   /*"obect_id: ( %d, %d )\n",go_grid.objid,go_grid.osnum */
  }

  assoc_lis.num_parents = nb_parents;
  assoc_lis.parents     = p_roots;
  assoc_lis.context     = context;
  assoc_lis.go_objid    = go_grid;
  assoc_lis.as_attr     = 0;
 
  status = om$send( msg = message NDnode.NDplace( &assoc_lis, md_env, NULL ), 
           targetid = my_id );
  as$status(action = RET_STATUS);

  if(roots_alloc)
   {
    /*| dealloc of p_roots */
    om$dealloc(ptr = p_roots);
   }


  /* Delete the clone object as connections are established again. */
     
  status=om$send(msg = message NDnode.NDnotify_disconnect(
                                               clone_grid),
                senderid     = clone_grid.objid,
                p_chanselect = to_father);

  as$status();
  status = om$send(msg = message Root.delete(1),
                  targetid = clone_grid.objid);
  as$status();

  cp_type = 0;
  status = om$send( msg = message NDnode.NDs_compute_node(&msg,cp_type,md_env),
           targetid = my_id );
  as$status(action = RET_STATUS);

  /*  pas util car place (faire modif pour faire un postab) */

  status = om$send( msg = message NDnode.NDchange_node(NULL ),
           targetid = my_id );
  as$status(action = RET_STATUS);
  return ( OM_S_SUCCESS );
}
		    
end implementation ASnode;
	 
