/* $Id: VDCmdDirFrmi.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/cmd / VDCmdDirFrmi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDirFrmi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  21:01:32  pinnacle
# UnInit warning
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/05/08  16:39:12  pinnacle
# Replaced: vdvisual/cmd/VDCmdDirFrmi.I for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	05/08/96	adz		Delete form in save & retrieve.
 *	10/31/97	ah		Fix undefined return
 * -------------------------------------------------------------------*/

class implementation VDCmdDirFrm;

#include "coimport.h"
#include "OMerrordef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "ODE.h"
#include "ex.h"
#include "grmessage.h"
#include "exmacros.h"
#include "griomacros.h"
#include "DImacros.h"
#include "FI.h"
#include <stdio.h>
#include "msmacros.h"
#include "VDCmdDirFrm.h"
#include "VDmsg.h"


# define max(a,b)              (a<b ? b : a)
# define min(a,b)              (a<b ? a : b)

#define DEFAULT_FILE   "report_file"
#define FORM1   1

%safe
static Form VDform1 = NULL; /* if NULL, form does not exist */
static int  VDdirform_level = 1;
static int  VDform_find_done = 0;
static char VDform_find_start [DI_PATH_MAX] = {0};
static int  VDform_find_max_level = 0;
static int  VDform_find_count = 0;
%endsafe

extern int GR_G_dir_mode;

/*

Name
 VDdelete_dir_form
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
  delete,form,journaling,sleep

History
  02/10/93 : Carlos M. Diaz : created

 */

void VDdelete_dir_form()
{
  if (VDform1)
  {
    int         sts;
    OM_S_OBJID objid = NULL_OBJID;

    sts = di$translate ( osnum = OM_Gw_TransOSnum_0,
      p_objid = &objid, path = "IGENOD", objname = "VDDirCmds" );
    if (sts == DIR_S_SUCCESS)
    {
      om$send ( msg = message Root.delete ( 1 ), targetid = objid,
        targetos = OM_Gw_TransOSnum_0, senderid = NULL_OBJID );
    }

    FIf_delete(VDform1);
    VDform1 = NULL;
  }
}


from cmdserver import disconnect_from_stack;

/* ---------------------------------------------------------------------------*/


/* This macro is used to find the names that match the regular expression.
    If lines is specified (char ***), it is filled out with the results.
   This macro is intended to be used by the directory sub-system only.

        o  deep returns the maximum layer number 
        o  max_level may be used to restrict the deep of the search (-1 means
           no restriction)

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------

        char *start_dir       : the place to start to find from        (IN)

        char ***lines         : if specified, the entries are         (OUT)
                                  listed in this array

        int *ptr              : the number of listed entry;                (OUT)

        int  max_level        : the maximum level of search                 (IN)
                                  (< 0 means no limit)

        int  *deep            : the effective deep of the                 (OUT)
                                  search (<= max_level)
 */

#omdef vd$form_find ( start_dir = ".",
                      lines = NULL,
                      ptr, 
                      max_level = -1,
                      deep = NULL )
       VDform_find ( (start_dir), (lines), (ptr), (max_level), (deep) )
#endomdef

/* ---------------------------------------------------------------------------*/

/* This macro is used to fetch the good name in the list displayed by a form.

    return status :
                    DIR_S_SUCCESS : successful operation
                    DIR_E_OVFLOW  : overflow error
                    DIR_E_ABORT   : directory error

      Argument description :
      --------------------
        char line [DI_PATH_MAX]  : the full path name                 (OUT)
        int  index            : the index of the name                 (IN)
 */

#omdef vd$fetch_form_find ( line, index )
       VDfetch_form_find ( (line), (index) )
#endomdef
/* ---------------------------------------------------------------------------*/

void VDget_dir_form( Form1 )
Form *Form1;
{
   *Form1 = VDform1;
}


/* for retrieving static values for co/cob/COnpt.sl report method*/
void VDget_form_find_info( max_level, start_dir )
   int *max_level;
   char *start_dir;
{
   strncpy( start_dir, VDform_find_start, DI_PATH_MAX );
   *max_level = VDform_find_max_level;
}


VDform_find ( start, lines, ptr, max_level, deep )
              char *start      /* The start directory                IN  */,
                   ***lines    /* The buffer to put the names in     OUT */;
              int  *ptr        /* The number of lines                OUT */,
                   max_level   /* The maximum level of the find      IN  */,
                   *deep       /* The effective level of the find    OUT */;
/*
   This function calls di$find for the form of the directory sub-system.
 */
{
  int status;

  /* set up static variables */
  VDform_find_done = 0;
  DIstrcpy ( VDform_find_start, start );
  VDform_find_max_level = max_level;

  /* call find */
  status = di$find ( start_dir = start, 
                     lines = lines, 
                     options = OPT_TRAILER | OPT_LEVEL,
                     max_level = max_level,
                     ptr = &VDform_find_count,
                     deep = deep );
  if (ptr) *ptr = VDform_find_count;

  return (status);
}


VDfetch_form_find( line, index )
   char line [DI_PATH_MAX]     /* The name              OUT */;
   int  index                  /* The name index        IN  */;
/*
   This function returns a full path name corresponding to a selected entry
   in the form.
 */
{
  int         i, status;
  static char **lines = 0;
  static int  count = 0;

  if (!VDform_find_done)
  {
    if (lines)
    {
      for (i = 0; i < count; i++)
        if (lines [i]) free ( lines [i] );
      free ( lines );
    }

    VDform_find_done = 1;
    count = 0;
    status = di$find ( start_dir = VDform_find_start, 
                       lines = &lines, 
                       options = 0,
                       ptr = &count, 
                       max_level = VDform_find_max_level );
  }
  else
    status = count ? DIR_S_SUCCESS : DIR_W_NAME_NOT_FOUND;

  if (status == DIR_S_SUCCESS)
    status = DIstrcpy ( line, lines [min ( index, count - 1 )] );
  else
    strcpy ( line, "" );

  return (status);
}


int VDdirform_process_form ( form_label, gadget_label, value )
int form_label;
int  gadget_label;
double value;
{
  int        stat_func, stat_OM;
  long       msg_loc;
  GRobjid    cmdobj;
  GRspacenum cmdos;

  stat_OM = OM_S_SUCCESS;
  stat_func = FIf_get_cmd_oid_os (VDform1,  &cmdobj,  &cmdos);
  if (stat_func)
    return (OM_E_ABORT);
  stat_OM =
  om$send(msg = message VDCmdDirFrm.do_form (&msg_loc,  form_label, 
                     gadget_label,  value), 
          senderid = NULL_OBJID,
	  targetid = cmdobj,
	  targetos = cmdos);
  if (!(stat_OM & 1))
    return (OM_E_ABORT);

  return (stat_OM);
}


VDSdirectory_command_form ()
{
  GRobjid objid;
  
  return om$construct ( classname = "VDCmdDirFrm", p_objid = &objid,
      msg = message VDCmdDirFrm.init_form () );
}

method init_form()
{
  int status, ret;

  if (VDform1) goto quit; /* form already exists */
  ret = FIf_new (FORM1, "VDSDirCmds",  VDdirform_process_form,  &VDform1);
  if (ret)
    return (OM_E_ABORT);
  ret = FIf_set_cmd_oid_os (VDform1,  my_id,  OM_Gw_current_OS);
  if (ret)
    return (OM_E_ABORT);
  status =
  om$send(msg = message VDCmdDirFrm.set_gadgets(), 
          targetid = my_id);
  if (!(status & 1))
    return (OM_E_ABORT);

  /* add my name to the IGENOD directory */
  di$add_name ( osnum = OM_Gw_current_OS,
                objid = my_id,
                path = "IGENOD",
                objname = "VDDirCmds" );

  status = om$send ( msg = message VDCmdDirFrm.update (),
                     targetid = my_id );
  if (!(status & 1))
    return OM_E_ABORT;

  ret = FIf_display ( VDform1 );
  if (ret)
    return OM_E_ABORT;

quit:
  return 1;
}


static int first;

method do_form ( long *msg; int form_label; int gadget_label; double value)
{
  int    sts, 
         field,    /* Field of instance data needing modify    */
         pop,      /* Does the button need to be popped up     */
         update,   /* Update the display field with a FIND     */
         resp;
  long   msg, size;
  char   auto_cd [DI_PATH_MAX],
         line [DI_PATH_MAX],
         buf  [DI_PATH_MAX],
         cmd  [DI_PATH_MAX];
  char   alpha[132];
  int    ret;
  double dvalue;

  sts = OM_S_SUCCESS;

  pop     = FALSE;
  update  = FALSE;
  DIstrcpy ( cmd, "" );
  DIstrcpy ( auto_cd, "" );

  if ( me->locked == 'T' )
  {
    if ( gadget_label == EXIT_BUTTON )
    {
      FIf_delete ( VDform1 );
      VDform1 = NULL; /* indicates form no longer exists */
      om$send ( msg = message Root.delete ( 1 ), targetid = my_id );
    }
  }
  else
  {
    switch (gadget_label)
    {
    case EXIT_BUTTON:

      FIg_set_state_off ( VDform1, gadget_label );
      FIf_delete ( VDform1 );
      VDform1 = NULL; /* indicates form no longer exists */
      om$send ( msg = message Root.delete ( 1 ), targetid = my_id );
      break;

    case EVENT_BUTTON:
      pop   = TRUE;
      field = EVENT_BUTTON;

      ret = FIg_get_text (VDform1, EDIT_FIELD, alpha);
      size = strlen(alpha) + 1;
      resp = EX_STRING;

      sts = ex$putque ( msg      = &msg,
		        response = &resp,
			pos      = FRONT,
			byte     = &size,
			buffer   = alpha );
      break;

    case WINDOW_BUTTON:
      break;

    case HELP_BUTTON:
      pop   = TRUE;
      field = HELP_BUTTON;
      break;

    case CD_BUTTON:
      if ( DIstrcmp ( me->info.command, "off" ) )
      {
        DIstrcpy ( me->info.command, "off" );
        field = CD_BUTTON;
        {
           /* Put the button back to FALSE position */
           ret = FIg_set_state_off (VDform1, CD_BUTTON);
        }
      }
      else
      {
        pop = TRUE;
        DIstrcpy ( me->info.command, "on" );
      }

      break;

    case DASH_BUTTON:
      pop   = TRUE;
      field = DASH_BUTTON;
      DIstrcpy ( auto_cd, "-" );

      break;

    case DOTDOT_BUTTON:
      pop   = TRUE;
      field = DOTDOT_BUTTON;
      DIstrcpy ( auto_cd, ".." );

      break;

    case MKDIR_BUTTON:
      pop   = TRUE;
      field = MKDIR_BUTTON;
      DIstrcpy ( cmd, "GRCrDr" );
      DIstrcpy ( me->info.command, "off" );

      break;

    case RMDIR_BUTTON:
      pop   = TRUE;
      field = RMDIR_BUTTON;
      DIstrcpy ( cmd, "GRDlDr" );
      DIstrcpy ( me->info.command, "off" );

      break;

    case REMOVE_BUTTON:
      pop   = TRUE;
      field = REMOVE_BUTTON;
      DIstrcpy ( cmd, "GRRnE" );
      DIstrcpy ( me->info.command, "off" );

      break;

    case RENAME_BUTTON:
      pop   = TRUE;
      field = RENAME_BUTTON;
      DIstrcpy ( cmd, "GRCENm" );
      DIstrcpy ( me->info.command, "off" );

      break;

    case HILIGHT_BUTTON:
      pop   = TRUE;
      field = HILIGHT_BUTTON;
      DIstrcpy ( cmd, "GRHiLtEl" );
      DIstrcpy ( me->info.command, "off" );

      break;

    case CURRENT_DIR_FIELD:
      ret = FIg_get_text(VDform1, CURRENT_DIR_FIELD, alpha);
      DIstrcpy ( auto_cd, alpha );

      break;

    case EDIT_FIELD:
      break;

    case REGULAR_EXP_FIELD:
      ret = FIg_get_text(VDform1, REGULAR_EXP_FIELD, alpha);
      if ( DIstrcmp ( alpha, "" ) )
      {
        DIstrcpy ( me->info.title, alpha );
      }
      else
        DIstrcpy ( me->info.title, "." );

      update = TRUE;

      break;

    case BOTTOM_LINE_FIELD:
      break;

    case SLIDER_BAR:
      ret = FIg_get_value(VDform1, SLIDER_BAR, &dvalue);
      me->max_depth = (int) dvalue;
      VDdirform_level = me->max_depth;
      update = TRUE;

      break;

    case REPORT_BUTTON:
      pop   = TRUE;
      field = REPORT_BUTTON;

      DIstrcpy ( cmd, "VDRpDr" );
      ret = FIg_get_text(VDform1, REGULAR_EXP_FIELD, alpha);
      strcpy( me->start_dir, alpha );

      break;

    case INNER_WINDOW:
      vd$fetch_form_find ( index = (int) value, line = line );

      if (DIstrcmp ( me->info.command, "off" ))
        DIstrcpy ( auto_cd, line );
      else
      {

        ret = FIg_set_text (VDform1, EDIT_FIELD, line);
     ret = FIfld_pos_cursor(VDform1, EDIT_FIELD, 0, 0, 0, strlen ( line ), 0, 0);
     }

      break;

    default:
      break;
    }

    if ( pop )
    {
      /* we don't want to pop up the selected gadget and the automatic
         cd mode gadget must stay down as long as we are in automatic
         cd mode */
      if ((me->last_icon != -1) && (me->last_icon != gadget_label) &&
          (me->last_icon != CD_BUTTON))
      {

        /* Put the button back to FALSE position */
        ret = FIg_set_state_off(VDform1, me->last_icon);
      }
      me->last_icon = gadget_label;
    }

    if ( *cmd )
    {
      size = strlen(cmd) + 1;
      resp = EX_CMD_KEY;

      sts = ex$putque ( msg      = &msg,
                        response = &resp,
                        pos      = FRONT,
                        byte     = &size,
                        buffer   = cmd );

/*
commented out by rmn : alpha has been stored in the instance variable
      if ( ! DIstrcmp ( cmd, "VDRpDr" ) )
      {
        DIstrcpy ( cmd, alpha );
        size = strlen(cmd) + 1;
        resp = EX_STRING;

        sts = ex$putque(msg      = &msg,
                        response = &resp,
                        pos      = BACK,
                        byte     = &size,
                        buffer   = cmd );
      }
*/
    }



    if ( *auto_cd )
    {
      sts = di$cd ( dirname = auto_cd  );
      if ( sts == DIR_W_DIR_NOT_FOUND )
      {
        ex$message(	field   = ERROR_FIELD,
			msgnumb = GR_E_DIR_NOT_FOUND );
      }

      di$pwd ( dirname = buf );

      if (!*buf)
      {
        DIstrcpy ( buf, DIR_G_str_dir );
        ret = FIg_set_text(VDform1, CURRENT_DIR_FIELD, buf);
      }
      update = TRUE;
    }

    /* The first time we must update to reset the number of rows in the form
       but only if the first time is not an EXIT_BUTTON, in which case the
       form has been deleted and the pointer (VDform1) cleared */
    if (first && (VDform1 != NULL))
    {

      /* we must clear the display */
      ret = FIfld_set_num_rows (VDform1, INNER_WINDOW, VDform_find_count);
      if (!VDform_find_count)
      FIg_reset (VDform1, INNER_WINDOW);
      first = 0;
    }

    if (update)
      om$send( msg = message VDCmdDirFrm.update (), targetid = my_id );
  }

  return (OM_S_SUCCESS);
}


method update ()
{
  int  i, sts, count, level, last_count;
  int  sel_flag=0;
  char **lines;
  char tmp [DI_PATH_MAX];
  char alpha[132];

  last_count = VDform_find_count;
  sts = vd$form_find ( start_dir = me->info.title, 
                       lines = &lines,
                       ptr = &count, 
                       max_level = me->max_depth,
                       deep = &level );

  /* Adjust level to be 1 relative, not 0 relative */
  ++level;

  FIfld_set_num_rows(VDform1, INNER_WINDOW, count);

  /* Fill out the display field with the results of find */
  for (i = 0; i < count; i++)
    FIfld_set_text(VDform1, INNER_WINDOW, i, 0, lines[i], sel_flag);

  if (!count)
  {
    /* we must clear the display */
    FIfld_set_num_rows ( VDform1, INNER_WINDOW, 0 );
    FIg_reset ( VDform1, INNER_WINDOW );
  }

  /* set the value of the slider bar */
  FIg_set_value ( VDform1, SLIDER_BAR, (double)level );
  me->info.count = level;

  di$free ( lines = lines, count = count );

  FIg_get_text(VDform1, CURRENT_DIR_FIELD, alpha);
  DIterminator ( alpha );

  di$pwd ( dirname = tmp );

  DIterminator ( tmp );
  if (DIstrcmp ( alpha, tmp ))
  {
    if ( !*tmp )
      DIstrcpy ( tmp, DIR_G_str_dir );

    FIg_set_text(VDform1, CURRENT_DIR_FIELD, tmp);
  }

  return OM_S_SUCCESS;
}


method set_gadgets ()
{
  int  sts, i, count;
  int  sel_flag=0;
  char **lines, dir[DI_PATH_MAX], alpha[132];
  
  first = 1;
  di$pwd ( dirname = dir );
  if (!DIstrcmp ( dir, "" ))
    DIstrcpy ( dir, DIR_G_str_dir );

  /* The title field will be used for the regular expression */
  DIstrcpy ( me->info.title, "." );

  /* The command field will be used for the auto_cd mode */
  DIstrcpy ( me->info.command, "off" );

  /* last icon doesn't exist yet */
  me->last_icon = -1;

  /* an out of the blue value for maximum depth of a find */
  me->max_depth = 1;

  sts = vd$form_find ( start_dir = me->info.title, 
                       deep = &me->info.count,
                       max_level = me->max_depth,
                       lines = &lines, 
                       ptr = &count );


  /* Fill out the display field with the results of find */
  for (i = 0; i < count; i++)
  {
    strcpy (alpha, lines [i]);
    FIfld_set_text (VDform1, INNER_WINDOW, i, 0, alpha, sel_flag);
  }

  FIg_set_value ( VDform1, SLIDER_BAR, (double)(me->info.count + 1) );
  FIg_set_text ( VDform1, CURRENT_DIR_FIELD, dir );
  FIg_set_text ( VDform1, EDIT_FIELD, "" );
  FIg_set_text ( VDform1, REGULAR_EXP_FIELD, "." );

  di$free ( lines = lines, count = count );

  return OM_S_SUCCESS;
}


method lock()
{
  me->locked = 'T';

  return OM_S_SUCCESS;
}


method unlock()
{
  me->locked = 'F';
  om$send ( msg = message VDCmdDirFrm.update (), targetid = my_id );

  return OM_S_SUCCESS;
}

method display_default( long *sts )
{
  ex$message( msgnumb = VD_S_DefFl, type="%s", var = DEFAULT_FILE );

  return OM_S_SUCCESS;  // Get rid of warning
}

method report_dir ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  DIchar line [DI_PATH_MAX];
  DIint  i, count;
  FILE   *fet;
  DIgrid grid;

  if ( me->event1.subtype == GRst_DEFAULT )
      strcpy ( me->rep_file, "report_file" );
  else
      strcpy ( me->rep_file, me->event1.event.keyin );


  /*|open the file */
  fet = fopen ( me->rep_file, "w" );
  if (fet)
  {
    /*|do a find */

    status = di$start_find ( ptr = &count,
                             start_dir = me->start_dir,
                             max_level = VDdirform_level,
                             options = OPT_TRAILER | OPT_LEVEL );

    if (status == DIR_S_SUCCESS)
    {
      /*|dump the result */
      for (i = 0; i < count; i++)
      {
        status = di$fetch_find ( line = line, p_grid = &grid, index = i );
        if (status == DIR_S_SUCCESS)
          fprintf ( fet, "%3d: %s - (%d, %d)\n", i, line, grid.osnum, grid.objid );
      }
    }

    /*|close the file */
    fclose ( fet );
  }
  if( status == DIR_S_SUCCESS )
        ex$message( msgnumb = VD_S_RpFlCr, type="%s", var = `me->rep_file`);

  *sts = status;
// quit:
  return OM_S_SUCCESS;
}


#ifdef ORIGINAL

#argsused
DIhilite_line ( p_grid )
struct GRid *p_grid;
{
  return 1;
}


#argsused
DIhilite_lines ( p_grid, count )
struct GRid *p_grid;
int         count;
{
  return 1;
}


DIclear_hilited ()
{
  return 1;
}

#endif

end implementation VDCmdDirFrm;
