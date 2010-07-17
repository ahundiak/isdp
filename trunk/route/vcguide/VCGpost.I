
/* $Id: VCGpost.I,v 1.3 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcguide / VCGpost.I
 *
 * Description:
 *   Database post of connectivity info for Guide
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCGpost.I,v $
 *        Revision 1.3  2002/05/08 15:48:24  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.2  2001/02/20 01:10:50  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:20:16  pinnacle
# Integ into Route 02040304
#
# Revision 1.1  1997/10/24  12:08:08  pinnacle
# initial revision
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      10/24/97    Alwin          Initial
 *
 *************************************************************************/

class implementation VCGuide;

#include "string.h"
#include "VDSpdudef.h"
#include "VDScheckin.h"
#include "VDScheckdef.h"
#include "VDSris_def.h"
#include "VDSris_siz.h"
#include "VDDbtbldef.h"
#include "vdbmacros.h"

#include "VCDBpar.h"
#include "VCdbstructs.h"
#include "VCdbaccess.h"
#include "VCdbpost.h"
#include "vdAPIequips.h"
#include "vrdbgmacros.h"

/*
#define MY_DEBUG
*/

/* Added by Alwin but not used currently we may use at the later stages
 * when need to do something very specific to Object ...
 */

method VDPostYourselfToDb( long *msg;		// (O)
			   char *key;		// (O)  
			   int  to_sql;		// (I) 
			   char *catalog;	// (I) 
			   char *partid;	// (I) 
			   char *revision;	// (I) 
			   char *designRep;
			   int  *delete;	// (I/O)
			 )
{
  IGRint        status;

  IGRint        nProd;
  IGRchar      *tablename;

  IGRchar       whout[400];

  IGRchar       tagnumber[VC_MAX_TAGNO];
  IGRchar       compcode[VC_MAX_CCODE];

  SetProc( VDPostYourselfToDb ); Begin;

/*
 * Not reqd based on a comment seen in VCCpost.I
 */
#if 0
  if( !strcmp( designRep, REP_SCHEM) )
    tablename = VD_CKTB_S_CBGUIDE;
  else 
    tablename = VD_CKTB_M_CBGUIDE;

  __DBGpr_str( "Table Name for the Guide Object ", tablename );

  whout[0] = '\0';
  sprintf(whout, "%s = '%s' AND %s = '%s' AND %s = '%s' AND %s = %d",
                              REG_CATALOG, catalog,
                              REG_PARTNUM, partid,
                              REG_PARTREV, revision,
                              VD_N_COMPSEQNO_IN, my_id );

  // Delete the contents in the Table before Posting anything, this will 
  // writing the same contents again and again 
  status = vdb$RisDelete (table_name = tablename,
                          where      = whout);
#endif

  __DBGpr_com( "Calling VDSroot.VDPostYourselfToDb" );

  status =
  om$send(msg = message VDSroot.VDPostYourselfToDb
                             (msg, key, to_sql, catalog, partid,
                                       revision, designRep, delete),
         mode = OM_e_wrt_message,
     targetid = my_id );
  as$status(action = RET_STATUS );

  if (*msg != MSSUCC)
  {
      End;
      return (status);
  }

  __DBGpr_com( "Posted the Guide Object Successfully" );

  End ;
  return MSSUCC;
}

end implementation VCGuide;
