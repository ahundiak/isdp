#include "machine.h"
#include "CMDTOOLS.h"

/* this functions can go away and moved into NFMcond_attr.c */

 long NFMquery_attributes_definition (user_id, table_type, table_name,
                                      attr_list)
   long     user_id;
   char     *table_type, *table_name;
   MEMptr   *attr_list;
   {
     static char *fname = "NFMquery_attributes_definition" ;
     long     status;

     NFMchange_case (table_type, 1);
     if (! strcmp (table_type, "nfmsystem"))  NFMchange_case (table_name, 1);

     _NFMdebug ((fname, "Table Type  = <%s>  : Table Name = <%s>\n",
		 table_type, table_name));

     status = NFMquery_attr_def (user_id, table_type, table_name,
              "", "", attr_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Query Attr Def : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


 long NFMquery_table_definition (user_id, table_type, table_name,
                                 attr_list)
   long     user_id;
   char     *table_type, *table_name;
   MEMptr   *attr_list;
   {
     static char *fname = "NFMquery_table_definition" ;
     long     status;

     NFMchange_case (table_type, 1);
     if (! strcmp (table_name, "nfmsystem")) NFMchange_case (table_name, 1);

     _NFMdebug ((fname, "Table Type  = <%s>  : Table Name = <%s>\n",
		 table_type, table_name));

     status = NFMquery_condition_definition (user_id,
              table_type, table_name, "", "", attr_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Query Cond Definition : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_table_attributes (user_id, table_type, table_name,
                                 attr_list, data_list, value_list)
   long     user_id;
   char     *table_type, *table_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_table_attributes" ;
     long     status;

     NFMchange_case (table_type, 1);
     if (! strcmp (table_name, "nfmsystem")) NFMchange_case (table_name, 1);

     _NFMdebug ((fname, "Table Type  = <%s>  : Table Name = <%s>\n",
		 table_type, table_name));

     status = NFMquery_condition_attributes (user_id,
              table_type, table_name, "", "",
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Query Cond Definition : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_table_attributes_value2 (user_id, table_type, table_name,
					attr_list, data_list, value_list)
   long     user_id;
   char     *table_type, *table_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_table_attributes_value2" ;
     long     status;

     NFMchange_case (table_type, 1);
     if (! strcmp (table_name, "nfmsystem")) NFMchange_case (table_name, 1);

     _NFMdebug ((fname, "Table Type  = <%s>  : Table Name = <%s>\n",
		 table_type, table_name));

     status = NFMquery_condition_attributes_value2 (user_id,
              table_type, table_name, "", "",
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Query Cond Definition : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_table_information (user_id, table_type, table_name,
                                  attr_list, data_list, value_list)
   long     user_id;
   char     *table_type, *table_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_table_information" ;
     long     status;

     NFMchange_case (table_type, 1);
     if (! strcmp (table_type, "nfmsystem")) NFMchange_case (table_name, 1);
    
     _NFMdebug ((fname, "Table Type  = <%s> : Table Name = <%s>\n",
		 table_type, table_name));

     status = NFMquery_condition_information (user_id,
              table_type, table_name, "", "",
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Query Cond Info : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_change_table_information (user_id, table_type, table_name,
                                         attr_list, data_list, value_list)
   long     user_id;
   char     *table_type, *table_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_change_table_information" ;
     long     status;

     NFMchange_case (table_type, 1);
     if (! strcmp (table_type, "nfmsystem")) NFMchange_case (table_name, 1);

     _NFMdebug ((fname, "Table Type  = <%s>  : Table Name = <%s>\n", 
		 table_type, table_name));
        
     status = NFMquery_change_condition_information (user_id,
              table_type, table_name, "", "",
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Qry Chg Info : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }



