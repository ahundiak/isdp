/* $Id: VDm_libi.I,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/******************************************************************************
 * I/VDS
 *
 * File:        vds240/vdrecluster/cmd/VDm_libi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDm_libi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:06  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/05/22  17:31:40  pinnacle
# Replaced: vdrecluster/cmd/VDm_libi.I for:  by jwfrosch for vds.240
#
# Revision 1.3  1995/12/13  16:40:10  pinnacle
# Replaced: vdrecluster/cmd/VDm_libi.I for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/12/07  16:59:18  pinnacle
# Replaced: vdrecluster/cmd/VDm_libi.I for:  by jwfrosch for vds.240
#
# Revision 1.1  1995/12/06  15:59:58  pinnacle
# Created: vdrecluster/cmd/VDm_libi.I by jwfrosch for vds.240
#
 *
 * History:
 *      MM/DD/YY      AUTHOR    DESCRIPTION
 *
 *	12/05/95	HF	Override of I/EMS Review Macro Library functionality
 *				in order to reduce the memory problems such as
 *				running out of swap space when many large libraries
 *				are attached.
 *	05/22/96	HF	Moved function COm_lib_review() to separate file COm_libi.I
 *				Removes multi-defined symbol when linking integrated MODEL_VDS
 *				executable.
 *
 ******************************************************************************/

class implementation VDm_lib;

#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "acdef.h"
#include "acmacros.h"
#include "ASmessages.h"
#include "FI.h"

#define AS_DEBUG

#define FORM_RESTART	 3
#define TEMPLATES	61

IGRboolean	VD_K_libTemplates;

%safe
static int	x_memo = -1,
		y_memo = -1,
		s_memo = -1;
%endsafe

extern	Form COm_lib_form_ptr;

VDm_lib_router(f_label,g_label,value,fp)
int f_label,g_label;
IGRdouble value;
char *fp;
{
  int toggl = 0;
  static char *strng = { "Review & MacroInputs Display uses more memory!!" };

  FIg_get_state ( fp, TEMPLATES, &toggl );
  if ( toggl )
  {
    VD_K_libTemplates = TRUE;

    FIg_set_text ( fp, FI_MSG_FIELD, strng );
    FIg_enable   ( fp, FI_MSG_FIELD );
    FIg_display  ( fp, FI_MSG_FIELD );
  }
  else
  {
    VD_K_libTemplates = FALSE;

    FIg_set_text ( fp, FI_MSG_FIELD, "" );
    FIg_disable  ( fp, FI_MSG_FIELD );
    FIg_erase    ( fp, FI_MSG_FIELD );
  }

  switch(g_label)
  {
    case TEMPLATES:
    {
	/*
	 * Toggle for display of Templates
	 */
      FIg_get_state ( fp, TEMPLATES, &toggl );
      if ( toggl )
      {
	VD_K_libTemplates = TRUE;

//	FIg_set_text ( fp, FI_MSG_FIELD, "Warning: Display of templates uses more memory" );
	FIg_set_text ( fp, FI_MSG_FIELD, strng );
	FIg_enable   ( fp, FI_MSG_FIELD );
	FIg_display  ( fp, FI_MSG_FIELD );
      }
      else
      {
	VD_K_libTemplates = FALSE;

	FIg_set_text ( fp, FI_MSG_FIELD, "" );
	FIg_disable  ( fp, FI_MSG_FIELD );
	FIg_erase    ( fp, FI_MSG_FIELD );
      }

      break;
    }
    default :
    {
      COm_lib_router(f_label,g_label,value,fp);

      break;
    }
  }

  FIf_get_location(fp,&x_memo,&y_memo);
  FIf_get_screen  (fp,&s_memo);

  return(1);
}

method init (int type; char *string_ptr )
{
  int FORM = 0;
  double value = 0.0;

  /* Initialize form */

  VD_K_libTemplates = FALSE;	// DEFAULT: DO NOT DISPLAY TEMPLATES !!!

  if(COm_lib_form_ptr == NULL)
  {
    FIf_new( FORM, "VDRevMacLib", VDm_lib_router, &COm_lib_form_ptr);
  }

  if(COm_lib_form_ptr != NULL)
  {
    if(x_memo != -1)
    {
      FIf_set_location(COm_lib_form_ptr,x_memo,y_memo);
      FIf_set_screen(COm_lib_form_ptr,s_memo);
    }
    FIf_display(COm_lib_form_ptr);

    COm_lib_router(FORM,FORM_RESTART,value,COm_lib_form_ptr);
  }

  return(OM_S_SUCCESS);
}

end implementation VDm_lib;
