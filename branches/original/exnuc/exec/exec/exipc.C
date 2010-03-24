#include <sys/types.h>
#ifndef NT
#include <sys/ipc.h>
#include <sys/msg.h>
#endif
#include <ctype.h>
#include <exmacros.h>
#include <ipcl.h>
#include <errno.h>
#include "exsysdep.h"
#include <stdlib.h>
#include <stdio.h>

#ifdef SUNOS
#include "OMminimum.h"
#endif

extern OMuint OM_Gf_mailbox;

static int EX_msgqid;
static key_t EX_msgqkey;


#define EX_BUFSIZ  1032

static int isnumber(ptr)
char *ptr;
{
   for( ; *ptr && isdigit(*ptr); ptr++);
   return( *ptr ? 0 : 1 );
}

/**********************************************/
/*                                            */
/*  make msgque key from input argument       */
/*                                            */
/**********************************************/

key_t EX_getkey(ptr)
char *ptr;
{
   key_t key;
   int i;
 
   if (isnumber(ptr))
   {
      key = (key_t) atol(ptr);
   }   
   else
   {
      key = (key_t) 0;
      for (i = 0; i < sizeof(key_t) && ptr[i]; i++)  
      {
         key = (key << 8) | ptr[i];
      }
   }
   return(key);
}

/***************************************************/
/*                                                 */
/*    set up message queue for other process       */
/*                                                 */
/***************************************************/
 void EX_set_msgque()
 {
   void EX_rm_msgque();
   int status, msgflg, qid;

   EX_msgqkey = EX_getkey("EXEC") + (key_t) getpid();
   EX_msgqid = -1;
   msgflg = 0666 | IPC_CREAT | IPC_EXCL;
   EX_msgqid = IPCL_get(IPCL_MES, EX_msgqkey,0, msgflg);
   if (EX_msgqid == -1 )
   {
      qid = IPCL_get(IPCL_MES, EX_msgqkey, 0, 0);
      status = IPCL_ctl(IPCL_MES, qid, NULL, IPC_RMID, NULL);
      EX_msgqid = IPCL_get(IPCL_MES, EX_msgqkey, 0, msgflg);
      if (EX_msgqid == -1 )
      {  
         perror(0);
         printf("\nEX_ipc set msg queue failed <%x> <%x>\n",EX_msgqkey, EX_msgqid);
         printf("   can not use mbox in this session\n\n");
      }     
   }  
}

/************************************************************msg*end*/

void EX_rm_msgque()
{
   if (OM_Gf_mailbox && (IPCL_ctl(IPCL_MES,EX_msgqid, IPC_RMID, NULL) == -1) &&
       (errno != EPERM))
   {
      perror("EX_ipc can not remove message queue");
   }   
}



/**********************************************/
/*                                            */
/*  called by exwfi to process msg queue      */
/*                                            */
/**********************************************/

int EX_process_msgque( )
{
   struct 
   {
      long mtype;
      int  response;
      char mtext[EX_BUFSIZ];
   }  buf;
   long status,sts ,len;
   int resp;
   long msg;   
   status = 0;
   while (status != -1)
   {
      status = msgrcv(EX_msgqid,(struct msgbuf *) &buf,
         (sizeof(buf) - sizeof(long)), 0L, IPC_NOWAIT );
      if (status != -1)
      {   
         len = status - sizeof(int);
         resp = buf.response;
         buf.mtext[len] = '\0';
         len++;
         sts = ex$putque(msg=&msg,response=&resp,pos=BACK,byte=&len,
            buffer= buf.mtext);
         if (sts == 0)
         {
            printf("putque failed, msg = %x\n",msg);
         } 
      }
   }
   return((status == -1) ? 0 : status);
}




