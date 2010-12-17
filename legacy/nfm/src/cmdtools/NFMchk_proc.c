#include "machine.h"
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "ERR.h"
#include "DEBUG.h"

#define      NULL    ((char *) 0)
 extern long NFM_PL_LOCK;
extern struct NFMglobal_st NFMglobal;

 long NFMcheck_process_locks (user_id)
   long   user_id;
   {
     char *fname = "NFMcheck_process_locks" ;
     long    status;

     _NFMdebug ((fname, "ENTER\n")) ;

     if (NFM_PL_LOCK != NFMglobal.NFMuserid)
      {
/*  DUR 1/5/91     ERRload_struct (NFM, NFM_E_PL_LOCK, "", NULL);   */
        _NFMdebug ((fname, "PROCESS STATUS : status = <0x%.8x>\n", 
        NFM_E_PL_LOCK));
        return (NFM_PL_LOCK);        
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMset_process_lock (user_id, lock_status)
   long   user_id, lock_status;
   {
     char *fname = "NFMset_process_lock" ;
     long    status;

     _NFMdebug ((fname, "Lock Status = <%d>\n", lock_status));

     if (NFM_PL_LOCK != NFMglobal.NFMuserid)
      {
           ERRload_struct (NFM, NFM_PL_LOCK, "", NULL);
        _NFMdebug ((fname, "PROCESS STATUS : status = <0x%.8x>\n",
        NFM_PL_LOCK));
        return (NFM_PL_LOCK);        
      }
   
     NFM_PL_LOCK = lock_status;
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMreset_process_lock (user_id, lock_status)
   long   user_id, lock_status;
   {
     char *fname = "NFMreset_process_lock" ;
     long    status;

     _NFMdebug ((fname, "Lock Status = <%d>\n", lock_status));

     if (NFM_PL_LOCK != lock_status)
      {
           ERRload_struct (NFM, NFM_PL_LOCK, "", NULL);
        _NFMdebug ((fname, "PROCESS STATUS : status = <0x%.8x>\n",
        NFM_PL_LOCK));
        return (NFM_PL_LOCK);        
      }

     NFM_PL_LOCK = NFMglobal.NFMuserid;

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
