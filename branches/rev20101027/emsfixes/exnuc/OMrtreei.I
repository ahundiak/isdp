/* $Id: OMrtreei.I,v 1.2 2001/01/13 00:42:07 hans Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:        emsfixes/exnuc/OMrtreei.I
 *
 * Description:
 *	Overwritten the constr_rtree & delete to handle a regeneration
 *	process of the corrupted Range rtree.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: OMrtreei.I,v $
 *	Revision 1.2  2001/01/13 00:42:07  hans
 *	SP16 modifications
 *	
 *	Revision 1.1  2001/01/12 23:20:36  hans
 *	SP16 modifications
 *
# Revision 1.1  2000/11/12  18:31:18  pinnacle
# Created: vds/emsfixes/exnuc/OMrtreei.I by impd252 for Service Pack
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      11/12/00   adz          File Creation
 *************************************************************************/

class implementation  OMrtree ;
								/*+meincs*/
#include "OMDB.h"
#include "OMindex.h"						/*-meincs*/

extern int DB_rtree_cluster_obj();
extern int DB_rtree_create();
extern int DB_rtree_delete();
extern int DB_rtree_deltree();
extern int DB_rtree_find_key();
extern int DB_rtree_get_status();
extern int DB_rtree_insert();
extern int DB_rtree_put_op();
extern int DB_rtree_replace();
extern int DB_rtree_search();
extern int DB_rtree_seed();
extern int DB_rtree_send();
extern int som_build_internal_classlist();

extern int OM_Gi_record_ops;

%safe
static	VD_OMrtree_delete = 0 ;
%endsafe

void VDsetOMrtree_delete()        { VD_OMrtree_delete = 1 ; }
void VDresetOMrtree_delete()      { VD_OMrtree_delete = 0 ; }
int  VDgetOMrtree_delete()        { return VD_OMrtree_delete ; }

								/*+public*/
method OMrtree_constr( unsigned char tree_type; int *ret )      /*+medesc*/

/*

Description:
	    This method calls DB_rtree_create to construct rtree.

Arguments:
	    Input
	    -----
            unsigned char tree_type 	type of rtree to be constructed

	    Output
	    ------
	    int *ret			return status from DB_rtree_create

*/								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{

ME.OMrtree->objid = my_id;
*ret = DB_rtree_create( tree_type, ME.OMrtree->tree_page );

if( VD_OMrtree_delete ) ME.OMrtree->count = 0 ;
return( OM_S_SUCCESS );
}								/*-public*/


#ifdef	NOT_NEEDED


								/*+public*/
method add( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret )							/*+medesc*/

/*

Description:
	    This method adds an entry to the rtree.

Arguments:
	    Input
	    -----
            OM_p_KEY_DESC p_key      The address of a data structure
				     which contains the key to be added
            OM_p_OBJID	  p_objid    The address of the objid to be
				     inserted along with the key
            int (*user_compare)()    not used in rtree

	    Output
	    ------
	    int *ret	    	     return status from DB_rtree_insert

*/								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{

if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  if (OM_Gf_verbose_warning) printf(" NOTTREEROOT : %d - %d \n", my_id,OM_Gw_current_OS );
  return(OM_E_NOTTREEROOT);
  }

*ret = DB_rtree_insert( ME.OMrtree->tree_page, p_key->key.p_3ddbl, p_objid );
if ( *ret == DB_SUCCESS )
	{		  /* Increment number of keys in tree by 1 */
	(ME.OMrtree->count)++;
        if (OM_Gi_record_ops)
	  {
	  DB_rtree_put_op(*p_objid, OM_R_ADD, OM_Gw_current_OS);
	  }
	}
else {
  if( OM_Gf_verbose_warning )
	printf(" B_rtree_insert failed : %d - %d\n", my_id,OM_Gw_current_OS );
}

return( OM_S_SUCCESS );
}								/*-public*/




								/*+public*/
method pass( OM_p_MESSAGE msg; OM_p_KEY_DESC p_select_key; OM_p_CLASSLIST classlist; OM_p_KEY_DESC p_target_key; int (*user_compare)(); int *ret)  /*+medesc*/
/*

Description:
	    This method provides the capability to send a message to
	    each object whose minimum bounding rectangle (rectangle
	    in 2D or cube in 3D) intersects the query range.

Arguments:
	    Input
	    -----

            OM_p_MESSAGE  msg        pointer to the message to be sent to each
				     candidate object
            OM_p_KEY_DESC p_select_key pointer to the query range
            OM_p_CLASSLIST classlist only objects of class(es) specified
                                     in this list will be sent the message
            int (*user_compare)()    not used in rtree

	    Output
	    ------
            OM_p_KEY_DESC p_target_key  pointer to the key associated with
				        the receiving object
	    int *ret	    	        return code from DB_rtree_search,
				        or DB_rtree_delete if cleanup action
				        is taken
*/								/*-medesc*/

								/*+merev*/
/*

Revision History:
	sss001 23-may-88 replaced the p_criteria arg by classlist

*/								/*-merev*/

{
int rtree_action();
struct dead_key_str
        {
        OM_S_KEY_DESC corpse;
        OM_S_OBJID objid;
        struct dead_key_str *p_next;
        };

struct context_str
	{
	OM_p_MESSAGE msg;
    int tree_type;
    OM_p_KEY_DESC p_target_key;
	OM_S_OBJID senderid;
	struct dead_key_str *p_dead_keys;
        int ret;
	}user_context;

struct dead_key_str *p_next_corpse;
int status;
OMbyte *classStatMap;



if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

user_context.msg = msg;
user_context.tree_type = (int)(ME.OMrtree->tree_page[1]); /* Only till opp works */
user_context.p_target_key = p_target_key;
user_context.senderid = sender_id;
user_context.p_dead_keys = NULL;
user_context.ret = OM_S_SUCCESS;

if ((classlist) && (classlist->w_count)){
  if (!(1&(status=som_build_internal_classlist(classlist, &classStatMap))))
    return(status);
}
else
  classStatMap = NULL;

*ret = DB_rtree_search( ME.OMrtree->tree_page, p_select_key->key.p_3ddbl,0,0,
                       rtree_action, &user_context, classStatMap );

while (user_context.p_dead_keys != NULL)
  {
  if (OM_Gf_verbose_warning)
    {
     printf ("WARNING - removing invalid object %d from the rtree\n",
                             user_context.p_dead_keys->objid);
    }
  status = om$send(msg=message OMrtree.remove(
                               &user_context.p_dead_keys->corpse,
                               &user_context.p_dead_keys->objid,
                               0, ret), targetid=my_id);

  if (!(status & 1))
    {
    printf("\nSomething went wrong in sending remove message to rtree during pass.\n");
    printf("OSnum: %d   Oid-of-Rtree: %d\n", OM_Gw_current_OS, my_id);
    }

  p_next_corpse = user_context.p_dead_keys->p_next;
  om$dealloc(ptr=user_context.p_dead_keys->corpse.key.p_3ddbl);
  om$dealloc(ptr=user_context.p_dead_keys);
  user_context.p_dead_keys = p_next_corpse;
  }

om$dealloc(ptr=(char *) classStatMap);
return( user_context.ret );
}								/*-public*/




							       /*+private*/
							        /*+dsdesc*/
/*
context_str

Description:
	    This structure carries information between pass method
   	    and rtree action routine.
*/

struct dead_key_str
        {
        OM_S_KEY_DESC corpse;
        OM_S_OBJID objid;
        struct dead_key_str *p_next;
        };

struct context_str
        {
	OM_p_MESSAGE msg;       /*  message to be sent to the
				     candidate object */
        int tree_type;           /*  the type of rtree */

        OM_p_KEY_DESC p_target_key;  /* pointer to the key associated with
				        the receiving object */

	OM_S_OBJID senderid;	 /*  The oid of the object who sends a pass
				     or skew_pass message to rtree which
				     in turn invoks rtree_action*/

        struct dead_key_str *p_dead_keys;   /* pointer to a list of keys
				     whose indexed objects have already been
				     deleted */

        int ret;                 /*  It'll contain the return status
				     of om$send from rtree_action */
	};							/*-dsdesc*/



								/*+fndesc*/
/*

Description:
            This function sends the message to the target object and
	    returns the key associated with that object.

Arguments:
	    Input
	    -----
	    char *p_lfkey    pointer to the key found in rtree search
            struct context_str *p_context    the message to be sent
					     and the type of rtree

	    Output
	    ------
            struct context_str *p_context    returns the key found and
					     the status of om$send

*/								/*-medesc*/

								/*+fnrev*/
/*

Revision History:

*/								/*-fnrev*/
								/*-fndesc*/

int rtree_action( p_lfkey, p_context )


char *p_lfkey;
struct context_str *p_context;

{
int status;
OM_p_OBJID p_objid;

p_objid = (OM_p_OBJID) (&((R_PACKED_KEYENTRY_3D_FLT *)(p_lfkey))->Objid);
if (p_context->p_target_key != NULL)
  {
   p_context->p_target_key->type = KEY_3D_DBL;
   p_context->p_target_key->key.p_3ddbl->xmin =
                               (double)(((DB_3D_FLT_BOX *)p_lfkey)->xmin);
   p_context->p_target_key->key.p_3ddbl->ymin =
                               (double)((DB_3D_FLT_BOX *)p_lfkey)->ymin;
   p_context->p_target_key->key.p_3ddbl->zmin =
                               (double)((DB_3D_FLT_BOX *)p_lfkey)->zmin;
   p_context->p_target_key->key.p_3ddbl->xmax =
                               (double)((DB_3D_FLT_BOX *)p_lfkey)->xmax;
   p_context->p_target_key->key.p_3ddbl->ymax =
                               (double)((DB_3D_FLT_BOX *)p_lfkey)->ymax;
   p_context->p_target_key->key.p_3ddbl->zmax =
                               (double)((DB_3D_FLT_BOX *)p_lfkey)->zmax;

  }


status = om$send( msg=p_context->msg,
		  senderid=p_context->senderid,
                  targetid=*p_objid );
p_context->ret = status;

if  ( status == OM_E_NOSUCHCLASS )
    {
    return( DB_CONTINUE );
    }

if ((status == OM_I_STOP_SENDING) || ( (!(1&status)) && (status & SEV_LEV) ) && ( status != OM_E_NOSUCHCLASS ) )
  {
  if (status == OM_E_NOSUCHOBJ)
    {
    struct dead_key_str *p_temp;

    p_temp = p_context->p_dead_keys;
    p_context->p_dead_keys = (struct dead_key_str *)om$malloc(size=sizeof(struct dead_key_str ));

    p_context->p_dead_keys->corpse.type = KEY_3D_DBL;
    if ( (p_context->p_dead_keys->corpse.key.p_3ddbl =
                       (DB_3D_DBL_BOX *)om$malloc(size=sizeof(DB_3D_DBL_BOX))) == NULL)
              return(DB_TERMINATE);
            p_context->p_dead_keys->corpse.key.p_3ddbl->xmin =
                              (double) ((DB_3D_FLT_BOX *)p_lfkey)->xmin;
           p_context->p_dead_keys->corpse.key.p_3ddbl->ymin =
                              (double) ((DB_3D_FLT_BOX *)p_lfkey)->ymin;
           p_context->p_dead_keys->corpse.key.p_3ddbl->zmin =
                              (double) ((DB_3D_FLT_BOX *)p_lfkey)->zmin;
           p_context->p_dead_keys->corpse.key.p_3ddbl->xmax =
                              (double) ((DB_3D_FLT_BOX *)p_lfkey)->xmax;
           p_context->p_dead_keys->corpse.key.p_3ddbl->ymax =
                              (double) ((DB_3D_FLT_BOX *)p_lfkey)->ymax;
           p_context->p_dead_keys->corpse.key.p_3ddbl->zmax =
                              (double) ((DB_3D_FLT_BOX *)p_lfkey)->zmax;


    p_context->p_dead_keys->objid = *p_objid;
    p_context->p_dead_keys->p_next = p_temp;
    p_context->ret = OM_S_SUCCESS;
    return( DB_CONTINUE );
    }
  else
    return( DB_TERMINATE );
  }
else
  {
  return( DB_CONTINUE );
  }
}
							       /*-private*/



								/*+public*/
method skew_pass( OM_p_MESSAGE msg; OM_p_SKEW_DESC p_key; OM_p_KEY_DESC p_target_key; OM_p_CLASSLIST classlist; int (*user_compare)(); int *ret ) /*+medesc*/

/*

Description:
	    This method provides the capability to send a message to
	    each object whose minimum bounding rectangle (rectangle
	    in 2D or cube in 3D) intersects a skewed query mbr.
Arguments:
	    Input
	    -----

            OM_p_MESSAGE  msg        pointer to the message to be sent to
				     sent candidate object
            OM_p_SKEW_DESC p_key     pointer to the query range
            OM_p_CLASSLIST classlist a list of classes to which the msg will
                                     be sent
            int (*user_compare)()    not used in rtree

	    Output
	    ------
            OM_p_KEY_DESC p_target_key  pointer to the key associated with
				        the receiving object
	    int *ret   	             return code from DB_rtree_search

*/								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{
int rtree_action(), status;
struct context_str user_context;
OMbyte *classStatMap;



if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

user_context.msg = msg;
user_context.tree_type = (int)(ME.OMrtree->tree_page[1]); /* Only till opp works */
user_context.p_target_key = p_target_key;
user_context.senderid = sender_id;
user_context.ret = OM_S_SUCCESS;

if ((classlist) && (classlist->w_count)){
  if (!(1&(status= (int) som_build_internal_classlist(classlist, &classStatMap))))
    return(status);
}
else
  classStatMap = NULL;

*ret = DB_rtree_search(ME.OMrtree->tree_page,
                      &(p_key->key.p_skew_3ddbl->range1),
                      &(p_key->key.p_skew_3ddbl->range2),
                      &(p_key->key.p_skew_3ddbl->sx),
                      rtree_action, &user_context, classStatMap);

om$dealloc(ptr=(char *) classStatMap);
return( user_context.ret );

}								/*-public*/




								/*+public*/
method translate( OM_p_OBJARRAY p_objarray; OM_p_KEY_DESC p_key; char *p_criteria; int (*user_compare)(); int *ret ) 			/*+medesc*/

/*

Description:
	    This method will return a list of objids in the tree
            that associated with the given key.

Arguments:
	    Input
	    -----

            OM_p_OBJARRAY p_objarray  the address of a structure
				      which will contain the resultant
				      list of objids. The size field
				      contains the total size of the
				      structure.
            OM_p_KEY_DESC p_key       pointer to the given key
            char *p_criteria	      not used currently
            int (*user_compare)()     not used in rtree

	    Output
	    ------
	    int *ret	    	      to return the status of operation

*/								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{
int rtrans_action();
OMbyte *classStatMap;


if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

p_objarray->count = 0;
p_objarray->tree_type = (int)(ME.OMrtree->tree_page[1]); /* Only till opp works */

classStatMap = NULL;
*ret = DB_rtree_search(ME.OMrtree->tree_page, p_key->key.p_3ddbl,0,0,
                        rtrans_action, p_objarray, classStatMap);
return(OM_S_SUCCESS);
}								/*-public*/




							       /*+private*/
								/*+fndesc*/
/*

Description:
            This function extracts the objid of qualified object from
            its correspoing key entry and puts it on the strucuture
	    passed in by the user.

Arguments:
	    Input
	    -----
	    char *p_lfkey    pointer to the key found in rtree search
            OM_p_OBJARRAY p_objarray    brings the total size of the array
				        and the type of tree

	    Output
	    ------
            OM_p_OBJARRAY  p_context    returns the number of objids
					and array of objids

*/								/*-medesc*/

								/*+fnrev*/
/*

Revision History:

*/								/*-fnrev*/
								/*-fndesc*/

int rtrans_action( p_lfkey, p_objarray )

char *p_lfkey;
OM_p_OBJARRAY p_objarray;

{
int max;
OM_p_OBJID p_objid;


p_objid = (OM_p_OBJID) (&((R_PACKED_KEYENTRY_3D_FLT *)(p_lfkey))->Objid);

/* Number of objids */
max = (p_objarray->size - (3 * sizeof(int) )) / sizeof(OM_S_OBJID);

if ( p_objarray->count < max )
	p_objarray->array[p_objarray->count] = *(p_objid);
(p_objarray->count)++;

return( DB_CONTINUE );
}						   	       /*-private*/




								/*+public*/
method remove( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret )							/*+medesc*/

/*

Description:
            This method removes a rtree key entry, i.e. a (range, objid)
            pair, from rtree. If an entry occurrs more than once in
	    the tree, they must be removed individually.

Arguments:
	    Input
	    -----
            OM_p_KEY_DESC p_key  the address of the range data structure
				 which is the key to be deleted
            OM_p_OBJID p_objid   pointer to the objid that will be deleted
				 along with the key
            int (*user_compare)()     not used in rtree

            Output
	    ------
	    int *ret		 return status from DB_rtree_delete

*/								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{


if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }


*ret = DB_rtree_delete( ME.OMrtree->tree_page, p_key->key.p_3ddbl, p_objid, 0 );
if ( *ret == DB_SUCCESS )
	{		  /* Decrement number of keys in tree by 1 */
	(ME.OMrtree->count)--;
        if (OM_Gi_record_ops)
	  {
	  DB_rtree_put_op(*p_objid, OM_R_REMOVE, OM_Gw_current_OS);
          }
	}

return(OM_S_SUCCESS);
}								/*-public*/


								/*+public*/
method find_and_remove( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret )						/*+medesc*/

/*

Description:
            This method is basically the same as remove method except
	    that a user only has to specify a range which intersects or
            is wholly contained within the entry's range

Arguments:
	    Input
	    -----
            OM_p_KEY_DESC p_key  the address of the range data structure
				 which is the key to be deleted
            OM_p_OBJID p_objid   pointer to the objid that will be deleted
				 along with the key
            int (*user_compare)()     not used in rtree

            Output
	    ------
	    int *ret		 return status from DB_rtree_delete

*/								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{


if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

*ret = DB_rtree_delete( ME.OMrtree->tree_page, p_key->key.p_3ddbl, p_objid, 1 );
if ( *ret == DB_SUCCESS )
	{		  /* Decrement number of keys in tree by 1 */
	(ME.OMrtree->count)--;
        if (OM_Gi_record_ops)
	  {
     	  DB_rtree_put_op(*p_objid, OM_R_FREMOVE, OM_Gw_current_OS);
          }
	}

return(OM_S_SUCCESS);
}								/*-public*/



#endif
								/*+public*/
method delete( int flag )					/*+medesc*/

/*

Description:
	    This method is used to destroy an rtree.

Arguments:
	    Input
	    -----
	    int flag   	not used for now

            Output
	    ------
      	    None

*/								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{


if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
	if( ! VD_OMrtree_delete ){
  		return(OM_E_NOTTREEROOT);
	}
  }

 if (OM_Gf_verbose_warning) printf(" Delete OMrtree: %d \n", my_id );

DB_rtree_deltree( my_id, ME.OMrtree->tree_page );

return( om$send( mode=OM_e_wrt_message,
		 msg=message OMindex.delete(0),
 		 senderid=my_id,
		 targetid=my_id ) );
}								/*-public*/


#ifdef	NOT_NEEDED

								/*+public*/
method neighbor( OM_p_KEY_DESC p_select_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret )						/*+medesc*/

/*

Description:
	    This method will return the objid of an object that is
     	    close to a specified range.

Arguments:
	    Input
	    -----
            OM_p_KEY_DESC p_select_key  pointer to the range data structure
					which defines the desired area or
				        volume
            OM_p_OBJID p_objid          the address which will contain the
					neighbor object id
            int (*user_compare)()       not used in rtree

            Output
	    ------
	    int *ret	       return status from DB_rtree_cluster_obj

*/								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{


if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

*ret = DB_rtree_cluster_obj( ME.OMrtree->tree_page, p_select_key, p_objid );
return(OM_S_SUCCESS);
}								/*-public*/



								/*+public*/
method get_stat( OM_p_RTREESTAT p_stat; int *ret )
								/*+medesc*/

/*

Description:
	    This method will return the general information of an rtree
	    to the data structure pointed by p_stat, the user has
            to specify what type of status is requested.

Arguments:
	    Input
	    -----
            OM_p_RTREESTAT p_stat       pointer to the data structure
					which will be filled in the status
					of rtree.
            Output
	    ------
	    int *ret	                return from DB_rtree_get_status

*/								/*-medesc*/

								/*+merev*/
/*
Revision History:

*/								/*-merev*/

{


if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

*ret = DB_rtree_get_status(ME.OMrtree->tree_page, p_stat);
if (p_stat->request_type == RTREE_MISC_STATUS)
  {
  p_stat->rtree_status.misc.key_count = ME.OMrtree->count;
  }
return(OM_S_SUCCESS);
}								/*-public*/


								/*+public*/
method replace( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int dim; OM_S_KEY_DESC new_keys[]; OM_S_OBJID new_objids[]; int *ret )		/*+medesc*/

/*

Description:
            This method remove a key from the R-tree and insert one
            or more new keys in its place.

Arguments:
	    Input
	    -----
            OM_p_KEY_DESC p_key  The address of an OM_S_KEY_DESC structure
				 containing the key to be replaced.
            OM_p_OBJID p_objid   Address of an object id associated with
				 the key to be replaced.
            int dim    		 Size of the new_keys and new_objids
				 arrays.
	    OM_S_KEY_DESC new_keys[] An array containing the new key(s).
	    OM_S_OBJID new_objids[]  ANn array of OM_S_OBJIDs corresponding
				     to the new keys.
            Output
	    ------
	    int *ret Return status. Zero indicates success. Other values
		     are defined include file OMDB.h.
*/								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{


if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

*ret = DB_rtree_replace( ME.OMrtree->tree_page, p_key->key.p_3ddbl, p_objid, dim, new_keys, new_objids );
if ( *ret == DB_SUCCESS )
	{		  /* Decrement number of keys in tree by 1 */
        if (dim > 1)
          {
	  (ME.OMrtree->count) += (dim - 1);
	  }
        if (OM_Gi_record_ops)
	  {
     	  DB_rtree_put_op(*p_objid, OM_R_REPLACE, OM_Gw_current_OS);
          }
	}

return(OM_S_SUCCESS);
}								/*-public*/


								/*+public*/
method seed( OM_S_KEY_DESC keys[]; int count; int *ret )        /*+medesc*/

/*

Description:
            This method would be sent to a newly constructed R-tree to
	    force the creation of a empty tree, i.e. blank leaf pages,
	    with pre_defined minimum bounding rectangles on the parent
	    pages.

Arguments:
	    Input
	    -----
            OM_S_KEY_DESC keys[]     An array holding the pre-defined MBR.
   	    int		  count      The size of the array.

            Output
	    ------
	    int 	  *ret	     Return status. Zero indicates success.
				     Other values are defined in OMDB.h.
*/								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{
int i;



if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

/* return error if rtree is not empty or has been seeded */
if (ME.OMrtree->count != 0 || ME.OMrtree->tree_page[2] != 0)
  {
  *ret = DB_E_NONEMPTYTREE;
  return(OM_S_SUCCESS);
  }

for (i = 0; i < count; ++i)
  {
  *ret = DB_rtree_seed( ME.OMrtree->tree_page, &keys[i] );
  if ( *ret != DB_SUCCESS )
    break;
  }

return(OM_S_SUCCESS);
}								/*-public*/


								/*+public*/
method control( char *p_flag; char *p_prev_flag )	 	/*+medesc*/

/*

Description:
	This message is provided to alter the certain behavior of rtree.

	RTREE_M_NOMERGE     Inhibit merging of pages when a leaf node
			    underflow
	RTREE_M_ORDER       Keep leaf node entries in sequence by
			    cluster number
	RTREE_M_DYNAMIC	    If an Rtree leaf node splits, move objects
			    among clusters so that the two resulting
			    leaf nodes do not share a cluster in common

Arguments:
	    Input
	    -----
   	    char     *p_flag   A bit mask enable/disable various behavior

            Output
	    ------
	    char     *p_prev_flag   Previous setting of the bit mask
*/								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{



if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

*p_prev_flag = ME.OMrtree->tree_page[3];
ME.OMrtree->tree_page[3] = *p_flag;

return(OM_S_SUCCESS);
}								/*-public*/




								/*+public*/
method find_key( OM_p_KEY_DESC p_select_key; OM_p_OBJID p_objid; OM_p_KEY_DESC p_target_key; int (*user_compare)(); int *ret )							/*+medesc*/

/*

Description:
            This method will search through the tree and return the first
	    key associated with the given object id to p_target_key.

Arguments:
	    OM_p_KEY_DESC p_select_key  An approximate key intersects or
					wholly overlaps with the target key,
					if supplied, it will save the
					searching time.

            OM_p_OBJID    p_objid       The objid of the target key.

            int 	  (*user_compare)()   Not used in rtree.

            OM_p_KEY_DESC p_target_key  To hold the key found.

	    int *ret      return status from R-tree code.
                          DB_SUCCESS:    key is found and returned
                          DB_KEYNOTFOUND key is not found

*/
								/*-medesc*/

								/*+merev*/
/*

Revision History:

*/								/*-merev*/

{


if ( ! (ME.OMrtree->tree_page[0]==R_LF_RT_PAGE || ME.OMrtree->tree_page[0]==R_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }
if (p_select_key)
 {
 *ret = DB_rtree_find_key(ME.OMrtree->tree_page,
              p_select_key->key.p_3ddbl, p_objid, p_target_key->key.p_3ddbl);
 }
else
 {
 *ret = DB_rtree_find_key(ME.OMrtree->tree_page,
              0, p_objid, p_target_key->key.p_3ddbl);
 }
p_target_key->type =  KEY_3D_DBL;

return(OM_S_SUCCESS);
}								/*-public*/

#endif

end implementation OMrtree;
