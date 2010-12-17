#include <stdio.h>
#include <memory.h>
#include "SQLerrordef.h"
#include "PDUris_incl.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "WFstruct.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"

/* Handy Math macro - Kumar */

#define PDMmod(x,y) (x % y)
#define PDMround_off(x) ((int) (x + 0.5))
#define PDMtruncate(x) ((int) (x))
#define PDMmax(x,y) ((x > y) ? x : y)

extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal ;
extern PDMexec_ptr PDMexec;
extern int      PDMdebug_on;
extern char PDM_DEBUG_FILE[];
extern char PDMdynamic_table[20];


/*
long PDMpre_parametric_creation (cat_data, acl_list, value_list)
     MEMptr   *cat_data, *acl_list, *value_list;
   {
     static char *fname = "PDMpre_parametric_creation" ;
     long     status;
     long     t_basic_row = -1, t_appl_row = -1, i, column_of_valueno, x, c ;
     char     **data, **column, user_name [50] ;
     char     str [1024], seq [5], date [50], tmp_str [512] ;
     long     next_seq_no = -1, count, no_buffers ;
     char     acl_no [20] ;
     MEMptr   list = NULL ;
     long     _NFMget_table_sysattr ();
     long     _NFMget_data_info ();
     long     _NFMadd_to_value_list () ;

     _PDMdebug (fname, "ENTER\n") ;
     

           status = MEMopen(cat_data,512);
            if(status != MEM_S_SUCCESS)
               {
                     MEMclose(&cat_data);
                  _PDMdebug(fname,"MEMopen of output class failed status %d\n",
status);
                     return(status);
                    }

           status = MEMwrite_format(*cat_data,"n_catalogno","integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_catalogname", "char(20)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_catalogdesc","char(40)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_creator", "char(14)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_creationdate", "timestamp");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_updater", "char(14)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_updatedate", "timestamp");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_identifier", "char(20)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_stateno", "integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_aclno", "integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_type", "char(3)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_archiveno", "integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_archivestate", "char(1)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_pendingflag", "char(2)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"t_basic", "char(20)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"t_appl", "char(20)");
           if(status != MEM_S_SUCCESS)
                   {
                  _PDMdebug(fname,"MEMwrite_format failed status %d\n", status);
                     return(status);
                   }


      str[0] = '\0';

     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS)
       {
	 _PDMdebug (fname, "Get Ris date : status = <0x%.8x>\n",
		     status) ;
	 return (status) ;
       }
     status = MEMbuild_array (*cat_data) ;
     if (status != MEM_S_SUCCESS)
     {
       _PDMdebug (fname, "MEMbuild_array:*cat_data:status=<0x%x.8>\n", status) ;
       return (NFM_E_MEM) ;
     }
     column = (char **) (*cat_data)->column_ptr ;

     for (i=0; i<(*cat_data_list)->columns; i++)
       {
	 if (strcmp (column [i], "t_basic") == 0)
	   {
	     strcat(str, "PDM") ;
             strcat(str,"\1");
	   }
	 else if (strcmp (column [i], "t_appl") == 0)
             {
	     strcat(str, "PDM") ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_identifier") == 0)
             {
	     strcat(str, "PDM") ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_creator") == 0)
             {
	     strcat(str, NFMglobal.NFMusername) ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_creationdate") == 0)
             {
	     strcat(str, date) ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_type") == 0)
             {
	     strcat(str, "CID") ;
             strcat(str,"\1");
              }
         else strcat(str,"\1");
       }

     status = MEMwrite (*cat_data, str) ;
     if (status != MEM_S_SUCCESS)
     {
       _PDMdebug (fname, "MEMwrite : *cat_data : status = <0x%x.8>\n", status) ;
       return (NFM_E_MEM) ;
     }
     status = _NFMget_catalog_acl_list (acl_list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _PDMdebug (fname, "Get ACL list : status = <0x%.8x>\n",
		     status) ;
	 return (status) ;
       }

     

           status = MEMopen(attr_bufr,512);
            if(status != MEM_S_SUCCESS)
               {
                     MEMclose(&attr_bufr);
                  _PDMdebug(fname,"MEMopen of output class failed status %d\n",
status);
                     return(status);
               }

           status = MEMwrite_format(*attr_bufr,"n_tablename", "char(20)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_name","char(20)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_datatype", "char(15)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_synonym","char(40)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_application", "char(3)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_read", "char(1)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_write", "char(1)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_update", "char(1)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_delete", "char(1)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_null", "char(1)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_checkin", "char(1)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_checkout", "char(1)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_seqno", "integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_attrno", "integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_tableno", "integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_default", "char(40)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_valueno", "integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*attr_bufr,"n_adviceno", "integer");
           if(status != MEM_S_SUCCESS)
                   {
                  _PDMdebug(fname,"MEMwrite_format failed status %d\n", status);
                     return(status);
                   }

     data = (char **) (*attr_list) -> data_ptr ;

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;
	_PDMdebug (fname, "columns is %s\n", data [count+c]) ;
        if (! strcmp (data [count + c], "n_creator"))
         {
           status = MEMwrite_data (*data_list, user_name, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _PDMdebug (fname, "Wr Data : status = <0x%.8x>\n",
			  status) ;
              return (NFM_E_MEM);           
            }
         }
        else if (! strcmp (data [count + c], "n_creationdate"))
         {
           status = MEMwrite_data (*data_list, date, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _PDMdebug (fname, "Wr Data : status = <0x%.8x>\n",
			  status) ;
              return (NFM_E_MEM);           
            }
         }
        else if (! strcmp (data [count + c], "n_aclno"))
         {
	   sprintf (tmp_str, "%d", WFinfo.acl) ;
           status = MEMwrite_data (*data_list, tmp_str, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _PDMdebug (fname, "Wr Data : status = <0x%.8x>\n",
			  status) ;
              return (NFM_E_MEM);           
            }

           status = MEMwrite_data (*attr_list, acl_no, x + 1,
				   column_of_valueno);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _PDMdebug (fname, "Wr Data : status = <0x%.8x>\n",
			  status) ;
              return (NFM_E_MEM);           
            }

         }
      }

     status = _NFMadd_to_value_list (attr_list, value_list, "t_basic",
				     t_basic_row, column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _PDMdebug (fname, "NFMadd_to_value_list : status = <0x%.8x>\n",
		     status) ;
	 return (status) ;
       }

     
     status = _NFMadd_to_value_list (attr_list, value_list, "t_appl", 
				     t_appl_row, column_of_valueno) ;
     if ((status != NFM_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND)) 
       {
	 _PDMdebug (fname, "NFMadd_to_value_list : status = <0x%.8x>\n",
		     status) ;
	 return (status) ;
       }

     _PDMdebug (fname, "SUCCESSFUL\n") ;
     return (NFM_S_SUCCESS);
   }


*/

/* - This function should be called to validate the view and to 
     get the buffer format for the view catalog creation
     - Kumar Narayanan
*/

long PDMprepare_view_catalog_creation (cat_data, acl_list, attr_list, data_list, value_list)
     MEMptr   *cat_data, *acl_list, *attr_list, *data_list, *value_list;
   {
     static char *fname = "PDMprepare_view_catalog_creation" ;
     long     status;
     char     **column ;
     char     str [1024], date [50] ;
     short    i =0;

     _PDMdebug (fname, "ENTER\n") ;
     

           status = MEMopen(cat_data,512);
            if(status != MEM_S_SUCCESS)
               {
                  _PDMdebug(fname,"MEMopen of output class failed status %d\n",
status);
                     return(status);
                    }

           status = MEMwrite_format(*cat_data,"n_catalogno","integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_catalogname", "char(20)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_catalogdesc","char(40)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_creator", "char(14)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_creationdate", "timestamp");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_updater", "char(14)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_updatedate", "timestamp");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_identifier", "char(20)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_stateno", "integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_aclno", "integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_type", "char(3)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_archiveno", "integer");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_archivestate", "char(1)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"n_pendingflag", "char(2)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"t_basic", "char(20)");
           if(status == MEM_S_SUCCESS)
           status = MEMwrite_format(*cat_data,"t_appl", "char(20)");
           if(status != MEM_S_SUCCESS)
                   {
                  _PDMdebug(fname,"MEMwrite_format failed status %d\n", status);
                     return(status);
                   }


      str[0] = '\0';

     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS)
       {
	 _PDMdebug (fname, "Get Ris date : status = <0x%.8x>\n",
		     status) ;
	 return (status) ;
       }
     status = MEMbuild_array (*cat_data) ;
     if (status != MEM_S_SUCCESS)
     {
       _PDMdebug (fname, "MEMbuild_array:*cat_data:status=<0x%x.8>\n", status) ;
       return (NFM_E_MEM) ;
     }
     column = (char **) (*cat_data)->column_ptr ;

     for (i=0; i<(*cat_data)->columns; i++)
       {
	 if (strcmp (column [i], "t_basic") == 0)
	   {
	     strcat(str, "PDM") ;
             strcat(str,"\1");
	   }
	 else if (strcmp (column [i], "t_appl") == 0)
             {
	     strcat(str, "PDM") ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_identifier") == 0)
             {
	     strcat(str, "PDM") ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_creator") == 0)
             {
	     strcat(str, NFMglobal.NFMusername);
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_creationdate") == 0)
             {
	     strcat(str, date) ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_type") == 0)
             {
	     strcat(str, "CID") ;
             strcat(str,"\1");
              }
         else strcat(str,"\1");
       }

     status = MEMwrite (*cat_data, str) ;
     if (status != MEM_S_SUCCESS)
     {
       _PDMdebug (fname, "MEMwrite : *cat_data : status = <0x%x.8>\n", status) ;
       return (NFM_E_MEM) ;
     }
     status = _NFMget_catalog_acl_list (acl_list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _PDMdebug (fname, "Get ACL list : status = <0x%.8x>\n",
		     status) ;
	 return (status) ;
       }


     status = NFMi_template (attr_list) ;
     if (status != NFM_S_SUCCESS)
       {
         _PDMdebug (fname, "template failed : status = <0x%.8x>\n",
                     status) ;
         return (status) ;
       }

    if(PDMdebug_on)
       MEMprint_buffer("attr_list",*attr_list,PDM_DEBUG_FILE);
     
     status = _NFMget_data_info (*attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _PDMdebug (fname, "Get Data Values : status = <0x%.8x>\n",
        status);
        return (status);
      }

    if(PDMdebug_on)
      {
       MEMprint_buffer("data_list",*data_list,PDM_DEBUG_FILE);
       MEMprint_buffer("value_list",*value_list,PDM_DEBUG_FILE);
      }
     _PDMdebug (fname, "SUCCESSFUL\n") ;
     return (PDM_S_SUCCESS);
   }

/*
  Kumar 8/14/92
   - Creation of view catalog is based on three assumptions
      1. The view defintion exists in risviews, and ris_view_def.
      2. e_catalog table is already created.
      3. Rows to describe the definition of n_itemname and n_itemdesc
         are entered with negative n_itemnos.
*/

long PDMcreate_view_catalog (cat_data, attr_list, data_list, value_list, 
                                dyn_table, dyn_attr,dyn_data,dyn_list)
     MEMptr   cat_data, attr_list, data_list, value_list;
     char     *dyn_table;
     MEMptr   dyn_attr, dyn_data, dyn_list;

   {
     static char *fname = "PDMcreate_view_catalog" ;
     long     status;
     char     **data, **column ;
     char     pdc_table[21], cat_name[20];
     short    y=0, i = -1, comma = 0, count = 0, add = 0;
     char     *sql_str, *sql_str1, sql_str2[200],table_no[32], out_str[25];
     char     e_cat[22];
     int      dyn_no = 0, catalog_no, acl = 0;
     MEMptr   bufr = NULL;
     

     _PDMdebug (fname, "ENTER\n") ;

    if(PDMdebug_on) {
      _PDMdebug (fname, "Printing input buffers...\n");
       MEMprint_buffer ("cat_data", cat_data, PDM_DEBUG_FILE);
       MEMprint_buffer ("attr_list", attr_list, PDM_DEBUG_FILE);
       MEMprint_buffer ("data_list", data_list, PDM_DEBUG_FILE);
       MEMprint_buffers ("value_list", value_list, PDM_DEBUG_FILE);
       MEMprint_buffer ("dyn_attr", dyn_attr, PDM_DEBUG_FILE);
       MEMprint_buffer ("dyn_data", dyn_data, PDM_DEBUG_FILE);
       MEMprint_buffers ("dyn_list", dyn_list, PDM_DEBUG_FILE);
      }

        sprintf(sql_str2,"SELECT n_commandno FROM nfmcommands WHERE n_commandname = 'Create Catalog' ");
        status = SQLquery(sql_str2,&bufr,512);
        if (status != SQL_S_SUCCESS) {
                _PDMdebug(fname, "PDMquery_commandno failed %d\n", status);
                return (status);
        }
        status  = MEMbuild_array(bufr);
        if (status != MEM_S_SUCCESS) {
                         MEMclose(&bufr);
                _PDMdebug(fname, "MEMbuild_array failed %d\n", status);
                return (status);
        }
          data = (char **) bufr->data_ptr;
                    WFinfo.command = atoi(data[0]);

            MEMclose(&bufr);
     status = MEMbuild_array (cat_data);
     if (status != MEM_S_SUCCESS)
      {
        WFload_catalog_no (-1) ;
        _PDMdebug (fname, "MEM Build Array : status = <0x%.8x>\n",
                    NFM_E_MEM);
        return (PDM_E_BUILD_ARRAY);
      }

     column = (char **) cat_data -> column_ptr;
     data  = (char **) cat_data -> data_ptr;


     for (y = 0; y < cat_data -> columns; ++y)
      {
        if (! strcmp (column [y], "n_catalogname"))  i = y;
        if (! strcmp (column [y], "n_aclno"))  acl = y;
      }
 

     sprintf (cat_name, "%s",   data [i]);

        if (!strlen (cat_name) )
       {
         WFload_catalog_no (-1) ;
         _PDMdebug (fname, "Bad catalog name\n") ;
         return (NFM_E_GET_CATALOG_NAME) ;
       }
   
      sprintf(e_cat,"e_%s",cat_name); 
    status = PDMget_table_no(e_cat,"catalog",&catalog_no);
    if(status != PDM_S_SUCCESS)
    {
      status = PDMget_table_no(e_cat,"CATALOG",&catalog_no);
       if(status != PDM_S_SUCCESS)
          {
          status = PDMcreate_interface_table(cat_name, &catalog_no);
             if(status != PDM_S_SUCCESS)
              {
            _PDMdebug(fname,"ERROR: e_%s not found :\n",cat_name);
                return(PDM_E_TABLE_NOT_FOUND);
               }
          }
     } 

    sql_str = (char *) malloc ((4 * cat_data -> row_size) + MEM_SIZE);
     if (! sql_str)
      {
        _PDMdebug (fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC);
        return (NFM_E_MALLOC);
      }
     sql_str [0] = '\0';

     sql_str1 = (char *) malloc ((4 * cat_data -> row_size) + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        _PDMdebug (fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC);
        return (NFM_E_MALLOC);
      }
     sql_str1 [0] = '\0';

     status = WFload_catalog_name (cat_name);

     status = WFload_catalog_no (catalog_no) ;

     sprintf (sql_str,  "INSERT INTO %s (", "NFMCATALOGS");
     sprintf (sql_str1, ") VALUES (");

     comma = 0; i = -1;

     for (count = 0; count < cat_data -> columns; ++count)
      {

        add = 0;

        _PDMdebug (fname, "%s\n", column [count]) ;

        if (! strcmp (column [count ], "n_catalogno"))
         {
           add = 1;

           sprintf (table_no, "%d", (catalog_no+1));

           status = MEMwrite_data (cat_data, table_no, 1, count + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              _PDMdebug (fname, "Wr Data : status = <0x%.8x>\n",
                          status);
              return (NFM_E_MEM);
            }
         }
        else if (! strcmp (column [count], "n_identifier"))
         {
           add = 1;

           status = MEMwrite_data (cat_data, "PDM", 1, count + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              _PDMdebug (fname, "Wr Data : status = <0x%.8x>\n",
                          status);
              return (NFM_E_MEM);
           }
         }
        else if (! strcmp (column [count], "n_aclno"))
         {
           if (! strlen (data [count]))
             {
               _PDMdebug (fname, "Failure : No Acl specified\n") ;
               return (NFM_E_BAD_ACL) ;
             }
           add = 1;
         }
        else if (! strcmp (column [count], "n_stateno"))
          add = 0;
        else if (! strcmp (column [count], "n_updater"))
           add = 0;
        else if (! strcmp (column [count ], "n_updatedate"))
           add = 0;
        else if (! strcmp (column [count ], "n_updatetime"))
           add = 0;
        else if (! strcmp (column [count ], "n_archivestate"))
           add = 0;
        else if (! strcmp (column [count ], "n_archiveno"))
           add = 0;
        else if (! strcmp (column [count ], "n_pendingflag"))
           add = 0;
        else if (! strcmp (column [count ], "n_pendinguser"))
           add = 0;
        else if (! strcmp (column [count ], "t_basic"))
           add = 0;
        else if (! strcmp (column [count ], "t_appl"))
           add = 0;
        else if (strlen (column [count])) add = 1;

        if (add)
         {
           if (comma)
            {
               strcat (sql_str,  ", ");
               strcat (sql_str1, ", ");
            }
           else
               comma = 1;

           strcat (sql_str, column [count]);

           if ((strcmp(column[count], "n_stateno")) &&
                (strcmp(column[count],"n_catalogno")) &&
                (strcmp(column[count], "n_aclno")) &&
                (strcmp(column[count], "n_archiveno")) &&
                (strcmp(column[count],"n_creationdate")) &&
                (strcmp(column[count],"n_updatedate")))
            {
               strcat (sql_str1, "'");
               strcat (sql_str1, data [count]);
               strcat (sql_str1, "'");
            }
            else if ((! strcmp (column [count], "n_creationdate")) ||
                      (! strcmp (column[count], "n_updatedate")))
              {
                status = NFMascii_to_timestamp_format (data [count], out_str) ;
                if (status != NFM_S_SUCCESS)
                  {
                    _PDMdebug (fname,"ascii to timestamp:status = <0x%.8x>\n",
                                status) ;
                    return (status) ;
                  }

                strcat (sql_str1, "TIMESTAMP '") ;
                strcat (sql_str1, out_str);
                strcat (sql_str1, "'") ;
              }

           else
              {
               if (strlen (data [count]))  strcat (sql_str1, data [count]);
               else  strcat (sql_str1, 'null');
               }
         }
      }
     WFload_acl_st (atol (data [acl])) ;

     status = WFload_wf_struct_for_sts () ;
     if (status != NFM_S_SUCCESS)
       {
         _PDMdebug (fname, "load transition for acl %d failed : status = <0x%.8x>\n", atol (data [acl]), status) ;
         return (status) ;
       }

     strcat (sql_str, sql_str1);
     strcat (sql_str, ")");

     free (sql_str1);

 status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
         free (sql_str);
         if (status == SQL_E_DUPLICATE_VALUE)
          {
            _PDMdebug (fname, "Cat Exists : status = <0x%.8x>\n",
            NFM_E_DUP_CATALOG);
            return (NFM_E_DUP_CATALOG);
          }

         _PDMdebug (fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
                     status);
         return (NFM_E_SQL_STMT);
      }

     free (sql_str);

     /* create the view attributes as a template */
     if(PDMdebug_on)
      {
       MEMprint_buffer("attr_list",attr_list,PDM_DEBUG_FILE);
       MEMprint_buffer("data_list",data_list,PDM_DEBUG_FILE);
       MEMprint_buffer("value_list",value_list,PDM_DEBUG_FILE);
      }

      status=NFMcreate_template("PDMVIEW",cat_name,"PDM", attr_list,
                        data_list,value_list);
    if (status != NFM_S_SUCCESS)
    {
             _PDMdebug(fname,"PDMcreate_catalog_template: \n");
             _PDMdebug(fname,"NFMcreate_template failed status = %d\n",status);
             status = PDM_E_CREATE_TEMPLATE;
             return(status);
    }


  /* create  pdc table for this catalog */

    strcpy(PDMdynamic_table,"");
    status = MEMbuild_array(dyn_attr);
    if(status == MEM_S_SUCCESS)
    {
   if(dyn_attr && dyn_attr->rows > 0 )
   {
   pdc_table[0] = '\0';
if((!strcmp(dyn_table,"")) || dyn_table == NULL)
   sprintf(pdc_table,"y_%s",cat_name);
   else(strcpy(pdc_table,dyn_table));

    status = PDMget_table_no(pdc_table,pdc_table,&dyn_no);
    if(status != PDM_S_SUCCESS && status != PDM_E_TABLE_NOT_FOUND)
    {
                PDMdebug("PDMmodify_catalog:\n");
               _PDMdebug(fname,"\tPDMget_table_no failed : status %d\n",status);
                return(status);
    }
     if(status != PDM_S_SUCCESS)
     {
    strcpy(PDMdynamic_table,pdc_table);
    if(PDMdebug_on)
      {
       MEMprint_buffer("dyn_attr",dyn_attr,PDM_DEBUG_FILE);
       MEMprint_buffer("dyn_data",dyn_data,PDM_DEBUG_FILE);
       MEMprint_buffer("dyn_value",dyn_list,PDM_DEBUG_FILE);
      }
   status = PDMcreate_dynamic_table(PDMexec->user_id,pdc_table,dyn_attr,dyn_data, dyn_list);
   if(status != PDM_S_SUCCESS)
       {
          _PDMdebug(fname, "PDMcreate_dynamic_table failed status ",status);
             return(status);
       }
     }
    }
   }
     _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", PDM_S_SUCCESS);

     _PDMdebug (fname, "EXIT\n") ;

     return(PDM_S_SUCCESS);

}


int PDMcreate_systable_view(view_name)
char *view_name;
{
char   *fname = "PDMcreate_systable_view";
char   **attr_column, **attr_data, cat_name[25], table_str[250], sql_str[1024];
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
long   status;
int    i,a = 0,b = 0, nxi, cat_no = 0;


      _PDMdebug(fname,"Enter:\n");

     if(strlen(view_name) > 18)
         return(PDM_E_IDENTIFIER_TOO_LONG);

    status = PDMi_verify_catalog(view_name);
   if(status == PDM_S_SUCCESS)
       {
                sprintf("%s \t %s %s %s \n",
                "PDMi_create_catalog aborted ..",
                "Catalog ",view_name,"found on the server");
                return(PDM_E_CATALOG_EXISTS);
          }

       strcpy(sql_str,"");

     sprintf (table_str, "n_tableno in (select n_tableno from nfmtables where n_tablename = 'catalog' and (n_tabletype = 't_basic' or n_tabletype = 't_appl') and n_identifier = 'PDM')") ;


     sprintf (sql_str, "SELECT %s%s%s FROM %s WHERE %s %s",
              "n_name, n_datatype, n_synonym, ",
              "n_application, n_read, n_write, n_update, n_delete, n_null, ",
              "n_checkin, n_checkout, n_seqno, n_attrno, n_tableno",
              "NFMATTRIBUTES", table_str, "ORDER BY n_tableno,n_seqno");

      status = _NFMget_attributes_from_query ( sql_str, &attr_list) ;
     if (status != NFM_S_SUCCESS)
       {
         _PDMdebug (fname, "Get attributes from query : status = <0x%.8x>\n",
                     status) ;
         return (status) ;
       }

         status = MEMbuild_array(attr_list);
     if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fname, "MEMbuild_array failed : status = <0x%.8x>\n",
                     status) ;
         return (status) ;
       }

       attr_column = (char **) attr_list->column_ptr;
       attr_data = (char **) attr_list->data_ptr;
       for(i=0; i < attr_list->columns; i++)
        {
         if(!strcmp(attr_column[i],"n_name")) a = i;
         else if(!strcmp(attr_column[i],"n_datatype")) b = i;
        }
       for(i=0; i < attr_list->rows; i++)
        {
          nxi = i * attr_list->columns;
         if(!strcmp(attr_data[nxi + a],"n_itemname")) 
             MEMwrite_data(attr_list,"char(240)",i+1, b+1);
         else if(!strcmp(attr_data[nxi+a],"n_itemdesc")) 
             MEMwrite_data(attr_list,"char(240)",i+1, b+1);
         }
          

     sprintf(sql_str,"p_altpartno\1char(40)\1Customer Part Number\1PDM\1Y\1Y\1Y\1Y\1Y\1Y\1Y\1%d\1%d\1%d\1%d\1%d\1",31, 1000000,47,0,0);
       status = MEMwrite(attr_list,sql_str);

       if(PDMdebug_on)
        MEMprint_buffer("attr_list", attr_list, PDM_DEBUG_FILE);
      status = _NFMget_data_info (attr_list, &data_list, &value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        _PDMdebug (fname, "Get Data Values : status = <0x%.8x>\n",
        status);
        return (status);
      }

      cat_name[0]= '\0';
      sprintf(cat_name ,"e_%s", view_name);
      status = _NFMcreate_table ("CATALOG", cat_name, "PDM",  &cat_no,
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        if (status != NFM_E_DUP_CATALOG)
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
        _PDMdebug (fname, "Create Cat : status = <0x%.8x>\n", status);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
      }

        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
      _PDMdebug(fname,"Exit:\n");
     
      return(PDM_S_SUCCESS);
}


/* Creation of parametric catalog doesn't create f_catalog 
   coz' this doesn't involve any files. Otherwise it's a
   regular catalog creation using the attribute subsytem.
   
   - Kumar Narayanan

*/
    
long PDMcreate_parametric_catalog (cat_attr, cat_data, attr_list, data_list, value_list,dyn_table, dyn_attr,dyn_data,dyn_list)
     MEMptr   cat_attr, cat_data; 
     MEMptr   attr_list, data_list, value_list;
     char     *dyn_table;
     MEMptr   dyn_attr, dyn_data, dyn_list;

   {
     static char *fname = "PDMcreate_parametric_catalog" ;
     long     status;
     int      dyn_no;
     char     **data, **column ;
     char     pdc_table[21], cat_name[20];
     short    y=0, i = -1, comma = 0, count = 0, add = 0;
     char     *sql_str, *sql_str1, table_no[32], out_str[25];
     int      catalog_no, acl =0;
     MEMptr   attr_list1 = NULL, data_list1 = NULL;
     MEMptr   attr_list2 = NULL, data_list2 = NULL;
     MEMptr   identifier_list = NULL ;
    
    
     _PDMdebug (fname, "ENTER\n") ;

    if(PDMdebug_on) {
       MEMprint_buffer("cat_attr",cat_attr,PDM_DEBUG_FILE);
       MEMprint_buffer("cat_data",cat_data,PDM_DEBUG_FILE);
          }

     status = MEMbuild_array (cat_data);
     if (status != MEM_S_SUCCESS)
      {
        WFload_catalog_no (-1) ;
        _PDMdebug (fname, "MEM Build Array : status = <0x%.8x>\n",
                    NFM_E_MEM);
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
        return (PDM_E_BUILD_ARRAY);
      }

     column = (char **) cat_data -> column_ptr;
     data  = (char **) cat_data -> data_ptr;


     for (y = 0; y < cat_data -> columns; ++y)
      {
        if (! strcmp (column [y], "n_catalogname"))  i = y;
        if (! strcmp (column [y], "n_aclno"))  acl = y;
      }
 

      sprintf (cat_name, "%s",   data [i]);

        if (!strlen (cat_name) )
       {
         WFload_catalog_no (-1) ;
         _PDMdebug (fname, "Bad catalog name\n") ;
         return (NFM_E_GET_CATALOG_NAME) ;
       }

status = NFMsplit_template_attributes (attr_list, data_list,
                                            &attr_list1, &data_list1,
                                            &attr_list2, &data_list2,
                                            &identifier_list) ;
     if (status != NFM_S_SUCCESS)
      {
        WFload_catalog_no (-1) ;
        MEMclose (&attr_list1);
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _PDMdebug (fname,  "Split Cat Buffers : status = <0x%.8x>\n", status);
        return (status);
      }

        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        MEMclose (&identifier_list);

      /* ALR   4/28/94  Data Definition stmts can not occur in a 
       transaction. Can not determine where the transaction has 
       started and not been committed. Turn transactions off to
       insure the create table will work.   TR 139418848 */

      status = NFMstart_transaction(0);
      if (status != NFM_S_SUCCESS)
       {
          _PDMdebug(fname,"NFMstart_transaction failed <0x%.8x>\n",status);
       } 
     _PDMdebug(fname,"Creating catalog table %s\n",cat_name);

      status = _NFMcreate_table ("CATALOG", cat_name, "PDM",  &catalog_no,
              attr_list1, data_list1, value_list);
     if (status != NFM_S_SUCCESS)
      {
        if (status != NFM_E_DUP_CATALOG)
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
        _PDMdebug (fname, "Create Cat : status = <0x%.8x>\n", status);
        return (status);
      }

   strcpy(PDMdynamic_table,"");
   status = MEMbuild_array (dyn_attr);
   if(status == MEM_S_SUCCESS) {

     /* create  pdc table for this catalog */

     if(dyn_attr->rows > 0 ) {
       pdc_table[0] = '\0';
       if(strlen(dyn_table) > 0)
            sprintf(pdc_table,"%s",dyn_table);
       else
            sprintf(pdc_table,"y_%s",cat_name);

       status = PDMget_table_no(pdc_table,pdc_table,&dyn_no);

       if(status != PDM_S_SUCCESS && status != PDM_E_TABLE_NOT_FOUND) {
           _PDMdebug(fname,"\tPDMget_table_no failed : status %d\n",status);
           return(status);
           }

       else if (status == PDM_E_TABLE_NOT_FOUND) {
    /*  table needs to be created.  MaC */
           strcpy(PDMdynamic_table,pdc_table);
           status = PDMcreate_dynamic_table(PDMexec->user_id,
                                                 pdc_table,
                                                 dyn_attr,
                                                 dyn_data,
                                                 dyn_list);
             if(status != PDM_S_SUCCESS) {
              NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
              _PDMdebug(fname, "PDMcreate_dynamic_table failed status ",status);
              return(status);
              }
          }

    /* If a table already exists,  it needs to be modified MaC*/
        else if(status == PDM_S_SUCCESS) {
          status = NFMchange_table(PDMexec->user_id,
                                     pdc_table, pdc_table,
                                     dyn_attr, dyn_data, dyn_list);
          if (status != NFM_S_SUCCESS) {
              _PDMdebug(fname,
                 "NFMchange_table of dynamic attrfailed : <0x%.8x>\n",status);
               NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
               NFMreset_change_table(PDMexec->user_id, pdc_table,
                                            pdc_table, NULL,
                                            NULL, NULL);
               return(status);
               }
        strcpy(PDMdynamic_table,pdc_table);
         }
     }
   }
  else if (status != MEM_S_SUCCESS) {
     _PDMdebug (fname, "MEM Build Array : status = <0x%.8x>\n", NFM_E_MEM);
      }

   sql_str = (char *) malloc ((4 * cat_data -> row_size) + MEM_SIZE);
   if (! sql_str)
      {
        _PDMdebug (fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC);
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
        return (NFM_E_MALLOC);
      }
    sql_str [0] = '\0';

    sql_str1 = (char *) malloc ((4 * cat_data -> row_size) + MEM_SIZE);
    if (! sql_str1)
      {
        free (sql_str);
        _PDMdebug (fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC);
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
        return (NFM_E_MALLOC);
      }
     sql_str1 [0] = '\0';

     status = WFload_catalog_name (cat_name);

     status = WFload_catalog_no (catalog_no) ;

     sprintf (sql_str,  "INSERT INTO %s (", "NFMCATALOGS");
     sprintf (sql_str1, ") VALUES (");

     comma = 0; i = -1;

     for (count = 0; count < cat_data -> columns; ++count)
      {

        add = 0;

        _PDMdebug (fname, "%s\n", column [count]) ;

        if (! strcmp (column [count ], "n_catalogno"))
         {
           add = 1;

           sprintf (table_no, "%d", catalog_no);

           status = MEMwrite_data (cat_data, table_no, 1, count + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              _PDMdebug (fname, "Wr Data : status = <0x%.8x>\n",
                          status);
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
              return (NFM_E_MEM);
            }
         }
        else if (! strcmp (column [count], "n_identifier"))
         {
           add = 1;

           status = MEMwrite_data (cat_data, "PDM", 1, count + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              _PDMdebug (fname, "Wr Data : status = <0x%.8x>\n",
                          status);
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
              return (NFM_E_MEM);
           }
         }
        else if (! strcmp (column [count], "n_aclno"))
         {
           if (! strlen (data [count]))
             {
               _PDMdebug (fname, "Failure : No Acl specified\n") ;
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
               return (NFM_E_BAD_ACL) ;
             }
           add = 1;
         }
        else if (! strcmp (column [count], "n_stateno"))
          add = 0;
        else if (! strcmp (column [count], "n_updater"))
           add = 0;
        else if (! strcmp (column [count ], "n_updatedate"))
           add = 0;
        else if (! strcmp (column [count ], "n_updatetime"))
           add = 0;
        else if (! strcmp (column [count ], "n_archivestate"))
           add = 0;
        else if (! strcmp (column [count ], "n_archiveno"))
           add = 0;
        else if (! strcmp (column [count ], "n_pendingflag"))
           add = 0;
        else if (! strcmp (column [count ], "n_pendinguser"))
           add = 0;
        else if (! strcmp (column [count ], "t_basic"))
           add = 0;
        else if (! strcmp (column [count ], "t_appl"))
           add = 0;
        else if (strlen (column [count])) add = 1;

        if (add)
         {
           if (comma)
            {
               strcat (sql_str,  ", ");
               strcat (sql_str1, ", ");
            }
           else
               comma = 1;

           strcat (sql_str, column [count]);

           if ((strcmp(column[count], "n_stateno")) &&
                (strcmp(column[count],"n_catalogno")) &&
                (strcmp(column[count], "n_aclno")) &&
                (strcmp(column[count], "n_archiveno")) &&
                (strcmp(column[count],"n_creationdate")) &&
                (strcmp(column[count],"n_updatedate")))
            {
               strcat (sql_str1, "'");
               strcat (sql_str1, data [count]);
               strcat (sql_str1, "'");
            }
            else if ((! strcmp (column [count], "n_creationdate")) ||
                      (! strcmp (column[count], "n_updatedate")))
              {
                status = NFMascii_to_timestamp_format (data [count], out_str) ;
                if (status != NFM_S_SUCCESS)
                  {
                    _PDMdebug (fname,"ascii to timestamp:status = <0x%.8x>\n",
                                status) ;
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
                    return (status) ;
                  }

                strcat (sql_str1, "TIMESTAMP '") ;
                strcat (sql_str1, out_str);
                strcat (sql_str1, "'") ;
              }

           else
              {
               if (strlen (data [count]))  strcat (sql_str1, data [count]);
               else  strcat (sql_str1, 'null');
               }
         }
      }
     WFload_acl_st (atol (data [acl])) ;

     status = WFload_wf_struct_for_sts () ;
     if (status != NFM_S_SUCCESS)
       {
         _PDMdebug (fname, "load transition for acl %d failed : status = <0x%.8x>\n", atol (data [i]), status) ;
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
         return (status) ;
       }

     strcat (sql_str, sql_str1);
     strcat (sql_str, ")");

     free (sql_str1);

 status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
         free (sql_str);
         if (status == SQL_E_DUPLICATE_VALUE)
          {
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
            _PDMdebug (fname, "Cat Exists : status = <0x%.8x>\n",
            NFM_E_DUP_CATALOG);
            return (NFM_E_DUP_CATALOG);
          }

         _PDMdebug (fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
                     status);
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
         return (NFM_E_SQL_STMT);
      }

     free (sql_str);

     _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", PDM_S_SUCCESS);

     _PDMdebug (fname, "EXIT\n") ;

     return(PDM_S_SUCCESS);

}

/* 
          STORE THE COMPUTE FUNCTIONS IN e_<catalog> TABLE


    The function or expression for computing the Part Number [n_itemname]
and Part Description [n_itemdesc] is stored in e_<catalog> table.

  kumar - 09/01/92

*/


int PDMstore_compute_functions(catalog_name, part_function, desc_function)

char *catalog_name;
char *part_function;
char *desc_function;

{
  char *fname="PDMstore_compute_functions";
  int item_no = -1;
   char *partnum_function;
   char *partdesc_function;
  int  name_str_len, desc_str_len, str_max,dyn_len, insert_str_len, part1 = 0, desc1 = 0;
  char *name_str, *desc_str, *temp_name, *temp_desc, str1[512];
  char  part_ins_str[241], desc_ins_str[241];
     long     status;


      _PDMdebug(fname,"Enter:\n");

       part1 = strlen (part_function) + 132;
       desc1 = strlen (desc_function) + 132;

      partnum_function = (char *) malloc (part1);
      partdesc_function = (char *) malloc (desc1);

    memset(partnum_function,NULL, part1);
    memset(partdesc_function,NULL, desc1);
    memset(desc_ins_str,NULL, 241);

         PDMparse_for_tic (part_function, partnum_function);
         PDMparse_for_tic (desc_function, partdesc_function);

      _PDMdebug(fname,"part %s:\n", partnum_function);
      _PDMdebug(fname,"desc %s:\n", partdesc_function);

    name_str_len = strlen (partnum_function);
    desc_str_len = strlen (partdesc_function);
    str_max = ( PDMmax(name_str_len,desc_str_len) + 1);
    _PDMdebug(fname,"str_max %d:\n", str_max);
    temp_name = name_str = (char *) malloc (str_max);
    temp_desc =desc_str = (char *) malloc (str_max);
    memset(name_str,NULL, str_max);
    memset(desc_str,NULL, str_max);
    sprintf(name_str,"%s", partnum_function);
    sprintf(desc_str,"%s", partdesc_function);
    _PDMdebug(fname,"name_str %s:\n", name_str);
    _PDMdebug(fname,"desc_str %s:\n", desc_str);
     insert_str_len = 0;

    while(insert_str_len < str_max)
   {
      if( (str_max - insert_str_len) < 241) dyn_len  = str_max - insert_str_len;
       else dyn_len = 240;
      insert_str_len = insert_str_len + dyn_len;
      _PDMdebug(fname,"dyn_len %d:\n", dyn_len);
      memset(desc_ins_str,NULL, 241);

       memccpy(part_ins_str,name_str,'\0', dyn_len);
      _PDMdebug(fname,"part_ins_str %s:\n", part_ins_str);
        memccpy(desc_ins_str,desc_str,'\0', dyn_len);
      _PDMdebug(fname,"desc_ins_str %s:\n", desc_ins_str);

   str1[0]='\0';
   sprintf(str1,"INSERT INTO e_%s (n_itemno, n_itemname,n_itemrev,n_itemdesc, p_parttype) VALUES (%d,'%s','0','%s','P')", catalog_name, item_no, part_ins_str,desc_ins_str);
      status = SQLstmt(str1);
      if(status != SQL_S_SUCCESS)
         {
          _PDMdebug(fname,"SQLstmt failed status %d\n",status);
          return(status);
         }
         item_no--;

      _PDMdebug(fname,"name_str %d:\n", &name_str);

         name_str = name_str +  (dyn_len -1) ;

      _PDMdebug(fname,"name_str %d:\n", &name_str);
      _PDMdebug(fname,"name_str %s:\n", name_str);

         desc_str = desc_str +  ( dyn_len -1) ;

      _PDMdebug(fname,"name_str %s:\n", name_str);
     }

      free(temp_name);
      free(temp_desc);
      free(partnum_function);
      free(partdesc_function);
     
     
     _PDMdebug(fname,"Exit:\n");
  return(PDM_S_SUCCESS);
}


/* Kumar Narayanan

   This functions reads the view defintion from ris_view_def and
   populates the attribute sub system buffers

*/

long PDMpopulate_attribute_info (cat_name, attr_list, data_list, value_list)
     char     *cat_name;
     MEMptr   attr_list, *data_list, value_list;
{
     static char *fname = "PDMpopulate_attribute_info" ;
     long     status;
     char     **column, **data , **col_data;
     char     **tables, **columns;
     char     datatype[20];
     int      seqno,numtbls, numcols, index, syn_index; 
     char     str [1024], seq[5] ;
     short    a = 0, b = 0, nxi, i =0, j =0;
     char     synonym [128], low_cat_name[21];
     MEMptr   col_bufr = NULL; 
     MEMptr   dummy_bufr = NULL; 

     _PDMdebug (fname, "ENTER\n") ;
     
/* ANSI */ 

    value_list = NULL;
     low_cat_name[0] = '\0';
    strcpy(low_cat_name, cat_name);
     if(!SVSGetTablesAndColumnsInView(low_cat_name, &tables,&numtbls,
                                          &columns,&numcols)) {
        _PDMdebug (fname, "ERROR: VIEW PARSER FAILED\n") ;
        return (NFM_E_MEM) ;
         }


   status = MEMsplit_copy_buffer(attr_list, &dummy_bufr, 0);
     if (status != MEM_S_SUCCESS) {
       _PDMdebug (fname, 
             "MEMsplit_copy_buffer:attr_list :status=<0x%x.8>\n", status) ;
       return (NFM_E_MEM) ;
       }

    if(PDMdebug_on)
       MEMprint_buffer("attr_list",attr_list,PDM_DEBUG_FILE);

     str[0] = '\0';
     col_bufr = NULL; 

/*
     sprintf(str, "Select column_name FROM ris_columns WHERE table_name = '%s' or upper_table_name = '%s'", cat_name, cat_name);
*/

/* RIS dictionary tables in V5 named different. 26/apr/95 - raj. */
 
#if defined ( RISV4 )

     sprintf(str, 
        "Select column_name,column_name FROM ris_columns WHERE table_name = '%s' or upper_table_name = '%s'", low_cat_name, cat_name);

#elif defined ( RISV5 )

     sprintf(str, 
        "Select column_name,column_name FROM ris5columns WHERE table_name = '%s' or upper_table_name = '%s'", low_cat_name, cat_name);

#else
#error "RIS version must be defined"
#endif

     status = SQLquery(str, &col_bufr, 1024);
     if (status != SQL_S_SUCCESS) {
        _PDMdebug(fname, 
         "Querying for the columns of the view failed status", status);
                return (status);
        }

    if(PDMdebug_on)
       MEMprint_buffer("col_bufr",col_bufr,PDM_DEBUG_FILE);

     status = MEMbuild_array (col_bufr) ;
     if (status != MEM_S_SUCCESS) {
      MEMclose(&col_bufr);
      _PDMdebug (fname, "MEMbuild_array:col_bufr :status=<0x%x.8>\n", status) ;
       return (NFM_E_MEM) ;
       }

     col_data = (char **) (col_bufr)->data_ptr ;


/* Fix added to update the n_syn col MaC 060393 */

     for(j=0; j < col_bufr->rows; j++) {
      syn_index = col_bufr->columns * j;
      
      synonym [0] = '\0';
      _PDMdebug (fname, "checking attr [%s]\n", col_data[syn_index]);
      if (!strcmp (col_data[syn_index], "n_itemname")) {
          strcpy (synonym, "Part Number");
      }
      else if (!strcmp (col_data[syn_index], "n_itemrev")) {
             strcpy (synonym, "Part Revision ");
             }
      else if (!strcmp (col_data[syn_index], "n_itemdesc")) {
             strcpy (synonym, "Part Description ");
             }
      else if (!strcmp (col_data[syn_index], "n_setindicator")) {
             strcpy (synonym, "Assembly Indicator");
             }
      else if (!strcmp (col_data[syn_index], "n_versionlimit")) {
             strcpy (synonym, "Version Limit");
             }
      else if (!strcmp (col_data[syn_index], "n_status")) {
             strcpy (synonym, "File Status ");
             }
      else if (!strcmp (col_data[syn_index], "n_pendingflag")) {
             strcpy (synonym, "Pending Flag ");
             }
      else if (!strcmp (col_data[syn_index], "n_itemlock")) {
             strcpy (synonym, "Locked");
             }
      else if (!strcmp (col_data[syn_index], "n_aclno")) {
             strcpy (synonym, "ACL");
             }
      else if (!strcmp (col_data[syn_index], "n_stateno")) {
             strcpy (synonym, "State ");
             }
      else if (!strcmp (col_data[syn_index], "n_prevstateno")) {
             strcpy (synonym, "Previous State");
             }
      else if (!strcmp (col_data[syn_index], "n_creator")) {
             strcpy (synonym, "Creator");
             }
      else if (!strcmp (col_data[syn_index], "n_creationdate")) {
             strcpy (synonym, "Part Creation Date");
             }
      else if (!strcmp (col_data[syn_index], "n_updater")) {
             strcpy (synonym, "Updater");
             }
      else if (!strcmp (col_data[syn_index], "n_updatedate")) {
             strcpy (synonym, "Part Update date");
             }
      else if (!strcmp (col_data[syn_index], "n_colevel")) {
             strcpy (synonym, "Set Level");
             }
      else if (!strcmp (col_data[syn_index], "n_archivestate")) {
             strcpy (synonym, "Archive State ");
             }
      else if (!strcmp (col_data[syn_index], "n_iconname")) {
             strcpy (synonym, "Looking Glass Icon Name");
             }
      else if (!strcmp (col_data[syn_index], "n_lgfiletype")) {
             strcpy (synonym, "Looking Glass File Type");
             }
      else if (!strcmp (col_data[syn_index], "p_explode")) {
             strcpy (synonym, "Explode in BOM");
             }
      else if (!strcmp (col_data[syn_index], "p_maxlevel")) {
             strcpy (synonym, "Maximum Level of explosion");
             }
      else if (!strcmp (col_data[syn_index], "p_parttype")) {
             strcpy (synonym, "Part Type");
             }
      else if (!strcmp (col_data[syn_index], "p_incpartrpt")) {
             strcpy (synonym, "Include Part in Summary");
             }
      else if (!strcmp (col_data[syn_index], "p_mrpbomuom")) {
             strcpy (synonym, "BOM Unit of Measure ");
             }
      else if (!strcmp (col_data[syn_index], "p_mrpeffectdate")) {
             strcpy (synonym, "MRP Effective Date ");
             }
      else if (!strcmp (col_data[syn_index], "p_mrpinvuom")) {
             strcpy (synonym, "MRP Inventory Unit of Measure");
             }
      else if (!strcmp (col_data[syn_index], "p_mrpfieldupd")) {
             strcpy (synonym, "MRP Field Update");
             }
      else if (!strcmp (col_data[syn_index], "p_mrppart")) {
             strcpy (synonym, "MRP Part ");
             }
      else if (!strcmp (col_data[syn_index], "p_mrpstruct")) {
             strcpy (synonym, "MRP Structure ");
             }
      else { continue;}
     
      _PDMdebug (fname, "Adding synonym [%s] to row [%d]..\n", synonym, j);

      status = MEMwrite_data (col_bufr, synonym, j+1, 2);
      if (status != MEM_S_SUCCESS) {
       _PDMdebug (fname, "MEMwrite : col_bufr : status = <0x%x.8>\n", status) ;
       return (NFM_E_MEM) ;
       }
      _PDMdebug (fname, "Wrote [%s].\n", synonym);
      }

/* end of additions... synonym addns*/

     status = MEMbuild_array (dummy_bufr) ;
     if (status != MEM_S_SUCCESS) {
       _PDMdebug (fname, 
             "MEMbuild_array:attr_list :status=<0x%x.8>\n", status) ;
       return (NFM_E_MEM) ;
       }

     column = (char **) (dummy_bufr)->column_ptr ;

     status = MEMbuild_array (col_bufr) ;
     if (status != MEM_S_SUCCESS) {
      MEMclose(&col_bufr);
      _PDMdebug (fname, "MEMbuild_array:col_bufr :status=<0x%x.8>\n", status) ;
       return (NFM_E_MEM) ;
       }

    if(PDMdebug_on)
       MEMprint_buffer("col_bufr after adding synonym",col_bufr,PDM_DEBUG_FILE);

     col_data = (char **) (col_bufr)->data_ptr ;

      seqno = 1;
     for(j=0; j < col_bufr->rows; j++)
     {
       index = j * col_bufr->columns;
       status = PDMget_ris_datatype (low_cat_name,col_data[index],datatype);
       if(status != PDM_S_SUCCESS) {
            _PDMdebug (fname, "PDMget_ris_datatype failed <0x%x.8>\n", status) ;
             return (status) ;
            }
       if(!strcmp(datatype,"int")) strcpy(datatype,"integer");
       _PDMdebug (fname, "adding attr [%s]\n", col_data[index]);
       str[0]='\0';
       for (i=0; i<attr_list->columns; i++) {
	 if (strcmp (column [i], "n_name") == 0) {
	     strcat(str, col_data[index]) ;
             strcat(str,"\1");
	   }
	 else if (strcmp (column [i], "n_datatype") == 0) {
	     strcat(str, datatype) ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_synonym") == 0) {
	     strcat(str, col_data[index+1]) ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_read") == 0) {
	     strcat(str, "Y") ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_write") == 0) {
	     strcat(str, "Y") ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_update") == 0) {
	     strcat(str, "Y") ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_delete") == 0) {
	     strcat(str, "N") ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_null") == 0) {
	     strcat(str, "N") ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_checkin") == 0) {
	     strcat(str, "U") ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_checkout") == 0) {
	     strcat(str, "U") ;
             strcat(str,"\1");
              }
	 else if (strcmp (column [i], "n_seqno") == 0) {
             sprintf(seq,"%d", seqno++ );
	     strcat(str, seq);
             strcat(str,"\1");
              }
         else {
          _PDMdebug ("Missed", "-> %s\n", column[i]);
          strcat(str,"\1");
          }
       }
      _PDMdebug(fname,"mem string before MEMwrite %s\n",str);  
     status = MEMwrite (attr_list, str) ;
     if (status != MEM_S_SUCCESS)
     {
       _PDMdebug (fname, "MEMwrite : attr_list : status = <0x%x.8>\n", status) ;
       return (NFM_E_MEM) ;
     }
       str[0]='\0';
    }

    if(PDMdebug_on)
       MEMprint_buffer("attr_list",attr_list,PDM_DEBUG_FILE);

     status = MEMbuild_array (attr_list) ;
     if (status != MEM_S_SUCCESS)
     {
    _PDMdebug (fname, "MEMbuild_array:attr_list :status=<0x%x.8>\n", status) ;
       return (NFM_E_MEM) ;
     }

      MEMclose(data_list);
      MEMclose(&dummy_bufr);
      MEMclose(&col_bufr);
      MEMopen(data_list,512); 
        column = (char **) attr_list->column_ptr;
        data = (char **) attr_list->data_ptr;

        for(i=0;i<attr_list->columns;i++)
        {
          if(!strcmp(column[i],"n_name")) a = i;
          else if(!strcmp(column[i],"n_datatype")) b = i;
        }
        for(i=0;i<attr_list->rows;i++)
        {
            nxi = i * attr_list->columns;
                _PDMdebug(fname,"%s - %s\n", data[nxi+a], data[nxi+b]);
                status = MEMwrite_format(*data_list,data[nxi+a],data[nxi+b]);
                if(status != MEM_S_SUCCESS)
                {
                _PDMdebug(fname,"MEMwrite_format  : status = <0x:%8x>\n", status);
                return (status);
                }
        }
        str[0] = '\0';
        strcpy (str, "\1");

        for (i = 1; i < attr_list->rows; i++)
                strcat (str, "\1");

        if ((status = MEMwrite (*data_list, str)) != MEM_S_SUCCESS) {
             _PDMdebug(fname,"MEMwrite failure : status = <0x:%8x>\n", status);
                return (status);
        }

       SVSFreeTablesAndColumns (&tables, numtbls, &columns, numcols);

     _PDMdebug (fname, "SUCCESSFUL\n") ;
     return (PDM_S_SUCCESS);
}

/* Kumar Narayanan 
*/

 long _PDMfake_create_table (table_type, table_name, identifier, table_no,
                       attr_list, data_list, value_list)
   char      *table_type, *table_name, *identifier;
   long      *table_no ;
   MEMptr    attr_list, data_list, value_list;
   {
     static char *fname = "PDMfake_create_table" ;
     long     status;
     long     _NFMcreate_attributes ();
     long     _NFMload_attributes ();

     _PDMdebug (fname, "Table Type  = <%s> : Table Name = <%s> : Identifier = <%s>\n", 
		 table_type, table_name, identifier);
     
     status = _NFMload_attributes (table_type, table_name, identifier, 
				   table_no,
				   attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Load Table Attr Failed : status = <0x%.8x>\n",
        status);
        return (status);         
      }
     
     _PDMdebug (fname, "SUCCESSFUL\n") ;
     return (NFM_S_SUCCESS);
   }



/* Kumar Narayanan   */


int PDMcreate_interface_table(view_name, cat_no)
char *view_name;
int  *cat_no;
{
char   *fname = "PDMcreate_systable_view";
char   **attr_column, **attr_data, cat_name[25], table_str[250], sql_str[1024];
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
long   status;
int    i,a = 0,b = 0, nxi;
long   cat_num = 0;


      _PDMdebug(fname,"Enter:\n");

     if(strlen(view_name) > 18)
         return(PDM_E_IDENTIFIER_TOO_LONG);

    status = PDMi_verify_catalog(view_name);
   if(status == PDM_S_SUCCESS)
       {
                sprintf("%s \t %s %s %s \n",
                "PDMi_create_catalog aborted ..",
                "Catalog ",view_name,"found on the server");
                return(PDM_E_CATALOG_EXISTS);
          }

       strcpy(sql_str,"");

     sprintf (table_str, "n_tableno in (select n_tableno from nfmtables where n_tablename = 'catalog' and (n_tabletype = 't_basic' or n_tabletype = 't_appl') and n_identifier = 'PDM')") ;


     sprintf (sql_str, "SELECT %s%s%s FROM %s WHERE %s %s",
              "n_name, n_datatype, n_synonym, ",
              "n_application, n_read, n_write, n_update, n_delete, n_null, ",
              "n_checkin, n_checkout, n_seqno, n_attrno, n_tableno",
              "NFMATTRIBUTES", table_str, "ORDER BY n_tableno,n_seqno");

      status = _NFMget_attributes_from_query ( sql_str, &attr_list) ;
     if (status != NFM_S_SUCCESS)
       {
         _PDMdebug (fname, "Get attributes from query : status = <0x%.8x>\n",
                     status) ;
         return (status) ;
       }

         status = MEMbuild_array(attr_list);
     if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fname, "MEMbuild_array failed : status = <0x%.8x>\n",
                     status) ;
         return (status) ;
       }

       attr_column = (char **) attr_list->column_ptr;
       attr_data = (char **) attr_list->data_ptr;
       for(i=0; i < attr_list->columns; i++)
        {
         if(!strcmp(attr_column[i],"n_name")) a = i;
         else if(!strcmp(attr_column[i],"n_datatype")) b = i;
        }
       for(i=0; i < attr_list->rows; i++)
        {
          nxi = i * attr_list->columns;
         if(!strcmp(attr_data[nxi + a],"n_itemname")) 
             MEMwrite_data(attr_list,"char(240)",i+1, b+1);
         else if(!strcmp(attr_data[nxi+a],"n_itemdesc")) 
             MEMwrite_data(attr_list,"char(240)",i+1, b+1);
         }
          

     sprintf(sql_str,"p_altpartno\1char(40)\1Customer Part Number\1PDM\1Y\1Y\1Y\1Y\1Y\1Y\1Y\1%d\1%d\1%d\1%d\1%d\1",31, 1000000,47,0,0);
       status = MEMwrite(attr_list,sql_str);

       if(PDMdebug_on)
        MEMprint_buffer("attr_list", attr_list, PDM_DEBUG_FILE);
      status = _NFMget_data_info (attr_list, &data_list, &value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        _PDMdebug (fname, "Get Data Values : status = <0x%.8x>\n",
        status);
        return (status);
      }

      cat_name[0]= '\0';
/* ANSI */
      cat_num = *cat_no;
/* end ANSI */
      sprintf(cat_name ,"e_%s", view_name);
 status =  _PDMfake_create_table ("CATALOG", cat_name, "PDM", &cat_num,
                       attr_list, data_list, value_list);
/* ANSI */
      *cat_no = cat_num;
/* end ANSI */
     if (status != NFM_S_SUCCESS)
      {
        if (status != NFM_E_DUP_CATALOG)
            NFMdelete_table (PDMexec->user_id, "CATALOG", cat_name);
        _PDMdebug (fname, "Create Cat : status = <0x%.8x>\n", status);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
      }

        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
      _PDMdebug(fname,"Exit:\n");
     
      return(PDM_S_SUCCESS);
}

