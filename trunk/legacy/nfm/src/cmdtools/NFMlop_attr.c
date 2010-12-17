#include "machine.h"
#include "CMDTOOLS.h"
#include "WFstruct.h"

extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal ;

 long NFMquery_lop_definition (user_id, lop_name, attr_list)
   long     user_id;
   char     *lop_name;
   MEMptr   *attr_list;
   {
     static char *fname = "NFMquery_lop_definition" ;
     long     status;

     sprintf (lop_name, "%s", "NFMPROJECTS");

     _NFMdebug ((fname, "LOP  Name  = <%s>\n", lop_name));

     status = NFMquery_table_definition (user_id, "NFMSYSTEM", 
              lop_name, attr_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        _NFMdebug ((fname, "Tab Definition : status = <0x%.8x>\n", status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_addto_lop_attributes (user_id, lop_name, 
                                     attr_list, data_list, value_list)
   long     user_id;
   char     *lop_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_addto_lop_attributes" ;
     long     status;
     char     user_name[50];
     char     **column, **data;
     long     x, y, count;
     long     a = -1, b = -1, d = -1;
     long	  no_buffers;
     char     acl_no[50];
     MEMptr   list = NULL;
     long     NFMget_transition_acl_list();

     sprintf (lop_name, "%s", "NFMPROJECTS");

     _NFMdebug ((fname, "LOP  Name  = <%s>  ", lop_name ));

     status = NFMquery_table_attributes (user_id, "NFMSYSTEM", 
              lop_name, attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Tab Attr : status = <0x%.8x>\n", status));
        return (status);          
      }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status)) ;
        return (NFM_E_MEM);                     
      }

     status = MEMbuild_array (*data_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status)) ;
        return (NFM_E_MEM);                     
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
        else if (! strcmp (column [y], "n_valueno"))    d = y;
      }

     strcpy (user_name, NFMglobal.NFMusername) ;

     status = NFMget_transition_acl_list (user_id, &list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Get ACL List : status = <0x%.8x>\n", status));
        return (status);           
      }

     if (*value_list)
      {
        status = MEMappend (list, *value_list);    
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "MEM Append : status = <0x%.8x>\n", 
                      status));
           return (status);           
         }
       }
      else
      {
        status = MEMsplit_copy_buffer (list, value_list, 0);    
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "MEM Append : status = <0x%.8x>\n", 
                      status));
           return (status);           
         }
       }

      status = MEMclose (&list);    
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         MEMclose (value_list);
         _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
         return (status);           
       }

  	  MEMno_buffers (*value_list, &no_buffers );
      sprintf (acl_no, "%d", no_buffers );

      for (x = 0; x < (*attr_list) -> rows; ++x)
       {
         count = (*attr_list) -> columns * x;

         if (! strcmp (data [count + a], "n_projectmgr"))
          {
             status = MEMwrite_data (*data_list, user_name, 1, x + 1);
             if (status != MEM_S_SUCCESS)
              {
                MEMclose (attr_list);
                MEMclose (data_list);
                MEMclose (value_list);
                _NFMdebug ((fname, "MEMwrite Data : status = <0x%.8x>\n",
                status));
                return (status);           
              }
          }
         else if (! strcmp (data [count + a], "n_aclno"))
          {
             status = MEMwrite_data (*attr_list, acl_no, x + 1, d + 1);
             if (status != MEM_S_SUCCESS)
              {
                MEMclose (attr_list);
                MEMclose (data_list);
                MEMclose (value_list);
                _NFMdebug ((fname, "MEMwrite Data : status = <0x%.8x>\n",
                status));
                return (status);           
              }
          }
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }





