#include <stdio.h>
#include <varargs.h>
#include "PDUerror.h"
#include "PDMmach_id.h"
#include "MEMstruct.h"
#include "PDMdebug.h"
#include "MSGstruct.h"
#include "NETstruct.h"
/* added to accomodate NFM2.2 debug style */
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "NFMsacdef.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"

extern MSGptr NFMmsg_ptr;
extern char *getenv();
/* APOGEE START static 	char s[1024]; APOGEE END */


/* Added to support to put the debugs by the envirnment variable PDMDEBUG 
   Kumar */


/* Added to support to put the debugs by the envirnment variable PDMDEBUG */
extern PDMexec_ptr PDMexec;

int PDMdebug_on_off ()
  {
	extern	struct msg_struct NFMmsg_ptr;
	extern	struct msg_struct MEMmsg_ptr;
	extern	struct NETuser_struct NETusr_info;
	int toggles[NFM_DEBUG_SUBSYSTEMS];
        char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];
        char  *debug_path;
	MEMptr list;


          PDM_DEBUG_FILE[0] = '\0';

	PDMdebug_on = PDMexec->operation;
        /*
	NFMmsg_ptr.debug_on = PDMexec->operation;
	MEMmsg_ptr.debug_on = PDMexec->operation;  
	sprintf (PDM_DEBUG_FILE, "%s%s%s",  "/usr/tmp", DELIM, "pdm.dbg");
	sprintf (NFMmsg_ptr.debug_file, "%s%s%s", "/usr/tmp", DELIM, "nfm.dbg");
	sprintf (MEMmsg_ptr.debug_file, "%s%s%s", "/usr/tmp", DELIM, "mem.dbg");
        */

    /* added to get time stamps */
    /*
        sprintf (PDM_TIME, "%s%s%s", "/usr/tmp", DELIM, "time.Dbg");
    */

/*  modified for NFM2.2 ..END */
	toggles [6] = PDMexec->operation;    /*NET deb on */
	toggles [8] = PDMexec->operation;    /*NFM deb on */
	toggles [9] = PDMexec->operation;    /*SQL deb on */
	toggles [11] = PDMexec->operation;   /*MEMS deb on */
	toggles [14] = PDMexec->operation;   /*ERRS deb on */
	toggles [3] = PDMexec->operation;    /*NET deb on */


         debug_path = getenv( "PDMDEBUG" );
        if(debug_path != NULL && strcmp(debug_path,""))
         {
	sprintf (PDM_DEBUG_FILE, "%s%s%s",debug_path,DELIM,"pdm.dbg");
	sprintf (files[8], "%s%s%s",debug_path,DELIM,"nfm.dbg");
	sprintf (files[11], "%s%s%s",debug_path,DELIM,"mem.dbg");
	sprintf (files[6], "%s%s%s",debug_path,DELIM,"net.dbg");
	sprintf (files[9], "%s%s%s",debug_path,DELIM,"nfm.dbg");
	sprintf (files[14], "%s%s%s",debug_path,DELIM,"err.dbg");
	sprintf (files[3], "%s%s%s",debug_path,DELIM,"netc.dbg");
         }
        else
         {
	sprintf (PDM_DEBUG_FILE, "%s%s%s","/usr/tmp",DELIM,"pdm.dbg");
	sprintf (files[8], "%s%s%s","/usr/tmp",DELIM,"nfm.dbg");
	sprintf (files[11], "%s%s%s","/usr/tmp",DELIM,"mem.dbg");
	sprintf (files[6], "%s%s%s","/usr/tmp",DELIM,"net.dbg");
	sprintf (files[9], "%s%s%s","/usr/tmp",DELIM,"nfm.dbg");
	sprintf (files[14], "%s%s%s","/usr/tmp",DELIM,"err.dbg");
	sprintf (files[3], "%s%s%s","/usr/tmp",DELIM,"netc.dbg");
         }
      if(debug_path) free (debug_path);
    NFMall_debug (toggles, files);

    MEMopen (&list, 1000);
    MEMclose (&list);
	return (PDM_S_SUCCESS);
  }


int PDMdebug (s)
  char	s[300];
  {
	FILE	*outfile, *fopen();

	if (PDMdebug_on)
	  {
		if ((strcmp (PDM_DEBUG_FILE, "")) != 0)
		  {
			if ((outfile = fopen (PDM_DEBUG_FILE, "a")) == NULL)
				return (PDM_E_OPEN_FILE);
			fputs (s, outfile);
			fclose (outfile);
		  }
		else
		  {
			fputs (s, stdout);
		  }
	  }

	return (PDM_S_SUCCESS);
  }


/*********
	Additional functions to time the product 
	in the code.
		- Arun
			***********/

_PDMdebug( va_alist)
va_dcl
  /*  arguments to send to vfprintf ()  */
  {
    FILE       *outfile, *fopen ();
    char        *fname;   /*  Name of calling function          */
    char        *format; /*    printf () format specification    */
    short      do_not_close;
    va_list    args;

    if (!PDMdebug_on) return;

    /*  Open the debug file  */

    if ((strcmp (PDM_DEBUG_FILE, "")) == 0)
      {
        /*  Default to stderr  */

        outfile = stderr;

        do_not_close = 1;
      }
    else
      {
        if ((outfile = fopen (PDM_DEBUG_FILE, "a")) == NULL)
                                return ;
        do_not_close = 0;
      }

    /*  Print out the name of the calling function  */

    va_start (args);

    fname = va_arg (args, char *);
    /*  Print out the remainder of the message  */
    format = va_arg (args, char *);
    fprintf (outfile, "%s: ", fname);
    vfprintf (outfile, format, args);

    va_end (args);

    /*  Close the file  */

    if (do_not_close == 0)
        fclose (outfile);

    return;
  }

