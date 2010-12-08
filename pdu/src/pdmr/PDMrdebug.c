#include <stdio.h>
#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "PDUintdef.h"
#include "MSGstruct.h"
#include <PDMmessage.h>
#include "DEBUG.h"
#include "MEMstruct.h"
#include "FI.h"

extern int PDU_connection;
extern int PDU_login;
extern Form PDU_form_id;
extern int PDM_debug_on;
extern int PDMdebug_on;

FILE 	*NFMdbg_ptr;      /* In RPS.a externed to assign 
			     the file pointer when writing 
			     debug to a file/device */

int PDUdebug_on_off (flag)
  int	flag;
  {
  int   display;

        extern short PDU_perm_window;
        int    status = PDM_S_SUCCESS;
        int toggles[NFM_DEBUG_SUBSYSTEMS];
        char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];

     _pdm_debug("in the function PDUdebug_on_off", 0);

     /* added on 6/26/91 to accomodate NFM2.2 style debug */

	/* declared in PDMrreports.c
	   to be used in RPS.a during debug */

	/*extern	struct msg_struct NFMmsg_ptr;*/


	/*  Set NET and MEM debug output to go to the console  */

                _NFMdebug_st.NFMdebug_on =1 ;
                _NFMdebug_st.SQLdebug_on =1 ;
                _NFMdebug_st.NETSdebug_on =1 ;
                _NFMdebug_st.NETCdebug_on =1 ;
                _NFMdebug_st.UTIdebug_on =1 ;
                strcpy(_NFMdebug_st.NETSdebug_file, "/usr/tmp/netserver.dbg") ;
                strcpy(_NFMdebug_st.NFMdebug_file, "/usr/tmp/nfm.dbg") ;
                strcpy(_NFMdebug_st.SQLdebug_file, "/usr/tmp/nfm.dbg") ;
                strcpy(_NFMdebug_st.NETCdebug_file, "/usr/tmp/netclient.dbg") ;
                strcpy(_NFMdebug_st.UTIdebug_file, "/usr/tmp/utility.dbg") ;
               /* strcpy(_NFMdebug_st.MEMdebug_file, "/dev/console") ; */


      /* added to accomodate NFM2.2 style debug : Start */
        toggles [3] = flag;    /*NETC deb on */
      /* set all other toggles to FALSE 
        toggles[1] = FALSE;
        toggles[2] = FALSE;
        toggles[4] = FALSE;
        toggles[5] = FALSE;
        toggles[6] = FALSE;
        toggles[7] = FALSE;
        toggles[8] = FALSE;
        toggles[9] = FALSE;
        toggles[10] = FALSE;
        toggles[11] = FALSE;
        toggles[12] = FALSE;
        toggles[13] = FALSE;
        toggles[14] = FALSE; */
/*
toggles [6] = PDMexec->operation;    
        toggles [8] = PDMexec->operation;    
        toggles [9] = PDMexec->operation;   
        toggles [11] = PDMexec->operation; 
        toggles [14] = PDMexec->operation;
        toggles [3] = PDMexec->operation;

        sprintf (PDM_DEBUG_FILE, "%s%s%s","/usr/tmp",DELIM,"pdm.dbg");
        sprintf (files[8], "%s%s%s","/usr/tmp",DELIM,"nfm.dbg");
        sprintf (files[11], "%s%s%s","/usr/tmp",DELIM,"mem.dbg");
        sprintf (files[6], "%s%s%s","/usr/tmp",DELIM,"net.dbg");
        sprintf (files[9], "%s%s%s","/usr/tmp",DELIM,"nfm.dbg");
        sprintf (files[14], "%s%s%s","/usr/tmp",DELIM,"err.dbg");
        sprintf (files[3], "%s%s%s","/usr/tmp",DELIM,"netc.dbg");
        sprintf (files[3], "%s", "/dev/console");

*/
       
        /*NFMall_debug (toggles, files); */
      
      /* added to accomodate NFM2.2 style debug : END */

	/*  Toggle the local flag, send debug to stdout  */

	PDMdebug_on = flag;
	PDM_debug_on = flag;

        /* Display Message */
        PDUmessage(PDS_M_DEBUG_ON_OFF, 's');

	  PDUload_exec_structure("","", "", "", "","","",flag, 0);
  
	  _pdm_debug("calling PDMdebug_on_off", 0);
	  PDMdebug_on_off();
          _pdm_debug("PDMdebug_on_off", status);
  
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return(status);
            }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("PDUdebug_on_off: returning SUCCESS", 0);
	return (status);
  }
