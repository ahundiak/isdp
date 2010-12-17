#include	<string.h>
#include	<sys/types.h>
#include	<sys/stat.h>
#include	<errno.h>
#include        <PDUerror.h>
#include        <PDUstr.h>
#include	<PDUintdef.h>
#include	<PDUint.h>
#include	<PDUuser.h>
#include	<PDUforms.h>
#include	<PDUproto.h>
#include	<OMlimits.h>
#include	<igrtypedef.h>
#include	<exdef.h>

extern struct PDUrefresh *refresh; 
extern struct PDUforms forms; 
extern struct PDUuser    *user;
extern IGRint		 PDU_invis_file_index;
extern IGRint PDUactive_checkin;
extern IGRchar *PDU_topdown_flag; /*jbp-change from IGRint to IGRcharfor ansi */
extern short  PDU_design_form_display;
extern int  PDU_design_listing_form_displayed;
extern int    PDU_command;
extern int    PDU_local_files_displayed;
extern short  PDU_active_part;
extern Form   place_part_f;
extern Form   ModifyPartForm;
extern Form   PDU_form_id;

/****************************************************************************

Document:	PDUverify_login

Description:
	This function checks to see if a user has logged in to PDU.
	If so, the refresh area will contain the username.

Return Status:
	PDM_S_SUCCESS	-	A user is logged in
	PDM_E_FAILURE	-	No user is logged in

Notes:
	PDUverify_login is invoked from the verify_command method of the
	command launcher; this method is invoked from every .sl file.

History:
	08/87		Bill Kirk	Created
	06/21/88	Bill Kirk	Documented

*****************************************************************************/

int	PDUverify_login ()
  {
  IGRint	status;
  IGRint        responses[1];
  IGRchar       *strings[1];

  extern IGRint PDU_connection;

  _pdm_debug("In the function PDUverify_login", 0);

  _pdm_debug("connection = %d",(char *)PDU_connection);
  if (user->username != NULL)
    {
    _pdm_debug("user->username = <%s>",user->username);
    }
  else
    {
    _pdm_debug("user->username = NULL", 0);
    }

  if ( !PDUnullstr(user->username) && ((PDU_form_id == forms.design_form_id) ||
        ((PDU_form_id == forms.local_files_form_id) && 
         (!PDU_local_files_displayed))))
     {
       /*disp_mod = PDUcheck_PDU_form_display();*/
       /*if (disp_mod)
         {
         _pdm_debug("PDU form already displayed", 0);
         return(PDM_S_SUCCESS);
         }*/
       PDUupdate_design_form();
       _pdm_debug("Displaying Form", 0);
       responses[0] = D_RESET;
       strings[0] = "";
       PDUprepare_queue(responses, strings, 1);
       PDU_design_form_display = TRUE;
       PDUmessage(PDM_E_CLEAR_FIELD, 's');
       status = PDM_E_CLEAR_FIELD;
     }
  else if (!PDUnullstr(user->username) && (PDU_form_id != forms.design_form_id))
     {
     _pdm_debug("user is already logged in", 0);
     PDUmessage(PDM_S_LOGIN, 's');
     status = PDM_S_LOGIN;
     }
  else
     {
     _pdm_debug("No user is logged in", 0);
     status = PDM_E_FAILURE;
     }

  return ( status );
  }

/****************************************************************************

Document:	PDUverify_command

Description:
	This function verifies that certain pre-conditions are satisfied
	for the specified command.

Return Status:
	PDM_S_SUCCESS	-	Success, pre-conditions are satisfied
	Other PDM status -	Depends on command specified

Notes:
	PDUverify_command is invoked from the verify_command method of the
	command launcher; this method is invoked from every .sl file.

Example:
.bp
	status = PDUverify_command (me->mytype);
.ep

History:
	08/87		Bill Kirk	Created
	06/02/88	Bill Kirk	Modified for checkin active file
	06/21/88	Bill Kirk	Documented
	10/89		Lynn Mettlen	Modified checkin to check for origin

*****************************************************************************/

int	PDUverify_command (command)

int	command;			/* i - PDU command selected */
  {
  IGRint	status = PDM_S_SUCCESS;		/* return status */
  /*IGRint	index = 0; APOGEE */ 		/* entry in invisible mod table */
  /*IGRchar	*orientation = NULL;		   APOGEE */
  extern struct PDUrefresh  *refresh;
  char          *state = NULL;

  _pdm_debug("In the function PDUverify_command, command type = %d", (char *)command);

  /* check pre-conditions for each command type */
  switch ( command )
     {
     case  PDC_M_ALIGN_PART:
     case  PDC_M_REPLACE_PART:
	   /* verify part specification in active refresh area */
	   status = PDUverify_part ( 'a' );
	   _pdm_status ("PDUverify_part (active)", status);
	   if (1&status )
	     {
	     /* verify part specification in review refresh area */
	     status = PDUverify_part ( 'r' );
	     _pdm_status ("PDUverify_part (review)", status);

             /* verify part type is not ascii */
             if ( (strcmp(refresh->rev_parttype,"A") == 0) ||
                  (strcmp(refresh->rev_parttype,"a") == 0) )
                {
                 status = PDM_E_INVALID_PART_TYPE;
                 break;
                }
	     }

	   if ( 1&status) 
	      {
	      /* verify view name specification in refresh area */
	      if ( PDUnullstr(refresh->view) )
		 {
		 _pdm_debug ("refresh view is undefined", 0 );
		 status = PDM_E_VIEW_NULL;
		 }
	      }
	   break;

     case  PDC_M_PLACE_VIEW:

	   /* verify part specification in active refresh area */
	   status = PDUverify_part ( 'a' );
	   _pdm_status ("PDUverify_part (active)", status);
	   if (1&status )
	     {
	     /* verify part specification in review refresh area */
	     status = PDUverify_part ( 'r' );
	     _pdm_status ("PDUverify_part (review)", status);
	     }

	   if ( 1&status) 
	      {
              /* verify part type is not parametric */
              if ( (strcmp(refresh->rev_parttype,"P") == 0) ||
                   (strcmp(refresh->rev_parttype,"p") == 0) )
                  status = PDM_E_CAN_NOT_ATTACH_PARAMETRIC_PART;

              /* verify part type is not ascii */
              if ( (strcmp(refresh->rev_parttype,"A") == 0) ||
                   (strcmp(refresh->rev_parttype,"a") == 0) )
                  status = PDM_E_INVALID_PART_TYPE;


	      /* verify view name specification in refresh area */
	      if ( PDUnullstr(refresh->view) )
		 {
		 _pdm_debug ("refresh view is undefined", 0 );
		 status = PDM_E_VIEW_NULL;
		 }
	      }
	   break;

     case  PDC_M_PLACE_PART:
	   /* verify part specification in active refresh area */
	   status = PDUverify_part ( 'a' );
	   _pdm_status ("PDUverify_part (active)", status);
	   if (1&status )
	     {
	     /* verify part specification in review refresh area */
	     status = PDUverify_part ( 'r' );
	     _pdm_status ("PDUverify_part (review)", status);
	     }

	   if ( 1&status) 
	      {
	      /* verify view name specification in refresh area */
	      if ( PDUnullstr(refresh->view) )
		 {
		 _pdm_debug ("refresh view is undefined", 0 );
		 status = PDM_E_VIEW_NULL;
		 }
              /* check to see if part type is parametric */
                 /*status = PDUcheck_if_parametric_part();
                 _pdm_status("PDUcheck_if_parametric_part", status); */

              /* check to see if part type is ascii 
                 if ( (strcmp(refresh->rev_parttype,"A") == 0) ||
                      (strcmp(refresh->rev_parttype,"a") == 0) )
                    status = PDM_E_INVALID_PART_TYPE;
              */
              }

	   break;

     case  PDC_M_EDIT_PART:
	   /* verify part specification in active refresh area */
	   status = PDUverify_part ( 'a' );
	   _pdm_status ("PDUverify_part (active)", status);

	   break;

     case  PDC_M_CANCEL_CHECKOUT:
	   /* verify part specification in review refresh area */
	   status = PDUverify_part ( 'r' );
	   _pdm_status ("PDUverify_part (review)", status);

	   break;

     case  PDC_M_COPY_PART:
     case  PDC_M_ATTACH_PART:
	   /* verify part specification in active refresh area */
	   status = PDUverify_part ( 'a' );
	   _pdm_status ("PDUverify_part (active)", status);

	   break;

     case  PDC_M_DEFINE_ORIGIN:
/*	   if ( PDUnullstr(refresh->view) )
	      status = PDM_E_VIEW_NULL; */
	   break;

     case  PDC_M_CHECKIN:
	break;

     case  PDC_M_CHECKOUT_UPDATE:
	   /* must have review part defined */
	   status = PDUverify_part ( 'r' );
	   _pdm_status ("PDUverify_part (review)", status);
           /* check if part can be checked out */
           if ((strcmp(refresh->rev_parttype,"P") == 0) ||
               (strcmp(refresh->rev_parttype,"p") == 0))
                return(PDM_E_CAN_NOT_CHECKOUT_PARAMETRIC_PART);

           if ((strcmp(refresh->rev_parttype,"A") == 0) ||
               (strcmp(refresh->rev_parttype,"a") == 0))
                return(PDM_E_INVALID_PART_TYPE);
          
           if ((strcmp(refresh->rev_parttype,"N") == 0) ||
               (strcmp(refresh->rev_parttype,"n") == 0))
                return(PDM_E_INVALID_PART_TYPE);
	   break;

         
     case  PDC_M_CREATE_GRAPHICS:
	   /* must have review part defined */
	   status = PDUverify_part ( 'r' );
	   _pdm_status ("PDUverify_part (review)", status);

           /* check if part type is invalid 
           if ((strcmp(refresh->rev_parttype,"N") != 0) &&
               (strcmp(refresh->rev_parttype,"n") != 0))
                return(PDM_E_INVALID_PART_TYPE);
           */
	   break;

              
     case  PDC_M_COPY:
	   /* must have review part defined */
	   status = PDUverify_part ( 'r' );
	   _pdm_status ("PDUverify_part (review)", status);

           if (status == PDM_S_SUCCESS)
              {
               /* check if part can be locally copied */
               if ((strcmp(refresh->rev_parttype,"G") != 0) &&
                  (strcmp(refresh->rev_parttype,"M") != 0) &&
                  (strcmp(refresh->rev_parttype,"C") != 0) &&
                  (strcmp(refresh->rev_parttype,"g") != 0) &&
                  (strcmp(refresh->rev_parttype,"m") != 0) &&
                  (strcmp(refresh->rev_parttype,"c") != 0) &&
                  (strcmp(refresh->rev_parttype,"A") != 0) &&
                  (strcmp(refresh->rev_parttype,"a") != 0) &&
                  (strcmp(refresh->rev_parttype,"D") != 0) &&
                  (strcmp(refresh->rev_parttype,"d") != 0))
                  {
                  _pdm_debug("parttype = <%s>", refresh->rev_parttype);
                  return(PDM_E_CAN_NOT_LOCALLY_COPY_PART);
                  }
               }
	   break;

     case  PDC_M_ACTIVATE_PART:
	   break;

     case  PDC_M_BOM_DISPLAY_REVIEW:
     case  PDC_M_REVIEW_PART:
     /*case  PDC_M_MODIFY_ELEMENT:*/
     case  PDC_M_DELETE_ELEMENT:
	   /* must have review part defined */
	   status = PDUverify_part ( 'r' );
	   _pdm_status ("PDUverify_part (review)", status);

	   break;

     case  PDC_M_LOGOUT:
     case  PDC_M_DETACH_PART:
     case  PDC_M_DELETE_ORIGIN:
	   status = PDM_S_SUCCESS;
	break;


     case  PDC_M_CREATE_CATALOG:
     case  PDC_M_DISPLAY_LOC:
        break;

     /*case  PDC_M_CREATE_ELEMENT:*/
     case  PDC_M_DISPLAY_CATALOG:
	   if ( PDUnullstr(refresh->rev_catalog) )
	      status = PDM_E_CAT_NULL;
        break;

     case PDC_M_DEFINE_BOMLIST:
        break;

     case PDC_M_DEFINE_CATLIST:
        break;

     case PDC_M_DEFINE_BOMCONT:
        break;

     case PDC_M_DEFINE_SEARCH:
        break;

     case PDC_M_SEARCH_ONOFF:
        break;


     /*case PDC_M_ARCHIVE_PENDING:
        break;

     case PDC_M_RETRIEVE_PENDING:
        break;*/

     case PDC_M_ARCHIVE_PENDING:
     case PDC_M_DELETE_PENDING:
     case PDC_M_BACKUP_PENDING:

          status = PDUget_file_status(refresh->rev_catalog, refresh->rev_partid,
                                     refresh->rev_revision, &state);
          _pdm_status("PDUget_file_status", status);

          _pdm_debug("state = <%s>", state);
          if ((state) && (strcmp(state, "I") == 0))
            status = PDM_S_SUCCESS;
          else
            status = PDM_I_PART_CHECKIN;

          break;

     default:
	status = PDM_S_SUCCESS;
	break;
     }

  return ( status );
  }

/****************************************************************************

Document:	PDUverify_part

Description:
	This function verifies the values contained in the refresh area
	part specification.  The type of verification done depends on the
	verify_flag:

.bp
	'a'	-	Verify active refresh area
	'r'	-	Verify review refresh area
	'e'	-	Verify that active part spec is equal to
			review part spec.
.ep

Return Status:
	PDM_S_SUCCESS	-	Success; Part specs are equal
	PDM_E_CAT_NULL	-	Catalog name in review refresh is NULL
	PDM_E_PART_NULL	-	Part id in review refresh is NULL
	PDM_E_REV_NULL	-	Revision in review refresh is NULL
	PDM_E_NOT_ACTIVE -	Any field in active refresh part spec is NULL
	PDM_E_FAILURE	-	Verification failed; Part specs not equal

bp


	status = PDUverify_part ('a');
.ep

History:
	08/87		Bill Kirk	Created
	06/02/88	Bill Kirk	Modified for checkin active file
	06/21/88	Bill Kirk	Documented

*****************************************************************************/

int	PDUverify_part (verify_flag)
int	verify_flag;			/* i - type of verification */
  {
  IGRint	status;				/* return status */

  switch ( verify_flag )
     {
     case 'r':
     	  if ( PDUnullstr(refresh->rev_catalog) )
	     status = PDM_I_ENTER_CATALOG;
     	  else if ( PDUnullstr(refresh->rev_partid) )
	     status = PDM_I_ENTER_PART;
     	  else if ( PDUnullstr(refresh->rev_revision) )
	     status = PDM_I_ENTER_REVISION;
     	  else
	     status = PDM_S_SUCCESS;
          break;
     
     case 'a':
     	  if ( PDUnullstr(refresh->act_catalog)  ||
	       PDUnullstr(refresh->act_partid)   ||
	       PDUnullstr(refresh->act_revision)
	     )
	     status = PDM_E_NOT_ACTIVE;		/* part was not activated */
          else
	     status = PDM_S_SUCCESS;
          break;

     case 'e':
   	  /* see if review part is same as active part */
	  if ( !strcmp(refresh->act_partid, refresh->rev_partid) &&
	       !strcmp(refresh->act_revision, refresh->rev_revision) &&
	       !strcmp(refresh->act_catalog, refresh->rev_catalog)
	     )
	     status = PDM_S_SUCCESS;
	  else
	     status = PDM_E_FAILURE;
	  break;

     default:
	  status = PDM_E_FAILURE;
	  break;
     }

  return ( status );
  }


/****************************************************************************

Document:	PDUverify_file

Description:
	This function checks to see if a specified file exists on the local
	disk.

Return Status:
	PDM_S_SUCCESS	-	Success, file exists
	PDM_E_FILE_NULL -	File name in refresh is NULL
	PDM_E_FILE_NOT_FOUND -	File does not exist locally
	PDM_E_FAILURE	-	An unpredicted UNIX system error occurred

Example:
.bp
	status = PDUverify_file (refresh->rev_filename);
.ep

History:
	08/87		Bill Kirk	Created
	04/88		Bill Kirk	Modified
	06/21/88	Bill Kirk	Documented

*****************************************************************************/

int	PDUverify_file (part_os)

  char	*part_os;		/* i - name of file for checkin */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  struct stat	file_status;		/* argument for stat call */
  int           string_len;

  if ( PDUnullstr(part_os) )
     {
     _pdm_debug("file name is null", 0);
     return ( PDM_E_FILE_NULL );
     }

  _pdm_debug("File at entry of PDUverify_file is <%s>",part_os);
  string_len = strlen(part_os);
  _pdm_debug("STRING LENGTH is <%d>",(char *)string_len);

  /* check to see if file exists */
  status = stat ( part_os, &file_status );
  _pdm_status("stat", status);

  /* file exists */
  if ( status == 0 )
     {
     _pdm_debug("file %s was found", part_os);
     status = PDM_S_SUCCESS;
     return(status);
     }
  /* file does not exist */
  if (status == -1)
     {
     if (errno == ENOTDIR)
        _pdm_debug("Path prefix is not a directory",0);
     else if (errno == ENOENT)
        _pdm_debug("Named file does not exist",0);
     else if (errno == EACCES)
        _pdm_debug("Search permission denied",0);
     else if (errno == EFAULT)
        _pdm_debug("Path points to invalid address",0);
     else if (errno == EINTR)
        _pdm_debug("Signal was caught during the stat systam call",0);
     else if (errno == ENOLINK)
        _pdm_debug("No link to remote machine",0);
     else if (errno == EMULTIHOP)
        _pdm_debug("Path requires hopping to multiple machines",0);
     status = PDM_E_FILE_NOT_FOUND;
     }
/*
  else if ( (status == -1) && (errno == ENOENT) )
     {
     _pdm_debug("ERROR in call to stat, errno = ENOENT (%d)", errno);
     _pdm_debug("file %s was not found", part_os);
     status = PDM_E_FILE_NOT_FOUND;
     }
*/
  /* an unpredicted error occurred */
  else
     {
     _pdm_debug("ERROR in call to stat: errno = %d", (char *)errno);
     status = PDM_E_FAILURE;
     }  

  return ( status );
  }
/*****************************************************************************
 
 Document:    PDUtopdown_terminate()

 Description:   This function checks to see if the topdown flag is set to 'yes'.                If so, PDM_S_SUCCESS is returned.

 Return Status:   PDM_S_SUCCESS
                  0

 History:     19 July 1991      Mychelle Joiner           Created

*****************************************************************************/

 int PDUtopdown_terminate()
 {
 int     status = 0;

 _pdm_debug("In the function PDUtopdown_terminate", 0);
 _pdm_debug("topdown_flag = <%s>", PDU_topdown_flag);

 if (strcmp(PDU_topdown_flag, "yes") == 0)
   {
   _pdm_debug("terminating place and attach part inside topdown design", 0);
   status = PDM_S_SUCCESS;
   }

 return (status);
 }
