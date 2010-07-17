
/* $Id: VCmacros.h,v 1.1.1.1 2001/01/04 21:12:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcinclude/VCmacros.h
 *
 * Description:
 *
 *     Include file to define retrieval macros for Cabling
 *     parameters.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCmacros.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:35  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/01/19  07:59:10  pinnacle
 * Replaced vcinclude/VCmacros.h for: CR179701619 by aharihar for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.3  1997/07/14  21:18:08  pinnacle
 * Replaced: vcinclude/*.h for:  by hverstee for cabling
 *
 * Revision 1.2  1997/01/20  20:07:28  pinnacle
 * Replaced: vcinclude/VCmacros.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:47:08  pinnacle
 * Created: vcinclude/VCmacros.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/14/95          HV            New
 *     18 Jan 1999      Anand           Added two macros for jumpers.
 *
 * -------------------------------------------------------------------*/

#ifndef  VCmacros_h

#define  VCmacros_h

#include "VCproto.h"
#include "VCCmdPJ.h"

/****************************************************************************/
/*                             M A C R O S                                  */
/****************************************************************************/

/*      new - add new object to directory     */

#omdef  vc$db_new ( msg = &retmsg,
                    element,
                    product,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code,
                    GRid = NULL)
status =
VCDB_new ( (msg), (element), (product), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$guide_new ( msg = &retmsg,
                       status = status,
                       osnum = OM_Gw_current_OS,
                       code,
                       GRid = NULL)
status =
VCDB_new ( (msg), (VC_GUIDE_TYPE), (VC_PROD_NONE), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$bksh_new ( msg = &retmsg,
                       status = status,
                       osnum = OM_Gw_current_OS,
                       code,
                       GRid = NULL)
status =
VCDB_new ( (msg), (VC_BKSH_TYPE), (VC_PROD_NONE), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$elterm_new ( msg = &retmsg,
                       status = status,
                       osnum = OM_Gw_current_OS,
                       code,
                       GRid = NULL)
status =
VCDB_new ( (msg), (VC_TERM_TYPE), (VC_PROD_ELEC), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$foterm_new ( msg = &retmsg,
                       status = status,
                       osnum = OM_Gw_current_OS,
                       code,
                       GRid = NULL)
status =
VCDB_new ( (msg), (VC_TERM_TYPE), (VC_PROD_FO), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$elcab_new ( msg = &retmsg,
                       status = status,
                       osnum = OM_Gw_current_OS,
                       code,
                       GRid = NULL)
status =
VCDB_new ( (msg), (VC_CABLE_TYPE), (VC_PROD_ELEC), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$focab_new ( msg = &retmsg,
                       status = status,
                       osnum = OM_Gw_current_OS,
                       code,
                       GRid = NULL)
status =
VCDB_new ( (msg), (VC_CABLE_TYPE), (VC_PROD_FO), (osnum) , (code) , (GRid) )
#endomdef


/*      del - delete object from directory     */

#omdef  vc$db_del ( msg = &retmsg,
                    element,
                    product,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code)
status =
VCDB_del ( (msg), (element), (product), (osnum) , (code) )
#endomdef

#omdef  vc$guide_del ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code)
status =
VCDB_del ( (msg), (VC_GUIDE_TYPE), (VC_PROD_NONE), (osnum) , (code) )
#endomdef

#omdef  vc$elterm_del ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code)
status =
VCDB_del ( (msg), (VC_TERM_TYPE), (VC_PROD_ELEC), (osnum) , (code) )
#endomdef

#omdef  vc$foterm_del ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code)
status =
VCDB_del ( (msg), (VC_TERM_TYPE), (VC_PROD_FO), (osnum) , (code) )
#endomdef

#omdef  vc$elcab_del ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code)
status =
VCDB_del ( (msg), (VC_CABLE_TYPE), (VC_PROD_ELEC), (osnum) , (code) )
#endomdef

#omdef  vc$focab_del ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code)
status =
VCDB_del ( (msg), (VC_CABLE_TYPE), (VC_PROD_FO), (osnum) , (code) )
#endomdef

/*      old - retrieve existing object (automatic load from DB)  */

#omdef  vc$db_old ( msg = &retmsg,
                    element,
                    product,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code,
                    GRid = NULL)
status =
VCDB_old ( (msg), (element), (product), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$guide_old ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code,
                    GRid = NULL)
status =
VCDB_old ( (msg), (VC_GUIDE_TYPE), (VC_PROD_NONE), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$bksh_old ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code,
                    GRid = NULL)
status =
VCDB_old ( (msg), (VC_BKSH_TYPE), (VC_PROD_NONE), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$elterm_old ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code,
                    GRid = NULL)
status =
VCDB_old ( (msg), (VC_TERM_TYPE), (VC_PROD_ELEC), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$foterm_old ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code,
                    GRid = NULL)
status =
VCDB_old ( (msg), (VC_TERM_TYPE), (VC_PROD_FO), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$elcab_old ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code,
                    GRid = NULL)
status =
VCDB_old ( (msg), (VC_CABLE_TYPE), (VC_PROD_ELEC), (osnum) , (code) , (GRid) )
#endomdef

#omdef  vc$focab_old ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code,
                    GRid = NULL)
status =
VCDB_old ( (msg), (VC_CABLE_TYPE), (VC_PROD_FO), (osnum) , (code) , (GRid) )
#endomdef

/*      idx - retrieve object index   */

#omdef  vc$db_idx ( msg = &retmsg,
                    element,
                    product,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    local = TRUE,
                    dbget = TRUE,
                    p_count,
                    p_codes = NULL,
                    p_desc  = NULL    )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vc$db_idx: no output specified"
#      else
           status =
           VCDB_list ( (msg), (element), (product), (osnum), (local), (dbget),
                       (p_count), (p_codes), (p_desc) )
#      endif
#endomdef

#omdef  vc$guide_idx ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    local = TRUE,
                    dbget = TRUE,
                    p_count,
                    p_codes = NULL,
                    p_desc  = NULL    )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vc$guide_idx: no output specified"
#      else
        status =
        VCDB_list ( (msg), (VC_GUIDE_TYPE), (VC_PROD_NONE), (osnum), (local),
                       (dbget), (p_count), (p_codes), (p_desc) )
#      endif
#endomdef

#omdef  vc$bksh_idx ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    local = TRUE,
                    dbget = TRUE,
                    p_count,
                    p_codes = NULL,
                    p_desc  = NULL    )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vc$bksh_idx: no output specified"
#      else
        status =
        VCDB_list ( (msg), (VC_BKSH_TYPE), (VC_PROD_NONE), (osnum), (local),
                       (dbget), (p_count), (p_codes), (p_desc) )
#      endif
#endomdef

#omdef  vc$elterm_idx ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    local = TRUE,
                    dbget = TRUE,
                    p_count,
                    p_codes = NULL,
                    p_desc  = NULL    )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vc$elterm_idx: no output specified"
#      else
        status =
        VCDB_list ( (msg), (VC_TERM_TYPE), (VC_PROD_ELEC), (osnum), (local),
                       (dbget), (p_count), (p_codes), (p_desc) )
#      endif
#endomdef

#omdef  vc$foterm_idx ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    local = TRUE,
                    dbget = TRUE,
                    p_count,
                    p_codes = NULL,
                    p_desc  = NULL    )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vc$foterm_idx: no output specified"
#      else
        status =
        VCDB_list ( (msg), (VC_TERM_TYPE), (VC_PROD_FO), (osnum), (local),
                       (dbget), (p_count), (p_codes), (p_desc) )
#      endif
#endomdef

#omdef  vc$elcab_idx ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    local = TRUE,
                    dbget = TRUE,
                    p_count,
                    p_codes = NULL,
                    p_desc  = NULL    )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vc$elcab_idx: no output specified"
#      else
        status =
        VCDB_list ( (msg), (VC_CABLE_TYPE), (VC_PROD_ELEC), (osnum), (local),
                       (dbget), (p_count), (p_codes), (p_desc) )
#      endif
#endomdef

#omdef  vc$focab_idx ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    local = TRUE,
                    dbget = TRUE,
                    p_count,
                    p_codes = NULL,
                    p_desc  = NULL    )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vc$focab_idx: no output specified"
#      else
        status =
        VCDB_list ( (msg), (VC_CABLE_TYPE), (VC_PROD_FO), (osnum), (local),
                       (dbget), (p_count), (p_codes), (p_desc) )
#      endif
#endomdef

/* added by alwin for CR179701619 */

/****************************************************************************/
/*                        J U M P E R     M A C R O S                       */
/****************************************************************************/

/* to fetch the jumper comp_codes from the DB */
#omdef  vc$jumper_idx ( msg 	= &retmsg,
			status 	= status,
			osnum 	= OM_Gw_current_OS,
			local 	= TRUE,
			dbget 	= TRUE,
			p_count,
			p_codes	= NULL,
			p_desc	= NULL )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vc$jumper_idx: no output specified"
#      else
        status =
        VCDB_list ( (msg), (VC_JUMPER_TYPE), (VC_PROD_NONE), (osnum), (local),
                       (dbget), (p_count), (p_codes), (p_desc) )
#      endif
#endomdef


/* To retrieve the existing Jumper model object, use this macro */
#omdef  vc$jumper_old ( msg = &retmsg,
                    status = status,
                    osnum = OM_Gw_current_OS,
                    code,
                    GRid = NULL)
status =
VCDB_old ( (msg), (VC_JUMPER_TYPE), (VC_PROD_NONE), (osnum) , (code) , (GRid) )
#endomdef

/* added by alwin for CR179701619 */

#endif

