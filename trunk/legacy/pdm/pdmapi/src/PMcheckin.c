/****************************************************************************
Include Files
****************************************************************************/
#include                <stdio.h>
#include                "PDUerror.h"
#include                "MEMstruct.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "SQLerrordef.h"
#include                "PDMapi.h"
#include                "UMS.h"
#include        <sys/stat.h>
#include                "PDUris_incl.h"
#include                "PDMproto.h"
#include                "PDUpdmrpro.h"
#include        <PDUstorage.h>
#include        <PDUuser.h>
#include        <PDUstr.h>

extern  int             PDMdebug_on;
extern  char            PDM_DEBUG_FILE[];
extern  PDMexec_ptr     PDMexec;
extern  PDMpart_ptr     PDMpart;
extern struct PDUuser     *user;




/****************************************************************************
Main Function
****************************************************************************/

long pdmoCheckinPart
(
char *cpr_catalog,
char *cpr_partnum,
char *cpr_revision,
char *cpr_filename,
char *car_st_update_flag
)
{

char *fname = "pdmoCheckinPart";
int          cpw_catno = 0;
int          update_structure;
char         cpw_type[6] = "", *cpw_message = NULL, *cpr_usageid = NULL;
long         status = PDM_S_SUCCESS, status1 = NFM_S_SUCCESS;
         MEMptr file_bufr = NULL;
        MEMptr child_bufr = NULL;
        MEMptr attach_bufr = NULL;
        MEMptr sv_bufr = NULL;
        MEMptr parm_buffer = NULL;
        MEMptr data_buffers = NULL;
        MEMptr para_ass = NULL;
        MEMptr para_ass_dynamic = NULL;
        struct PDUcat_node *para_cats = NULL;
        MEMptr delete_list= NULL;
        MEMptr mul_files = NULL;
        int PDMremove_files_locally();
        int PDMchange_to_read_only();
char *file_format = NULL;
char *ems_format = NULL;
struct stat file_status;
  


   _PDMdebug(fname,"Enter\n");

   /* Check for login */
   if(!pdmcheck_log_in()) 
       {
       _PDMdebug(fname,"User has not logged into the database\n");
       return (PDM_E_USER_NOT_LOGGED_IN);
        }
      
   /* Validate the user access*/
     status = PDMvalidate_user_access("PDMCheck In Part", "",
           cpr_catalog, "", cpr_partnum, cpr_revision );
     if (status != PDM_S_SUCCESS)
      {
      _PDMdebug(fname,"User does not access to checkin the part\n");
       return(status);
      }

    /* This operation is not valid on parametric parts */
    status = PDMget_catno_type(cpr_catalog,&cpw_catno, cpw_type);
                if(status != SQL_S_SUCCESS)
                {
                       if(status == SQL_I_NO_ROWS_FOUND) ;
                       else
                       {
                     _PDMdebug(fname,"Parametric Parts can't be checked in\n");
                       return(status);
                       }
                 }

    /* Validate the part for this command based upon the
       current status of the part */

       status = PDMload_part_info(cpr_catalog, cpr_partnum, cpr_revision);
        if (status != PDM_S_SUCCESS) 
        {
     _PDMdebug (fname, "PDMload_part_info failed status <0x%x.8>\n", status);
        return (status);
        }
     _PDMdebug(fname, "parttype = %s, n_status = %s\n",  PDMpart.p_parttype,
                       PDMpart.n_status);

    /* Check whether the part is not checked out */ 
      if(!strcmp(PDMpart.n_status,"I") )
      {
      _PDMdebug(fname,"Part has tobe checked out\n");
      return (PDM_E_NOTCHECK_OUT);
     }

  /* Check the part for flagging */
      if ((!strncmp(PDMpart.n_pendingflag, "IA", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SA", 2))) {
                _PDMdebug (fname,  "Part is flagged for achive\n");
                return (PDM_E_PART_FLAGGED_FOR_ARCHIVE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IB", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SB", 2)))
           {
           _PDMdebug (fname,  "Part is flagged for backup\n");
                return (PDM_E_PART_FLAGGED_FOR_BACKUP);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "ID", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SD", 2)))
           {
           _PDMdebug (fname,  "Part is flagged for delete\n");
                return (PDM_E_PART_FLAGGED_FOR_DELETE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IR", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SR", 2)))
           {
            _PDMdebug (fname,  "Part is flagged for delete\n");
                return (PDM_E_PART_FLAGGED_FOR_RESTORE);
           }

    PDMstrcpy(cpr_catalog, &PDMexec->catalog);
    PDMstrcpy(cpr_partnum, &PDMexec->part_num);
    PDMstrcpy(cpr_revision, &PDMexec->revision);

     /* Jenny put your code to kickoff the ppl which calls the PDU function
    */
     if ((car_st_update_flag) && (strcmp(car_st_update_flag, "") != 0) &&
         (strcmp(car_st_update_flag, "N") != 0) && (strcmp(car_st_update_flag,
          "n") != 0))
         {
         update_structure = 1;
         status = pdmoObjectSpaceInfoForCheckin(cpr_filename) ;
         _pdm_status("pdmoObjectSpaceInfoForCheckin", status);
         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("pdmoObjectSpaceInfoForCheckin failed", 0);
           return(status);
           }
         
/* MJG 12/23/94  If file is not a PDU design file, do not try to read data from
   files in /usr/tmp 
*/
         status = PDUread_format_from_file(&file_format);
         _pdm_status("PDUread_format_from_file", status);
         _pdm_debug("file_format = <%s>", file_format);

         if (status != PDM_S_SUCCESS)
           return(status);

         PDUfill_in_string(&ems_format, "File is not a PDU design file");
         _pdm_debug("ems_format = <%s>", ems_format);

         if (file_format && ems_format &&
            (strcmp(file_format, ems_format) != 0))
           {
           /*  Function which reads the data back from the shared memory */ 
           _pdm_debug("calling PDMrec_data_from_file", 0);
           status =  PDMrec_data_from_file (&file_bufr,&child_bufr,&attach_bufr,
                                          &sv_bufr, &parm_buffer,&data_buffers,
                                          &para_ass, &para_ass_dynamic);
           if(status != PDM_S_SUCCESS)
             {
             _PDMdebug(fname, "Could not read data from file: %d\n", status );
             return(status);
             }
           }
         else
           {
           _pdm_debug("passing NULL for object space buffers", 0);
           update_structure = 0;
           }
         }
       else
         update_structure = 0;

       status = stat("/usr/tmp/format.dat" ,&file_status);
       if (status == 0) /* entry exists */
         {
         _pdm_debug("removing format.dat file", 0);
         status = unlink("/usr/tmp/format.dat");
         }

       if (ems_format)
         free(ems_format);
       if (file_format)
         free(file_format);
        

     /* Call the PDM function which does the checkin of the part */

     status =  PDMcheckin_part1 (update_structure, 1, child_bufr,attach_bufr,
                                sv_bufr, parm_buffer, data_buffers,
                                para_ass, para_ass_dynamic, NULL,
                                &delete_list, &mul_files);

         if(status != PDM_S_SUCCESS)
             {
      _PDMdebug(fname,"Could not checkin the part: %d\n", status );
             return(status);
             }

            if (status == NFM_E_NOT_CO_USER)
          status = PDM_E_NOT_CHECKOUT_USER;

        if (status != PDM_S_SUCCESS)
          {
           if (delete_list)
             MEMclose(&delete_list);

           if (mul_files)
              MEMclose(&mul_files);

           return(status);
          }
          if (PDMdebug_on)
           {
           MEMprint_buffer("local file buffer:", delete_list, PDM_DEBUG_FILE);
           MEMprint_buffer("part files buffer:", mul_files, PDM_DEBUG_FILE);
           }

        /* remove file(s) locally */
        status = PDMremove_files_locally(delete_list);
        _pdm_status("PDUremove_files_locally", status);

        if (status != PDM_S_SUCCESS)
           {
            if (delete_list)
               MEMclose(&delete_list);

            if (mul_files)
               MEMclose(&mul_files);
            return(PDM_E_COMPLETE_CHECKIN);
           }

        /* Change permissions on part files, if any. */
        status = PDMchange_to_read_only(mul_files);
        _pdm_status("PDUchange_to_read_only", status);

        if (status != PDM_S_SUCCESS)
           {
            if (delete_list)
               MEMclose(&delete_list);

            if (mul_files)
               MEMclose(&mul_files);

            return(PDM_E_COMPLETE_CHECKIN);
           }
          /* Close buffers */

        if (delete_list)
           MEMclose(&delete_list);
        if(mul_files) MEMclose(&mul_files);

         /* mark total time */

    if(status != PDM_S_SUCCESS)
     {
   /* Convert the status to a message string */
      if ((status1 = UMSGetByNum (cpw_message, status, NULL)) != UMS_S_SUCCESS)
           _PDMdebug(fname, "UNKNOWN: %d\n", status );
      }
      else
       {
        status = NFM_S_SUCCESS;
        cpw_message = (char *) malloc (80);
        strcpy(cpw_message, "Successful Completion");
       }

    /* Make a log of this command and corresponding transition */
    /* If set_to_state fails, don't return a error, ignore it */
      if ((status1 = PDMset_to_state (status, "PDM", cpw_message)) != PDM_S_SUCCESS)

       _PDMdebug(fname, "PDMset_to_state failed status %d\n", status1);
       
     if(cpw_message) free(cpw_message);
       MEMclose(&file_bufr);
        MEMclose(&child_bufr);
        MEMclose(&attach_bufr);
        MEMclose(&sv_bufr);
        MEMclose(&parm_buffer);
        MEMclose(&data_buffers);
        MEMclose(&para_ass);
   
     _PDMdebug(fname,"Exit - SUCCESSFUL COMPLETION\n");
     return(PDM_S_SUCCESS);
}

int PDMremove_files_locally(file_buffer)

 MEMptr  file_buffer;
{
 long    status = PDM_S_SUCCESS;
 int     i;
 int     file_col;
 char    full_name[256];
 char    **file_names;
 char    local_files_path[256];
 struct  stat file_status;
 extern  struct PDUuser  *user;

 _pdm_debug("In the PDUremove_files_locally function", 0);

 /* Check to see if file buffer is empty */
 if ( !(file_buffer) || (file_buffer->rows <= 0) )
  {
     _pdm_debug("no files to remove locally", 0);
     return(PDM_S_SUCCESS);
    }

 MEMbuild_array(file_buffer);

 status = PDUget_buffer_col(
                            file_buffer,
                            "n_cofilename",
                            &file_col
                           );
 if (status != PDM_S_SUCCESS)
    return(status);


 file_names = (char **) file_buffer->data_ptr;

 /* Construct local files full path */
 strcpy(local_files_path, user->wrkst_cwd);
 strcat(local_files_path, "/");
_pdm_debug("local files full path = <%s>", local_files_path);

 /* Loop thru file buffer deleting files */
 for (i = 0; i < file_buffer->rows; ++i)
     {
      strcpy(full_name, local_files_path);
      strcat(full_name, file_names[i]);

      _pdm_debug("removing <%s> locally", full_name);

      status = stat(full_name, &file_status);
      if (status == 0)
         {
          /* Remove file */
          unlink(full_name);

          if (status == 0)
             {
              _pdm_debug("file <%s> was deleted successfully", full_name);
             }

           else
               {
                _pdm_debug("failed to delete file <%s>", full_name);
               }
         }

      else
         {
          _pdm_debug("file <%s> does not exist locally", full_name);
         }

     } /* end for loop */

 return(PDM_S_SUCCESS);
}

int PDMchange_to_read_only(part_files)

 MEMptr  part_files;
{
 long    status = PDM_S_SUCCESS;
 int     i;
 int     file_col;
 char    full_name[256];
 char    **file_names;
 char    local_files_path[256];
 struct  stat file_status;
 mode_t  mode;
 extern  struct PDUuser  *user;

 _pdm_debug("In the PDUchange_to_read_only function", 0);

 /* Check to see if file buffer is empty */
 if ( !(part_files) || (part_files->rows <= 0) )
    {
     _pdm_debug("no files to change permissions on", 0);
     return(PDM_S_SUCCESS);
    }

MEMbuild_array(part_files);

 status = PDUget_buffer_col(
                            part_files,
                            "n_cofilename",
                            &file_col
                           );
 if (status != PDM_S_SUCCESS)
    return(status);


 file_names = (char **) part_files->data_ptr;

 /* Construct local files full path */
 strcpy(local_files_path, user->wrkst_cwd);
 strcat(local_files_path, "/");

 _pdm_debug("local files full path = <%s>", local_files_path);

 /* Loop thru part files buffer changing permissions */
 for (i = 0; i < part_files->rows; ++i)
{
      strcpy(full_name, local_files_path);
      strcat(full_name, file_names[i]);

      _pdm_debug("changing permissions on <%s>", full_name);

      status = stat(full_name, &file_status);
      if (status == 0)
         {
          /* Change file permissions to read only */
          mode = S_IRUSR | S_IRGRP | S_IROTH;
           if(chmod(full_name, mode))
             {
              _pdm_debug("chmod failed", 0);
              return(status);
             }
         }

      else
         {
          _pdm_debug("file <%s> does not exist locally", full_name);
         }

     } /* end for loop */

 return (PDM_S_SUCCESS);
}
