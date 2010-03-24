#include <stdio.h>
#include <string.h>
#include "OMDB.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMindex.h"
#include "OMbtreedef.h"

/********************** DB_btree_adjust_tree **********************/
DB_btree_adjust_tree(
   KEY_LENGTH nl_key_length,
   int (*user_compare_routine_p)(),
   B_NL_PAGE **cur_page_pp,
   B_NL_PAGE **new_page_pp,
   char *cur_page_high_key_p,
   KEY_LENGTH *cur_page_high_key_length_p,
   char *new_page_low_key_p,
   KEY_LENGTH *new_page_low_key_length_p,
   B_PATH_HISTORY *insert_path_p)

{
   B_PATH_ENTRY      parent;
   B_NL_PAGE         *parent_page_p, *new_parent_page_p;
   KEY_LENGTH        key_length,
                     parent_page_high_key_length, 
                     new_parent_page_low_key_length;
   CHILD_PTR_COUNT   *child_ptr_count_p;
   char              *key_p, 
                     parent_page_high_key[200],
                     new_parent_page_low_key[200];
   OM_S_OBJID        *child_ptr_p;
   short             status,
                     key_exist, 
                     key_cmp_result;
   unsigned short    save_path_count;
   OM_S_RIP          rip;

   do
   {
      /* Initialize */
      new_parent_page_p = NULL;
 
      /* get parent page */
      parent = insert_path_p->Path_array[insert_path_p->Path_count-1];
      parent_page_p = DEREF(B_NL_PAGE, parent.Child_ptr, rip);
      if ( parent_page_p == NULL )
      {
#ifdef DEBUG
	printf("\n*** NULLDEREF in DB_btree_adjust_tree ***\n");
#endif

         return( DB_E_NULLDEREF );
      }
 
      GET_NL_KEY_ENTRY (parent_page_p, parent.Offset_entry_num,
         nl_key_length, key_length, child_ptr_count_p, key_p, child_ptr_p);
      USER_COMPARE(user_compare_routine_p, cur_page_high_key_p,
         key_p, (KEY_LENGTH) MIN(((KEY_LENGTH) *cur_page_high_key_length_p), nl_key_length),
         key_length, key_cmp_result);

      if ( key_cmp_result == 0 )
      {
         /* A key was split between pages and the new page has only one key 
            entry. */

         status = DB_btree_put_child_ptr(
                      nl_key_length,  
                      user_compare_routine_p, 
                      parent_page_p, 
                      parent.Offset_entry_num, 
                      (unsigned short) (parent.Child_entry_num +1), 
                      *child_ptr_count_p, 
                      *new_page_pp, 
                      &new_parent_page_p,
                      parent_page_high_key,
                      &parent_page_high_key_length, 
                      new_parent_page_low_key, 
                      &new_parent_page_low_key_length);
         if (status != 0) return(status);
      }		      
      else
      {
         /* The key entry in the  parent page now points to the new page instead
            of the current page. */
         child_ptr_p += parent.Child_entry_num;
         *child_ptr_p = REF(OM_S_OBJID, (*new_page_pp));
         if ( IF_EQ_OBJID(*child_ptr_p, NULL_OBJID) )
            return(DB_E_NULLIDREF);

         key_exist = 0;

         /*   if ((*cur_page_pp)->Offset_entry_count == 1)   */
         {
            /* We need to check if current page high key already
               exists in upper nonleaf pages. */

            if (insert_path_p->Path_array[insert_path_p->Path_count-1].Offset_entry_num != 0)
            {
               GET_NL_KEY_ENTRY(parent_page_p, --insert_path_p->
                  Path_array[insert_path_p->Path_count-1].Offset_entry_num,
                  nl_key_length, key_length, child_ptr_count_p, 
                  key_p, child_ptr_p);

               USER_COMPARE(user_compare_routine_p, key_p,
                  cur_page_high_key_p, key_length, (KEY_LENGTH)
                  MIN(nl_key_length, (KEY_LENGTH) *cur_page_high_key_length_p), 
	          key_cmp_result );

               if (key_cmp_result == 0)
               {       
                  key_exist = 1;
                  insert_path_p->Path_array[insert_path_p->Path_count -1].
                     Child_entry_num = *child_ptr_count_p - 1;
               }
               else
               {
                  insert_path_p->Path_array[insert_path_p->Path_count-1].
                     Offset_entry_num++;
               }
            }
            else 
            {
               if (insert_path_p->Path_count > 1)
               {
                  save_path_count = (unsigned short)
                     insert_path_p->Path_count--;
	          status = DB_btree_check_key_exist( nl_key_length,
	             user_compare_routine_p, &parent_page_p,
                     insert_path_p, save_path_count, cur_page_high_key_p, 
                     cur_page_high_key_length_p, &key_exist);
                  if (status != 0)
                     return(status);
               }
            }  
         }

         if (key_exist)
         {
            /* Current page high key exists in upper nonleaf pages.
               We need to add a new child_ptr entry. */

            status = DB_btree_put_child_ptr(nl_key_length,
               user_compare_routine_p, parent_page_p, insert_path_p->
               Path_array[insert_path_p->Path_count-1].Offset_entry_num, 
               ++insert_path_p->Path_array[insert_path_p->Path_count-1].
               Child_entry_num, *child_ptr_count_p, *cur_page_pp, 
               &new_parent_page_p, parent_page_high_key,
               &parent_page_high_key_length, new_parent_page_low_key, 
               &new_parent_page_low_key_length);
            if (status != 0)
               return (status);
         }
         else
         {
            /* otherwise, we only need to add one new key entry. */

            status = DB_btree_put_nl_key(nl_key_length, 
               user_compare_routine_p, parent_page_p, insert_path_p->
               Path_array[insert_path_p->Path_count-1].Offset_entry_num,
               *cur_page_high_key_length_p, cur_page_high_key_p,
               cur_page_pp, &new_parent_page_p, parent_page_high_key,  
               &parent_page_high_key_length, new_parent_page_low_key, 
               &new_parent_page_low_key_length);

            if (status != 0)
               return(status);
         }
      } /* else */
      *cur_page_pp = parent_page_p;
      insert_path_p->Path_count--;
      DB_MOV_N_BYTES(parent_page_high_key, cur_page_high_key_p, nl_key_length);
      *cur_page_high_key_length_p = parent_page_high_key_length;
      if ((*new_page_pp = new_parent_page_p ) != NULL)
      {
         DB_MOV_N_BYTES(new_parent_page_low_key, new_page_low_key_p,
            nl_key_length);
         *new_page_low_key_length_p = new_parent_page_low_key_length;
      }
   } /* do */
   while ( NOT_B_ROOT((*cur_page_pp)->Page_type) &&
      (*new_page_pp) != NULL); 	/* the end of while do loop */
   return (0);
}




/********************** DB_btree_adjust_tree_hk *********************/
/*
	This routine has been severely modified under extreme duress.
	Any simplicity or clarity introduced is purely coincidental
	and should not be misconstrued as the intent of the authors
	of the modification. 7/6/90
*/
DB_btree_adjust_tree_hk(
   KEY_LENGTH nl_key_length,
   int (*user_compare_routine_p)(),
   KEY_LENGTH new_key_length,
   char *new_key_p,
   B_NL_PAGE **cur_page_pp,
   B_NL_PAGE **new_page_pp,
   char *cur_page_high_key_p,
   KEY_LENGTH *cur_page_high_key_length_p,
   char *new_page_low_key_p,
   KEY_LENGTH *new_page_low_key_length_p,
   B_PATH_HISTORY *insert_path_p)

{
   B_NL_PAGE         *parent_page_p,
                     *new_parent_page_p;
   CHILD_PTR_COUNT   *child_ptr_count_p;
   OM_p_OBJID        child_ptr_p;
   B_PATH_ENTRY      parent;
   OM_S_RIP          rip;
   KEY_LENGTH        key_length,
                     parent_page_high_key_length, 
                     new_parent_page_low_key_length;
   char              *key_p, 
                     parent_page_high_key[200], new_parent_page_low_key[200];
   short             status,
                     key_cmp_result;

   if (*new_page_pp != NULL)
   {
      /*
       **	We must make sure the old parent page high key is still
       **	the high key after the split.  For example:
       **
       **		+------------+
       **		| ...    54  |
       **		+------------+
       **			 |
       **		 +-------------+ 
       **		 | 22 34 48 54 |
       **		 +-------------+
       **
       **	splits into:
       **
       **		+---------------+
       **		| ...    54  55 |
       **		+---------------+
       **			 /    \
       **		 +-------+   +----------+ 
       **		 | 22 34 |   | 48 54 55 |
       **		 +-------+   +----------+
       **
       **	Now the old parent page high key should be changed from
       **	54 to 34.
       */

      /* get parent page */

      parent = insert_path_p->Path_array[insert_path_p->Path_count-1];
      parent_page_p = DEREF(B_NL_PAGE, parent.Child_ptr, rip);
      if ( parent_page_p == NULL )
         return( DB_E_NULLDEREF);
	
      GET_NL_KEY_ENTRY(parent_page_p, parent.Offset_entry_num,
         nl_key_length, key_length, child_ptr_count_p, key_p,
         child_ptr_p);

      USER_COMPARE(user_compare_routine_p, cur_page_high_key_p,
         key_p, (KEY_LENGTH) MIN((KEY_LENGTH) *cur_page_high_key_length_p, nl_key_length),
	 key_length, key_cmp_result);

      if (key_cmp_result != 0)
      {
         *(KEY_LENGTH *)((char *)child_ptr_count_p - BYTES_KEY_LENGTH) =
            (KEY_LENGTH) MIN((KEY_LENGTH) *cur_page_high_key_length_p, nl_key_length);
         DB_MOV_N_BYTES(cur_page_high_key_p, key_p, nl_key_length);
      }
 
      /*
       **	This ensures that the first inserted non-leaf
       **	key entry is for the new page caused by a split.
       */

      *cur_page_high_key_length_p = new_key_length;
      DB_MOV_N_BYTES(new_key_p, cur_page_high_key_p, new_key_length);
      *cur_page_pp = *new_page_pp;
   }

   do
   {
      new_parent_page_p = NULL;
      /* get parent page */
      parent = insert_path_p->Path_array[insert_path_p->Path_count-1];

      parent_page_p = DEREF(B_NL_PAGE, parent.Child_ptr, rip);
      if ( parent_page_p == NULL )
      {
#ifdef DEBUG
	printf("\n*** NULLDEREF in DB_btree_adjust_tree_hk ***\n");
#endif
         return( DB_E_NULLDEREF);
      }
	
      GET_NL_KEY_ENTRY(parent_page_p, parent.Offset_entry_num, nl_key_length,  
         key_length, child_ptr_count_p, key_p, child_ptr_p);
 
      if (*new_page_pp != NULL)
      {
         /*
          **	Split:	because this is a new high key, we must add a new
          **		non-leaf key entry.
          */

         insert_path_p->Path_array[insert_path_p->Path_count-1].
            Offset_entry_num++;

         status = DB_btree_put_nl_key(nl_key_length, user_compare_routine_p,
            parent_page_p, insert_path_p->Path_array[insert_path_p->
            Path_count-1].Offset_entry_num, *cur_page_high_key_length_p,
            cur_page_high_key_p, cur_page_pp, &new_parent_page_p,
            parent_page_high_key, &parent_page_high_key_length,
            new_parent_page_low_key, &new_parent_page_low_key_length);

         if (status != 0)
            return(status);
      }
      else
      {
         /*
          **	No split
          */

         /* Change the key value to be the highest key. */
         if (*child_ptr_count_p == 1)
         {
            *(KEY_LENGTH *)((char *)child_ptr_count_p - BYTES_KEY_LENGTH) =
               MIN(new_key_length, nl_key_length);
            DB_MOV_N_BYTES(new_key_p, key_p, nl_key_length); 
         }
         else
         {
            (*child_ptr_count_p)--;
            parent_page_p->Space_used -= BYTES_CHILD_PTR;

            status = DB_btree_put_nl_key(nl_key_length,
               user_compare_routine_p, parent_page_p,
               parent_page_p->Offset_entry_count, new_key_length,
               new_key_p, cur_page_pp, &new_parent_page_p,
               parent_page_high_key, &parent_page_high_key_length,
               new_parent_page_low_key, &new_parent_page_low_key_length);

            if (status != 0)
               return(status); 
         } /* else */
      } /* else */
      *cur_page_pp = parent_page_p;
      insert_path_p->Path_count--;
      DB_MOV_N_BYTES(parent_page_high_key, cur_page_high_key_p,
         nl_key_length);
      *cur_page_high_key_length_p = parent_page_high_key_length;
      if ((*new_page_pp = new_parent_page_p ) != NULL)
      {
         DB_MOV_N_BYTES(new_parent_page_low_key, new_page_low_key_p,
            nl_key_length);
         *new_page_low_key_length_p = new_parent_page_low_key_length;
      }
   } /* do */
   while ( NOT_B_ROOT((*cur_page_pp)->Page_type) );

   return (0);
}




/*********************** DB_btree_change_path ***********************/

DB_btree_change_path(
   KEY_LENGTH nl_key_length,
   int (*user_compare_routine_p)(),
   B_PATH_HISTORY *insert_path_p,
   B_NL_PAGE *leaf_page_p,
   unsigned short save_path_count)

{
   B_NL_PAGE         *parent_page_p,
                     *child_page_p;
   CHILD_PTR_COUNT   *child_ptr_count_p;
   char              *key_p;
   long              *child_ptr;
   OM_S_OBJID        *child_ptr_p;
   OM_S_RIP          rip;
   short             status;
   KEY_LENGTH        key_length;

   parent_page_p = DEREF(B_NL_PAGE, insert_path_p->
      Path_array[insert_path_p->Path_count - 1].Child_ptr, rip);
   if ( parent_page_p == NULL )
   {
#ifdef DEBUG
	printf("\n*** NULLDEREF in DB_btree_change_path ***\n");
#endif

      return(DB_E_NULLDEREF);
   }

   GET_NL_KEY_ENTRY(parent_page_p, insert_path_p->
      Path_array[insert_path_p->Path_count - 1].Offset_entry_num,
      nl_key_length, key_length, child_ptr_count_p, key_p, child_ptr_p);

   if (((unsigned short) (*child_ptr_count_p -1) >
     insert_path_p->Path_array[insert_path_p->Path_count -1].Child_entry_num)
         ||
     ((unsigned short) (parent_page_p->Offset_entry_count - 1) > 
     insert_path_p->Path_array[insert_path_p->Path_count-1].Offset_entry_num))
   {
      if ((unsigned short) (*child_ptr_count_p -1) >
         insert_path_p->Path_array[insert_path_p->Path_count -1].
         Child_entry_num)
      {
         child_ptr = (long *) DEREF(int, (*(child_ptr_p + 
            ++insert_path_p->Path_array[insert_path_p->Path_count -1].
            Child_entry_num)), rip);
         if ( child_ptr == NULL )
         {
#ifdef DEBUG
		printf("\n*** NULLDEREF in DB_btree_change_path ***\n");
#endif
            return(DB_E_NULLDEREF);
         }
      }
      else
      {
         GET_NL_KEY_ENTRY(parent_page_p, ++insert_path_p->
            Path_array[insert_path_p->Path_count - 1].Offset_entry_num,
            nl_key_length, key_length, child_ptr_count_p, key_p,
            child_ptr_p);
         insert_path_p->Path_array[insert_path_p->Path_count - 1].
            Child_entry_num = 0;
         child_ptr = DEREF(long, (*child_ptr_p), rip);
         if ( child_ptr == NULL )
         {
#ifdef DEBUG
		printf("\n*** NULLDEREF in DB_btree_change_path ***\n");
#endif
            return(DB_E_NULLDEREF);
         }
      }

      /* Go down until reach the lowest nonleaf level. */
      while ((unsigned short) insert_path_p->Path_count < save_path_count)
      {
         child_page_p = (B_NL_PAGE *)child_ptr;
         GET_NL_KEY_ENTRY(child_page_p, 0, nl_key_length, key_length,
            child_ptr_count_p, key_p, child_ptr_p);

         /* Save information for insert path array and go one level down */
         insert_path_p->Path_array[insert_path_p->Path_count].Child_ptr =
            REF(OM_S_OBJID, child_ptr);
         if (IF_EQ_OBJID(insert_path_p->Path_array[insert_path_p->
            Path_count].Child_ptr, NULL_OBJID) )
            return(DB_E_NULLIDREF);

         insert_path_p->Path_array[insert_path_p->Path_count].
            Offset_entry_num = 0;
         insert_path_p->Path_array[insert_path_p->Path_count++].
            Child_entry_num = 0;
         child_ptr = DEREF(long, (*child_ptr_p), rip);
         if ( child_ptr == NULL )
         {
#ifdef DEBUG
		printf("\n*** NULLDEREF in DB_btree_change_path ***\n");
#endif
            return(DB_E_NULLDEREF);
         }
      } /* while */

      /* If child_ptrs are not matched, something went wrong in BTREE. */
      if (child_ptr !=(long *)leaf_page_p)
         return(1);
   } /* if */
   else
   {
      insert_path_p->Path_count--;
      status = DB_btree_change_path(nl_key_length,
         user_compare_routine_p, insert_path_p, leaf_page_p, save_path_count);
      if (status != 0)
      return(status);
   }
   return (0);
}



/************************ DB_btree_check_key_exist ***********************/    

DB_btree_check_key_exist(
   KEY_LENGTH nl_key_length,
   int (*user_compare_routine_p)(),
   B_NL_PAGE **parent_page_pp,
   B_PATH_HISTORY *insert_path_p,
   unsigned short save_path_count,
   char *old_page_high_key_p,
   KEY_LENGTH *old_page_high_key_length_p,
   short *key_exist_p)

{
   CHILD_PTR_COUNT   *child_ptr_count_p;
   char              *key_p;
   long              *child_ptr;
   OM_S_OBJID        *child_ptr_p;
   OM_S_RIP          rip;
   short             key_cmp_result;
   short             status;
   KEY_LENGTH        key_length;

   *parent_page_pp = DEREF(B_NL_PAGE, insert_path_p->
      Path_array[insert_path_p->Path_count-1].Child_ptr, rip);
   if (*parent_page_pp == NULL)
   {
#ifdef DEBUG
		printf("\n*** NULLDEREF in DB_btree_check_key_exist ***\n");
#endif
      return(DB_E_NULLDEREF);
   }
	
   if (insert_path_p->Path_array[insert_path_p->Path_count -1].
      Offset_entry_num > 0)
   {
      GET_NL_KEY_ENTRY((*parent_page_pp), --insert_path_p->
         Path_array[insert_path_p->Path_count -1].Offset_entry_num,
         nl_key_length, key_length, child_ptr_count_p, key_p, child_ptr_p);

      USER_COMPARE(user_compare_routine_p, key_p, old_page_high_key_p, 
         key_length, (KEY_LENGTH) MIN(nl_key_length,
         (KEY_LENGTH) *old_page_high_key_length_p), key_cmp_result );

      if (key_cmp_result == 0)
      {
         *key_exist_p = 1;

         child_ptr = (long *) DEREF(int, (*(child_ptr_p +
            *child_ptr_count_p -1)), rip);
         if ( child_ptr == NULL )
         {
#ifdef DEBUG
		printf("\n*** NULLDEREF in DB_btree_check_key_exist ***\n");
#endif
            return(DB_E_NULLDEREF);
         }

         insert_path_p->Path_array[insert_path_p->Path_count -1].
            Child_entry_num = *child_ptr_count_p - 1;

         /* Go down until reach the nonleaf level which we started with. */
         while ((unsigned short) insert_path_p->Path_count < save_path_count)
         {
            *parent_page_pp = (B_NL_PAGE *)child_ptr;
            GET_NL_KEY_ENTRY((*parent_page_pp), ((*parent_page_pp)->
               Offset_entry_count -1), nl_key_length, key_length,
               child_ptr_count_p, key_p, child_ptr_p);

            /* Save information for insert path array and go one level down */
            insert_path_p->Path_array[insert_path_p->Path_count].Child_ptr =
               REF(OM_S_OBJID, child_ptr);
            if (IF_EQ_OBJID(insert_path_p->Path_array[insert_path_p->
               Path_count].Child_ptr, NULL_OBJID) )
               return(DB_E_NULLIDREF);

            insert_path_p->Path_array[insert_path_p->Path_count].
               Offset_entry_num = (*parent_page_pp)->Offset_entry_count -1;
            insert_path_p->Path_array[insert_path_p->Path_count++].
               Child_entry_num = *child_ptr_count_p -1;
            child_ptr = (long *) DEREF(int, (*(child_ptr_p +
               *child_ptr_count_p -1)), rip);
            if ( child_ptr == NULL )
            {
#ifdef DEBUG
		printf("\n*** NULLDEREF in DB_btree_check_key_exist ***\n");
#endif
               return(DB_E_NULLDEREF);
            }
         } /* while */
      }
      else if (key_cmp_result < 0)
      {
         *key_exist_p = 0;
         insert_path_p->Path_array[insert_path_p->Path_count-1]
            .Offset_entry_num++;

         /* Go to the nonleaf level which we started with. */
         insert_path_p->Path_count = (unsigned char) save_path_count;

         *parent_page_pp = DEREF(B_NL_PAGE, insert_path_p->
            Path_array[insert_path_p->Path_count-1].Child_ptr, rip);
	 if ( *parent_page_pp == NULL )
         {
#ifdef DEBUG
		printf("\n*** NULLDEREF in DB_btree_check_key_exist ***\n");
#endif
            return(DB_E_NULLDEREF);
         }
      }
      else
         return(1);  /* Something went wrong in BTREE. */
   } /* if */
   else
   {
      if (insert_path_p->Path_count > 1)
      {
         insert_path_p->Path_count--;
         status = DB_btree_check_key_exist(nl_key_length,
            user_compare_routine_p, parent_page_pp, insert_path_p,
            save_path_count, old_page_high_key_p, 
            old_page_high_key_length_p, key_exist_p);
         if (status != 0)
            return(status);
      }
      else
      {
         /* Go to the nonleaf level which we started with. */

         insert_path_p->Path_count = (unsigned char) save_path_count;
         *parent_page_pp = DEREF(B_NL_PAGE, insert_path_p->
            Path_array[insert_path_p->Path_count-1].Child_ptr, rip);
	 if (*parent_page_pp == NULL)
         {
#ifdef DEBUG
	printf("\n*** NULLDEREF in DB_btree_check_key_exist ***\n");
#endif
            return(DB_E_NULLDEREF);
         }
      }
   } /* else */
   return (0);
}    


/****************************************************************/
/* This function is called recursively to search a BTREE for
   leaf page to hold a new key entry, an user compare
   routine is passed in to this function which will be used
   for comparing each index key with the new key. */

#define B_PARENTKEY_EQ (char)(1)

int DB_btree_choose_leaf(
   B_NL_PAGE *non_leaf_p,
   KEY_LENGTH nl_key_length,
   int (*user_compare_routine_p)(),
   char *new_key_p,
   KEY_LENGTH new_key_length,
   OM_p_OBJID new_rec_ptr_p,
   B_PATH_HISTORY *insert_path_p)

{
   long              *rec_ptr_p;
   int	             rtn,
                     return_code,
                     parent_level;
   B_LF_PAGE	     *leaf_p,
                     *next_lf_p;
   char		     *page_p,
                     *key_p,
                     *lf_key_p;
   OM_p_OBJID        child_ptr_p;
   CHILD_PTR_COUNT   *child_ptr_count_p, j;
   REC_PTR_COUNT     *rec_ptr_count_p;
   OM_S_RIP	     rip;
   KEY_LENGTH        key_length,
                     real_len_1,
                     real_len_2;
   unsigned short    i;

   if (NOT_B_LEAF(non_leaf_p->Page_type))
   {
      /* process non-leaf page */
      for (i=0; i<non_leaf_p->Offset_entry_count; i++ )
      {
         GET_NL_KEY_ENTRY(non_leaf_p, i, nl_key_length, key_length,
            child_ptr_count_p, key_p, child_ptr_p);

         USER_COMPARE(user_compare_routine_p, new_key_p, key_p, 
            (KEY_LENGTH) MIN(new_key_length, nl_key_length), key_length, rtn);

         if (rtn <= 0)
         {
            insert_path_p->Path_array[insert_path_p->Path_count].
               Offset_entry_num = i;
	    insert_path_p->Path_array[insert_path_p->Path_count].
	       Child_ptr = REF(OM_S_OBJID, non_leaf_p);
            parent_level = insert_path_p->Path_count;

            if (rtn == 0)
            {
               insert_path_p->Filler[0] = B_PARENTKEY_EQ;
            }
            for (j=0; j<*child_ptr_count_p; j++)
            {
               insert_path_p->Path_array[insert_path_p->
                  Path_count++].Child_entry_num = j;
               page_p = DEREF(char, (*( child_ptr_p + j )), rip);
               if (page_p == NULL)
                  return(DB_E_NULLDEREF);
               if ((return_code = DB_btree_choose_leaf((B_NL_PAGE *) page_p,
                     nl_key_length, user_compare_routine_p, new_key_p,
                     new_key_length, new_rec_ptr_p, insert_path_p )) !=
                     DB_CONTINUE)
               {
                  return(DB_SUCCESS);
               }
               insert_path_p->Path_count = parent_level;          
            }

            if ((rtn == 0) &&
               (i != (unsigned short) (non_leaf_p->Offset_entry_count - 1)))
            {
               GET_NL_KEY_ENTRY(non_leaf_p, (i + 1), nl_key_length,
                  key_length, child_ptr_count_p, key_p, child_ptr_p);
               page_p = DEREF(char, (*child_ptr_p), rip);
               if ( page_p == NULL )
                  return(DB_E_NULLDEREF);
               insert_path_p->Path_array[insert_path_p->Path_count].
                  Offset_entry_num++;
   	       insert_path_p->Path_array[insert_path_p->Path_count].
   	          Child_entry_num = 0;
	       insert_path_p->Path_count++;
	       insert_path_p->Filler[0] = B_PARENTKEY_EQ;
               return((return_code = DB_btree_choose_leaf((B_NL_PAGE *) page_p,
                  nl_key_length, user_compare_routine_p, new_key_p,
                  new_key_length, new_rec_ptr_p, insert_path_p)));
            }
            return(DB_CONTINUE);
         }  /* if new key <= present key */
      }  /* for loop */
   }  /* if non leaf page */
   else
   {
      /* process leaf page */

      leaf_p = (B_LF_PAGE *)non_leaf_p;
      GET_LF_KEY_ENTRY(leaf_p, leaf_p->Offset_entry_count - 1,
         key_length, rec_ptr_count_p, lf_key_p, rec_ptr_p);
      if ( leaf_p->Key_type == KEY_STRING )
      {
         real_len_1 = strlen( new_key_p );
         real_len_2 = strlen( lf_key_p );
      }
      else
      {
         real_len_1 = new_key_length;
         real_len_2 = key_length;
      }

      USER_COMPARE( user_compare_routine_p, new_key_p, lf_key_p,
         real_len_1, real_len_2, rtn );
      if (rtn == 0)
      {
         rec_ptr_p = rec_ptr_p + (*rec_ptr_count_p - 1);
         COMPARE_REC_PTR((OM_p_OBJID) new_rec_ptr_p,
            (OM_p_OBJID) rec_ptr_p, rtn);
         if ((rtn > 0) && !(IF_EQ_OBJID(leaf_p->Next_p, NULL_OBJID)) )
         {
            next_lf_p = DEREF(B_LF_PAGE, leaf_p->Next_p, rip);
            GET_LF_KEY_ENTRY(next_lf_p, 0, key_length, rec_ptr_count_p,
               lf_key_p, rec_ptr_p);
            if ( next_lf_p->Key_type == KEY_STRING )
            {
               real_len_1 = strlen( new_key_p );
               real_len_2 = strlen( lf_key_p );
            }
            else
            {
               real_len_1 = new_key_length;
               real_len_2 = key_length;
            }
            USER_COMPARE( user_compare_routine_p, new_key_p, lf_key_p,
               real_len_1, real_len_2, rtn );
            if (rtn == 0)
            {
               COMPARE_REC_PTR((OM_p_OBJID) new_rec_ptr_p,
                  (OM_p_OBJID) rec_ptr_p, rtn);
            }
         }
      }

      if (rtn > 0 && insert_path_p->Filler[0] == B_PARENTKEY_EQ
         && !(IF_EQ_OBJID(leaf_p->Next_p, NULL_OBJID)) )
      {
         return(DB_CONTINUE);
      }    
      else
      {
         insert_path_p->Path_array[insert_path_p->Path_count].Child_ptr =
            REF(OM_S_OBJID, leaf_p);
         return(DB_SUCCESS);
      }
   }
   return(1);
}



/************************** DB_btree_duplicate_key **********************/

DB_btree_duplicate_key(
   KEY_LENGTH nl_key_length,
   int (*user_compare_routine_p)(),
   KEY_LENGTH new_key_length,
   char *new_key_p,
   long *new_rec_ptr_p,
   B_LF_PAGE **leaf_page_pp,
   unsigned short offset_entry_num,
   REC_PTR_COUNT *rec_ptr_count_p,
   long *rec_ptr_p,
   B_LF_PAGE **new_leaf_page_pp,  
   char *leaf_page_high_key_p,
   KEY_LENGTH *leaf_page_high_key_length_p,
   char *new_leaf_page_low_key_p,
   KEY_LENGTH *new_leaf_page_low_key_length_p,
   B_PATH_HISTORY *insert_path_p)

{
   char              *next_key_p;
   long              *next_rec_ptr_p;
   B_LF_PAGE         *next_leaf_page_p;
   REC_PTR_COUNT     rec_ptr_num,
                     *next_rec_ptr_count_p;
   OM_S_RIP	     rip;
   short             key_cmp_result,
                     rp_cmp_result,
                     status;
   unsigned short    save_path_count;
   KEY_LENGTH        next_key_length,
                     real_len_1,
                     real_len_2;


   /* Initialization. */
   rp_cmp_result = 1;

   /* Locate the right place in the duplicate key entry for the new 
      record pointer. */

   for (rec_ptr_num = 0; (rec_ptr_num < *rec_ptr_count_p) &&
      (rp_cmp_result > 0); rec_ptr_p++, rec_ptr_num++)
   {
      COMPARE_REC_PTR(new_rec_ptr_p, rec_ptr_p, rp_cmp_result);
   }
   if (rp_cmp_result < 0)
   {
      /* The new record pointer is not a duplicate of any existing record 
         pointer.  So we are ready to put the new record pointer in. */

      status = DB_btree_put_record_pointer(user_compare_routine_p, 
         (*leaf_page_pp), offset_entry_num, (--rec_ptr_num), 
         new_key_length, *rec_ptr_count_p, new_rec_ptr_p, new_leaf_page_pp, 
         leaf_page_high_key_p, leaf_page_high_key_length_p, 
         new_leaf_page_low_key_p, new_leaf_page_low_key_length_p);
                                 
      if (status != 0)
         return(status);
   }
   else if (rp_cmp_result == 0)
   {
      /* The new record pointer is a duplicate of an existing record pointer.
         So put an error message and return. */
      return(1);
   }
   else /* rp_cmp_result > 0 */
   {
      /* The new record pointer is higher than all record pointers in the
         current duplicate key entry.  We need to check if the duplicate
         key expends to the next page before putting the new record pointer. */
      if ( (offset_entry_num < (unsigned short)
         ((*leaf_page_pp)->Offset_entry_count - 1)) ||
         ( IF_EQ_OBJID((*leaf_page_pp)->Next_p, NULL_OBJID)  ) )
	
      {
         status = DB_btree_put_record_pointer( 
                                    user_compare_routine_p, 
                                    (*leaf_page_pp), 
                                    offset_entry_num, 
                                    rec_ptr_num, 
                                    new_key_length, 
                                    *rec_ptr_count_p, 
                                    new_rec_ptr_p, 
                                    new_leaf_page_pp, 
                                    leaf_page_high_key_p, 
                                    leaf_page_high_key_length_p, 
                                    new_leaf_page_low_key_p, 
                                    new_leaf_page_low_key_length_p   );
                                 
         if (status != 0)
            return(status);
      }
      else 
      {
         next_leaf_page_p = DEREF(B_LF_PAGE, (*leaf_page_pp)->Next_p, rip);
         if ( next_leaf_page_p == NULL )
         {
#ifdef DEBUG
   printf("\n*** NULLDEREF in DB_btree_duplicate_key ***\n");
#endif
            return(DB_E_NULLDEREF);
         }

         GET_LF_KEY_ENTRY(next_leaf_page_p, 0, next_key_length,
            next_rec_ptr_count_p, next_key_p, next_rec_ptr_p);

         /* Compute the real key length for string keys!!! */

         if ( next_leaf_page_p->Key_type == KEY_STRING )
         {
            real_len_1= strlen(new_key_p);
            real_len_2 = strlen(next_key_p);
         }
         else
         {
            real_len_1 = new_key_length;
            real_len_2 = next_key_length;
         }

         USER_COMPARE(user_compare_routine_p, new_key_p, next_key_p,
            real_len_1, real_len_2, key_cmp_result );
         if (key_cmp_result != 0)
         {           
            status = DB_btree_put_record_pointer(
                                    user_compare_routine_p,  
                                    (*leaf_page_pp), 
                                    offset_entry_num, 
                                    rec_ptr_num, 
                                    new_key_length, 
                                    *rec_ptr_count_p, 
                                    new_rec_ptr_p, 
                                    new_leaf_page_pp, 
                                    leaf_page_high_key_p, 
                                    leaf_page_high_key_length_p, 
                                    new_leaf_page_low_key_p, 
                                    new_leaf_page_low_key_length_p   );
            if (status != 0)
               return(status);
         }
         else
         {
            *leaf_page_pp = next_leaf_page_p;
            offset_entry_num = 0;
            rec_ptr_count_p = next_rec_ptr_count_p;
            rec_ptr_p = next_rec_ptr_p;
            save_path_count = insert_path_p->Path_count;
            status = DB_btree_change_path (nl_key_length,
               user_compare_routine_p, insert_path_p,
               (B_NL_PAGE *) next_leaf_page_p, save_path_count);
            if (status != 0)
               return(status);
            status = DB_btree_duplicate_key(nl_key_length,
               user_compare_routine_p, new_key_length, new_key_p,
               new_rec_ptr_p, leaf_page_pp, 0, rec_ptr_count_p,
               rec_ptr_p, new_leaf_page_pp, leaf_page_high_key_p,
               leaf_page_high_key_length_p, new_leaf_page_low_key_p,
               new_leaf_page_low_key_length_p, insert_path_p);
            if (status != 0)
               return(status);
         }
      }
   } /* rp_cmp_result == 0 */

   return(0);
}




/********************* DB_btree_insert_highest_key ********************/

DB_btree_insert_highest_key(
   KEY_LENGTH nl_key_length,
   int (*user_compare_routine_p)(),
   KEY_LENGTH new_key_length,
   char *new_key_p,
   long *new_rec_ptr_p,
   B_NL_PAGE **cur_page_pp,
   B_NL_PAGE **new_page_pp,
   char *cur_page_high_key_p,
   KEY_LENGTH *cur_page_high_key_length_p, 
   char *new_page_low_key_p,
   KEY_LENGTH *new_page_low_key_length_p,
   B_PATH_HISTORY *insert_path_p)

{
   CHILD_PTR_COUNT   *child_ptr_count_p;
   char              *key_p;
   OM_S_OBJID        *child_ptr_p;
   OM_S_RIP          rip;
   short             status,
                     key_cmp_result;
   KEY_LENGTH        key_length;

   /* Initialization. */
   key_cmp_result = 1;

   /* Choose the leaf page which has the highest key. */
   while (NOT_B_LEAF((*cur_page_pp)->Page_type))
   {
      GET_NL_KEY_ENTRY((*cur_page_pp), ((*cur_page_pp)->Offset_entry_count-1), 
         nl_key_length, key_length, child_ptr_count_p, key_p,
         child_ptr_p);

      /* Save information for insert path array and go one level down */
      insert_path_p->Path_array[insert_path_p->Path_count].Child_ptr =
         REF(OM_S_OBJID, (*cur_page_pp));
      if ( IF_EQ_OBJID(insert_path_p->Path_array[insert_path_p->
         Path_count].Child_ptr, NULL_OBJID) )
         return(DB_E_NULLIDREF);

      insert_path_p->Path_array[insert_path_p->Path_count].
         Offset_entry_num = (*cur_page_pp)->Offset_entry_count - 1;
      insert_path_p->Path_array[insert_path_p->Path_count++].
         Child_entry_num = *child_ptr_count_p - 1;
      *cur_page_pp = DEREF(B_NL_PAGE, (*(child_ptr_p +
         (*child_ptr_count_p - 1))), rip);
      if ( *cur_page_pp == NULL )
      {
#ifdef DEBUG
		printf("\n*** NULLDEREF in DB_btree_insert_highest_key ***\n");
#endif
         return(DB_E_NULLDEREF);
      }
   }
   status = DB_btree_put_lf_key( 
                         user_compare_routine_p, 
                         ((B_LF_PAGE *)(*cur_page_pp)), 
                         (*cur_page_pp)->Offset_entry_count, 
                         new_key_length, 
                         new_key_p,
                         new_rec_ptr_p,  
                         (B_LF_PAGE **) new_page_pp, 
                         cur_page_high_key_p, 
                         cur_page_high_key_length_p, 
                         new_page_low_key_p, 
                         new_page_low_key_length_p);
   if (status != 0)
      return(status);
   return(0);
}


/*********************** DB_btree_insert_key **********************/

DB_btree_insert_key(
   KEY_LENGTH nl_key_length,
   int (*user_compare_routine_p)(),
   KEY_LENGTH new_key_length,
   char *new_key_p,
   long *new_rec_ptr_p,
   B_NL_PAGE **cur_page_pp,
   B_NL_PAGE **new_page_pp,
   char *cur_page_high_key_p,
   KEY_LENGTH *cur_page_high_key_length_p,
   char *new_page_low_key_p,
   KEY_LENGTH *new_page_low_key_length_p,
   B_PATH_HISTORY *insert_path_p)

{
   B_LF_PAGE      *leaf_page_p;
   REC_PTR_COUNT  *rec_ptr_count_p=NULL;
   char           *key_p;
   long           *rec_ptr_p=NULL;
   OM_S_RIP       rip;
   OFFSET_ENTRY   offset_entry_num;
   KEY_LENGTH     key_length,
                  real_len_1,
                  real_len_2;
   short          status,
                  key_cmp_result;

   /* Initialization. */
   key_cmp_result = 1;

   /* Choose the right leaf page for the new key. */

   status = DB_btree_choose_leaf(*cur_page_pp, nl_key_length,
      user_compare_routine_p, new_key_p, new_key_length,
      (OM_p_OBJID) new_rec_ptr_p, insert_path_p); 

   if (status != DB_SUCCESS)
      return(DB_E_BCHOOSELF); /* something went wrong in DB_btree_choose_leaf */
   leaf_page_p = (B_LF_PAGE *) DEREF(B_NL_PAGE, insert_path_p->
      Path_array[insert_path_p->Path_count].Child_ptr, rip);

   *cur_page_pp = (B_NL_PAGE *) leaf_page_p;

   /* Locate the right place in the leaf page choosed for new key. */
   for (offset_entry_num = 0; 
       (offset_entry_num < leaf_page_p->Offset_entry_count) &&
       (key_cmp_result > 0); offset_entry_num++)
   {
      GET_LF_KEY_ENTRY(leaf_page_p, offset_entry_num, key_length,
         rec_ptr_count_p, key_p, rec_ptr_p);

      /* Compute the real key length for string keys!!! */

      if ( leaf_page_p->Key_type == KEY_STRING )
      {
         real_len_1= strlen(new_key_p);
         real_len_2 = strlen(key_p);
      }
      else
      {
         real_len_1 = new_key_length;
         real_len_2 = key_length;
      }

      USER_COMPARE(user_compare_routine_p, new_key_p, key_p,
         real_len_1, real_len_2, key_cmp_result);
   }
   if (key_cmp_result != 0)
   {
      /* The new key is not a duplicate of any existing key.  So we are ready 
         to put the new key entry in. */
      if (!((key_cmp_result > 0) && (offset_entry_num ==
         leaf_page_p->Offset_entry_count)))
      {
         --offset_entry_num;
      }
      status = DB_btree_put_lf_key( 
                             user_compare_routine_p, 
                             leaf_page_p, 
                             offset_entry_num, 
                             new_key_length, 
                             new_key_p,
                             new_rec_ptr_p,  
                             (B_LF_PAGE **) new_page_pp, 
                             cur_page_high_key_p, 
                             cur_page_high_key_length_p, 
                             new_page_low_key_p, 
                             new_page_low_key_length_p);
      if (status != 0) return(status);
   }
   else if(key_cmp_result == 0)
   {
      if (leaf_page_p->Key_type & (unsigned char) BTREE_NODUP)
      {
         return(DB_B_NODUP_ALLOWED);
      }
      /* The new key is a duplicate of an existing key.  So we need only 
         to put the new record pointer in that existing key. */
      status = DB_btree_duplicate_key(
                             nl_key_length, 
                             user_compare_routine_p, 
                             new_key_length, 
                             new_key_p, 
			     new_rec_ptr_p,  
                             (B_LF_PAGE **) cur_page_pp,
                             --offset_entry_num, 
                             rec_ptr_count_p, 
                             rec_ptr_p, 
                             (B_LF_PAGE **) new_page_pp,
                             cur_page_high_key_p, 
                             cur_page_high_key_length_p, 
                             new_page_low_key_p, 
                             new_page_low_key_length_p, 
                             insert_path_p              );
      if (status != 0) return(status);
   }
   return(0);
}

/*************************** DB_btree_insert ****************************/

DB_btree_insert(
   B_NL_PAGE *cur_page_p,
   char *new_key_p,
   KEY_LENGTH new_key_length,
   long *new_rec_ptr_p,  
   int (*user_compare_routine_p)())

{
   B_NL_PAGE         *new_page_p;
   CHILD_PTR_COUNT   *child_ptr_count_p;
   REC_PTR_COUNT     *rec_ptr_count_p=NULL;
   OM_S_OBJID        *child_ptr_p;
   long              *rec_ptr_p=NULL;
   short             status, key_cmp_result;
   B_PATH_HISTORY    insert_path;
   char              *key_p,
                     cur_page_high_key[200],
                     new_page_low_key[200];
   KEY_LENGTH        real_len_1,
                     real_len_2,
                     nl_key_length,
                     key_length,
                     cur_page_high_key_length, 
                     new_page_low_key_length;

   /* initialization. */
   insert_path.Path_count = 0;
   new_page_p = NULL;
   nl_key_length = cur_page_p->Nl_key_length;
   if (cur_page_p->Offset_entry_count == 0)
   {
      /* Put the very first key. */
      status = DB_btree_put_lf_key(
                            user_compare_routine_p,  
                            (B_LF_PAGE *)cur_page_p, 
                            cur_page_p->Offset_entry_count, 
                            new_key_length, 
                            new_key_p,
                            new_rec_ptr_p, 0, 0, 0, 0, 0 );
      if (status != 0)
         return(status);
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
                        rec_ptr_p);

         /* Compute the real key length for string keys!!! */

         if ( cur_page_p->Key_type == KEY_STRING )
         {
            real_len_1= strlen(new_key_p);
            real_len_2 = strlen(key_p);
         }
         else
         {
            real_len_1 = new_key_length;
            real_len_2 = key_length;
         }

         USER_COMPARE(user_compare_routine_p, new_key_p, key_p,
            real_len_1, real_len_2, key_cmp_result );
      }
      else
      {
         GET_NL_KEY_ENTRY(cur_page_p, 
                      (cur_page_p->Offset_entry_count-1), 
                      nl_key_length, 
                      key_length, 
                      child_ptr_count_p, 
                      key_p, 
                      child_ptr_p);

         USER_COMPARE(user_compare_routine_p, new_key_p, key_p,
            (KEY_LENGTH) MIN(new_key_length, nl_key_length),
            key_length, key_cmp_result );
      }

      /* Check if the new key has the highest key value. */
      if (key_cmp_result > 0) 
      {
         status = DB_btree_insert_highest_key
             ( nl_key_length, user_compare_routine_p, new_key_length, 
              new_key_p, new_rec_ptr_p, &cur_page_p,
              &new_page_p, cur_page_high_key,
              &cur_page_high_key_length, new_page_low_key, 
              &new_page_low_key_length, &insert_path);
         if (status != 0)
            return(status);

         if (NOT_B_ROOT(cur_page_p->Page_type)) 
         {
            status = DB_btree_adjust_tree_hk
               ( nl_key_length, user_compare_routine_p, new_key_length, 
               new_key_p, &cur_page_p, &new_page_p, cur_page_high_key, 
               &cur_page_high_key_length, new_page_low_key, 
               &new_page_low_key_length, &insert_path);
            if (status != 0) return(status);    
         }
      }
      else
      {
         status = DB_btree_insert_key
             ( nl_key_length, user_compare_routine_p, new_key_length, 
              new_key_p, new_rec_ptr_p, &cur_page_p, 
              &new_page_p, cur_page_high_key,
              &cur_page_high_key_length, new_page_low_key, 
              &new_page_low_key_length, &insert_path);
         if (status != 0) return(status);

         if ((new_page_p != NULL) && (NOT_B_ROOT(cur_page_p->Page_type)))
         {
            status = DB_btree_adjust_tree
               ( nl_key_length, user_compare_routine_p, &cur_page_p, 
               &new_page_p, cur_page_high_key, 
               &cur_page_high_key_length, new_page_low_key, 
               &new_page_low_key_length, &insert_path);
            if (status != 0) return(status);    
         }
      } /* else */

      if (IS_B_ROOT(cur_page_p->Page_type) && (new_page_p != NULL))
      {
         status = DB_btree_make_root
             ( nl_key_length, user_compare_routine_p, cur_page_p, 
              new_page_p, cur_page_high_key,
              cur_page_high_key_length, new_page_low_key,
              new_page_low_key_length);
         if (status != 0) return(status);

#ifdef DEBUG
printf("\n****************************************************\n");
printf("************ After MAKE_ROOT in DB_btree_insert ******\n");
/* DB_dump_btree(cur_page_p,5); */
#endif
      }    
   } /* else */
   return(0);
}




/************************** DB_btree_make_root ***************************/
DB_btree_make_root(
   KEY_LENGTH nl_key_length,
   int (*user_compare_routine_p)(),
   B_NL_PAGE *root_page_p,
   B_NL_PAGE *new2_page_p,
   char *new1_page_high_key_p,
   KEY_LENGTH new1_page_high_key_length,
   char *new2_page_low_key_p,
   KEY_LENGTH new2_page_low_key_length)

{

B_NL_PAGE        *new1_page_p;
short            status, key_cmp_result;
KEY_LENGTH       key_length;
CHILD_PTR_COUNT  *child_ptr_count_p;
OM_S_OBJID       *child_ptr_p;
char             *new2_page_high_key_p;
REC_PTR_COUNT    *rec_ptr_count_p;
long             *rec_ptr_p;
KEY_LENGTH       real_len_1, real_len_2;
OM_S_RIP	 rip;


/* Initialization. */

/* Compute the real key length for string keys!!! */

if ( root_page_p->Key_type == KEY_STRING && IS_B_LEAF(root_page_p->Page_type) )
	{
	real_len_1 = strlen(new1_page_high_key_p);
	real_len_2 = strlen(new2_page_low_key_p);
	}
else
	{
	real_len_1 = new1_page_high_key_length;
	real_len_2 = new2_page_low_key_length;
	}

USER_COMPARE(user_compare_routine_p, new1_page_high_key_p, new2_page_low_key_p,    real_len_1, real_len_2, key_cmp_result );

/* Get the 1st new page for root split. */


GET_FREE_PAGE( B_NL_PAGE, new1_page_p, "OMbtree", rip );

#ifdef DEBUG
printf("\n*** CALLED GET_FREE_PAGE in DB_btree_make_root ***\n");
printf("root_page_p: %x\n", root_page_p);
printf("new2_page_p: %x\n", new2_page_p);
printf("new1_page_p: %x\n", new1_page_p);
#endif

if ( new1_page_p == NULL )
	return( DB_E_GETPAGEFAIL );

/* In order to keep the root in the same logical and physical location, 
   the current contents of the root need to be copied into the 1st new page. */


DB_MOV_N_BYTES(root_page_p, new1_page_p, DB_BYTES_BPAGE );
new1_page_p->Key_type = root_page_p->Key_type;
if (root_page_p->Page_type == B_LF_RT_PAGE)
    {
    new1_page_p->Page_type = B_LF_NR_PAGE;
    ((B_LF_PAGE *)new2_page_p)->Prior_p = REF( OM_S_OBJID, new1_page_p ); 
    if ( IF_EQ_OBJID( ((B_LF_PAGE *)new2_page_p)->Prior_p, NULL_OBJID) )
	return(DB_E_NULLIDREF);
	
    GET_LF_KEY_ENTRY((B_LF_PAGE *)new2_page_p,
                     (new2_page_p->Offset_entry_count-1), 
                      key_length, 
                      rec_ptr_count_p, 
                      new2_page_high_key_p, 
                      rec_ptr_p                          );
   }
else
    {
    new1_page_p->Page_type = B_NL_NR_PAGE;
    GET_NL_KEY_ENTRY(new2_page_p, 
                     (new2_page_p->Offset_entry_count-1), 
                     nl_key_length, 
                     key_length, 
                     child_ptr_count_p, 
                     new2_page_high_key_p, 
                     child_ptr_p                           );
    }

/* create two new entries for the empty root */

root_page_p->Nl_key_length = nl_key_length;
root_page_p->Page_type = B_NL_RT_PAGE;
root_page_p->Offset_entry_count = 0;
root_page_p->Space_used = BYTES_B_NL_HEADER;
root_page_p->Key_start = DB_BYTES_BPAGE;

if (key_cmp_result == 0 && new2_page_p->Offset_entry_count == 1)
    {
    status = DB_btree_put_nl_key( 
                             nl_key_length, 
                             user_compare_routine_p, 
                             root_page_p, 
                             0, 
                             new1_page_high_key_length, 
                             new1_page_high_key_p, 
                             &new1_page_p, 0, 0, 0, 0, 0 );
    if (status != 0) return(status);
    status = DB_btree_put_child_ptr(
                      nl_key_length, 
                      user_compare_routine_p, 
                      root_page_p, 
                      0, 
                      1,
                      1,  
                      new2_page_p, 0, 0, 0, 0, 0 );
    if (status != 0) return(status);
    }
else 
   {
    status = DB_btree_put_nl_key(
                             nl_key_length, 
                             user_compare_routine_p,  
                             root_page_p, 
                             0, 
                             new1_page_high_key_length, 
                             new1_page_high_key_p, 
                             &new1_page_p, 0, 0, 0, 0, 0 );
   if (status != 0) return(status);

   USER_COMPARE(user_compare_routine_p, new1_page_high_key_p,
      new2_page_high_key_p, (KEY_LENGTH) MIN(nl_key_length,
      new1_page_high_key_length), (KEY_LENGTH) MIN(nl_key_length,
      key_length), key_cmp_result );
   if (key_cmp_result == 0)
     {
     status = DB_btree_put_child_ptr(
                      nl_key_length, 
                      user_compare_routine_p, 
                      root_page_p, 
                      0, 
                      1,
                      1,  
                      new2_page_p, 0, 0, 0, 0, 0 );
     if (status != 0) return(status);
     }
   else
     {
     status = DB_btree_put_nl_key( 
                             nl_key_length, 
                             user_compare_routine_p, 
                             root_page_p, 
                             1, 
                             key_length, 
                             new2_page_high_key_p, 
                             &new2_page_p, 0, 0, 0, 0, 0 );
     if (status != 0) return(status);
     }
   }
return (0);
}




/*********************** DB_btree_put_lf_key *********************/
DB_btree_put_lf_key(
   int (*user_compare_routine_p)(),
   B_LF_PAGE *leaf_page_p,
   OFFSET_ENTRY offset_entry_num,
   KEY_LENGTH new_key_length,
   char *new_key_p,
   long *new_rec_ptr_p,
   B_LF_PAGE **new_leaf_page_pp,
   char *old_page_high_key_p, 
   KEY_LENGTH *old_page_high_key_length_p,
   char *new_page_low_key_p,
   KEY_LENGTH *new_page_low_key_length_p)

{                                 
   REC_PTR_COUNT    rec_ptr_count;
   char             new_key_entry[200], *new_key_entry_p;
   unsigned short   key_space_needed,
                    space_available, contiguous_space;
   short            key_cmp_result, status;
   KEY_LENGTH	      real_len_1, real_len_2;

   /* Pack the new key entry. */
   rec_ptr_count = 1;
   DB_MOV_N_BYTES(&new_key_length, new_key_entry, BYTES_KEY_LENGTH);
   new_key_entry_p = (char *)new_key_entry + BYTES_KEY_LENGTH;
   DB_MOV_N_BYTES(&rec_ptr_count, new_key_entry_p, BYTES_REC_PTR_COUNT);
   new_key_entry_p += BYTES_REC_PTR_COUNT;
   DB_MOV_N_BYTES(new_key_p, new_key_entry_p, new_key_length);
   new_key_entry_p += new_key_length;
   DB_MOV_N_BYTES(new_rec_ptr_p, new_key_entry_p, BYTES_REC_PTR);
   key_space_needed = LF_OFFSET_KEY_SPACE_1(new_key_length);
   space_available = DB_BYTES_BPAGE - (leaf_page_p)->Space_used;
   contiguous_space = (leaf_page_p)->Key_start - BYTES_B_LF_HEADER -
      BYTES_OFFSET_ENTRY * (leaf_page_p)->Offset_entry_count;
   if (space_available < key_space_needed)
   {
      status = DB_btree_split_leaf(leaf_page_p, new_leaf_page_pp,
         old_page_high_key_p, old_page_high_key_length_p, 
         new_page_low_key_p, new_page_low_key_length_p);
      if (status != 0)
         return(status);
      if (offset_entry_num <=
         (unsigned short) (leaf_page_p->Offset_entry_count - 1))
      {
         /* Put the new leaf key entry in the old leaf page. */
         PUT_LF_KEY_ENTRY(leaf_page_p, offset_entry_num,((char *)new_key_entry) );
      }
      else
      {
         /* Compute the real key length for string keys!!! */

         if ( leaf_page_p->Key_type == KEY_STRING )
         {
            real_len_1 = strlen(old_page_high_key_p);
            real_len_2 = strlen(new_page_low_key_p);
         }
         else
         {
            real_len_1 = *old_page_high_key_length_p;
            real_len_2 = *new_page_low_key_length_p;
         }

         USER_COMPARE(user_compare_routine_p, old_page_high_key_p,
            new_page_low_key_p, real_len_1, real_len_2, key_cmp_result);

         if (key_cmp_result == 0)
            offset_entry_num -= (leaf_page_p->Offset_entry_count - 1);
         else
            offset_entry_num -= leaf_page_p->Offset_entry_count;

         PUT_LF_KEY_ENTRY((*new_leaf_page_pp), offset_entry_num,
            ((char *)new_key_entry)); 
      }
   }
   else
   {
      if (contiguous_space < key_space_needed)
         COMPRESS_LF_PAGE( leaf_page_p );

      PUT_LF_KEY_ENTRY(leaf_page_p, offset_entry_num,
         ((char *)new_key_entry));
   }
   return(0);
}      




/************************ DB_btree_put_child_ptr *************************/

DB_btree_put_child_ptr(
   KEY_LENGTH nl_key_length,
   int (*user_compare_routine_p)(),
   B_NL_PAGE *nonleaf_page_p,
   unsigned short offset_entry_num,
   unsigned short child_entry_num,
   CHILD_PTR_COUNT child_ptr_count,
   B_NL_PAGE *new_child_page_p,
   B_NL_PAGE **new_nonleaf_page_pp,
   char *old_page_high_key_p,
   KEY_LENGTH *old_page_high_key_length_p,
   char *new_page_low_key_p,
   KEY_LENGTH *new_page_low_key_length_p)

{                 
   char              *key_p;
   OM_S_OBJID        *child_ptr_p,
                     new_child_ptr;
   CHILD_PTR_COUNT   *child_ptr_count_p;
   unsigned short    key_space_needed,
                     space_available,
                     contiguous_space;    
   KEY_LENGTH        key_length;
   short             key_cmp_result,
                     status;
 
#ifdef DEBUG
   printf("\n****** In PUT_CHILD_PTR ******\n");
#endif

   new_child_ptr = REF( OM_S_OBJID, new_child_page_p );
   space_available = DB_BYTES_BPAGE - (nonleaf_page_p)->Space_used + 
      NL_OFFSET_KEY_SPACE(nl_key_length, child_ptr_count);
   key_space_needed = NL_OFFSET_KEY_SPACE(nl_key_length, ++child_ptr_count);

   contiguous_space = (nonleaf_page_p)->Key_start - BYTES_B_NL_HEADER -
      BYTES_OFFSET_ENTRY * (nonleaf_page_p)->Offset_entry_count;

   if (space_available < key_space_needed)
   {
      status = DB_btree_split_nonleaf( nl_key_length, 
                            nonleaf_page_p, 
                            new_nonleaf_page_pp,   
                            old_page_high_key_p, old_page_high_key_length_p, 
                            new_page_low_key_p, new_page_low_key_length_p);
      if (status != 0)
         return(status);
	 
      if (offset_entry_num <
         (unsigned short) (nonleaf_page_p->Offset_entry_count - 1))
      {
         /* Put the new record pointer in the old nonleaf page. */

#ifdef DEBUG
   printf("\n*** In DB_btree_put_child_ptr ***\n");
   printf("child_ptr: %x\n", new_child_ptr);
#endif
         PUT_CHILD_PTR(nonleaf_page_p, offset_entry_num, child_entry_num,
            new_child_ptr, nl_key_length);
      }
      else if (offset_entry_num  ==
         (unsigned short) (nonleaf_page_p->Offset_entry_count - 1))
      {
         GET_NL_KEY_ENTRY(nonleaf_page_p, offset_entry_num, nl_key_length, 
            key_length, child_ptr_count_p, key_p, child_ptr_p);
         if (child_entry_num <= (*child_ptr_count_p))
         {
#ifdef DEBUG
   printf("\n*** In DB_btree_put_child_ptr ***\n");
   printf("child_ptr: %x\n", new_child_ptr);
#endif
            PUT_CHILD_PTR(nonleaf_page_p, offset_entry_num,
               child_entry_num, new_child_ptr, nl_key_length);
         }
         else
         {
            child_entry_num -= *child_ptr_count_p;

#ifdef DEBUG
   printf("\n*** In DB_btree_put_child_ptr ***\n");
   printf("child_ptr: %x\n", new_child_ptr);
#endif

            PUT_CHILD_PTR((*new_nonleaf_page_pp), 0, child_entry_num,
               new_child_ptr, nl_key_length);
         }
      }
      else
      {
         USER_COMPARE(user_compare_routine_p, old_page_high_key_p,
            new_page_low_key_p, *old_page_high_key_length_p,
            *new_page_low_key_length_p, key_cmp_result );

         if (key_cmp_result == 0)
            offset_entry_num -= (nonleaf_page_p->Offset_entry_count - 1);
         else
            offset_entry_num -= nonleaf_page_p->Offset_entry_count;

         contiguous_space = (*new_nonleaf_page_pp)->Key_start -
            BYTES_B_NL_HEADER - BYTES_OFFSET_ENTRY *
            (*new_nonleaf_page_pp)->Offset_entry_count;

         if (contiguous_space < key_space_needed)
         {
            MOVE_NONLEAF_KEY((*new_nonleaf_page_pp),
               offset_entry_num, child_entry_num, child_ptr_count,
               &new_child_ptr, nl_key_length);
         }
         else
         {
#ifdef DEBUG
   printf("\n*** In DB_btree_put_child_ptr ***\n");
   printf("child_ptr: %x\n", new_child_ptr);
#endif

            PUT_CHILD_PTR((*new_nonleaf_page_pp), offset_entry_num,
               child_entry_num, new_child_ptr, nl_key_length);
	 }
      }
   }
   else
   {
      if (contiguous_space < key_space_needed)
      {
         MOVE_NONLEAF_KEY(nonleaf_page_p, offset_entry_num,
            child_entry_num, child_ptr_count, &new_child_ptr, nl_key_length);
      }
      else
      {
#ifdef DEBUG
   printf("\n*** In DB_btree_put_child_ptr ***\n");
   printf("child_ptr: %x\n", new_child_ptr);
#endif

         PUT_CHILD_PTR(nonleaf_page_p, offset_entry_num, child_entry_num,
            new_child_ptr, nl_key_length);
      }
   }
   return(0);
}




/**************************** DB_btree_put_nl_key ****************************/

DB_btree_put_nl_key(
   KEY_LENGTH nl_key_length,
   int (*user_compare_routine_p)(),
   B_NL_PAGE *nonleaf_page_p,
   unsigned short offset_entry_num,
   KEY_LENGTH new_key_length,
   char *new_key_p,
   B_NL_PAGE **new_page_pp,
   B_NL_PAGE **new_nonleaf_page_pp,
   char *old_page_high_key_p,
   KEY_LENGTH *old_page_high_key_length_p,
   char *new_page_low_key_p,
   KEY_LENGTH *new_page_low_key_length_p)  

{                                        
   OM_S_OBJID        insert_page_p;
   CHILD_PTR_COUNT   child_ptr_count;
   char              new_key_entry[200], 
                     *new_key_entry_p;
   short             key_cmp_result, status;
   unsigned short    key_space_needed,
                     space_available,
                     contiguous_space;  

   /* Pack the new key entry. */

   child_ptr_count = 1;
   new_key_length = MIN(nl_key_length, new_key_length);
   DB_MOV_N_BYTES(&new_key_length, new_key_entry, BYTES_KEY_LENGTH);
   new_key_entry_p = (char *)new_key_entry + BYTES_KEY_LENGTH;
   DB_MOV_N_BYTES(&child_ptr_count, new_key_entry_p, BYTES_CHILD_PTR_COUNT);
   new_key_entry_p += BYTES_CHILD_PTR_COUNT;
   DB_MOV_N_BYTES(new_key_p, new_key_entry_p, new_key_length);
   new_key_entry_p += nl_key_length;
   insert_page_p = REF(OM_S_OBJID, (*new_page_pp));

#ifdef DEBUG
   printf("\n*** DB_btree_put_nl_key ***\n");
   printf("*new_page_pp: %x\n", *new_page_pp);
   printf("insert_page_p after REF: %x\n", insert_page_p);
#endif

   if ( IF_EQ_OBJID(insert_page_p, NULL_OBJID) )
      return(DB_E_NULLIDREF);
	
   DB_MOV_N_BYTES(&insert_page_p, new_key_entry_p, BYTES_CHILD_PTR);

#ifdef DEBUG
   printf("After MOV_N_BYTES into new_key_entry_p\n");
   printf("*new_key_entry_p: %x\n", *(OM_p_OBJID)(new_key_entry_p));
#endif

   key_space_needed = NL_OFFSET_KEY_SPACE_1(nl_key_length);
   space_available = DB_BYTES_BPAGE - (nonleaf_page_p)->Space_used;
   contiguous_space = (nonleaf_page_p)->Key_start - BYTES_B_NL_HEADER -
      BYTES_OFFSET_ENTRY * (nonleaf_page_p)->Offset_entry_count;

   if (space_available < key_space_needed)
   {
      status = DB_btree_split_nonleaf( nl_key_length, 
                            nonleaf_page_p, 
                            new_nonleaf_page_pp,  
                            old_page_high_key_p, old_page_high_key_length_p, 
                            new_page_low_key_p, new_page_low_key_length_p);
      if (status != 0)
         return(status);
      if (offset_entry_num <=
         (unsigned short) (nonleaf_page_p->Offset_entry_count - 1))
      {
         /* Put the new nonleaf key entry in the old nonleaf page. */

         PUT_NL_KEY_ENTRY(nonleaf_page_p, offset_entry_num, 
            ((char *)new_key_entry), nl_key_length);
      }
      else
      {
         USER_COMPARE(user_compare_routine_p, old_page_high_key_p,
            new_page_low_key_p, *old_page_high_key_length_p,
            *new_page_low_key_length_p, key_cmp_result );
	    
         if (key_cmp_result == 0)
            offset_entry_num -= (nonleaf_page_p->Offset_entry_count - 1);
         else
            offset_entry_num -= nonleaf_page_p->Offset_entry_count;

         PUT_NL_KEY_ENTRY( (*new_nonleaf_page_pp), offset_entry_num, 
            ((char *)new_key_entry), nl_key_length);
      }
   }
   else
   {
      if (contiguous_space < key_space_needed)
         COMPRESS_NL_PAGE( nonleaf_page_p, nl_key_length);
      PUT_NL_KEY_ENTRY(nonleaf_page_p, offset_entry_num, 
         ((char *)new_key_entry), nl_key_length);
   }

#ifdef DEBUG
  GET_NL_KEY_ENTRY(nonleaf_page_p, offset_entry_num, nl_key_length, 
    tstkey_len, tstchild_ptr_count_p, tstkey_p, tstchild_ptr_p);
  printf("\n*** GET AFTER PUT in put_nl_key ***\n");
  printf("Got page : %x\n", nonleaf_page_p);
  printf("offset_entry_num: %d\n", offset_entry_num);
  printf("nl_key_length: %d\n", nl_key_length);
  printf("tstkey_len: %d\n", tstkey_len);
  printf(" tstchild_ptr_count_p: %x\n", tstchild_ptr_count_p);
  printf("*tstchild_ptr_count_p: %d\n", *tstchild_ptr_count_p);
  printf("tstkey_p: %x\n", tstkey_p);
  printf(" tstchild_ptr_p: %x\n", tstchild_ptr_p);
  printf("*tstchild_ptr_p: %x\n", *tstchild_ptr_p);
  printf("**** DUMP BTREE from PUT_NL_KEY *****\n");
/* DB_dump_btree(nonleaf_page_p,5); */
#endif

   return(0);
}




/*********************** DB_btree_put_record_pointer *********************/
DB_btree_put_record_pointer(
   int (*user_compare_routine_p)(),
   B_LF_PAGE *leaf_page_p,
   unsigned short offset_entry_num,
   unsigned short rec_ptr_num,
   KEY_LENGTH key_length,
   REC_PTR_COUNT rec_ptr_count,
   long *new_rec_ptr_p,
   B_LF_PAGE **new_leaf_page_pp,
   char *old_page_high_key_p,
   KEY_LENGTH *old_page_high_key_length_p,
   char *new_page_low_key_p,
   KEY_LENGTH *new_page_low_key_length_p)    

{                                                                
     REC_PTR_COUNT    *rec_ptr_count_p;
     long        *rec_ptr_p;
     char             *key_p;
     unsigned short   key_space_needed, 
                      space_available, contiguous_space;
     short            key_cmp_result, status;
     KEY_LENGTH       real_len_1, real_len_2;

     space_available = DB_BYTES_BPAGE - (leaf_page_p)->Space_used + 
		LF_OFFSET_KEY_SPACE(key_length, rec_ptr_count);
     key_space_needed = LF_OFFSET_KEY_SPACE(key_length, ++rec_ptr_count);
     contiguous_space 
               = (leaf_page_p)->Key_start 
               - BYTES_B_LF_HEADER
               - BYTES_OFFSET_ENTRY * (leaf_page_p)->Offset_entry_count;
     if (space_available < key_space_needed)
         {
         status = DB_btree_split_leaf( 
                         leaf_page_p, 
                         new_leaf_page_pp, 
                         old_page_high_key_p, old_page_high_key_length_p, 
                         new_page_low_key_p, new_page_low_key_length_p);
         if (status != 0) return(status);
	 

         if (offset_entry_num <
            (unsigned short) (leaf_page_p->Offset_entry_count - 1))
            {
            /* Put the new record pointer in the old leaf page. */
            PUT_REC_PTR(leaf_page_p, offset_entry_num, rec_ptr_num, 
                         new_rec_ptr_p);
	    }
         else if (offset_entry_num  ==
            (unsigned short) (leaf_page_p->Offset_entry_count - 1))
            {
            GET_LF_KEY_ENTRY(leaf_page_p, offset_entry_num, key_length, 
                             rec_ptr_count_p, key_p,rec_ptr_p);
            if (rec_ptr_num <= (unsigned short) (*rec_ptr_count_p))
                {
                PUT_REC_PTR(leaf_page_p, offset_entry_num, rec_ptr_num,
                            new_rec_ptr_p);
               }
            else
               {
                rec_ptr_num -= *rec_ptr_count_p;

                PUT_REC_PTR( (*new_leaf_page_pp), 0, rec_ptr_num, new_rec_ptr_p);
               }
	    }
         else
            {

     /* Compute the real key length for string keys!!! */

     if ( leaf_page_p->Key_type == KEY_STRING )
	{
	real_len_1= strlen(old_page_high_key_p);
	real_len_2 = strlen(new_page_low_key_p);
	}
     else
	{
	real_len_1 = *old_page_high_key_length_p;
	real_len_2 = *new_page_low_key_length_p;
	}

            USER_COMPARE(user_compare_routine_p, old_page_high_key_p, new_page_low_key_p, real_len_1, real_len_2, key_cmp_result );

	    if (key_cmp_result == 0)
               offset_entry_num -= (leaf_page_p->Offset_entry_count - 1);
            else
               offset_entry_num -= leaf_page_p->Offset_entry_count;
            contiguous_space 
                = (*new_leaf_page_pp)->Key_start 
                - BYTES_B_LF_HEADER
                - BYTES_OFFSET_ENTRY * (*new_leaf_page_pp)->Offset_entry_count;

            if (contiguous_space < key_space_needed)
	      {
	      MOVE_LEAF_KEY((*new_leaf_page_pp), offset_entry_num, rec_ptr_num,new_rec_ptr_p);
	      }
	    else
	      {
              PUT_REC_PTR((*new_leaf_page_pp), offset_entry_num, rec_ptr_num, new_rec_ptr_p);
	      }
            }
         }
     else
         {
         if (contiguous_space < key_space_needed)
	    {
 	    MOVE_LEAF_KEY(leaf_page_p, offset_entry_num, rec_ptr_num, new_rec_ptr_p);
	    }
	 else
	    {
            PUT_REC_PTR(leaf_page_p, offset_entry_num, rec_ptr_num, new_rec_ptr_p);
	    }
	 }
     return(0);
}
 


#define MIN_RID_COUNT ( 1 )
#define MIN_CHILD_COUNT ( 1 )

/************************* DB_btree_split_leaf *********************/
DB_btree_split_leaf(
   B_LF_PAGE *full_page_p,
   B_LF_PAGE **empty_page_pp,
   char *full_high_key_p,
   KEY_LENGTH *full_high_key_len_p,
   char *empty_low_key_p,
   KEY_LENGTH *empty_low_key_len_p)

{

KEY_LENGTH       key_len=0;
REC_PTR_COUNT    *count_p=NULL;
char             *key_p=NULL;
long		 *rid_array_p=NULL;
B_LF_PAGE        *update_page_p;
unsigned short   f_next_entry_offset_index, e_next_entry_offset_index;
unsigned short   f_current_space; /* # of bytes that have been assinged  */
				  /* to the full page already            */
unsigned short   save_space;
unsigned short   e_move_entry_count;
int              i;
int              spliting_point;
OM_S_RIP	 rip;



spliting_point = full_page_p->Space_used / 2;

/* update next and prior pointers in the      */
/* full, empty, and updated (full->next) page */
/* AND, initialize the empty page             */

GET_FREE_PAGE( B_LF_PAGE, (*empty_page_pp), "OMbtree", rip);

#ifdef DEBUG
printf("\n*** CALLED GET_FREE_PAGE in DB_btree_split_leaf ***\n");
printf("*empty_page_pp: %x\n", *empty_page_pp);
#endif

if ( *empty_page_pp == NULL )
	return( DB_E_GETPAGEFAIL );

(*empty_page_pp)->Key_type = full_page_p->Key_type;

if( full_page_p->Page_type == B_LF_RT_PAGE)
   (*empty_page_pp)->Page_type = B_LF_NR_PAGE;
else
   (*empty_page_pp)->Page_type = full_page_p->Page_type;
(*empty_page_pp)->Nl_key_length = full_page_p->Nl_key_length;
(*empty_page_pp)->Offset_entry_count = 0;
(*empty_page_pp)->Space_used = BYTES_B_LF_HEADER;
(*empty_page_pp)->Key_start = DB_BYTES_BPAGE;
(*empty_page_pp)->Next_p = NULL_OBJID;
update_page_p =DEREF( B_LF_PAGE, full_page_p->Next_p, rip);

(*empty_page_pp)->Prior_p = REF(OM_S_OBJID, full_page_p);

(full_page_p->Next_p) = REF(OM_S_OBJID, (*empty_page_pp));

if ( update_page_p != NULL )
  {

    ((*empty_page_pp)->Next_p) =  REF(OM_S_OBJID, update_page_p);

    (update_page_p->Prior_p) = REF(OM_S_OBJID, (*empty_page_pp));

  } /* if */
f_next_entry_offset_index = 0;
f_current_space = BYTES_B_LF_HEADER;		       
e_next_entry_offset_index = 0;

/*  find the dividing point to split the page */
/*                                            */

while ( (f_current_space < (unsigned short) spliting_point) && 
        (f_next_entry_offset_index <= full_page_p->Offset_entry_count) )
  {
     GET_LF_KEY_ENTRY( full_page_p, f_next_entry_offset_index, key_len, 
			 count_p, key_p, rid_array_p);
     f_current_space += LF_OFFSET_KEY_SPACE( key_len, *count_p);
     f_next_entry_offset_index++;
  }/* while */

DB_MOV_N_BYTES(key_p, full_high_key_p, key_len);
*full_high_key_len_p = key_len;

e_move_entry_count = full_page_p->Offset_entry_count - 
		     f_next_entry_offset_index;

/* if the center entry has more than one record id then */
/* split the entry between two pages                    */

if ( (*count_p != 1) && ((int) f_current_space != spliting_point) )
  {
         f_next_entry_offset_index--;
         save_space = f_current_space;
	 f_current_space -= ((*count_p - 1) * BYTES_REC_PTR );
         i = 1;
         while ((f_current_space < (unsigned short) spliting_point) &&
            ((unsigned short) i <= *count_p))
	    {
	      f_current_space += BYTES_REC_PTR;
	      i++;
            } /*while*/
         if (( i <= MIN_RID_COUNT ) && (f_next_entry_offset_index != 0)) 
            /* put whole entry in empty_page */
            {
              full_page_p->Offset_entry_count = f_next_entry_offset_index;
	      full_page_p->Space_used = save_space - 
	       			   LF_OFFSET_KEY_SPACE( key_len, *count_p );
              e_move_entry_count++;
              GET_LF_KEY_ENTRY( full_page_p, f_next_entry_offset_index - 1,
		                key_len, count_p, key_p, rid_array_p); 
              DB_MOV_N_BYTES(key_p, full_high_key_p, key_len);
              *full_high_key_len_p = key_len;
            }
         else if (((unsigned short) i >=
                  (unsigned short) (*count_p - MIN_RID_COUNT) ) &&
                  (full_page_p->Offset_entry_count > 1) )
            /* move all into full_page */
            {
	      f_next_entry_offset_index++;
              full_page_p->Offset_entry_count = f_next_entry_offset_index;
	      full_page_p->Space_used = save_space;
            }
         else        
            {
             *count_p -= i;
             PUT_LF_KEY_ENTRY_P( (*empty_page_pp), 
				 (char *)count_p - BYTES_KEY_LENGTH, 
	                         rid_array_p + i);
             *count_p = i;    
             e_next_entry_offset_index = 1;
             full_page_p->Space_used = f_current_space;
             full_page_p->Offset_entry_count = f_next_entry_offset_index + 1;
             f_next_entry_offset_index++;
            }
  } /* if */
else
  {
    full_page_p->Offset_entry_count = f_next_entry_offset_index;
    full_page_p->Space_used = f_current_space ;
  }

for ( i = e_next_entry_offset_index; 
      (unsigned short) i < (unsigned short) (e_move_entry_count +
      e_next_entry_offset_index);
      i++)
 {
   GET_LF_KEY_ENTRY(full_page_p, f_next_entry_offset_index,
                       key_len, count_p, 
                       key_p,  rid_array_p );
   f_next_entry_offset_index++;
   PUT_LF_KEY_ENTRY ( (*empty_page_pp), i, 
                      (char *)count_p - BYTES_KEY_LENGTH );
 } /* for */ 

/* compress full_page */

COMPRESS_LF_PAGE( full_page_p );
GET_LF_KEY_ENTRY( (*empty_page_pp), 0, key_len, count_p, key_p, rid_array_p);
DB_MOV_N_BYTES(key_p, empty_low_key_p, key_len);
*empty_low_key_len_p = key_len;

return (0);
}/* end */




/************************* DB_btree_split_nonleaf *********************/
DB_btree_split_nonleaf(
   KEY_LENGTH nl_key_length,
   B_NL_PAGE *full_page_p,
   B_NL_PAGE **empty_page_pp,
   char *full_high_key_p,
   KEY_LENGTH *full_high_key_len_p,
   char *empty_low_key_p,
   KEY_LENGTH *empty_low_key_len_p)

{
   CHILD_PTR_COUNT   *count_p=NULL;
   char              *key_p=NULL;
   OM_p_OBJID        child_array_p=NULL;
   int               i, spliting_point;
   OM_S_RIP	     rip;
   KEY_LENGTH        key_len=0;
   unsigned short    f_next_entry_offset_index,
                     e_next_entry_offset_index,
                     f_current_space, /* bytes already assigned to full page */
                     save_space,
                     e_move_entry_count;

#ifdef DEBUG
   printf("\n*** In SPLIT_NONLEAF PAGE ***\n");
#endif

   spliting_point = full_page_p->Space_used / 2;

   GET_FREE_PAGE( B_NL_PAGE, (*empty_page_pp), "OMbtree", rip);

#ifdef DEBUG
   printf("\n*** CALLED GET_FREE_PAGE in DB_btree_split_nonleaf ***\n");
   printf("*empty_page_pp: %x\n", *empty_page_pp);
#endif

   if ( *empty_page_pp == NULL )
      return( DB_E_GETPAGEFAIL );

   (*empty_page_pp)->Key_type = full_page_p->Key_type;

   if ( *empty_page_pp == NULL )
      return( DB_E_GETPAGEFAIL );
   if( full_page_p->Page_type == B_NL_RT_PAGE)
      (*empty_page_pp)->Page_type = B_NL_NR_PAGE;
   else
      (*empty_page_pp)->Page_type = full_page_p->Page_type;
   (*empty_page_pp)->Nl_key_length = full_page_p->Nl_key_length;
   (*empty_page_pp)->Offset_entry_count = 0;
   (*empty_page_pp)->Space_used = BYTES_B_NL_HEADER;
   (*empty_page_pp)->Key_start = DB_BYTES_BPAGE;

   f_next_entry_offset_index = 0;
   f_current_space = BYTES_B_NL_HEADER;		       
   e_next_entry_offset_index = 0;

   /*  find the dividing point to split the page */
   while ( (f_current_space < (unsigned short) spliting_point) && 
      f_next_entry_offset_index <= full_page_p->Offset_entry_count )
   {
      GET_NL_KEY_ENTRY(full_page_p, f_next_entry_offset_index,
         nl_key_length, key_len, count_p, key_p, child_array_p);
      f_current_space += NL_OFFSET_KEY_SPACE( nl_key_length, *count_p);
      f_next_entry_offset_index++;
   }

   DB_MOV_N_BYTES(key_p, full_high_key_p, key_len);
   *full_high_key_len_p = key_len;
   e_move_entry_count = full_page_p->Offset_entry_count - 
      f_next_entry_offset_index;

   /* if the center entry has more than one record id then */
   /* split the entry between two pages                    */
   if ((*count_p != 1) && ((int) f_current_space != spliting_point))
   {
      f_next_entry_offset_index--;
      save_space = f_current_space;
      f_current_space -= ((*count_p - 1) * BYTES_CHILD_PTR);
      i = 1;
      while ((f_current_space < (unsigned short) spliting_point) &&
         (i <= (int) *count_p))
      {
         f_current_space += BYTES_CHILD_PTR;
         i++;
      }

      if ((i <= MIN_CHILD_COUNT) && (f_next_entry_offset_index != 0))
      {
         /* put hole entry in empty_page */
         full_page_p->Offset_entry_count = f_next_entry_offset_index;
         full_page_p->Space_used = save_space - 
            NL_OFFSET_KEY_SPACE( nl_key_length, *count_p );
         e_move_entry_count++;
         GET_NL_KEY_ENTRY( full_page_p, f_next_entry_offset_index - 1,
            nl_key_length, key_len, count_p, key_p, child_array_p); 
         DB_MOV_N_BYTES(key_p, full_high_key_p, key_len);
         *full_high_key_len_p = key_len;
      }
      else if (( i >= (int) (*count_p - MIN_CHILD_COUNT)) &&
         (full_page_p->Offset_entry_count > 1) )
      {
         /* move all into full_page */
         f_next_entry_offset_index++;
         full_page_p->Offset_entry_count = f_next_entry_offset_index;
         full_page_p->Space_used = save_space;
      }
      else        
      {
         *count_p -= i;
         PUT_NL_KEY_ENTRY_P((*empty_page_pp),
            (char *) count_p - BYTES_KEY_LENGTH, 
            (child_array_p + i), nl_key_length);
         *count_p = i;    
         e_next_entry_offset_index = 1;
         full_page_p->Space_used = f_current_space;
         full_page_p->Offset_entry_count = f_next_entry_offset_index + 1;
         f_next_entry_offset_index++;
      }
   }
   else
   {
      full_page_p->Offset_entry_count = f_next_entry_offset_index;
      full_page_p->Space_used = f_current_space ;
   }

   for (i = (int) e_next_entry_offset_index; 
        i < (int) (e_move_entry_count + e_next_entry_offset_index);
        i++)
   {
      GET_NL_KEY_ENTRY(full_page_p, f_next_entry_offset_index,
         nl_key_length,  key_len, count_p, key_p, child_array_p);
      f_next_entry_offset_index++;
      PUT_NL_KEY_ENTRY(*empty_page_pp, i, 
         ((char *) count_p - BYTES_KEY_LENGTH), nl_key_length );
   }

   /* compress full page */

   COMPRESS_NL_PAGE( full_page_p, nl_key_length );
   GET_NL_KEY_ENTRY(*empty_page_pp, 0, nl_key_length, key_len,
      count_p, key_p, child_array_p);
   DB_MOV_N_BYTES(key_p, empty_low_key_p, key_len);
   *empty_low_key_len_p = key_len;
  
   return( 0 );
}



TST_upt_rec_ptr(leaf_page_p, offset_entry_num, rec_ptr_num, new_rec_ptr_p)
B_LF_PAGE      *leaf_page_p;
unsigned short offset_entry_num, rec_ptr_num;
long	       *new_rec_ptr_p;
{
   unsigned short nbytes, leaf_key_space;
   char           *key_entry_p, *destination_p;
   OFFSET_ENTRY   *offset_entry_p;

   offset_entry_p = (OFFSET_ENTRY *) ((char *)(leaf_page_p) +
      BYTES_B_LF_HEADER + BYTES_OFFSET_ENTRY * offset_entry_num);
   key_entry_p = *offset_entry_p + (char *)(leaf_page_p);
   leaf_key_space = LF_KEY_SPACE (*(KEY_LENGTH *)(key_entry_p),
      ++(*(REC_PTR_COUNT *)((key_entry_p) + BYTES_KEY_LENGTH)));
   (leaf_page_p)->Key_start -= leaf_key_space;
   *offset_entry_p = (leaf_page_p)->Key_start;
   (leaf_page_p)->Space_used += BYTES_REC_PTR;
   destination_p = (char *)(leaf_page_p) + (leaf_page_p)->Key_start;
   nbytes = LF_KEY_SPACE( *(KEY_LENGTH *)(key_entry_p), rec_ptr_num);
   DB_MOV_N_BYTES((key_entry_p), destination_p, nbytes);
   destination_p += nbytes;
   DB_MOV_N_BYTES((new_rec_ptr_p), destination_p, BYTES_REC_PTR);
   destination_p += BYTES_REC_PTR;
   key_entry_p += nbytes;
   nbytes = leaf_key_space - nbytes - BYTES_REC_PTR;
   DB_MOV_N_BYTES(key_entry_p, destination_p, nbytes);
   return(1);
}
