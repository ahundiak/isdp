#include <stdio.h>

#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDMmessage.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "PDMproto.h"

static  char 	s[1024];
extern	PDUsts_ptr 	PDUsts;
extern	int 	PDMdebug_on;


/*
	n_cofilename is an optional input 
    if provided the checked out part wil have this 
	name on the WS. The user is  expected to provide 
	the same name while checking in this part later.
	n_cofilename is set to NULL if the user prefers
	the server name for the checked out file

	storage_buffer can be NULL
	If the server knows the storage areas for the 
	part being checked out
*/

int PDMrcheckout_part (
                      catalog, 
		      n_itemname,
		      n_itemrev,
		      n_cofilename,
                      files_bufr,
                      attach_info_bufr
                     )
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  char		*n_cofilename;
  MEMptr        *files_bufr;
  MEMptr        *attach_info_bufr;
  {
	MEMptr		file_bufr = NULL;
	long		status = PDM_S_SUCCESS; /* PDM_S_SUCCESS APOGEE */
/*
        long           ci_enter;
        long           ci_exit;
        long           ci_inter;
        long           call_time();
        double           d_enter;
        double           d_exit;
        double           d_inter;
        double           system_time();
*/

        /* mark entry time */
/*
         ci_enter = ci_inter =  call_time();
         d_enter = d_inter =  system_time();
*/

	sprintf (s, "PDMrcheckout_part: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMrcheckout_part: n_itemname = <%s>\n", n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "PDMrcheckout_part: n_itemrev = <%s>\n", n_itemrev);
	_pdm_debug(s, 0);
	sprintf (s, "PDMrcheckout_part: n_cofilename = <%s>\n", n_cofilename);
	_pdm_debug(s, 0);

    PDUsts->MEMstatus = MEMopen(&file_bufr,512);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
    {
		sprintf(s,"%s %s %d\n",
		"PDMrcheckout_part: MEMopen ",
		"Failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		return(PDM_E_OPEN_BUFFER);
	}
	PDUsts->MEMstatus = MEMwrite_format
					(file_bufr,"n_cofilename","char(30)");
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&file_bufr);
		sprintf(s,"%s %s %d\n",
		"PDMrcheckout_part: MEMwrite_format ",
		"Failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		return(PDM_E_WRITE_FORMAT);
	}
	if(n_cofilename == NULL || !strcmp(n_cofilename,""))
	{
		s[0] = '\0';
		sprintf(s,"%s\1","");
    }
	else
	{
		s[0] = '\0';
		sprintf(s,"%s\1",n_cofilename);
    }
	PDUsts->MEMstatus = MEMwrite(file_bufr,s);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&file_bufr);
		sprintf(s,"%s %s %d\n",
		"PDMrcheckout_part: MEMwrite ",
		"Failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		return(PDM_E_WRITE_ROW);
	}
        /* mark exit time */
/*
         ci_exit = call_time();
         d_exit = system_time();
         sprintf(s,"From enter PDMrchkout to PDM function call  %f\n",(ci_exit - ci_inter));
         TIMEdebug(s);
         _TIMEdebug(d_inter,d_exit,"From enter PDMrchkout to PDM functon call");
*/

         /* mark enter time */
/*
         ci_inter = call_time();
         d_inter = system_time();
*/

        /* Display message */
        PDUmessage(PDS_M_CHECKOUT_PART, 's');

	/* load exec structure */
	PDUload_exec_structure("",catalog,n_itemname,n_itemrev, "","","",0, 0);

        PDUdeactivate_stop_sign();
	status = PDMcheckout_part(file_bufr, files_bufr, attach_info_bufr);
	_pdm_status("PDMcheckout_part", status);
        PDUactivate_stop_sign();

	if (status != PDM_S_SUCCESS)
	  {
	  PDUmessage(status, 's');
          PDUmessage(PDM_E_CLEAR_FIELD, 's');
	  /*MEMclose(&file_bufr);*/
	  MEMclose(files_bufr);
	  MEMclose(attach_info_bufr);
          return(status);
          }

        /* mark exit time */
/*
         ci_exit = call_time();
         d_exit = system_time();
         sprintf(s,"after PDM function  %f\n",(ci_exit - ci_inter));
         TIMEdebug(s);
         _TIMEdebug(d_inter,d_exit,"after PDM function");
*/

        /* Extract multiple files buffer */

            if (PDMdebug_on)
           {
            if (*files_bufr)
               MEMprint_buffer(
                               "files buffer",
                               *files_bufr, 
                               PDU_DEBUG_FILE
                              );

            if (*attach_info_bufr)
               MEMprint_buffer(
                               "attach info buffer",
                               *attach_info_bufr,
                               PDU_DEBUG_FILE
                              );
           }

        if ( (*attach_info_bufr == NULL) || ((*attach_info_bufr)->rows <= 0) )
           {
            _pdm_debug("no attach info found at checkout time", 0);
           }
        
        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug ("PDMrcheckout_part: returning SUCCESS", 0);

        /* mark total time */
/*
         ci_exit = call_time();
         d_exit = system_time();
         sprintf(s,"Total time in PDMrchkout  %f\n",(ci_exit - ci_enter));
         TIMEdebug(s);
         _TIMEdebug(d_enter,d_exit,"Total time in PDMrchkout");
*/

	return (status);
  }
