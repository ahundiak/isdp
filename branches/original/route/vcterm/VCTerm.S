
/* $Id: VCTerm.S,v 1.2 2002/05/08 15:48:25 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTerm.S
 *
 * Description:
 *
 *      Abstract class to define the behavior of a cabling terminal
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTerm.S,v $
 *      Revision 1.2  2002/05/08 15:48:25  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1999/02/12  11:04:56  pinnacle
# Replaced: vcterm/VCTerm.S for: CR 179701619 by aharihar for route
#
# Revision 1.2  1999/01/19  09:00:12  pinnacle
# Replaced: vcterm/VCTerm.S for: CR179701619 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.6  1998/04/26  20:33:54  pinnacle
# Replaced: vcterm/VCTerm.S for:  by kddinov for route
#
# Revision 1.5  1998/04/12  21:11:48  pinnacle
# Replaced: vcterm/VCTerm.S for:  by kddinov for route
#
# Revision 1.4  1998/02/24  22:39:34  pinnacle
# Replaced: vcterm/VCTerm.S for:  by kddinov for route
#
# Revision 1.3  1998/02/18  20:06:36  pinnacle
# Replaced: vcterm/VCTerm.S for:  by kddinov for route
#
# Revision 1.2  1997/11/30  16:17:50  pinnacle
# Replaced: vcterm/VCTerm.S for:  by r250_int for route
#
# Revision 1.14  1997/11/27  05:44:30  pinnacle
# Replaced: vcterm/VCTerm.S for:  by apazhani for cabling
#
# Revision 1.13  1997/07/22  14:47:06  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.12  1997/07/14  22:08:36  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.11  1997/05/22  15:05:58  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.10  1997/05/19  13:37:04  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.9  1997/04/28  21:56:56  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.8  1997/03/12  16:25:46  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.7  1997/01/20  21:18:04  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.6  1996/10/25  13:49:46  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.5  1996/10/16  20:41:04  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.4  1996/10/03  18:15:52  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.3  1996/09/30  15:20:52  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:20:40  pinnacle
# Replaced: vcterm/VCTerm.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:27:38  pinnacle
# Created: vcterm/VCTerm.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *      11/27/97    Alwin       Overding NDmove_to_root
 *
 *      02/98	    KDD		adding new data instances for 
 *				Jumper connections and Jumper description .
 *			 	VCInitInstance override.
 *
 *	4/98	    KDD		override override VCGetMatrix; to handle
 *				scaling of embedded terminal offsets.
 *
 *      4-98        KDD         Override GRget_matrix. to handle EMS moves.
 *
 *   19 Jan 1999    Anand       Implemented VCSetJumpInstance and
 *				VCGetJumpInstance methods for setting jumper
 *				data and connectivity information to the
 *				terminal (CR 179701619).
 *
 *   12 Feb 1999    Anand       Implemented VCGetNumJumpCabOnTermPin method
 *
 *************************************************************************/

class specification VCTerm (0:0) of VCCon,VCP,VCMac;

#include "VCstructs2.h"


instance VCTerm
{
  variable
  struct VCterm_sigtab    VCT_sig[0];   /*   signal names etc. */

  variable
  struct VCT_passthru     VCT_pass[0];  /*   passthru pairs    */


  variable char		  JumpConn[0];  /* pointer to VCJumpConn structure */

  IGRshort		  JumpConnType; /* size of a single JumpConn data 
					   packet sizeof(VCJumpConn) */


  variable char		  JumpData[0];  /* pointer to VCJumpData structure */

  IGRshort		  JumpDataType; /* size of a single JumpConn data 
					   packet sizeof(VCJumpData) */
};

/*   MESSAGES            */

/*   Get real terminal from virtual     */

message VCTRealCon( IGRlong    *msg;
             struct GRid       *RealCon;
             struct GRmd_env   *md_env);

message VCTembed (IGRboolean   *bEmbedded);

/*   set passthrough   */
message VCTpass   (IGRlong    *msg;
            struct GRid       *CB1;
            struct VCpos      *Cutpos1;
            struct GRid       *CB2;
            struct VCpos      *Cutpos2);

/*   cut passthrough   */
message VCTcut    (IGRlong    *msg;
            struct GRid       *CB1;
            struct VCpos      *Cutpos1;
            struct GRid       *CB2;
            struct VCpos      *Cutpos2);

/*   find other passthrough cable  */
message VCTpWhich (IGRlong    *msg;
            struct GRid       *CB1;
            struct GRid       *CB2;
                   IGRshort   *nCP);

/*   find attached cables amongst children   */
message VCTcables    (IGRlong   *msg;
                      IGRshort  *nTotcab; /*  total # of cables        */
                      IGRshort  *nRefcab; /*  # of ref. cables         */
               struct GRid      *Cables); /*  array of cab GRids       */

message VCTshells    (IGRlong   *msg;
                      IGRshort  *nShell;  /*  total # of backshells    */
               struct GRid      *Shells); /*  array of shell GRids     */



/******************** FOR JUMPERS ****************************/

    /* The below two methods, set and retrieve respectively, the information
       pertaining to the jumpers, from the terminal's instance. To take care of
       problems that might arise due to legacy issues, structures are cast
       converted to voids and passed (as with the case of cable offsets. */

message VCSetJumpInstance (	IGRlong *msg;
				void	*JumperInfo;
				IGRint	NbJumpers;
				void	*JumpConnectInfo );

message VCGetJumpInstance (	IGRlong *msg;
				void	**JumperInfo;
				IGRint	*NbJumpers;
				void	**JumpConnectInfo );

    /* The below method retrieves the number of cable leads and number of
       jumpers (whose cnt_vs_max attribute is set to 'y') that are connected to
       a terminal pin. The pin id (mod and pos information in struct VCTpos) is
       passed to this method within the struct VCPinConnect, and the above
       information including the max DB limit of the terminal pin, is returned
       in this structure itself. */

message VCGetNumJumpCabOnTermPin( IGRlong                 *msg;
				  struct VCPinConnect     *ReqdInfo;
				);
/* NOTE : All the above 3 jumper related methods are implemented in
	  vcterm/VCTinfo.I */


/**************************** OVERRIDES ***********************************/

override VCGetEquipId;
override VCGetEquipTag;

override ACcheckin_candidate;

override NDplace;
override NDcopy;
override NDupdate;
override NDdelete;
override NDmove_to_root; /* Overriding to delete the Embedded Terminal when
                           it's Parent Equipment is deleted. Alwin */

override GRget_siblings;
override GRget_matrix;

override VCBaseMat;
override VCTransMat;
override VCGetMatrix;

override VCGetNumberOfCpts;

override VCSetInstance;
override VCGetInstance;
override VCGetTopology;
override VCGetSupports;

override VCGetCpts;

override VCP_reorg;            /*   actual reorganization     */

/*C return connection information    */

override VCConnect;
override VCConDisc;
override VCConDscall;

override VCGetSignal;
override VCPutSignal;

override VCConList;

override VCGetThru;
override VCConGetTrace;
override VCConGetPtrc;

override VCGetCompart;

override VCDUMP;

override VCInitInstance;    /* to initialize the "variable char' structures */

override VDgetObjDef;

override VDPostYourselfToDb; /* to post the Jumper Instance data. Alwin */


/* methods for using the me->Data backdoor provided in VCRoot */
override      VCSetDataVLA, VCGetDataVLA, VCDataTypeSize;

end specification VCTerm;

