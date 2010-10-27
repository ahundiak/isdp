/* $Id: VDstrcaps.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdannot/func/VDstrcaps.I
 *
 * Description:
 *	Implementation of function for transfering string to CAPS
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      07/15/96	Y. Zhu		Creation
 *	09/17/97	Ming Dong	Modification
 * -------------------------------------------------------------------*/

class implementation Root;

#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "v_miscmacros.h"
#include "v_dbgmacros.h"

IGRlong VDstr_caps ( IGRchar		 *str)
{

  IGRint status = OM_S_SUCCESS;
  IGRint i,len;
  IGRchar *cstr;

  SetProc(VDstr_caps); Begin

  __DBGpr_str(" input string ", str);

  len = strlen( str );
  cstr = _MALLOC( len+1, char);

  __DBGpr_int(" len ", len);
 
  for(i = 0; i < len; i++) {
      cstr[i]= toupper(str[i]);
  }
  strcpy(str, cstr);
  str[len] = '\0';
  
  __DBGpr_str(" output string", str);
  _FREE(cstr);
  End
  return status;
}

IGRlong VDstr_reverse ( IGRchar		 *str)
{

  IGRint status = OM_S_SUCCESS;
  IGRint i,len, j;
  IGRchar *cstr, temp_char;
  IGRint front_index, rear_index;

  SetProc(VDstr_reverse); Begin

  __DBGpr_str(" input string ", str);

  front_index = 0;
  rear_index = 0;

  len = strlen( str );
  cstr = _MALLOC( len+1, char);
  strcpy(cstr, str);
  cstr[len] = '\0';

  __DBGpr_int(" len ", len);
 
  do 
  {
    for( i = front_index ; i <= len ; i++)
    {
      if(cstr[i] == '\n' || cstr[i] == '\0')
      {
        rear_index = i-2;
	break;
      }	
    }
 
    if(cstr[rear_index+2] != '\0')
    {
      for( i = front_index, j = rear_index ; i < j ; i++, j--)
      {
        temp_char = cstr[i];
        cstr[i] = cstr[j];
        cstr[j] = temp_char;
      }
      front_index = rear_index + 3;
    }
    else
    {
      for( i = front_index, j = rear_index+1 ; i < j ; i++, j--)
      {
        temp_char = cstr[i];
        cstr[i] = cstr[j];
        cstr[j] = temp_char;
      }
      cstr[rear_index+2] = '\0';
    }
  }
  while(cstr[rear_index+2] != '\0');

  strcpy(str, cstr);
  str[len] = '\0';
  
  __DBGpr_str(" output string", str);
  _FREE(cstr);
  End
  return status;
}

end implementation Root;
