
/* $Id: VCDB_FOfn.I,v 1.2 2001/02/20 01:10:29 build Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDB_FOfn.I
 *
 * Description:
 *
 * Utility function to retrieve list of fiberoptic connectors/splices
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDB_FOfn.I,v $
 *      Revision 1.2  2001/02/20 01:10:29  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/10/20  15:58:06  pinnacle
# Replaced: vcdbattr/VCDB_FOfn.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/08/15  12:53:58  pinnacle
# Replaced: vcdbattr/VCDB_FOfn.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:17:52  pinnacle
# Replaced: vcdbattr/VCDB_FOfn.I for:  by hverstee for cabling
#
# Revision 1.2  1997/01/23  23:09:36  pinnacle
# Replaced: vcdbattr/VCDB_FOfn.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:52:30  pinnacle
# Created: vcdbattr/VCDB_FOfn.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/13/96          HV            New
 *      10/06/98          Alwin         Modified to query the DB to fetch the
 *                                      Connector/Slice information to list it
 *                                      in the form.
 *
 * -------------------------------------------------------------------*/

class implementation VCDB;

#include <string.h>
#include "PDUerror.h"
#include "v_risproto.h"
#include "VCdbaccess.h"
#include "VCproto.h"
#include "VDmem.h"
#include "VDDbDef.h"
#include "vrdbgmacros.h"

/*
#define   MY_DEBUG
*/




IGRint  VC_FOCONlist (IGRlong         *msg,
                      IGRchar         *szMtc1,
                      IGRchar         *szMtc2,
                      IGRint          *Cnum,
                      IGRchar         *Clist)
{
  IGRint         status, NbRow=0;
  IGRchar       *Loc, **DbIO=NULL;
  IGRchar	szWhere[50];

  SetProc( Fn VC_FOCONlist ); Begin

  status = OM_S_SUCCESS;
  *msg   = MSSUCC;

  /*      @@@@@ TBD @@@@@   */

  /*    Using the two match strings (connector matchcodes) generate
        a list of connectors that satisfies BOTH codes.

        refer to database tables concerning fiberoptic connector
        matching                                                      */

   *Cnum = 0;

  __DBGpr_str( " String 1 ", szMtc1 );
  __DBGpr_str( " String 2 ", szMtc2 );

  /* added by alwin for TR179801275 */
  /* This DB call may change in future, we may use a DB object to store this
  information which shoule reduce our interaction with the DB. */
  //Get the information from the DB table "vct_fsel"

  sprintf( szWhere, " con_match = '%s' ", szMtc2 );
  status=
  vdb$RisSelect (select     = "con_spl_def",
                 table_name = "vct_fsel",
                 where      = szWhere,
                 numselect  = 1,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  Loc = szMtc1;
  Loc = szMtc2;

  __DBGpr_int( " Nb. of Rows found in DB ", NbRow );

  if( ( Clist != NULL ) && ( NbRow > 0 ) )
  {
    IGRint i;

    for( i=0; i<NbRow; i++ )
    {
      //__DBGpr_str( " Connector type ", DbIO[i] );

      strcpy( Clist, DbIO[i] );

      __DBGpr_str( " Connector type ", Clist );
      Clist += VC_MAX_CCODE;
    }
  }

  *Cnum = NbRow;
  /* added by alwin for TR179801275 */

  _FREE( DbIO );

  End
  return (status);
}

end implementation VCDB;

