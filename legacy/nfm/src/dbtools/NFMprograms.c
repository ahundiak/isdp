#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMget_program_no (user_id, program_name, program_no)
   long    user_id;
   char    *program_name;
   long    *program_no;
   {
     static char *fname = "NFMget_program_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *program_no = 0;

     _NFMdebug ((fname, "Program Name = <%s>  : Program No = <%d>\n",
		 program_name));

     sprintf (sql_str, "WHERE %s = '%s'", "n_programname", program_name);

     status = NFMget_attr_value (user_id, "NFMPROGRAMS", "n_itemno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_PROGRAM, "", NULL);
           _NFMdebug ((fname, "No Such Program : status = <0x%.8x>\n", NFM_E_BAD_PROGRAM));
           return (NFM_E_BAD_PROGRAM);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     *program_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : Program No = <%d>\n", *program_no));
     return (NFM_S_SUCCESS);
   }

 long NFMget_program_name (user_id, program_no,  program_name)
   long    user_id;
   long    program_no;
   char    *program_name;
   {
     static char *fname = "NFMget_program_name" ;
     long    status;
     char    sql_str [1024];

     program_name [0] = 0;

     _NFMdebug ((fname, "Program No   = <%d>  : Program Name = <%s>\n",
		 program_no, program_name));

     sprintf (sql_str, "WHERE %s = '%s'", "n_programno", program_no);

     status = NFMget_attr_value (user_id, "NFMPROGRAMS", "n_itemno",
              sql_str, program_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_PROGRAM, "", NULL);
           _NFMdebug ((fname, "No Such Program : status = <0x%.8x>\n", NFM_E_BAD_PROGRAM));
           return (NFM_E_BAD_PROGRAM);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : Program Name = <%s>\n", program_name));
     return (NFM_S_SUCCESS);
   }
