/* $Id: COm_libi.I,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/******************************************************************************
 * I/VDS
 *
 * File:        vds240/vdrecluster/cmd/COm_libi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: COm_libi.I,v $
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
# Revision 1.1  1996/05/22  17:32:52  pinnacle
# Created: vdrecluster/cmd/COm_libi.I by jwfrosch for vds.240
#
 *
 * History:
 *      MM/DD/YY      AUTHOR    DESCRIPTION
 *
 *	05/22/96	HF	Creation date
 *				Override of I/EMS Review Macro Library functionality
 *				in order to reduce the memory problems such as
 *				running out of swap space when many large libraries
 *				are attached.
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

extern	Form COm_lib_form_ptr;

/******************************************************************************

   Interface function between C-form and CO

******************************************************************************/

COm_lib_review ( f_label, g_label, value,fp )
  int		 f_label, g_label;
  double	 value;
  char		*fp;
{
  VDm_lib_router ( f_label, g_label+100, value, COm_lib_form_ptr);
  return 1;
}

end implementation VDm_lib;
