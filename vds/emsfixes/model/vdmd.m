/* $Id: vdmd.m,v 1.14 2002/06/10 14:40:31 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/model / VDMd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdmd.m,v $
 *	Revision 1.14  2002/06/10 14:40:31  hans
 *	Cleanup; removed all files that have been integrated into EMS
 *	
 *	Revision 1.13  2002/01/22 17:37:23  hans
 *	*** empty log message ***
 *	
 *	Revision 1.12  2002/01/16 18:19:44  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.11  2002/01/07 22:28:28  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.10  2001/08/25 14:41:09  ramarao
 *	Fixed a locate problem TR# 5355.
 *	
 *	Revision 1.9  2001/07/10 18:15:01  hans
 *	Fix for TR# 5409 (mass property crash)
 *	
 *	Revision 1.8  2001/06/22 14:54:05  hans
 *	No TR# Fix for sqrt() DOMAIN error
 *	
 *	Revision 1.7  2001/05/16 16:51:42  hans
 *	Fix for TR# MP4946
 *	
 *	Revision 1.6  2001/03/15 22:49:10  ramarao
 *	Fixed TR# 4115 && TR# 4099.
 *
 *	Revision 1.5  2001/03/15 14:52:40  hans
 *	Disable EMintf.I
 *
 *	Revision 1.4  2001/02/15 18:18:00  hans
 *	Fix for TR# MP4567
 *
 *	Revision 1.3  2001/01/22 19:16:53  ahundiak
 *	ah
 *
 *	Revision 1.2  2001/01/14 19:14:31  hans
 *	SP16 modifications
 *
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *
# Revision 1.4  2000/02/08  17:32:30  pinnacle
# (No comment)
#
# Revision 1.3  2000/01/05  05:03:20  pinnacle
# Replaced vdmd.m by jpulapar for loft
#
# Revision 1.2  1998/06/24  14:55:26  pinnacle
# tr179801103
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.6  1998/04/10  12:33:12  pinnacle
# TR179800681
#
# Revision 1.5  1998/04/04  00:03:44  pinnacle
# Replaced: emsfixes/model/vdmd.m for:  by impd for vds
#
# Revision 1.4  1998/03/13  17:53:30  pinnacle
# Replaced: emsfixes/model/vdmd.m for:  by impd for vds
#
# Revision 1.3  1998/03/09  23:34:46  pinnacle
# Replaced: emsfixes/model/vdmd.m for:  by impd for vds
#
# Revision 1.2  1998/03/06  16:00:24  pinnacle
# TR179800243
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1997/01/28  06:05:44  pinnacle
# Replaced: emsfixes/model/vdmd.m for:  by rgade for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/06/05  21:25:52  pinnacle
# Replaced: emsfixes/model/vdmd.m for:  by jwfrosch for vds.240
#
# Revision 1.3  1996/06/05  21:17:12  pinnacle
# Replaced: emsfixes/model/vdmd.m for:  by jwfrosch for vds.240
#
# Revision 1.2  1996/03/27  17:08:28  pinnacle
# Replaced: emsfixes/model/vdmd.m for:  by v240_int for vds.240
#
# Revision 1.1  1996/02/07  23:44:44  pinnacle
# Created: ./emsfixes/model/vdmd.m by azuurhou for vds.240
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/20/95  adz     Add EMssgetageom.I
 * 02/07/96  adz     Recreated for EMdprdeactst.I
 * 01/28/97  Ravi    Added EFgetcreator for TR#179604071
 * 03/06/98  ah      TR179800243 Vis edge crashing on infinite planes
 * 04/03/98  HF	     TR179800504 LOFT: Create Balanced Plates
 * 04/10/98  ah      TR179800681 Assoc Contour
 * 06/24/98  ah      TR179801103 Offset curve problem
 * 01/05/2000 Jaya   Added EMccoffset.I for unwrapTR179900860
 * 02/08/00  RR	     TR#179901004 Mass Properties problem.
 *		     Added EMcsMassProp.I and EFstrokecrv.c files to the list.
 * 01/22/01  ah      Moved library to vds/lib
 * 02/15/01  HF      Added cvintpt.c for TR# MP4567
 * 07/10/2001 HF     Added EFstrokecrv.c for TR# MP5409
 * 08/25/2001 RR     Fixed a locate problem TR# 5355
 * 01/07/2002 YL     Added EMrvGetRvFmt.I for ETL11699
 *
 * 01/22/2002 HF     The following list of files/fixes have been integrated
 *                   into the CVS ems/model source-tree:

 162 -rw-rw-rw-      82581 Jul 10  2001 EFmapthecrv.I
  24 -rw-rw-rw-      11846 Jul 10  2001 EFprjcvpln.I
  10 -rw-rw-rw-       4818 Jul 10  2001 EFstrokecrv.c
 112 -rw-rw-rw-      56678 Jul 10  2001 EMbndloopint.I
  10 -rw-rw-rw-       4475 Jul 10  2001 EMbsIntPln.I
  16 -rw-rw-rw-       7224 Jul 10  2001 EMbsOffset.I
  14 -rw-rw-rw-       7062 Jul 10  2001 EMbsgetpy.I
  32 -rw-rw-rw-      15833 Jul 10  2001 EMccaddtoc.I
  38 -rw-rw-rw-      18984 Jul 10  2001 EMccoffset.I
  26 -rw-rw-rw-      12339 Jan  4  2001 EMcsMassProp.I
   4 -rw-rw-rw-       2006 Jul 10  2001 EMdprdeactst.I
  26 -rw-rw-rw-      12348 Jul 10  2001 EMgnMvCrsNrm.I
  80 -rw-rw-rw-      39947 Jul 10  2001 EMintf.I
  42 -rw-rw-rw-      20959 Aug 25 09:41 EMlpbdryloc.I
  14 -rw-rw-rw-       6570 Jul 10  2001 EMrvGenAbs.I
  22 -rw-rw-rw-      10358 Jul 10  2001 EMssPrismRel.I
  18 -rw-rw-rw-       8224 Jul 10  2001 EMssgetageom.I
  42 -rw-rw-rw-      20593 Jul 10  2001 EMssredrange.I
  62 -rw-rw-rw-      31035 Jul 10  2001 cvintpt.c
  18 -rw-rw-rw-       8828 Jul 10  2001 edptproj.c

 * with the exception of:

  12 -rw-rw-rw-       5644 Jan  7 16:27 EMrvGetRvFmt.I
  30 -rw-rw-rw-      15313 Jul 10  2001 EFgetcreator.I  ==>> VDS    specific changes
  42 -rw-rw-rw-      21436 Jul 10  2001 EMcoll.C        ==>> VDS    specific changes
  10 -rw-rw-rw-       4274 Jul 10  2001 EMssmkwrfrm.I   ==>> STRUCT specific changes

 * so, in future, when a new EMS release is available, only these need to be
 * delivered as emsfixes !!
 *
 * 06/10/2002 HF     Cleanup:
                     For PLOAD ISPD 02.06.03.07 & EMS 03.04.00.12 removed all files, except:

  30 -rw-rw-rw-      15313 Jul 10  2001 EFgetcreator.I  ==>> VDS    specific changes
  42 -rw-rw-rw-      21436 Jul 10  2001 EMcoll.C        ==>> VDS    specific changes

 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
#else
EFgetcreator.I
EMcoll.C 	/* TR 179800243 */
#endif

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vdidloadmodel.o
#else
#if 0
$VDS/etc/needed_dload/dloadmodel.o
#else
$VDS/lib/vdidloadmodel.o
#endif
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$GRNUC/ingrsys
$MODEL/include
$MODEL/proto_include
$GRNUC/src/assoc/include_priv
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
