#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMstruct.h"
#include "DEBUG.h"

  extern struct NFMglobal_st NFMglobal ;

 long NFMget_program_filename (user_id, program_name, file_name)
   long    user_id;
   char    *program_name;
   char    *file_name;
   {
     static   char *fname = "NFMget_program_filename" ;
     long     status, atol ();
     char     sql_str [1024], value [50];
     long     sa_no, cat_no, program_no, file_no;
     char     attr [50] ;
     char     node_name [50], user_name [25], passwd [50];
     char     path_name [100], device_type [10];
     char     mach_id [10], op_sys [10];
     char     net_tcp [10], net_xns [10], net_dec [10];
     char     file [50];

     _NFMdebug ((fname, "Program Name = <%s> \n", program_name));

     status = NFMget_program_no (user_id, program_name, &program_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Program No : status = <0x%.8x>\n", status));
        return (status);
      }

       sprintf (sql_str, "WHERE n_itemnum = %d", program_no);

     sprintf (attr, "MAX(%s)", "n_fileversion");

     status = NFMget_attr_value (user_id, "f_nfmsyscat", attr,
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_FILE, "", NULL);
           _NFMdebug ((fname, "No Such File : status = <0x%.8x>\n", 
		       NFM_E_BAD_FILE));
           return (NFM_E_BAD_FILE);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     strcat (sql_str, " AND n_fileversion = ");
     strcat (sql_str, value);

     status = NFMget_attr_value (user_id, "f_nfmsyscat", "n_fileno", 
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_FILE, "", NULL);
           _NFMdebug ((fname, "No Such File : status = <0x%.8x>\n", 
		       NFM_E_BAD_FILE));
           return (NFM_E_BAD_FILE);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     file_no = atol (value);

     status = NFMget_catalog_no (NFMglobal.NFMuserid, "nfmsyscat", &cat_no) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Bad catalog no for nfmsyscat : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     _NFMdebug ((fname, "NFMSYSCAT CAT NO IS %d\n", cat_no)) ;

     status = NFMget_file_name (user_id, cat_no, file_no, file);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get File Name : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMget_sa_no (user_id, "REPORTS", &sa_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Sa No : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMget_sa_no_info (user_id, sa_no,
              node_name, user_name, passwd, path_name, device_type,
              mach_id, op_sys, net_tcp, net_xns, net_dec);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Sa No Info : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMappend_path_file (op_sys, path_name, file, file_name);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Append File : status = <0x%.8x>\n", status));
        return (status);
      }

     _NFMdebug ((fname, "File Name = <%s> : SUCCESSFUL\n", file_name));

     return (NFM_S_SUCCESS);
   }




