/* $Id: VRcor_funk.I,v 1.4 2002/04/10 18:13:19 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcorrection / VRcor_funk.I
 *
 * Description:
 * 	util functions 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcor_funk.I,v $
 *	Revision 1.4  2002/04/10 18:13:19  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.3  2001/05/18 16:55:43  anand
 *	Added support for optional VREndPrep.u PPL (in API directory) to overwrite software's verify().
 *	
 *	Revision 1.2  2001/02/20 01:13:26  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:50  cvs
 *	Initial import to CVS
 *	
# Revision 1.7  2000/01/25  18:53:26  pinnacle
# Replaced: vrcorrection/VRcor_funk.I for:  by lawaddel for route
#
# Revision 1.6  1999/05/17  12:06:32  pinnacle
# Replaced: vrcorrection/VRcor_funk.I for:  by sbilla for route
#
# Revision 1.5  1999/05/14  22:10:16  pinnacle
# Replaced: vrcorrection/VRcor_funk.I for:  by lawaddel for route
#
# Revision 1.2  1998/11/06  22:45:32  pinnacle
# Replaced: vrcorrection/VRcor_funk.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/01/14  18:42:42  pinnacle
# Replaced: vrcorrection/VRcor_funk.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/04/05  18:35:12  pinnacle
# Replaced: vrcorrection/VRcor_funk.I for:  by msmanem for route240
#
# Revision 1.5  1996/01/16  23:26:48  pinnacle
# Replaced: vrcorrection/VRcor_funk.I for:  by r240_int for route240
#
 *
 * History:
 *     	10/14/94   Lori  	Make socket end prep components 
 *                               codelist 401,402,421 intercompatible
 *				 i.e. no flange is placed between
 *				 TR#179307962 - function verify
 *     	06/14/95   Lori  	Modify GetTempAttr to stop making
 *                               unnecessary clones of collection 
 *                               objects.  TR#179420979
 *	06/19/95   Manyam 	Make prep values 441 and 391( but
 *				   internally always pipe end prep
 *			 	   is hardcoded to 301 in VREvaluate.
 *				   Thus making compatible with 301) 
 *				   compatible ( no flange in between )
 *				   TR#179524955.
 *	01/15/96  tlb		Add prototypes
 *				Modify call to VRMkTransShape
 *	04/05/96  msm		Fix for TR #179600329
 *				Modified VRChgCorCmpAttr to modify the collector
 *				only if component parameters are modified.
 *				Now a new collector is created for the corr.
 *				component, if the attributes are different and
 *				the parent has more than one child. Earlier the
 *				parent collector was getting messed up there by
 *				the entire network was getting messed up.
 *      12/22/97  law           CR179309874 Added VR_ELLIPSE shapecode
 *      11/01/98  law           tr179801939-errors in tier processing
 *      05/04/99  Reddy         Doble value comparision corrected
 *      05/14/99  Reddy         CR179800491 - Variable Tier spacing in Raceways
 *				is stored in the collector .
 *      05.17.99  Reddy         Arguments of VRFetchTierdata changed 
 *      01/25/00    law         tr179900976 - transition failures
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/


class implementation VRCorrection;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/
#include <math.h>

#include "nddef.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "ACattrib.h"
#include "VRattr_def.h"
#include "VRpriv_attr.h"
#include "VRact_params.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRprivmacros.h"
#include "vrparameters.h"
#include "AS_status.h"
#include "VRMath.h"
#include "vrtools_pto.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bspt_on_lne.h"

#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "v_datamacros.h"

#include "VRRwDimen.h"

#include "VDtypedef.h"	// Added by Anand
#include "VDppl1.h"	// Added by Anand

#define AS_DEBUG 1

from	VRGeneric	import	VRGetCptGeom, VRGetParams, VRGetOrigCoor;
from    VRGeneric       import  VRGetNeighbors;
from	ACncpx		import	ACset_NV_rep;

/*********************************************************/

IGRboolean verify(IGRint end_treat1, IGRint end_treat2)
{
    IGRint 	i;
    IGRboolean 	ok;

    IGRint FFFE[14]; 	/* (11) */
    IGRint FFFEWG[14];	/* (16) */
    IGRint RFFE[13];	/* (21) */
    IGRint RFFEWG[12];	/* (26) */
    IGRint RJFE[5];	/* (31) */
    IGRint STFE[2];	/* (41) */
    IGRint LTFE[2]; 	/* (42) */
    IGRint SMFE[2];	/* (43) */
    IGRint LMFE[2];	/* (44) */
    IGRint SGFE[2];	/* (51) */
    IGRint LGFE[2];	/* (52) */
    IGRint SFFE[2];	/* (53) */
    IGRint LFFE[2];	/* (54) */
    IGRint FFLFE[10];	/* (61) */
    IGRint RFLFE[11];	/* (71) */ 
    IGRint RJLFE[4];	/* (81) */
    IGRint STLFE[2];	/* (91) */
    IGRint LTLFE[2];	/* (92) */
    IGRint SMLFE[2];	/* (93) */
    IGRint LMLFE[2];	/* (94) */
    IGRint SGLFE[2];	/* (101) */
    IGRint LGLFE[2];	/* (102) */
    IGRint SFLFE[2];	/* (103) */
    IGRint LFLFE[2];	/* (104) */
    IGRint FFTBE[11];	/* (111) */ 
    IGRint FFTBEWG[11];	/* (116) */ 
    IGRint RFTBE[12];	/* (121) */
    IGRint RFTBEWG[11];	/* (126) */ 
    IGRint RJTBE[5];	/* (131) */
    IGRint MRJTBEWG[3];	/* (146) */
    IGRint FFTBCSE[3];	/* (151) */
    IGRint FFTBCSEWG[3];/* (156) */
    IGRint RFTBCSE[3];	/* (161) */
    IGRint RFTBCSEWG[3];/* (166) */
    IGRint RJTBCSE[2];	/* (171) */
    IGRint FFFTBE[3];	/* (181) */
    IGRint FFFTBEWG[3];	/* (186) */
    IGRint MJE[1];	/* (191) */
    IGRint BE[7];	/* (301) */
    IGRint TBE[5];	/* (311) */
    IGRint MFE[4];	/* (321) */ 
    IGRint MTE[1];	/* (331) */
    IGRint MGE[1];	/* (341) */
    IGRint MQCE[1];	/* (351) */
    IGRint MFRE[1];	/* (361) */
    IGRint MHE[1];	/* (371) */
    IGRint SPE[1];	/* (381) */
    IGRint PE[8];	/* (391) */
    IGRint FFPE3[1];	/* (393) */
    IGRint FFPE6[1];	/* (395) */
    IGRint SE[5];	/* (401) */
    IGRint SBE[5];	/* (402) */
    IGRint SWE[6];	/* (421) */
    IGRint FTE[4];	/* (441) */ 
    IGRint FGE[1];	/* (461) */
    IGRint FQCE[1];	/* (481) */
    IGRint FFRE[1];	/* (501) */
    IGRint FHE[1];	/* (521) */ 
    IGRint BLE[1];	/* (541) */ 
    IGRint HCE[5];	/* (591) */

    /* Below lines added by Anand */
    struct GRid 	pplID ;
    IGRint		pplRET ;

    __DBGpr_int(" End Prep 1 is", end_treat1);
    __DBGpr_int(" End Prep 2 is", end_treat2);

    /* Load ppl */
    __DBGpr_com( " PPL is going to be loaded ");
    vdppl$Load(name = "VREndPrep", pplID = &pplID);

    if (pplID.objid != NULL_OBJID) 
    {
	__DBGpr_com( " PPL is loaded ");

	/* Set the two input arguments (the two end preparations) in the
	    * ppl by calling the setData */

	vdppl$SetData(  pplID = &pplID,
			name  = "end_treat1",
			size  = sizeof(int),
			data  = (IGRchar*) &end_treat1 );

	vdppl$SetData( pplID = &pplID,
			name  = "end_treat2",
			size  = sizeof(int),
			data  = (IGRchar*) &end_treat2 );

	vdppl$Run( pplID = &pplID,
		    name = "VRChkEndPrepCmpblty",
		    ret = &pplRET );

	/* Get  the variable from the ppl by calling the GetData on
	 * bCmptble which is the output from the ppl  */

	vdppl$GetData(
		pplID = &pplID,
		name  = "bCmptble",
		size  = sizeof(int),
		data  = (IGRchar*) &ok );

	vdppl$Delete(pplID = &pplID);

	__DBGpr_int(" End Prep 1 is", end_treat1);
	__DBGpr_int(" End Prep 2 is", end_treat2);
	__DBGpr_int(" End Prep compatibility is", ok);

	return ok;
    }

    __DBGpr_com(" Loading of PPL failed! Using hard-coded matrix");
    /* Above lines added by Anand */


    FFFE[0]  = 11;   FFFE[1]  = 16;   FFFE[2]  = 21;   FFFE[3]  = 26;
    FFFE[4]  = 61;   FFFE[5]  = 71;   FFFE[6]  = 111;  FFFE[7]  = 116;
    FFFE[8]  = 121;  FFFE[9]  = 126;  FFFE[10] = 151;  FFFE[11] = 156;
    FFFE[12] = 181;  FFFE[13] = 186;

    FFFEWG[0] = 11;   FFFEWG[1] = 16;   FFFEWG[2] = 21;   FFFEWG[3] = 26;
    FFFEWG[4] = 61;   FFFEWG[5] = 71;   FFFEWG[6] = 111;   FFFEWG[7] = 116;
    FFFEWG[8] = 121;   FFFEWG[9] = 126;   FFFEWG[10] = 151;   FFFEWG[11] = 156;
    FFFEWG[12] = 181;   FFFEWG[13] = 186;


    RFFE[0] = 11;   RFFE[1] = 16;   RFFE[2] = 21;   RFFE[3] = 26;
    RFFE[4] = 61;   RFFE[5] = 71;   RFFE[6] = 111;   RFFE[7] = 116;
    RFFE[8] = 121;   RFFE[9] = 126;   RFFE[10] = 161;   RFFE[11] = 166;
    RFFE[12] = 321;   

    RFFEWG[0] = 11;   RFFEWG[1] = 16;   RFFEWG[2] = 21;   RFFEWG[3] = 26;
    RFFEWG[4] = 61;   RFFEWG[5] = 71;   RFFEWG[6] = 111;   RFFEWG[7] = 116;
    RFFEWG[8] = 121;   RFFEWG[9] = 126;   RFFEWG[10] = 161;   RFFEWG[11] = 166;


    RJFE[0] = 31;   RJFE[1] = 81;   RJFE[2] = 131;   RJFE[3] = 146;
    RJFE[4] = 171;

    STFE[0] = 51;   STFE[1] = 101;

    LTFE[0] = 52;   LTFE[1] = 102;

    SMFE[0] = 53;   SMFE[1] = 103;

    LMFE[0] = 54;   LMFE[1] = 104;

    SGFE[0] = 41;   SGFE[1] = 91;

    LGFE[0] = 42;   LGFE[1] = 92;

    SFFE[0] = 43;   SFFE[1] = 93;

    LFFE[0] = 44;   LFFE[1] = 94;

    FFLFE[0] = 11;   FFLFE[1] = 16;
    FFLFE[2] = 21;   FFLFE[3] = 26;   FFLFE[4] = 61;   FFLFE[5] = 71;
    FFLFE[6] = 111;   FFLFE[7] = 116;   FFLFE[8] = 121;   FFLFE[9] = 126;

    RFLFE[0] = 11;   RFLFE[1] = 16;   RFLFE[2] = 21;   RFLFE[3] = 26;
    RFLFE[4] = 61;   RFLFE[5] = 71;   RFLFE[6] = 111;   RFLFE[7] = 116;
    RFLFE[8] = 121;   RFLFE[9] = 126;   RFLFE[10] = 321;

    RJLFE[0] = 31;   RJLFE[1] = 81;   RJLFE[2] = 131;   RJLFE[3] = 146;

    STLFE[0] = 51;   STLFE[1] = 101;

    LTLFE[0] = 52;   LTLFE[1] = 102;

    SMLFE[0] = 53;   SMLFE[1] = 103;

    LMLFE[0] = 54;   LMLFE[1] = 104;

    SGLFE[0] = 41;   SGLFE[1] = 91;

    LGLFE[0] = 42;   LGLFE[1] = 92;

    SFLFE[0] = 43;   SFLFE[1] = 93;

    LFLFE[0] = 44;   LFLFE[1] = 94;

    FFTBE[0] = 11;   FFTBE[1] = 16;   FFTBE[2] = 21;   FFTBE[3] = 26;
    FFTBE[4] = 61;   FFTBE[5] = 71;   FFTBE[6] = 111;   FFTBE[7] = 116;
    FFTBE[8] = 121;   FFTBE[9] = 126;   FFTBE[10] = 151;

    FFTBEWG[0] = 11;   FFTBEWG[1] = 16;   FFTBEWG[2] = 21;   FFTBEWG[3] = 26;
    FFTBEWG[4] = 61;   FFTBEWG[5] = 71;   FFTBEWG[6] = 111;   FFTBEWG[7] = 116;
    FFTBEWG[8] = 121;   FFTBEWG[9] = 126;   FFTBEWG[10] = 156;

    RFTBE[0] = 11;   RFTBE[1] = 16;   RFTBE[2] = 21;   RFTBE[3] = 26;
    RFTBE[4] = 61;   RFTBE[5] = 71;   RFTBE[6] = 111;   RFTBE[7] = 116;
    RFTBE[8] = 121;   RFTBE[9] = 126;   RFTBE[10] = 161;   RFTBE[11] = 321;

    RFTBEWG[0] = 11;   RFTBEWG[1] = 16;   RFTBEWG[2] = 21;   RFTBEWG[3] = 26;
    RFTBEWG[4] = 61;   RFTBEWG[5] = 71;   RFTBEWG[6] = 111;
    RFTBEWG[7] = 116;   RFTBEWG[8] = 121;   RFTBEWG[9] = 126;
    RFTBEWG[10] = 166;

    RJTBE[0] = 31;   RJTBE[1] = 81;   RJTBE[2] = 131;   RJTBE[3] = 146;
    RJTBE[4] = 171;

    MRJTBEWG[0] = 31;   MRJTBEWG[1] = 81;   MRJTBEWG[2] = 131;

    FFTBCSE[0] = 11;   FFTBCSE[1] = 16;   FFTBCSE[2] = 111;

    FFTBCSEWG[0] = 11;   FFTBCSEWG[1] = 16;   FFTBCSEWG[2] = 116;

    RFTBCSE[0] = 21;   RFTBCSE[1] = 26;   RFTBCSE[2] = 121;

    RFTBCSEWG[0] = 21;   RFTBCSEWG[1] = 26;   RFTBCSEWG[2] = 126;

    RJTBCSE[0] = 31;   RJTBCSE[1] = 131;

    FFFTBE[0] = 11;   FFFTBE[1] = 16;   FFFTBE[2] = 181;

    FFFTBEWG[0] = 11;   FFFTBEWG[1] = 16;   FFFTBEWG[2] = 186;

    MJE[0] = 191;

    BE[0] = 301;   BE[1] = 311;   BE[2] = 391;   BE[3] = 401;   BE[4] = 402;
    BE[5] = 421;   BE[6] = 591;


    TBE[0] = 301;   TBE[1] = 311;   TBE[2] = 391;   TBE[3] = 421;
    TBE[4] = 591;

    MFE[0] = 21;   MFE[1] = 71;   MFE[2] = 121;   MFE[3] = 321;

    MTE[0] = 441;

    MGE[0] = 461;

    MQCE[0] = 481;

    MFRE[0] = 501;

    MHE[0] = 521;

    SPE[0] = 541;

    PE[0] = 391;   PE[1] = 301;   PE[2] = 311;   PE[3] = 401;   PE[4] = 402;
    PE[5] = 421;   PE[6] = 441;   PE[7] = 591;

    FFPE3[0] = 591;

    FFPE6[0] = 591;

    SE[0] = 301;   SE[1] = 391; SE[2] = 401; SE[3] = 402; SE[4] = 421;

    SBE[0] = 301;   SBE[1] = 391; SBE[2] = 401; SBE[3] = 402; SBE[4] = 421;

    SWE[0] = 301;   SWE[1] = 311;   SWE[2] = 391; SWE[3] = 401; SWE[4] = 402; SWE[5] = 421;

    FTE[0] = 331;   FTE[1] = 391;	  FTE[2] = 301;	   FTE[3] = 441;

    FGE[0] = 341;

    FQCE[0] = 351;

    FFRE[0] = 361;

    FHE[0] = 371;

    BLE[0] = 381;

    HCE[0] = 301;   HCE[1] = 311;   HCE[2] = 391;   HCE[3] = 393;
    HCE[4] = 395;

    /* ------------------------- search ------------------- */

    if( end_treat1 == 11 ) 
    {
	for( i=0; i<14; i++ )
	{
	    if( end_treat2 == FFFE[i] )
		return(TRUE);
	}
	return(FALSE);
    }

    if( end_treat1 == 16 ) 
    {
	for (i=0;i<14;i++)
	{
	    if (end_treat2 == FFFEWG[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 21) 
    {   
	for (i=0;i<13;i++)
	{  
	    if (end_treat2 == RFFE[i])
		return(TRUE);
	}
	return(FALSE);
    }


    if (end_treat1 == 26) 
    {   
	for (i=0;i<12;i++)
	{
	    if (end_treat2 ==  RFFEWG[i])
		return(TRUE);
	}
	return(FALSE);
    }


    if (end_treat1 == 31) 
    { 
	for (i=0;i<5;i++)
	{
	    if (end_treat2 ==  RJFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 41) 
    { 
	for (i=0;i<2;i++)
	{
	    if (end_treat2 ==  STFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 42) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 ==  LTFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 43) 
    {  
	for (i=0;i<2;i++)
	{
	    if (end_treat2 == SMFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 44) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 ==  LMFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 51) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 ==  SGFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 52) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 ==  LGFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 53) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 ==  SFFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 54) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 ==  LFFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 61) 
    {
	for (i=0;i<10;i++)
	{
	    if (end_treat2 ==  FFLFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 71) 
    {
	for (i=0;i<11;i++)
	{
	    if (end_treat2 == RFLFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 81) 
    {
	for (i=0;i<4;i++)
	{
	    if (end_treat2 == RJLFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 91) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 == STLFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 92) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 == LTLFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 93) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 == SMLFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 94) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 == LMLFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 101) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 == SGLFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 102) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 == LGLFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 103) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 == SFLFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 104) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 == LFLFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 111) 
    {
	for (i=0;i<11;i++)
	{
	    if (end_treat2 == FFTBE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 116) 
    {
	for (i=0;i<11;i++)
	{
	    if (end_treat2 == FFTBEWG[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 121) 
    {
	for (i=0;i<12;i++)
	{
	    if (end_treat2 == RFTBE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 126) 
    {
	for (i=0;i<11;i++)
	{
	    if (end_treat2 == RFTBEWG[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 131) 
    {
	for (i=0;i<5;i++)
	{
	    if (end_treat2 == RJTBE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 146) 
    {
	for (i=0;i<3;i++)
	{
	    if (end_treat2 == MRJTBEWG[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 151) 
    {
	for (i=0;i<3;i++)
	{
	    if (end_treat2 == FFTBCSE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 156) 
    {
	for (i=0;i<3;i++)
	{
	    if (end_treat2 == FFTBCSEWG[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 161) 
    {
	for (i=0;i<3;i++)
	{
	    if (end_treat2 == RFTBCSE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 166) 
    {
	for (i=0;i<3;i++)
	{
	    if (end_treat2 == RFTBCSEWG[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 171) 
    {
	for (i=0;i<2;i++)
	{
	    if (end_treat2 == RJTBCSE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 181) 
    {
	for (i=0;i<3;i++)
	{
	    if (end_treat2 == FFFTBE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 186) 
    {
	for (i=0;i<3;i++)
	{
	    if (end_treat2 == FFFTBEWG[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 191) 
    {
	ok = (end_treat2 == MJE[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 301) 
    {
	for (i=0;i<7;i++)
	{
	    if (end_treat2 == BE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 311) 
    {
	for (i=0;i<5;i++)
	{
	    if (end_treat2 == TBE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 321) 
    {
	for (i=0;i<4;i++)
	{
	    if (end_treat2 == MFE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 331) 
    {
	ok = (end_treat2 == MTE[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 341) 
    {
	ok = (end_treat2 ==  MGE[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 351) 
    {
	ok = (end_treat2 ==  MQCE[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 361) 
    {
	ok = (end_treat2 == MFRE[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 371) 
    {
	ok = (end_treat2 == MHE[0]) ? TRUE : FALSE;
	return(ok);
    }


    if (end_treat1 == 381) 
    {
	ok = (end_treat2 == SPE[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 391) 
    {
	for (i=0;i<8;i++)
	{
	    if (end_treat2 == PE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 393) 
    {
	ok = (end_treat2 == FFPE3[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 395) 
    {
	ok = (end_treat2 ==  FFPE6[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 401) 
    {
	for (i=0;i<5;i++)
	{
	    if (end_treat2 == SE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 402) 
    {
	for (i=0;i<5;i++)
	{
	    if (end_treat2 == SBE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 421) 
    {
	for (i=0;i<6;i++)
	{
	    if (end_treat2 == SWE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 441) 
    {
	for (i=0;i<4;i++)
	{
	    if (end_treat2 == FTE[i])
		return(TRUE);
	}
	return(FALSE);
    }

    if (end_treat1 == 461) 
    {
	ok = (end_treat2 == FGE[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 481) 
    {
	ok = (end_treat2 ==  FQCE[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 501) 
    {
	ok = (end_treat2 ==  FFRE[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 521) 
    {
	ok = (end_treat2 == FHE[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 541)
    {
	ok = (end_treat2 ==  BLE[0]) ? TRUE : FALSE;
	return(ok);
    }

    if (end_treat1 == 591) 
    {
	for (i=0;i<5;i++)
	{
	    if (end_treat2 == HCE[i])
		return(TRUE);
	}
    }

    return(FALSE);

}

/*****************************************************************************/

IGRboolean VRInsertValid( CmpCptIndex, CmpId, md_env )

IGRshort		*CmpCptIndex;
struct	GRid		*CmpId;
struct	GRmd_env	*md_env;

/*.VRInsertValid */
{
  IGRboolean	GoodPoint;
  IGRlong	bsretcode;
  IGRlong	status, retcode;
  IGRdouble	Uparams;
  IGRpoint	OrigCoor, Cpt0, Cpt1;
  IGRvector	CptVect;

  SetProc ( VRInsertValid ); Begin

  /* -- Check whether the CmpCptIndex equals -1 and return FALSE if so -- */
  if ( CmpCptIndex[0] == -1 || CmpCptIndex[1] == -1 ) return FALSE;

  status = om$send( msg      = message VRGeneric.VRGetCptGeom
                               ( &retcode, CmpCptIndex[0], Cpt0, NULL, NULL,
                                 md_env ),
                    senderid = NULL_OBJID,
                    targetid = CmpId[0].objid,
                    targetos = CmpId[0].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"Cpt0 = %f %f %f\n", Cpt0[0], Cpt0[1], Cpt0[2] */

  status = om$send( msg      = message VRGeneric.VRGetOrigCoor 
					( &retcode, OrigCoor, md_env ),
                    senderid = NULL_OBJID,
                    targetid = CmpId[1].objid,
                    targetos = CmpId[1].osnum );

  /*"orig = %f %f %f\n", OrigCoor[0], OrigCoor[1], OrigCoor[2] */

  status = om$send( msg      = message VRGeneric.VRGetCptGeom
                               ( &retcode, CmpCptIndex[1], Cpt1, NULL, NULL, 
                                 md_env ),
                    senderid = NULL_OBJID,
                    targetid = CmpId[1].objid,
                    targetos = CmpId[1].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"Cpt1 = %f %f %f\n", Cpt1[0], Cpt1[1], Cpt1[2] */

  BSmkvec( &bsretcode, CptVect, Cpt0, Cpt1 );
  if( BSlenvec( &bsretcode, CptVect ) < VRGetTol(VR_LENGTH_TOL) ) return FALSE;

  BSmkvec( &bsretcode, CptVect, OrigCoor, Cpt1 );
  if( BSlenvec( &bsretcode, CptVect ) < VRGetTol(VR_LENGTH_TOL) )
  {
	/* some components have their origin and Cpt coincident */
	return TRUE;
  }

  /* look if Cpt0 is between Orig and Cpt1 */
  BSpt_on_lne( &bsretcode, OrigCoor, Cpt1, Cpt0, &Uparams, &GoodPoint );

  if( GoodPoint ) return FALSE;

  End
  return TRUE;
  
}

/*****************************************************************************/

VRChgCorCmpAttrs
	( retmsg, Product, CorCmpId, CorCmpParams, Representation, md_env )

IGRlong				*retmsg;
IGRshort			Product;
struct		GRid		*CorCmpId;
union		VRparam_attr	*CorCmpParams;
IGRchar				Representation;
struct		GRmd_env	*md_env;

/*. VRChgCorCmpAttrs */
{
  IGRlong		status=OM_S_SUCCESS, retcode=MSSUCC;
  IGRint		nb_child;
  struct  GRid		CorActParamId, NewActParamId, *list_child;
  IGRboolean		param_changed = FALSE;
  union	  VRparam_attr	ActParams;

  SetProc ( VRChgCorCmpAttrs ); Begin

  /*| Initialize return codes */

  *retmsg = MSSUCC;

  if( !CorCmpId ) return OM_E_INVARG;

  __DBGpr_obj( "change attributs of CorCmpId", *CorCmpId );

  status = om$send( msg      = message VRGeneric.VRGetParams
                                       ( &retcode, &CorActParamId, NULL, NULL ),
		    senderid = NULL_OBJID,
		    targetid = CorCmpId->objid,
		    targetos = CorCmpId->osnum  );
  as$status( action = RET_STATUS );
  
  status = VR$GetDimensionAttributes (  p_retmsg	  = &retcode,
					Product		  = Product,
					p_SysCollectionId = &CorActParamId,
					p_DimAttributes	  = &ActParams,
					p_MdEnv		  = md_env );

  __DBGpr_obj ( "CorActParamId ", CorActParamId );
  switch( Product )
  {
	case VR_PIPING :
        /*BILLA  Double value comparison problem */
        if( ( fabs( ActParams.piping_attr.G_diameter -
                    CorCmpParams->piping_attr.R_diameter ) < VRGetTol(VR_DIST_TOL) ) &&
            ( fabs( ActParams.piping_attr.R_diameter -
                    CorCmpParams->piping_attr.G_diameter ) < VRGetTol(VR_DIST_TOL) ) )
	{
	    __DBGpr_com ("Active Piping Parameters == Corr Cmp params" );
	    param_changed = FALSE;
	}
	else
	    param_changed = TRUE;
	break;

	case VR_RWAY :
        /* TR179801939 Add rectangular processing */
        if (( ActParams.hvac_attr.shape == CorCmpParams->hvac_attr.shape ) &&
              ActParams.hvac_attr.shape == VR_RECT)
        {
          IGRint TmpNbNei, Idum;
          struct GRid TmpIds[2];
          IGRshort nTmp[2];
          struct ACrg_coll  NewListAttr[10];
          IGRint FootIndex=-1, intmsg, NbAttr;
          struct ret_struct TmpParam;
	  IGRchar no_tier_str[50];
	  IGRchar sp_tier_str[50], tier_str1[256], tier_str2[256];
          IGRint no_tiers_1 , no_tiers_2 ;

           __DBGpr_obj (" XXXXXXXXXXXXXXXXXXXXXXCorentity id " ,*CorCmpId);
           /* Get the tier data from the component */
           /* If the G/R tier data is different */
           /* Find out which cpts  it is connected */

           status= om$send ( msg = message VRGeneric.VRGetNeighbors
                                        ( &retcode, 0, 1, &TmpNbNei,
                                        TmpIds,
                                        nTmp, md_env),
                                senderid = NULL_OBJID,
                                targetid = CorCmpId->objid,
                                targetos = CorCmpId->osnum);

	 __DBGpr_obj(" cpt0 of correction is attached to ",TmpIds[0]);
	 __DBGpr_obj(" cpt1 of correction is attached to ",TmpIds[1]);
	 __DBGpr_int(" the cpt index on the attached component is ",nTmp[0]);
	 __DBGpr_int(" the cpt index on the attached component is ",nTmp[1]);

         __DBGpr_int(" the number of neighbors attached to correction is ",TmpNbNei);
	/** Processing for cpt1 ****/

	/******  CR179900491 -- Variable Tier space processing **/
        Idum = (int)nTmp[0]+1;
          status = VRFetchTierdata(md_env,Idum,
                                    TmpIds[0], 0, &no_tiers_1, tier_str1);

        Idum = (int)nTmp[1]+1; 

	/*Reddy -(int)nTmp[0]+2 changed to (int)nTmp[1]+1 and cpt index is 
          changed from 1 to 0  */

          status = VRFetchTierdata(md_env,Idum,
                                    TmpIds[1], 0, &no_tiers_2, tier_str2);

	 __DBGpr_int( " No. of tiers on connect pt. 0 are " , no_tiers_1) ;
	 __DBGpr_int( " No. of tiers on connect pt. 1 are " , no_tiers_2) ;
	 __DBGpr_str( " Spacing0 string value ", tier_str1 );
	 __DBGpr_str( " Spacing1 string value ", tier_str2 );

/*
	 VR_Build_Tier_Str( (int)nTmp[0]+1,0,sp_tier_str,no_tier_str);

	__DBGpr_str( "no_tier_str is ", no_tier_str);
	__DBGpr_str( " sp_tier_str is ",sp_tier_str);
         status = om$send( msg = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, no_tier_str,
                                 &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = TmpIds[0].objid,
                      targetos = TmpIds[0].osnum );

         no_tiers_1 = (IGRint) TmpParam.var.root_pm_st.value;
	 __DBGpr_int( " No. of tiers on connect pt. 0 are " , no_tiers_1) ;

         status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, sp_tier_str,
                                 &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = TmpIds[0].objid,
                      targetos = TmpIds[0].osnum );

	 strcpy( tier_str1, TmpParam.var.text_st.text_string );
	 __DBGpr_str( " Spacing string value ", tier_str1 );
*/
	/** Processing for cpt2 ****/
/*
	 VR_Build_Tier_Str((int)nTmp[1]+1,0,sp_tier_str,no_tier_str);

	__DBGpr_str( "no_tier_str is ", no_tier_str);
	__DBGpr_str( " sp_tier_stris ",sp_tier_str);

         status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, no_tier_str,
                                 &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = TmpIds[1].objid,
                      targetos = TmpIds[1].osnum );

         no_tiers_2 = (IGRint) TmpParam.var.root_pm_st.value;
	 __DBGpr_int( " No. of tiers on connect pt. 2 are " , no_tiers_2) ;

         status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, sp_tier_str,
                                 &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = TmpIds[1].objid,
                      targetos = TmpIds[1].osnum );

	 strcpy( tier_str2, TmpParam.var.text_st.text_string );
	 __DBGpr_str( " Spacing string value ", tier_str2 );
*/
	 /********************/

         NbAttr = 0;
         strcpy(NewListAttr[NbAttr].name, VR_N_NUMTIER1_IN);
         NewListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
         NewListAttr[NbAttr].desc.value.att_exp = (double)no_tiers_1;
         NbAttr++;

         strcpy(NewListAttr[NbAttr].name, VR_N_NUMTIER2_IN);
         NewListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
         NewListAttr[NbAttr].desc.value.att_exp = (double)no_tiers_2;
         NbAttr++;

	 VR_Build_Tier_Str( 1, 0, sp_tier_str, NULL);

	 __DBGpr_str( "no_tier_str is ", no_tier_str);
	 __DBGpr_str( " sp_tier_stris ",sp_tier_str);

         strcpy( NewListAttr[NbAttr].name, sp_tier_str );
         NewListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
         strcpy( NewListAttr[NbAttr].desc.value.att_txt, tier_str1 );
         NbAttr++;

	 VR_Build_Tier_Str( 2, 0, sp_tier_str, NULL);
         strcpy( NewListAttr[NbAttr].name, sp_tier_str );
         NewListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
         strcpy( NewListAttr[NbAttr].desc.value.att_txt, tier_str2 );
         NbAttr++;

	 /****
         strcpy( NewListAttr[NbAttr].name, VR_N_TIERSP1_DB);
         NewListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
         NewListAttr[NbAttr].desc.value.att_exp = tier_sp;
         NbAttr++;

         strcpy( NewListAttr[NbAttr].name, VR_N_TIERSP2_DB);
         NewListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
         NewListAttr[NbAttr].desc.value.att_exp = tier_sp;
         NbAttr++;
	 ****/

         status = VR$ModifyCollection(
                            p_msg                   = &retcode,
                            Operation               = VR_MERGE_COLL,
                            p_ParamsListToModify    = NewListAttr,
                            NbParamsToModify        = NbAttr,
                            p_OutputCollectionId    = &CorActParamId );
         as$status();

        }

	case VR_HVAC :
	__DBGpr_int ("ActParams.hvac_attr.shape ", ActParams.hvac_attr.shape );
	__DBGpr_dbl ("ActParams.hvac_attr.G_width ", ActParams.hvac_attr.G_width );
	__DBGpr_dbl ("ActParams.hvac_attr.G_depth ", ActParams.hvac_attr.G_depth );
	__DBGpr_dbl ("ActParams.hvac_attr.R_width ", ActParams.hvac_attr.R_width );
	__DBGpr_dbl ("ActParams.hvac_attr.R_depth ", ActParams.hvac_attr.R_depth );

	__DBGpr_int ("CorCmpParams->hvac_attr.shape ", CorCmpParams->hvac_attr.shape );
	__DBGpr_dbl ("CorCmpParams->hvac_attr.G_width ", CorCmpParams->hvac_attr.G_width );
	__DBGpr_dbl ("CorCmpParams->hvac_attr.G_depth ", CorCmpParams->hvac_attr.G_depth );
	__DBGpr_dbl ("CorCmpParams->hvac_attr.R_width ", CorCmpParams->hvac_attr.R_width );
	__DBGpr_dbl ("CorCmpParams->hvac_attr.R_depth ", CorCmpParams->hvac_attr.R_depth );



        if (( ActParams.hvac_attr.shape == CorCmpParams->hvac_attr.shape )
                &&
            (fabs( ActParams.hvac_attr.G_width - CorCmpParams->hvac_attr.G_width
 ) < VRGetTol(VR_DIST_TOL))
                &&
            (fabs( ActParams.hvac_attr.G_depth - CorCmpParams->hvac_attr.G_depth
 ) < VRGetTol(VR_DIST_TOL))
                &&
            (fabs( ActParams.hvac_attr.R_width - CorCmpParams->hvac_attr.R_width
 ) < VRGetTol(VR_DIST_TOL))
                &&
            (fabs( ActParams.hvac_attr.R_depth - CorCmpParams->hvac_attr.R_depth
 ) < VRGetTol(VR_DIST_TOL) ))

	{
	    __DBGpr_com ("Active HVAC Parameters == Corr Cmp params" );
	    param_changed = FALSE;
	}
	else
	    param_changed = TRUE;
	break;
  }

  if ( param_changed == TRUE )
  {
	status = _VD_SEND_OBJN ( CorActParamId, NDnode.NDget_objects
			  ( ND_CHILDREN | ND_IN_BUF, NULL, 0, &list_child,
			    0, OM_K_MAXINT, &nb_child ));
	__DBGpr_int ("nb child", nb_child );
	if ( nb_child == 1 )
	{
	/* There is one child and it is the current correction component */

		status = VRModifyParameterBox
		    ( &retcode, Product, CorCmpParams, &CorActParamId, &CorActParamId);
		as$status( action = RET_STATUS );
	}
	else if ( nb_child > 1 )
	{
		NewActParamId.objid = NULL_OBJID;
		NewActParamId.osnum = CorActParamId.osnum;
		status = om$construct_and_copy ( objid = CorActParamId.objid,
						 obj_osnum = CorActParamId.osnum,
						 p_objid = &NewActParamId.objid,
						 osnum = NewActParamId.osnum );
		CheckRC ( status, 1 );
		status = VRModifyParameterBox
		    ( &retcode, Product, CorCmpParams, &NewActParamId, &NewActParamId);
		as$status( action = RET_STATUS );

		status = _VD_SEND_OBJN( *CorCmpId, NDnodein.NDchange_connect 
					( 1, &CorActParamId, &NewActParamId ));
	}
  }
  /*^ VRprint_user_attr( &CorActParamId ); */

  /* Kludge : Set Representation befor compute */
  status = om$send( msg      = message ACncpx.ACset_NV_rep( (unsigned)Representation, md_env ),
		    senderid = NULL_OBJID,
		    targetid = CorCmpId->objid,
		    targetos = CorCmpId->osnum  );
  as$status( action = RET_STATUS );

  status = om$send( msg      = message NDnode.NDcompute_node
                                              ( &retcode, 0, 0, NULL, md_env ),
		    senderid = NULL_OBJID,
		    targetid = CorCmpId->objid,
		    targetos = CorCmpId->osnum  );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
  
  End
  return(OM_S_SUCCESS);
}

/*****************************************************************************/

VRGetTempAttr( retmsg, ProductName, CmpId, ActParamId, UserParamId, 
		FatherParams, md_env )

IGRlong			*retmsg;
IGRshort		ProductName;
struct	GRid		*CmpId, *ActParamId, *UserParamId;
union	VRparam_attr	*FatherParams;
struct	GRmd_env	*md_env;
{
  IGRlong status=OM_S_SUCCESS, retcode=MSSUCC;
  struct GRid MissParamId;
  extern GRclassid        OPP_VRCptIn_class_id;
  extern GRclassid        OPP_VRNozzle_class_id;
  GRclassid               ObjClassId;

  SetProc ( VRGetTempAttr ); Begin

  *retmsg = MSSUCC;

  om$get_classid(objid = CmpId->objid,
		 osnum = CmpId->osnum,
		 p_classid = &ObjClassId);

  if ( (om$is_ancestry_valid
	(subclassid   = ObjClassId,
	 superclassid = OPP_VRNozzle_class_id) == OM_S_SUCCESS) ||
	(om$is_ancestry_valid
	(subclassid = ObjClassId,
	superclassid = OPP_VRCptIn_class_id) == OM_S_SUCCESS))
    {
	/* if the component is a nozzle, we need to make a 
	   new collection which contains the piping system
	   collection parameters with values taken from 
	   the nozzle collection when the parameter 
	   names match.
	   if it is a VRCptIn we need to clone attributes too. */
       status = VR$GetCmpAttributes(p_retmsg      = &retcode,
				    Product       = ProductName,
				    p_ComponentId = CmpId,
				    p_SysParamId  = ActParamId,
				    p_UserParamId = UserParamId,
				    p_MdEnv       = md_env );
	as$status(action = RET_STATUS);
	as$status(sts = retcode, action = RET_STATUS);
    }
  else
    {
	/* just return the objid of the component system and user collection */
  	status = om$send(msg = message VRGeneric.VRGetParams(&retcode,
						       ActParamId,
						       UserParamId,
						       &MissParamId),
		   senderid = NULL_OBJID,
		   targetid = CmpId->objid,
		   targetos = CmpId->osnum);
 	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );
     }

  /* Get dimensional parameters */
  status = VR$GetDimensionAttributes(	p_retmsg          = &retcode,
                             		Product           = ProductName,
                                	p_SysCollectionId = ActParamId,
                                        p_DimAttributes   = FatherParams,
                                        p_MdEnv      	  = md_env );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  End
  return OM_S_SUCCESS;
}

/*****************************************************************************/

VRGetCmpParams( ProductName, CmpName, Pipe, Father, Cmp )

IGRshort		ProductName;
IGRshort		CmpName;
union	VRparam_attr	*Pipe, *Father, *Cmp;

/*.VRGetCmpParams */ 
{
  IGRint	tmp;	/* temporary integer location */

  SetProc( VRGetCmpParams ); Begin
  *Cmp = *Father;

  /*"CmpName = %d\n", CmpName */

  switch( ProductName )
  {
	case VR_PIPING:

    		Cmp->piping_attr.R_diameter = Father->piping_attr.G_diameter;

		if( CmpName == VR_RED )
		{
			/*| VR_RED */

    			if( Father->piping_attr.G_diameter < Pipe->piping_attr.G_diameter )
    			{
      				Cmp->piping_attr.G_diameter = Pipe->piping_attr.G_diameter;
      				Cmp->piping_attr.R_diameter = Father->piping_attr.G_diameter;
    			}
    			else Cmp->piping_attr.R_diameter = Pipe->piping_attr.G_diameter;
		}

		/*"Cmp G_diam = %f\n", Cmp->piping_attr.G_diameter*/
		/*"Cmp R_diam = %f\n", Cmp->piping_attr.R_diameter*/

	break;

	case VR_HVAC:
	case VR_CABLING:

		/*"Father G_Width = %f\n", Father->hvac_attr.G_width */
		/*"Father G_depth = %f\n", Father->hvac_attr.G_depth */
		/*"Pipe G_Width   = %f\n", Pipe->hvac_attr.G_width */
		/*"Pipe R_depth   = %f\n", Pipe->hvac_attr.G_depth */

		Cmp->hvac_attr.R_width = Father->hvac_attr.G_width;
    		Cmp->hvac_attr.R_depth = Father->hvac_attr.G_depth;

 		if( CmpName == VR_ADP )
		{
 		  /*| get adapter parameters */

		  /*"Father.shape = %d\n", Father->hvac_attr.shape */
		  /*"Pipe.shape   = %d\n", Pipe->hvac_attr.shape    */

		  VRMkTransShape ( (int)Father->hvac_attr.shape, 
					(int)Pipe->hvac_attr.shape, &tmp);
		  Cmp->hvac_attr.shape = tmp;

		  /*"Cmp.shape = %d\n", Cmp->hvac_attr.shape */

	 	  if( Father->hvac_attr.shape > Pipe->hvac_attr.shape )
		  {
		  /* Verification of the twist does not make sense as the 
		     value for bTwist is never set, it is for reference only */

		  /*
		   *	if (Father->hvac_attr.bTwist)
		   *	{
		   *	Cmp->hvac_attr.G_width = Pipe->hvac_attr.G_depth;
		   *	Cmp->hvac_attr.G_depth = Pipe->hvac_attr.G_width;
		   *	}
		   *	else
		   */
			{
			Cmp->hvac_attr.G_width = Pipe->hvac_attr.G_width;
			Cmp->hvac_attr.G_depth = Pipe->hvac_attr.G_depth;
			}
		  }
		  else
		  {
		  /*
		   *	if (Father->hvac_attr.bTwist)
		   *	{
        	   *	Cmp->hvac_attr.R_width = Pipe->hvac_attr.G_depth;
        	   *	Cmp->hvac_attr.R_depth = Pipe->hvac_attr.G_width;
		   *	}
		   *	else
		   */
			{
        		Cmp->hvac_attr.R_width = Pipe->hvac_attr.G_width;
        		Cmp->hvac_attr.R_depth = Pipe->hvac_attr.G_depth;
			}
		  }
		}

		if( CmpName == VR_RED )
		{
			/*| get reducer parameters */
                        /*BILLA  Double value comparison problem */
                        if( ( Father->hvac_attr.G_width >
                              Pipe->hvac_attr.G_width ) ||
                            ( fabs( Father->hvac_attr.G_width -
                              Pipe->hvac_attr.G_width ) < VRGetTol(VR_DIST_TOL) ) &&
                            ( Father->hvac_attr.G_depth >
                              Pipe->hvac_attr.G_depth ) )
    			{
      				Cmp->hvac_attr.R_width = Pipe->hvac_attr.G_width;
      				Cmp->hvac_attr.R_depth = Pipe->hvac_attr.G_depth;
   			 }
    			else
    			{	
			/*
			 *	if (Father->hvac_attr.bTwist)
			 *	{
			 *	Cmp->hvac_attr.R_width = Pipe->hvac_attr.G_depth;
			 *	Cmp->hvac_attr.R_depth = Pipe->hvac_attr.G_width;
			 *	}
			 *	else
			 */
				{
      				Cmp->hvac_attr.G_width = Pipe->hvac_attr.G_width;
      				Cmp->hvac_attr.G_depth = Pipe->hvac_attr.G_depth;
				}
    			} 
		}

		/*"Cmp G_Width = %f\n", Cmp->hvac_attr.G_width */
		/*"Cmp G_depth = %f\n", Cmp->hvac_attr.G_depth */
		/*"Cmp R_Width = %f\n", Cmp->hvac_attr.R_width */
		/*"Cmp R_depth = %f\n", Cmp->hvac_attr.R_depth */
		/*"Cmp shape   = %d\n", Cmp->hvac_attr.shape   */
	break;
  }

  End
  return OM_S_SUCCESS;

}

/*****************************************************************************/

VRGetTransCode( Shape1, Shape2, TransCode )

IGRshort Shape1, Shape2, *TransCode;

/*.VRGetTransCode CR179309874- Added VR_ELLIPSE */
{
    *TransCode = -1; /*** tr179900976 ***/
    switch( Shape1 )
    {
	case VR_CORNER :
		switch( Shape2 )
		{
			case VR_RECT : *TransCode = VR_TRANS_R_Co; break;
			case VR_OVAL : *TransCode = VR_TRANS_O_Co; break;
			case VR_CIRC : *TransCode = VR_TRANS_C_Co; break;
			case VR_ELLIPSE : *TransCode = VR_TRANS_E_Co; break;
		}
	break;

      	case VR_CIRC :
		switch( Shape2 )
		{
			case VR_RECT   : *TransCode = VR_TRANS_R_C; break;
			case VR_OVAL   : *TransCode = VR_TRANS_O_C; break;
			case VR_CORNER : *TransCode = VR_TRANS_C_Co; break;
			case VR_ELLIPSE   : *TransCode = VR_TRANS_E_C; break;
		}
	break;

      	case VR_OVAL :
		switch( Shape2 )
		{
			case VR_RECT   : *TransCode = VR_TRANS_R_O; break;
			case VR_CIRC   : *TransCode = VR_TRANS_O_C; break;
			case VR_CORNER : *TransCode = VR_TRANS_O_Co; break;
			case VR_ELLIPSE : *TransCode = VR_TRANS_O_E; break;
		}
	break;

	case VR_RECT :
		switch( Shape2 )
		{
			case VR_CIRC   : *TransCode = VR_TRANS_R_C; break;
			case VR_OVAL   : *TransCode = VR_TRANS_R_O; break;
			case VR_CORNER : *TransCode = VR_TRANS_R_Co; break;
			case VR_ELLIPSE  : *TransCode = VR_TRANS_R_E; break;
		}
	break;

	case VR_ELLIPSE :
		switch( Shape2 )
		{
			case VR_CIRC   : *TransCode = VR_TRANS_E_C; break;
			case VR_OVAL   : *TransCode = VR_TRANS_O_E; break;
			case VR_CORNER : *TransCode = VR_TRANS_E_Co; break;
			case VR_RECT   : *TransCode = VR_TRANS_R_E; break;
		}
	break;

	default : as$status( sts = OM_E_ABORT, msg = "Given shape not valid" );
	
    }

    return OM_S_SUCCESS;
}

end implementation VRCorrection;
