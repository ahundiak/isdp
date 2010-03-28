/*
 *  Unit utilities
 */

#include "msdef.h"
#include "UOMdef.h"
#include "UOMerrordef.h"

struct UOM_dlist_pointer {
  struct UOM_dlist_pointer *next;
  struct UOM_dlist_pointer *prev;
};
typedef struct UOM_dlist_pointer UOM_DLIST_POINTER;

/*------------------------------------------------------------------*/
int UOM_MulUnit( udm1, udm2, mul )
char udm1[], udm2[], mul[];
{
  int ii;

  for ( ii = 0; (ii < UOM_K_MAX_DIMS); ii++ )
    mul[ii] = udm1[ii] + udm2[ii];

  return 1;
}

/*------------------------------------------------------------------*/
int UOM_DivUnit( udm1, udm2, div )
char udm1[], udm2[], div[];
{
  int ii;

  for ( ii = 0; (ii < UOM_K_MAX_DIMS); ii++ )
    div[ii] = udm1[ii] - udm2[ii];

  return 1;
}

/*------------------------------------------------------------------*/
int UOM_EquUnit( udm1, udm2 )
char udm1[], udm2[];
{
  int ii;

  for ( ii = 0; (ii < UOM_K_MAX_DIMS); ii++ )
    if ( udm1[ii] != udm2[ii] )
      return 0;

  return 1;
}

/*------------------------------------------------------------------*/
int UOM_CpyUnit( to_udm, fr_udm )
char to_udm[], fr_udm[];
{
  int ii;

  for ( ii = 0; (ii < UOM_K_MAX_DIMS); ii++ )
    to_udm[ii] = fr_udm[ii];

  return 1;
}

/*------------------------------------------------------------------*/
int UOM_NoUnit( udm )
char udm[];
{
  int ii;

  for ( ii = 0; (ii < UOM_K_MAX_DIMS); ii++ )
    udm[ii] = 0;

  return 1;
}

/*------------------------------------------------------------------*/
int UOM_HasUnit( udm )
char udm[];
{
  int ii;

  for ( ii = 0; (ii < UOM_K_MAX_DIMS); ii++ )
    if ( udm[ii] )
      return 1;

  return 0;
}

/*------------------------------------------------------------------*/
int UOM_list_append( new_ptr, list_ptr )

UOM_DLIST_POINTER  *new_ptr;     /* i  pointer to new record to insert */
UOM_DLIST_POINTER **list_ptr;    /* io pointer to list head pointer    */

/*
DESCRIPTION
  This function appends a record to a doubly linked list of similar records.
  It sets list_ptr if it is initially NULL (ie. empty).

HISTORY
       Author        Date              Description
       ------        ----              -----------
    Dale and Lew   11/26/84            wrote it
    moh            11/29/88            handle new_ptr == 0
    moh            08/13/91            apogee conversion. cleanup.
*/
  {
  int ret0 = UOM_S_SUCCESS;

  if ( new_ptr )
    {
    if ( ! *list_ptr )
      {
      *list_ptr = new_ptr;
      new_ptr->next = new_ptr;
      new_ptr->prev = new_ptr;
      }
    else
      {
      new_ptr->next = *list_ptr;
      new_ptr->prev = (*list_ptr)->prev;
      (*list_ptr)->prev->next = new_ptr;
      (*list_ptr)->prev = new_ptr;
      }
    }
  /* if new_ptr */

  return ret0 ;
  }
/* UOM_list_append */

/*------------------------------------------------------------------*/
int UOM_list_remove_head( list_ptr, ptr_to_head )

UOM_DLIST_POINTER **list_ptr;        /* io ptr to list head ptr        */
UOM_DLIST_POINTER **ptr_to_head;     /* io ptr to removed head rec ptr */

/*
DESCRIPTION
  This function removes the record at the head of a doubly linked list from 
  the list and return a pointer to it.

HISTORY
       Author        Date              Description
       ------        ----              -----------
    Dale and Lew   11/30/84            wrote it
    moh		   11/30/88            fixed it
    moh            08/13/91            apogee conversion. cleanup.
*/
  {
  int ret0 = UOM_S_SUCCESS;

  if( ! *list_ptr ) {
    ret0 = UOM_E_UNEXPECTED_NULL_PTR;
    goto ret_error_exit;
  }

  *ptr_to_head = *list_ptr;

  (*list_ptr)->prev->next = (*list_ptr)->next;
  (*list_ptr)->next->prev = (*list_ptr)->prev;

  *list_ptr = (*list_ptr)->next;
  if (*list_ptr == *ptr_to_head)
    *list_ptr = 0;

  (*ptr_to_head)->next = (*ptr_to_head)->prev = *ptr_to_head ;

ret_error_exit:
  return ret0;
  }
/* UOM_list_remove_head */

/*------------------------------------------------------------------*/
int UOM_list_remove( ptr_to_remove, list_ptr )

UOM_DLIST_POINTER  *ptr_to_remove;       /* io ptr to remove from list */
UOM_DLIST_POINTER **list_ptr;            /* io ptr to list head ptr    */

/*
DESCRIPTION
  This function removes a record from a doubly linked list.  It will update
  list_ptr if it points to the removed item -- next or NULL if resulting
  list empty.

HISTORY
       Author        Date              Description
       ------        ----              -----------
    Dale and Lew   11/30/84            wrote it
    moh            12/11/88	       set next,prev of removed member
    jch		   03/02/90	       check for NULL ptr_to_remove
    moh            08/13/91            apogee conversion. cleanup.
*/
  {
  int ret0 = UOM_S_SUCCESS;

  if( ! *list_ptr || ! ptr_to_remove ) {
    ret0 = UOM_E_UNEXPECTED_NULL_PTR;
    goto ret_error_exit;
  }

  ptr_to_remove->prev->next = ptr_to_remove->next;
  ptr_to_remove->next->prev = ptr_to_remove->prev;

  if( *list_ptr == ptr_to_remove )
    *list_ptr = ptr_to_remove->next;

  if( *list_ptr == ptr_to_remove )
    *list_ptr = 0;

  ptr_to_remove->next = ptr_to_remove->prev = ptr_to_remove ;

ret_error_exit:
  return ret0;
  }
/* UOM_list_remove */
