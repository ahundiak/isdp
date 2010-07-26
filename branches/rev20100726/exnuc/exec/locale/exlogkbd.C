#include "exsysdep.h"
#include <stdio.h>
#include <fcntl.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <exlocale.h>
#include <exlocaledef.h>
#include <exmacros.h>

extern int EX_kbd_wrt;
extern int EX_kbd_rd;
extern int EX_logkbd;


int EX_create_logical_keyboard()
{
#ifndef NT
    char np1[30]; 
    char np2[30];
    char npp1[30]; 
    char npp2[30];

    static IGRint EXpipes_active = 1;
    IGRlong  msg;
    IGRint   which_error;
    struct EX_locale_var var_list[2];
    IGRint   kbd_pid;
    IGRchar  kbd_name[80];
    IGRchar  *argu[3];
    extern IGRchar  *getenv();
    IGRint   kbd_for_read;
    IGRint   kbd_for_write;
    struct EX_logkbd_buf buffer;

    strcpy(np1, "KBDNP1=/usr/tmp/KBDNP1");        
    strcpy(np2, "KBDNP2=/usr/tmp/KBDNP2");
    strcpy(npp1, "/usr/tmp/KBDNP1");        
    strcpy(npp2, "/usr/tmp/KBDNP2");

    /* get pid of logical keyboard if available,  also
       get the logical keyboard name in case it has to be
       created
    */

    var_list[0].var = EX_Kbd_Pid;
    var_list[0].var_ptr = &kbd_pid;

    var_list[1].var = EX_Kbd_Name;
    var_list[1].var_ptr = kbd_name;

    ex$inq_locale (msg = &msg, 
                   count = 2, 
                   which_error = &which_error, 
                   var = var_list,
                   flags = EX_Text);


    if (msg == EX_Success) {
        if (!kbd_pid) {



            argu[0] = kbd_name;
            argu[1] = (char *) NULL;

            ex$fork (num_entry = 1, 
                      argu = argu, 
                      childpid = &kbd_pid, 
                      redir_io = CREATE_PIPE,
                      np1 = np1, 
                      np2 = np2);

            EX_logkbd = kbd_pid;

            var_list[0].var = EX_Kbd_Pid;
            var_list[0].var_ptr = (struct EX_fonts *) &kbd_pid;

	    ex$set_locale (msg = &msg, 
	                   which_error = &which_error, 
	                   var = var_list);
        }

        if (EXpipes_active == 1) {
	    EXpipes_active = 0;


	    kbd_for_write = open (npp1, O_WRONLY | O_TRUNC);

            EX_kbd_wrt = kbd_for_write;




	    kbd_for_read = open (npp2, O_RDONLY);
            EX_kbd_rd = kbd_for_read;
  	    /* Store pipe ids in locale */

            var_list[0].var = EX_Kbd_Read_Pipe;
            var_list[0].var_ptr = (struct EX_fonts *) &kbd_for_read;

            var_list[1].var = EX_Kbd_Write_Pipe;
            var_list[1].var_ptr = (struct EX_fonts *) &kbd_for_write;

	    ex$set_locale (msg = &msg, 
	                   count = 2, 
	                   which_error = &which_error, 
	                   var = var_list);

        /*  Request the logical keyboard for the process id.
            This also implies the log. kbd will connect to the
            named pipes, NAMEDPIPE1 and NAMEDPIPE2 */

            buffer.rc = 1;
            buffer.nbytes = 0;

            write (kbd_for_write, &buffer, sizeof (struct EX_logkbd_buf));
            read (kbd_for_read, &buffer, sizeof (struct EX_logkbd_buf));

            if (buffer.data.int_data != kbd_pid) {
                printf ("Error in pid of log. kbd \n");
            }
	}
    }
    else {
	printf ("ex$inq_locale failed \n");
    }

#endif
  return 1;
}

int EX_syserror(msg)
char *msg;
{
	extern int errno,sys_nerr;
	extern char *sys_errlist[];
	 
	fprintf(stderr,"ERROR : %s : %d\n",msg,errno);
	if(errno>0 && errno<sys_nerr){
		fprintf(stderr,"%s\n",sys_errlist[errno]);
	}

        return 1;
}
