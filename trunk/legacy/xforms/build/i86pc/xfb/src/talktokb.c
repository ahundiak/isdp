/***********************************

		talktokb.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
						added POSIX changes one more time
*/

/*** Japan ***/
 
#include "signal.h"
#include "commdefs.h"

/* include for POSIX read/write */
#include "sys/types.h"
#include "unistd.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"


/* sml;04-29-92	change from int to pid_t for POSIX */
extern pid_t  lkb_pid;
extern int  m_to_kb,kb_to_m;

talk_to_kb(char *character,
           int  *count)
{
	int i;
	/* dmb:08/29/92: ifdef around for now */
	/* sml:04-29-92	change from int to ssize_t for POSIX read() */
#if defined(build_posix)
	ssize_t no_read;
#else
	size_t no_read;
#endif

	

	int	sts;

        char key_buf[256];
	struct
	{
	    	int	message;
	    	int	no_bytes;
		union
		{
			unsigned char ch_data[1024];
			int	      int_data;
		} data;
	
	}com_data;

        key_buf[0] = character[0];
    	character[0] = 0;
    	 
    	for ( i = 0; i < *count; i++ )
    	{
    		com_data.message = KYBD_INPUT;
    		com_data.no_bytes = 1;
    		com_data.data.ch_data[0] = key_buf[i];
		com_data.data.ch_data[1] = 0;
    		 
			/* sml:04-29-92	cast 2nd and 3rd args for POSIX write() */
    		write (m_to_kb,(void *)(&com_data), (size_t) sizeof(com_data));
    		 
    		sts = kill(lkb_pid,SIGUSR1);
    		 
			/* sml:04-29-92	cast 2nd and 3rd args for POSIX read() */
    		no_read = read(kb_to_m,(void *)(&com_data), (size_t) sizeof(com_data));
    		 
    		if( (no_read > 0 ) && ( com_data.no_bytes > 0 ) )
    		{
    			strcat(character, (char *) (com_data.data.ch_data));
    		}
    	}
	*count = strlen(character);
}
