class implementation FIlstform;

#include "coimport.h"
#include <stdio.h>
#include "codebug.h"
#include "UMS.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "msmacros.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrmacros.h"
#include "grmessage.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DImacros.h"
#include "FI.h"
#include "grcmd.h"


%safe
static Form fp = NULL		    /* The form we're dealing with          */;
static char info_command [DI_PATH_MAX] /* The command that was typed by user   */;
static char selected [DI_PATH_MAX]   /* The line that was selected by user  */;
%endsafe

/*

Name
 COdelete_dir_list_form
Abstract
 This function is called from the super_object when 
 it gets the sleep message. It deletes the form so that it 
 won't interfere with journaling when doing a save. 
Synopsis

Description
 
Return Value

Notes

Index

Keywords
  delete,form,journaling,directory,list

History
  02/10/93 : Carlos M. Diaz : created

*/

void COdelete_dir_list_form()
{
  if (fp)
  {
    FIf_delete(fp);
    fp = NULL;
  }
}

method set_defaults ( char *data; char *back )
{
  me->info = *((struct FormPackInfo *) data);

  return OM_S_SUCCESS;
}


int DirList_form_input ( form_label, gadget_label, value )
int    form_label;
int    gadget_label;
double value;
{
  int  Row;
  int  *sel_flag, *r_pos;
  int  terminate = TERMINATE;
  long msg, size;
  char alpha [DI_PATH_MAX];
  char buffer [2];
  int  resp;

  switch (gadget_label)
  {
  case EXIT_BUTTON:
    FIf_erase ( fp );
    fp = NULL;
    size = 2;
    ex$putque( msg = &msg,
        byte = &size,
        pos = FRONT,
        response = &terminate,
        buffer = buffer );
    break;

  case EVENT_BUTTON:
    size = strlen ( selected ) + 1;
    resp = EX_STRING;
    ex$putque ( msg = &msg,
        response = &resp,
        pos = FRONT,
        byte = &size,
        buffer = selected );
    break;

  case DISPLAY_FIELD:
    Row = value;
    FIfld_get_text ( fp, gadget_label, Row, 0, 132, alpha, &sel_flag, &r_pos );
    strcpy ( selected, alpha );
    break;

  case COMMAND_FIELD:
    FIg_set_text ( fp, gadget_label, info_command );
    break;

  default:
    break;
  }

  return OM_S_SUCCESS;
}


method init ( int type; char *str_ptr )
{
  me->ls = type;

  return OM_S_SUCCESS;
}


method execute ( int *response; char *response_data; int pos )
{
  struct GRevent event;
  long   msg;

  /* we prompt for the command */
  ex$message ( msgnumb = me->ls ? GRC_M_Lst : GRC_M_SrchForNm, field = MESSAGE_FIELD );
  co$getevent ( msgnum = me->ls ? GR_P_Lst : GR_P_Find,
                event_size = sizeof ( event ),
                event_mask = GRm_STRING,
                msg  = &msg,
                event = &event,
                response = response,
                response_data = response_data );
  if (event.response == STRING)
  {
    /* we load the form */    
    om$send ( msg = message FIlstform.form_find ( event.event.keyin, me->ls ), targetid = my_id );
    *response = TERMINATE;
    *response_data = '\0';
  }

  return OM_S_SUCCESS;
}


method set_gadgets ()
{
  int i, count, sts, sel_flag;

  /* Retrieve the number of lines to place in the display field */
  count = me->info.count;
  sts = FIfld_set_num_rows ( fp, DISPLAY_FIELD, count );
  if (sts != FI_SUCCESS) printf ( "Error with FIfld_set_num_rows\n" );

  /* Prepare the display setting with the results of lst or find */
  FIfld_set_num_rows ( fp, DISPLAY_FIELD, count );
  for (i = 0; i < count; i++)
    FIfld_set_text ( fp, DISPLAY_FIELD, i, 0, me->info.list [i], &sel_flag );

  /* Load the header information for the form */
  FIg_set_text ( fp, COMMAND_FIELD, me->info.command );
  strcpy ( info_command, me->info.command );

  /* Still need to send message to DISPLAY FIELD to clear it */
  if (!count)
    FIfld_set_text ( fp,DISPLAY_FIELD, 0, 0, "", &sel_flag );
  *selected = '\0';

  return OM_S_SUCCESS;
}


DIfwrite ( file_name, lines, grids, count )
char   *file_name  /* The file name      				IN  */,
       **lines     /* The lines to be dumped    			IN  */;
DIgrid *grids  	   /* The grids to be dumped    			IN  */;
int    count       /* The number of lines/grids    			IN  */;
/*
   This function writes lines and grids to the file called file_name ( lines
and/or grids may be NULL in order to turn their dump off )

   Return Code :  DIR_S_SUCCESS : Operation sucessfuly completed
                  DIR_E_ABORT   : Cannot open file
*/
{
  int i, status = 1;
  FILE  *fet;

  fet = fopen ( file_name, "w" );
  if (fet)
  {
    for (i = 0; i < count; i++)
    {
      fprintf ( fet, "%4d: ", i );
      if (lines)
        fprintf ( fet, "'%s' ", lines [i] );
      if (grids)
        fprintf ( fet, "( %d, %d )", grids [i].osnum, grids [i].objid );
      fprintf ( fet, "\n" );
    }
    fclose ( fet );
  }
  else
    status = DIR_E_ABORT;

  return status;
}


method form_find ( char *input; int ls )
/*char *input	 whatever was keyed in by the user			IN  */
/*int  ls	 0 for a find, 1 for an ls				IN  */ 
{
  struct FormPackInfo FormPack;
  int                 status, ret, i, j, count, opt_mask = 0;
  char                **lines, dir [DI_PATH_MAX], name [DI_PATH_MAX], option [DI_PATH_MAX];
  char                buff1[UMS_MAX_BUFLEN];

  status = MSSUCC;
  if (!*input)
  {
    /* no options or name was specified */
    *option = '\0';
    strcpy ( name, "*" );
    i = strlen ( input );
  }
  else
  {
    /* either an option and/or a name was specified */
    if (!strchr ( input, '-' ))
    /* no option was specified, interpret data as name */
    {
      *option = '\0';
      strcpy ( name, input );
      i = strlen ( input );
    }
    else
    /* option was specified, interpret data as option with/without name */
    {
      j = 0;

      /* parse the data to determine option, argument, and name */
      for (i = 1; input [i] != ' ' && input [i] != NULL; i++)
      {
        if (input [i] == 'a' || input [i] == 't' || input [i] == 'l')
        /* found a valid option */
        {
          option [j] = input [i];
          j++;
        }
      }
      option [j] = '\0';
      j = 0;

      for (; input [i] == ' '; i++);
      if (input [i] == NULL)
        /* no name was specified, use default ALL value */
        strcpy ( name, "*" );
      else
      {
        /* get the name of the element to find */
        for (; (input [i] != ' ') && input [i]; i++)
        {
          name [j] = input [i];
          j++;
        }
        name [j] = '\0';
      }
    }
  }

  /* get the start directory information, either from event or default */
  for (; (input [i] == ' ') && input [i]; i++);
  if (input [i])
    strcpy ( dir, "." );
  else
    strcpy ( dir, &(input [i]) );

  if (ls) {
    ex$message(msgnumb = GRC_M_Lst, buff = buff1);
    strcat (buff1, "=");
    strcat ( strcpy ( FormPack.command, buff1 ), input );
  }
  else {
    ex$message(msgnumb = GRC_M_Find, buff = buff1);
    strcat (buff1, "=");
    strcat ( strcpy ( FormPack.command, buff1 ), input );
  }

  if (strchr( option, 'a' ) ) opt_mask | =  OPT_ALL;
  if (strchr( option, 't' ) ) opt_mask | =  OPT_TRAILER;
  if (strchr( option, 'l' ) ) opt_mask | =  OPT_LEVEL;

  /* Place results of find in lines */
  if (ls)
    status = di$ls ( regexp = name, lines = &lines, ptr = &count, options = opt_mask );
  else
    status = di$find ( regexp = name, start_dir = dir, lines = &lines,
        ptr = &count, options = opt_mask );

  /* package the information for the form to receive */
  if (status == DIR_S_SUCCESS )
  {
    FormPack.list = lines;
    FormPack.count = count;
    /* Now use count to signal if need for di$free */
    count = 1;
  }
  else
  {
    FormPack.list  = NULL;
    FormPack.count = 0;
    /* Now use count to signal if need for di$free */
    count = 0;
    
    /* Tell the user that no name was found */
    ex$message ( msgnumb = GR_E_NAME_NOT_FND, field = ERROR_FIELD, justification = CENTER_JUS );  
  }

  if (!fp && count)
  {
    FIf_new ( 100, "GRDirList", DirList_form_input, &fp );
    if (!fp)
      return OM_E_ABORT;
    status = om$send ( msg = message FIlstform.set_defaults ( (char *) &FormPack, NULL ),
        targetid = my_id );
    me->info.list = lines;

    status = om$send ( msg = message FIlstform.set_gadgets (), targetid = my_id );
    ret = FIf_display ( fp );
    if (ret) return OM_E_ABORT;
  }
  else
  {
    /* yes, the form already exists */
    if (count)
    {
      om$send ( msg = message FIlstform.set_defaults ( (char *) &FormPack, NULL ),
          targetid = my_id );
      me->info.list = lines;
      status = om$send ( msg = message FIlstform.set_gadgets (), targetid = my_id );
    }
    else
      /* either an empty directory or an invalid name */
      status = (status == DIR_S_SUCCESS ) ? DIR_I_DIR_EMPTY : DIR_E_INVARG;
  }

  if (count)
    di$free ( lines = lines, count = count );

  return status;
}


end implementation FIlstform;
