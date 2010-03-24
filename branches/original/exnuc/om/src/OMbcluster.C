#include <string.h>
#include "OMDB.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMindex.h"
#include "OMbtreedef.h"



DB_btree_cluster_obj
( B_NL_PAGE *root_page_p, char *new_key_p, KEY_LENGTH new_key_length,
 int (*user_compare_routine_p)(), long *neighbor_objid_p)


/*  Searches for specified key or location where key should be found
    in btree, returns record id of leaf index page.  */

{
B_LF_PAGE     *leaf_page_p;
B_NL_PAGE     *cur_page_p;
OFFSET_ENTRY  offset_entry_num;
KEY_LENGTH    key_length, nl_key_length;
CHILD_PTR_COUNT *child_ptr_count_p=NULL;
REC_PTR_COUNT *rec_ptr_count_p;
char          *key_p;
OM_S_OBJID    *child_ptr_p=NULL;
long          *rec_ptr_p=NULL;
short         key_cmp_result;
KEY_LENGTH    real_len_1, real_len_2;
OM_S_RIP      rip;

cur_page_p = root_page_p;
nl_key_length = cur_page_p->Nl_key_length;

if (cur_page_p->Offset_entry_count == 0)
{

       *neighbor_objid_p = 0;
       return(DB_SUCCESS); /*  empty btree */
}
else
{
   if (IS_B_LEAF(cur_page_p->Page_type))
   {
      GET_LF_KEY_ENTRY((B_LF_PAGE *)cur_page_p,
                       (cur_page_p->Offset_entry_count-1), 
                        key_length, 
                        rec_ptr_count_p, 
                        key_p, 
                        rec_ptr_p                          );

   if ( cur_page_p->Key_type == KEY_STRING )
	{
	real_len_1 = strlen( new_key_p );
	real_len_2 = strlen( key_p );
	}
   else
	{
	real_len_1 = new_key_length;
	real_len_2 = key_length;
	}

      USER_COMPARE(user_compare_routine_p, new_key_p, key_p, real_len_1,
         real_len_2, key_cmp_result );

   }
   else
   {
      GET_NL_KEY_ENTRY(cur_page_p, 
                      (cur_page_p->Offset_entry_count-1), 
                      nl_key_length, 
                      key_length, 
                      child_ptr_count_p, 
                      key_p, 
                      child_ptr_p                           );

      USER_COMPARE(user_compare_routine_p, new_key_p, key_p,
         (KEY_LENGTH) (MIN(new_key_length, nl_key_length)), key_length,
         key_cmp_result );
      
   }
   

   /* Check if the new key has the highest key value. */
   if (key_cmp_result > 0) 
   {
      while (NOT_B_LEAF(cur_page_p->Page_type))
      {
         GET_NL_KEY_ENTRY(cur_page_p, (cur_page_p->Offset_entry_count-1), 
                          nl_key_length, key_length, child_ptr_count_p, key_p, 
                          child_ptr_p);

         cur_page_p = DEREF(B_NL_PAGE, (*(child_ptr_p + ((*child_ptr_count_p)-1))), rip);
	 if ( cur_page_p == NULL )
		return(DB_E_NULLDEREF);

      }   		
      GET_LF_KEY_ENTRY(cur_page_p, (cur_page_p->Offset_entry_count-1), 
                       key_length, rec_ptr_count_p, key_p, 
                       rec_ptr_p);	  
      *neighbor_objid_p = *rec_ptr_p;
      return(DB_SUCCESS);
   }



   /* Choose a leaf page for the new key */
   while (NOT_B_LEAF(cur_page_p->Page_type))
   {
     key_cmp_result = 1;

     for (offset_entry_num = 0; 
       (offset_entry_num < cur_page_p->Offset_entry_count) &&
       (key_cmp_result > 0);
       offset_entry_num++                                                    )
     {
       GET_NL_KEY_ENTRY(cur_page_p, offset_entry_num, nl_key_length, 
                        key_length, child_ptr_count_p, key_p, child_ptr_p);

       USER_COMPARE(user_compare_routine_p, new_key_p, key_p, 
          (KEY_LENGTH) (MIN(nl_key_length, new_key_length)), key_length,
          key_cmp_result );
     }


     if (key_cmp_result <= 0)
     {

         cur_page_p = DEREF(B_NL_PAGE, (*child_ptr_p), rip);
	 if ( cur_page_p == NULL )
		return(DB_E_NULLDEREF);

     }
     else
     {
         /* set record id to greatest leaf key value's record id */
         cur_page_p = DEREF(B_NL_PAGE, (*(child_ptr_p + ((*child_ptr_count_p)-1))), rip);
	 if ( cur_page_p == NULL )
		return(DB_E_NULLDEREF);

         while (NOT_B_LEAF(cur_page_p->Page_type))
         {
            GET_NL_KEY_ENTRY(cur_page_p, (cur_page_p->Offset_entry_count-1), 
                          nl_key_length, key_length, child_ptr_count_p, key_p, 
                          child_ptr_p);

            cur_page_p = DEREF(B_NL_PAGE, (*(child_ptr_p +
((*child_ptr_count_p)-1))), rip);
	    if ( cur_page_p == NULL )
		return(DB_E_NULLDEREF);
         }   		
         GET_LF_KEY_ENTRY(cur_page_p, (cur_page_p->Offset_entry_count-1), 
                       key_length, rec_ptr_count_p, key_p, 
                       rec_ptr_p);	  

      *neighbor_objid_p = *rec_ptr_p;

      return (DB_SUCCESS);
     }


    } /* while */


   leaf_page_p = (B_LF_PAGE *)cur_page_p;
   key_cmp_result = 1;

   /* Locate the right place in the leaf page chosen for new key. */

   for (offset_entry_num = 0; 
     (offset_entry_num < leaf_page_p->Offset_entry_count)
     && (key_cmp_result > 0);
     offset_entry_num++                                                    )
   {
     GET_LF_KEY_ENTRY(leaf_page_p, offset_entry_num, 
                      key_length, rec_ptr_count_p, key_p, rec_ptr_p);

     if ( leaf_page_p->Key_type == KEY_STRING )
	{
	real_len_1 = strlen( new_key_p );
	real_len_2 = strlen( key_p );
	}
     else
	{
	real_len_1 = new_key_length;
	real_len_2 = key_length;
	}

     USER_COMPARE(user_compare_routine_p, new_key_p, key_p, real_len_1, real_len_2, key_cmp_result );

   }


   *neighbor_objid_p = *rec_ptr_p;

   return(DB_SUCCESS);
 }
}
