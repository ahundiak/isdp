#include <stdio.h>
#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "PDUfile_def.h"
#include "PDMmessage.h"
#include <PDUproto.h>
#include <PDMproto.h>

extern	PDUsts_ptr 	PDUsts;
extern	int 	PDMdebug_on;
static  long	status;
extern MEMptr PDU_file_bufr;
extern short PDU_is_om_file;

/* DESCRIPTION: checkin a pdm part 

	n_cofilename  is the name of the graphics file
	and it can be NULL to indicate that the filename
    is stored on the server

	child_bufr	 may/may not be empty 

	The format is as follows

	n_catalogname		char(14)
	n_itemname			char(14)
	n_itemrev			char(14)
	p_orient			char(528)
	p_quantity			integer
	p_history			char(10)
	p_childno			char(25)
	p_usageid			char(25)
	p_viewid			char(25)

	attach_bufr  may/may not be empty 

	foramt is as follows

	p_seqno			> 0 indicates BOM attachment
					= 0 pdmcit attachment
	n_catalogname	char(14)
    n_itemname		char(14)
	n_itemrev		char(14)	
    
    sv_bufr  may/may not be empty 

	p_origin			char(100)
	p_rotation			char(528)
	p_viewname			char(40)

	storage_buffer can be NULL
	If the server knows the storage areas for the 
	part being checked in

   RETURN CODES:

	  PDM_S_SUCCESS    				on success
	  PDM_E_PART_NOT_FOUND		part could not be found on server
	  PDM_E_PART_CHECKEDIN		If part is in checkedin status
	  PDM_E_NOT_CO_USER			User did not check out the part

*/

int PDMrcheckin_part (
                      catalog, 
		      n_itemname,
		      n_itemrev,
		      child_bufr,
		      attach_buffer,
		      view_buffer,
		      parm_buffer,
		      data_buffers,
                      param_ass_bufr,
                      param_child_dyn_bufr,
                      param_cat_list
                    )
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  MEMptr	child_bufr;
  MEMptr        attach_buffer;
  MEMptr	view_buffer;
  MEMptr	parm_buffer;
  MEMptr	data_buffers;
  MEMptr	param_ass_bufr;
  MEMptr        param_child_dyn_bufr;
  struct PDUcat_node *param_cat_list;
{
        MEMptr          local_files = NULL;
        MEMptr          part_files = NULL;
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


/*
	NFMtime_stamp_start("time.dat");
*/
         /* mark entry time */
/*
         ci_enter = ci_inter =  call_time();
         d_enter = d_inter =  system_time();
*/

	_pdm_debug("ENTER:PDMrcheckin_part", 0);
	_pdm_debug("PDMrcheckin_part: catalog = <%s>", catalog);
	_pdm_debug("PDMrcheckin_part: n_itemname = <%s>", n_itemname);
	_pdm_debug("PDMrcheckin_part: n_itemrev = <%s>", n_itemrev);
	/*_pdm_debug("PDMrcheckin_part: n_cofilename = <%s>", n_cofilename);*/

        if (!PDU_file_bufr)
          {
          status = PDUformat_buffer(PDU_FILE_BUFFER, &PDU_file_bufr);
          _pdm_status("PDUformat_buffer", status);
          }

        if (PDMdebug_on)
          {
          MEMprint_buffer 
		("PDMrcheckin_part: PDU_file_bufr",PDU_file_bufr,PDU_DEBUG_FILE);
          MEMprint_buffer 
		("PDMrcheckin_part: child_buffer",child_bufr,PDU_DEBUG_FILE);
	  MEMprint_buffer 
		("PDMrcheckin_part: attach_buffer",attach_buffer,PDU_DEBUG_FILE);
	  MEMprint_buffer
		("PDMrcheckin_part: view_buffer",view_buffer,PDU_DEBUG_FILE);
	  MEMprint_buffer
		("PDMrcheckin_part: parm_buffer",parm_buffer,PDU_DEBUG_FILE);
	  MEMprint_buffers
		("PDMrcheckin_part: data_buffers",data_buffers,PDU_DEBUG_FILE);
	  MEMprint_buffer
		("PDMrcheckin_part: param_ass_buffers",param_ass_bufr,
                 PDU_DEBUG_FILE);

          MEMprint_buffers
                ("PDMrcheckin_part: param_child_dyn_bufr",
                                    param_child_dyn_bufr, PDU_DEBUG_FILE);
          }

         /* mark exit time */
/*
         ci_exit = call_time();
         d_exit = system_time();
         sprintf(s,"From enter PDMrchkin to PDM function call  %ld\n",(ci_exit - ci_inter));
         TIMEdebug(s);
         _TIMEdebug(d_inter,d_exit,"From enter PDMrchkin to PDM function call");
*/
         /* mark enter time */
/*
         ci_inter = call_time();
         d_inter = system_time();
*/

        /* Display Message */
        PDUmessage(PDS_M_CHECKIN_PART, 's');

        /*
	if (attach_buffer == NULL) MEMopen(&attach_buffer, 512);
	if (child_bufr == NULL) MEMopen(&child_bufr, 512);
        if (view_buffer == NULL) MEMopen(&view_buffer, 512);
	if (parm_buffer == NULL) MEMopen(&parm_buffer, 512);
	if (data_buffers == NULL) MEMopen(&data_buffers, 512);
        */

	/* load exec structure */
	PDUload_exec_structure("",catalog,n_itemname,n_itemrev, "","","",0, 0);

	/* call PDM function */
        _pdm_debug("calling PDMcheckin_part", 0);
        PDUdeactivate_stop_sign();
	status = PDMcheckin_part1(PDU_is_om_file,
                                 1,
                                 child_bufr,
                                 attach_buffer,
                                 view_buffer,
                                 parm_buffer,
				 data_buffers, 
                                 param_ass_bufr,
                                 param_child_dyn_bufr,
                                 param_cat_list, 
                                 &local_files,
                                 &part_files
                                );
	_pdm_status("PDMcheckin_part", status);
        PDUactivate_stop_sign();

        if (status == NFM_E_NOT_CO_USER)
         {
           /* ALR  1/14/94  */
          status = PDM_E_ANOTHER_USER;
          PDUmessage(status,'s');
         }

	if (status != PDM_S_SUCCESS)
          {
           if (PDU_file_bufr)
             {
	     MEMclose(&PDU_file_bufr); 
             PDU_file_bufr = NULL;
             }
           if (local_files)
	     MEMclose(&local_files);

           if (part_files)
              MEMclose(&part_files);

           return(status);
          }
         else
         {
          PDUmessage(status,'s');
          sleep(3);
         }

         /* mark exit time */
/*
         ci_exit = call_time();
         d_exit = system_time();
         sprintf(s,"after PDM function  %ld\n",(ci_exit - ci_inter));
         TIMEdebug(s);
         _TIMEdebug(d_inter,d_exit,"after PDM function");
*/

/*
	NFMtime_stamp_stop("AFTER CHECKIN FINISH","time.dat");
*/
        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

        /* Print out file buffer */
        if (PDMdebug_on)
           MEMprint_buffer("local file buffer:", local_files, PDU_DEBUG_FILE);

        /* Print out part files buffer */
        if (PDMdebug_on)
           MEMprint_buffer("part files buffer:", part_files, PDU_DEBUG_FILE);

        /* remove file(s) locally */
        status = PDUremove_files_locally(local_files);
        _pdm_status("PDUremove_files_locally", status);

        if (status != PDM_S_SUCCESS)
           {
            if (PDU_file_bufr)
               MEMclose(&PDU_file_bufr);

            if (local_files)
               MEMclose(&local_files);

            if (part_files)
               MEMclose(&part_files);

            return(PDM_E_COMPLETE_CHECKIN);
           }

        /* Change permissions on part files, if any. */
        status = PDUchange_to_read_only(part_files);
        _pdm_status("PDUchange_to_read_only", status);
       
        if (status != PDM_S_SUCCESS)
           {
            if (PDU_file_bufr)
               MEMclose(&PDU_file_bufr);

            if (local_files)
               MEMclose(&local_files);

            if (part_files)
               MEMclose(&part_files);

            return(PDM_E_COMPLETE_CHECKIN);
           }

        /* Close buffers */
        if (PDU_file_bufr)
            MEMclose(&PDU_file_bufr);

        if (local_files)
	   MEMclose(&local_files);

         /* mark total time */
/*
         ci_exit = call_time();
         d_exit = system_time();
	_pdm_debug("PDMrcheckin_part: ci_exit = <%ld>", ci_exit);
         sprintf(s,"total time in PDMrchkin  %ld\n",(ci_exit - ci_enter));
         TIMEdebug(s);
         _TIMEdebug(d_enter,d_exit,"Total time in PDMrchkin");
*/

	return (status);
  }
