/* $Id: VDSirCheckin.I,v 1.1.1.1.2.1 2003/05/16 14:37:28 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/imp / VDScheckin.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSirCheckin.I,v $
 *	Revision 1.1.1.1.2.1  2003/05/16 14:37:28  ahundiak
 *	ah
 *
 *	Revision 1.1.1.1  2001/06/01 20:06:27  tlstalli
 *	Creating aim module
 *	
# Revision 1.2  2000/07/10  19:44:28  pinnacle
# Replaced: vds/vdcheckin/imp/VDScheckin.I for:  by apazhani for Service Pack
#
# Revision 1.13  2000/03/07  20:04:56  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by impd252 for vds
#
# Revision 1.12  1999/08/27  06:53:46  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by ssranade for vds
#
# Revision 1.11  1999/02/08  19:09:14  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by lawaddel for vds
#
# Revision 1.10  1999/01/28  20:21:38  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by lawaddel for vds
#
# Revision 1.9  1998/11/25  05:13:30  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for: CR # 179801371 by ssranade for vds
#
# Revision 1.8  1998/09/30  06:53:50  pinnacle
# Display posting status on status bar
#
# Revision 1.7  1998/09/28  07:26:32  pinnacle
# (No comment)
#
# Revision 1.6  1998/09/04  19:38:46  pinnacle
# Added string.h for strtok
#
# Revision 1.5  1998/09/03  08:06:50  pinnacle
# TR # 179801453
#
# Revision 1.4  1998/08/31  07:45:12  pinnacle
# TR #:179801292  

# Changes in generation of SIR posting logfile
#
# Revision 1.3  1998/08/14  04:52:48  pinnacle
# For SIR LogFile Generation for Posting SIR parts.
#
# Revision 1.2  1998/08/07  03:59:20  pinnacle
# For SIR

# Modified VDPmeCheckin to accomodate SIR
#
# Revision 1.10  1998/04/17  19:44:52  pinnacle
# TR179800996
#
# Revision 1.9  1998/04/17  19:06:36  pinnacle
# TR179800996
#
# Revision 1.8  1998/04/17  18:04:16  pinnacle
# TR179800996
#
# Revision 1.7  1998/01/30  14:21:22  pinnacle
# AssyTree
#
# Revision 1.6  1998/01/06  20:02:58  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by v250_int for vds
#
# Revision 1.5  1997/12/03  22:04:48  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by yzhu for vds
#
# Revision 1.3  1997/10/27  09:13:14  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by apazhani for vds
#
# Revision 1.2  1997/10/15  10:47:12  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by apazhani for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.4  1997/03/13  10:26:58  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by rgade for vds.241
#
# Revision 1.3  1997/02/27  15:07:40  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by hverstee for vds.241
#
# Revision 1.2  1997/02/05  11:20:38  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by rgade for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.11  1996/05/30  20:43:10  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by tlbriggs for vds.240
#
# Revision 1.10  1996/05/16  19:54:08  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.9  1996/05/13  21:47:34  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.8  1996/05/09  13:27:00  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.7  1996/05/08  17:29:44  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.6  1996/05/06  16:24:50  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.5  1996/05/03  15:45:00  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sljenks for vds.240
#
# Revision 1.4  1995/10/31  20:17:08  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by sundar for vds.240
#
# Revision 1.2  1995/10/25  14:20:52  pinnacle
# Replaced: vdcheckin/imp/VDScheckin.I for:  by hverstee for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *  08/07/98    Shailesh    Modified VDPmeCheckin to accomodate SIR
 *	10/31/95	tlb		Remove corrections fix.
 *      04/30/96        slj 		Altered to remove schematic stuff.
 *	05/01/96	slj		Removed commented out stuff
 *	05/06/96	slj		Added FREE(p_obj_list) to VdsCheckIn
 *	05/09/96	slj		Removed call to VDPostConnection in
 *					VDScheckin, initialized logfile, p_file
 *	05/16/96	slj		Reset p_nbCatalogs, p_svdsCatalog if
 *				 	vdscatalogs is not found in database
 *	05/30/96	tlb		Replace VDS_CHECKIN_MODEL by REP_MODEL
 *	07/19/96	msm		Added Function VDPmeCheckin -
 *					Reconcile PME code changes.
 *	11/05/96        Ravi 		Added the boolean argument to the
 *					VDPmeCheckin function call to facilitai
 *					te the use of TranslistSav object..
 *	10/15/97        Alwin           Added case PID_EQUIP_OBJ, for pid equip
 *	10/26/97        Alwin           Added cases for the Backshell component.
 *                                      Added some Debug statements.
 *	01/30/98	ah		Post Assembly Tree
 *      04/17/98        ah              TR179800996 Core dump while posting some files
 *                                      and getting extraneous warning messages
 *  04/08/98        Shailesh            Logfile generation for posting Parts to AIM.
 *  08/31/98        Shailesh            Changes in logfile ( ISR posting ).
 *  09/04/98        ah                  Add string.h to make clix happy
 *  09/30/98        Shailesh           	Added VDaimGetpostyes()
 *                                      to show posting status on status bar.
 *  25Nov98		SSR		CR#179801371 Posting of parts or FSIs
 *  					Depending on File type.
 *  01/28/99            law             CR179802489 Posting cable leads
 *  02/04/99            law             CR179701619 Posting jumpers
 *  Aug27/99		SSR		Removed Parts posting to AIM
 *  May23/00		Alwin		Added case's for PID posting of PIPING
 *					and HVAC. CR179901521
 *  Jul/10/00		Alwin		Added case's for Rway Nozzle 
 *
 * -------------------------------------------------------------------*/

/*     

ABSTRACT : 

CHANGE HISTORY

CH  16-Jan-1991  : Design date
MF  04-Dec-1991  : RIS integration

modified for 'Fast-checkin' by J.o's & B.j
modified for 'RIS access' by Marc Fournier (20-Nov-1991)
modified for 'Drawing checkin' by Marc Fournier (23-Jan-1992)
modified for 'PDM checkin of design file' by Mallik (9-May-92)
modified for 'Composite beams' by Alain & Mallik(18-May-92)
modified for 'The order of PDM checkin of design file'
             'Read the checkin flag from the database' by Mallik(28-May-92)
modified for 'Modified for Yarrow' by Mallik 10-July-92
modified for 'PDM 2.0 checkin file to server' by Roger Malmgren (3-Sep-92)
modified for 'command object interface' by Rishad Ali (25-Aug-94)
*/

class implementation ACdb_info ;

/*
#define vaimDEBUG
#define vaimerrDEBUG
 */

#include	<stdio.h>
#include <time.h>
#include "string.h"

#include	"ex.h"
#include	"exdef.h"
#include	"exmacros.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"msdef.h"
#include	"msmacros.h"

#include	"ACdb_info.h"

#include	"AS_status.h"
#include	"parametric.h"
#include	"expression.h"
#include	"expmacros.h"

#include	"madef.h"

#include	"ACcheckin.h"
#include	"VDmem.h"
#include	"VDScheckdef.h"

#include	"PDUerror.h"
#include 	"PDMexec.h"
#include	"PDUuser.h"
#include	"PDUcommand.h"
#include	"PDMfile_mac.h"
#include	"PDUstr.h"

#include	"VDScheckin.h"
#include	"VDSris_def.h"
#include	"VDSris_siz.h"
#include	"VDDbtbldef.h"
#include	"vdbmacros.h"
#include	"v_risproto.h"
#include	"v_miscmacros.h"
#include	"vadbgmacros.h"
#include	"v_datamacros.h"

#include 	"VDPdef.h"
#include	"ACrg_collect.h"


#define FILE_PRINT      if (dm2_log) fprintf

#define TRACE
/******************************************************************************/

from OMObjSpace import pass;
from ACcpx      import find_macro, ACgive_structure;
from ACcpx_defn import ACgive_name;
/*from VDREquip 	import VDGetConnectivity;*/
from VDSroot	import VDPostYourselfToDb;
from VDPtrTbl	import	VDPpostPMEdata;
from VDPenabObj         import VDPIsObjEnabled;
from ACrg_collect import ACget_named_attribute;

/*  from VRCorrection  import  VRGetPipeCpts; */

/******************************************************************************/

extern  struct  PDUuser         *user;
extern  int     VD_PDU_present;
/******************************************************************************/

extern  GRclassid     OPP_ACdb_info_class_id;
extern  GRclassid     OPP_VDSroot_class_id;
extern  struct  PDUrefresh  *refresh;
extern int* VDaimGetpostyes();
extern int* VDaimGetpostno();

//extern int CumPartVar;

#ifdef COR_FIX
    extern  GRclassid     OPP_VRCorrection_class_id;
#endif

/* ----------------------------------------------
 * Main AIM/SIR Posting Routine
 * Major chainsaw refactoring
 * I think it's only called with TrSav = FALSE
 */
IGRint VDPmeCheckin( IGRlong   *msg, IGRboolean TrSav  )
{
  IGRint       status=OM_S_SUCCESS, objcount, objctr, diagCtl = 0,
               i = 0;
  struct GRid  TrTblId, EqpBufId, WrkPkgId, EnabId, DefDat;
  OMuword      curOs;
  IGRboolean   allPosted=FALSE;
  IGRchar      DirName[DI_PATH_MAX],
               ListName[DI_PATH_MAX], DefDirName[DI_PATH_MAX];
  struct GRid *list = NULL;
  IGRboolean   flag;
  FILE        *dm2_log = NULL;
  IGRchar      FileName[257], TmpFileName[270];
  time_t       ltime;
  IGRchar     *token, errmsg[100];
  IGRint       CumPartVar = VDaimGetCumPartVar();
  int	      *yespost=0, *nopost=0, FileType;
  struct ACrg_coll coll;

  SetProc( VDPmeCheckin ); Begin
  *msg = MSSUCC;

  __DBGpr_int( " VDScheckin.I.CumPartVar ", CumPartVar );

  /* Grab Transaction List */
  TrTblId.objid = NULL_OBJID;

  ex$get_cur_mod( osnum = &curOs );

  status = di$give_pathname(osnum     = curOs,
                            pathname = DirName );

  if ( TrSav )
  {
    sprintf(ListName,"%s%s%s\0",DirName,SIR_GLOBAL_DIR,SIR_TRANS_LIST_SAV);
  }
  else
  { 
    sprintf(ListName,"%s%s%s\0",DirName,SIR_GLOBAL_DIR,SIR_TRANS_LIST);
  }
  __DBGpr_str( "Transaction List Name", ListName );

  //CR179801371 prepare the default fir name to read file type.
  sprintf(DefDirName,"%s%s%s\0", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA);

  status = di$translate(objname = ListName,
                        p_objid = &TrTblId.objid,
                        p_osnum = &TrTblId.osnum ); 
  __CheckRC(status, 1, "VDPmeCheckin", wrapup);
  __DBGpr_obj( "Tr TblId", TrTblId );
      
  EnabId.objid = NULL_OBJID;
  status = VDPGetEnabledListId( msg, curOs, &EnabId);
  __DBGpr_obj ( "Enabled List Id ", EnabId );

  if ( TrTblId.objid == NULL_OBJID )
    UI_status ( "Transaction List Not Found ");
  if ( EnabId.objid == NULL_OBJID)
    UI_status ( "Enabled Items List Not found ");

  // CR#179801371 Get the default data dir name, Id
  status = di$translate(objname = DefDirName,
	  		p_objid = &DefDat.objid,
			p_osnum = &DefDat.osnum );

  if (( TrTblId.objid != NULL_OBJID )&& ( EnabId.objid != NULL_OBJID))
  {
    status = _VD_SEND_OBJN(TrTblId,
	    		   VDPtrTbl.VDPpostPMEdata( msg, &allPosted ) );
	__CheckRC( status, *msg, "VDPpostPMEdata", wrapup );
	__DBGpr_int ( "Posted Flag", allPosted ); 
	if ( allPosted )
	{
	  status = _VD_SEND_OBJN ( TrTblId, Root.delete ( 1 ));
	  CheckRC( status, 1 ); 
	}
      } 
      /* Parts not to be posted SSR Aug 27 99 */

wrapup :

    nopost = VDaimGetpostno();
    yespost = VDaimGetpostyes();

    //sprintf(errmsg, "%d Objects Posted , %d errors.", *yespost, *nopost );
    sprintf(errmsg, "%d out of %d objects posted", *yespost,(*yespost+*nopost));
    *yespost = 0;
    *nopost=0;

    UI_status(errmsg);
    FILE_PRINT(dm2_log, "\n%s", errmsg );

    if ( dm2_log ) 
      {
      fprintf( dm2_log, "\n");
      fclose ( dm2_log );
      }

    End
    return OM_S_SUCCESS;
}

end implementation ACdb_info ;
