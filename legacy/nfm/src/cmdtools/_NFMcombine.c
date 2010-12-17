#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long _NFMget_catalog_no (user_id, catalog_name, catalog_num)
   long    user_id;
   char    *catalog_name;
   char    *catalog_num;

   {
     long    status;
     long    cat_no;
     static char *fname = "_NFMget_catalog_no" ;

     _NFMdebug ((fname, "Enter.\n")); 
     status = NFMget_catalog_no (user_id, catalog_name, &cat_no);
     if (status == NFM_S_SUCCESS)
         sprintf (catalog_num, "%ld", cat_no);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_catalog_name (user_id, catalog_num, catalog_name)
   long    user_id;
   char    *catalog_num;
   char    *catalog_name;

   {
     static char *fname = "_NFMget_catalog_name" ;
     long    status, atol ();
     long    cat_no;

     _NFMdebug ((fname, "Enter.\n")); 
     cat_no = atol (catalog_num);

     status = NFMget_catalog_name (user_id, cat_no, catalog_name);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_item_no (user_id, cat_name, item_name, item_rev, item_num)
   long    user_id;
   char    *cat_name;
   char    *item_name;
   char    *item_rev;
   char    *item_num;

   {
     long    status, atol ();
     long    item_no;
     static char *fname = "_NFMget_item_no" ;

     _NFMdebug ((fname, "Enter.\n")); 
     status = NFMget_item_no (user_id, cat_name, item_name, item_rev, &item_no);
     if (status == NFM_S_SUCCESS)
         sprintf (item_num, "%ld", item_no);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_item_name (user_id, cat_name, item_num, item_name, item_rev)
   long    user_id;
   char    *cat_name;
   char    *item_num;
   char    *item_name;
   char    *item_rev;

   {
     static char *fname = "_NFMget_item_name" ;
     long    status, atol ();
     long    item_no;

     _NFMdebug ((fname, "Enter.\n")); 
     item_no = atol (item_num);

     status = NFMget_item_name (user_id, cat_name, item_no, item_name, 
                                item_rev);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_node_no (user_id, node_name, node_num)
   long    user_id;
   char    *node_name;
   char    *node_num;

   {
     long    status, atol ();
     long    node_no;
     static char *fname = "_NFMget_node_no" ;

     _NFMdebug ((fname, "Enter.\n")); 
     status = NFMget_node_no (user_id, node_name, &node_no);
     if (status == NFM_S_SUCCESS)
         sprintf (node_num, "%ld", node_no);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_node_name (user_id, node_num, node_name)
   long    user_id;
   char    *node_num;
   char    *node_name;

   {
     long    status, atol ();
     long    node_no;
     static char *fname = "_NFMget_node_name" ;

     _NFMdebug ((fname, "Enter.\n")); 
     node_no = atol (node_num);

     status = NFMget_node_name (user_id, node_no, node_name);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_sa_no (user_id, sa_name, sa_num)
   long    user_id;
   char    *sa_name;
   char    *sa_num;

   {
     long    status, atol ();
     long    sa_no;
     static char *fname = "_NFMget_sa_no" ;

     _NFMdebug ((fname, "Enter.\n")); 
     status = NFMget_sa_no (user_id, sa_name, &sa_no);
     if (status == NFM_S_SUCCESS)
         sprintf (sa_num, "%ld", sa_no);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_sa_name (user_id, sa_num, sa_name)
   long    user_id;
   char    *sa_num;
   char    *sa_name;

   {
     long    status, atol ();
     long    sa_no;
     static char *fname = "_NFMget_sa_name" ;

     _NFMdebug ((fname, "Enter.\n")); 
     sa_no = atol (sa_num);

     status = NFMget_sa_name (user_id, sa_no, sa_name);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }


 long _NFMget_acl_no (user_id, acl_name, acl_num)
   long    user_id;
   char    *acl_name;
   char    *acl_num;

   {
     long    status, atol ();
     long    acl_no;
     static char *fname = "_NFMget_acl_no" ;

     _NFMdebug ((fname, "Enter.\n")); 
     status = NFMget_acl_no (user_id, acl_name, &acl_no);
     if (status == NFM_S_SUCCESS)
         sprintf (acl_num, "%ld", acl_no);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_acl_name (user_id, acl_num, acl_name)
   long    user_id;
   char    *acl_num;
   char    *acl_name;

   {
     long    status, atol ();
     long    acl_no;
     static char *fname = "_NFMget_acl_name" ;

     _NFMdebug ((fname, "Enter.\n")); 
     acl_no = atol (acl_num);

     status = NFMget_acl_name (user_id, acl_no, acl_name);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_class_no (user_id, wf_num, class_name, class_num)
   long    user_id;
   char    *wf_num;
   char    *class_name;
   char    *class_num;

   {
     long    status, atol ();
     long    wf_no;
     long    class_no;
     static char *fname = "_NFMget_class_no" ;

     _NFMdebug ((fname, "Enter.\n")); 
     wf_no = atol (wf_num);
     status = NFMget_class_no (user_id, wf_no, class_name, &class_no);
     if (status == NFM_S_SUCCESS)
         sprintf (class_num, "%ld", class_no);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_class_name (user_id, wf_num, class_num, class_name)
   long    user_id;
   char    *wf_num;
   char    *class_num;
   char    *class_name;

   {
     long    status, atol ();
     long    wf_no;
     long    class_no;
     static char *fname = "_NFMget_class_name" ;

     _NFMdebug ((fname, "Enter.\n")); 
     wf_no = atol (wf_num);
     class_no = atol (class_num);

     status = NFMget_class_name (user_id, wf_no, class_no, class_name);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_user_no (user_id, user_name, user_num)
   long    user_id;
   char    *user_name;
   char    *user_num;

   {
     long    status, atol ();
     long    user_no;
     static char *fname = "_NFMget_user_no" ;

     _NFMdebug ((fname, "Enter.\n")); 
     status = NFMget_user_no (user_id, user_name, &user_no);
     if (status == NFM_S_SUCCESS)
         sprintf (user_num, "%ld", user_no);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_user_name (user_id, user_num, user_name)
   long    user_id;
   char    *user_num;
   char    *user_name;

   {
     long    status, atol ();
     long    user_no;
     static char *fname = "_NFMget_user_name" ;

     _NFMdebug ((fname, "Enter.\n")); 
     user_no = atol (user_num);

     status = NFMget_user_name (user_id, user_no, user_name);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }


 long _NFMget_workflow_no (user_id, workflow_name, workflow_num)
   long    user_id;
   char    *workflow_name;
   char    *workflow_num;

   {
     long    status, atol ();
     long    workflow_no;
     static char *fname = "_NFMget_workflow_no" ;

     _NFMdebug ((fname, "Enter.\n")); 
     status = NFMget_workflow_no (user_id, workflow_name, &workflow_no);
     if (status == NFM_S_SUCCESS)
         sprintf (workflow_num, "%ld", workflow_no);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }

 long _NFMget_workflow_name (user_id, workflow_num, workflow_name)
   long    user_id;
   char    *workflow_num;
   char    *workflow_name;

   {
     long    status, atol ();
     long    workflow_no;
     static char *fname = "_NFMget_workflow_name" ;

     _NFMdebug ((fname, "Enter.\n")); 
     workflow_no = atol (workflow_num);

     status = NFMget_workflow_name (user_id, workflow_no, workflow_name);
     _NFMdebug ((fname, "Returning: <0x%.8x>.\n", status)); 
     return (status);

   }



