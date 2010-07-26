/*
-----------------------------------------------------------------------

	Name :			OMbransear.c
 	Author:			Sheng Shiau
	Creation Date:		May 29, 1986
        Operating System:	Unix SYSV, v2
        Abstract:


    	Revision History:

-----------------------------------------------------------------------
*/

#include <string.h>
#include "OMDB.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMindex.h"
#include "OMbtreedef.h"


/******************** DB_btree_range_search *******************/
/* This function is called to search a BTREE for records within
   a specified range.  An action routine is passed in to this
   function which will be executed once for every recid with a
   qualifed key value. */

DB_btree_range_search (non_leaf_p,
               	       low_key_value_p,
	               low_key_length, 
                       high_key_value_p,
	               high_key_length, 
                       user_compare_routine_p, 
                       user_action_routine_p,
                       user_context_p)



  B_NL_PAGE     *non_leaf_p;
  char		*low_key_value_p, *high_key_value_p;
  KEY_LENGTH	low_key_length, high_key_length;
  int		(*user_compare_routine_p)();
  int		(*user_action_routine_p)();
  char		*user_context_p;

  {
  KEY_LENGTH        nl_key_length;
  B_LF_PAGE	    *leaf_p;
  int	            i, rtn;
  char              *key_p, *lf_key_p;
  OM_S_OBJID	    *child_ptr_p;
  CHILD_PTR_COUNT   *child_ptr_count_p;
  KEY_LENGTH        key_length;
  REC_PTR_COUNT     *obj_id_count_p, k;
  long              *obj_id_p;
  KEY_LENGTH	    real_len_1, real_len_2;
  OM_S_RIP	    rip;
  


#ifdef DEBUG
printf("\n*** Entering DB_btree_range_search ***\n");
printf("\n*** low_key_value: ");
for (ii=0;ii<low_key_length;ii++)
	printf("%c",low_key_value_p[ii]);
printf("\n");
printf("\n*** high_key_value: ");
for (ii=0;ii<high_key_length;ii++)
	printf("%c",high_key_value_p[ii]);
printf("\n\n");
#endif

  nl_key_length = non_leaf_p->Nl_key_length;
  while (NOT_B_LEAF(non_leaf_p->Page_type))
    {
    /* process non-leaf page */

    for (i = 0; (unsigned short) i<non_leaf_p->Offset_entry_count ; i++ )
      {
      GET_NL_KEY_ENTRY(non_leaf_p, i, nl_key_length, 
         	       key_length, child_ptr_count_p,
                       key_p, child_ptr_p);

      USER_COMPARE(user_compare_routine_p, low_key_value_p, 
		key_p, (KEY_LENGTH) MIN(low_key_length, nl_key_length), 
		key_length, rtn);
		
      if ( rtn <= 0)
        {
        non_leaf_p = DEREF(B_NL_PAGE, *child_ptr_p, rip);
	if ( non_leaf_p == NULL )
		{
#ifdef DEBUG
		printf("\n bad return because of NULLDEREF \n");
#endif
		return(DB_E_NULLDEREF);
		}

        break;
        }
      }	/* for */
    }  		/* while */


  /* process leaf page */


  if ( NOT_B_LEAF(non_leaf_p->Page_type) )
    {
    return (DB_SUCCESS);  
    }
  else
    {
    leaf_p = (B_LF_PAGE *)non_leaf_p;
    }

#ifdef DEBUG
printf("Found leaf page; ready to process leaf page \n");
#endif

  i = 0;
  do
    {

    if ((unsigned short) i >= leaf_p->Offset_entry_count)
      {
      return(DB_SUCCESS);
      }

    GET_LF_KEY_ENTRY(leaf_p, i++, key_length, obj_id_count_p,
                        		 lf_key_p, obj_id_p);

    if ( leaf_p->Key_type == KEY_STRING )
	{
	real_len_1 = strlen(lf_key_p);
	real_len_2 = strlen(low_key_value_p);
	}
    else
	{
	real_len_1 = key_length;
	real_len_2 = low_key_length;
     	}

    USER_COMPARE(user_compare_routine_p, lf_key_p, low_key_value_p, 
	real_len_1, real_len_2, rtn);
	
    } while ( rtn < 0 ); 	/* do while loop */

     

#ifdef DEBUG
printf("Exited first do/while (rtn<0) \n");
#endif
    
  do
    {

    if ( leaf_p->Key_type == KEY_STRING )
	{
	real_len_1 = strlen(lf_key_p);
	real_len_2 = strlen(high_key_value_p);
	}
    else
	{
	real_len_1 = key_length;
	real_len_2 = high_key_length;
     	}

    USER_COMPARE(user_compare_routine_p, lf_key_p, high_key_value_p, 
	real_len_1, real_len_2, rtn);

    if ( rtn <= 0 )
      {
      for (k=0; k < (*obj_id_count_p); k++)
        {

#ifdef DEBUG
	printf("Prepare to call action routine \n");
#endif

        if (( rtn = (*user_action_routine_p)(obj_id_p + k, user_context_p))
		  	                                   == DB_TERMINATE)
          {
#ifdef DEBUG
	  printf("Return DB_TERMINATE \n");
#endif
	  return(rtn);
          }
        }	/* for */
      }
    else
      {
#ifdef DEBUG
      printf(" Returned DB_SUCCESS if !(rtn<=0) \n");
#endif
      return(DB_SUCCESS);
      }
    if (i == (int) leaf_p->Offset_entry_count)
      {
      if (! IF_EQ_OBJID(leaf_p->Next_p, NULL_OBJID))
	{
	leaf_p = DEREF(B_LF_PAGE,leaf_p->Next_p, rip);
	i = 0;
        }
      else
        {
#ifdef DEBUG
	printf("\n Returned DB_SUCCESS since leaf_p->Next_p is NULL\n");
#endif
	return(DB_SUCCESS);
	}
      }
    GET_LF_KEY_ENTRY(leaf_p, i++, key_length, obj_id_count_p,
                        lf_key_p, obj_id_p);
    } while ((unsigned short) i <= leaf_p->Offset_entry_count); /* do while */
    return(1);
  }
