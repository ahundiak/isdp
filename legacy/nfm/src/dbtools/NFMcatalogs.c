#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMget_catalog_no (user_id, catalog_name, catalog_no)
   long    user_id;
   char    *catalog_name;
   long    *catalog_no;
   {
     static char *fname = "NFMget_catalog_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *catalog_no = 0;
/*
     NFMchange_case (catalog_name, 1);
 */
     _NFMdebug ((fname, "Catalog Name = <%s>\n", catalog_name));

     sprintf (sql_str, "WHERE %s = '%s'", "n_catalogname", catalog_name);

     status = NFMget_attr_value (user_id, "NFMCATALOGS", "n_catalogno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_CATALOG, "", NULL);
           _NFMdebug ((fname, "No Such Catalog : status = <0x%.8x>\n", NFM_E_BAD_CATALOG));
           return (NFM_E_BAD_CATALOG);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     *catalog_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL :Catalog No = <%d>\n", *catalog_no));
     return (NFM_S_SUCCESS);
   }

 long NFMget_catalog_name (user_id, catalog_no, catalog_name)
   long    user_id;
   long    catalog_no;
   char    *catalog_name;
   {
     static char *fname = "NFMget_catalog_name" ;
     long    status;
     char    sql_str [1024];

     catalog_name [0] = 0;

     _NFMdebug ((fname, "Catalog No   = <%d>  ", catalog_no  ));

     sprintf (sql_str, "WHERE %s = %d", "n_catalogno", catalog_no);

     status = NFMget_attr_value (user_id, "NFMCATALOGS", "n_catalogname",
              sql_str, catalog_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_CATALOG, "", NULL);
           _NFMdebug ((fname, "No Such Catalog : status = <0x%.8x>\n",
           NFM_E_BAD_CATALOG));
           return (NFM_E_BAD_CATALOG);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL :  Catalog Name = <%s>\n", catalog_name));
     return (NFM_S_SUCCESS);
   }
