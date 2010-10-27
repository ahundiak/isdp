/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        smspace/func/SMspcTmpStr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMspcTmpStr.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:37  cvs
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
# Revision 1.2  1996/02/02  19:14:52  pinnacle
# Replaced: smspace/func/SMspcTmpStr.I for:  by azuurhou for vds.240
#
# Revision 1.1  1996/01/02  10:12:58  pinnacle
# Created: smspace/func/SMspcTmpStr.I by rgade for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *     02/01/1996       Ravi            Creation for TR#179528394
 *	02/02/1996	adz		Add Surface and Solid reference.
 * -------------------------------------------------------------------*/

class implementation VDS_LOCATE;

#include <string.h>
#include "macro.h"
#include "acmacros.h"
#include "parametric.h"
#include "SMCmdBnd.h"
#include "FI.h"
#include "SMmsg.h"
#include "v_dbgmacros.h"

/* ----------------------------------------------------------------- */
/* Routine to return the template type code in concatenated string
 format. Input is template type and requested is a buffer.
*/

SMspace_getTempDefString( msg, type, tpString )

IGRlong         *msg ;
IGRint          type ;
IGRchar         *tpString ;

{
        IGRchar         *c = NULL ;

        SetProc( SMspace_getTempDefString ); Begin

        *msg = MSSUCC ;

        if( ! tpString ){ *msg = MSFAIL ; goto wrapup ; }

        tpString[0] = '\0' ;

        if( type == ~0 ){
                strcpy( tpString, "not defined");
                goto wrapup ;
        }

        if( type & surface_generic)     strcat( tpString, "surf|");
        if( type & solid_generic)       strcat( tpString, "solid|");
        if( type & macro_generic )      strcat( tpString, "macro|");
        if( type & line_generic )       strcat( tpString, "line|");
        if( type & point_generic )      strcat( tpString, "point|");
        if( type & conic_generic )      strcat( tpString, "conic|");
        if( type & curve_generic )      strcat( tpString, "curve|");
        if( type & parameter_generic){
          if( type == double_type)      strcat( tpString, "double|");
          else if( type == text_type)   strcat( tpString, "text|");
          else                          strcat( tpString, "double|text|");
        }
        if( type & lbs_generic)         strcat( tpString, "text|");
        if( type & ref_generic)         strcat( tpString, "c.s.|");
        if( type & debug_type)          strcat( tpString, "plane|");
        if( type & other_generic)       strcat( tpString, "not defined|");

        c = strrchr( tpString,'|');
        if(c) *c = '\0';
        if( tpString[0] == '\0')
               strcpy( tpString,"not defined");

wrapup:
        End
        return( (*msg == MSSUCC) ? TRUE : FALSE );
}

end implementation VDS_LOCATE ;

