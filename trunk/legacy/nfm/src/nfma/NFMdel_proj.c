#include "machine.h"
#include "NFMA.h"

 long NFMdelete_project (user_id, proj_name, proj_no)
   long      user_id;
   char      *proj_name;
   long      *proj_no;
   {
     static char *fname = "NFMdelete_project" ;
     long     status;

     *proj_no = 0;

     _NFMdebug ((fname, "Proj Name = <%s>  ", proj_name));

     status = NFMget_project_no (user_id, proj_name, proj_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Project No : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMcheck_projectcit_empty (user_id, *proj_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Projectcit Not Empty : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMcheck_project_aclmap_empty (user_id, *proj_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Project Acl Map not Empty : status = <0x%.8x>\n",
                  status));
        return (status);
      }

     status = NFMcheck_project_samap_empty (user_id, *proj_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Project Sa Map not Empty: status = <0x%.8x>\n",
                  status));
        return (status);
      }
 
     status = NFMdelete_lop_entry (user_id, *proj_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Delete Lop Entry : status = <0x%.8x>\n", status));
        return (status);
      }
 
     _NFMdebug ((fname, "SUCCESSFUL :  Proj No = <%d>\n", *proj_no));
     return (NFM_S_SUCCESS);
   }





