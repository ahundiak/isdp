
#include <string.h>
#include "OMDB.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMindex.h"
#include "OMbtreedef.h"

#define RIGHT_BROTHER (0)
#define LEFT_BROTHER  (1)
#define RIGHT_COUSIN  (2)
#define LEFT_COUSIN   (3)
#define RIGHT_BUDDY   (4)
#define LEFT_BUDDY    (5)

/*************************** DB_btree_delete **************************/
DB_btree_delete (char *key_p, KEY_LENGTH key_len, long *rid,
   B_NL_PAGE *root_page_p, int (*user_compare)())

/*  remove key entry record id from leaf page in btree and call 
    DB_btree_concatenation if 2 adjacent pages can be contained
				              within 1 page  */

{
int               i,
                  check_flag,
                  key_notfound,
                  cur_parent_level,
                  nl_key_length,
                  action,
                  underflow;
CHILD_PTR_COUNT   *p_child_ptr_count_p;
REC_PTR_COUNT     *c_rec_ptr_count_p;
long              *c_rec_ptr_p;
B_LF_PAGE         *leaf_page_p,
                  *p_temp_page;
B_NL_PAGE         *parent_page_p,
                  *cur_parent_p,
                  *nl_page_p,
                  *grandpa_p,
                  *neighbor_nl_page_p;
char              *p_key_p,
                  *c_key_p,
                  *s,
                  *d;
OM_S_OBJID        *p_child_ptr_p;
unsigned short    recid_entry_num;      
KEY_LENGTH        c_key_length,
                  p_key_length;
B_PATH_HISTORY    Path_history;
B_PATH_HISTORY    left_buddy_path;
OM_S_RIP	  rip;
unsigned char     empty_leaf_page = FALSE;


 /* initialize path history */

 Path_history.Path_count = 0;
 Path_history.Path_array[0].Child_ptr = REF(OM_S_OBJID, root_page_p);
 if ( IF_EQ_OBJID(Path_history.Path_array[0].Child_ptr, NULL_OBJID ))
	return(DB_E_NULLIDREF);

 Path_history.Path_array[0].Offset_entry_num = 0;
 nl_key_length = root_page_p->Nl_key_length;
 leaf_page_p = (B_LF_PAGE *)root_page_p;
 /* search for key entry in rtree */  

 check_flag = FALSE;
 if ((key_notfound = DB_btree_findleaf (key_p, key_len, rid, 
     (KEY_LENGTH) nl_key_length, user_compare, &check_flag,
     (long **) &leaf_page_p, &Path_history)) ==TRUE)
   {
   return(DB_KEYNOTFOUND);  
   } 

 recid_entry_num = Path_history.Path_array[Path_history.Path_count].
                                                         Child_entry_num;  
 GET_LF_KEY_ENTRY(leaf_page_p, Path_history.Path_array[Path_history.
                           Path_count].Offset_entry_num, c_key_length, 
                           c_rec_ptr_count_p, c_key_p, c_rec_ptr_p);

 if (*c_rec_ptr_count_p == 1)       /* key has only 1 record id, shift 
				     offsets to delete key entry */

   {
   i = Path_history.Path_array[Path_history.Path_count].Offset_entry_num;
   s = (char *)leaf_page_p + BYTES_B_LF_HEADER + (i * BYTES_OFFSET_ENTRY);
   DB_MOV_N_BYTES(s + BYTES_OFFSET_ENTRY, s, 
           (leaf_page_p->Offset_entry_count - 1 - i)*BYTES_OFFSET_ENTRY);  
   leaf_page_p->Offset_entry_count --;
   i = BYTES_KEY_LENGTH + BYTES_REC_PTR_COUNT + c_key_length + BYTES_REC_PTR;
   leaf_page_p->Space_used -= (i + BYTES_OFFSET_ENTRY);
   if ((char *)c_rec_ptr_count_p - BYTES_KEY_LENGTH ==
                             (char *)leaf_page_p + leaf_page_p->Key_start)
     {
     leaf_page_p->Key_start = leaf_page_p->Key_start + i;
     }
   if (leaf_page_p->Offset_entry_count == 0)
     {
     if ( IS_B_ROOT(leaf_page_p->Page_type) )  
       {
       /* All keys have been deleted the B tree is empty. */

       leaf_page_p->Key_start = DB_BYTES_BPAGE;
       return (DB_SUCCESS);
       }
     /* update forward and/or backward pointer(s) 
          on the prior and/or next page(s) */

     if ( IF_EQ_OBJID((leaf_page_p->Prior_p), NULL_OBJID) )
       {
       p_temp_page=DEREF(B_LF_PAGE, (leaf_page_p->Next_p), rip);
       if ( p_temp_page == NULL )
		return(DB_E_NULLDEREF);
       p_temp_page->Prior_p = NULL_OBJID;

       }
     else if ( IF_EQ_OBJID((leaf_page_p->Next_p), NULL_OBJID) )
	    {
	    p_temp_page=DEREF(B_LF_PAGE, (leaf_page_p->Prior_p), rip);
	    if ( p_temp_page == NULL )
		return(DB_E_NULLDEREF);
	    p_temp_page->Next_p = NULL_OBJID;
	    }
	  else
	    {
	    p_temp_page=DEREF(B_LF_PAGE, leaf_page_p->Prior_p, rip);
	    if ( p_temp_page == NULL )
		return(DB_E_NULLDEREF);
	    p_temp_page->Next_p = leaf_page_p->Next_p;

    	    p_temp_page=DEREF(B_LF_PAGE, leaf_page_p->Next_p, rip);
	    if ( p_temp_page == NULL )
		return(DB_E_NULLDEREF);
	    p_temp_page->Prior_p = leaf_page_p->Prior_p;
	    }
     PUT_FREE_PAGE(leaf_page_p);
     empty_leaf_page = TRUE;
     /* adjust child_ptr entries in parent */
 
     Path_history.Path_count --;
     if ((i = DB_btree_update_keys_on_path((KEY_LENGTH) nl_key_length,
              &Path_history)) != DB_SUCCESS)
       {
       return(i);
       }
     Path_history.Path_count ++;
     }
   else if ( NOT_B_ROOT(leaf_page_p->Page_type) ) 
          {
          if (Path_history.Path_array[Path_history.Path_count].
		   Offset_entry_num == leaf_page_p->Offset_entry_count)
            { 
            parent_page_p = DEREF(B_NL_PAGE, Path_history.Path_array[Path_history.Path_count-1].Child_ptr, rip);
	    if ( parent_page_p == NULL )
		return(DB_E_NULLDEREF);

            GET_NL_KEY_ENTRY(parent_page_p, Path_history.Path_array
                          [Path_history.Path_count - 1].Offset_entry_num,
                          nl_key_length, p_key_length, p_child_ptr_count_p,
                          p_key_p, p_child_ptr_p);
            if (*p_child_ptr_count_p == 1)
              {  
              GET_LF_KEY_ENTRY(leaf_page_p, (Path_history.Path_array
                   [Path_history.Path_count].Offset_entry_num-1), 
                   c_key_length, c_rec_ptr_count_p, c_key_p, c_rec_ptr_p);
		    
              key_len = (KEY_LENGTH) MIN((int) c_key_length, nl_key_length);

    	      USER_COMPARE(user_compare, p_key_p, c_key_p, p_key_length, key_len, i );
              if (i != 0)
                {
                DB_MOV_N_BYTES(c_key_p, p_key_p, key_len);
                *((KEY_LENGTH *)((char *)p_child_ptr_count_p -
                                             BYTES_KEY_LENGTH)) = key_len; 
                }
              /* climb tree looking for more nonleaf key updates */
                    
              cur_parent_level = Path_history.Path_count - 1;
	      cur_parent_p = parent_page_p;
	      while(cur_parent_level >= 1)
                {
                parent_page_p = DEREF(B_NL_PAGE, Path_history.Path_array[cur_parent_level - 1].Child_ptr, rip);
		if ( parent_page_p == NULL )
			return(DB_E_NULLDEREF);

                GET_NL_KEY_ENTRY(parent_page_p, Path_history.Path_array
                           [cur_parent_level - 1].Offset_entry_num,
		           nl_key_length, p_key_length,
                           p_child_ptr_count_p, p_key_p, p_child_ptr_p);
                if ((*p_child_ptr_count_p == (OM_S_OBJID) 1) && (Path_history.
       	               Path_array[cur_parent_level].Offset_entry_num == 
		    (unsigned short) (cur_parent_p->Offset_entry_count - 1)))
                  {
                  DB_MOV_N_BYTES(c_key_p, p_key_p, key_len);
                  *((KEY_LENGTH *)((char *)p_child_ptr_count_p -
                                            BYTES_KEY_LENGTH)) = key_len;
	          cur_parent_level--;
		  cur_parent_p = parent_page_p;
      		  }
                else
                  {
	          break;
        	  }
	        }  	/* while */
              } 
            }                       
          }
   }
 else  /* delete proper key record id, shift record ids  */
   {
   d = (char *)c_rec_ptr_p + (recid_entry_num * BYTES_REC_PTR);
   s = (char *)d + BYTES_REC_PTR;
   i = (*c_rec_ptr_count_p - 1 - recid_entry_num) * BYTES_REC_PTR;
   DB_MOV_N_BYTES(s,d,i); 
   (*c_rec_ptr_count_p) --;  /* update # rids in key entry */
   leaf_page_p->Space_used -= BYTES_REC_PTR;
   }
 if (Path_history.Path_count > 0)
   {
   if ( root_page_p->Offset_entry_count == 1 )
     {
     GET_NL_KEY_ENTRY(root_page_p, 0, nl_key_length, p_key_length,
		      p_child_ptr_count_p, p_key_p, p_child_ptr_p);  
     if (*p_child_ptr_count_p == 1)
       {
       nl_page_p = DEREF(B_NL_PAGE, *p_child_ptr_p, rip);
       if ( nl_page_p == NULL )
	    return(DB_E_NULLDEREF);

       DB_MOV_N_BYTES(nl_page_p, root_page_p, DB_BYTES_BPAGE);
       if (IS_B_LEAF(nl_page_p->Page_type))
         {
   	 root_page_p->Page_type = B_LF_RT_PAGE;
         }
       else
	 {
         root_page_p->Page_type = B_NL_RT_PAGE;
	 }
       PUT_FREE_PAGE(nl_page_p);
       return(DB_SUCCESS);
       }
     }
   /* Since parent_page_p probably not points to the parent of
      leaf page which contained the deleted key any more,
      we need to get it again */

   parent_page_p = DEREF(B_NL_PAGE, Path_history.Path_array[Path_history.Path_count - 1].Child_ptr, rip);
   if ( parent_page_p == NULL )
	return(DB_E_NULLDEREF);

   if (empty_leaf_page)
     {
     if ((--Path_history.Path_count) > 0 &&
			  parent_page_p->Offset_entry_count > 0)
       {
       if ((i = DB_btree_find_neighbor_action ((KEY_LENGTH) nl_key_length,
         (char *) parent_page_p, &Path_history, (char **) &neighbor_nl_page_p,
         &left_buddy_path, &action, &underflow)) != DB_SUCCESS)
         {
         return(i);
         }
       if (underflow)
	 {
         Path_history.Path_count--;
         grandpa_p = DEREF(B_NL_PAGE, Path_history.Path_array[Path_history.Path_count].Child_ptr, rip);
	 if ( grandpa_p == NULL )
		return(DB_E_NULLDEREF);

         if ((i = DB_btree_concatenate (user_compare, root_page_p,
            (KEY_LENGTH) nl_key_length, &Path_history, parent_page_p,
            grandpa_p, (B_LF_PAGE *) neighbor_nl_page_p, action,
            left_buddy_path )) != 0 )
           {
           return(i);
           }
         } 
       }
     }
   else
     {
     if ((i = DB_btree_find_neighbor_action ((KEY_LENGTH) nl_key_length,
        (char *) leaf_page_p, &Path_history, (char **) &neighbor_nl_page_p,
        &left_buddy_path, &action, &underflow)) != DB_SUCCESS)
       {
       return(i);
       }
     if (underflow)
       {
       Path_history.Path_count--;
       if ((i = DB_btree_concatenate ( user_compare, root_page_p,
          (KEY_LENGTH) nl_key_length, &Path_history, (B_NL_PAGE *) leaf_page_p,
          parent_page_p, (B_LF_PAGE *) neighbor_nl_page_p, action,
          left_buddy_path )) != 0 )
         {
         return(i);
         }
       }
     }
   }
 return (DB_SUCCESS);
}  
    



/************************** DB_btree_findleaf ***************************/
DB_btree_findleaf(
   char *inq_key_p,
   KEY_LENGTH inq_key_len,
   long	*inq_rec_ptr_p,
   KEY_LENGTH nl_key_len,
   int (*user_compare)(),
   int *one_more_check,
   long **cur_page_pp,
   B_PATH_HISTORY *history_ptr)

{
 /* assume the current page is non-leaf page */
 
 int              key_notfound,
                  retcd,
                  p;
 B_LF_PAGE        *cur_page_p2;
 B_NL_PAGE        *cur_page_p1,
                  *parent_page_p;
 long             *current_child_ptr,
                  *rec_ptr_p;
 OM_S_OBJID       *child_ptr_p;
 CHILD_PTR_COUNT  *child_ptr_count_p;
 REC_PTR_COUNT    *rec_ptr_count_p;
 char             *key_p;
 KEY_LENGTH       key_length,
                  cmp_key_len,
                  real_len_1,
                  real_len_2;
 unsigned short   current_offset_entry_num;
 OM_S_RIP	  rip;
 
 key_notfound = TRUE; 
 cur_page_p1 = (B_NL_PAGE *)(*cur_page_pp);
 /* keep track of the offset entry number being checked */
 current_offset_entry_num = history_ptr->Path_array[history_ptr->
                                                  Path_count].Offset_entry_num;
 if (NOT_B_LEAF(cur_page_p1->Page_type))
   {
    /* search for a qualified key entry, i.e. the inquiry key value is less 
       than or equal to the index key value */
    while (current_offset_entry_num < cur_page_p1->Offset_entry_count)
      {
       /* to get index key entry by giving the current_offset_entry_num and 
                                         the pointer points to current page */
       GET_NL_KEY_ENTRY(cur_page_p1, current_offset_entry_num,
                    nl_key_len, key_length, child_ptr_count_p, key_p, child_ptr_p);
       /* compare the current index key to the inquiry key */
       cmp_key_len = (KEY_LENGTH) MIN(inq_key_len, nl_key_len);

       USER_COMPARE(user_compare, inq_key_p, key_p, cmp_key_len, key_length, retcd );

       if (retcd <= 0)
         {
          parent_page_p = cur_page_p1;     
	  for (p = 0; p < (int) *child_ptr_count_p; p++)   /* to search through the
						      child_ptr's or their corre-
						      ssponding subtree */
            {
             current_child_ptr = DEREF(long, (*(child_ptr_p + p)), rip);
	     if ( current_child_ptr == NULL )
		return(DB_E_NULLDEREF);

             history_ptr->Path_array[history_ptr->
                       Path_count].Offset_entry_num = current_offset_entry_num;
             history_ptr->Path_array[history_ptr->Path_count].Child_entry_num= p;
       	     *cur_page_pp = current_child_ptr;
             history_ptr->Path_count++;
             history_ptr->Path_array[history_ptr->Path_count]
		 	      .Child_ptr = REF(OM_S_OBJID, current_child_ptr);
	     if ( IF_EQ_OBJID( history_ptr->Path_array[
		history_ptr->Path_count].Child_ptr, NULL_OBJID) )
		return(DB_E_NULLIDREF);

	     history_ptr->
                      Path_array[history_ptr->Path_count].Offset_entry_num = 0;
	     history_ptr->Path_array[history_ptr->Path_count].Child_entry_num= 0;
             key_notfound = DB_btree_findleaf(inq_key_p, inq_key_len, 
                     inq_rec_ptr_p, nl_key_len, user_compare, one_more_check,
                                                   cur_page_pp,  history_ptr);
             if (key_notfound == FALSE)
               {
	        return(key_notfound);
               }                
             else if (! *one_more_check)
   	             return(key_notfound);

             history_ptr->Path_count--;
            }  	     /* for loop */

          *cur_page_pp = (long *)cur_page_p1;
          current_offset_entry_num++;
	  if (current_offset_entry_num == cur_page_p1->Offset_entry_count)
             return(key_notfound);
	  else
             *one_more_check = FALSE;
         }
       else
    	 {
	  current_offset_entry_num++;
	 }
      }		/* while loop */
    return(key_notfound);
   } 		/* if (non_leaf) */
 else
   {
    /* It is a leaf page, so cast the double pointer to leaf-page type */
    cur_page_p2 = (B_LF_PAGE *) cur_page_p1;    
    for (current_offset_entry_num = 0; current_offset_entry_num < 
                 cur_page_p2->Offset_entry_count; current_offset_entry_num++)
      {
       GET_LF_KEY_ENTRY(cur_page_p2, current_offset_entry_num,
                                key_length, rec_ptr_count_p, key_p, rec_ptr_p);

       if ( cur_page_p2->Key_type == KEY_STRING )
	{
	real_len_1 = strlen(inq_key_p);
	real_len_2 = strlen(key_p);
	}
       else
	{
	real_len_1 = inq_key_len;
	real_len_2 = key_length;
	}

       USER_COMPARE(user_compare, inq_key_p, key_p, real_len_1, real_len_2, retcd );
       
       if (retcd == 0)
         {
          for (p = 0; p < (int) *rec_ptr_count_p; p++)
    	    {
             COMPARE_REC_PTR(inq_rec_ptr_p, rec_ptr_p, retcd);
             if (retcd == 0)
               {
	        key_notfound = FALSE;
	        history_ptr->Path_array[history_ptr->Path_count]
			          .Offset_entry_num = current_offset_entry_num;
	        history_ptr->Path_array[history_ptr->
						 Path_count].Child_entry_num = p;
	        return(key_notfound);
	       }
	     else if (retcd == -1)
		    {
                     key_notfound = TRUE;
		     return(key_notfound);
		    }
   	     rec_ptr_p ++;
	    }
         }
       else if (retcd < 0)	/* inquiry key < index key */
              {
               return(key_notfound);
              }
       if ((unsigned short) (current_offset_entry_num + 1) ==
          cur_page_p1->Offset_entry_count)
         {
    	  *one_more_check = TRUE;
          return(key_notfound==TRUE);
         }
      }		/* for loop */

   }		/* leaf_page */
   return(1);
}
        


/************************* DB_btree_concatenate **************************/
/* concatenates underflowed nodes in  B tree,  from leaf to root */
DB_btree_concatenate(
   int               (*user_compare) (),
   B_NL_PAGE         *root_page_p,
   KEY_LENGTH        nl_key_length,
   B_PATH_HISTORY    *history_p,
   B_NL_PAGE         *child_page_p,
   B_NL_PAGE         *parent_page_p,
   B_LF_PAGE         *neighbor_lf_page_p,
   int               action,
   B_PATH_HISTORY    left_buddy_path)

{
B_LF_PAGE         *leaf_page_p;
long              *rec_ptr_p,
                  *n_rec_ptr_p;
OM_p_OBJID        child_ptr_p,
                  p_child_ptr_p,
                  n_child_ptr_p;
CHILD_PTR_COUNT   *child_ptr_count_p,
                  *p_child_ptr_count_p,
	          *n_child_ptr_count_p;
char              *key_p,
                  *n_key_p,
                  *p_key_p,
                  *s,
                  *source_p,
                  *destination_p;
B_LF_PAGE         *lf_page_p;
B_NL_PAGE         *neighbor_nl_page_p,
                  *nl_page_p;
REC_PTR_COUNT     *rec_ptr_count_p,
                  *n_rec_ptr_count_p;
B_PATH_ENTRY      parent_path_entry;
int               start_index,
                  i, j,
                  parent_level,
                  underflow;
OFFSET_ENTRY      *offset_entry_p;
unsigned short    key_space,
                  bytes_child_ptrs,
                  contiguous_space;
KEY_LENGTH        key_length,
                  p_key_length,
                  n_key_length;
short             key_cmp_result;
OM_S_RIP          rip;



leaf_page_p = (B_LF_PAGE *)child_page_p;
neighbor_nl_page_p = (B_NL_PAGE *)neighbor_lf_page_p;

do
  { 
  parent_level = history_p->Path_count;
  parent_path_entry = history_p->Path_array[parent_level];
  underflow = FALSE;
  
  if (action == RIGHT_BROTHER || action == RIGHT_COUSIN
			               || action == RIGHT_BUDDY)
  /* move key entries from neighbor page to underflow child page */
    {
    if (IS_B_LEAF(child_page_p->Page_type))  /* leaf underflow */
      {  
      GET_LF_KEY_ENTRY(leaf_page_p, leaf_page_p->Offset_entry_count-1,
		       key_length, rec_ptr_count_p, key_p,  rec_ptr_p);
      GET_LF_KEY_ENTRY(neighbor_lf_page_p, 0, n_key_length,
  	               n_rec_ptr_count_p, n_key_p, n_rec_ptr_p);
      USER_COMPARE(user_compare, key_p, n_key_p, key_length, n_key_length, key_cmp_result);
      if (key_cmp_result == 0)
        {
        key_space = LF_KEY_SPACE(key_length, (*rec_ptr_count_p + *n_rec_ptr_count_p));
        contiguous_space = leaf_page_p->Key_start - BYTES_B_LF_HEADER - BYTES_OFFSET_ENTRY * leaf_page_p->Offset_entry_count;
        if (contiguous_space < key_space)
 	  {
	  COMPRESS_LF_PAGE(leaf_page_p);
	  /* all entries have been relocated, need to get the highest key again */
          GET_LF_KEY_ENTRY(leaf_page_p, leaf_page_p->Offset_entry_count-1,
		           key_length, rec_ptr_count_p, key_p, rec_ptr_p);
	  }
	offset_entry_p = (OFFSET_ENTRY *)((char *)leaf_page_p +
			  BYTES_B_LF_HEADER + BYTES_OFFSET_ENTRY *
		           (leaf_page_p->Offset_entry_count - 1));
        source_p = (char *)leaf_page_p + leaf_page_p->Key_start;
	leaf_page_p->Key_start -= key_space;
	*offset_entry_p = leaf_page_p->Key_start;
	bytes_child_ptrs = (*n_rec_ptr_count_p) * BYTES_REC_PTR;
	leaf_page_p->Space_used += bytes_child_ptrs;
	destination_p = (char *)leaf_page_p + leaf_page_p->Key_start;
	key_space = key_space - bytes_child_ptrs;
        DB_MOV_N_BYTES(source_p, destination_p, key_space);
 	DB_MOV_N_BYTES(n_rec_ptr_p, destination_p+key_space, bytes_child_ptrs);
	/* find the new address of rec_ptr_count */
	rec_ptr_count_p = (REC_PTR_COUNT *)(destination_p + BYTES_KEY_LENGTH);
	*rec_ptr_count_p += *n_rec_ptr_count_p;
	start_index = 1;
        }
      else
	{
	start_index = 0;
	}
      COMPRESS_LF_PAGE(leaf_page_p);
      for (i = start_index, j = leaf_page_p->Offset_entry_count;
               i < (int) neighbor_lf_page_p-> Offset_entry_count; i++, j++)
        {
        GET_LF_KEY_ENTRY(neighbor_lf_page_p, i, key_length,
  	                         rec_ptr_count_p, key_p, rec_ptr_p);
        PUT_LF_KEY_ENTRY(leaf_page_p, j,
                        (char *)rec_ptr_count_p - BYTES_KEY_LENGTH);
        }

      /* adjust forward & backward pointers for child leaf
         page and its neighbor to right (neighbor disappears) */

      leaf_page_p->Next_p = neighbor_lf_page_p->Next_p;
      if (action == RIGHT_BUDDY)
	{
        if ( ! IF_EQ_OBJID((leaf_page_p->Prior_p), NULL_OBJID))
	  {
	  lf_page_p = DEREF(B_LF_PAGE, leaf_page_p->Prior_p, rip);
	  if ( lf_page_p == NULL )
		return(DB_E_NULLDEREF);

	  lf_page_p->Next_p = REF(OM_S_OBJID, neighbor_lf_page_p);
	  if ( IF_EQ_OBJID( lf_page_p->Next_p, NULL_OBJID) )
		return(DB_E_NULLIDREF);

          }
	DB_MOV_N_BYTES(leaf_page_p, neighbor_lf_page_p, DB_BYTES_BPAGE);
        PUT_FREE_PAGE(leaf_page_p);
        }
      else
	{
        if ( ! IF_EQ_OBJID((neighbor_lf_page_p->Next_p), NULL_OBJID))
          {
          lf_page_p = DEREF(B_LF_PAGE, (neighbor_lf_page_p->Next_p), rip);
	  if ( lf_page_p == NULL )
		return(DB_E_NULLDEREF);

          lf_page_p->Prior_p = neighbor_lf_page_p->Prior_p;
          }
        PUT_FREE_PAGE(neighbor_lf_page_p);
	}
      }
    else    		/* nonleaf underflow */
      {
      GET_NL_KEY_ENTRY(child_page_p, child_page_p->Offset_entry_count-1,
	 nl_key_length, key_length, child_ptr_count_p, key_p, child_ptr_p);
      GET_NL_KEY_ENTRY(neighbor_nl_page_p, 0, nl_key_length,
	        n_key_length, n_child_ptr_count_p, n_key_p, n_child_ptr_p);
      USER_COMPARE(user_compare, key_p, n_key_p, key_length, n_key_length, key_cmp_result);
      if (key_cmp_result == 0)
        {
        key_space = NL_KEY_SPACE(nl_key_length, (*child_ptr_count_p + *n_child_ptr_count_p));
        contiguous_space = child_page_p->Key_start - BYTES_B_NL_HEADER - BYTES_OFFSET_ENTRY * child_page_p->Offset_entry_count;
        if (contiguous_space < key_space)
 	  {
	  COMPRESS_NL_PAGE(child_page_p, nl_key_length);
	  /* all entries have been relocated, need to get the highest key again */
          GET_NL_KEY_ENTRY(child_page_p, child_page_p->Offset_entry_count-1, nl_key_length, key_length, child_ptr_count_p, key_p, child_ptr_p);
	  }
	offset_entry_p = (OFFSET_ENTRY *)((char *)child_page_p +
			  BYTES_B_NL_HEADER + BYTES_OFFSET_ENTRY *
	                  (child_page_p->Offset_entry_count - 1));
        source_p = (char *)child_page_p + child_page_p->Key_start;
	child_page_p->Key_start -= key_space;
	*offset_entry_p = child_page_p->Key_start;
	bytes_child_ptrs = (*n_child_ptr_count_p) * BYTES_CHILD_PTR;
	child_page_p->Space_used += bytes_child_ptrs;
	destination_p = (char *)child_page_p + child_page_p->Key_start;
	key_space = key_space - bytes_child_ptrs;
        DB_MOV_N_BYTES(source_p, destination_p, key_space);
 	DB_MOV_N_BYTES(n_child_ptr_p, destination_p+key_space, bytes_child_ptrs);
	/* find the new address of child_ptr_count */
	child_ptr_count_p = (CHILD_PTR_COUNT *)(destination_p + BYTES_KEY_LENGTH);
	*child_ptr_count_p += *n_child_ptr_count_p;
	start_index = 1;
        }
      else
	{
	start_index = 0;
	}
      COMPRESS_NL_PAGE(child_page_p, nl_key_length);
      for (i = start_index, j = child_page_p->Offset_entry_count;
       	      i < (int) neighbor_nl_page_p->Offset_entry_count; i++, j++)
        {
        GET_NL_KEY_ENTRY(neighbor_nl_page_p, i, nl_key_length,
		 key_length, child_ptr_count_p, key_p, child_ptr_p);

        PUT_NL_KEY_ENTRY(child_page_p, j,
           (char *)child_ptr_count_p - BYTES_KEY_LENGTH, nl_key_length);
        }
      if (action == RIGHT_BUDDY)
	{
	DB_MOV_N_BYTES(child_page_p, neighbor_nl_page_p, DB_BYTES_BPAGE);
        PUT_FREE_PAGE(child_page_p);
        }
      else
	{
        PUT_FREE_PAGE(neighbor_nl_page_p);
	}
      }
    }
  else
    /* action is LEFT_BROTHER, LEFT_COUSIN or LEFT_BUDDY,
       move key entries from  leaf/nonleaf page to neighbor page */
    {
    if (IS_B_LEAF(child_page_p->Page_type))   /* leaf underflow */
      {
      GET_LF_KEY_ENTRY(neighbor_lf_page_p,
         neighbor_lf_page_p->Offset_entry_count-1, n_key_length,
         n_rec_ptr_count_p, n_key_p, n_rec_ptr_p);
      GET_LF_KEY_ENTRY(leaf_page_p, 0, key_length, rec_ptr_count_p, key_p,
         rec_ptr_p);
        USER_COMPARE(user_compare, key_p, n_key_p, key_length, n_key_length, key_cmp_result);
      if (key_cmp_result == 0)
        {
        key_space = LF_KEY_SPACE(n_key_length, (*rec_ptr_count_p + *n_rec_ptr_count_p));
        contiguous_space = neighbor_lf_page_p->Key_start - BYTES_B_LF_HEADER - BYTES_OFFSET_ENTRY * neighbor_lf_page_p->Offset_entry_count;
        if (contiguous_space < key_space)
 	  {
	  COMPRESS_LF_PAGE(neighbor_lf_page_p);
	  /* all entries have been relocated, need to get the highest key again */
          GET_LF_KEY_ENTRY(neighbor_lf_page_p, neighbor_lf_page_p->Offset_entry_count-1, n_key_length, n_rec_ptr_count_p,
             n_key_p, n_rec_ptr_p);
	  }
	offset_entry_p = (OFFSET_ENTRY *)((char *)neighbor_lf_page_p +
			  BYTES_B_LF_HEADER + BYTES_OFFSET_ENTRY *
		           (neighbor_lf_page_p->Offset_entry_count - 1));
        source_p = (char *)neighbor_lf_page_p + neighbor_lf_page_p->Key_start;
	neighbor_lf_page_p->Key_start -= key_space;
	*offset_entry_p = neighbor_lf_page_p->Key_start;
	bytes_child_ptrs = (*rec_ptr_count_p) * BYTES_REC_PTR;
	neighbor_lf_page_p->Space_used += bytes_child_ptrs;
	destination_p = (char *)neighbor_lf_page_p + neighbor_lf_page_p->Key_start;
	key_space = key_space - bytes_child_ptrs;
        DB_MOV_N_BYTES(source_p, destination_p, key_space);
 	DB_MOV_N_BYTES(rec_ptr_p, destination_p+key_space, bytes_child_ptrs);
	/* find the new address of n_rec_ptr_count */
	n_rec_ptr_count_p = (REC_PTR_COUNT *)(destination_p + BYTES_KEY_LENGTH);
	*n_rec_ptr_count_p += *rec_ptr_count_p;
	start_index = 1;
        }
      else
	{
	start_index = 0;
	}
      COMPRESS_LF_PAGE(neighbor_lf_page_p);
      for (i = start_index, j = neighbor_lf_page_p->Offset_entry_count;
		    i < (int) leaf_page_p->Offset_entry_count; i++, j++)
        {
        GET_LF_KEY_ENTRY(leaf_page_p, i, key_length,
				 rec_ptr_count_p, key_p, rec_ptr_p);
        PUT_LF_KEY_ENTRY(neighbor_lf_page_p, j,
                        (char *)rec_ptr_count_p - BYTES_KEY_LENGTH);
        }

      /* adjust pointers for left neighbor leaf page and
         underflow child leaf page (child page disappears) */

      neighbor_lf_page_p->Next_p = leaf_page_p->Next_p;
      if (action == LEFT_BUDDY)
        {
        if ( ! IF_EQ_OBJID((neighbor_lf_page_p->Prior_p), NULL_OBJID))
          {
          lf_page_p = DEREF(B_LF_PAGE, (neighbor_lf_page_p->Prior_p), rip);
	  if ( lf_page_p == NULL )
		return(DB_E_NULLDEREF);

          lf_page_p->Next_p = REF(OM_S_OBJID, leaf_page_p);
	  if ( IF_EQ_OBJID(lf_page_p->Next_p, NULL_OBJID) )
		return(DB_E_NULLIDREF);

          }
        DB_MOV_N_BYTES(neighbor_lf_page_p, leaf_page_p, DB_BYTES_BPAGE);
        PUT_FREE_PAGE(neighbor_lf_page_p);
        }
      else
        {
        if ( ! IF_EQ_OBJID((leaf_page_p->Next_p), NULL_OBJID))
          {
          lf_page_p = DEREF(B_LF_PAGE, (leaf_page_p->Next_p), rip);
	  if ( lf_page_p == NULL )
		return(DB_E_NULLDEREF);

          lf_page_p->Prior_p = leaf_page_p->Prior_p;
          }
        PUT_FREE_PAGE(leaf_page_p);
        }
      }
    else   /* nonleaf underflow */
      {
      GET_NL_KEY_ENTRY(neighbor_nl_page_p, neighbor_nl_page_p->Offset_entry_count-1, nl_key_length, n_key_length, n_child_ptr_count_p, n_key_p, n_child_ptr_p);
      GET_NL_KEY_ENTRY(child_page_p, 0, nl_key_length, key_length, child_ptr_count_p, key_p, child_ptr_p);
        USER_COMPARE(user_compare, key_p, n_key_p, key_length, n_key_length, key_cmp_result);
      if (key_cmp_result == 0)
        {
        key_space = NL_KEY_SPACE(nl_key_length, (*child_ptr_count_p + *n_child_ptr_count_p));
        contiguous_space = neighbor_nl_page_p->Key_start - BYTES_B_NL_HEADER - BYTES_OFFSET_ENTRY * neighbor_nl_page_p->Offset_entry_count;
        if (contiguous_space < key_space)
 	  {
	  COMPRESS_NL_PAGE(neighbor_nl_page_p, nl_key_length);
	  /* all entries have been relocated, need to get the highest key again */
          GET_NL_KEY_ENTRY(neighbor_nl_page_p, neighbor_nl_page_p->Offset_entry_count-1, nl_key_length, n_key_length, n_child_ptr_count_p, n_key_p, n_child_ptr_p);
	  }
	offset_entry_p = (OFFSET_ENTRY *)((char *)neighbor_nl_page_p +
			  BYTES_B_NL_HEADER + BYTES_OFFSET_ENTRY *
		           (neighbor_nl_page_p->Offset_entry_count - 1));
        source_p = (char *)neighbor_nl_page_p + neighbor_nl_page_p->Key_start;
	neighbor_nl_page_p->Key_start -= key_space;
	*offset_entry_p = neighbor_nl_page_p->Key_start;
	bytes_child_ptrs = (*child_ptr_count_p) * BYTES_CHILD_PTR;
	neighbor_nl_page_p->Space_used += bytes_child_ptrs;
	destination_p = (char *)neighbor_nl_page_p + neighbor_nl_page_p->Key_start;
	key_space = key_space - bytes_child_ptrs;
        DB_MOV_N_BYTES(source_p, destination_p, key_space);
 	DB_MOV_N_BYTES(child_ptr_p, destination_p+key_space, bytes_child_ptrs);
	/* find the new address of n_child_ptr_count */
	n_child_ptr_count_p = (CHILD_PTR_COUNT*)
           (destination_p + BYTES_KEY_LENGTH);
	*n_child_ptr_count_p += *child_ptr_count_p;
	start_index = 1;
        }
      else
	{
	start_index = 0;
	}
      COMPRESS_NL_PAGE(neighbor_nl_page_p, nl_key_length);
      for (i = start_index, j = neighbor_nl_page_p->Offset_entry_count;
	          i < (int) child_page_p->Offset_entry_count; i++, j++)
        {
        GET_NL_KEY_ENTRY(child_page_p, i, nl_key_length, key_length,
                             child_ptr_count_p, key_p, child_ptr_p);
        PUT_NL_KEY_ENTRY(neighbor_nl_page_p, j,
	 (char *)child_ptr_count_p - BYTES_KEY_LENGTH, nl_key_length);
        }
      if (action == LEFT_BUDDY)
	{
	DB_MOV_N_BYTES(neighbor_nl_page_p, child_page_p, DB_BYTES_BPAGE);
        PUT_FREE_PAGE(neighbor_nl_page_p);
        }
      else
	{
        PUT_FREE_PAGE(child_page_p);
	}
      }
    }

  i = parent_path_entry.Offset_entry_num;

  /* a variable name starts with p_ means parent key */

  GET_NL_KEY_ENTRY(parent_page_p, i, nl_key_length, p_key_length,
		    p_child_ptr_count_p, p_key_p, p_child_ptr_p);

  switch ( action )
    {
    case RIGHT_BROTHER:
           DB_MOV_N_BYTES(((char *)(p_child_ptr_p + parent_path_entry.
		      Child_entry_num + 2)), ((char *)(p_child_ptr_p + 
                      parent_path_entry.Child_entry_num + 1)), 
                      ((((*p_child_ptr_count_p) --) - parent_path_entry.
                      Child_entry_num - 1) * BYTES_CHILD_PTR));          
           parent_page_p->Space_used -= BYTES_CHILD_PTR;
           break;

    case LEFT_BROTHER:
           DB_MOV_N_BYTES(((char *)(p_child_ptr_p + parent_path_entry.
		      Child_entry_num + 1)), ((char *)(p_child_ptr_p +
                      parent_path_entry.Child_entry_num)), 
                      ((((*p_child_ptr_count_p) --) - parent_path_entry.
		      Child_entry_num) * BYTES_CHILD_PTR));          
           parent_page_p->Space_used -= BYTES_CHILD_PTR;
           break;

    case RIGHT_COUSIN:
	   /* a variable name starts with n_ means parent's neighbor key */

           GET_NL_KEY_ENTRY(parent_page_p, (i + 1), nl_key_length,
		n_key_length, n_child_ptr_count_p, n_key_p, n_child_ptr_p);
           *n_child_ptr_p = *(p_child_ptr_p + ((*p_child_ptr_count_p)-1));
           if (*p_child_ptr_count_p != 1)
	     {
             (*p_child_ptr_count_p) --;
             parent_page_p->Space_used -= BYTES_CHILD_PTR;
	     }
	   else
	     {
             /* delete parent key entry and update page header */

             s = (char *)parent_page_p + BYTES_B_NL_HEADER
	                                     + (i * BYTES_OFFSET_ENTRY);
             DB_MOV_N_BYTES(s + BYTES_OFFSET_ENTRY, s, 
                                ((parent_page_p->Offset_entry_count --)
                                             - i) * BYTES_OFFSET_ENTRY);
             i = NL_KEY_SPACE_1(nl_key_length);
             parent_page_p->Space_used -= (i + BYTES_OFFSET_ENTRY);
             if ((char *)p_child_ptr_count_p - BYTES_KEY_LENGTH ==
                      (char *)parent_page_p + parent_page_p-> Key_start)
	       {
               parent_page_p->Key_start +=  i;
	       }
             }
           break;

    case LEFT_COUSIN:
           GET_NL_KEY_ENTRY(parent_page_p, (i - 1), nl_key_length,
               n_key_length, n_child_ptr_count_p, n_key_p, n_child_ptr_p);
           *p_child_ptr_p = *(n_child_ptr_p + ((*n_child_ptr_count_p)-1));
           if (*n_child_ptr_count_p != 1)
	     {
             (*n_child_ptr_count_p) --;
             parent_page_p->Space_used -= BYTES_CHILD_PTR;
	     }
	   else
	     {
             /* delete neighbor key entry and update page header */

             s = (char *)parent_page_p + BYTES_B_NL_HEADER
	                                     + (i * BYTES_OFFSET_ENTRY);
             DB_MOV_N_BYTES(s , s - BYTES_OFFSET_ENTRY, 
                                ((parent_page_p->Offset_entry_count --)
                                         - i + 1) * BYTES_OFFSET_ENTRY);
             i = NL_KEY_SPACE_1(nl_key_length);
             parent_page_p->Space_used -= (i + BYTES_OFFSET_ENTRY);
             if ((char *)n_child_ptr_count_p - BYTES_KEY_LENGTH ==
                      (char *)parent_page_p + parent_page_p-> Key_start)
	       {
               parent_page_p->Key_start +=  i;
	       }
             }
           break;

    case RIGHT_BUDDY:
	   /* update appropriate key entries on parent path */

           if ((i = DB_btree_update_keys_on_path(nl_key_length,
 			              history_p)) != DB_SUCCESS)
             {
             return(i);
             }
           break;

    case LEFT_BUDDY:
	   /* update appropriate key entries on left_buddy_path */

           left_buddy_path.Path_count--;
           if ((i = DB_btree_update_keys_on_path(nl_key_length,
 			             &left_buddy_path)) != DB_SUCCESS)
             {
             return(i);
             }
           break;
    default:
           return(DB_E_BADACTION);
    }
   
    if ( root_page_p->Offset_entry_count == 1 )
       {
       GET_NL_KEY_ENTRY(root_page_p, 0, nl_key_length, p_key_length,
		         p_child_ptr_count_p, p_key_p, p_child_ptr_p);  
       if (*p_child_ptr_count_p == 1)
	 {
	 nl_page_p = DEREF(B_NL_PAGE, *p_child_ptr_p, rip);
	 if ( nl_page_p == NULL )
		return(DB_E_NULLDEREF);

         lf_page_p = (B_LF_PAGE *)nl_page_p;
         if (IS_B_LEAF(nl_page_p->Page_type))
             {
             DB_MOV_N_BYTES(nl_page_p, root_page_p, DB_BYTES_BPAGE);
   	     root_page_p->Page_type = B_LF_RT_PAGE;
             PUT_FREE_PAGE(nl_page_p);
             }
           else
	     {
             DB_MOV_N_BYTES(lf_page_p, root_page_p, DB_BYTES_BPAGE);
  	     root_page_p->Page_type = B_NL_RT_PAGE;
             PUT_FREE_PAGE(lf_page_p);
	     }
         }
       }
     else
       {
       if (NOT_B_ROOT(parent_page_p->Page_type))
         {
         if (parent_page_p->Offset_entry_count > 0)
           {
           child_page_p = parent_page_p;
           if ((i = DB_btree_find_neighbor_action (nl_key_length,
              (char *) child_page_p, history_p, (char **) &neighbor_nl_page_p,
              &left_buddy_path, &action, &underflow)) != DB_SUCCESS)
             {
             return(i);
             }
           /* set Path_count to the new parent level
		 & get new parent page */

           history_p->Path_count --;
           parent_page_p = DEREF(B_NL_PAGE, history_p->Path_array[history_p->Path_count].Child_ptr, rip);
	   if ( parent_page_p == NULL )
		return(DB_E_NULLDEREF);

           }
         }   	/* if NOT_B_ROOT */
       }

 } while (underflow == TRUE && NOT_B_ROOT(child_page_p->Page_type)); 

     
return(DB_SUCCESS);
}




/**********************************************************************/
/* update appropriate key entries on parent path */

 DB_btree_update_keys_on_path(
   KEY_LENGTH       nl_key_length,
   B_PATH_HISTORY   *history_p)

{
 int              i, delete_parent_key,
                  parent_level;
 char             *s, *p_key_p,
                  *prior_key_p=NULL;
 B_NL_PAGE        *parent_page_p;
 CHILD_PTR_COUNT  *p_child_ptr_count_p,
                  *child_ptr_count_p;
 OM_S_OBJID       *p_child_ptr_p,
                  *child_ptr_p;
 KEY_LENGTH       p_key_length,
                  prior_key_length=0;
 OM_S_RIP	  rip;

 parent_level = history_p->Path_count;
 parent_page_p = DEREF(B_NL_PAGE, history_p->Path_array[parent_level].Child_ptr, rip);
 if ( parent_page_p == NULL )
	return(DB_E_NULLDEREF);

 GET_NL_KEY_ENTRY(parent_page_p, history_p->Path_array[parent_level].
		  Offset_entry_num, nl_key_length, p_key_length,
		  p_child_ptr_count_p, p_key_p, p_child_ptr_p);
 delete_parent_key = TRUE;
 do
   {
   if (*p_child_ptr_count_p == 1)
     {
     if ( delete_parent_key )
       {
       /* delete parent key by shifting offsets */

       i = history_p->Path_array[parent_level].Offset_entry_num;
       s = (char *)parent_page_p + BYTES_B_NL_HEADER
	                          + (i * BYTES_OFFSET_ENTRY);
       DB_MOV_N_BYTES(s + BYTES_OFFSET_ENTRY, s, 
                     ((parent_page_p->Offset_entry_count --) 
                                  - i) * BYTES_OFFSET_ENTRY);
       i = NL_KEY_SPACE_1(nl_key_length);
       parent_page_p->Space_used -= (i + BYTES_OFFSET_ENTRY);
       if ((char *)p_child_ptr_count_p - BYTES_KEY_LENGTH ==
           (char *)parent_page_p + parent_page_p-> Key_start)
         {
         parent_page_p->Key_start += i;
         }
       if (parent_page_p->Offset_entry_count == history_p->
    	        Path_array[parent_level].Offset_entry_num &&
			                    parent_level > 0)
         {
         if (parent_page_p->Offset_entry_count > 0)
           {
           /* get the key prior to deleted key */
           GET_NL_KEY_ENTRY(parent_page_p, (history_p->Path_array
                           [parent_level].Offset_entry_num - 1),
	                   nl_key_length, prior_key_length,
                           child_ptr_count_p, prior_key_p, child_ptr_p);
           delete_parent_key = FALSE;
           }
         else
           { 
           delete_parent_key = TRUE;
   	   PUT_FREE_PAGE(parent_page_p);
           }
         parent_level--;
         parent_page_p = DEREF(B_NL_PAGE, history_p->Path_array[parent_level].Child_ptr, rip);
	 if ( parent_page_p == NULL )
		return(DB_E_NULLDEREF);

         GET_NL_KEY_ENTRY(parent_page_p, history_p->Path_array
                        [parent_level].Offset_entry_num,
			nl_key_length, p_key_length,
			p_child_ptr_count_p, p_key_p, p_child_ptr_p);
         }
       else
	 {
         return(DB_SUCCESS);
         }
       }
     else
       {
       /* update parent key value in stead of deleting it */

       DB_MOV_N_BYTES(prior_key_p, p_key_p, prior_key_length);
       *((KEY_LENGTH *)((char *)p_child_ptr_count_p -
                        BYTES_KEY_LENGTH)) = prior_key_length; 
       if (((unsigned short) (parent_page_p->Offset_entry_count - 1) ==
          history_p-> Path_array[parent_level].Offset_entry_num) &&
	  (parent_level > 0))
         {
         parent_level--;
         parent_page_p = DEREF(B_NL_PAGE, history_p->Path_array[parent_level].Child_ptr, rip);
	 if ( parent_page_p == NULL )
		return(DB_E_NULLDEREF);

         GET_NL_KEY_ENTRY(parent_page_p, history_p->Path_array
                        [parent_level].Offset_entry_num,
			nl_key_length, p_key_length,
			p_child_ptr_count_p, p_key_p, p_child_ptr_p);
         }
       else
         {
         return(DB_SUCCESS);
         }
       }  
     }
   else
     {
     if (delete_parent_key)
       {
       /* shift parent key's child_ptr's */

       DB_MOV_N_BYTES(((char *)(p_child_ptr_p + (history_p->
				Path_array[parent_level].
                                Child_entry_num + 1))),
                                ((char *)(p_child_ptr_p + 
                                history_p->Path_array[parent_level].
			        Child_entry_num)), 
                                BYTES_CHILD_PTR * (*p_child_ptr_count_p - 1
                                - history_p->Path_array[parent_level]
				.Child_entry_num));
       (*p_child_ptr_count_p)--;
       parent_page_p->Space_used -= BYTES_CHILD_PTR;
       }
     else
       {
       if (history_p->Path_array[parent_level].Child_entry_num
	   == (unsigned short) (*p_child_ptr_count_p - 1))
	 {
         DB_MOV_N_BYTES(prior_key_p, p_key_p, prior_key_length);
         *((KEY_LENGTH *)((char *)p_child_ptr_count_p -
                        BYTES_KEY_LENGTH)) = prior_key_length; 
         }
       }
     return(DB_SUCCESS);
     }
   } while ( TRUE );        /* do while */
 }



/*************************************************************************/
DB_btree_find_neighbor_action(
   KEY_LENGTH      nl_key_length,
   char            *child_page_p,
   B_PATH_HISTORY  *history_p,
   char            **neighbor_page_pp,
   B_PATH_HISTORY  *left_buddy_path_p,
   int             *action_p,
   int             *underflow)

{
  CHILD_PTR_COUNT    *child_ptr_count_p,
                     *p_child_ptr_count_p;
  REC_PTR_COUNT      *rec_ptr_count_p;
  long               *rec_ptr_p;
  KEY_LENGTH         key_length,
                     p_key_length;
  B_NL_PAGE          *left_nl_neighbor_p,
                     *right_nl_neighbor_p,
                     *nonleaf_page,
                     *parent_page_p;
  B_LF_PAGE          *left_lf_neighbor_p,
                     *right_lf_neighbor_p,
                     *lf_child_page_p,
	             *lf_page_p;
  char               *key_p,
                     *p_key_p,
                     *right_neighbor_p,
                     *left_neighbor_p;
  int                i,
                     leveldelta,
                     left_neighbor_type=0;
  int                right_neighbor_type=0;
  OM_S_OBJID         *child_ptr_p,
                     *p_child_ptr_p,
                     t;
  unsigned short     repeat;
  OM_S_RIP	     rip;
  B_PATH_ENTRY       parent_history;
  
     /* get left and right nonleaf neighbors, check for underflow */

     *underflow = FALSE;
     left_neighbor_p = NULL;
     right_neighbor_p = NULL;

     parent_history = history_p->Path_array[history_p->Path_count-1];
     parent_page_p = DEREF(B_NL_PAGE, parent_history.Child_ptr, rip);
     if ( parent_page_p == NULL )
	return(DB_E_NULLDEREF);

     GET_NL_KEY_ENTRY(parent_page_p, parent_history.Offset_entry_num,
		      nl_key_length, p_key_length, p_child_ptr_count_p,
		      p_key_p, p_child_ptr_p);

     if (parent_history.Child_entry_num > 0)
       {
       left_neighbor_p = DEREF(char, (*(p_child_ptr_p + (parent_history.Child_entry_num-1))), rip);
       if ( left_neighbor_p == NULL )
	return(DB_E_NULLDEREF);

       left_neighbor_type = LEFT_BROTHER;
       }
     else if (parent_history.Offset_entry_num > 0)
            {
            /* rightmost child entry in leftmost offset */
            i = parent_history.Offset_entry_num;
            GET_NL_KEY_ENTRY(parent_page_p, --i, nl_key_length, 
                        key_length, child_ptr_count_p, key_p, child_ptr_p);
            left_neighbor_p = DEREF(char, (*(child_ptr_p + ((*child_ptr_count_p)-1))), rip);
	    if ( left_neighbor_p == NULL )
		return(DB_E_NULLDEREF);

	    left_neighbor_type = LEFT_COUSIN;
            }

     if (parent_history.Child_entry_num < 
         (unsigned short ) ((*p_child_ptr_count_p)-1))
       {
       right_neighbor_p = DEREF(char, (*(p_child_ptr_p + (parent_history.Child_entry_num+1))), rip);
       if ( right_neighbor_p == NULL )
		return(DB_E_NULLDEREF);

       right_neighbor_type = RIGHT_BROTHER;
       }
     else if (parent_history.Offset_entry_num <
              (unsigned short) (parent_page_p->Offset_entry_count - 1))
            {
            /* leftmost child entry in rightmost offset */
            i = parent_history.Offset_entry_num;
            GET_NL_KEY_ENTRY(parent_page_p, ++i, nl_key_length, 
                        key_length, child_ptr_count_p, key_p, child_ptr_p);
            right_neighbor_p = DEREF(char, (*(child_ptr_p)), rip);
	    if ( right_neighbor_p == NULL )
		return(DB_E_NULLDEREF);

	    right_neighbor_type = RIGHT_COUSIN;
            }

     if (left_neighbor_p == NULL)
       /* 1. The parent key entry is leftmost on parent page and
	  2. its leftmost child pointer refers to the underflow page */

       {
       leveldelta = 1;
       repeat = TRUE;
       do
         {
         nonleaf_page = DEREF(B_NL_PAGE, history_p->Path_array[history_p->Path_count - leveldelta].Child_ptr, rip);
	 if ( nonleaf_page == NULL )
		return(DB_E_NULLDEREF);

         GET_NL_KEY_ENTRY(nonleaf_page, history_p->Path_array
                   [history_p->Path_count - leveldelta].Offset_entry_num,
		   nl_key_length, key_length, child_ptr_count_p, key_p,
		   child_ptr_p);
         if (history_p->Path_array[history_p->Path_count-leveldelta]
                   .Offset_entry_num == 0  && history_p->Path_array
                 [history_p->Path_count-leveldelta].Child_entry_num == 0)
           {
           leveldelta ++;
           }
         else
           {
           break;
  	   }    
         } while (leveldelta <= (int) history_p->Path_count);
	 
     /* traverse down to correct level in tree */

       if (leveldelta != 1)
         {
         if ((leveldelta - 1) != (int) history_p->Path_count)
           {
           left_buddy_path_p->Path_count = 0;
           left_buddy_path_p->Path_array[left_buddy_path_p->Path_count].
	       Child_ptr = history_p->Path_array[history_p->Path_count -
	   		                          leveldelta].Child_ptr;
           if (history_p->Path_array[history_p->Path_count-leveldelta].
                                                    Child_entry_num > 0)
	     {
             i = history_p->Path_array[history_p->Path_count 
				    - leveldelta].Child_entry_num - 1;
	     left_buddy_path_p->Path_array[left_buddy_path_p->Path_count].
		 Offset_entry_num = history_p->Path_array[history_p->
			    Path_count - leveldelta].Offset_entry_num;
	     left_buddy_path_p->Path_array[left_buddy_path_p->Path_count].
		                                  Child_entry_num = i;
	     t = *(child_ptr_p + i);
             nonleaf_page = DEREF(B_NL_PAGE, t, rip);
	     if ( nonleaf_page == NULL )
		return(DB_E_NULLDEREF);

 	     }      
           else
             {
	     /* rightmost child entry in leftmost offset */

	     i = history_p->Path_array[history_p->Path_count
		   		       - leveldelta].Offset_entry_num - 1;
             GET_NL_KEY_ENTRY(nonleaf_page, i, nl_key_length, key_length,
			           child_ptr_count_p, key_p, child_ptr_p);
	     left_buddy_path_p->Path_array[left_buddy_path_p->Path_count].
		                                     Offset_entry_num = i;
	     left_buddy_path_p->Path_array[left_buddy_path_p->Path_count].
		                 Child_entry_num = *child_ptr_count_p - 1;
	     t = *(child_ptr_p + ((*child_ptr_count_p) - 1));
             nonleaf_page = DEREF(B_NL_PAGE, t, rip);
	     if ( nonleaf_page == NULL )
		return(DB_E_NULLDEREF);

             }
           left_buddy_path_p->Path_array[++ left_buddy_path_p->
				                Path_count].Child_ptr = t;
           left_buddy_path_p->Path_array[left_buddy_path_p->Path_count].
		  Offset_entry_num = nonleaf_page->Offset_entry_count - 1;
           leveldelta --;
           do
	     {
             GET_NL_KEY_ENTRY(nonleaf_page, nonleaf_page->
                          Offset_entry_count-1,  nl_key_length, key_length,
                          child_ptr_count_p, key_p, child_ptr_p);
             i = (*child_ptr_count_p) - 1;
	     left_buddy_path_p->Path_array[left_buddy_path_p->Path_count].
		                                      Child_entry_num = i;
	     t = *(child_ptr_p + i);
             nonleaf_page = DEREF(B_NL_PAGE, t, rip);
	     if ( nonleaf_page == NULL )
		return(DB_E_NULLDEREF);

	     left_buddy_path_p->Path_array[++ left_buddy_path_p->
				                Path_count].Child_ptr = t;
	     left_buddy_path_p->Path_array[left_buddy_path_p->Path_count].
		  Offset_entry_num = nonleaf_page->Offset_entry_count - 1;
             leveldelta --;
	     } while (leveldelta >= 1);
	   if (IS_B_LEAF(nonleaf_page->Page_type))
	     {
	     lf_page_p = (B_LF_PAGE *) nonleaf_page;
             GET_LF_KEY_ENTRY(lf_page_p, lf_page_p->Offset_entry_count - 1,
                           key_length, rec_ptr_count_p, key_p, rec_ptr_p);
             left_buddy_path_p->Path_array[left_buddy_path_p->Path_count].
		               Child_entry_num = *rec_ptr_count_p - 1;
	     }
	   else
	     {
             GET_NL_KEY_ENTRY(nonleaf_page, nonleaf_page->
                        Offset_entry_count - 1, nl_key_length, 
			key_length, child_ptr_count_p, key_p, child_ptr_p);
             left_buddy_path_p->Path_array[left_buddy_path_p->Path_count].
		               Child_entry_num = *child_ptr_count_p - 1;
	     }
	   left_neighbor_p = (char *)nonleaf_page;
	   left_neighbor_type = LEFT_BUDDY;
	   }
	 /* else -- underflow page is the leftmost page on it's level */
         }	/* if leveldelta != 1 */
       }	/* if left_neighbor_p == NULL */


         if (right_neighbor_p == NULL) 
            /* rightmost child entry refers to underflowed page, climb tree
               and find leftmost child entry at underflow page's level */
         { /* if right_neighbor == NULL */
             leveldelta = 1;
             repeat = TRUE;
             do
             {  /* do loop */
                nonleaf_page = DEREF(B_NL_PAGE, history_p->Path_array[history_p->Path_count - leveldelta].Child_ptr, rip);
		if ( nonleaf_page == NULL )
			return(DB_E_NULLDEREF);
		
	        GET_NL_KEY_ENTRY(nonleaf_page, history_p->Path_array
                                 [history_p->Path_count - leveldelta].
                                 Offset_entry_num,  nl_key_length, key_length,
                                 child_ptr_count_p, key_p, child_ptr_p);

	        if (((history_p->Path_array[history_p->Path_count-leveldelta]
                   .Offset_entry_num) ==
                   (unsigned short) (nonleaf_page->Offset_entry_count - 1))
                    &&
                   (history_p->Path_array[history_p->Path_count-leveldelta].
                   Child_entry_num ==
                   (unsigned short) ((*child_ptr_count_p) - 1)))
                  {
                  leveldelta ++;
                  }    
                else
		  {
                  break;
		  }   

             } while (leveldelta <= (int) history_p->Path_count);
	 
             /* traverse down to correct level in tree, following rightmost
                path */

             if (leveldelta != 1)
             {
	     if ((leveldelta - 1) != (int) history_p->Path_count)
	       {
               if (history_p->Path_array[history_p->Path_count-leveldelta].
                   Child_entry_num < (unsigned short) ((*child_ptr_count_p)-1))
		 {
                 nonleaf_page = DEREF(B_NL_PAGE, (*(child_ptr_p + (history_p->Path_array[history_p->Path_count-leveldelta].Child_entry_num+1))), rip);
		 if ( nonleaf_page == NULL )
			return(DB_E_NULLDEREF);

   	         }         
               else
	         {
	   	 GET_NL_KEY_ENTRY(nonleaf_page, history_p->
				Path_array[history_p->Path_count -
				leveldelta].Offset_entry_num + 1,
				nl_key_length, key_length,
			        child_ptr_count_p, key_p, child_ptr_p);
		 nonleaf_page = DEREF(B_NL_PAGE, (*child_ptr_p), rip);
		 if ( nonleaf_page == NULL )
			return(DB_E_NULLDEREF);

	         }
                leveldelta --;
	        do
	        { /* climb down to correct level on tree */

                  GET_NL_KEY_ENTRY(nonleaf_page, 0, nl_key_length, 
                                   key_length, child_ptr_count_p, 
                                   key_p, child_ptr_p);

                  nonleaf_page = DEREF(B_NL_PAGE, (*child_ptr_p), rip);
		  if ( nonleaf_page == NULL )
			return(DB_E_NULLDEREF);

	          leveldelta --;
     	        } while (leveldelta >= 1);
  	        right_neighbor_p = (char *)nonleaf_page;
		right_neighbor_type = RIGHT_BUDDY;
		}
            }
        }
     if (NOT_B_LEAF( ((B_NL_PAGE *)child_page_p)->Page_type ))
       {       
       left_nl_neighbor_p = (B_NL_PAGE *)left_neighbor_p;
       right_nl_neighbor_p = (B_NL_PAGE *)right_neighbor_p;
       if (left_neighbor_p != NULL && right_neighbor_p != NULL)
         {
         if (left_nl_neighbor_p->Space_used <= right_nl_neighbor_p->Space_used)
           {
           if ((((B_NL_PAGE *)child_page_p)->Space_used +
               left_nl_neighbor_p->Space_used - BYTES_B_NL_HEADER) <
               DB_BYTES_BPAGE)
             {
	     *action_p = left_neighbor_type;
             *underflow = TRUE;
             *neighbor_page_pp = left_neighbor_p;
             }
           }
         else
           {
           if ((((B_NL_PAGE *)child_page_p)->Space_used +
               right_nl_neighbor_p->Space_used - BYTES_B_NL_HEADER) <
               DB_BYTES_BPAGE)
             {
	     *action_p = right_neighbor_type;
             *underflow = TRUE;
             *neighbor_page_pp = right_neighbor_p;
             }
           }
         }
       else if (left_neighbor_p == NULL)  /* leftmost leaf originally under
					     flowed so deal only with right
					   nonleaf neighbors of underflowed
				           nonleaf page */
              {
              if ((((B_NL_PAGE *)child_page_p)->Space_used +
                  right_nl_neighbor_p->Space_used - BYTES_B_NL_HEADER) <
                  DB_BYTES_BPAGE)
                {
   	        *action_p = right_neighbor_type;
                *underflow = TRUE;
	        *neighbor_page_pp = right_neighbor_p;
                }
              }
            else if (right_neighbor_p == NULL) /* rightmost leaf originally
						 underflowed so deal only
    				                with left nonleaf neighbors
					     of underflowed nonleaf page */
                   {
                   if ((((B_NL_PAGE *)child_page_p)->Space_used +
                        left_nl_neighbor_p->Space_used - BYTES_B_NL_HEADER) <
                        DB_BYTES_BPAGE)
                     {   
   	             *action_p = left_neighbor_type;
                     *underflow = TRUE;
		     *neighbor_page_pp = left_neighbor_p;
                     }
                   }
       }
     else
       {
       lf_child_page_p = (B_LF_PAGE *)child_page_p;
       left_lf_neighbor_p = (B_LF_PAGE *)left_neighbor_p;
       right_lf_neighbor_p = (B_LF_PAGE *)right_neighbor_p;
       if (left_neighbor_p != NULL && right_neighbor_p != NULL)
         {
         if (left_lf_neighbor_p->Space_used <= right_lf_neighbor_p->Space_used)
           {
           if ((lf_child_page_p->Space_used + left_lf_neighbor_p->Space_used
                                       - BYTES_B_LF_HEADER) < DB_BYTES_BPAGE)
             {
	     *action_p = left_neighbor_type;
             *underflow = TRUE;
             *neighbor_page_pp = left_neighbor_p;
             }
           }
         else
           {
           if ((lf_child_page_p->Space_used +
                right_lf_neighbor_p->Space_used - BYTES_B_LF_HEADER) <
                DB_BYTES_BPAGE)
             {
	     *action_p = right_neighbor_type;
             *underflow = TRUE;
             *neighbor_page_pp = right_neighbor_p;
             }
           }
         }
       else if (left_neighbor_p == NULL)  /* leftmost leaf originally 
					    underflowed so deal only with
					    right nonleaf neighbors of
 				            underflowed nonleaf page */
              {
              if ((lf_child_page_p->Space_used +
                  right_lf_neighbor_p->Space_used - BYTES_B_LF_HEADER) <
                  DB_BYTES_BPAGE)
                {
		*action_p = right_neighbor_type;
                *underflow = TRUE;
		*neighbor_page_pp = right_neighbor_p;
                }
              }
            else if (right_neighbor_p == NULL)/* rightmost leaf originally
					         underflowed so deal only 
					         with left nonleaf neighbor
                                                underflowed nonleaf page */
                   {
	           if ((lf_child_page_p->Space_used +
                        left_lf_neighbor_p->Space_used -
                        BYTES_B_LF_HEADER) < DB_BYTES_BPAGE)
      	             {
		     *action_p = left_neighbor_type;
                     *underflow = TRUE;
		     *neighbor_page_pp = left_neighbor_p;
                     }
                   }
       }
  return(DB_SUCCESS);
}


/*********************************************************************/	

DB_btree_deltree( OM_S_OBJID my_id, B_NL_PAGE *page_p )
	
{
int               sts, p;
B_LF_PAGE         *leaf_page_p;
OM_S_OBJID        *child_ptr_p;
CHILD_PTR_COUNT   *child_ptr_count_p;
char              *key_p;
B_NL_PAGE         *p_temp_nlpage;
OM_S_OBJID        temp_objid;
OM_p_OBJECTHDR	  temp_object_p;
OM_S_RIP	  rip;
KEY_LENGTH        key_length;
unsigned short    i;

if ( NOT_B_LEAF(page_p->Page_type) )
   {
   for ( i=0; i < page_p->Offset_entry_count; i++ )
	{
	GET_NL_KEY_ENTRY( page_p, i, page_p->Nl_key_length, key_length, 
		child_ptr_count_p, key_p, child_ptr_p );
	for( p=0; p < (int) *child_ptr_count_p; p++ )
	   {
	   p_temp_nlpage = DEREF(B_NL_PAGE, (*(child_ptr_p + p)), rip);
	   if ( p_temp_nlpage == NULL )
		return(DB_E_NULLDEREF);
	   DB_btree_deltree( my_id, p_temp_nlpage );

	   }	   
	}

   temp_objid = REF(OM_S_OBJID, page_p);
   if ( IF_EQ_OBJID(temp_objid, NULL_OBJID) )
	return(DB_E_NULLIDREF);
   temp_object_p = (OM_p_OBJECTHDR)( (int)page_p - 
	(int)sizeof(OM_S_OBJID) - (int)sizeof(int) - 
	(int)sizeof(OM_S_OBJECTHDR) ); 
#ifdef DEBUG
   printf("\nobjid of nonleaf page to dealloc: %x\n", temp_objid);
   printf("addr of objecthdr: %x\n", temp_object_p);
#endif
   if ( ! IF_EQ_OBJID( my_id, temp_objid ) )
     {
     sts=om$delete_object(osnum=OM_Gw_current_OS, 
			object=temp_object_p,
			objid=temp_objid 
			);
     if (!(sts&1))
	{
	om$report_error(sts=sts);
	exit(1);
	}
     }
   }
else		/* leaf page */
   {
   leaf_page_p = (B_LF_PAGE *)page_p;
   temp_object_p = (OM_p_OBJECTHDR)( (int)leaf_page_p - 
	(int)sizeof(OM_S_OBJID) - (int)sizeof(int) - 
	(int)sizeof(OM_S_OBJECTHDR) ); 
   temp_objid = REF(OM_S_OBJID, leaf_page_p);
   if ( IF_EQ_OBJID(temp_objid, NULL_OBJID) )
	return(DB_E_NULLIDREF);
#ifdef DEBUG
   printf("\nobjid of leaf page to dealloc: %x\n", temp_objid);
   printf("addr of objecthdr: %x\n", temp_object_p);
#endif
   if ( ! IF_EQ_OBJID( my_id, temp_objid ) )
     {
     sts=om$delete_object(osnum=OM_Gw_current_OS, 
			object=temp_object_p,
			objid=temp_objid 
			);
     if (!(sts&1))
	{
	om$report_error(sts=sts);
	exit(1);
	}
     }
   }
   return(1);
}

