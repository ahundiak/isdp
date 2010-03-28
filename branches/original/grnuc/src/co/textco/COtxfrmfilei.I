/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     CLASS NAME   COtxfrmfile

     METHOD NAMES COwakeup
                  COexecute

     Abstract:    This method will prompt the user to keyin the name
               of the file that contains the text that is to be placed
               on the softwate queue.
-----
%SC%
             COtxfrmfile_COwakeup_method (IGRint pos)

             COtxfrmfile_COexecute_method (IGRint *response;
                                           IGRchar *response_data;
                                           IGRint pos)
-----
%EN%
 
     ON ENTRY:

        NAME        DATA TYPE              DESCRIPTION
     ----------    ------------   -----------------------------------
     response      IGRint         
     response_data IGRchar
     pos           IGRint
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *message       IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:    

     Methods:

-----
%RL%

     RELATIONS REFERENCED:

-----
%UI%

     USER INTERFACE DESCRIPTION:

-----
%NB%

     NOTES:  

-----
%CH%
     CHANGE HISTORY:
        
        WBC  03/09/88 : Design date.
        WBC  03/09/88 : Creation date.
	jjm   3/10/93 : added pre_wakeup method and some instance data
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This command object is an input generator that reads text from a
file and places it on the software queue.
----*/
/*EH*/

class implementation COtxfrmfile;

#include "coimport.h"
%safe
#include <sys/types.h>
#include <sys/stat.h>
%endsafe
#include <errno.h>
#include <fcntl.h>
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grmessage.h"
#include "exmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "exdef.h"
#include "execmsg.h"

/*---------------------------------------------------------------*/
/*                       method  pre_wakeup                      */
/*---------------------------------------------------------------*/

method pre_wakeup(int (*dyn_function)();char *additional_info)
{
   me->flag = 0;

   /* check if the Place Text command or Edit Text command */
   /* is on the stack immediately before us                */
   /*                                                      */
   /* Place Text and Edit Text pass us info via the        */
   /* additional_info parameter.  This is done in their    */
   /* pre_sleep method.                                    */

   if (additional_info)
   {
      if (strncmp(additional_info,"Place Text",10))
         if (strncmp(additional_info,"Edit Text",9))
            me->flag = 1;
   }
   else me->flag = 1;

}

/*---------------------------------------------------------------*/
/*                       method COwakeup                         */
/*---------------------------------------------------------------*/

method wakeup (IGRint pos)
{
   ex$message(field = PROMPT_FIELD,
              in_buff = "");
   ex$message(field = ERROR_FIELD,
              in_buff = "");
   ex$message(msgnumb = GRC_M_TxFrmFile);
   return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method COexecute                        */
/*---------------------------------------------------------------*/

method execute ( IGRint *response;
                 IGRchar *response_data;
                 IGRint pos )
{
    struct GRevent    event;         /* event from co$getevent        */
    struct stat       stbuf;         /* info about the specified file */
    IGRlong           temp_msg, status, msgkey, nbytes;
    IGRint            exit, fd;
    IGRchar           text_buffer[EX_RESPONSE_DATA_SIZE];


    if (me->flag)
    {
       /* neither Place Text nor Edit Text are on the stack, so  */
       /* first put Place Text, then Select Text From ASCII File */
       /* on the queue.  On the way out, terminate ourselves.    */
      
       long msg, size;
       int resp;

       resp = EX_CMD_KEY;
       size = 13;
       ex$putque( msg = &msg, response = &resp, byte = &size, 
		  buffer = "GRSlTxFrAS");

       resp = EX_CMD_KEY;
       size = 10;
       ex$putque( msg = &msg, response = &resp, byte = &size, 
		  buffer = "GRPTx");

       *response = TERMINATE;
       return (OM_S_SUCCESS);
    }


    exit = FALSE;

    do
    {
        co$getevent(msg = &temp_msg,
                    event_mask = GRm_STRING | GRm_RESET,
                    msgnum = EX_P_InputFileName,
                    response = response,
                    response_data = response_data,
                    event = &event);

        switch(event.response)
        {
            case RESET:

                ex$message(field = ERROR_FIELD,
                           in_buff = "");
                break;

            case STRING:

                /*
                 * check to see if the specified file both exists and we
                 * have read permission
                 */

                if (stat(response_data,&stbuf) == -1)
                {
                    /*
                     * the specified file could not be accessed; display a
                     * message explaining the error
                     */

                    switch (errno)
                    {
                        case ENOENT:

                            /*
                             * the named file does not exist
                             */

                            msgkey = GR_E_FlNotFnd;

                            break;

                        case ENOTDIR:

                            /*
                             * a component of the path prefix is not a
                             * directory
                             */

                            msgkey = EX_S_NotDir;

                            break;

                        case EACCES:

                            /*
                             * search permission is denied for a component of
                             * the path prefix
                             */

                            msgkey = EX_S_Access;

                            break;

                        default:

                            msgkey = GR_E_CantReadFile;

                            break;
                    }  /* end switch (errno) */

                    ex$message(msgnumb = msgkey);
                }
                else
                {
                    /*
                     * only read ordinary (text) files (i.e. don't want to
                     * read directory or special files)
                     */

                    if ((stbuf.st_mode & S_IFMT) != S_IFREG)
                    {
                        ex$message(msgnumb = GR_E_NotTxFile);
                    }
                    else   /* ordinary file */
                    {
                        if ((fd = open(response_data,O_RDONLY)) == -1)
                        {
                            ex$message(msgnumb = GR_E_FlCantOpn);
                        }
                        else  /* successfully opened the file for reading */
                        {
                            /*
                             *  read the specified file and put its contents
                             *  on the software queue; a maximum of
                             *  EX_RESPONSE_DATA_SIZE bytes may be put on the
                             *  software queue per event
                             */

                            *response = STRING;

                            while ((nbytes = read(fd,text_buffer,
                                                  EX_RESPONSE_DATA_SIZE - 1)) > 0)
                            {
                                /*
                                 *  string placed on the software queue must
                                 *  be NULL terminated
                                 */

                                text_buffer[nbytes] = '\0';
                                ++nbytes;

                                status = ex$putque(msg = &temp_msg,
                                                   pos = BACK,
                                                   response = response,
                                                   byte = &nbytes,
                                                   buffer = text_buffer);

                                if (!(status & temp_msg & 1))
                                {
                                    exit = TRUE;
                                    break;
                                }
                            }
                            exit = TRUE;
                            *response = TERMINATE;
                            close(fd);
                        }
                    }
                }
                break;

            case GR_UNKNOWN_TYPE:

                break;

            default:

                printf("Unknown response type\n");
                break;

        }  /* end switch */
    } while ((!exit) && (event.response != GR_UNKNOWN_TYPE));

    return(OM_S_SUCCESS);
}

end implementation COtxfrmfile;
