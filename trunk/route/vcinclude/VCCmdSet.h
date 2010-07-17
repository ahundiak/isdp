/* $Id: VCCmdSet.h,v 1.1.1.1 2001/01/04 21:12:34 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCCmdSet.h
 *
 * Description:
 *
 *      Gadgets for the general VCSetAtt (set/review attributes) form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmdSet.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.5  2000/03/13  17:06:38  pinnacle
 * Replaced: vcinclude/VCCmdSet.h for:  by lawaddel for route
 *
 * Revision 1.4  1998/12/22  17:03:58  pinnacle
 * Replaced: vcinclude/VCCmdSet.h for:  by lawaddel for route
 *
 * Revision 1.3  1998/06/24  19:10:14  pinnacle
 * tr179801131
 *
 * Revision 1.2  1998/06/15  20:10:48  pinnacle
 * Replaced: vcinclude/VCCmdSet.h for:  by lawaddel for route
 *
 * Revision 1.3  1998/02/18  10:11:22  pinnacle
 * Replaced: vcinclude/VCCmdSet.h for: TR179702189 by aharihar for route
 *
 * Revision 1.2  1998/02/03  13:59:48  pinnacle
 * Replaced: vcinclude/VCCmdSet.h for:  by apazhani for route
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.2  1997/07/25  18:11:38  pinnacle
 * Replaced: vcinclude/VCCmdSet.h for:  by hverstee for cabling
 *
 * Revision 1.1  1997/07/14  21:22:06  pinnacle
 * Created: vcinclude/VCCmdSet.h by hverstee for cabling
 *
 *
 * History:
 * MM/DD/YY   AUTHOR  DESCRIPTION
 * 05/27/96   hv      Initial
 * 02/03/98   Alwin   Added few gadets for CR179702192
 * 02/18/98   Anand   Added names to denote some gadgets' labels
 *                    in VCSetAtt form (TR 179702189)
 * 06/02/98   law     Added message field
 * 12/02/98   law     Add angle field
 * 03/06/00   law     Add cable/connector fields to guide form
 *************************************************************************/

#ifndef	VCCmdSet_include

#define	VCCmdSet_include

/*    Group gadgets            */

#define VCSET_GDGGRP_FENCE                         78
#define VCSET_GDGGRP_CABLE                        200
#define VCSET_GDGGRP_TERM                         300

/*    Titles                   */

#define VCSET_GDG_HDTERM                           15
#define VCSET_GDG_HDBKSH                           16
#define VCSET_GDG_HDGUIDE                          39
#define VCSET_GDG_HDCABLE                          79

/*    General                  */

#define VCSET_GDG_DESC                             49
#define VCSET_GDG_CCODE                            52
#define VCSET_GDG_TAGNO                            53

#define VCSET_GDG_ADDLAB                           59
#define VCSET_GDG_UNIT                             62
#define VCSET_GDG_SYSNM                            27
#define VCSET_GDG_MTO                              66
#define VCSET_GDG_NOTES                            61
#define VCSET_GDG_CHGNUM                           69
#define VCSET_GDG_APPRV                            63
#define VCSET_GDG_CONSTR                           28

#define VCSET_GDG_COPYBTN                          24
#define VCSET_GDG_USERBTN                          25

/*    erasable gadgets              */

#define VCSET_GDG_CCODE_TXT                        12   /*  */
#define VCSET_GDG_TAG_TXT                          50   /*  */
#define VCSET_GDG_DIAM_TXT                         80   /*  */
#define VCSET_GDG_DIAM_FLD                         27   /*  */

#define VCSET_GDG_AROT_TXT                         45
#define VCSET_GDG_AROT_FLD                         44
#define VCSET_GDG_SCALE_TXT                        76
#define VCSET_GDG_SCALE_FLD                        77

#define VCSET_GDG_DBSW                             17

/*    Fence group               */

#define VCSET_GDG_FENCE_UP                         75
#define VCSET_GDG_FENCE_DN                         74
#define VCSET_GDG_FENCE_FL                         73

/*   Guide gadgets for cr179900814  */
#define VCSET_GDG_GDUA_TXT                         60
#define VCSET_GDG_GDUA_FLD                         46
#define VCSET_GDG_GDUB_TXT                         64
#define VCSET_GDG_GDUB_FLD                         57
#define VCSET_GDG_GDCB_TXT                         65
#define VCSET_GDG_GDCB_FLD                         56
#define VCSET_GDG_TTXT_GTYP                        94
#define VCSET_GDG_TTXT_GTAG                        81

/*    Terminal group               */

#define VCSET_GDG_TERM_EQTYP                       20
#define VCSET_GDG_TERM_EQTAG                       21
#define VCSET_GDG_TERM_CMPAR                       37
#define VCSET_GDG_TERM_BKSH                        41

/* added by alwin */
#define VCSET_GDG_TERM_BKSH_LIST                   42
/* added by alwin */

#define VCSET_GDG_TERM_STOCK                       33
#define VCSET_GDG_TERM_CATAL                       34
#define VCSET_GDG_TERM_STAND                       18
#define VCSET_GDG_TERM_WGT                         36

#define VCSET_GDG_TTXT_EQTYP                       35
#define VCSET_GDG_TTXT_EQTAG                       19
#define VCSET_GDG_TTXT_CMPAR                       22
#define VCSET_GDG_TTXT_BKSH                        40

#define VCSET_GDG_TERM_VCBTN                       17
#define VCSET_GDG_TERM_CPBTN                       38

/*     Cable group             */

#define VCSET_GDG_CABA_EQTYP                       87
#define VCSET_GDG_CABA_EQTAG                       11
#define VCSET_GDG_CABA_TRTYP                       12
#define VCSET_GDG_CABA_TRTAG                      100
#define VCSET_GDG_CABA_BKSH                       102

	/* Following lines added by Anand */
#define VCSET_GDG_TTXT_CABA_EQTYP                  83
#define VCSET_GDG_TTXT_CABA_EQTAG                  85
#define VCSET_GDG_TTXT_CABA_TRTYP                  95
#define VCSET_GDG_TTXT_CABA_TRTAG                  96
#define VCSET_GDG_TTXT_CABA_BKSH                   98
	/*Above five lines added by Anand */


/*added by alwin */
#define VCSET_GDG_CABA_BKSH_LIST                  101
/*added by alwin */

#define VCSET_GDG_CABA_CMPAR                       91
#define VCSET_GDG_CABA_VCBTN                      113

#define VCSET_GDG_CABB_EQTYP                       93
#define VCSET_GDG_CABB_EQTAG                       30
#define VCSET_GDG_CABB_TRTYP                      103
#define VCSET_GDG_CABB_TRTAG                      104
#define VCSET_GDG_CABB_BKSH                       105

/*added by alwin */
#define VCSET_GDG_CABB_BKSH_LIST                   43
/*added by alwin */

#define VCSET_GDG_CABB_CMPAR                      109
#define VCSET_GDG_CABB_VCBTN                      110

#define VCSET_GDG_CAB_SWAP                        108

#define VCSET_GDG_CAB_TAILLGT                     114
#define VCSET_GDG_CAB_ESTLGT                      115

#define VCSET_GDG_CAB_CALCBTN                     116
#define VCSET_GDG_CAB_MOREBTN                      92

#define VCSET_GDG_MESSAGE                           9   /* law-TR179800042 */

#endif
