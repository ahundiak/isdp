
/* $Id: VCCmdCON.S,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmdconn/VCCmdCON.S
 *
 * Description:
 *
 *  Class Specification for Connect fibers/leads command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdCON.S,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:08:40  pinnacle
# Replaced: vccmdconn/VCCmdCON.S for:  by r250_int for route
#
# Revision 1.8  1997/11/17  23:22:02  pinnacle
# Replaced: vccmdconn/VCCmdCON.S for:  by kddinov for cabling
#
# Revision 1.1  1997/10/30  04:16:58  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.7  1997/08/12  22:13:48  pinnacle
# Replaced: vccmdconn for:  by hverstee for cabling
#
# Revision 1.6  1997/07/14  22:45:34  pinnacle
# Replaced: vccmdconn/VCCmdCON.S for:  by hverstee for cabling
#
# Revision 1.5  1997/05/06  15:07:06  pinnacle
# Replaced: vccmdconn/VCCmdCON.S for:  by hverstee for cabling
#
# Revision 1.4  1997/01/24  00:04:06  pinnacle
# Replaced: vccmdconn/VCCmdCON.S for:  by hverstee for cabling
#
# Revision 1.3  1997/01/20  22:26:02  pinnacle
# Replaced: vccmdconn/VCCmdCON.S for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:48:50  pinnacle
# Replaced: vccmdconn/VCCmdCON.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:33:56  pinnacle
# Created: vccmdconn/VCCmdCON.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCCmdCON (1:0) of VDS_LOCATE;

#include <stdio.h>
#include <string.h>
#include <float.h>

#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "FI.h"
#include "FEI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "acrepdef.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "asdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "acrepmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCCmdDef.h"
#include "VCCmdCON.h"
#include "VCparameters.h"

#include "VCproto.h"

instance VCCmdCON
{
  IGRint          MyRet;       /*C my return        */
  struct GRid     RefId;       /*C item being connected */
  struct GRid     ModelId;     /*C DB cache id          */
  IGRint          LocType;     /*C located elem type, possible elements are
                                 "FO equipment", "connector", "cable"        */
  IGRint          Product;
  IGRchar         szTag[VC_MAX_TAGNO];   /*  Terminal tag            */
  IGRchar         szEqT[VC_MAX_EQ_ID];   /*  Equipment tag           */

  IGRboolean      bICB;        /* flag, double sided form used       */
  IGRboolean      bSigChk;     /* signal checking on/off             */
  IGRboolean      bRedisplay;  /* form redisplay needed              */
  IGRboolean      bActConn;    /* active fiberoptic connector        */

  IGRshort        nCptNum;     /*C connect point of the ref element  */
  IGRint          nActPos;     /*  active connectrow                 */
  IGRint          nActSide;    /*  active connectside (column)       */
  IGRint          nActCnd;     /*  active candidate index            */

  IGRshort        nCurC_S;     /* current connection/splice   */
  IGRshort        WRT_os;      /* writable os                 */

  /*C instance to hold connection info (for modification 
      purposes)                                                   */
  IGRshort        nNumConTab;  /* number of connecttable entries  */
  IGRshort        nNumConEnt;  /* number of layout entries        */

  IGRshort        nMaxCnd;     /* candidate table size            */
  IGRshort        nMaxCon;     /* connect table size              */

  IGRshort        nCndNum;     /* current # of free leads         */

  struct VCcontab INITstr;
  struct VCcsgtab INITsig;
  struct VCpos    INITtrm;

  IGRchar         szMSG[200];

  /****************************************************************/
  /*      Attached cables list                                    */

  variable
  struct GRid     CabId[0];

  variable
  IGRshort        nCPS[0];

  /****************************************************************/
  /*      TABLES FOR CONNECTIONS                                  */

  variable
  struct VClayout PosTab[0];   /*   positions                     */

  int		DBNumPins;	/* number of DB pin pairs for that terminal */
				/* KDD 11-97 used in PinConnect */

  variable 
  struct VCPinConnect PinConnect[0];	/* KDD 11-97 pin connectivity */ 

  /*     tables -- connected to.....                              */

  variable
  struct VCcontab ConTab1[0];  /*   first (single) side           */

  variable
  struct VCcsgtab ConSig1[0];  /*   signals first side            */

  variable
  struct VCcontab ConTab2[0];  /*   second (if double) side       */

  variable
  struct VCcsgtab ConSig2[0];  /*   signals second side           */

  /****************************************************************/
  /*      TABLES FOR CANDIDATES                                   */

  variable
  struct VCcontab  CndTab[0];  /*   unconnected leads             */

  variable
  struct VCcsgtab  CndSig[0];  /*   unconnected signals           */

  IGRint           CSPnum;
  IGRchar         *CSPlist;    /*  list of connectors/splices to
                                    choose from                    */
};

override init;

override form_notification;

message VCCONRetCode  ();

message VCCONCables   ( long * sts );

message VCCONCleanup  ( long * sts );

message VCCONRefInfo  ( long * sts );

message VCCONFillForm ();

message VCCONactv (IGRchar  *formptr;
                   IGRint    Nactcon;
                   IGRint    Nactsid;
                   IGRint    Nactcnd);

message VCCONinsert (IGRshort  index);

message VCCONlst ( IGRboolean  bSET;
                   int         form_label ;
                   char      * form_ptr );

message VCCONctab ( int         form_label ;
                    char      * form_ptr );

message VCCONstab ( int         form_label ;
                    char      * form_ptr );

message VCCONmtab ( int         form_label ;
                    char      * form_ptr );

message VCCONcbtn ( int         form_label ;
                    char      * form_ptr );

message VCCONdbtn ( int         form_label ;
                    char      * form_ptr );


/* KDD 11-97 */
message VCGetNumOfDatabaseConn (IGRlong         *msg;
                                struct VCTpos   *PinId;
                                int             *index;
                                int             *limit);

message VCGetNumOfConnections(  IGRlong         *msg;
                                struct VCTpos   *PinId;
                                int             *index;
                                int             *NumConn);

end specification VCCmdCON;

