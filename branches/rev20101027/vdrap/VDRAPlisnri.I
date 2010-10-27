/* $Id: VDRAPlisnri.I,v 1.8 2001/06/06 16:38:36 hans Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrap / VDRAPlisnri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDRAPlisnri.I,v $
 *	Revision 1.8  2001/06/06 16:38:36  hans
 *	Fix for TR#5210 - Start/Stop record not working if ISDP_JOURNAL is not set.
 *	
 *	Revision 1.7  2001/03/06 19:48:29  hans
 *	Updated
 *	
 *	Revision 1.6  2001/03/06 15:11:16  hans
 *	Append to file if less than 12H old.
 *	
 *	Revision 1.5  2001/03/05 19:03:53  hans
 *	Updated
 *	
 *	Revision 1.4  2001/03/05 15:45:27  hans
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/03/03 19:34:36  hans
 *	Header Section
 *	
 *	Revision 1.2  2001/03/02 23:33:50  hans
 *	Enable/Disable Verbose Journalling
 *	
 *	Revision 1.1  2001/03/02 22:55:49  hans
 *	Created
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *	03/02/2001	HF		Creation
 *					Adapted from GRNUC "start and record"
 *
 *	06/06/2001	HF		TR#5210
 *					Make sure start/stop works normally if
 *					ISDP_JOURNAL is NOT set...
 * -------------------------------------------------------------------*/
/*
Name
   VDRAPlisnri.I

Description
   This file contains functions and methods to implement the record and
   playback system.  The RAP code consists of a RAP listener object that
   receives user input and writes it to a .u file.  During a design session,
   the listener object is sent a listen message after an event is taken from
   the front of the software queue and before the event is passed to the exec.
   If record is on, the RAP listener determines what event type has been
   intercepted, and writes the event out to a .u file.  The format includes
   the ci macro, ci$put, followed by a command key, string, data point, form
   event, or other event to be put on the software queue at playback time.
   After the ppl file has been generated during a record session, the user
   must process it with ci as with any other file.

Notes

History
   12/31/91 : Tim : changed ifdef sparc to ifdef NEVER_DEF for sprintf
                    statements that were changed for use with sun's
                    /usr/include.  Now that we are using /usr/5include, it is
                    no longer needed.
   01/29/92 : rlw : Modified the formListen method not to output anything
                    to the .u file when picks are made on pallettes or
                    menus (bar,panel).
   01/31/92 : rlw : Modified to write out the x, y, and z coordinates for
                    resets since the sketch command depends on these values.
   02/18/92 : mrm : Modified the formListen method so that it is not dependent
                    on the menu names.
   06/23/92 : scw : Added static ANSI C prototypes.
   07/10/92 : dhm : ANSI conversion.
   12/16/92 : Tim : here we go again - changed NEVER_DEF to SUNOS because
                    ansi c uses the Berkley style sprintf
   12/30/92 : mrm : modified form definitions and structs to use exfi.h
   01/26/93 : dhm : TR 119300163 - Write commands out by cmd_key and not by
                    string.
   02/26/93 : dhm : TR 119301475 - fixed sprintf to work no matter what
                    compiler or libraries are used.
   03/09/93 : dhm : TR 119302401 - made stop record a shutdown and added the
                    flag remove_last_command_flag.
   03/11/93 : dhm : TR 119302736 - fixed the handling of arguments in a string.
   05/18/93 : dhm : TR 11925530 - fixed the deletion of characters in function,
                    RAP_get_keyboard_data.
   05/20/93 : dhm : TR 11914212 - fixed the "^F" font sequence problem in
                    function, RAP_get_keyboard_data.
   05/24/93 : dhm : TR 11900860 - fixed handling the control sequences in
                    placing text.
   06/09/93 : dhm : TR 11913881 - fixed handling of the EXDfInGn command.
   06/17/93 : dhm : TR 119222997 - fixed handling of deletion of characters
                    after placing text.
*/

class implementation VDRAPlisnr;

#include <stdio.h>
#include <time.h>
#include <sys/utsname.h>
#include <limits.h>

#include "VDRAPdefs.h"
#include "exmacros.h"
#include "exdef.h"
#include "ex.h"
#include "msdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "exfi.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "OMminimum.h"
#include "OMtypes.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "madef.h"
#include "igewindef.h"

#define BUTTON_EVENT	0
#define STRING_EVENT	1
#define RECORD_ON	1
#define RECORD_OFF	0

#ifndef DBL_DIG
#define DBL_DIG      15
#endif

typedef char *Form;

extern char EX_version[];
extern char EX_date[];

static FILE *my_global_file_ptr;
static short check_for_string;
static char  global_argument[80];

static int   enable_print;

%safe
  static short flag                     = RECORD_ON;
  static short flag_string_record       = RECORD_ON;
  static int   last_response            = 1;
  static short remove_last_command_flag = TRUE;
  static short have_global_argument     = FALSE;
  static short place_text_command       = FALSE;
  static short text_has_been_placed     = FALSE;
%endsafe

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static char *GetTime __((void));
static char *GetResponseType __((int response));
static char *GetFIDataType __((int type));
static char *GetFISelectType __((int type));
#ifdef RAP_DEBUG
static void DisplayValues __((int *response, char *response_data,
                              int *num_char, int *ended));
#endif
static void WriteString __((FILE *fp, char *s));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
// Function to enable toggling the value of enable_print (Enable/Disable Verbose Journalling)
// from within a PPL.
// Execute PPL: ci=toggle_verb
//
int toggle_enable_print()
{
  if (enable_print)
  {
    enable_print = 0;
  }
  else
  {
    enable_print = 1;
  }
  return enable_print;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  GetTime

Abstract
  Gets the date and time of day.

Synopsis
  char *GetTime()

Description

Return Value
  returns a character string containing the date and time.

Notes

Index

Keywords
  function, time, RAP

History
  02/17/93 : dhm : documented

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

static char *GetTime()
{
  long       clock;
  struct tm *data;

  clock = time ((long *)0);
  data  = localtime(&clock);

  return(asctime(data));
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  GetResponseType

Abstract
  Given the response returned from the command server, this function will
  return the equivalent of the integer response as a character.

Synopsis
  char *GetResponseType(response)

  response   int   I   the event response returned from the command server

Description

Return Value
  char   *string   the character string that cooresponds to the event response

Notes

Index

Keywords
  function, RAP

History
  02/17/93 : dhm : documented

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

static char *GetResponseType(int response)
{
  static char returnValue[32];

  switch (response)
  {
    case COMMAND:          return("COMMAND");
    case DATA:             return("DATA");
    case RESET:            return("RESET");
    case D_COMMAND:        return("D_COMMAND");
    case D_DATA:           return("D_DATA");
    case D_RESET:          return("D_RESET");
    case HELP:             return("HELP");
    case EXEC:             return("EXEC");
    case STRING:           return("STRING");
    case CMD_STRING:       return("CMD_STRING");
    case ODEN:             return("ODEN");
    case OMPMS:            return("OMPMS");
    case VALUE:            return("VALUE");
    case CHAR:             return("CHAR");
    case STATUS_DISP:      return("STATUS_DISP");
    case CLEAR_STACK:      return("CLEAR_STACK");
    case MOVE_ON:          return("MOVE_ON");
    case TERMINATE:        return("TERMINATE");
    case TOGGLE_COMMAND:   return("TOGGLE_COMMAND");
    case ABS_DIG:          return("ABS_DIG");
    case FORM_FINISHED:    return("FORM_FINISHED");
    case SPECIFIED_OBJ:    return("SPECIFIED_OBJ");
    case EX_RESTART:       return("EX_RESTART");
    case EX_CMD_KEY:       return("EX_CMD_KEY");
    case EX_POCKET:        return("EX_POCKET");
    case EX_CMD_M_STR:     return("EX_CMD_M_STR");
    case EX_CMD_M_KEY:     return("EX_CMD_M_KEY");
    case EX_CMDSVR_RETURN: return("EX_CMDSVR_RETURN");
    case EX_EXIT:          return("EX_EXIT");
    case EX_FORM_DATA:     return("EX_FORM_DATA");
    case EX_WINDOW_CHANGE: return("EX_WINDOW_CHANGE");
    case EX_MAX_RESPONSE:  return("EX_MAX_RESPONSE");
    default:
      sprintf(returnValue,"%d /* UNKNOWN_TYPE */",response);
      return(returnValue);
  } /* switch */
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  GetFIDataType

Abstract
  This function returns the character string equivalent of the form data type

Synopsis
  char *GetFIDataType(type)

  type    int    I     the type of form data

Description

Return Value
  char    *string    the character string equivalent of the form data type

Notes

Index

Keywords
  function, form, RAP

History
  02/17/93 : dhm : documented

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

static char *GetFIDataType(int type)
{
  static char returnValue[32];

  switch (type)
  {
    case EXFI_STATE:     return("EXFI_STATE");
    case EXFI_INT:       return("EXFI_INT");
    case EXFI_DOUBLE:    return("EXFI_DOUBLE");
    case EXFI_ALPHA:     return("EXFI_ALPHA");
    case EXFI_SUBFORM:   return("EXFI_SUBFORM");
    case EXFI_SELECTION: return("EXFI_SELECTION");
    case EXFI_CLEAR:     return("EXFI_CLEAR");
    case EXFI_POINT:     return("EXFI_POINT");
    case 10:             return("10");
    case 11:             return("11");
    case 12:             return("12");
    default:
      sprintf(returnValue,"%d /* UNKNOWN_DATA_TYPE */",type);
      return(returnValue);
  } /* switch */
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  GetFISelectType

Abstract

Synopsis
  char *GetFISelectType(type)

  type    int     I    the form data select type

Description

Return Value
  char    *string    the character string equivalent of the form data
                     select type

Notes

Index

Keywords
  function, form, RAP

History
  02/17/93 : dhm : documented

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

static char *GetFISelectType(int type)
{
  static char returnValue[32];

  switch (type)
  {
    case EXFI_EDIT_NOSELECT: return("EXFI_EDIT_NOSELECT");
    case EXFI_EDIT_SELECT:   return("EXFI_EDIT_SELECT");
    case EXFI_NOTSELECTED:   return("EXFI_NOTSELECTED");
    case EXFI_SELECTED:      return("EXFI_SELECTED");
    default:
      sprintf(returnValue,"%d /* UNKNOWN_SELECT_TYPE */",type);
      return(returnValue);
  } /* switch */
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  DisplayValues

Abstract
  This function is a debugging tool.

Synopsis
  void DisplayValues(response, response_data, num_char, ended)

  response          int      I     event response
  response_data    *char     I     event response data
  num_char          int      I     number of characters in response_data
  ended             int      I

Description

Return Value

Notes

Index

Keywords
  function, RAP

History
  02/17/93 : dhm : documented

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

#ifdef RAP_DEBUG
#include <ctype.h>

static void DisplayValues (int *response, char *response_data, int *num_char, int *ended)
{
  int i;
  char              window_name[32];
  struct EX_button *data;

  printf("\nRAP -- \tResponse = %s\n",GetResponseType(*response));
  printf("RAP -- \tNum_char = %d\n",*num_char);
  switch (*response)
  {
    case STRING:
    case CMD_STRING:
    case CHAR:
    case EX_CMD_KEY:
      printf("RAP -- \t    Data = \"%s\"\n",response_data);
      break;
    case COMMAND:
    case DATA:
    case RESET:
    case D_COMMAND:
    case D_DATA:
    case D_RESET:
      data = (struct EX_button *)response_data;

      printf("RAP -- \t       x = %.0f\n",data->x);
      printf("RAP -- \t       y = %.0f\n",data->y);
      printf("RAP -- \t  button = ");
      switch (data->numb)
      {
        case 0:
          printf("LEFT_BUTTON\n");
          break;
        case 1:
          printf("MIDDLE_BUTTON\n");
          break;
        case 2:
          printf("RIGHT_BUTTON\n");
          break;
        default:
          printf("INVALID_TYPE\n");
      } /* switch */
      printf("RAP -- \twindow # = %ld\n",data->window);

      Inq_win_name(data->window,window_name,32);
      printf("RAP -- \tHardware window name = <%s>\n",window_name);

      printf("RAP -- \tobjid = %ld\n",data->objid);
      printf("RAP -- \tosnum = %ld\n",data->osnum);
      break;
    default:
      printf("RAP -- \t    Data =");
      for (i=0;i<*num_char;i++)
      {
        if (isprint(response_data[i]))
          printf(" %c",response_data[i]);
        else
          printf(" 0x%X",response_data[i]);
      }
      printf("\n");
  }
  printf("RAP -- \t   Ended = %d\n\n",*ended);
}
#endif


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  RAP_suspend_record

Abstract
  This function controls the setting off of the global variable, flag.

Synopsis
  short RAP_suspend_record()

Description
  This function is called during certain events, such as
  PLACE ASCII TEXT FROM FILE.  It sets a flag to off.  The
  flag is checked by the RAP listen method for all input received by
  the RAP listener.  As long as the flag is off, no input is recorded.

Return Value
  short    TRUE    always returns a TRUE value

Notes

Index

Keywords
  function, RAP

History
  02/17/93 : dhm : documented

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

short RAP_suspend_record ()
{
  int     	status;
  OM_S_OBJID 	lisnr_id;

#ifdef RAP_DEBUG
  printf("RAP -- In RAP_suspend_record\n");
#endif

  /* see if the listener object exists */

  status = ex$get_objid_from_NOD(NODname   = NOD_NAME,
                                 objname   = LISTENER_NAME,
                                 pobjid    = &lisnr_id,
                                 modid     = OM_GO_TransOS_0,
                                 mod_osnum = OM_Gw_TransOSnum_0);

  if (status == OM_S_SUCCESS)  /* Disable static, global record flag. */
  {
    flag = RECORD_OFF;
  }

  return TRUE;
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  RAP_resume_record

Abstract
  This function controls the setting on of the global variable, flag.

Synopsis
  short RAP_resume_record()

Description
  This function is called for certain events, such as
  "PLACE ASCII TEXT FROM FILE".  It sets a flag to on. The
  flag is checked by the RAP listen method for all input received by
  the RAP listener.  As long as the flag is on, all input is recorded.

Return Value
  short     TRUE    always returns a TRUE value

Notes

Index

Keywords
  function, RAP

History
  02/17/93 : dhm : documented

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

short RAP_resume_record ()
{
  int  status;
  OM_S_OBJID 	lisnr_id;

  /* see if the listener object exists */

  status = ex$get_objid_from_NOD(NODname   = NOD_NAME,
                                 objname   = LISTENER_NAME,
                                 pobjid    = &lisnr_id,
                                 modid     = OM_GO_TransOS_0,
                                 mod_osnum = OM_Gw_TransOSnum_0);

  if (status == OM_S_SUCCESS)   /* Enable static, global record flag. */
  {
    flag = RECORD_ON;
  }

  return TRUE;
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  RAPFormListener

Abstract
  This function is called from within the exec.wait_for_input method to pass
  the form event data to the RAP listener object.

Synopsis
  unsigned int RAPFormListener(formName,formData)

  formName    char *                 I    the name of the form
  formData    struct EXFI_data_st    I    the structure containing the form
                                          data found in exfi.h

Description
  This function basically just acts as a buffer between the exec and the
  VDRAPlisnr.formListen method.

Return Value
  OM_S_SUCCESS    always returns success

Notes

Index

Keywords
  function, RAP

History
  02/17/93 : dhm : documented

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

extern unsigned int RAPFormListener(char *formName, struct EXFI_data_st *formData)
{
  unsigned int sts;
  OM_S_OBJID lisnr_id;


#ifdef RAP_DEBUG
  printf("RAP -- Entering RAPFormListener()\n");
#endif

  if (flag)	/* If record has been supended, flag will be false. */
  {
    sts = ex$get_objid_from_NOD(NODname   = NOD_NAME,
                                objname   = LISTENER_NAME,
                                pobjid    = &lisnr_id,
                                modid     = OM_GO_TransOS_0,
                                mod_osnum = OM_Gw_TransOSnum_0);
    if (sts == OM_S_SUCCESS)
    {
      sts = om$send (msg      = message VDRAPlisnr.formListen(formName,formData),
                     senderid = OM_GO_current_OS_objid,
                     targetid = lisnr_id,
                     targetos = OM_Gw_TransOSnum_0);
      ERROR_CHK;
    }

#ifdef RAP_DEBUG
    printf("RAP -- Exiting RAPFormListener()\n");
#endif
  }
  return(OM_S_SUCCESS);
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  WriteString

Abstract
  This function writes a string to the given file.

Synopsis
  void WriteString(fp, s)

  fp    FILE *    I    the file pointer to the output file
  s     char *    I    the string to write to the file

Description
  This function is used throughout the record and playback system to write to
  the .u file that is being generated by RAP.

Return Value

Notes

Index

Keywords
  function, RAP

History
  02/17/93 : dhm : documented

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

static void WriteString(FILE *fp, char *s)
{
#ifdef RAP_DEBUG
  int i;
  int len;

  len = strlen(s);
  fprintf(stderr,"RAP -- writing:");
  for (i = 0; i < len; i++)
    if (s[i] == '\n' && i != len - 1)
      fprintf(stderr,"\nRAP -- writing:");
    else
      fputc(s[i],stderr);
#endif
  fprintf(fp,"%s",s);
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  RAP_record_string

Abstract
  This function is called from the exec to let rap know that the last thing
  written was a command.

Synopsis
  unsigned int RAP_record_string ( command_key, command_name_ptr)

  command_key    char *    I    command key
  command_name_ptr  char*  I    command name

Description
  This function is called by the executive when a command is put on
  the sw queue.  It checks to see if RAP is on, and if so writes the
  command's associated command table cmd_key and message file
  cmd_string to the record file as a comment.  It also checks to see if the
  last thing recorded was a command, and if so it writes it out by command
  key instead of by string.

Return Value
  OM_S_SUCCESS    sucess

Notes
  This function doesn't update me->last_n.

  The reason for the remove_last_command_flag is to prevent RAP from removing
  the user's response to Exit's question to save the file or not.  The code
  used to record the command 'stop record' and then remove it in the finish
  method.  Now the executive sends the shutdown stop record command_key when
  an exit is done and recording is stopped.  The shutdown stop record command
  it not recorded by RAP, therefore, there is no need to remove it.

  The reason for the have_global_argument is to let RAP know that the last
  command that was recorded by string had an argument and that the argument
  was placed in global_argument.

Index

Keywords
  function, RAP

History
  10/15/89 : Bill Tetmeyer : creation
  01/26/93 : dhm : added check_for_string code to remove the string the
                   user keyed in and record it by cmd_key since it turned
                   out to be a command.
  03/10/93 : dhm : added remove_last_command_flag.
  03/11/93 : dhm : added have_global_argument code.
  06/09/93 : dhm : added check for EXDfInGn command.

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

unsigned int RAP_record_string ( char *command_key, char *command_name_ptr)
{
  int     	status, sts, sts1;
  OM_S_OBJID 	lisnr_id;

  if (my_global_file_ptr == NULL)
  {
    return (OM_S_SUCCESS);
  }
#ifdef RAP_DEBUG
  printf("RAP -- In RAP_record_string\n");
  printf("Strings are: %s, %s \n", command_key,command_name_ptr);
#endif

  /* see if the listener object exists */

  status = ex$get_objid_from_NOD(NODname   = NOD_NAME,
                                 objname   = LISTENER_NAME,
                                 pobjid    = &lisnr_id,
                                 modid     = OM_GO_TransOS_0,
                                 mod_osnum = OM_Gw_TransOSnum_0);

  /*  Check for the "stop record" command key because we don't want to
   *  record it.  Also check for the shutdown stop record.
   */

  sts  = strcmp(command_key, "VDStopRcrd");	/* Returns 0 if equal. */
  sts1 = strcmp(command_key, "VDShutRcrd");

  if (  (status == OM_S_SUCCESS) && (sts != 0 ) && (sts1 != 0) )
  {
    /*
     * If the command recorded was the input generator command (brings up
     * the pocket menu), then remove it from the .u file since RAP has no
     * way of dismissing the pocket menu.   TR 11913881 - Doree.
     */

    sts = strcmp(command_key, "EXDfInGn");

    if (!sts)  /* Returns 0 if equal */
    {
      sts = om$send(msg      = message VDRAPlisnr.remove_last_command(),
                    senderid = NULL_OBJID,
                    targetid = lisnr_id,
                    targetos = OM_Gw_TransOSnum_0);

      ERROR_CHK;
    }
    else if (remove_last_command_flag)
    {
      if (check_for_string)
      {
        /*
         * The last string recorded turned out to be a command.  Need to
         * remove the ci$put(string record and replace it with a
         * ci$put(cmd_key
         */

        sts = om$send(msg      = message VDRAPlisnr.remove_last_command(),
                      senderid = NULL_OBJID,
                      targetid = lisnr_id,
                      targetos = OM_Gw_TransOSnum_0);

        ERROR_CHK;

          fprintf(my_global_file_ptr, "\n\tci$put(cmd_key = \"%s\");\n", command_key);

        /* Check to see if the previous command had an argument that needs
         * to be written out.    TR 119302736.
         */

        if (have_global_argument)
        {
          fprintf(my_global_file_ptr, "\n\tci$put(string = \"%s\");\n", global_argument);

          have_global_argument = FALSE;
        }

        check_for_string = FALSE;
      }

      /*  Write the command table command_key and the message file
       *  command name to the .u file as a comment.
       */

      if (TRUE)
      {
        long       tim;
        struct tm *dat;

        tim  = time ((long *)0);
        dat  = localtime(&tim);
        if (strcmp(command_name_ptr, "ci"))
        {
          fprintf(my_global_file_ptr,"\n\t//\"%s\" \"%s\" @%d\n", command_key, command_name_ptr, tim);
        }
        else
        {
          fprintf(my_global_file_ptr,"\n\t//\"%s\" \"ci=%s\" @%d\n", command_key, global_argument, tim);
        }
      }
    }

  }

  /*  Check for exit command because we don't want to remove last command
   *  if we are shutting down.  The exec will put the GRStopRcrd on the
   *  queue itself, so there is no need to remove the last command.
   *  TR 119302401   dhm    3/9/93.
   */

  sts = strcmp(command_key, "EXEx");
  if (sts == 0)
  {
    remove_last_command_flag = FALSE;

    // The exec will NOT put the VDStopRcrd on the queue, so we have to finish ourselves...
    fprintf(my_global_file_ptr,"\n}\n");
    fclose (my_global_file_ptr);
  }

#ifdef RAP_DEBUG
  printf("RAP_record_string -- end\n");
#endif

  return (OM_S_SUCCESS);
}	/* end RAP_record_string */


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  init_new_file

Abstract
  This method writes the declarations and initial statements
  required for the CI command file into the file pointed to by file_ptr.

Synopsis
  init_new_file(FILE *file_ptr)

  file_ptr    FILE *    I    the output ci file

Description

Return Value

Notes

Index

Keywords
  method, RAP

History
  03/10/89 : Terry McIntyre : creation
  07/05/89 : dlw : changed header format
  10/06/89 : bt : modified header style and contents

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method init_new_file(FILE *file_ptr)   /* prepare the file for record */
{
  char s[256], filnam[DI_PATH_MAX], *journal = NULL;
  int  sts;
  struct utsname node;

  journal = (char*)getenv("ISDP_JOURNAL");
  //HF: 06/06/2001 - TR#5210 Make sure start/stop works normally if ISDP_JOURNAL is NOT set...
  if (journal == NULL)
  {
    enable_print = 1;
  }

#ifdef RAP_DEBUG
  printf("RAP -- Entering VDRAPlisnr.init\n");
#endif

  me->last_n = 0;

  me->file_ptr       = file_ptr;
  my_global_file_ptr = file_ptr;

  uname(&node);

  sts = ex$filename (name = filnam, len = DI_PATH_MAX);

  sprintf(s, "//~FileName  : %s\n", filnam);
  WriteString(me->file_ptr,s);

  /*  WriteString(me->file_ptr,"//~Name      : \n");

  sprintf(s, "//~Originator: %s\n",logname());  Jagdish */
  sprintf(s, "//~Originator: %s\n",getenv("LOGNAME"));
  WriteString(me->file_ptr,s);

  sprintf(s,"//~Originated: %s",GetTime());
  WriteString(me->file_ptr,s);

  sprintf(s,"//~Product   : %s %s\n",EX_version,EX_date);
  WriteString(me->file_ptr,s);

  sprintf(s,"//~Nodename  : %s\n",node.nodename);
  WriteString(me->file_ptr,s);

//    if (enable_print) WriteString(me->file_ptr,"//~Command   :\n");
//    if (enable_print) WriteString(me->file_ptr,"//~Comments  :\n");

  WriteString(me->file_ptr,"\n");

  if (enable_print) WriteString(me->file_ptr,"#include \"ciminimum.h\"\n");

  if (enable_print) WriteString(me->file_ptr,"#include \"cimacros.h\"\n");

  if (enable_print) WriteString(me->file_ptr,"#include \"exfi.h\"\n\n");

  if (enable_print) WriteString(me->file_ptr,"main()\n");

  if (enable_print) WriteString(me->file_ptr,"{\n");

  if (enable_print) WriteString(me->file_ptr,"	double pt[3];\n");

  if (enable_print) WriteString(me->file_ptr,"	struct EXFI_data_st formData;\n\n");

#ifdef RAP_DEBUG
  printf("RAP -- Exiting VDRAPlisnr.init\n");
#endif

  return(OM_S_SUCCESS);
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  append_to_file

Abstract
  This method sets a file up to be appended to.

Synopsis
  append_to_file(FILE *file_ptr)

  file_ptr    FILE *    I    file to append to

Description
  This method searches backwards from end of file for a
  close curly brace, "}", closing the ci program.  The method then
  removes the brace, and writes a comment indicating that everything
  after that point was appended.

Return Value
  OM_S_SUCCESS    success

Notes

Index

Keywords
  method, RAP

History
  06/15/89 : Dave Wilson : creation

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method append_to_file(FILE *file_ptr)   /*prepare the file for appending */
{
  char my_char;
  int status;
  long position;

  me->last_n = 0;

  me->file_ptr = file_ptr;
  my_global_file_ptr = file_ptr;

  status =  fseek(file_ptr, 0L, 2);   /* move the pointer to end of file */

  my_char = getc (file_ptr);          /* get last character in file */

  position = ftell (file_ptr); /* Return current position in file */

  while (my_char != '}' && status == 0 ) /* search for close brace */
  {
    status =  fseek(file_ptr, -2L, 1);   /* back the pointer up 2 bytes */

    position = ftell (file_ptr); /* Return current position in file */
    if (!ferror (file_ptr) )	    /* If call to ftell had no error */
    {
      my_char = getc (file_ptr);       /* get last character in file */
    }
  }

  if (my_char == '}')
  {
    status =  fseek(file_ptr, -1L, 1);   /* back the pointer up to brace */
    fprintf(file_ptr," \n");
    fprintf(file_ptr,"//~Appended  : (RAP )%s\n", GetTime());
#ifdef RAP_DEBUG
    printf("RAP -- Found closing bracket and appending\n");
#endif
    return(OM_S_SUCCESS);
  }
  else
  {
    return(MSFAIL);
#ifdef RAP_DEBUG
    printf("RAP -- Failure to append\n");
#endif
  }
}	 /* End of append_to_file */


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  RAP_get_keyboard_data

Abstract

Synopsis
  long RAP_get_keyboard_data ( character, count)

  character    char *    I    character to write to file
  count        int       I

Description
  This function checks to see if RAP is turned on, and if so, handles the
  keyboard data the user keyed in.  It checks for all valid characters
  (special control characters and regular characters) and does any special
  handling before it sends the dataListen message, which writes one character
  to a ci file for later playback.  However, if it is the delete character,
  we remove the last character written to the RAP ppl record file.

Return Value

Notes
  This function is called from within the text dynamics routine,
  $GRNUC/src/display/grdisplay/dptxdynamics.I.

  There is some special handling going on with deleting a character after the
  user just placed the text string.  I keep a buffer of all the characters the
  user has entered in the variable, buff.  These characters get written to the
  file, except for the deleted character, when the user deletes a character
  after placing the text.  I had to add a global flag, place_text_command, in
  order to know when the text command was finished so I could clear the static
  buffer, buff.

Index

Keywords
  function, RAP, text

History
  09/10/89 : Bill Tetmeyer (and Dave Wilson) : creation
  05/18/93 : dhm : TR 11925530 - fixed the deletion of characters.
  05/20/93 : dhm : TR 11914212 - fixed the "^F" font sequencing problem.
  05/24/93 : dhm : TR 11900860 - fixed handling of control sequences in placing
                   text.
  06/17/93 : dhm : TR 119222997 - fixed handling of deletion of characters
                   after placing text. Added all the code dealing with buff
                   and place_text_command.
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

long RAP_get_keyboard_data ( char *character, int count)
{

  int           response = STRING_EVENT;   /* this is a keyboard event */
  int           status, i;
  short         valid_char;
  char          comma[2], tmp_char;
  OM_S_OBJID    lisnr_id;
  static int    char_count = 0, buff_size = 0;
  static char   *buff = NULL;
  static short  replace_return_with_comma = FALSE;
  static short  skip_return = FALSE;
  static short  look_for_y_or_n = FALSE;
  static short  skip_return_again = FALSE;

  status = OM_S_SUCCESS;
  count  = 0;

  /* Turn place_text_command flag on so I can use it in the listen method
   * when I get a TERMINATE from the command server.
   */

  place_text_command = TRUE;


#ifdef RAP_DEBUG
  printf("RAP -- in RAP_get_keyboard_data.\n");
#endif

  /* see if the listener object exists */

  status = ex$get_objid_from_NOD(NODname   = NOD_NAME,
                                 objname   = LISTENER_NAME,
                                 pobjid    = &lisnr_id,
                                 modid     = OM_GO_TransOS_0,
                                 mod_osnum = OM_Gw_TransOSnum_0);

  if (!(1&status))
    goto quit;

  /* Malloc character buff */

  if (!buff)
  {
    buff_size = 500;
    buff = (char *)om$malloc(size = buff_size);
  }

  /*  Check for valid character and handle special cases */

  if (*character == 0x6)  /* ^f */
  {
    valid_char = TRUE;

    /*  Set the global flag for later use and then let it go ahead and write
     *  out the "^f".  Doree
     */

    replace_return_with_comma = TRUE;
  }
  else if ( (*character == 0xa)  ||    /* linefeed */
            (*character == 0xd)  ||    /* return */
            (*character == 0x5)  ||    /* ^e */
            (*character == 0x01) ||    /* FRACTION_KEY */
            (*character == 0x7f) )     /* DELETE_KEY */
  {
    valid_char = TRUE;
  }
  else if ( (*character == 0x11) ||    /* ^q */
            (*character == 0x13) ||    /* ^s */
            (*character == 0x14) ||    /* ^t */
            (*character == 0x16) ||    /* ^v */
            (*character == 0x17) ||    /* ^w */
            (*character == 0x18) ||    /* ^x */
            (*character == 0x19) )     /* ^y */
  {
    valid_char = TRUE;

    /*  Need to ignore the carriage return with these cntrl characters */

    skip_return = TRUE;
  }
  else if (*character == 0x2)   /* ^b */
  {
    valid_char = TRUE;

    /*  With the ^b, need to replace the first return with a comma and the
     *  skip the second return.  Then I need to be on the look out for a
     *  y or n, which indicates justification.
     */

    replace_return_with_comma = TRUE;
    skip_return = TRUE;
    look_for_y_or_n = TRUE;
  }
  else if (*character == 0x10)   /* ^p */
  {
    valid_char = TRUE;

    /*  With the ^p, need to replace the first return with a comma and the
     *  skip the second return.
     */

    replace_return_with_comma = TRUE;
    skip_return = TRUE;
  }
  else if ( (*character >= 0x20) && (*character <= 0x7e) ) /* regular char */
  {
    valid_char = TRUE;
  }
  else if (*character == 0x1b)   /* <esc> */
  {
    /*  If it is the <esc> key, just exit.  Don't need to write it out
     *  because the next thing to be keyed in will be a command.
     */

    place_text_command = FALSE;  /* won't be in the text command any more */
    goto quit;
  }
  else if (last_response == TERMINATE)
  {
    /* If it is a terminate, then I need to dealloc buff and reset the
     * static variables and exit.
     */

    if (buff)
    {
      om$dealloc(ptr = buff);
      buff = NULL;
      buff_size = 0;
      char_count = 0;
    }

    place_text_command = FALSE;
    goto quit;
  }
  else
  {
    valid_char = FALSE;
  }


  /* Write out the character that the user keyed in  */

  if ( replace_return_with_comma &&
       ( (*character == 0xd) || (*character == 0x2c) ) ) /* return or comma */
  {
    /*  TR  11914212 - The ending deliminator to a ^F font sequence in a
     *  text string needs to be a comma instead of a carriage return when
     *  you are not in dynamics (which is the case in RAP).  Doree
     */

    strcpy(comma, ",");

    /* Buffer the characters that are being written out */

    if (char_count > buff_size)
    {
      buff_size = sizeof(buff) + 500;
      buff = om$realloc(ptr = buff, size = buff_size);
    }

    if (buff)
    {
      buff[char_count] = comma[0];
      char_count++;
    }
    else
    {
      buff_size = 0;
      char_count = 0;
    }

    status = om$send (msg = message VDRAPlisnr.dataListen ( comma, count,
                                                            &response),
                      senderid = NULL_OBJID,
                      targetid = lisnr_id,
                      targetos = OM_Gw_TransOSnum_0);

    replace_return_with_comma = FALSE;
  }
  else if ( skip_return && (*character == 0xd) )  /* carriage return */
  {
    if (skip_return_again)
      skip_return_again = FALSE;
    else
      skip_return = FALSE;

    goto quit;
  }
  else if ( look_for_y_or_n &&
            ( (*character == 0x59) || (*character == 0x79) ||   /* Y or y */
              (*character == 0x4e) || (*character == 0x6e) ) )  /* N or n */
  {
    /*  We are in the ^b sequence of events.  We don't want to write out the
     *  y or n.  For y, we want to write out a ^g (for justification) and
     *  skip the return.  For n, we want to just skip it.
     */

    look_for_y_or_n = FALSE;

    if ( (*character == 0x59) || (*character == 0x79) ) /* Y or y */
    {
      tmp_char = 0x7;   /* ^g */

      /* Buffer the characters that are being written out */

      if (char_count > buff_size)
      {
        buff_size = sizeof(buff) + 500;
        buff = om$realloc(ptr = buff, size = buff_size);
      }

      if (buff)
      {
        buff[char_count] = tmp_char;
        char_count++;
      }
      else
      {
        buff_size = 0;
        char_count = 0;
      }

      status = om$send (msg = message VDRAPlisnr.dataListen (&tmp_char, count,
                                                             &response),
                        senderid = NULL_OBJID,
                        targetid = lisnr_id,
                        targetos = OM_Gw_TransOSnum_0);

      skip_return = TRUE;
      skip_return_again = TRUE;
    }
    else /* it's N or n */
    {
      skip_return = TRUE;
      goto quit;
    }

  }
  else if ( valid_char && (*character != 0x7f) )   /* Not delete key */
  {
    /* Buffer the characters that are being written out */

    if (char_count > buff_size)
    {
      buff_size = sizeof(buff) + 500;
      buff = om$realloc(ptr = buff, size = buff_size);
    }

    if (buff)
    {
      buff[char_count] = *character;
      char_count++;
    }
    else
    {
      buff_size = 0;
      char_count = 0;
    }

    status = om$send (msg = message VDRAPlisnr.dataListen ( character, count,
                                                            &response),
                      senderid = NULL_OBJID,
                      targetid = lisnr_id,
                      targetos = OM_Gw_TransOSnum_0);
  }
  else if ( (*character == 0x7f) && (text_has_been_placed) )
  {
    /* TR 119222997   -  dhm  6/16/93
     * It was the delete key after the text had already been placed.
     * Write an EX_RJT_MOVEON to the file so that the place text command
     * will clear out its buffer of text characters.  Then print
     * out buffered characters, except for the deleted one.  Last, set the
     * last_response flag so that it will handle anything else the user
     * keys in correctly.
     */

    if (enable_print) fprintf(my_global_file_ptr, "\n\tci$put(response = EX_RJT_MOVEON);  ");
    if (enable_print) fprintf(my_global_file_ptr, "// clears the command's buffered text\n");

    if (char_count)  --char_count;

    for (i = 0; i < char_count; i++)
    {
      status = om$send(msg = message VDRAPlisnr.dataListen ( &buff[i], count,
                                                             &response),
                       senderid = NULL_OBJID,
                       targetid = lisnr_id,
                       targetos = OM_Gw_TransOSnum_0);
    }

    text_has_been_placed = FALSE;
    last_response = STRING;

  }
  else if ( (*character == 0x7f) &&
            ( (last_response == STRING)     || (last_response == EX_CMD_KEY) ||
              (last_response == CMD_STRING) || (last_response == TERMINATE) ) )
  {
    /*  It was the delete key.  Remove the last character written to the file
     *  if there are any character left to delete.
     */

    if (char_count)
    {
      status = om$send(msg = message VDRAPlisnr.remove_last_command(),
                       senderid = NULL_OBJID,
                       targetid = lisnr_id,
                       targetos = OM_Gw_TransOSnum_0);

      --char_count;
    }
  }

quit:
  return(status);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  RAP_get_button_data

Abstract

Synopsis
  long RAP_get_button_data()

Description
  This function checks to see if RAP is turned on, and if so,
  it sends a message to the RAP listener, which writes to a ci
  file for later playback.  For now, it will be stubbed out until this
  function is needed.

Return Value
  1

Notes

Index

Keywords
  function, RAP

History
  02/17/93 : dhm : document

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

long RAP_get_button_data()
{
  return(1);
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  listen

Abstract
  This method converts response & response_data into the CI format
  and writes it to the file pointed to by me->file_ptr.

Synopsis
  listen(int *response;char *response_data;int *num_char)

  response         int *    I    specifies the event response type
  response_data    char *   I    a union whose type depends on response
  num_char         int *    I    stores the number of chars in response_data

Description

Return Value

Notes

Index

Keywords
  method, RAP

History
  03/10/89 : Terry McIntyre : creation
  01/26/93 : dhm : changed to record by cmd_key instead of by string
                   where the user keys in a command name. TR 119300163.
  02/26/93 : dhm : TR 119301475 - took out #ifdef SUNOS around sprintf() and
                   changed it to work no matter what compiler or libraries
                   were used.
  03/11/93 : dhm : TR 119302736 - changed the handling of arguments in a string
                   by adding global_argument and have_global_argument in the
                   string case.
  06/17/93 : dhm : TR 119222997 - added case TERMINATE to send to
                   RAP_get_keyboard_data if place_text_command is set.

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method listen(int *response;char *response_data;int *num_char)
{
  unsigned int sts;
  int          status;
  int          num_cp = 0, count;
  long         msg;
  long         error_var;
  long         bytes;
  char         *equal_sign_ptr, character;
  char         local_str[80], argument_str[80];
  char         s[1024];
  char         win_name[32];
  struct EX_button *data;
  /*
    struct
    {
    union
    {
    struct EX_button        button;
    IGRchar          keyin[GR_MAX_CHAR];
    IGRdouble        value;
    } event;
    IGRint      subtype;    /* subtype of this data point
    IGRshort    num_id;     /* number of big id's in this structure
    IGRshort    num_val;    /* number of numeric values
    IGRdouble   values[2];
    struct GRlc_info        located_object[2];
    } *event_data;
  */
  struct EX_cmd   my_str;
  struct var_list var_list_array[2];

#ifdef RAP_DEBUG
  printf("RAP -- Entering VDRAPlisnr.listen\n");
  DisplayValues (response,response_data,num_char,&ended);
#endif

  check_for_string = FALSE;

  if (flag)	/* If record has been suspended, flag will be false. */
  {
    me->last_n = 0;

    last_response = *response;

    switch (*response)
    {
      case CMD_STRING:	/* 9 */

        /* If there is an equal sign in the string, then arguments can be
         * specified on the command line. In this case, we need to parse
         * out the command before the equal sign to check to see if it is
         * a valid command and to get its command key. Next, we need to parse
         * out the argument after the equal sign if there is one. If there is
         * an argument, then we will write it to the file as a ci$put(string.
         */

        equal_sign_ptr = (IGRchar *) strchr( response_data, '=' );

        /* Copy the command and get any arguments. */

        if (equal_sign_ptr)
        {
          num_cp = equal_sign_ptr - response_data;
          strncpy( local_str, response_data, num_cp );
          local_str[num_cp] = '\0';
          equal_sign_ptr++;
          num_cp = strlen(response_data) - (num_cp + 1);

          if ( num_cp != 0 )
          {
            strncpy(argument_str, equal_sign_ptr, num_cp);
            argument_str[num_cp] = '\0';
          }
        }
        else	/* Copy the whole string. */
        {
          strcpy( local_str, response_data );
        }

        /*
         * Check for a legal command.  If so, write the command key to the
         * file.  If there was an argument in the string, then write it to
         * the file as well.  TR 119300163  dhm 1/26/93
         */

        status = ex$get_cmd_info( string = local_str,
                                  mode   = EX_STRING,
                                  cmdstr = &my_str );

        if (status)    /* is it a legal command? */
        {
          sprintf( s,"\n	ci$put(cmd_key = \"%s\");\n", my_str.command_key);
          me->last_n = strlen(s);

          if (enable_print) WriteString(me->file_ptr,s);

          /* If there was an argument, then write it to the file. */

          if ( (equal_sign_ptr) && (num_cp != 0) )
          {
            sprintf(s,"\n        ci$put(string = \"%s\");\n", argument_str);
            me->last_n += strlen(s);

            if (enable_print) WriteString(me->file_ptr, s);
          }

        } /* end if */

        break;


      case EX_CMD_KEY:	/* 23 */

        /* Turn place_text_command off because no longer in text command.
         * Flag is used in RAP_get_keyboard_data.
         */

        if (place_text_command)  place_text_command = FALSE;

        status = ex$get_cmd_info( string = response_data,
                                  mode   = EX_CMD_KEY,
                                  cmdstr = &my_str );

        if (status)          /* Is it a legal command ? */
        {
          sprintf(s,"\n	ci$put(cmd_key = \"%s\");", response_data);
          me->last_n = strlen(s);

          if (enable_print) WriteString(me->file_ptr,s);

        }
        break;

      case STRING: /* 8 */
      case CHAR  : /* 13 */
        if (flag_string_record)
        {
          /* If there is an equal sign in the string, then we need to save
           * any arguments in global_argument and set the have_global_argument
           * flag to be checked in the RAP_record_string function.  This
           * function will then handle erasing this string and writing it out
           * as cmd_key and argument string if it turns out to be a command.
           */

          equal_sign_ptr = (IGRchar *) strchr (response_data, '=');

	  if (equal_sign_ptr)
          {
            /* Get any arguments and save them in global_argument */

            equal_sign_ptr++;
            num_cp = strlen(response_data) - (num_cp + 1);

            if (num_cp != 0)
            {
              strncpy(global_argument, equal_sign_ptr, num_cp);
              global_argument[num_cp] = '\0';
            }

            have_global_argument = TRUE;

          }  /* end if legal command */

          /* Copy the string out to the file */

          sprintf(s,"\n  ci$put(string = \"%s\");\n", response_data);
          me->last_n = strlen(s);

          if (enable_print) WriteString(me->file_ptr, s);

          /* Set the check_for_string flag to true so that the

          * RAP_record_string function will know to overwrite this
          * string if it turns out to be a command.
          */

          check_for_string = TRUE;

        }
        else	 /* flag_string_record was off and the switch code was skipped */
        {
          flag_string_record = RECORD_ON;  /* Set it on for next string. */
        }
        break;

        /*
         * Modified to write out coordinates for single resets.
         *
         * rlw 01/31/92
         */
      case RESET:
      case DATA: /* 1 */

        data = (struct EX_button *) response_data;

        /* if got a DATA from within text command, then the text is being
         * placed.  Set flag to let RAP_get_keyboard_data know.
         */

        if (place_text_command)  text_has_been_placed = TRUE;

        /* Determine in which window the data point occurred  */

        var_list_array[0].var            = GRAGAD_NAME;
        var_list_array[0].var_ptr        = win_name;
        var_list_array[0].num_bytes      = 32;
        var_list_array[0].bytes_returned = &bytes;

        var_list_array[1].var            = END_PARAM;

        sts = dp$inq_set_gragad(msg          = &msg,
                                osnum        = data->osnum,
                                gragad_objid = data->objid,
                                which_error  = &error_var,
                                var_list     = var_list_array);
        ERROR_CHK;

        if (msg == MSSUCC)
        {
#ifdef RAP_DEBUG
          printf("RAP -- Using dp$inq_set_gragad...\n");
          printf("RAP -- window_name = <%s>\n",win_name);
#endif
        }
        else
        {
          printf("RAP -- Error getting window name\n");
          printf("RAP -- which_error = %d\n",error_var);
          return(OM_S_SUCCESS);
        }

        if (data->x == 0.0)
        {
          sprintf(s,"\n	pt[0] = 0.0;\n");
          me->last_n += strlen(s);
        }
        else
        {
          sprintf(s,"\n	pt[0] = %.*f;\n", DBL_DIG, data->x);
          me->last_n += strlen(s);
        }
        if (enable_print) WriteString(me->file_ptr,s);

        if (data->y == 0.0)
        {
          sprintf(s,"	pt[1] = 0.0;\n");
          me->last_n += strlen(s);
        }
        else
        {
          sprintf(s,"	pt[1] = %.*f;\n", DBL_DIG, data->y);
          me->last_n += strlen(s);
        }
        if (enable_print) WriteString(me->file_ptr,s);

        if (data->z == 0.0)
        {
          sprintf(s,"	pt[2] = 0.0;\n");
          me->last_n += strlen(s);
        }
        else
        {
          sprintf(s,"	pt[2] = %.*f;\n", DBL_DIG, data->z);
          me->last_n += strlen(s);
        }
        if (enable_print) WriteString(me->file_ptr,s);

        /*
         * Following fragment dealing with Reset added by rlw 01/31/92
         */

        if (*response == RESET)
        {
          sprintf(s,"	ci$putevent(data = pt,\n");
          me->last_n += strlen(s);

          if (enable_print) WriteString(me->file_ptr,s);

          sprintf(s,"		response=RESET,\n");
          me->last_n += strlen(s);
        }
        else
        {
          sprintf(s,"	ci$put(point = pt,\n");
          me->last_n += strlen(s);
        }

        if (enable_print) WriteString(me->file_ptr,s);

        sprintf(s,"		window_name = \"%s\");\n", win_name);
        me->last_n += strlen(s);

        if (enable_print) WriteString(me->file_ptr,s);

        break;

	/* Don't record. These are software generated responses.   */

      case VALUE:		/* 12: Dbl precision floating pt   */
      case FORM_FINISHED:	/* 20: End form response type	   */
      case SPECIFIED_OBJ:	/* 21: Object id		   */
      case EX_POCKET:		/* 24: Pocket menu		   */
      case EX_CMDSVR_RETURN:	/* 27: From batch		   */
      case EX_FORM_DATA:	/* 29: For ppl put to sw queue	   */
        break;

      case TERMINATE:
        /* If we are placing text, then we need to call
         * RAP_get_keyboard_data() to dealloc buff and reset
         * variables.
         */

        if (place_text_command)
        {
          character = NULL;
          count = 1;
          RAP_get_keyboard_data(&character, count);
        }

      default:
        sprintf(s,"\n	ci$put(response = %s);\n", GetResponseType(*response));
        me->last_n = strlen(s);
        if (enable_print) WriteString(me->file_ptr,s);
        break;
    }

#ifdef RAP_DEBUG
    printf("RAP -- Bytes written: %d\n",me->last_n);
    printf("RAP -- Exiting VDRAPlisnr.listen\n");
#endif

  } /* end if (flag) */

  return(OM_S_SUCCESS);
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  formListen

Abstract
  This method converts EXFI_data_st into the CI format and writes
  it to the file pointed to by me->file_ptr.

Synopsis
  formListen(char *formName;struct EXFI_data_st *formData)

  formName    char *                   I    form name
  formData    struct EXFI_data_st *    I    form event data

Description

Return Value

Notes

Index

Keywords
  method, RAP, form

History
  03/30/89 : Terry McIntyre : creation
  02/26/93 : dhm : TR 119301475 - took out #ifdef SUNOS around sprintf() and
                   changed it to work no matter what compiler or libraries
                   were used.

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method formListen(char *formName;struct EXFI_data_st *formData)
{
  char s[256];

#ifdef RAP_DEBUG
  printf("RAP -- Entering VDRAPlisnr.formListen\n");
#endif

  /* don't record input from the menus - command keys are saved elsewhere */
  if (RAPformIsMenu(formName)) return(OM_S_SUCCESS);

  me->last_n = 0;

  sprintf(s,"\n	formData.label = %d;\n", formData->label);
  me->last_n = strlen(s);
  if (enable_print) WriteString(me->file_ptr,s);

  sprintf(s,"	formData.type = %s;\n", GetFIDataType(formData->type));
  me->last_n += strlen(s);
  if (enable_print) WriteString(me->file_ptr,s);

  sprintf(s,"	formData.index = %d;\n", formData->index);
  me->last_n += strlen(s);
  if (enable_print) WriteString(me->file_ptr,s);

  sprintf(s,"	formData.max_index = %d;\n", formData->max_index);
  me->last_n += strlen(s);
  if (enable_print) WriteString(me->file_ptr,s);

  sprintf(s,"	formData.select_flag = %s;\n", GetFISelectType(formData->select_flag));
  me->last_n += strlen(s);
  if (enable_print) WriteString(me->file_ptr,s);

  sprintf(s,"	formData.sts = %d;\n", formData->sts);
  me->last_n += strlen(s);
  if (enable_print) WriteString(me->file_ptr,s);

  switch(formData->type)
  {
    case EXFI_STATE:
      sprintf(s,"	formData.value.state = %d;\n", formData->value.state);
      me->last_n += strlen(s);
      if (enable_print) WriteString(me->file_ptr,s);
      break;

    case EXFI_INT:
      sprintf(s,"	formData.value.ivalue = %d;\n",formData->value.ivalue);
      me->last_n += strlen(s);
      if (enable_print) WriteString(me->file_ptr,s);
      break;

    case EXFI_DOUBLE:
      sprintf(s,"	formData.value.dvalue = %.20f;\n", formData->value.dvalue);
      me->last_n += strlen(s);
      if (enable_print) WriteString(me->file_ptr,s);
      break;

    case EXFI_ALPHA:
      if (formData->value.alpha == NULL)
      {
        sprintf(s,"	strcpy(formData.value.alpha,\"\");\n");
        me->last_n += strlen(s);
      }
      else
      {
        sprintf(s, "	strcpy(formData.value.alpha,\"%s\");\n", formData->value.alpha);
        me->last_n += strlen(s);
      }
      if (enable_print) WriteString(me->file_ptr,s);
      break;

    case EXFI_SUBFORM:
      sprintf(s, "	formData.value.subform.label = %d;\n", formData->value.subform.label);
      me->last_n += strlen(s);
      if (enable_print) WriteString(me->file_ptr,s);

      sprintf(s,"	formData.value.subform.x = %d;\n", formData->value.subform.x);
      me->last_n += strlen(s);
      if (enable_print) WriteString(me->file_ptr,s);

      sprintf(s,"	formData.value.subform.y = %d;\n", formData->value.subform.y);
      me->last_n += strlen(s);
      if (enable_print) WriteString(me->file_ptr,s);
      break;

    case EXFI_SELECTION:
    case EXFI_CLEAR:
      /* ????????? */
      break;

    case EXFI_POINT:
      sprintf(s, "	formData.value.btn.x = %d;\n", formData->value.btn.x);
      me->last_n += strlen(s);
      if (enable_print) WriteString(me->file_ptr,s);

      sprintf(s, "	formData.value.btn.y = %d;\n", formData->value.btn.y);
      me->last_n += strlen(s);
      if (enable_print) WriteString(me->file_ptr,s);

      sprintf(s, "	formData.value.btn.numb = %d;\n", formData->value.btn.numb);
      me->last_n += strlen(s);
      if (enable_print) WriteString(me->file_ptr,s);

      sprintf(s, "	formData.value.btn.click = %d;\n", formData->value.btn.click);
      me->last_n += strlen(s);
      if (enable_print) WriteString(me->file_ptr,s);

      sprintf(s, "	formData.value.btn.down = %d;\n", formData->value.btn.down);
      me->last_n += strlen(s);
      if (enable_print) WriteString(me->file_ptr,s);

      break;
  }

  sprintf(s, "	ci$put (form = \"%s\",\n",formName);
  me->last_n += strlen(s);
  if (enable_print) WriteString(me->file_ptr,s);

  sprintf(s, "		gadget = &formData);\n");
  me->last_n += strlen(s);
  if (enable_print) WriteString(me->file_ptr,s);

#ifdef RAP_DEBUG
  printf("RAP -- Bytes written: %d\n",me->last_n);
  printf("RAP -- Exiting VDRAPlisnr.formListen\n");
#endif

  return(OM_S_SUCCESS);
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  dataListen

Abstract
  This method receives data from an event and writes it to the
  file pointed to by me->file_ptr.

Synopsis
  dataListen( char *character; int count; int *response )

  character    char *    I
  count        int       I
  response     int *     I    event response

Description

Return Value
  TRUE    always returns this.

Notes

Index

Keywords
  method, RAP

History
  09/22/89 : Bill Tetmeyer : creation
  02/26/93 : dhm : TR 119301475 - took out #ifdef SUNOS around sprintf() and
                   changed it to work no matter what compiler or libraries
                   were used.

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method dataListen( char *character; int count; int *response )
{
  char s[256];

  if (*response == STRING_EVENT)
  {
#ifdef RAP_DEBUG
    printf("RAP -- VDRAPlisnr.dataListen\n");
    printf("RAP -- \"%c\" \n", *character);
#endif

    sprintf(s,"	ci$put(string = \"%c\");\n", *character);
    me->last_n = strlen(s);
    if (enable_print) WriteString(me->file_ptr,s);
  }
  else if (*response == BUTTON_EVENT)
  {
    ;
/*      me->last_n = sprintf(s,"       x coord was: %d\n", *x);
        WriteString(me->file_ptr,s);
*/
  }

  return TRUE;

}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  remove_last_command

Abstract
  This method removes the last command written to the .u file.

Synopsis
  remove_last_command()

Description
  This method will move the file_ptr back 'n' bytes, where n
  is the number of bytes written for the last command.  It will then
  write over them with blanks and again move the file_ptr back
  'n' bytes.  This method is used to remove any unwanted RAP commands
  from the CI file.

Return Value
  OM_S_SUCCESS    success

Notes
  An enhancement to RAP writes associated command key and command
  name comments with ci$put strings for all commands except "stop".  The
  subroutine that writes the comments is a function and doesn't update
  last_n so remove_last_command works for the stop command and no others.
  This command should remove any line in the record file which was written
  with the writestring method.

Index

Keywords
  method, RAP

History
  03/10/89 : Terry McIntyre : creation

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method remove_last_command()
{
  int i;

#ifdef RAP_DEBUG
  printf("RAP -- Entering VDRAPlisnr.remove_last_command\n");
  printf("RAP -- Number of bytes to be removed: %d\n",me->last_n);
#endif

  if (fseek(me->file_ptr,-me->last_n,1))
    perror("VDRAPlisnr.finish: Error calling fseek");

  for (i=0;i<me->last_n-1;i++)
    fprintf(me->file_ptr," ");

  fprintf(me->file_ptr,"\n");

  if (fseek(me->file_ptr,-me->last_n,1))
    perror("VDRAPlisnr.finish: Error calling fseek");

#ifdef RAP_DEBUG
  printf("RAP -- Exiting VDRAPlisnr.remove_last_command\n");
#endif
  return(OM_S_SUCCESS);
}


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name
  finish

Abstract
  This method removes the "stop record" command and closes the file
  pointed to by me->file_ptr.

Synopsis
  finish ()

Description

Return Value
  OM_S_SUCCESS    success

Notes

Index

Keywords
  method, RAP

History
  03/10/89 : Terry McIntyre : creation

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method finish ()
{
  unsigned int sts;

#ifdef RAP_DEBUG
  printf("RAP -- Entering VDRAPlisnr.finish\n");
  printf("RAP -- Removing \"stop record\" command from file\n");
#endif

  /*  TR 119302401 - added remove_last_command_flag so that I can control
   *  what command's get removed on shutdown, since I made stop record a
   *  shutdown command.
   */

  if (remove_last_command_flag)
  {
    sts = om$send(msg = message VDRAPlisnr.remove_last_command(),
                  targetid = my_id);

    ERROR_CHK;
  }
  if (enable_print) fprintf(me->file_ptr,"\n}\n");
  fclose(me->file_ptr);

#ifdef RAP_DEBUG
  printf("RAP -- Exiting VDRAPlisnr.finish\n");
#endif

  return (OM_S_SUCCESS);

} /*finish */

end implementation VDRAPlisnr;
