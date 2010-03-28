/*

Name
  exp_di.I

Description

 * The purpose of these methods is to support the directory command form
 * as an edit capability. This message will be sent by the form when
 * the user has modified the string returned by DIget_edit_string. In
 * order word, these 2 methods (DIget_... and DIput_...) allows expressions
 * to support syntaxic modification from the form.
 * Note that any class can support these two messages.

Notes


 */

class implementation expression;


#include "string.h"
#include <OMminimum.h>
#include <OMmacros.h>
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include <stdio.h> 

%safe
#include <math.h> 
%endsafe

#include "exmacros.h"
#include "AS_status.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "expression.h"
#include "expmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "asbox.h"

#include "godef.h"
#include "nddef.h"
#include "ndmacros.h"
#include <ctype.h>




method DIput_edit_string ( char *string )
/*
 * The purpose of this method is to support the directory command form
 * as an edit capability. This message will be sent by the form when
 * the user has modified the string returned by DIget_edit_string. In
 * order word, these 2 methods (DIget_... and DIput_...) allows expressions
 * to support syntaxic modification from the form.
 * An expression returns <name> = <syntax>
 * Note that any class can support these two messages.
 */
{
  return exp$modify ( exp_id = my_id, exp_syntax = string );
}


method DIget_edit_string ( char *string )
/*
 * The purpose of this method is to support the directory command form
 * as an edit capability. This message will be sent by the form when
 * the form wants to give the user an editable string.
 */
{
  if (me->pretty_print [0])
    EXP_universal_to_named ( OM_Gw_current_OS, my_id, me->pretty_print, string, REL_TO_CREAT_DIR );
  else
  {
    int  status;    
    char my_name [DI_PATH_MAX];    
    
    *my_name = '\0';

    status = di$untranslate ( objid = my_id, objname = my_name );
    if (status &1)
    {
      di$split ( pathname = my_name, name = my_name );
      sprintf ( string, "%s = ", my_name );
    }
    else
      *string = '\0';    
  }

  
  return OM_S_SUCCESS;
}

 
end implementation expression;
