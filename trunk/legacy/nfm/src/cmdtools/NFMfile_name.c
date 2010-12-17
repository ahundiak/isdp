#include "machine.h"
#include "NFMerrordef.h"
/***********************************************************************
*			NFMold_file_name				*
*	This function takes a catalog number and file number and	*
*	returns filename in the old convention				*
*									*
************************************************************************/
#include "DEBUG.h"

 long NFMold_file_name (user_id, cat_no, file_no, file_name)
   long    user_id;
   long    cat_no, file_no;
   char    *file_name;/*	Calling function responsible to allocate
				enough space				*/
   {
     long    y;
     char *fname="NFMold_file_name";

     file_name [0] = 0;

     _NFMdebug ((fname,"Entry>>User  Id = <%d> CatNo = <%d> File No = <%d>\n\
                       File  Name = <%s>\n",user_id,cat_no,file_no, file_name));

     sprintf (file_name, "%4.4d%9.9d0", cat_no, file_no);
 
     for (y = 0; y < strlen (file_name); ++y)
      if (file_name [y] == ' ') file_name [y] = '0';

     for (y = strlen (file_name) - 1; y > 9;  --y)
      file_name [y] = file_name [y - 1];

     file_name [8] = '.';
    
     _NFMdebug ((fname,"Exit>>SUCCESSFUL :Filename <%s> status = <0x%.8x>\n",file_name, NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

