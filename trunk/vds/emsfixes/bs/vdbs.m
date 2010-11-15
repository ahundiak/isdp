/* $Id: vdbs.m,v 1.13 2002/05/31 13:32:16 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/bs/vdbs.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: vdbs.m,v $
 * Revision 1.13  2002/05/31 13:32:16  hans
 * Removes bs files; included in new dynamic bspmath library 31-May-2002
 *
 * Revision 1.12  2002/05/16 15:56:53  ramarao
 * Fixed a Infinite Loop and Crash problem ( TR# 5262 ).
 *
 * Revision 1.11  2001/08/22 14:07:02  ramarao
 * Fixed TR# 5530.
 *
 * Revision 1.10  2001/08/07 14:21:57  ramarao
 * Fixed TR# 5492.
 *
 * Revision 1.9  2001/06/15 17:03:43  hans
 * Temporary fix for asin DOMAIN error
 *
 * Revision 1.8  2001/06/01 13:54:51  hans
 * New math libraries, so no need for any BS files.
 *
 * Revision 1.7  2001/04/17 21:19:12  hans
 * TR MP4842
 *
 * Revision 1.6  2001/04/02 22:37:23  ramarao
 * Fixed TR# 4999
 *
 * Revision 1.5  2001/02/11 18:24:50  hans
 * No need for any BS functions anymore, since bsot_sn5.[a/so] is up-to-date
 *
 * Revision 1.4  2001/01/22 19:16:53  ahundiak
 * ah
 *
 * Revision 1.3  2001/01/17 21:16:08  hans
 * Cleaned up obsolete junk (new math-libraries/Model-executable)
 *
 * Revision 1.2  2001/01/12 22:22:18  hans
 * SP16 files added for OLD Model exec.
 *
 * Revision 1.1.1.1  2001/01/04 21:07:27  cvs
 * Initial import to CVS
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/09/97  adz     Add three files corrections.
 * 03/05/98  ah      Add VDdbgFlags.c for debug flags
 * 05/15/98  ah      An earlier change created a new file bsmdptbscv1.h
 *                   Checked this file into this directory and added .
 *                   To the list of include search paths
 * 05/22/98  ah      TR179801101 Data reduction core dumps bsdta_rdusf.c
 * 06/24/98  ah      TR179801103 Offset curve problem
 * 06/29/99  ah      New bspmath build, get rid of almost everything
 * 12/08/99  ah      Added new functions from loft unwrap
 * 01/05/20  Jayadev Added three new file for loft unwrap
 * 02/15/00  RR      Added two files related to BSmdistcvsf() function
 * 02/28/00  HF      Fix for TR 179901421
 * 05/10/00  HF      Fix for TR 179901376
 * 05/11/00  HF      Fix for TR ???
 *                   Performance and accuracy improvements
 * 07/14/00  HF      Fix for TR 179901384
 * 01/17/01  HF      Remove all obsolete & SP related junk
 * 01/22/01  ah      Moved library to vds/lib
 * 02/11/01  HF      bsot_sn5.so/bsot_sn5.a is up-to-date;
 *                   No need for any BS functions anymore
 * 05/31/02  HF      Updated for 02.06.03.05, removed bs files (included
 *                   in new dynamic bspmath library 31-May-2002)
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
#else
VDdbg_glob.c 		/* for TR 179800857 */
VDdbgFlags.c
                /* fontserver assertions causing core dumps */
#endif

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vdidloadbsp.o
#else
$VDS/lib/vdidloadbsp.o
#endif

INCLUDE
$BS/include
$BS/igr_include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
.

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
