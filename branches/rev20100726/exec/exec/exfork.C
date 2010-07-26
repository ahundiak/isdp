#include <stdio.h>
#include <sys/types.h>
#ifndef NT
#include <sys/ipc.h>
#include <sys/msg.h>
#endif
#include <errno.h>
#include <fcntl.h>
#include <exdef.h>
#include <stdlib.h>
#include <string.h>


int EX_fork(num_entry, argu, wait_flag, redir_io, childpid, mask,
   np1, np2, delete_flag)
int   num_entry, wait_flag, redir_io, *childpid, mask, delete_flag;
char  *argu[], *np1, *np2;
{
#ifndef NT
   int   qid, i, len, retu, ret_sta;
   char  *pp;
   long  type;    

#define MAX_MSG      512
#define DELIM_LEN    8
#define DELIM        " _D_e_L_"
#define APP_MTYP     555
#define PARENT_MTYP  888

   struct forkmsg
   {
     long mtype;
     int  wait_flag;
     int  redir_io;
     int  mask;      /* child umask val */
     int  argc;
     int  delete_flag;
     char np1[80];   /* named pipe to be created */
     char np2[80];   /* named pipe to be created */
     char mtext[MAX_MSG];     
   } buf;
   
   struct forkresp
   {
     long mtype;
     int  status;
     int  err_no; 
     int  childpid;
   } buf1;  

 ret_sta = 1;
 pp = getenv("DRIVERQID");
 if ( pp )
  { 
   qid = atoi(pp);

   /* construct msg struct */

   buf.mtype = APP_MTYP;
   buf.wait_flag = wait_flag;
   buf.redir_io = redir_io;
   buf.mask = mask;
   buf.argc = num_entry;
   buf.delete_flag = delete_flag;
   if ((redir_io & CREATE_PIPE) == CREATE_PIPE)
   {
      if ( np1 ) strncpy(buf.np1, np1, 80);
      if ( np2 ) strncpy(buf.np2, np2, 80);  
   }
   else
   {
      buf.np1[0] = '\0';
      buf.np2[0] = '\0';
   }

   buf.mtext[0] = '\0';
   len = 0;
   for (i = 0; i < num_entry; ++i)
   {
      len += strlen(argu[i]);
      len += DELIM_LEN;
      if( len < MAX_MSG )
      {
         strcat(buf.mtext,argu[i]);
         strcat(buf.mtext,DELIM);
      }
      else
      {
         printf("IN EX_fork total length greater than msg buffer\n");
         return(0);
      }
   }

   /* send the message to IGEdriver  */

   retu = msgsnd(qid, (struct msgbuf *) &buf,
      len + 5*sizeof(int) + 160, IPC_NOWAIT);

   if (retu == -1)
   {
      printf("IN EX_fork msgsnd failed qid = %d\n", qid);
      perror("IN EX_fork msgsnd");
      return(0);
   }
   else  /* get msg from driver status of fork */
   {
      type = PARENT_MTYP;
      retu = msgrcv(qid,(struct msgbuf *) &buf1,
         (sizeof(struct forkresp) - sizeof(long)), type, 0);
      if( retu == -1)
      {
         perror("In EX_fork did not rcv return status from driver\n");
	 return(0);
      }								
      else
      {
         if (buf1.status == 0)
	 {
             printf("fork failed\n");
             return(0); 
         }
         else
	 {
            /* return child process id */
            if( childpid != 0 )
	    {
               *childpid = buf1.childpid;
	    }
	    
            /* get msg from driver status of wait */
            if( wait_flag && ! redir_io )  
	    { 
               type = PARENT_MTYP;
               retu = msgrcv(qid,(struct msgbuf *) &buf1,
                  (sizeof(struct forkresp) - sizeof(long)), type, 0);
               if( retu == -1)
               {
                  perror("In EX_fork did not rcv return status from execvp\n");
               }								
               else
               {
                  /* printf("after wait\n"); */
		  ret_sta = buf1.err_no;
	       }
            }
	 }
      }
   }
  }
 else
  {
   printf("In EX_fork no DRIVERQID found from getenv\n");
   ret_sta = 0;
  }
   return( ret_sta );
#else
  printf("ex$fork not implemented for NT\n");
  return(0);
#endif
}
