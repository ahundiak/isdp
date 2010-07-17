
/* $Id: VCsys.h,v 1.1.1.1 2001/01/04 21:12:35 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCsys.h
 *
 * Description:
 *
 *      Constants defining the VC system global switches
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCsys.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:35  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.2  1997/07/25  18:11:26  pinnacle
 * Replaced: vcinclude/VCsys.h for:  by hverstee for cabling
 *
 * Revision 1.1  1997/07/14  21:20:50  pinnacle
 * Created: vcinclude/VCsys.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *
 *************************************************************************/

#ifndef	VCsys_include
#define VCsys_include

#define  VCG_SYSPAR     "VC_syspar"

#define  VCG_PRESERVE   1
#define  VCG_DYNCPT     2
#define  VCG_OFFSET     3
#define  VCG_BRKCHR     4

#define  VCG_MAX        3

#define  VCT_INT     1
#define  VCT_DBL     2
#define  VCT_CHR     3

union  VCtypes
{
  IGRint        iF;
  IGRdouble     dF;
  IGRchar       cF[20];
};

struct VCsysbuf
{
  IGRshort          nType;
  IGRshort          nIndic;
  union   VCtypes   fld;
};

/*      define the globals       */

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
                    IGRboolean     VCSYSGLB_preserve;

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
                    IGRboolean     VCSYSGLB_dyncpt;

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
                    IGRboolean     VCSYSGLB_offset;

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
                    IGRchar        VCSYSGLB_brkchr[12];

#endif

