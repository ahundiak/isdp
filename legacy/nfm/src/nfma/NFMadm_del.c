#include "machine.h"
/************************************************/
/* Karen Tice  -  2/27/92                       */
/* These functions have been added as wrappers  */
/* around the delete catalog/project functions  */
/* since the NFM API functions return the index */
/* of the catalog/project just deleted and the  */
/* NFMR API functions do not.                   */
/************************************************/

long NFM_delete_catalog (user_id, catalog_name)
   long    user_id;
   char    *catalog_name;

   {
   long     status;
   long     catalog_no;
   static char *fname = "NFM_delete_catalog" ;

   status = NFMdelete_catalog (user_id, catalog_name, &catalog_no);
   return (status);
   }

long NFM_delete_project (user_id, project_name)
   long    user_id;
   char    *project_name;

   {
   long     status;
   long     project_no;
   static char *fname = "NFM_delete_project" ;

   status = NFMdelete_project (user_id, project_name, &project_no);
   return (status);
   }




