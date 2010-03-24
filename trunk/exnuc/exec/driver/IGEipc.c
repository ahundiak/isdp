#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/sem.h>
#include <ctype.h>
#include <errno.h>
#include <ipcl.h>

extern key_t IGE_msgqkey;

static int IGE_msgqid;
static int IGE_semid;

#define NULL       0
#define IGE_BUFSIZ  1032

/***************************************************/
/*                                                 */
/*    set up message queue for other process       */
/*                                                 */
/***************************************************/
 int IGE_set_msgque()
 {
   if((IGE_msgqid =IPCL_init(0, IGE_msgqkey, 0666,  IPC_CREAT)) == -1 )
   {
         perror("\nIGE_driver set msg queue failed \n");
         printf("   can not use mbox in this session\n\n");
         return(-1);
   }  
   return(IGE_msgqid);
}

/************************************************************msg*end*/

void IGE_rm_msgque()
{
   if( (IPCL_ctl(IPCL_MES, IGE_msgqid, NULL, IPC_RMID, NULL) == -1)  &&
       (errno != EPERM))
   {
      printf("\nIGE_ipc can not remove message queue errno = %d\n",errno);
   }   
}


/***************************************************/
/*                                                 */
/*    set up semaphore for EX_main                 */
/*                                                 */
/***************************************************/
 int IGE_set_sem()
 {
    if( (IGE_semid = IPCL_get( IPCL_SEM, IGE_msgqkey, 1, 
                                   0666 | IPC_CREAT | IPC_EXCL) ) == -1)
    {
         perror("IGE_driver set semaphore failed ");
         printf("   can not use mbox in this session\n\n");
         return(-1);
    }     
    return((int) IGE_semid);
}

/************************************************************msg*end*/

void IGE_rm_sem()
{
   if( IPCL_ctl(IPCL_SEM, IGE_semid, 1, IPC_RMID, NULL) == -1 )
   {
      perror("IGE_ipc can not remove ");
   }   
}
