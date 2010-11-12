/* $Id: GRnbi.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	 vds/emsfixes/grnuc/GRnbi.I
 *
 * Description:  Creates or opens a notebook file in DI directory,
 *		 :file.dgn:Notebook, using a form.
 *		 Only one notebook can be open at any time.
 *
 * Dependencies: $GRNUC/config/english/forms/GRNoteBook
 *
 * Revision History:
 *      $Log: GRnbi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/10/22  21:00:38  pinnacle
# TR179802032: Fix crash by checking to see if a notebook form already exists; initial checkin to vds pnnacle
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      10/22/98        ejm     TR179802032: Create / Open Notebook
 *                              Command crashes when first form is converted to
 *                              a window, second form brought up, and both are
 *                              exited.
 *				Fix: check for existing non-NULL form pointer
 *				when trying to bring up second form; return if
 *				non-NULL pointer found.
 * -------------------------------------------------------------------*/

class implementation GRnb;

#include "coimport.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "ODE.h"
#include "ex.h"
#include "grmessage.h"
#include "exmacros.h"
#include "griomacros.h"
#include "DImacros.h"
#include "FI.h"
#include <stdio.h>
#include <tools.h>
#include "msdef.h"
#include "msmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "ASmessages.h"
#include "expression.h"
#include "expmacros.h"
#include "alloca.h"
#include "DIglob.h"
#include "grmsg.h"
#include "DIprims.h"
#include "DItypedef.h"
#include "DIdef.h"

#include "actparam.h"

%safe
static Form    NBform = NULL;
static GRobjid NBobjid;
%endsafe

static IGRboolean aflag;

/*

Name
 COdelete_note_book_form  
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
  delete,form,journaling,notebook,sleep

History
  02/10/93 : Carlos M. Diaz : created

 */

void COdelete_note_book_form()
{
  if (NBform)
  {
    FIf_delete(NBform);
    NBform = NULL;
  }
}

static void NBPermanentWindow ()
/*
 * Transforms the form from a save/restore to a permanent window (so that other
 * forms can be activated).
 */
{
  FIf_cvrt_to_perm_win ( NBform );
  FIg_disable ( NBform, 5 );
}

IGRint NBProcessForm ( form_label, gadget_label, value )
IGRint    form_label;
IGRint    gadget_label;
IGRdouble value;
{

  if (gadget_label == EXIT_BUTTON || gadget_label == ABORT_BUTTON)
  {
    GRspacenum osnum;

    aflag = pwIsActivationOn();
    if (aflag)
    {
       osnum = pwGetActiveOs();
    }
    else
    {
       ex$get_cur_mod ( osnum = &osnum );
    }


    om$send ( msg = message GRnb.close_form ( gadget_label == EXIT_BUTTON ),
        senderid = NULL_OBJID, targetid = NBobjid, targetos = osnum );
    FIf_delete ( NBform );
    NBform = NULL;
  }
  else
    if (gadget_label == READ_IN_BUTTON)
    {
      NBPermanentWindow ();
      NBread_in ();
    }
    else
      if (gadget_label == WRITE_OUT_BUTTON)
      { 
        NBPermanentWindow ();         
        NBwrite_out ();
      }  
      else
        if (gadget_label == NAME_FIELD)
        {
          char       name [DI_PATH_MAX];
          int        status;
          GRspacenum osnum;
          GRobjid    objid;
  
    aflag = pwIsActivationOn();
    if (aflag)
    {
       osnum = pwGetActiveOs();
    }
    else
    {
       ex$get_cur_mod ( osnum = &osnum );
    }

          FIg_get_text ( NBform, NAME_FIELD, name );
          status = di$translate ( osnum = osnum, path = "NoteBook", objname = name,
              p_objid = &objid );
          if (status != DIR_S_SUCCESS)
          {
            status = om$construct ( classname = "GRnb", p_objid = &objid, osnum = osnum );
            if (status & 1)
            status = di$add_name ( osnum = osnum, path = "NoteBook", objname = name,
                objid = objid );
            if (status != DIR_S_SUCCESS)
              om$send ( msg = message Root.delete ( 1 ), targetos = osnum, targetid = objid, 
                  senderid = NULL_OBJID );
          }
          om$send ( msg = message GRnb.close_form ( 1 ), targetos = osnum, targetid = NBobjid,
              senderid = NULL_OBJID );
          om$send ( msg = message GRnb.init_form (), targetos = osnum, targetid = objid,
              senderid = NULL_OBJID );
        }
        else
          if (gadget_label == DELETE_BUTTON)
          {
            int        status;
            GRspacenum osnum;
            GRobjid    objid;
            char       my_name [DI_PATH_MAX];
            
            /*
             * We delete the current one (unless it is Notebook).
             */
            NBPermanentWindow ();
            FIg_get_text ( NBform, NAME_FIELD, my_name );
            if (strcmp ( my_name, "NoteBook" ))
            {
              char buffer [DI_PATH_MAX];
              
              /*
               * Make sure that the user really wants to delete the note book
               */
              ex$message ( msgnumb = GR_M_DELETE_NB, buff = buffer, 
                  type = "%s", var = `my_name` );
              
              if (GRconfirm_box ( buffer ) == TRUE)
              {

    aflag = pwIsActivationOn();
    if (aflag)
    {
       osnum = pwGetActiveOs();
    }
    else
    {
       ex$get_cur_mod ( osnum = &osnum );
    }

                objid = NBobjid;
                om$send ( msg = message GRnb.close_form ( 0 ), targetos = osnum, targetid = NBobjid,
                    senderid = NULL_OBJID );
                om$send ( msg = message Root.delete ( 1 ), targetos = osnum, targetid = objid, 
                    senderid = NULL_OBJID );
                status = di$translate ( osnum = osnum, path = "NoteBook", objname = "NoteBook",
                    p_objid = &objid );
                if (status & 1)
                {
                  status = om$send ( msg = message GRnb.init_form (), targetos = osnum, targetid = objid,
                    senderid = NULL_OBJID );
                }
                
                if (!(status & 1))
                {
                  if (NBform)
                  {
                    FIf_delete ( NBform );
                    NBform = NULL;
                  }
  
                  if (NBobjid)
                  {
                    om$send ( msg = message Root.delete ( 1 ), targetos = osnum, targetid = NBobjid, 
                        senderid = NULL_OBJID );
                    NBobjid = NULL_OBJID;
                  }
                }
              }
            }
            else
            {
              char buffer [256];
              
              ex$message ( msgnumb = GR_E_NoNbDel, buff = buffer );
              UI_error ( buffer );
            }
          }
          else 
            if (gadget_label == 5)
              NBPermanentWindow ();

  return OM_S_SUCCESS;
}


NBcreate ()
/*
 * This routine creates an instance of the note book if it doesn't 
 * already exists. The form is displayed.
 * TR179802032: if NBform !NULL, a GRNoteBook form already exists.
 */
{
  int        status, ret;
  GRspacenum osnum;
  GRobjid    objid;

    if( NBform ){
       UI_status(" Only one notebook may be open at any time");
       return 1;
    }
  
    aflag = pwIsActivationOn();
    if (aflag)
    {
       osnum = pwGetActiveOs();
    }
    else
    {
       ex$get_cur_mod ( osnum = &osnum );
    }


  di$mkdir ( osnum = osnum, dirname = "NoteBook" );
  status = di$translate ( osnum = osnum, objname = "NoteBook", p_objid = &objid );
  if (status == DIR_S_SUCCESS)
  {
    status = di$translate ( osnum = osnum, path = "NoteBook", objname = "*",
        p_objid = &objid );
    if (status != DIR_S_SUCCESS)
    {
      status = om$construct ( classname = "GRnb", p_objid = &objid, osnum = osnum );


      if (status & 1)
        status = di$add_name ( osnum = osnum, path = "NoteBook", objname = "NoteBook",
            objid = objid );
    }
  
    if (status & 1)
    {
      ret = FIf_new ( 0, "GRNoteBook", NBProcessForm, &NBform );
      if (ret)
        status = OM_E_ABORT;
      else
      {
        status = om$send ( msg = message GRnb.init_form (), targetos = osnum, targetid = objid,
            senderid = NULL_OBJID );
        if (status & 1)
        {    
          ret = FIf_display ( NBform );
          if (ret)
            status = OM_E_ABORT;
        }
      }
    }
  }

  return status;
}


method init_form ()
{
  int  i, current_length, length, line, count, status, old_line;
  char *ptr, **lines, my_name [DI_PATH_MAX], tmp [DI_PATH_MAX];


  NBobjid = my_id;

    aflag = pwIsActivationOn();
    if (aflag)
    {
       GRspacenum osnum;

       osnum = pwGetActiveOs();
       DIstmocpy ( tmp, "NoteBook", "*", 0, osnum );
    }
    else
    {
       DIstmocpy ( tmp, "NoteBook", "*", 0, OM_Gw_current_OS ); 
    }

 
  status = di$ls ( ptr = &count, lines = &lines, regexp = tmp );
  if (status == DIR_S_SUCCESS)
  {
    FIfld_set_list_num_rows ( NBform, NAME_FIELD, 0, count );

    aflag = pwIsActivationOn();
    if (aflag)
    {
       GRspacenum osnum;

       osnum = pwGetActiveOs();
       di$untranslate(osnum = osnum, objid = my_id, objname = my_name);
    }
    else
    {
       di$untranslate ( osnum = OM_Gw_current_OS, objid = my_id, objname = my_name );
    }

    di$split ( pathname = my_name, name = my_name );
    FIg_set_text ( NBform, NAME_FIELD, my_name );
    for (i = 0; i < count; i++)
    {
      di$split ( pathname = lines [i], name = lines [i] );
      FIfld_set_list_text ( NBform, NAME_FIELD, i, 0, lines [i], 0 );
      free ( lines [i] );
    }
      
    length = om$dimension_of ( varray = me->notes );
    FIfld_get_num_rows ( NBform, EDIT_FIELD, &old_line );
    for (ptr = &me->notes [0], line = 0, current_length = 0; current_length < length; )
    {
      FIfld_set_text ( NBform, EDIT_FIELD, line++, 0, ptr, 0 );
      current_length += strlen ( ptr ) + 1;
      ptr = &me->notes [current_length];
    }
    
    for (; line < old_line;)
      FIfld_set_text ( NBform, EDIT_FIELD, line++, 0, "", 0 );
  }

  return OM_S_SUCCESS;
}


method close_form ( int save )
{
  int  ret, size, line, i, sel_flag, position;
  char tmp [DI_PATH_MAX], *ptr, *ptr_tmp;
 
  char *strip,*strip1;

  if (save)
  {
    for (size = 0, line = 0;; line++)
    {
      ret = FIfld_get_text ( NBform, EDIT_FIELD, line, 0, 
          DI_PATH_MAX, tmp, &sel_flag, &position );
      if (ret)
        break;
      size += strlen ( tmp ) + 1;
    }


    om$vla_set_dimension ( varray = me->notes, size = size );

    for (i = 0, ptr = &me->notes [0]; i < line; i++)
    {
      FIfld_get_text ( NBform, EDIT_FIELD, i, 0, DI_PATH_MAX, tmp, &sel_flag, &position );

      for (ptr_tmp = tmp; *ptr_tmp;)
        *ptr++ = *ptr_tmp++;
      *ptr++ = '\0';
    }
  }
  
  NBobjid = NULL_OBJID;

  return OM_S_SUCCESS;
}


%safe
static Form NBfile_form = NULL;
%endsafe


void NBprocess_file_out ( form_label, gadget_label, value )
IGRint    form_label;
IGRint    gadget_label;
IGRdouble value;
{
  int  i, sel_flag, position; 
  FILE *fet;
  char tmp [DI_PATH_MAX], file_name [DI_PATH_MAX];

  if (NBfile_form)
  {
    *file_name = '\0';
    FIg_get_text ( NBfile_form, 20, file_name );
    FIf_delete ( NBfile_form );
    NBfile_form = NULL;

    /*
     * Make sure we prompt before overwriting an existing file
     */
    fet = fopen ( file_name, "r" );
    if (fet)
    {
      char buffer [DI_PATH_MAX];

      fclose ( fet );
      ex$message ( msgnumb = GR_P_FlExOv, buff = buffer );
      if (GRconfirm_box ( buffer ) != TRUE)
        return;
    }
    
    /* open the file */
    fet = fopen ( file_name, "w" );
    if (fet)
    {
      for (i = 0;; i++)
      {
        if (FIfld_get_text ( NBform, EDIT_FIELD, i, 0, DI_PATH_MAX, tmp, &sel_flag, &position ))
          break;
        fprintf ( fet, "%s", tmp );
        if (!strchr ( tmp, '\n' ))
          fprintf ( fet, "\n", tmp );
      }
      fclose ( fet );    
    }
  }

  return;
}


NBread_line ( line, fet )
char *line	/* The memory to put the stuff in (DI_PATH_MAX)		OUT */;
FILE *fet	/* The file to read from				IN  */;
/*
 *  This routine reads a line on the file specified by fet.
*/
{
  char not_eof, *ptr;
  int  count = 0;

  ptr = line;
  do
  {
    if (not_eof = fread ( ptr++, 1, 1, fet ))
      if (*(ptr - 1) == '\t')
      {
        /*
         * We add spaces until we reach a modulo 9 position
         */
        for (*--ptr = ' ', count++; (count % 9) && (count != DI_PATH_MAX); count++)
          *ptr++ = ' ';
      }
      else
        count++;
      if (count == DI_PATH_MAX)
      {
        /*
         * We truncate the line
         */
        break;
      }
  }
  while (not_eof && (*(ptr - 1) != '\n'));
  *(ptr - 1) = '\0';

  return not_eof;
}


void NBprocess_file_in ( form_label, gadget_label, value )
IGRint    form_label;
IGRint    gadget_label;
IGRdouble value;
{
  int  line; 
  FILE *fet;
  char tmp [DI_PATH_MAX], file_name [DI_PATH_MAX];

  if (NBfile_form)
  {
    *file_name = '\0';
    FIg_get_text ( NBfile_form, 20, file_name );
    FIf_delete ( NBfile_form );
    NBfile_form = NULL;

    /* open the file */
    fet = fopen ( file_name, "r" );
    if (fet)
    {
      for (line = 0; NBread_line ( tmp, fet ); line++)
      {
        if (!strchr ( tmp, '\n' ))
          strcat ( tmp, "\n" );
        FIfld_set_text ( NBform, EDIT_FIELD, line, 0, tmp, 0 );
      }
      FIfld_set_num_rows ( NBform, EDIT_FIELD, line );
      fclose ( fet );    
    }
  }

  return;
}


NBwrite_out ()
/*
 * Write the current notes to a file
 */
{
  int  x, y, x1, y1, status;
  char buffer [DI_PATH_MAX];
  
  status = FIf_new ( 1, "GRNbIn", NBprocess_file_out, &NBfile_form );
  if (!status)
  {
    FIf_get_location ( NBform, &x1, &y1 );
    FIg_get_location ( NBform, WRITE_OUT_BUTTON, &x, &y );
    FIf_set_location ( NBfile_form, x + x1, y + y1 );
    ex$message ( msgnumb = GR_M_WRITE_OUT, buff = buffer );
    FIg_set_text ( NBfile_form, 11, buffer );

    FIf_display ( NBfile_form );

    FIg_get_location ( NBfile_form, FILE_NAME_FIELD, &x, &y );
    FIf_process_point ( NBfile_form, x + 1, y + 1, MIDDLE_BUTTON, SINGLE_CLICK, 0 );
  }

  return OM_S_SUCCESS;  
}


NBread_in ()
/*
 * Read the current notes from a file
 */
{
  int x, y, x1, y1, status;
  
  status = FIf_new ( 1, "GRNbIn", NBprocess_file_in, &NBfile_form );
  if (!status)
  {
    FIf_get_location ( NBform, &x1, &y1 );
    FIg_get_location ( NBform, READ_IN_BUTTON, &x, &y );
    FIf_set_location ( NBfile_form, x + x1, y + y1 );
    FIf_display ( NBfile_form );
  
    FIg_get_location ( NBfile_form, FILE_NAME_FIELD, &x, &y );
    FIf_process_point ( NBfile_form, x + 1, y + 1, MIDDLE_BUTTON, SINGLE_CLICK, 0 );
  }

  return OM_S_SUCCESS;  
}


end implementation GRnb;
