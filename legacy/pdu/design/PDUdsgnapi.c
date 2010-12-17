#include        <PDUint.h>
#include        <PDUintdef.h>
#include        <PDUfile_def.h>
#include        <MEMerrordef.h>
#include        <PDUstr.h>
#include <stdio.h>
#include <string.h>
#include <PDUprompt.h>
#include <PDUuser.h>
#include <PDUfile_def.h>
#include <PDUassy.h>
#include <PDUproto.h>

extern struct PDUrefresh        *refresh;
extern struct PDUuser           *user;
extern int    PDU_validate_access;
extern int    new_mode;
extern int    similar_mode;
extern char   *np_catalog;
extern MEMptr PDU_func_buffer;

#define	BUFFER_COLS	40

int  PDUformat_buffer (type, buffer)
  int	type;			/* i - buffer type */
  MEMptr	*buffer;		/* o - buffer for macro values */
  {
  int	sts = PDM_S_SUCCESS;	/* return status */
  int	i;			/* loop index */
  int	columns = 0;		/* number of columns */
  char	*names[BUFFER_COLS];	/* column names for buffer */
  char	*types[BUFFER_COLS];	/* data types for buffer */

  _pdm_debug("In the function PDUformat_buffer", 0);

  switch ( type )
     {
     case PDU_REPORT_ATTACH:
	  /* open attach buffer  */
	  sts = PDMopen_buffer(2, buffer);
	  _pdm_status("PDMopen_buffer (attach buffer for check in)", sts);

	  return (sts);
	  /*break;				APOGEE */

     case PDU_REPORT_CHECKIN:
	  sts = PDMopen_buffer(1, buffer);
	  _pdm_status("PDMopen_buffer( child buffer for check in)", sts);

	  return (sts);
	  /*break;				APOGEE */

     case PDU_IN_ATTR:
          /* open buffer for search and sort criteria */
          sts = MEMopen(buffer, 512);
          _pdm_status("MEMopen (buffer for search and sort criteria, size = 512)", sts);
          break;

     case PDU_SEARCH_SORT:
          /* open buffer for attribute names */
          sts = MEMopen(buffer, 512);
          _pdm_status("MEMopen (buffer for attribute names, size = 512)", sts);
          break;

     case PDU_FILE_BUFFER:
          /* open buffer for attribute names */
          sts = MEMopen(buffer, 512);
          _pdm_status("MEMopen (buffer for files to delete, size = 512)", sts);
          break;

     case PDU_REPORT_PARTSPEC:
	  /* open macro part buffer  */
	  sts = MEMopen(buffer, 512);
	  _pdm_status("MEMopen (macro part buffer, size = 512)", sts);
	  break;

     case PDU_REPORT_LIST:
	  /* open parameter values buffer  */
	  sts = MEMopen(buffer, 1024);
	  _pdm_status("MEMopen (parameter values buffer, size = 1024)", sts);
	  break;

     case PDU_ASSY_PARTS:
	  /* open parameter values buffer  */
	  sts = MEMopen(buffer, 1024);
	  _pdm_status("MEMopen (assembly part buffer, size = 1024)", sts);
	  break;

     case PDU_ASSY_STRUCT:
	  /* open parameter values buffer  */
	  sts = MEMopen(buffer, 1024);
	  _pdm_status("MEMopen (assembly structure buffer, size = 1024)", sts);
	  break;

     case PDU_CHILD_BUFR:
	  /* open parameter values buffer  */
	  sts = MEMopen(buffer, 1024);
	  _pdm_status("MEMopen (nongraphic assembly structure buffer, size = 1024)", sts);
	  break;

     case PDU_CAT_ATTR:
          /* open parameter values buffer  */
          sts = MEMopen(buffer, 1024);
          _pdm_status("MEMopen (catalog attr bufr, size = 1024)", sts);
          break;

     case PDU_SAVE_CRITERIA:
          /* open parameter values buffer  */
          sts = MEMopen(buffer, 1024);
          _pdm_status("MEMopen (catalog attr bufr, size = 1024)", sts);
          break;

     case PDU_PART_FILE_BUFFER:
          /* open parameter values buffer  */
          sts = MEMopen(buffer, 1024);
          _pdm_status("MEMopen (part_file_buffer, size = 1024)", sts);
          break;

     case PDU_PARTS_LIST_BUFFER:
          /* open parameter values buffer  */
          sts = MEMopen(buffer, 1024);
          _pdm_status("MEMopen (parts_list_buffer, size = 1024)", sts);
          break;

     case PDU_ADD_FILE_BUFFER:
          /* open parameter values buffer  */
          sts = MEMopen(buffer, 1024);
          _pdm_status("MEMopen (add_file_buffer, size = 1024)", sts);
          break;

     case PDU_PARTS_MCF_BUFFER:
          /* open parameter values buffer  */
          sts = MEMopen(buffer, 1024);
          _pdm_status("MEMopen (parts_list_buffer, size = 1024)", sts);
          break;

     case PDU_STATES_BUFFER:
          /* open parameter values buffer  */
          sts = MEMopen(buffer, 1024);
          _pdm_status("MEMopen (parts_list_buffer, size = 1024)", sts);
          break;

     case PDU_ASSY_BUFR:
          /* open parameter values buffer  */
          sts = MEMopen(buffer, 1024);
          _pdm_status("MEMopen (parts_list_buffer, size = 1024)", sts);
          break;

     default:
	  break;
     }

  if ( sts != MEM_S_SUCCESS )
     sts = PDM_E_OPEN_BUFFER;
  else
     sts = PDM_S_SUCCESS;

  /* format buffer */
  if ( 1&sts )
     {
     /* set up arrays of column names and data types */
     switch ( type )
	{
	case PDU_REPORT_ATTACH:
	     names[0] = "p_seqno";
	     types[0] = "integer";
	     names[1] = "p_catalogname";
	     types[1] = "char(30)";
	     names[2] = "p_partnum";
	     types[2] = "char(30)";
	     names[3] = "p_revision";
	     types[3] = "char(30)";

	     columns = PDU_ATTACH_COLS;
	     break;

	case PDU_REPORT_CHECKIN:
	     columns = PDU_CHECKIN_COLS;
	     break;

	case PDU_REPORT_PARTSPEC:
	     names[0] = "p_catalogname";
	     types[0] = "char(30)";
/*
	     names[1] = "p_partnum";
	     types[1] = "char(30)";
	     names[2] = "p_revision";
	     types[2] = "char(30)";
             names[3] = "p_childno";
	     types[3] = "char(20)";
*/
	     columns = 1;
	     break;

        case PDU_FILE_BUFFER:
             names[0] = "n_catalogno";
             types[0] = "char(20)";
             names[1] = "n_itemno";
             types[1] = "char(15)";
             names[2] = "n_catalogname";
             types[2] = "char(150)";
             names[3] = "n_itemname";
             types[3] = "char(150)";
             names[4] = "n_itemrev";
             types[4] = "char(150)";
             names[5] = "n_cofilename";
             types[5] = "char(15)";
             names[6] = "p_parttype";
             types[6] = "char(2)";
             names[7] = "p_action";
             types[7] = "char(20)";
             columns = 8;
             break;

        case PDU_ASSY_PARTS:
             names[0] = "p_catalogname";
             types[0] = "char(20)";
             names[1] = "p_partnum";
             types[1] = "char(15)";
             names[2] = "p_revision";
             types[2] = "char(15)";
             names[3] = "p_partdesc";
             types[3] = "char(40)";
             names[4] = "p_usageid";
             types[4] = "char(40)";
             columns = 5;
             break;

        case PDU_ASSY_STRUCT:
             names[0] = "p_level";
             types[0] = "integer";
             names[1] = "p_pchildno";
             types[1] = "integer";
             names[2] = "p_childno";
             types[2] = "integer";
             names[3] = "n_catalogname";
             types[3] = "char(40)";
             names[4] = "n_itemname";
             types[4] = "char(40)";
             names[5] = "n_itemrev";
             types[5] = "char(40)";
             names[6] = "n_itemdesc";
             types[6] = "char(40)";
             names[7] = "p_attached";
             types[7] = "char(1)";
             names[8] = "p_quantity";
             types[8] = "char(40)";
             names[9] = "p_usageid";
             types[9] = "char(140)";
             names[10] = "n_cofilename";
             types[10] = "char(14)";
             columns = 11;
             break;

        case PDU_CHILD_BUFR:
             names[0] = "p_childno";
             types[0] = "integer";
             names[1] = "n_catalogname";
             types[1] = "char(40)";
             names[2] = "n_itemname";
             types[2] = "char(240)";
             names[3] = "n_itemrev";
             types[3] = "char(40)";
             names[4] = "p_attached";
             types[4] = "char(1)";
             names[5] = "p_quantity";
             types[5] = "char(40)";
             names[6] = "p_usageid";
             types[6] = "char(25)";
             names[7] = "p_tagno";
             types[7] = "char(25)";
             names[8] = "p_alttagno";
             types[8] = "char(40)";
             names[9] = "p_incbom";
             types[9] = "char(1)";
             names[10] = "p_incstr";
             types[10] = "char(1)";
             names[11] = "p_explode";
             types[11] = "char(1)";
             names[12] = "n_cofilename";
             types[12] = "char(14)";
             names[13] = "p_history";
             types[13] = "char(160)";
             names[14] = "n_catalogno";
             types[14] = "integer";
             names[15] = "n_itemno";
             types[15] = "integer";
             names[16] = "n_level";
             types[16] = "integer";
             columns = 17;
             break;

        case PDU_SEARCH_SORT:
             names[0] = "loc_search";
             types[0] = "char(200)";
             names[1] = "loc_sort";
             types[1] = "char(200)";
             names[2] = "cat_search";
             types[2] = "char(500)";
             names[3] = "cat_sort";
             types[3] = "char(500)";
             columns = 4;
             break;

        case PDU_IN_ATTR:
             names[0] = "n_nfmname";
             types[0] = "char(20)";
             columns = 1;
             break;

	case PDU_REPORT_LIST:
	     names[0] = "coord_sys";
	     types[0] = "char(2)";
	     names[1] = "d";
	     types[1] = "double";
	     names[2] = "tw";
	     types[2] = "double";
	     names[3] = "bf";
	     types[3] = "double";
	     names[4] = "tf";
	     types[4] = "double";
	     names[5] = "k";
	     types[5] = "double";
	     names[6] = "interference";
	     types[6] = "char(2)";
	     names[7] = "schematic";
	     types[7] = "char(2)";
	     names[8] = "without_fillet";
	     types[8] = "char(2)";
	     names[9] = "with_fillet";
	     types[9] = "char(2)";
	     names[10] = "without_names";
	     types[10] = "char(2)";
	     names[11] = "with_names";
	     types[11] = "char(2)";

	     columns = 12;
	     break;

        case PDU_CAT_ATTR:
             names[0] = "n_name";
             types[0] = "char(20)";
             names[1] = "n_synonym";
             types[1] = "char(40)";
             names[2] = "n_datatype";
             types[2] = "char(15)";
             columns = 3;
             break;

        case PDU_SAVE_CRITERIA:
             names[0] = "select";
             types[0] = "char(20)";
             names[1] = "from";
             types[1] = "char(20)";
             names[2] = "where";
             types[2] = "char(200)";
             names[3] = "orderby";
             types[3] = "char(200)";
             names[4] = "prompts";
             types[4] = "char(20)";
             columns = 5;
             break;

        case PDU_PART_FILE_BUFFER:
             names[0] = "n_catalogname";
             types[0] = "char(20)";
             names[1] = "n_itemname";
             types[1] = "char(40)";
             names[2] = "n_itemrev";
             types[2] = "char(40)";
             names[3] = "n_itemdesc";
             types[3] = "char(40)";
             names[4] = "n_cofilename";
             types[4] = "char(15)";
             columns = 5;
             break;

        case PDU_PARTS_LIST_BUFFER:
             names[0] = "p_level";
             types[0] = "integer";
             names[1] = "n_catalogname";
             types[1] = "char(20)";
             names[2] = "n_itemname";
             types[2] = "char(100)";
             names[3] = "n_itemrev";
             types[3] = "char(100)";
             names[4] = "n_cofilename";
             types[4] = "char(100)";
             names[5] = "p_attached";
             types[5] = "char(2)";
             names[6] = "p_quantity";
             types[6] = "char(32)";
             names[7] = "p_usageid";
             types[7] = "char(25)";
             columns = 8;
             break;

        case PDU_ADD_FILE_BUFFER:
             names[0] = "n_filenum";
             types[0] = "integer";
             names[1] = "n_cofilename";
             types[1] = "char(14)";
             names[2] = "n_filetype";
             types[2] = "char(5)";
             names[3] = "n_cisaname";
             types[3] = "char(30)";
             names[4] = "n_cifilename";
             types[4] = "char(14)";
             names[5] = "n_cosano";
             types[5] = "integer";
             names[6] = "n_couser";
             types[6] = "char(14)";
             names[7] = "p_filedesc";
             types[7] = "char(40)";
             columns = 8;
             break;

        case PDU_PARTS_MCF_BUFFER:
             names[0] = "n_catalogname";
             types[0] = "char(20)";
             names[1] = "n_itemname";
             types[1] = "char(40)";
             names[2] = "n_itemrev";
             types[2] = "char(40)";
             names[3] = "n_itemdesc";
             types[3] = "char(40)";
             names[4] = "n_filetype";
             types[4] = "char(5)";
             names[5] = "n_cofilename";
             types[5] = "char(15)";
             names[6] = "p_local";
             types[6] = "char(120)";
             names[7] = "n_statename";
             types[7] = "char(40)";
             names[8] = "p_update";
             types[8] = "char(3)";
             names[9] = "p_parttype";
             types[9] = "char(2)";
             columns = 10;
             break;

        case PDU_STATES_BUFFER:
             names[0] = "n_statename";
             types[0] = "char(41)";
             names[1] = "n_stateno";
             types[1] = "integer";
             names[2] = "n_transitionname";
             types[2] = "char(128)";
             names[3] = "n_status";
             types[3] = "char(20)";
             columns = 4;
             break;

        case PDU_ASSY_BUFR:
             names[0] = "ex_level";
             types[0] = "integer";
             names[1] = "ex_catalog";
             types[1] = "char(20)";
             names[2] = "ex_partid";
             types[2] = "char(240)";
             names[3] = "ex_revision";
             types[3] = "char(40)";
             names[4] = "ex_description";
             types[4] = "char(40)";
             names[5] = "ex_cofilename";
             types[5] = "char(15)";
             names[6] = "ex_parttype";
             types[6] = "char(3)";
             names[7] = "p_level";
             types[7] = "integer";
             names[8] = "p_pchildno";
             types[8] = "integer";
             names[9] = "p_childno";
             types[9] = "integer";
             names[10] = "p_attached";
             types[10] = "char(40)";
             names[11] = "p_quantity";
             types[11] = "char(40)";
             names[12] = "p_usageid";
             types[12] = "char(25)";
             names[13] = "p_tagno";
             types[13] = "char(25)";
             names[14] = "p_alttagno";
             types[14] = "char(40)";
             names[15] = "p_incbom";
             types[15] = "char(1)";
             names[16] = "p_incstr";
             types[16] = "char(1)";
             names[17] = "p_explode";
             types[17] = "char(1)";
             names[18] = "p_history";
             types[18] = "char(160)";
             names[19] = "n_catalogno";
             types[19] = "integer";
             names[20] = "n_itemno";
             types[20] = "integer";
             names[21] = "new_level";
             types[21] = "integer";
             names[22] = "new_catalog";
             types[22] = "char(40)";
             names[23] = "new_partid";
             types[23] = "char(240)";
             names[24] = "new_revision";
             types[24] = "char(40)";
             names[25] = "new_description";
             types[25] = "char(40)";
             names[26] = "new_cofilename";
             types[26] = "char(15)";
             names[27] = "new_cifilename";
             types[27] = "char(15)";
             names[28] = "new_parttype";
             types[28] = "char(3)";
             names[29] = "new_usageid";
             types[29] = "char(25)";
             names[30] = "delete";
             types[30] = "char(2)";
             names[31] = "ems_reffile";
             types[31] = "char(2)";
             names[32] = "add";
             types[32] = "char(2)";
             names[33] = "display";
             types[33] = "char(2)";
             names[34] = "add_db";
             types[34] = "char(2)";
             names[35] = "mcf_row";
             types[35] = "integer";
             columns = 36;
             break;

	default:
	     break;
	}

     for ( i = 0; i < columns; i = i+1 )
	 {
	 if ( 1&sts )
	    {
	    /* write buffer format */
	    sts = MEMwrite_format(*buffer, names[i], types[i]);
	    _pdm_status("MEMwrite_format ()", sts);

	    if ( sts != MEM_S_SUCCESS )
	       sts = PDM_E_WRITE_FORMAT;
	    else
	       sts = PDM_S_SUCCESS;
	    }
	 }
     }

  return(sts);
  }

int  PDUdealloc (variable)
  char  **variable;
  {
  if ( *variable != NULL )
     {
     free(*variable);
     *variable = NULL;
     }
 
  return (PDM_S_SUCCESS);
  }

int     PDUstrcpy (variable, value)
char    **variable;
char    *value;
  {
 
  if (( *variable != NULL ) && ( strcmp(*variable, "")) )
     {
     free (*variable);
     *variable = NULL;
     }
 
  /*if ( (value != NULL) && strcmp(value, NULLSTR) )*/
  if (value != NULL)
     {
     *variable = (char *) malloc ( strlen(value) + 1);
     strcpy (*variable, value);
     }
 
  return ( PDM_S_SUCCESS );
  }
int	PDUset_debug (env_var, on_off_flag)
  char	*env_var;
  short	on_off_flag;
  {
  char	*debug_set, *(getenv) ();
  extern int	PDM_debug_on;

  /* set debug mode */
  if ( env_var )
     {
     /* get debug mode from environment */
     debug_set = getenv(env_var);

     if ( debug_set )
	PDM_debug_on = TRUE;
     else
	PDM_debug_on = FALSE;
     }
  else
     {
     /* use debug mode parameter */
     PDM_debug_on = on_off_flag;
     }

  return ( PDM_S_SUCCESS );
  }

/****************************************************************************

Document:	PDUwork_controller

Description:
	This function provides external support to the PDU commands for
	work flow.  It sends information from the review
	refresh partspec and command string to initialize the work
	flow, to the server.

Algoritm:
	1. Prefix PDM to the command string to make the work flow string.
	2. Call PDMvalidate_user_access function to validate the users access
	   with the current command and workflow.


Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	Error status returned from PDMvalidate_user_
				access.
Notes:

History:
	11/02/89	Lynn Mettlen	Created
	01/02/90	Lynn Mettlen	Modified

*****************************************************************************/

 int  PDUwork_controller ( command_string )
  char	*command_string;
  {
  int	status = PDM_S_SUCCESS;
  char	wkfl_com_string[100];
  long       checkstatus;
  _pdm_debug("In PDUwork_controller function, command_string %s", command_string);

  switch ( refresh->command )
     {
       case PDC_M_CREATE_CATALOG:
       case PDC_M_CREATE_LIKE_CATALOG:
  	status = PDMvalidate_user_access ( "Create Catalog", NULLSTR, 
			refresh->rev_catalog, refresh->rev_project, 
                         refresh->rev_partid, 
			refresh->rev_revision );
  	_pdm_status ("PDMvalidate_user_access", status);
       break;

       case PDC_M_MODIFY_CATALOG:
  	status = PDMvalidate_user_access ( "Change Catalog", NULLSTR, 
			refresh->rev_catalog, NULLSTR, refresh->rev_partid, 
			refresh->rev_revision );
  	_pdm_status ("PDMvalidate_user_access", status);
       break;

       case PDC_M_DELETE_CATALOG:
  	status = PDMvalidate_user_access ( "Delete Catalog", NULLSTR, 
			refresh->rev_catalog, NULLSTR, refresh->rev_partid, 
			refresh->rev_revision );
  	_pdm_status ("PDMvalidate_user_access", status);
       break;

       case PDC_M_MODIFY_USER_PASSWORD:
  	status = PDMvalidate_user_access ( command_string, NULLSTR, 
			refresh->rev_catalog, NULLSTR, refresh->rev_partid, 
			refresh->rev_revision );
  	_pdm_status ("PDMvalidate_user_access", status);
       break;


       default:
        if (refresh->command == PDC_M_BOM_SUMMARY_BOM)
          strcpy(wkfl_com_string, "PDMCreate BOM Summary");
        else
          {
  	  strcpy ( wkfl_com_string, "PDM" );
  	  strcat ( wkfl_com_string, command_string);
          }
	if (((refresh->command == PDC_M_ADD_PART_PROJ) ||
              (refresh->command == PDC_M_CREATE_LIKE_PART)) &&
	     (refresh->rev_project != NULL))
           {
  	   status = PDMvalidate_user_access ( wkfl_com_string,
			NULLSTR, refresh->rev_catalog,
			refresh->rev_project, refresh->rev_partid,
                        refresh->rev_revision);
           }
         else if ((refresh->command == PDC_M_CREATE_ELEMENT) &&
                 (PDU_validate_access == TRUE)) 
           {
           if (new_mode)
             {
             status = PDMvalidate_user_access ( wkfl_com_string,
			NULLSTR, refresh->rev_catalog,
			refresh->rev_project, NULLSTR, NULLSTR );
             }
           if (similar_mode)
             {
             status = PDMvalidate_user_access ( wkfl_com_string,
			NULLSTR, refresh->new_catalog,
                        refresh->new_project, refresh->new_partid,
                        refresh->new_revision );
             }
           }
          else if ((refresh->command == PDC_M_CREATE_ELEMENT) &&
                  (PDU_validate_access == FALSE))
             status = PDM_S_SUCCESS;
          else if ((refresh->command != PDC_M_CHECKIN) &&
                   (refresh->command != PDC_M_CHECKOUT) &&
                   (refresh->command != PDC_M_COPY))
           {
     	    status = PDMvalidate_user_access ( wkfl_com_string,
			NULLSTR, refresh->rev_catalog,
			NULLSTR, refresh->rev_partid, refresh->rev_revision );
       	    _pdm_status ("PDMvalidate_user_access", status);
            _pdm_debug("Default case ", 0);
            if ((status != PDM_S_SUCCESS) && 
                (
                /*(refresh->command == PDC_M_CHECKIN) ||*/
                /*(refresh->command == PDC_M_CHECKOUT) ||*/
                (refresh->command == PDC_M_CHECKOUT_UPDATE)
                /*(refresh->command == PDC_M_COPY)*/
                ))
               {
               checkstatus = PDMcheck_item 
                        (
                        refresh->rev_catalog,refresh->rev_partid,
                        refresh->rev_revision,refresh->command,
                        user->username
                        );

  	       _pdm_status ("PDMcheck_item", checkstatus);
               if (checkstatus != PDM_S_SUCCESS)
                  status = checkstatus;
               }
            }
        
       	_pdm_status ("PDMvalidate_user_access", status);
        break;
       }
  return ( status );
  }

int PDUvalidate_api_data_value(attr_text1, attr_value, attr_buffer, list_buffer)

char *attr_text1;
char *attr_value;
MEMptr attr_buffer;
MEMptr list_buffer;

  {
  int status;
  int i;
  int buffer_number = 0;
  int attr_num;
  int min_num;
  int max_num;
  int FOUND = FALSE;
  double real_num, real_max, real_min;
  double doub_num, doub_max, doub_min;
  char **attr_data = NULL;
  char **list_data = NULL;
  char **list_col = NULL;
  char *datatype = NULL;
  char *attr_name = NULL;
  char *attr_text = NULL;
  char *str = NULL;
  char *function_name = NULL;

  _pdm_debug("In PDUvalidate_data_value", 0);

  _pdm_debug("Attribute text is <%s>", attr_text);
  _pdm_debug("Attribute value is <%s>", attr_value);
  if (PDM_debug_on)
    {
    MEMprint_buffer("attribute buffer", attr_buffer, PDU_DEBUG_FILE);
    MEMprint_buffers("list buffer", list_buffer, PDU_DEBUG_FILE);
    }

  status = MEMbuild_array(attr_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **)attr_buffer->data_ptr;

  /* strip off * if there is one */
  PDUfill_in_string(&attr_text, attr_text1);
  if (attr_text[0] == '*') 
    attr_text = attr_text + 1;
  else 
    {
     str = strstr(attr_text, "(min:");

     if (str)
        {
        *((char *) strstr(attr_text, "(min:")) = '\0';
        *((char *) strrchr(attr_text, ' ')) = '\0';
        }
    }

  for (i = 0; i < attr_buffer->rows; i ++)
    {
     if (strcmp(attr_data[(attr_buffer->columns * i) + PDU_NFM_SYN_COL], 
         attr_text) == 0)
       {
       PDUfill_in_string(&attr_name, attr_data[(attr_buffer->columns * i) +
                         PDU_NFM_ATTR_COL]);
       PDUfill_in_string(&datatype, attr_data[(attr_buffer->columns * i)
                         + PDU_NFM_DATA_COL]);
       sscanf(attr_data[(attr_buffer->columns * i) + PDU_NFM_LISTNO_COL],
                        "%d", &buffer_number);
       break;
       }
     else if (strcmp(attr_data[(attr_buffer->columns * i) + PDU_NFM_ATTR_COL], 
              attr_text) == 0)
       {
       PDUfill_in_string(&attr_name, attr_text);
       PDUfill_in_string(&datatype, attr_data[(attr_buffer->columns * i)
                         + PDU_NFM_DATA_COL]);
       sscanf(attr_data[(attr_buffer->columns * i) + PDU_NFM_LISTNO_COL],
                        "%d", &buffer_number);
       break;
       }
     }

     if ((strcmp(attr_value, "") == 0) && (strcmp(attr_name, PDU_MAXLEVEL_ATTR)
         == 0))
        return(PDM_E_AT_MAXLEVEL);
     else if (strcmp(attr_value, "") == 0)
        return(PDM_S_SUCCESS);

     status = PDUvalidate_value(attr_value, datatype);
     _pdm_status("PDUvalidate_value", status);

     if (status != PDM_S_SUCCESS)
       return(status);

     if (buffer_number > 0)
       {
       /* check and see if what kind of list */
       _pdm_debug("buffer_number = <%d>", (char *)buffer_number);
       status = MEMreset_buffer_no(list_buffer, buffer_number);
       _pdm_status("MEMreset_buffer_no", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_RESET_BUFFER);
       
       list_data = (char **)list_buffer->data_ptr;
       list_col = (char **)list_buffer->column_ptr;

       if (strcmp(list_col[0], "n_value") == 0)
         {
         _pdm_debug("validate value against static list", 0);
         for (i = 0; i < list_buffer->rows; i ++)
           {
         if (strcmp(attr_value, list_data[(list_buffer->columns * i) + 0]) == 0)
             {
             FOUND = TRUE;
             break;
             }
           }
         if (!FOUND)
           status = PDM_E_INVALID_INPUT;
         else 
           status = PDM_S_SUCCESS;
         } 
       else if (strcmp(list_col[0], "n_aclno") == 0)
         {
         _pdm_debug("validate value against static list", 0);
         for (i = 0; i < list_buffer->rows; i ++)
           {
           if (strcmp(attr_value, list_data[list_buffer->columns * i]) == 0)
             {
             FOUND = TRUE;
             break;
             }
           }
         if (!FOUND)
           {
           _pdm_debug("Please enter a value in the list", 0);
           status = PDM_E_INVALID_INPUT;
           }
         else 
           status = PDM_S_SUCCESS;
         } 
       else if ((strcmp(datatype, "integer") == 0) || (strcmp(datatype,
                 "smallint") == 0))
         {
           sscanf(list_data[1], "%d", &min_num);
           sscanf(list_data[2], "%d", &max_num);
           sscanf(attr_value, "%d", &attr_num);
           if ((strcmp(list_data[1], "") == 0) && (attr_num > max_num))
             {
             _pdm_debug("Please enter a value less than the upper bound", 0);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[1], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((strcmp(list_data[2], "") == 0) && (attr_num < min_num))
             {
             _pdm_debug("Please enter a value greater than the lower bound", 0);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[2], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((attr_num > max_num) || (attr_num < min_num))
             {
             _pdm_debug("Please enter a value between lower and upper bound",0);
             status = PDM_E_INVALID_INPUT;
             }
           else
             status = PDM_S_SUCCESS;
         }
       else if (strcmp(datatype, "real") == 0)
         {
           sscanf(list_data[1], "%lf", &real_min);
           sscanf(list_data[2], "%lf", &real_max);
           sscanf(attr_value, "%lf", &real_num);
           if ((strcmp(list_data[1], "") == 0) && (real_num > real_max))
             {
             _pdm_debug("Please enter a value less than the upper bound", 0);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[1], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((strcmp(list_data[2], "") == 0) && (real_num < real_min))
             {
             _pdm_debug("Please enter a value greater than the lower bound", 0);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[2], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((real_num > real_max) || (real_num < real_min))
             {
             _pdm_debug("Please enter a value between lower and upper bound");
             status = PDM_E_INVALID_INPUT;
             }
           else
             status = PDM_S_SUCCESS;
         }
       else
         {
           sscanf(list_data[1], "%lf", &doub_min);
           sscanf(list_data[2], "%lf", &doub_max);
           sscanf(attr_value, "%lf", &doub_num);
           if ((strcmp(list_data[1], "") == 0) && (doub_num > doub_max))
             {
             _pdm_debug("Please enter a value less than the upper bound", 0);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[1], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((strcmp(list_data[2], "") == 0) && (doub_num < doub_min))
             {
             _pdm_debug("Please enter a value greater than the lower bound", 0);
             status = PDM_E_INVALID_INPUT;
             }
           else if (strcmp(list_data[2], "") == 0)
             status = PDM_S_SUCCESS;
           else if ((doub_num > doub_max) || (doub_num < doub_min))
             {
             _pdm_debug("Please enter a value between lower and upper bound");
             status = PDM_E_INVALID_INPUT;
             }
           else
             status = PDM_S_SUCCESS;
         }
       }
   else if (PDU_func_buffer)
     {
     status = PDUcheck_for_function(attr_name, &function_name, PDU_func_buffer);
     _pdm_status("PDUcheck_for_function", status);

     if (status == PDM_S_SUCCESS)
       status = PDM_E_FAILURE; 
     else
       status = PDM_S_SUCCESS;
      }
   return(status);
   }

int PDUcheck_for_function(attr_name, func_name, func_buffer)

  char *attr_name;
  char **func_name;
  MEMptr func_buffer;

  {
  int status;
  int i;
  int FOUND;
  char **func_data = NULL;

  _pdm_debug("In PDUcheck_for_function", 0);

  if (func_buffer == NULL)
    return(0);

  status = MEMbuild_array(func_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(status);

  func_data = (char **)func_buffer->data_ptr;

  FOUND = FALSE;
  _pdm_debug("before for loop", 0);
  for (i = 0; i < func_buffer->rows; i++)
   {
   _pdm_debug("attr_name = <%s>", attr_name);
   if (strcmp(attr_name, func_data[(func_buffer->columns * i) + 0]) == 0)
     {
     FOUND = TRUE;
     if ((func_buffer->columns == 3) && (func_data[(func_buffer->columns * i) +
          2]) && (strcmp(func_data[(func_buffer->columns * i) + 2], "") != 0))
       PDUfill_in_string(func_name, func_data[(func_buffer->columns * i) 
                       + 2]);
     else
       PDUfill_in_string(func_name, func_data[(func_buffer->columns * i) 
                       + 1]);
     _pdm_debug("function name = <%s>", *func_name);
     break;
     }
    }

  if (!FOUND)
    return(PDM_E_FAILURE);
  return(PDM_S_SUCCESS);
  }


/*
 * This function determines if a part placement is cyclic.
 */
int PDUis_cyclic_placement(
                              catalog,        /* INPUT */
                              number,         /* INPUT */
                              revision,       /* INPUT */
                              asm_struct_bufr /* OUTPUT */
                             )
 char        *catalog;
 char        *number;
 char        *revision;
 MEMptr         *asm_struct_bufr;
 {
  int        status;
  int        i;
  int        cat_col;
  int        part_col;
  int        rev_col;
  char       **row_data = NULL;

  extern char *PDU_incl_ASM;


  _pdm_debug("In the PDUis_cyclic_placement function", 0);


  /* Check to see if part is placed in itself */
  if ( (strcmp(catalog, refresh->act_catalog) == 0) &&
       (strcmp(number, refresh->act_partid) == 0) &&
       (strcmp(revision, refresh->act_revision) == 0) &&
       (strcmp(PDU_incl_ASM, "Y") == 0) )
       {
        _pdm_debug("an attempt to place a part into itself", 0);
        return(1);
       }

  /* Check nth-cyclic placement */
  status = PDMget_assembly_structure(
                                     catalog,
                                     number,
                                     revision,
                                     MAX_LEVEL,
                                     asm_struct_bufr,
                                     1
                                    );
  _pdm_status("PDMget_assembly_structure", status);

  if (*asm_struct_bufr)
     {
      if ((*asm_struct_bufr)->rows == 1)
         {
          _pdm_debug("part is atomic", 0);
          
          return(0);
         }

      else if ((*asm_struct_bufr)->rows > 1)
          {
           /* Check if placement is background */
           if (strcmp(PDU_incl_ASM, "Y") != 0)
              {
               _pdm_debug("background placement of assembly");
               return(0);
              }

           MEMbuild_array(*asm_struct_bufr);
           PDUsetup_buffer(
                           *asm_struct_bufr,
                           ROW,
                           &row_data
                          );

           /* Extract catalog name column no */
           PDUget_buffer_col(
                             *asm_struct_bufr,
                             "n_catalogname",
                             &cat_col
                            );

           /* Extract part column no */
           PDUget_buffer_col(
                             *asm_struct_bufr,
                             "n_itemname",
                             &part_col
                            );

           /* Extract part revision column no */
           PDUget_buffer_col(
                             *asm_struct_bufr,
                             "n_itemrev",
                             &rev_col
                            );

           for (i = 1; i < (*asm_struct_bufr)->rows; ++i)
               {
                if ( (strcmp(refresh->act_catalog,
                     row_data[((*asm_struct_bufr)->columns*i)+cat_col]) == 0) &&
                     (strcmp(refresh->act_partid,
                     row_data[((*asm_struct_bufr)->columns*i)+part_col])== 0) &&
                     (strcmp(refresh->act_revision,
                     row_data[((*asm_struct_bufr)->columns*i)+rev_col]) == 0) )
                     {
                      _pdm_debug("nth-level cyclic placement detected", 0);
                      
                      return(1);
                     }

               } /* end for i loop */
          }

      else 
          {
           _pdm_debug("SEVERE error: No rows found in asm_struct_bufr", 0);
           return(-1);
          }
     }

  else
      {
       _pdm_debug("SEVERE error: asm_struct_bufr is empty", 0);
       return(-1);
      }

  return(0);
 }
