/*
 *  Function:  GRunit_database_type
 *
 *  Abstract:  give an object space number, this function determines
 *             if the DISTANCE data base units of the the OS are 
 *             english, metric, or other.  If other, this is not a
 *             design file that the I/EMS product will support.
 *             SRH 10/18/91
 *
 *  Arguments: 
 *
 *    OMuword  osnum     I   object space tested
 *    IGRint  *eng_met   O   type of units (in griodef.h):
 *                             GRIO_UNITS_ARE_ENGLISH - 1 DBU = 1 inch
 *                             GRIO_UNITS_ARE_METRIC  - 1 DBU = 1 milimeter
 *                             GRIO_UNITS_ARE_UNKNOWN - not supported 
 *
 *  Returns: 
 *    IGRint 
 *       MSSUCC - If DISTANCE table IS     found in the specified object space
 *       MSFAIL - If DISTANCE table IS NOT found in the specified object space
 *      
 *  History:
 *    Shelley R. Heard  10/18/91 - created
 *    Scott Walters     07/14/92 - ansi conversion
 */

#include    "grimport.h"
#include    "codebug.h"
#include    "OMprimitives.h"
#include    "igrtypedef.h"
#include    "igr.h"
#include    "msdef.h"
#include    "griodef.h"
#include    "OMminimum.h"
#include    "griopriv.h"
#include    "exmacros.h"
#include    "codef.h"
#include    "csmacros.h"
#include    "griomacros.h"
#include    "igrmacros.h"

/*
 *  due to a general distrust of double precision arithmetic, comparisons
 *  will be done within tolerance of 1.0E-12.
 */
#define _close_enough            ( 1.0E-12 )
#define _compare_doubles(d1,d2)  ( ( d1 - d2 ) < _close_enough )

int GRunit_database_type( osnum, 
			  eng_met )

  OMuword      osnum;      /* object space # table is in           */
  IGRint      *eng_met;    /* type of units (english,metric,other) */

{
    int     status,
	    msg;
    double  result;

    /*
     * get object id of units object
     */

    status = co$cvt_exp_to_wrk( msg       = &msg, 
                                osnum     =  osnum,
                                unit_type =  GRIO_DISTANCE,
                                units     =  1.0,
                                alias     =  "inch",
                                result    = &result );



    if      (_compare_doubles(result, 1.0))  *eng_met = GRIO_UNITS_ARE_ENGLISH;
    else if (_compare_doubles(result,25.4))  *eng_met = GRIO_UNITS_ARE_METRIC;
    else                                     *eng_met = GRIO_UNITS_ARE_UNKNOWN;
    
    return((status&1) ? MSSUCC : MSFAIL );
}
