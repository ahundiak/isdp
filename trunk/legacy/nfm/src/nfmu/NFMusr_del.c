#include "machine.h"
/************************************************/
/* Karen Tice  -  2/27/92                       */
/* This function has been added as a wrapper    */
/* around the delete item function since the    */
/* NFM API function returns the index of the    */
/* item just deleted and the NFMR API function  */
/* does not.                                    */
/************************************************/

long NFM_delete_item (user_id, cat_name, item_name, item_rev)
   long    user_id;
   char    *cat_name;
   char    *item_name, *item_rev;

   {
   long     status;
   long     item_no;
   static char *fname = "NFM_delete_item" ;

   status = NFMdelete_item (user_id, cat_name, item_name, item_rev, &item_no);
   return (status);
   }




