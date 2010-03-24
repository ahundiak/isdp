class implementation OMbtree;

#include <string.h>
#include "OMDB.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMindex.h"						
#include "OMbtreedef.h"

extern int DB_btree_contents();
extern int DB_btree_create();
extern int DB_btree_range_search();
extern int DB_btree_search();
extern int DB_btree_seq_search();
extern int DB_dump_btree();
extern int som_build_internal_classlist();

method OMbtree_constr( unsigned char tree_type; int *ret )

/* This method constructs the btree by calling DB_create_btree.

input
-----
char tree_type			type of btree to be constructed

output
------
int *ret			return code from DB_btree_create

*/

{

ME.OMbtree->objid = my_id;
*ret = DB_btree_create( tree_type, ME.OMbtree->btree_page );
return( OM_S_SUCCESS );

}


method add( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int(*user_compare)();
  int *ret )

/* This method adds a key to the btree by calling DB_btree_insert.

input
-----
OM_p_KEY_DESC p_key		key to be inserted
OM_p_OBJID p_objid		objid of key
int (*user_compare)()		user compare routine; if not given,
				default is a lexicographic compare
output
------
int *ret			retrun code from DB_btree_insert

*/

{
short real_key_length, key_length;
char p_align_key[134];

if ( ! (ME.OMbtree->btree_page[0]==B_LF_RT_PAGE || ME.OMbtree->btree_page[0]==B_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

if ((ME.OMbtree->btree_page[1]& (~BTREE_NODUP)) != p_key->type)
  {
  *ret = DB_E_TYPECONFLICT;
  }
else
  {
  switch (p_key->type)
    {
    case KEY_STRING:
         real_key_length = strlen(p_key->key.p_string);
         strcpy( p_align_key, p_key->key.p_string );
         key_length = (sizeof(int) - (real_key_length%(sizeof(int)))) + real_key_length;

#ifdef BDEBUG
  printf("SSSADD  %s\t%d\t%u\t%u\n", p_align_key, *p_objid, my_id, OM_Gw_current_OS);
#endif

         *ret = DB_btree_insert( (B_NL_PAGE *) ME.OMbtree->btree_page,
            (char *)p_align_key, key_length, (long *) p_objid, user_compare );
	 break;
    case KEY_INTEGER:
         key_length = 4;
         *ret = DB_btree_insert( (B_NL_PAGE *) ME.OMbtree->btree_page,
            (char *) p_key->key.p_integer, key_length, (long *) p_objid, user_compare );
         break;
    case KEY_FLOAT:
         key_length = 4;
         *ret = DB_btree_insert( (B_NL_PAGE *) ME.OMbtree->btree_page,
            (char *) p_key->key.p_float, key_length, (long *) p_objid, user_compare );
         break;
    case KEY_DOUBLE:   
         key_length = 8;
         *ret = DB_btree_insert( (B_NL_PAGE *) ME.OMbtree->btree_page,
            (char *) p_key->key.p_double, key_length, (long *) p_objid, user_compare );
         break;
    default:
         *ret = DB_E_BADKEYTYPE;
    }
  }

if ( *ret == DB_SUCCESS )
	{		  /* Increment number of keys in tree by 1 */
	(ME.OMbtree->count)++;
	}

return(OM_S_SUCCESS);
}


method range_pass( OM_p_MESSAGE msg; OM_p_KEY_DESC p_key_low; OM_p_KEY_DESC p_key_high; char *p_criteria; int (*user_compare)(); int *ret )

/* This method sends a message msg to every key in the btree whose
   value is between p_key_low and p_key_high inclusive. 

input
-----
OM_p_MESSAGE msg		pointer to the message to be sent to
			        each key found
OM_p_KEY_DESC p_low_key		low key for search
OM_p_KEY_DESC p_key_high	high key for search
char *p_criteria		not used currently
int (*user_compare)()		user compare routine; if not given,
				will default to lexicographic compare
output
------
int *ret			return code from DB_btree_range_search

*/

{
int btree_action();
struct context_str
	{
	OM_p_MESSAGE msg;
	OM_S_OBJID senderid;
	int ret;
	} user_context;
short key_length_low, key_length_high, real_key_length_low, 
	real_key_length_high;
int comp_rlt;
char p_align_key_low[134], p_align_key_high[134];

if ( ! (ME.OMbtree->btree_page[0]==B_LF_RT_PAGE || ME.OMbtree->btree_page[0]==B_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

if (((ME.OMbtree->btree_page[1]& (~BTREE_NODUP)) != p_key_low->type) ||
    ((ME.OMbtree->btree_page[1]& (~BTREE_NODUP)) != p_key_high->type) )
  {
  *ret = DB_E_TYPECONFLICT;
  }
else
  {
  user_context.msg = msg;
  user_context.senderid = sender_id;
  user_context.ret = OM_S_SUCCESS;
  switch (p_key_low->type)
    {
    case KEY_STRING:
         real_key_length_low = strlen(p_key_low->key.p_string);
         real_key_length_high = strlen(p_key_high->key.p_string);
         strcpy( p_align_key_low, p_key_low->key.p_string );
         strcpy( p_align_key_high, p_key_high->key.p_string );
         key_length_low = (sizeof(int) - (real_key_length_low%(sizeof(int))))+ 
		real_key_length_low;
         key_length_high = (sizeof(int)-(real_key_length_high%(sizeof(int))))+ 
		real_key_length_high;
	USER_COMPARE(user_compare, p_key_low->key.p_string, 
		p_key_high->key.p_string, real_key_length_low, 
		real_key_length_high, comp_rlt);
	if (comp_rlt > 0)
	  {
	  *ret = DB_E_LKEYGTHKEY;
	  }
	else
	  {
	  *ret = DB_btree_range_search( ME.OMbtree->btree_page, 
		p_align_key_low, key_length_low, p_align_key_high, 
		key_length_high, user_compare, btree_action, 
		&user_context );
	  }
         break;
    case KEY_INTEGER:
        key_length_low = 4;
        key_length_high = 4;
	comp_rlt = (*user_compare)(p_key_low->key.p_integer, 
		p_key_high->key.p_integer, key_length_low, 
		key_length_high);
	if (comp_rlt > 0)
	  {
	  *ret = DB_E_LKEYGTHKEY;
	  }
	else
	  {
	  *ret=DB_btree_range_search( ME.OMbtree->btree_page, p_key_low->key.p_integer, key_length_low, p_key_high->key.p_integer, key_length_high, 
		user_compare, btree_action, &user_context );
	  }
	 break;
    case KEY_FLOAT:
        key_length_low = 4;
        key_length_high = 4;
	comp_rlt = (*user_compare)(p_key_low->key.p_float, 
		p_key_high->key.p_float, key_length_low, 
		key_length_high);
	if (comp_rlt > 0)
	  {
	  *ret = DB_E_LKEYGTHKEY;
	  }
	else
	  {
	  *ret=DB_btree_range_search( ME.OMbtree->btree_page, p_key_low->key.p_float, key_length_low, p_key_high->key.p_float, key_length_high, 
		user_compare, btree_action, &user_context );
	  }
	 break;
    case KEY_DOUBLE:   
        key_length_low = 8;
        key_length_high = 8;
	comp_rlt = (*user_compare)(p_key_low->key.p_double, 
		p_key_high->key.p_double, key_length_low, 
		key_length_high);
	if (comp_rlt > 0)
	  {
	  *ret = DB_E_LKEYGTHKEY;
	  }
	else
	  {
	  *ret=DB_btree_range_search( ME.OMbtree->btree_page, p_key_low->key.p_double, 
		key_length_low, p_key_high->key.p_double, key_length_high, 
		user_compare, btree_action, &user_context );
	  }
	 break;
    default:
         *ret = DB_E_BADKEYTYPE;
    }
  }

return(user_context.ret);

}


method pass( OM_p_MESSAGE msg; OM_p_KEY_DESC p_select_key; OM_p_CLASSLIST classlist; OM_p_KEY_DESC p_target_key; int (*user_compare)(); int *ret )

/* This method searches the tree for the given key.  The message
   msg is sent to every key found in the btree that matches the search
   key.

input
-----
OM_p_MESSAGE msg		pointer to the message to be sent to
			        every key found
OM_p_KEY_DESC p_select_key	the key we are searching for
OM_p_CLASSLIST classlist        a list of classes to which the msg will
				be sent
int (*user_compare)()		user compare routine; if not given,
				a lexicographic compare is used
output
------
OM_p_KEY_DESC p_target_key	key found
int *ret			return code from DB_btree_search

*/

{
int btree_action();
struct context_str
	{
	OM_p_MESSAGE msg;
	OM_S_OBJID senderid;
	int ret;
	} user_context;
short real_key_length, key_length;
int status;
char p_align_key[134];
OMbyte *classStatMap;



if ( ! (ME.OMbtree->btree_page[0]==B_LF_RT_PAGE || ME.OMbtree->btree_page[0]==B_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

if ((classlist) && (classlist->w_count)){
  if (!(1&(status=som_build_internal_classlist(classlist, &classStatMap))))
    return(status);
}
else
  classStatMap = NULL;

if ((ME.OMbtree->btree_page[1]& (~BTREE_NODUP)) != p_select_key->type)
  {
  *ret = DB_E_TYPECONFLICT;
  }
else
  {
  user_context.msg = msg;
  user_context.senderid = sender_id;
  user_context.ret = OM_S_SUCCESS;
  switch (p_select_key->type)
    {
    case KEY_STRING:
         real_key_length = strlen(p_select_key->key.p_string);
         key_length = (sizeof(int) - (real_key_length%(sizeof(int)))) + 
		real_key_length;
         strcpy( p_align_key, p_select_key->key.p_string );
         *ret = DB_btree_search( ME.OMbtree->btree_page, p_align_key,
				 key_length, user_compare,
				 btree_action, &user_context, classStatMap );
         break;

    case KEY_INTEGER:
         key_length = 4;
         *ret = DB_btree_search( ME.OMbtree->btree_page, p_select_key->key.p_integer, key_length, user_compare, btree_action, &user_context, classStatMap );
	 break;

    case KEY_FLOAT:
         key_length = 4;
         *ret = DB_btree_search( ME.OMbtree->btree_page, p_select_key->key.p_float, key_length, user_compare, btree_action, &user_context, classStatMap );
	 break;

    case KEY_DOUBLE:   
         key_length = 8;
         *ret = DB_btree_search( ME.OMbtree->btree_page, p_select_key->key.p_double, key_length, user_compare, btree_action, &user_context, classStatMap );
	 break;

    default:
         *ret = DB_E_BADKEYTYPE;
    }
  }

om$dealloc(ptr=(char *) classStatMap);
return(OM_S_SUCCESS);
}


struct context_str
	{
	OM_p_MESSAGE msg;
	OM_S_OBJID senderid;
	int ret;
	};

int btree_action(
OM_p_OBJID    p_rec,
struct context_str *context)
{

int status;

#ifdef DEBUG
printf("\n*** btree_action ***\n");
printf("targetid: %x\n", *p_rec);
printf("context->msg->select.DefClassid: %d\n",
	context->msg->select.DefClassid);
printf("context->msg->select.ReqClassid: %d\n",
	context->msg->select.ReqClassid);
printf("context->msg->select.FuncIndex: %d\n",
	context->msg->select.FuncIndex);
printf("context->msg->size: %d\n",
	context->msg->size);
printf("context->msg->p_arglist: %x\n",
	context->msg->p_arglist);
#endif

status = om$send(	msg=(context->msg),
			senderid=context->senderid,
			targetid=*p_rec);
context->ret = status;

#ifdef DEBUG
printf("*** status from send: %x\n", status);
if ( !(status&1) )
	om$report_error(sts=status);
#endif


if ((status == OM_I_STOP_SENDING) || ( (!(1&status)) && (status &
SEV_LEV) ) && ( status != OM_E_NOSUCHCLASS ) )

  {
#ifdef DEBUG
  printf("\n*** DB_TERMINATE ***\n");
#endif
  return( DB_TERMINATE );
  }
else
  {
  return( DB_CONTINUE );
  }
}



method seqpass( int count; OM_S_OBJID objid; OM_p_KEYNAME key_array; int *ret )

/* This method searches the Btree sequentially for the specified 
   objid and returns the key associated with that objid.

input
-----
int count		dimension of key_array
OM_S_OBJID objid	objid we are searching for

output
------
OM_p_KEYNAME		key (length and value) associated with
			the search objid
int *ret		return code from DB_btree_seq_search


*/
{

if ( ! (ME.OMbtree->btree_page[0]==B_LF_RT_PAGE || ME.OMbtree->btree_page[0]==B_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

*ret = DB_btree_seq_search( ME.OMbtree->btree_page, count, objid, key_array );
return(OM_S_SUCCESS);

}


method btree_contents( int start_key_num; int *num_keys;
 OM_p_BTREE_CONTENTS keyobj_array; int *ret )

/* This method returns the contents of a btree in a buffer of 
   objid/key pairs (keyobj_array).  Num_keys is the number of these
   pairs the buffer can hold.  Start_key_num is the place in the btree
   where data will start being returned from.  A start_key_num of 0,
   for example, means data will be returned starting from the leftmost 
   key in the tree.  On return, num_keys holds the actual number of 
   objid/key pairs inserted into the buffer.

   If a NULL buffer is passed in , this method simply returns the number
   of keys in the btree via num_keys.

input
-----
int start_key_num	position in tree from which filling
			of buffer will start
int *num_keys		dimension of keyobj_array

output
------
OM_p_BTREE_CONTENTS keyobj_array 	array of objid/key pairs
					which is to be filled
int *num_keys				number of objid/key pairs
					actually returned in buffer
				 	or optionally the number
					of keys in the btree
int *ret				return code from DB_btree_contents

*/
{

if ( ! (ME.OMbtree->btree_page[0]==B_LF_RT_PAGE || ME.OMbtree->btree_page[0]==B_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

if (keyobj_array == NULL)
   {
   *num_keys = ME.OMbtree->count;     /* return number of keys in tree */
   *ret = DB_SUCCESS;
   return(OM_S_SUCCESS);
   }
else
   {
   *ret = DB_btree_contents( ME.OMbtree->btree_page, start_key_num, num_keys, keyobj_array );
   return(OM_S_SUCCESS);
   }
}


method translate( OM_p_OBJARRAY p_objarray; OM_p_KEY_DESC p_key;
  char *p_criteria; int (*user_compare)(); int *ret )

/* This method searches the Btree for the given key and returns
   all the objids associated with that key that the array field
   of p_objarray will hold.  The size field of p_objarray should 
   contain the total size of the structure in bytes.  The count 
   field in p_objarray is the total number of objids found associated 
   with the search key.

input
-----
OM_p_OBJARRAY p_objarray	the size and type fields are input
OM_p_KEY_DESC p_key		the search key
char *p_criteria		not used currently
int(*user_compare)()		user compare routine; if not
				specified, a lexicographic comparison
				is assumed

output
------
OM_p_OBJARRAY p_objarray	the array and count fields are output
int *ret			return code from DB_btree_search
 
*/

{
int trans_action();
short real_key_length, key_length;
char p_align_key[134];
OMbyte *classStatMap=NULL;



if ( ! (ME.OMbtree->btree_page[0]==B_LF_RT_PAGE || ME.OMbtree->btree_page[0]==B_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

if ((ME.OMbtree->btree_page[1]& (~BTREE_NODUP)) != p_key->type)
  {
  *ret = DB_E_TYPECONFLICT;
  }
else
  {
  p_objarray->count = 0;
  switch (p_key->type)
    {
    case KEY_STRING:
         real_key_length = strlen(p_key->key.p_string);
         key_length = (sizeof(int) - (real_key_length%(sizeof(int)))) + 
		real_key_length;
         strcpy( p_align_key, p_key->key.p_string );

#ifdef BDEBUG
  printf("SSSTRA  %s\t%u\t%u\n", p_align_key, my_id, OM_Gw_current_OS);
#endif

         *ret = DB_btree_search( ME.OMbtree->btree_page, p_align_key,
				 key_length, user_compare,
				 trans_action, p_objarray, classStatMap );
	 break;
    case KEY_INTEGER:
         key_length = 4;
         *ret = DB_btree_search( ME.OMbtree->btree_page, p_key->key.p_integer,
 	   key_length, user_compare, trans_action, p_objarray, classStatMap );

	 break;
    case KEY_FLOAT:
         key_length = 4;
         *ret = DB_btree_search( ME.OMbtree->btree_page, p_key->key.p_float,
           key_length, user_compare, trans_action, p_objarray, classStatMap );

	 break;
    case KEY_DOUBLE:   
         key_length = 8;
         *ret = DB_btree_search( ME.OMbtree->btree_page, p_key->key.p_double,
           key_length, user_compare, trans_action, p_objarray, classStatMap );
	 break;
    default:
         *ret = DB_E_BADKEYTYPE;
    }
  }

return(OM_S_SUCCESS);
}


int trans_action(
OM_p_OBJID p_objid,
OM_p_OBJARRAY p_objarray)

{
int max;


max = (p_objarray->size - 3*sizeof(int))/sizeof(OM_S_OBJID);   /* Number of objids */

if ( p_objarray->count < max ) 
	p_objarray->array[p_objarray->count] = *(p_objid);
(p_objarray->count)++;

return( DB_CONTINUE );
}



method remove( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret )

/* This method removes a key from the btree by calling DB_btree_delete.

input
-----
OM_p_key_DESC p_key		key to be deleted
OM_p_OBJID p_objid		objid of key
int (*user_compare)()		user compare routine; if not given,
				lexicographic compare is used
output
------
int *ret			return code from DB_btree_delete

*/

{
short real_key_length, key_length;
char p_align_key[134];

if ( ! (ME.OMbtree->btree_page[0]==B_LF_RT_PAGE || ME.OMbtree->btree_page[0]==B_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

if ((ME.OMbtree->btree_page[1]& (~BTREE_NODUP)) != p_key->type)
  {
  *ret = DB_E_TYPECONFLICT;
  }
else
  {
  switch (p_key->type)
    {
    case KEY_STRING:
         real_key_length = strlen(p_key->key.p_string);
         key_length = (sizeof(int) - (real_key_length%(sizeof(int)))) + 
		real_key_length;
         strcpy( p_align_key, p_key->key.p_string );

#ifdef BDEBUG
  printf("SSSREM  %s\t%d\t%u\t%u\n", p_align_key, *p_objid, my_id, OM_Gw_current_OS);
#endif

         *ret = DB_btree_delete( p_align_key, key_length, 
	    (long *) p_objid, (B_NL_PAGE *) ME.OMbtree->btree_page, user_compare );
	 break;
    case KEY_INTEGER:
         key_length = 4;
         *ret = DB_btree_delete( (char *) p_key->key.p_integer, key_length,
	    (long *) p_objid, (B_NL_PAGE *) ME.OMbtree->btree_page, user_compare );

	 break;
    case KEY_FLOAT:
         key_length = 4;
         *ret = DB_btree_delete( (char *) p_key->key.p_float, key_length,
	    (long *) p_objid, (B_NL_PAGE *) ME.OMbtree->btree_page, user_compare );

	 break;
    case KEY_DOUBLE:   
         key_length = 8;
         *ret = DB_btree_delete( (char *) p_key->key.p_double, key_length,
	    (long *) p_objid, (B_NL_PAGE *) ME.OMbtree->btree_page, user_compare );

	 break;
    default:
         *ret = DB_E_BADKEYTYPE;
    }
  }

if ( *ret == DB_SUCCESS )
	{		  /* Decrement number of keys in tree by 1 */
	(ME.OMbtree->count)--;
	}

return( OM_S_SUCCESS);
}



method delete( int flag  )

/*  This method deletes the objids of all the pages in the Btree.

input
-----
int flag		not used currently

*/
{

if ( ! (ME.OMbtree->btree_page[0]==B_LF_RT_PAGE || ME.OMbtree->btree_page[0]==B_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

#ifdef DEBUG
printf("\n*** Call to deltree in delete method ***\n");
#endif

DB_btree_deltree( my_id, (B_NL_PAGE *) ME.OMbtree->btree_page );

#ifdef DEBUG
printf("*** return from deltree ***\n");
#endif

return( om$send( mode=OM_e_wrt_message, msg=(message Root.delete(0)), senderid=my_id, targetid=my_id ) );

}


method neighbor( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret )

/*  This method retreives the objid of an object that would be close
    to an object with the specified key.

input
-----
OM_p_KEY_DESC p_key		key to cluster around
int (*user_compare)()		user compare routine; if not given,
				default is a lexicographic compare
output
------
OM_p_OBJID p_objid		objid of object close to object with
				p_key
int *ret			return code from DB_btree_cluster_objid

*/

{         
short real_key_length, key_length;
char p_align_key[134];

if ( ! (ME.OMbtree->btree_page[0]==B_LF_RT_PAGE || ME.OMbtree->btree_page[0]==B_NL_RT_PAGE) )
  {
  return(OM_E_NOTTREEROOT);
  }

if ((ME.OMbtree->btree_page[1]& (~BTREE_NODUP)) != p_key->type)
  {
  *ret = DB_E_TYPECONFLICT;
  }
else
  {
  switch (p_key->type)
    {
    case KEY_STRING:
         real_key_length = strlen(p_key->key.p_string);
         key_length = (sizeof(int) - (real_key_length%(sizeof(int)))) + 
		real_key_length;
         strcpy( p_align_key, p_key->key.p_string );
         *ret = DB_btree_cluster_obj( (B_NL_PAGE *) ME.OMbtree->btree_page,
             (char *) p_align_key, key_length, user_compare, (long *) p_objid );
	 break;
    case KEY_INTEGER:
         key_length = 4;
         *ret = DB_btree_cluster_obj( (B_NL_PAGE *) ME.OMbtree->btree_page,
            (char *) p_key->key.p_integer, key_length, user_compare, (long *) p_objid );

	 break;
    case KEY_FLOAT:
         key_length = 4;
         *ret = DB_btree_cluster_obj( (B_NL_PAGE *) ME.OMbtree->btree_page,
            (char *) p_key->key.p_float, key_length, user_compare, (long *) p_objid );

	 break;
    case KEY_DOUBLE:   
         key_length = 8;
         *ret = DB_btree_cluster_obj( (B_NL_PAGE *) ME.OMbtree->btree_page,
            (char *) p_key->key.p_double, key_length, user_compare, (long *) p_objid );

	 break;
    default:
         *ret = DB_E_BADKEYTYPE;
    }
  }

return(OM_S_SUCCESS);
}


method btree_dump( unsigned char tree_type )

/* This method dumps the contents of the btree */

{
OM_S_RIP rip;
long *root_page;

root_page = DEREF(long,ME.OMbtree->objid,rip);

if (tree_type == BTREE_INTEGER)
	DB_dump_btree(root_page,4,tree_type);
else if (tree_type == BTREE_STRING)
	DB_dump_btree(root_page,8,tree_type);

return(OM_S_SUCCESS);
}

end implementation OMbtree;
