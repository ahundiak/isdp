 /* $Id: VDpdmStartup.c,v 1.11 2002/05/10 19:33:50 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/VDpdmStartup.c
 *
 * Description: Functions required to check hull approved configuration
 *              on startup of VDS.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmStartup.c,v $
 *      Revision 1.11  2002/05/10 19:33:50  ahundiak
 *      ah
 *
 *      Revision 1.10  2002/01/07 18:20:55  jdsauby
 *      JTSMP CR 5952, new rules for hull applicability check and hull approval check.
 *
 *      Revision 1.9  2001/10/03 14:07:13  jdsauby
 *      JTS MP CR 5527
 *
 *      Revision 1.8  2001/07/26 13:33:35  jdsauby
 *      MP5447 - jds
 *
 *      Revision 1.7  2001/07/16 13:54:15  jdsauby
 *      VDassert working with Z D F
 *
 *      Revision 1.6  2001/04/12 20:42:48  jdsauby
 *      sp 11
 *
 *      Revision 1.5  2001/03/08 14:38:57  jdsauby
 *      Re - organization of VDpdm.h
 *
 *      Revision 1.4  2001/03/07 19:09:18  jdsauby
 *      Made better for VDstartup.
 *
 *      Revision 1.3  2001/03/06 23:03:39  jdsauby
 *      Fixed crash for parts not having an approved config
 *
 *      Revision 1.2  2001/02/21 21:58:22  jdsauby
 *      Just keeping the server up to date
 *
 *      Revision 1.1  2001/02/21 13:01:44  jdsauby
 *      CR4088
 *
 *
 *      Revision 1.1  2001/02/05 16:38:42  jdsauby
 *      JTS MP CR4088, initial creation
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/13/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDnfmc.h"
#include "VDrisc.h"
#include "VDpdm.h"
//#include "VDpdmACfg.h"
#include "VDpdmCmd.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "time.h"
#include "VDfrmc.h"

VDASSERT_FFN("vdpdm/func/VDpdmStartup.c");

/* -----------------------------------------------
 * Compare approved for hull configurations of active
 * file to that of each reference file.
 * ***/
IGRstat VDpdmCompareCfgRefToActive( VDpdmHullApp *actShips, 
	                            IGRint       *filekey,
		                    IGRchar      *rev)
{
    VDASSERT_FN("VDpdmCompareCfgRefToActive");

    IGRstat       retFlag = 0;
    IGRstat       sts;

    VDpdmHullApp  refShips;
    IGRint        i,j;
    IGRint        has_ship;

    if (actShips->cnt < 1)    goto wrapup;
    if (*filekey < 1) goto wrapup;
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // check if the revision is valid, if the revision is not valid, it
    // passes this comparison.
    if (rev) {
	if (!VDpdmIsRevisionValid(rev)) {
	    retFlag = 1;
	    goto wrapup;
	}
    }

    // get the approved for config hulls
    sts = VDpdmGetApprCfgforFilekey(filekey, &refShips);
    if ( (!(sts & 1)) || (refShips.cnt < 1) ) goto wrapup;
    
    if (traceFlag) printf("### %s %s loop and compare\n",ffn(),fn);
    // loop and compare
    /* JTSMP CR 5952 Lowest HULL rule, only need to compare first hull in
     * actShips.  */
    //for (i = 0; i < actShips->cnt; i++) {
	has_ship = 0;

	for (j = 0; j < refShips.cnt; j++) {
	    if (!strcmp(actShips->hulls[0],refShips.hulls[j])) {
		retFlag = 1;
		if (traceFlag) 
		    printf("### Active <%s> Ref <%s>, has ship <%d>\n",
			    actShips->hulls[i],refShips.hulls[j],has_ship);
		goto wrapup;
	    }
	}
//nextHull:
	//if (!has_ship) goto wrapup;
    //}

    // done, all ships accounted for
    //retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}

/* ---------------------------------------------------
 * Check and compare hull approved configurations for 
 * files referenced into active file
 *
 * CRITERIA:
 *   1.  The active file must have an approved hull configuration set.
 *       If it does not, then the rest of the check is meaninless.
 *   2.  Each referenced file must have at least the same approved hull
 *       configuration set.  For example, Active file (A) is approved for 
 *       hulls ship1 and ship3.  If reference file (B) is approved for hulls
 *       ship1, ship2, ship3, and ship4, then it passes because it is at
 *       least approved for the same two ships as file (A).  If reference 
 *       file (C) is approved for hulls ship1, ship2, and ship5, then it fails
 *       because it needed both ship1 and ship3.
 *   3.  If a reference file does not have an approved for hull configuration
 *       set, then it fails.
 *   4.  All reference files which fail will be added to the list.
 ****/
IGRstat VDpdmCheckApprCfgForRefFiles(VDosnum  osnum)
{
    VDASSERT_FN("VDpdmCheckApprCfgForRefFiles");

    IGRstat       retFlag = 1;
    IGRstat       sts;
    TVDpdmInfo    actInfo;
    VDpdmHullApp  actShips;
    IGRint        i, noncompliant;
    TVDpdmRefList refList; // all reference files
    TVDpdmRefList nonList; // reference files which do not meet comparison criteria
    IGRchar *envVar;
    IGRstat flag;
    IGRchar msg[80];

    // init
    VDpdmInitRefList( &refList );
    VDpdmInitRefList( &nonList );
    noncompliant = 0;

        // logged in?
    sts = VDpdmVerifyLogin();
    if (!(sts & 1)) goto wrapup;

    // Shut this all off based on environment variable
    if (getenv("ISDP_HULL_CFG_OFF")) {
	envVar = getenv("ISDP_HULL_CFG_OFF");
	flag = atoi(envVar);
	if (flag) goto wrapup;
    }

    // set the status
    strcpy(msg,"Checking Approved Hull Configuration");
    UI_status(msg);

    // get approved configuration list for active file
    if (traceFlag) printf("### %s %s getPdmInfo\n",ffn(),fn);
    sts = VDpdmGetPdmInfo( osnum, &actInfo);
    if ( (!(sts & 1)) || (actInfo.filekey == 0) ) goto wrapup; 

    if (traceFlag) printf("### %s %s getapprcfgforfilekey\n",ffn(),fn);
    sts = VDpdmGetApprCfgforFilekey( &actInfo.filekey, &actShips);
    if ( (!(sts & 1)) || (actShips.cnt < 1) ) goto wrapup;

    // get list of reference files and count
    if (traceFlag) printf("### %s %s getreflist\n",ffn(),fn);
    sts = VDpdmGetRefList( osnum, &refList );
    if ( (!(sts & 1)) || (refList.cnt < 1) ) goto wrapup;

    // loop through each reference file and compare
    if (traceFlag) printf("### %s %s start to compare\n",ffn(),fn);
    noncompliant = 0;
    for ( i = 0; i < refList.cnt; i++ ) {
	// comparison routine
	if ( (!VDpdmCompareCfgRefToActive(&actShips, 
		                          &refList.infos[i].filekey,
					  refList.infos[i].rev))     ||
	     (!VDpdmIsShipApplicabilityValid(&actInfo.filekey,&refList.infos[i].filekey)) )
	{
	    // Add the part to the non compliant nonList
	    VDpdmAddPartToRefList( &nonList, &refList.infos[i] );
	    noncompliant = 1;
	    if (traceFlag) printf("### c <%s> p <%s> r <%s>\n",refList.infos[i].catalog,
		    refList.infos[i].part, refList.infos[i].rev );
	}
    }

    // Tell the user if there are any non-compliant files
    if (noncompliant == 1) 
	VDpdmDisplayNonCompliantRefList( &actInfo, &actShips, &nonList );

    // done

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    VDpdmFreeRefList( &refList );
    VDpdmFreeRefList( &nonList );
    return retFlag;
}

/* ------------------------------------------
 * Called from VDStartup routine.  This will store
 * PDM Info, Purpose Info, and check approved hull
 * configurations.
 * **/
IGRstat VDpdmStartup()
{
    IGRstat retFlag = 1;
    IGRstat sts;

    VDosnum osnum = OM_K_NOT_AN_OS;

    // verify logged in
    sts = VDpdmVerifyLogin();
    if (!(sts & 1)) goto wrapup;

    // update PDM Info
    sts = VDpdmUpdatePdmInfo(osnum);
    
    // no need to continue without PDM Info
    if (!(sts & 1)) goto wrapup;

    // update Purpose Info
    VDpdmUpdatePurposeInfo(osnum);

    // Check the Approved Hull configuration
    sts = VDpdmCheckApprCfgForRefFiles(osnum);

    // done
    
wrapup:
    return retFlag;
}

    

    
