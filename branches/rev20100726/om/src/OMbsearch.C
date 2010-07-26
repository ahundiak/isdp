#include <string.h>
#include "OMDB.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMindex.h"
#include "OMbtreedef.h"

/* This function is called to search a BTREE for entries
   containing a specified key value. An action routine is
   passed in to this function which will be executed once
   for each instance of an equal key value. GDK. */

DB_btree_search (root_page_p,
                 search_key_value_ptr,
	         search_key_length, 
                 user_compare_routine_ptr, 
                 user_action_routine_ptr,
                 user_context_ptr,
		 classStatMap)

  B_NL_PAGE     *root_page_p;
  char		*search_key_value_ptr;
  KEY_LENGTH	search_key_length;
  int		(*user_compare_routine_ptr)();
  int		(*user_action_routine_ptr)();
  char		*user_context_ptr;
  OMbyte        *classStatMap;
  
 {
  KEY_LENGTH            nl_key_length;
  BTREE_LOCAL_CONTEXT	local_context;
  int			DB_btree_page_search();
  int			ret;

  if ( root_page_p->Offset_entry_count != 0 )
    {
     nl_key_length = root_page_p->Nl_key_length;
  
     /* build local context */

     local_context.search_id = 0;
     local_context.key_value_ptr = search_key_value_ptr;
     local_context.key_value_length = search_key_length;
     local_context.nl_key_length = nl_key_length;
     local_context.user_compare_routine_ptr = user_compare_routine_ptr;
     local_context.user_action_routine_ptr = user_action_routine_ptr;
     local_context.user_context_ptr = user_context_ptr;

     /* initiate search with root node */

     ret = DB_btree_page_search( root_page_p, &local_context, classStatMap);
    }
  return(DB_SUCCESS);
 }





/******************************************************************/
/* this routine is responsible for searching an btree node
   and invoking the appropiate routine. */

int DB_btree_page_search ( non_leaf_ptr, local_context_ptr, classStatMap)

  B_NL_PAGE 		*non_leaf_ptr;
  BTREE_LOCAL_CONTEXT	*local_context_ptr;
  OMbyte        *classStatMap;

  {
  int	            i, return_code;
  B_LF_PAGE	    *leaf_ptr;
  long		    *page_ptr;
  char              *key_ptr, *lf_key_ptr;
  OM_S_OBJID        *child_ptr_p;
  CHILD_PTR_COUNT   *child_ptr_count_p, j;
  KEY_LENGTH        key_length;
  REC_PTR_COUNT     *obj_id_count_ptr, k;
  long              *obj_id_ptr;
  int               rtn, top, middle, bottom;
  KEY_LENGTH        real_len_1, real_len_2;
  OM_S_RIP	    rip;
  


  if (NOT_B_LEAF(non_leaf_ptr->Page_type))
    {
    /* process non-leaf page */

    for (i=0; (unsigned short) i<non_leaf_ptr->Offset_entry_count; i++ )
      {
      GET_NL_KEY_ENTRY(non_leaf_ptr, i, local_context_ptr->nl_key_length, 
		       key_length, child_ptr_count_p,
                       key_ptr, child_ptr_p);

      USER_COMPARE((*local_context_ptr->user_compare_routine_ptr), 
                  local_context_ptr->key_value_ptr, 
		  key_ptr, 
		  (KEY_LENGTH) MIN(local_context_ptr->key_value_length, 
		      local_context_ptr->nl_key_length), 
		  key_length, rtn );

      if ( (rtn <= 0 ))
        {
	for (j=0; j<*child_ptr_count_p; j++)
          {

           page_ptr =  (long *) DEREF(int, (*( child_ptr_p + j )), rip);
	   if ( page_ptr == NULL )
		return(DB_E_NULLDEREF);

           if ((return_code = DB_btree_page_search((B_NL_PAGE *) page_ptr,
              local_context_ptr, classStatMap)) != DB_CONTINUE)
               {
                return(return_code);
               }
          }/* for */
        if ( rtn == 0  && i != non_leaf_ptr->Offset_entry_count-1 )
          {
            GET_NL_KEY_ENTRY(non_leaf_ptr, i+1, 
			     local_context_ptr->nl_key_length, 
			     key_length, child_ptr_count_p,
                             key_ptr, child_ptr_p);

            page_ptr = (long *) DEREF(int, (*child_ptr_p), rip);
	    if ( page_ptr == NULL )
		return(DB_E_NULLDEREF);

              if ((return_code = DB_btree_page_search((B_NL_PAGE *) page_ptr,
                 local_context_ptr, classStatMap)) != DB_CONTINUE)
                {
                return(return_code);
		}
          }
        break;
	}/* if new key <= present key */
      }
    }/* if non leaf page */
  else
    {
    /* process leaf page */

    leaf_ptr = (B_LF_PAGE *)non_leaf_ptr;

    top = leaf_ptr->Offset_entry_count - 1;
    bottom = 0;
    do
      {
      middle = (top + bottom) / 2;
      GET_LF_KEY_ENTRY(leaf_ptr, middle, key_length, obj_id_count_ptr,
                       lf_key_ptr, obj_id_ptr);

      if ( leaf_ptr->Key_type == KEY_STRING )
	{
	real_len_1 = strlen( local_context_ptr->key_value_ptr );
	real_len_2 = strlen( lf_key_ptr );
	}
      else
	{
	real_len_1 = local_context_ptr->key_value_length;
	real_len_2 = key_length;
	}

      USER_COMPARE( (*local_context_ptr->user_compare_routine_ptr), 
	    local_context_ptr->key_value_ptr, lf_key_ptr,
	    real_len_1, real_len_2, rtn );
	    
      if ( rtn == 0 )
        {
        for (k=0; k<(*obj_id_count_ptr); k++)
          {
          if (!classStatMap || classStatMap[OM_GA_active_to_filed[OM_GA_OSDs[OM_Gw_current_OS]->Spacemap[*(obj_id_ptr+k)].p_acld->w_classid]])
            {
            if (( return_code = (*local_context_ptr->user_action_routine_ptr)
              (obj_id_ptr + k,local_context_ptr->user_context_ptr)) != DB_CONTINUE)
              {
	      return(return_code);
              }
            }  /* if user specified class */
          }  /* for */

        if (middle == leaf_ptr->Offset_entry_count-1)
          {
          if ( !( IF_EQ_OBJID(leaf_ptr->Next_p, NULL_OBJID) ) )
	    {
            leaf_ptr = DEREF(B_LF_PAGE, leaf_ptr->Next_p, rip);
            GET_LF_KEY_ENTRY(leaf_ptr, 0, key_length, obj_id_count_ptr,
                             lf_key_ptr, obj_id_ptr);

            if ( leaf_ptr->Key_type == KEY_STRING )
   	      {
  	      real_len_1 = strlen( local_context_ptr->key_value_ptr );
	      real_len_2 = strlen( lf_key_ptr );
              }
            else
	      {
	      real_len_1 = local_context_ptr->key_value_length;
	      real_len_2 = key_length;
	      }

            USER_COMPARE( (*local_context_ptr->user_compare_routine_ptr), 
	                   local_context_ptr->key_value_ptr, lf_key_ptr,
	    		   real_len_1, real_len_2, rtn );
	    if (rtn == 0)
	      {
	      return(DB_CONTINUE);
	      }    
	    }	/* if leaf_ptr->Next_p != NULL_OBJID */
          }	/* The current key is the highest key */

	return(DB_SUCCESS);
        }	/* if new key <= present key */
      else if ( rtn > 0)
              bottom = middle + 1;
           else
              top = middle - 1;

      }  while (top >= bottom);

    }	/* else */
  return(DB_CONTINUE);
  }





/************************************************************************/

DB_btree_seq_search( page_p, maxkeys, objid, key_array )

	B_NL_PAGE *page_p;
	int maxkeys;
	OM_S_OBJID objid;
	OM_p_KEYNAME key_array;
	
{
short i, ii;
int count=0;
B_LF_PAGE *leaf_page_p;
OM_S_OBJID *child_ptr_p;
CHILD_PTR_COUNT *child_ptr_count_p;
REC_PTR_COUNT *rec_ptr_count_p;
KEY_LENGTH key_length;
char *key_p;
long *rec_ptr_p;
int p;
OM_S_RIP rip;



while ( NOT_B_LEAF(page_p->Page_type) )
   {
	GET_NL_KEY_ENTRY( page_p, 0, page_p->Nl_key_length, key_length, 
		child_ptr_count_p, key_p, child_ptr_p );
        page_p = DEREF(B_NL_PAGE, (*(child_ptr_p)), rip );
	if ( page_p == NULL )
		return(DB_E_NULLDEREF);

   }

/* Leaf page found */

   leaf_page_p = (B_LF_PAGE *)page_p;
   do
     {
     for ( i=0; (unsigned short) i<leaf_page_p->Offset_entry_count; i++ )
	{
	GET_LF_KEY_ENTRY( leaf_page_p, i, key_length, rec_ptr_count_p, 
		key_p, rec_ptr_p );
	for ( p=0; p< (int) *rec_ptr_count_p; p++ )		
	   {

	   /* Process Leaf Key */

	   if ( (OM_S_OBJID) *rec_ptr_p == objid )	 
		{
                key_array[count].key_len = key_length;
		for ( ii=0; (KEY_LENGTH) ii<key_length; ii++)
		   key_array[count].key_name[ii] = ((char *)key_p)[ii];
		count++;
		if ( count == maxkeys ) return( DB_SUCCESS );

		}

	   rec_ptr_p++;

	   }
	}
     leaf_page_p = DEREF( B_LF_PAGE, leaf_page_p->Next_p, rip);

     } while (leaf_page_p != NULL );

return( DB_SUCCESS );

}



/************************************************************************/

DB_btree_contents( page_p, start_key_num, num_keys, keyobj_array )

	B_NL_PAGE *page_p;

	int start_key_num;		  /* where in btree to start */

	int *num_keys;			  /* input - max num keys
					    keyobj_array will hold 

					    output - num keys actually
					    filled into keyobj_array
					  */

	OM_p_BTREE_CONTENTS keyobj_array; /* holds tree contents */
	
{
short i, ii;
int buf_count=0;		/* Position in btree contents buffer */
int key_count=0;		/* Count of key we are processing */
B_LF_PAGE *leaf_page_p;
OM_S_OBJID *child_ptr_p;
CHILD_PTR_COUNT *child_ptr_count_p;
REC_PTR_COUNT *rec_ptr_count_p;
KEY_LENGTH key_length;
char *key_p;
long *rec_ptr_p;
int p;
OM_S_RIP rip;


while ( NOT_B_LEAF(page_p->Page_type) )
   {
	GET_NL_KEY_ENTRY( page_p, 0, page_p->Nl_key_length, key_length, 
		child_ptr_count_p, key_p, child_ptr_p );
        page_p = DEREF(B_NL_PAGE, (*(child_ptr_p)), rip );
	if ( page_p == NULL )
		{
		*num_keys = 0;
		return(DB_E_NULLDEREF);
		}

   }

/* Leaf page found */

   leaf_page_p = (B_LF_PAGE *)page_p;
   do
     {
     for ( i=0; (unsigned short) i<leaf_page_p->Offset_entry_count; i++ )
	{
	GET_LF_KEY_ENTRY( leaf_page_p, i, key_length, rec_ptr_count_p, 
		key_p, rec_ptr_p );
	for ( p=0; p< (int) *rec_ptr_count_p; p++ )		
	   {

	   if (key_count >= start_key_num)
		{

	        /* Process Leaf Key */

        	keyobj_array[buf_count].objid = *rec_ptr_p;
                keyobj_array[buf_count].name.key_len = key_length;
		for ( ii=0; (unsigned short) ii<key_length; ii++)
		   keyobj_array[buf_count].name.key_name[ii] = ((char *)key_p)[ii];
		buf_count++;
		if ( buf_count == *num_keys ) return( DB_SUCCESS );
		}
	   key_count++;
	   rec_ptr_p++;

	   }
	}
     leaf_page_p = DEREF( B_LF_PAGE, leaf_page_p->Next_p, rip);

     } while (leaf_page_p != NULL );

*num_keys = buf_count;	/* number of keys actually returned */
return( DB_SUCCESS );

}
