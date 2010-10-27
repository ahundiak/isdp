/* $Id: VDXsignal.C,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXsignal.C
 *
 * Description:
 *		Support function for extract for review command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXsignal.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.2  1999/06/02  12:22:20  pinnacle
 * ah
 *
 * Revision 1.1  1999/04/19  13:58:34  pinnacle
 * for dynapipe
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *
 ***************************************************************************/


#include <stdio.h>  
#include <signal.h>
#include <UMS.h>
#include <FI.h>

#include "igrtypedef.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"

#include "VDXmsg.h"
#include "VDXstructs.h"
#include "VDX4struct.h"

/***  VDX4DYN.u global variables  ***/
VDXglobals		VDXform_info;
VDXreference_files	*VDXref_files;


/***  VDXcre_dgn.u global variables  ***/

MYFILE			*VDXdrv_outfile,
			*VDXdri_outfile,
			*VDXdst_outfile;
FILE			*VDXlog_file;
IGRlong			 VDXIGDS_filedesc;
struct GUcvt_bufs	 VDXcvt_buffers;
IGRchar			*VDXptr;
struct GRid		*VDXgr_grp;
struct GRid		*VDXcopies;


/* Signal Handler function pointers to be used to re
   store previous Signal
   Handlers.  Extract for review will override I/VDS signals when invoked. and 
   restore them upon exit.                                               */ 


void (*VDXold_handler1) ();
void (*VDXold_handler2) ();
void (*VDXold_handler3) ();
void (*VDXold_handler4) ();
void (*VDXold_handler5) ();
void (*VDXold_handler6) ();
void (*VDXold_handler7) ();
void (*VDXold_handler8) ();
void (*VDXold_handler9) ();


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++ VDXsignal_handler */
/* Called to cleanup after a signal.
*/
void  VDXsignal_handler(int sig)
{
  static char	fun_name[] = { "VDXsignal_handler" };
  char		*signal_str;
  int		status;
  char          msg_buf[256];  

  extern        exit ();
  extern        char *VDXget_signal_string();
  extern        void VDXrestore_signals ();
  extern        int VDXsig_cleanup ();

  signal_str = VDXget_signal_string ( sig );
  status = UMSGetByNum (msg_buf, VDX_F_SigTrap1, "%s%s", fun_name,
                        signal_str);
  if (status != UMS_S_SUCCESS)
   {
      sprintf (msg_buf, "FATAL (%s): Signal trapped: %s", 
               fun_name, signal_str);
   }

  printf ("%s\n", msg_buf);

  VDXsig_cleanup ();

  /*** Restore the I/VDS signals ***/

  VDXrestore_signals ();
}


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++ VDXget_signal_string */
/* This function returns the string associated with a signal.
*/
char *VDXget_signal_string ( sig )
  int	sig;
{
  char	*cp;

  switch ( sig ) {
    case SIGHUP:
	cp = "hangup";
	break;
    case SIGINT:
	cp = "interrupt";
	break;
    case SIGQUIT:
	cp = "quit";
	break;
    case SIGILL:
	cp = "illegal instruction";
	break;
    case SIGTRAP:
	cp = "trace trap";
	break;
    case SIGIOT:
	cp = "IOT instruction or abort";
	break;
    case SIGEMT:
	cp = "EMT instruction";
	break;
    case SIGFPE:
	cp = "floating point exception";
	break;
    case SIGKILL:
	cp = "kill";
	break;
    case SIGBUS:
	cp = "bus error";
	break;
    case SIGSEGV:
	cp = "segmentation violation";
	break;
    case SIGSYS:
	cp = "bad argument to system call";
	break;
    case SIGPIPE:
	cp = "write on a pipe with no one to read it";
	break;
    case SIGALRM:
	cp = "alarm clock";
	break;
    case SIGTERM:
	cp = "software termination signal";
	break;
    case SIGUSR1:
	cp = "user-defined signal 1";
	break;
    case SIGUSR2:
	cp = "user-defined signal 2";
	break;
    case SIGCLD:
	cp = "death of a child";
	break;
    case SIGPWR:
	cp = "power fail";
	break;
    default:
	cp = "unknown signal";
	break;
  }

  return ( cp );
}


void VDXsetup_signals (void)
 {

  VDXref_files = NULL;
  VDXform_info.productionFlag = FALSE ;
  VDXform_info.ref_count = 0;
  VDXform_info.cur_ref_idx = 0;
  VDXform_info.cur_ref_level = 0;
  VDXform_info.main_form_exists = FALSE;
  VDXform_info.ref_form_exists = FALSE;
  VDXform_info.main_form_displayed = FALSE;
  VDXform_info.ref_form_displayed = FALSE;

  VDXdrv_outfile = NULL;
  VDXdri_outfile = NULL;
  VDXdst_outfile = NULL;
  VDXlog_file    = NULL;
  VDXIGDS_filedesc  = -1;
  VDXptr         = NULL;
  VDXcopies      = NULL;
  VDXgr_grp      = NULL;

  VDXold_handler1 = signal ( SIGINT,  VDXsignal_handler );
  if (VDXold_handler1 == SIG_ERR)
     printf ("Internal: Cannot Establish new signal handler for SIGINT.\n");

  VDXold_handler2 = signal ( SIGQUIT, VDXsignal_handler );
  if (VDXold_handler2 == SIG_ERR)
     printf ("Internal: Cannot Establish new signal handler for SIGQUIT.\n");

  VDXold_handler3 = signal ( SIGILL,  VDXsignal_handler );
  if (VDXold_handler3 == SIG_ERR)
     printf ("Internal: Cannot Establish new signal handler for SIGILL.\n");

  VDXold_handler4 = signal ( SIGFPE,  VDXsignal_handler );
  if (VDXold_handler4 == SIG_ERR)
     printf ("Internal: Cannot Establish new signal handler for SIGFPE.\n");

  VDXold_handler5 = signal ( SIGBUS,  VDXsignal_handler );
  if (VDXold_handler5 == SIG_ERR)
     printf ("Internal: Cannot Establish new signal handler for SIGBUS.\n");

  VDXold_handler6 = signal ( SIGSYS,  VDXsignal_handler );
  if (VDXold_handler6 == SIG_ERR)
     printf ("Internal: Cannot Establish new signal handler for SIGSYS.\n");

  VDXold_handler7 = signal ( SIGTERM, VDXsignal_handler );
  if (VDXold_handler7 == SIG_ERR)
     printf ("Internal: Cannot Establish new signal handler for SIGTERM.\n");

  VDXold_handler8 = signal ( SIGIOT,  VDXsignal_handler );
  if (VDXold_handler8 == SIG_ERR)
     printf ("Internal: Cannot Establish new signal handler for SIGIOT.\n");

  VDXold_handler9 = signal ( SIGEMT,  VDXsignal_handler );
  if (VDXold_handler9 == SIG_ERR)
     printf ("Internal: Cannot Establish new signal handler for SIGEMT.\n");

  return;
}



void VDXrestore_signals (void)
 {
  if (VDXold_handler1 != SIG_ERR)
     if (signal ( SIGINT,  VDXold_handler1 ) == SIG_ERR)
        printf ("Internal: Cannot restore old signal handler for SIGINT.\n");

  if (VDXold_handler2 != SIG_ERR)
     if (signal ( SIGQUIT,  VDXold_handler2 ) == SIG_ERR)
        printf ("Internal: Cannot restore old signal handler for SIGQUIT.\n");

  if (VDXold_handler3 != SIG_ERR)
     if (signal ( SIGILL,  VDXold_handler3 ) == SIG_ERR)
        printf ("Internal: Cannot restore old signal handler for SIGILL.\n");

  if (VDXold_handler4 != SIG_ERR)
     if (signal ( SIGFPE,  VDXold_handler4 ) == SIG_ERR)
        printf ("Internal: Cannot restore old signal handler for SIGFPE.\n");

  if (VDXold_handler5 != SIG_ERR)
     if (signal ( SIGBUS,  VDXold_handler5 ) == SIG_ERR)
        printf ("Internal: Cannot restore old signal handler for SIGBUS.\n");

  if (VDXold_handler6 != SIG_ERR)
     if (signal ( SIGSYS,  VDXold_handler6 ) == SIG_ERR)
        printf ("Internal: Cannot restore old signal handler for SIGSYS.\n");

  if (VDXold_handler6 == SIG_ERR)
     printf ("Internal: Cannot Establish new signal handler for SIGSYS.\n");

  if (VDXold_handler7 != SIG_ERR)
     if (signal ( SIGTERM,  VDXold_handler7 ) == SIG_ERR)
        printf ("Internal: Cannot restore old signal handler for SIGTERM.\n");

  if (VDXold_handler8 != SIG_ERR)
     if (signal ( SIGIOT,  VDXold_handler8 ) == SIG_ERR)
        printf ("Internal: Cannot restore old signal handler for SIGIOT.\n");

  if (VDXold_handler9 != SIG_ERR)
     if (signal ( SIGEMT,  VDXold_handler9 ) == SIG_ERR)
        printf ("Internal: Cannot restore old signal handler for SIGEMT.\n");

  return;
}


int VDXsig_cleanup ()
 {
    int j;

    if (VDXref_files != NULL)
     {
        for (j = VDXform_info.ref_count - 1; j > 0; j = j - 1)
           free (VDXref_files[j]);
        free (VDXref_files);
     }
    VDXref_files = NULL;
    VDXform_info.productionFlag = FALSE ;
    VDXform_info.cur_ref_idx = 0;
    VDXform_info.ref_count = 0;
    VDXform_info.cur_ref_level = 0;

    if (VDXform_info.ref_form_exists == TRUE)
     {
        FIf_delete (VDXform_info.ref_form);
        VDXform_info.ref_form_exists = FALSE;
        VDXform_info.ref_form_displayed = FALSE;
     }

    if (VDXform_info.main_form_exists == TRUE)
     {
        FIf_delete (VDXform_info.main_form);
        VDXform_info.main_form_exists = FALSE;
        VDXform_info.main_form_displayed = FALSE;
     }

    /**  Close all open files **/

    printf ("close VDXlog_file\n");
    if (VDXlog_file != NULL)
       fclose (VDXlog_file);
    VDXlog_file = NULL;

    printf ("close VDXdrv_outfile\n");
    if (VDXdrv_outfile != NULL)
       fclose ((FILE *) VDXdrv_outfile);
    VDXdrv_outfile = NULL;

    printf ("close cvt_buffers.file_des\n");
    if (VDXcvt_buffers.file_des != -1)
       close (VDXcvt_buffers.file_des);
    VDXcvt_buffers.file_des = -1;

    printf ("close IGDS_filedesc\n");
    if (VDXIGDS_filedesc != -1)
       close (VDXIGDS_filedesc);
    VDXIGDS_filedesc = -1;

    printf ("close VDXdri_outfile\n");
    if (VDXdri_outfile != NULL)
       fclose ((FILE *) VDXdri_outfile);
    VDXdri_outfile = NULL;

    printf ("close VDXdst_outfile\n");
    if (VDXdst_outfile != NULL)
       fclose ((FILE *) VDXdst_outfile);
    VDXdst_outfile = NULL;

    /**  Free up all global allocated memory **/

    printf ("free up memory for VDXptr\n");
    if (VDXptr != NULL)
     {
        free (VDXptr);
        VDXptr = NULL;
     }
    printf ("free up memory for VDXgr_grp\n");
    if (VDXgr_grp != NULL)
     {
        free (VDXgr_grp);
        VDXgr_grp = NULL;
     }
    printf ("free up memory for VDXcopies\n");
    if (VDXcopies != NULL)
     {
        free (VDXcopies);
        VDXcopies = NULL;
     }

    return (0);
}
