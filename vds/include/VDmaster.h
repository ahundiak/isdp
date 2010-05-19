/* $Id: VDmaster.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDmaster.h
 *
 * Description: Try a master include file for vds stuff
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDmaster.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.4  1998/03/15  15:18:54  pinnacle
 * AssyTree
 *
 * Revision 1.3  1997/11/25  15:52:24  pinnacle
 * NULL_GRID
 *
 * Revision 1.2  1997/11/25  01:13:28  pinnacle
 * AssyTree
 *
 * Revision 1.1  1997/10/29  14:50:42  pinnacle
 * Master Include
 *
 *
 * History:
 * MM/DD/YY   AUTHOR  DESCRIPTION
 * 10/28/97   ah      Added header
 * 03/15/98   ah      Split into VDtypedef.h
 ***************************************************************************/

#ifndef VDmaster_include
#define VDmaster_include

/* -------------------------------------------
 * VDtypedef includes a bunch of exnuc/grnuc
 * basic information as well as the std files
 */

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

/* -------------------------------------------
 * 25 Nov 1997, not sure what I did here,
 * asbox.h defines NULL_GRID as struct GRid
 * Is it defined differently somewhere else?
 */
/*
extern GRobjid NULL_GRID;
*/
#include "asbox.h"

#ifndef REFERENCES_DEFS
#include "refdef.h"
#endif

#ifndef   didef
#include "DIdef.h"
#endif

#ifndef   DItypedef_include
#include "DItypedef.h"
#endif

#ifndef   diglob
#include "DIglob.h"
#endif

#ifndef   DIprims
#include "DIprims.h"
#endif

#ifndef   DImacros

#omdef di$strcat ( to, from )
       DIstrcat ( to, from )
#endomdef

#endif

#ifndef   nddef_include
#include "nddef.h"
#endif

#ifndef   ndmacros_include
#include "ndmacros.h"
#endif

#ifndef   asmacros_include
#include "asmacros.h"
#endif

#include "AS_status.h"

#ifndef   asdeb_include
#include "AS_debug.h"
#endif

#ifndef   ASmessages_include
#include "ASmessages.h"
#endif

#ifndef   MACRODEF
#include "macro.h"
#endif

#ifndef   dpdef_include
#include "dpdef.h"
#endif

#ifndef   dpmacros_include
#include "dpmacros.h"
#endif

#include "coparamac.h"   /* Privaleged file, make fence */

#ifndef   expmacros
#include "expmacros.h"
#endif

#ifndef   expression_include
#include "expression.h"
#endif

#ifndef   lcdef_include
#include "lcdef.h"
#endif

#ifndef   lcmac_include
#include "lcmacros.h"
#endif

#ifndef   csdef_include
#include "csdef.h"
#endif

#ifndef   csmacros_include
#include "csmacros.h"
#endif

#ifndef   bserr_include
#include "bserr.h"       /* Includes bstypes.h */
#endif

#ifndef   FI_H_INCLUDED
#include "FI.h"
#endif

// VDS Stuff
#ifndef   vd_vds_include
#include "vds.h"
#endif

#ifndef   vdsmacros_include
#include "vdsmacros.h"
#endif

#ifndef   v_misc_include
#include "v_miscmacros.h" /* Gets VDmem.h as well */
#endif

#ifndef   v_geommacros_include
#include "v_geommacros.h"
#endif

#ifndef   v_debug_include
#include "v_dbgmacros.h"
#endif

#ifndef   VDSpathdef_include
#include "VDSpathdef.h"
#endif

#ifndef   VDSudp_mac_include
#include "VDSudp_mac.h"
#endif

#ifndef   VDvla_include
#include "VDvla.h"
#endif

#ifndef   VDah_include
#include "VDah.h"
#endif

#ifndef   VDbro_include
#include "VDbro.h"
#endif

#ifndef   VDbro1_include
#include "VDbro1.h"
#endif

// Of Include Block
#endif





