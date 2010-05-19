/* $Id: SMfrm_ut5.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/func / SMfrm_ut5.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMfrm_ut5.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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
# Revision 1.2  1996/04/17  14:31:28  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.1  1995/07/24  16:06:26  pinnacle
# Created: smframe/func/SMfrm_ut5.I by hverstee for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"

#include "igrtypedef.h"
#include "igrdef.h"
#include "godef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "parametric.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "csmacros.h"
#include "asbox.h"
#include "expression.h"
#include "expmacros.h"
#include "igrdp.h"
#include "go.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "SMframe.h"
#include "VDmem.h"


#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "SMmsg.h"

#include "AS_status.h"


/* Convert a number of internal unit value to the value in specified unit */
SMfr_convert_int_unit(input,unit,output)
IGRdouble input;      /* [I] internal value  */
IGRchar   *unit;      /* [I] unit to convert */
IGRdouble *output;    /* [O] external value  */
{
  /* Jean 27 July 93 : buffer for convert_array should be 150 */
  IGRchar convert_array[150],*output_alias[1];
  IGRshort num_def;
  IGRlong msg,status;
  OMuword  mod_osnum;

  output_alias[0]=NULL;
  num_def = 1;
  output_alias[0] = _MALLOC(strlen(unit)+2,char);
  strcpy(output_alias[0],unit);

  ex$get_cur_mod(osnum=&mod_osnum);
  status = co$cvt_exp_to_alias(msg =  &msg,
                               unit_type = GRIO_DISTANCE,
                               num_def = &num_def,
                               output_alias = output_alias,
                               working_units = &input,
                               cvt_list =  convert_array,
                               osnum = mod_osnum);
  _FREE(output_alias[0]);
  if(!(status & msg & 1))
    return 0;
  if(sscanf(convert_array,"%lf",output) != 1)
   {
     printf("Erreur convertion\n");
     return 0;
   }
  return 1;
}

end implementation Root;



