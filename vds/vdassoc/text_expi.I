/* $Id: text_expi.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdassoc / text_expi.I
 *
 * Description: this is a modification of NDgive_structure in expression
 *              class. See worksheet 6410848
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: text_expi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.3  1996/04/02  15:19:06  pinnacle
# Replaced: vdassoc/text_expi.I for:  by yzhu for vds.240
#
# Revision 1.2  1996/03/29  00:07:08  pinnacle
# Replaced: vdassoc/text_expi.I for:  by yzhu for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation text_exp ;

/* from interface import wakeup; */

#include <tools.h>
#include <stdio.h> 
#include <string.h> 
#include <OMminimum.h>
#include <OMmacros.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "expression.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMindex.h"
#include "asmacros.h"
#include "AS_status.h"
#include "gocmacros.h"

#define AS_DEBUG 1

extern GRclassid OPP_text_exp_class_id;
extern GRclassid OPP_Gtext_exp_class_id;

/*---------------------------------------------------------------------------*/
method NDgive_structure (IGRlong *msg; struct ret_struct  *ptr_rst;
			 struct GRmd_env *md_env )
/* this Method is used to enquire about this parameter */
{
  *msg = MSSUCC;
  if( ! ptr_rst ){
	*msg = MSFAIL;
  }
  else{
    ptr_rst->type = text_type;
    ptr_rst->var.text_st.text_string[0] = '\0';
  
    if( strlen(ME.expression->pretty_print) > 80 )
	*msg = MSFAIL;
    else
      strcpy(	ptr_rst->var.text_st.text_string,
		ME.expression->pretty_print);
  }

  return(OM_S_SUCCESS);
}

end implementation text_exp ;
