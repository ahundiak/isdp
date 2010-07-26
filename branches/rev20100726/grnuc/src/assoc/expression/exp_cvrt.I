/*

Name
  exp_cvrt.I

Description
  The routine to do on demand conversion of expressions from 
  previous versions of EMS.

Notes


 */

class implementation expression;

#include "string.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "GMdef.h"
#include "nddef.h"
#include "drawparam.h"

method convert_to_new_syntax ()
{
  IGRboolean need_to_convert;
  char *ptr_to_equal;
  char *curr_pos;
  char *start_pos;

  /*
   * Special case for expressions that have NULL ("\0") syntax but make
   * sure that they are not undefined (value == MAXDOUBLE).
   */
  if ((om$dimension_of ( varray = me->pretty_print ) <= 1) && 
      me->value != MAXDOUBLE)
  {
    char syntax [DI_PATH_MAX];
    int  stat;
    
    sprintf ( syntax, "%g", me->value );
    stat = om$vla_set_dimension ( varray = me->pretty_print, 
      size = strlen ( syntax ) + 1 );
    if (stat & 1)
      strcpy ( me->pretty_print, syntax );
    else
      return stat;
  }
    
  need_to_convert = TRUE;
  curr_pos = me->pretty_print;
  ptr_to_equal = strchr (curr_pos, '=' );
  while ((ptr_to_equal != NULL) && need_to_convert)
  {
    if (strncmp(ptr_to_equal,"==",2) == 0)
      curr_pos = ptr_to_equal + 2;
    else 
    {
      if (ptr_to_equal >  me->pretty_print)
      {
        start_pos = ptr_to_equal - 1;
        
        if ((strncmp(start_pos,"<=",2) == 0) ||
            (strncmp(start_pos,">=",2) == 0) ||
            (strncmp(start_pos,"!=",2) == 0))
          curr_pos = ptr_to_equal + 1;
        else
          need_to_convert = FALSE;
      }          
      else
        need_to_convert = FALSE;
    }
    ptr_to_equal = strchr (curr_pos, '=' );
  }
  
  if (need_to_convert && strlen ( me->pretty_print ))
  {
    char new_syntax [DI_PATH_MAX];
    int  status;

    strcpy ( new_syntax, "\\-1 = " );
    strcat ( new_syntax, me->pretty_print );
    
    status = om$vla_set_dimension ( varray = me->pretty_print, size = strlen ( new_syntax ) + 1 );
    if (status & 1)
      strcpy ( me->pretty_print, new_syntax );
    else
      om$vla_set_dimension ( varray = me->pretty_print, size = 0 );
  }
  
  return OM_S_SUCCESS;
}


end implementation expression;
