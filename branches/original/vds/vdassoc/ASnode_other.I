/* $Id: ASnode_other.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / ASnode_other.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ASnode_other.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
 * I/VDS
 *
 * TR 179419192.
 */
class implementation ASnode;
/*
   Ch    dec 87 :  update for the 1.1 release
   Rad          :  introduced clone object to avoid and temporary deletion 
                   of support only elements. - in method ASadd_opt
                   

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
#include "OMminimum.h"


#define AS_DEBUG 1

method ASadd_opt( struct GRid opt; IGRint flag; struct GRmd_env *md_env )

/* 
 * optional object : cs or track point
 *                   NULL_OBJID for DETACH case
 * flag : 0 for ref cs, 1 for track point
 */
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

/* RADHAI....*/

 OM_S_CHANSELECT *to_father,*to_children;
 struct GRid clone_grid;

/* ....RADHAI*/

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



/* RADHAI .... */

/*
 * Support only elements get deleted when all their children disconnect;  To
 * avoid this, we create a temporary clone object, and move the to_father
 * channel from my_id object to the clone object, so that the support only
 * elements are not left without any children during the process
 * At the end, we disconnect the clone object and delete it.
 */

   status = NDget_channel( &to_father, &to_children );
   as$status();

   status = om$construct(p_objid = &clone_grid.objid,
                         classid = OPP_NDnodein_class_id);
   as$status(action = RET_STATUS);

   clone_grid.osnum = OM_Gw_current_OS;
   status = om$send(msg      = message Root.move_chan(*to_father, my_id,
                                                      OM_Gw_current_OS, 
                                                      *to_father),
                    targetid = clone_grid.objid);
   as$status(action = RET_STATUS);

/* ....RADHAI */


/* commented out by RADHAI

  status=om$send(msg = message NDnode.NDdisconnect( 0, NULL), targetid = my_id);
  as$status( action = RET_STATUS );
*/

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

/* RADHAI...
 * The track pt. or ref cs to be detached from, is always the last parent ?? 
 * ...RADHAI */

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

  cp_type = 0;
  status = om$send( msg = message NDnode.NDs_compute_node(&msg,cp_type,md_env),
           targetid = my_id );
  as$status(action = RET_STATUS);

  /*  pas util car place (faire modif pour faire un postab) */

  status = om$send( msg = message NDnode.NDchange_node(NULL ),
           targetid = my_id );
  as$status(action = RET_STATUS);

/* RADHAI.... */
/* 
 * Now disconnect the clone object from its parents and delete it
 */

   status=om$send(msg          = message NDnode.NDnotify_disconnect(clone_grid),
                  senderid     = clone_grid.objid,
                  p_chanselect = to_father);

   as$status();
   status = om$send(msg      = message Root.delete(1),
                    targetid = clone_grid.objid);
   as$status();

/* ...RADHAI */

  return ( OM_S_SUCCESS );
}
		    
end implementation ASnode;
	 
