#include "machine.h"
#include "INIT.h"

       char EXECPATH [132] ;
       MSGptr NFMRmsg_ptr = {0, "/dev/console", 0, ""};

nfm_enter (server, environment, username, password, exec_path)
char *server, *environment, *username, *password ;
char *exec_path ;

{
  static char *fname = "nfm_enter" ;
  int    status;
  char   msg [256] ;
    _NFMdebug ((fname, "<%s>", "nfm_enter"));

    strcpy (EXECPATH, exec_path) ;

    /* see if NFM has already been initialized */

    status = nfm_init ();
    if (status != NFM_S_SUCCESS)
        {
        /* may be failure or cancel - return FAILURE to screen controller */
	  _NFMdebug ((fname, "nfm_init failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRget_message (msg) ;
	  SCdisplay_msg (msg) ;
 	  return (NFI_E_FAILURE); 
        }

/* Faliure in order to exit of Screen Controller */

    ERRload_struct (NFI, NFI_S_SUCCESS, "", "") ;
    return (NFI_E_FAILURE) ;
}


nfm_exit ()

{
  static char *fname = "nfm_exit" ;

    _NFMdebug ((fname, "NFMSexit : <%s>", "nfm_exit"));

    return (NFM_S_SUCCESS);
}
