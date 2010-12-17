/***********************************

		proclkb.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
						added POSIX changes one more time
*/

#include "stdio.h"
#include "fcntl.h"

#include "signal.h"
#include "sys/types.h"
#include "sys/stat.h"
#include "commdefs.h"


#include "NFBpriv.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"
#include "XFBproto_pri.h"


extern char token[255];
extern int token_type;
extern char line[255];
extern int line_ptr;
extern int end_of_file;
extern int old_line_ptr;

extern FILE 	*startup_file;
/* dmb:08/31/92:THis should be extern: defined in exec.c */
extern char		LOGKBD;
/* sml:04-28-92	change from int to pid_t for POSIX */
pid_t		lkb_pid;
int		m_to_kb,kb_to_m;


int process_logical_keyboard_keyword(void)
{
  int	sts;


  struct	COM_DATA
    {
	int	message;
	int	no_bytes;
	union{
		unsigned char	ch_data[1024];
		int		int_data;
	}data;
    }com_data;

  char pathname[200];
  FILE *log_kbd_file;


  fprintf (stderr, "Processing logical keyboard\n");

  token_type = OTHER_TOKEN;
   
   while ((token_type != STRING_TOKEN) &&
          (!end_of_file))
   {
      Get_token();
      
      if (token_type == STRING_TOKEN)
      {
      	 strcpy (pathname, &token[1]);
      	 pathname[strlen(pathname)-1] = '\0';
      	 
         log_kbd_file = fopen (pathname, "r");
         
         if (log_kbd_file == NULL)
         {
         char error_string[1000];

            sprintf (error_string, "no such logical keyboard: %s", pathname);
            Report_nonfatal_error (error_string);
         }
         else
         {
            fclose (log_kbd_file);

   	    LOGKBD = 1;
 
	    /*
 	     * creat the pipes
	     */

            /*********************************************/
            /*                                           */
            /* First get rid of any pipes that may exist */
            /*                                           */
            /*********************************************/

            sts = unlink ("/usr/tmp/KBNP1");
            sts = unlink ("/usr/tmp/KBNP2");

	    sts = mknod("/usr/tmp/KBNP1",S_IFIFO | 0777,0);
	    if( sts == -1 )
	    {
		fprintf(stderr,"Can not creat KBNP1\n");
		perror(NULL);
		LOGKBD = 0;
		return(0);
	    }
	    sts = mknod("/usr/tmp/KBNP2",S_IFIFO | 0777,0);
	    if( sts == -1 )
	    {
		fprintf(stderr,"Can not creat KBNP2\n");
		perror(NULL);
		LOGKBD = 0;
		return(0);
	    }
	    putenv("KBDNP1=/usr/tmp/KBNP1");
	    putenv("KBDNP2=/usr/tmp/KBNP2");

	    switch( ( lkb_pid = fork() ) )
	    {
		case -1:
		fprintf(stderr,"Can not fork the logical keyboard\n");
		LOGKBD = 0;
		break;
		 
		case 0:
		sts = execlp(pathname,"igejlk",(char *)NULL);
		if( sts == -1 )
		{
                char error_string[1000];

		   sprintf (error_string,"Can not execute logical keyboard");
                   Report_fatal_error (error_string);
		}
		
/*
		default:
		printf("Logical keyboard PID = %d\n",lkb_pid);
		break;
*/		 
	    }

  	    /*
 	     * Open the pipes
 	     */
	
	    m_to_kb = open("/usr/tmp/KBNP1", ( O_WRONLY | O_TRUNC ) );
	    if( m_to_kb == (int) NULL )
	    {
		perror("/usr/tmp/KBNP1");
		LOGKBD = 0;
		return(0);
	    }

	    kb_to_m = open("/usr/tmp/KBNP2", ( O_RDONLY ) );
	    if( kb_to_m == (int) NULL )
	    {
		perror("/usr/tmp/KBNP2");
		close(m_to_kb);
		LOGKBD = 0;
		return(0);
	    }
	
	    /*
	     * First send to get pid of keyboard - should have a time out
	     */

	 
	    while(1)
	    {
		com_data.message = REQ_FOR_PID;
		com_data.no_bytes = 0;

		/* sml:04-29-92	cast 2nd arg to (void *) and 3rd arg to
			size_t in write and read 
	 	 */
		write(m_to_kb,(void *)(&com_data),(size_t) sizeof(com_data));
		 
		read(kb_to_m,(void *)(&com_data),(size_t) sizeof(com_data));
		if(com_data.message!=RET_PID)
		{
			printf("MAIN: rec'd wrong message from LK\n");
			printf("MAIN: waiting for RET_PID\n\n");
		}
		else
		{
			break;
		}
	    }
	 
	    lkb_pid = com_data.data.int_data;
	 
        /*
	    printf("MAIN: got pid = %d\n\n",lkb_pid);
        */
      	 }
      }
   }

  line_ptr = old_line_ptr;

  return(0);
}
