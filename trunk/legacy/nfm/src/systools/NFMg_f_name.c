#include "machine.h"
#include "NFMsysinc.h"

 long NFMget_file_name (user_id, cat_no, file_no, file_name)
   long    user_id;
   long    cat_no, file_no;
   char    *file_name;
   {
	return(NFMnew_file_name(user_id,cat_no,file_no,file_name));
   }
