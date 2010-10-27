 /* $Id: VDpdmPtHull.c,v 1.19 2002/05/10 19:33:50 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmPtHull.c
 *
 * Description: Given a part, find the hulls for which this part is approved
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmPtHull.c,v $
 *      Revision 1.19  2002/05/10 19:33:50  ahundiak
 *      ah
 *
 *      Revision 1.18  2002/01/15 22:44:45  jdsauby
 *      JTSMP TR5972, it was the PDUrefresh checks that caused it. jds
 *
 *      Revision 1.17  2002/01/10 21:12:15  jdsauby
 *      JTSMP CR5866, added clear all and set all gadgets
 *
 *      Revision 1.16  2001/12/06 21:38:57  jdsauby
 *      JTSMP TR 5863
 *
 *      Revision 1.15  2001/10/03 14:02:44  jdsauby
 *      Utilize COset_trace for debug
 *
 *      Revision 1.14  2001/07/16 13:53:01  jdsauby
 *      VDassert working with Z D F
 *
 *      Revision 1.13  2001/06/04 14:46:23  jdsauby
 *      fixed a crash on isuservalid.  I found it, so no TR or CR
 *
 *      Revision 1.12  2001/06/04 13:07:49  jdsauby
 *      CR3403, new replace part
 *
 *      Revision 1.11  2001/04/13 20:43:47  jdsauby
 *      trace statements left on
 *
 *      Revision 1.10  2001/04/12 20:41:36  jdsauby
 *      sp 11
 *
 *      Revision 1.9  2001/03/30 20:33:03  jdsauby
 *      js sp
 *
 *      Revision 1.8  2001/03/08 14:39:34  jdsauby
 *      Re - organization of VDpdm.h
 *
 *      Revision 1.7  2001/03/07 19:08:17  jdsauby
 *      Added more status comments.  Better Purpose Info.
 *
 *      Revision 1.6  2001/03/05 19:43:28  jdsauby
 *      Finish Purpose Info
 *
 *      Revision 1.5  2001/03/02 21:45:34  jdsauby
 *      Added purpose Info
 *
 *      Revision 1.4  2001/02/23 16:10:17  jdsauby
 *      Just some more changes, nearing completion
 *
 *      Revision 1.3  2001/02/21 13:00:33  jdsauby
 *      CR4088
 *
 *      Revision 1.2  2001/02/11 17:54:47  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/02/05 16:38:05  jdsauby
 *      JTS MP CR4088
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/11/00  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDpdmCmd.h"
#include "VDpdmForms.h"
#include "VDfrmc.h"

#include "PDUstr.h"
extern struct PDUrefresh *refresh;

VDASSERT_FFN("vdpdm/cmd/VDpdmPtHull.c");

static TVDpdmClass class;
static Form        s_form;
#if 0
/* ------------------------------------------
 * Clear the nth gadget
 * ***/
static IGRstat clearNthGadget( Form    form,
	                       IGRint  nth )
{
    VDASSERT_FN("clearNthGadget");

    IGRstat retFlag = 1;

    VDASSERTW(form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // just a switch
    switch (nth) {
      case  0: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_L1);       goto wrapup;
      case  1: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_L2);       goto wrapup;
      case  2: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_L3);       goto wrapup;
      case  3: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_L4);       goto wrapup;
      case  4: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_L5);       goto wrapup;
      case  5: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_L6);       goto wrapup;
      case  6: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_L7);       goto wrapup;
      case  7: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_L8);       goto wrapup;
      case  8: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_L9);       goto wrapup;
      case  9: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_L10);      goto wrapup;
      case 10: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_CATALOG);  goto wrapup;
      case 11: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_PART);     goto wrapup;
      case 12: VDpdmClearGadgetList(form,VDPDM_PART_HULL_G_REV);      goto wrapup;
      case 13: VDfrmSetgText(form,VDPDM_PART_HULL_G_FILEKEY,"");       goto wrapup;
      case 14: VDpdmClearGadgetColumn(form,VDPDM_PART_HULL_APPL_TO);  goto wrapup;
      case 15: VDpdmClearGadgetColumn(form,VDPDM_PART_HULL_APPR_FOR); goto wrapup;
      default: return 0;

    } // end of switch

    // done
wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}


/* -------------------------------------------
 * Clear up all gadget levels below the current
 * gadget being selected, including catalog, part,
 * revision, filekey, hull appl, and hull appr
 * ***/
static IGRstat clearGadgetLevels( Form   form,
	                          IGRint gadget )
{
    VDASSERT_FN("clearGadgetLevels");

    IGRstat retFlag = 1;
    IGRstat sts;
    IGRint  i, level;
    IGRchar buf[1024];
    

    VDASSERTW(gadget != 0);
    
    // init
    buf[0] = '\0';
    level  = 0;
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // do it depending on the gadget
    switch (gadget) {

	// Level 1 gadget, clear level 2 and the rest
      case VDPDM_PART_HULL_G_L1:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_L2, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L2
	  level = 1;
	  break;

      case VDPDM_PART_HULL_G_L2:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_L3, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L3
	  level = 2;
	  break;
 
      case VDPDM_PART_HULL_G_L3:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_L4, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L4
	  level = 3;
	  break;
 
      case VDPDM_PART_HULL_G_L4:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_L5, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L5
	  level = 4;
	  break;
 
      case VDPDM_PART_HULL_G_L5:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_L6, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L6
	  level = 5;
	  break;
 
      case VDPDM_PART_HULL_G_L6:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_L7, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L7
	  level = 6;
	  break;
 
      case VDPDM_PART_HULL_G_L7:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_L8, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L8
	  level = 7;
	  break;
 
      case VDPDM_PART_HULL_G_L8:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_L9, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L9
	  level = 8;
	  break;
 
      case VDPDM_PART_HULL_G_L9:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_L10, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from L10
	  level = 9;
	  break;
 
      case VDPDM_PART_HULL_G_L10:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_CATALOG, buf);
	  if (buf[0] == '\0') goto clearLevels;

	  // start clearing from CATALOG
	  level = 10;
	  break;
 
      case VDPDM_PART_HULL_G_CATALOG:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_PART, buf);
	  if (buf[0] == '\0') goto wrapup;

	  // start clearing from PART
	  level = 11;
	  break;
 
      case VDPDM_PART_HULL_G_PART:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_REV, buf);
	  if (buf[0] == '\0') goto wrapup;

	  // start clearing from REV
	  level = 12;
	  break;
 
      case VDPDM_PART_HULL_G_REV:
	  // check if already cleared
	  VDfrmGetgText(form, VDPDM_PART_HULL_G_FILEKEY, buf);
	  if (buf[0] == '\0') goto wrapup;

	  // start clearing from FILEKEY
	  level = 13;
	  break;
 
      case VDPDM_PART_HULL_G_FILEKEY:

	  // clear the hull appl, and appr_for
	  level = 14;
	  break;
	  
      default:
	  // always clear catalog, part, rev
	  level = 10;
	  break;

    } // end of switch (gadget)
clearLevels:
    if (level == 0) level = 10;
    // Now we know where to start the clearing, so do it
    for( i = level; clearNthGadget( form, i ); i++ ) {}

    // done
    
wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}
#endif

/* ---------------------------------------------
 * Set the Hull Applicable to and Approved for data
 * on the form for the filekey
 * ***/
static IGRstat setHullAppAndConfig( IGRint *fileKey )
{
    VDASSERT_FN("setHullAppAndConfig");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i;

    TVDrisInfo   ris;
    VDpdmHullApp appl_ships;
    VDpdmHullApp appr_ships;

    // init
    VDrisInitInfo( &ris );

    VDASSERTW(s_form);
    VDASSERTW(fileKey && *fileKey > 0);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // set the status
    VDfrmSetgText( s_form, VDPDM_PART_HULL_STATUS,
	    "Getting Hull Applicablity and Configuration Information" );

    // clear any existing data on form
    // APPL_TO
    VDpdmClearGadgetColumn( s_form, VDPDM_PART_HULL_APPL_TO );

    // APPR_FOR
    VDpdmClearGadgetColumn( s_form, VDPDM_PART_HULL_APPR_FOR );

    // Delete any caching
    VDpdmCdeleteFilekeyCache(fileKey);

    // get the hull applicability
    sts = VDpdmGetHullAppforFilekey(fileKey, &appl_ships);
    if ( !(sts & 1) || (appl_ships.cnt < 1) ) {
	retFlag = 1;
	goto wrapup;
    }

    // display on form
    for( i = 0; i < appl_ships.cnt; i++ ) {
	VDfrmSetfText(s_form, VDPDM_PART_HULL_APPL_TO, i, 0, appl_ships.hulls[i]);
    }
	
    // get the hulls for which this file is the approved configuration
    sts = VDpdmGetApprCfgforFilekey(fileKey, &appr_ships);
    if ( !(sts & 1) || (appr_ships.cnt < 1) ) {
	retFlag = 1;
	goto wrapup;
    }

    // display on the form
    for( i = 0; i < appr_ships.cnt; i++ ) {
	VDfrmSetfText(s_form, VDPDM_PART_HULL_APPR_FOR, i, 0, appr_ships.hulls[i]);
    }

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------------
 * set all on the approved for column.  This will be used
 * to actually remove all
 * **/
static IGRstat notifyClearAll()
{
    VDASSERT_FN("notifyClearAll");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i,numrows;

    VDASSERTW(s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the number of rows
    numrows = 0;
    VDfrmGetNumRows( s_form, VDPDM_PART_HULL_APPR_FOR, &numrows, NULL, NULL );
    if (numrows == 0) goto wrapup;

    // set them all to selected
    for (i = 0; i < numrows; i++) {
	VDfrmSetSelect(s_form, VDPDM_PART_HULL_APPR_FOR, i, 0, 1);
    }

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
    
/* ----------------------------------------
 * remove hulls from approved for
 * ***/
static IGRstat notifyRemoveApprHull()
{
    VDASSERT_FN("notifyRemoveApprHull");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i,numrows,sel,fileKey;
    IGRchar ship[64],fkey[64];

    VDASSERTW(s_form);
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the number of rows on the form
    numrows = 0;
    //VDfrmGetgListNumRows( form, VDPDM_PART_HULL_APPR_FOR, &numrows );
    VDfrmGetNumRows( s_form, VDPDM_PART_HULL_APPR_FOR, &numrows, NULL, NULL );
    if (numrows == 0) goto wrapup;

    // get the file key
    fkey[0] = '\0';
    VDfrmGetgText(s_form, VDPDM_PART_HULL_G_FILEKEY, fkey);
    if (fkey[0] == '\0') goto wrapup;
    fileKey = atoi(fkey);

    // get the ones selected
    for (i = 0; i < numrows; i++ ) {
	VDfrmGetSelect( s_form, VDPDM_PART_HULL_APPR_FOR, i, 0, &sel);
	if (sel) {
	    // get the text
	    ship[0] = '\0';
	    VDfrmGetfText( s_form, VDPDM_PART_HULL_APPR_FOR, i, 0, ship );
	    if (ship[0] == '\0') goto wrapup;

	    // set the appr cfg for file and hull to approved
	    VDpdmSetApprCfgForFileKeyHull(&fileKey, ship, 
		                          VDPDM_IS_NOT_APPROVED,
					  VDPDM_IS_NOT_PRODUCTION);
	}
    }

    // reset the approved for gadget
    setHullAppAndConfig( &fileKey );

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
	
/* --------------------------------------
 * set all on the applicable to column
 * **/
static IGRstat notifySetAll()
{
    VDASSERT_FN("notifySetAll");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i,numrows;

    VDASSERTW(s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the number of rows
    numrows = 0;
    VDfrmGetNumRows( s_form, VDPDM_PART_HULL_APPL_TO, &numrows, NULL, NULL );
    if (numrows == 0) goto wrapup;

    // set them all to selected
    for (i = 0; i < numrows; i++) {
	VDfrmSetSelect(s_form, VDPDM_PART_HULL_APPL_TO, i, 0, 1);
    }

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ----------------------------------------
 * Add hulls to approved for
 * ***/
static IGRstat notifyAddApprHull()
{
    VDASSERT_FN("notifyAddApprHull");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i,numrows,sel,fileKey;
    IGRchar ship[64],fkey[64];

    VDASSERTW(s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the number of rows on the form
    numrows = 0;
    //VDfrmGetgListNumRows( form, VDPDM_PART_HULL_APPL_TO, &numrows );
    VDfrmGetNumRows( s_form, VDPDM_PART_HULL_APPL_TO, &numrows, NULL, NULL );
    if (numrows == 0) goto wrapup;
    if (traceFlag) printf("### %s %s numrows <%d>\n",ffn(),fn,numrows);

    // get the file key
    fkey[0] = '\0';
    VDfrmGetgText(s_form, VDPDM_PART_HULL_G_FILEKEY, fkey);
    if (fkey[0] == '\0') goto wrapup;
    fileKey = atoi(fkey);
    if (traceFlag) printf("### %s %s filekey <%d>\n",ffn(),fn,fileKey);

    // get the ones selected
    for (i = 0; i < numrows; i++ ) {
	VDfrmGetSelect( s_form, VDPDM_PART_HULL_APPL_TO, i, 0, &sel);
	if (sel) {
	    // get the text
	    ship[0] = '\0';
	    VDfrmGetfText( s_form, VDPDM_PART_HULL_APPL_TO, i, 0, ship );
	    if (ship[0] == '\0') goto wrapup;

	    // set the appr cfg for file and hull to approved
	    VDpdmSetApprCfgForFileKeyHull(&fileKey, ship, 
		                          VDPDM_IS_APPROVED,
					  VDPDM_IS_NOT_PRODUCTION);
	}
    }

    // reset the approved for gadget
    setHullAppAndConfig( &fileKey );

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ------------------------------------
 * Set the purpose info on the form
 * ***/
static setPurposeInfo( IGRint  *fkey)
{
    VDASSERT_FN("setPurposeInfo");

    IGRstat retFlag = 1;
    IGRstat sts;
    TVDpdmPurposeInfo  info;

    VDASSERTW(s_form);
    VDASSERTW(*fkey != 0);
    memset(&info,0,sizeof(info));

    // set the status
    VDfrmSetgText(s_form, VDPDM_PART_HULL_STATUS, "Getting Purpose Info" );

    // clear existing form data
    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_PURPOSE, "" );
    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_ZONE,    "" );
    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_UNIT,    "" );
    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_SYSTEM,  "" );

    // query the db for it
    VDpdmQryPurposeInfo(*fkey, &info);
    if (*info.purpose == 0) {
	VDfrmSetgText(s_form, VDPDM_PART_HULL_STATUS, "Purpose Info Not Found" );
	goto wrapup;
    }

    // set it
    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_PURPOSE, info.purpose);
    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_ZONE,    info.zone);
    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_UNIT,    info.unit);
    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_SYSTEM,  info.system);

    // done
    retFlag = 1;
    VDfrmSetgText(s_form, VDPDM_PART_HULL_STATUS, "Done" );
wrapup:
    return retFlag;
}

/* -----------------------------------
 * Get the filekey based on part,catalog, and rev
 *      - AND / OR - 
 * Key in the fileKey.
 * Regardless, once the filekey has been established, need
 * to fill up the rest of the form
 * ***/
static IGRstat notifyFileKey()
{
    VDASSERT_FN("notifyFileKey");

    IGRstat  retFlag = 0;
    IGRstat  sts;

    IGRchar  catalog[64],
             part   [64],
	     rev    [64],
	     fileKey[64];
    IGRint   i,fkey;

    // init
    VDASSERTW(s_form);
    catalog[0] = '\0';
    part[0]    = '\0';
    rev[0]     = '\0';
    fileKey[0] = '\0';

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // fileKey was keyed in, get it
    VDfrmGetgText(s_form, VDPDM_PART_HULL_G_FILEKEY, fileKey);

    if (fileKey[0] != '\0') {
	fkey = atoi(fileKey);
	sts = VDpdmGetCPRForFilekey(&fkey, catalog, part, rev);
	if (sts) {
	    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_CATALOG, catalog);
	    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_PART,    part);
	    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_REV,     rev);
	}
    }

    if (fileKey[0] == '\0') {
	// get it from catalog, part, rev
	VDfrmGetgText(s_form, VDPDM_PART_HULL_G_CATALOG, catalog);
	if (catalog[0] == '\0') goto wrapup;

	VDfrmGetgText(s_form, VDPDM_PART_HULL_G_PART, part);
	if (part[0] == '\0') goto wrapup;

	VDfrmGetgText(s_form, VDPDM_PART_HULL_G_REV, rev);
	if (rev[0] == '\0') goto wrapup;
	
	// get the filekey
	VDpdmGetFileKeyForCPR(catalog, part, rev, &fkey);
	if (fkey == 0) goto wrapup;

	// set fileKey for form
	sprintf(fileKey,"%d",fkey);
    }

    // better have a fileKey now
    if (fileKey[0] == '\0') goto wrapup;

    // display it on the form
    VDfrmSetgText( s_form, VDPDM_PART_HULL_G_FILEKEY, fileKey );

    // set the hull app and config stuff
    setHullAppAndConfig( &fkey );

    // set the purpose info
    setPurposeInfo( &fkey );

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ---------------------------------------
 * A local file was selected
 * ***/
static IGRstat notifyLocalFile( )
{
    VDASSERT_FN("notifyLocalFile");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar fkey[24];
    IGRint  row,pos;

    VDASSERTW(s_form);
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init
    *fkey = 0;

    // get the active row
    VDfrmGetActiveRow( s_form, VDPDM_PART_HULL_G_LOC_FILE, &row, &pos);

    // get the fkey text
    VDfrmGetfText(s_form, VDPDM_PART_HULL_G_LOC_FILE, row, 1, fkey);
    if (*fkey == 0) goto wrapup;

    // put the key on the form
    VDfrmSetgText(s_form, VDPDM_PART_HULL_G_FILEKEY, fkey);

    // notify filekey
    sts = notifyFileKey( );

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}

/* ------------------------------------
 * Get revisions based on part and catalog
 * ***/
static IGRstat notifyRev()
{
    VDASSERT_FN("notifyRev");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar catalog[64],
            part   [64];


    // init
    catalog[0] = '\0';
    part[0]    = '\0';

    VDASSERTW(s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the catalog and part
    VDfrmGetgText(s_form, VDPDM_PART_HULL_G_CATALOG, catalog);
    if (catalog[0] == '\0') goto wrapup;
    
    VDfrmGetgText( s_form, VDPDM_PART_HULL_G_PART, part );
    if (part[0] == '\0') goto wrapup;

    // Query for revisions
    sts = VDpdmFillGadgetRev( s_form, VDPDM_PART_HULL_G_REV, catalog, part );
    if (!(sts & 1)) goto wrapup;
    
    // tell the user what to do
    VDfrmSetgText( s_form, VDPDM_PART_HULL_STATUS, "Select Revision" );

    // clear, then notify file key
    VDfrmSetgText( s_form, VDPDM_PART_HULL_G_FILEKEY, "");
    notifyFileKey( );
    
    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/* -------------------------------------
 * Get parts based on catalog selected
 * ***/
static IGRstat notifyPart()
{
    VDASSERT_FN("notifyPart");

    IGRstat    retFlag = 0;
    IGRstat    sts;
    IGRchar    catalog[64];
    
    // init
    catalog[0] = '\0';

    VDASSERTW(s_form);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the catalog
    VDfrmGetgText( s_form, VDPDM_PART_HULL_G_CATALOG, catalog );
    if (catalog[0] == '\0') goto wrapup;

    // query for parts
    sts = VDpdmFillGadgetPart( s_form, VDPDM_PART_HULL_G_PART, catalog );
    if (!(sts & 1)) goto wrapup;

    // tell the user what to do
    VDfrmSetgText( s_form, VDPDM_PART_HULL_STATUS, "Select Part" );

    // notify rev
    notifyRev( );
    
    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------
 * Get catalogs based on classifications selected
 * **/
static IGRstat notifyCatalog()
{
    VDASSERT_FN("notifyCatalog");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar     catalog[80];
    
    // init
    catalog[0] = '\0';
  
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // see if catalog was just keyed in
    VDfrmGetgText( s_form, VDPDM_PART_HULL_G_CATALOG, catalog );
    if (catalog[0] != '\0') {
	notifyPart();
	retFlag = 1;
	goto wrapup;
    }

    // fill the gadget
    sts = VDpdmFillGadgetCatalog( s_form, VDPDM_PART_HULL_G_CATALOG, &class );
    if (!(sts & 1)) goto wrapup;
    
    // notify part
    notifyPart( );

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ----------------------------------
 * Do it gadget pressed
 * **/
static IGRstat notifyDoit( )
{
    VDASSERT_FN("notifyDoit");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar fkey[30];
    IGRchar fname[40];
    IGRchar msg[80];
    IGRint  row,pos;
    VDosnum osnum = OM_K_NOT_AN_OS;

    TVDpdmPurposeInfo  info;

    // init
    memset(&info,0,sizeof(info));
    *fname = 0;
    *fkey  = 0;

    VDASSERTW(s_form);

    // Get the data from the form
    VDfrmGetgText(s_form, VDPDM_PART_HULL_G_FILEKEY, fkey);
    if (*fkey == 0) goto wrapup;
    
    VDfrmGetgText(s_form, VDPDM_PART_HULL_G_PURPOSE, info.purpose);
    if (*info.purpose == 0) goto wrapup;

    VDfrmGetgText(s_form, VDPDM_PART_HULL_G_ZONE, info.zone);
    VDfrmGetgText(s_form, VDPDM_PART_HULL_G_UNIT, info.unit);
    VDfrmGetgText(s_form, VDPDM_PART_HULL_G_SYSTEM, info.system);

    // Check that values match purpose
    sts = VDrrvCheckPurposeValues( &info, msg );
    if (!(sts & 1)) {
	VDfrmSetgText(s_form, VDPDM_PART_HULL_STATUS, msg );
	goto wrapup;
    }

    // update the purp_info expression in file
    // get the active row
    VDfrmGetActiveRow( s_form, VDPDM_PART_HULL_G_LOC_FILE, &row, &pos);

    // get the filename text
    VDfrmGetfText(s_form, VDPDM_PART_HULL_G_LOC_FILE, row, 0, fname);
    if (*fname == 0) goto wrapup;

    // get the os from filename
    VDosGetFileNameOS( fname, &osnum );
    if (osnum == OM_K_NOT_AN_OS) goto wrapup;

    // update it
    VDpdmSetPurposeInfo(osnum,&info);
    
    // done
    retFlag = 1;

wrapup:
    if (retFlag) 
	VDfrmSetgText(s_form, VDPDM_PART_HULL_STATUS, "Purpose Info set");
    return retFlag;
}

/* --------------------------------------------
 * Open the Approved ACL list file
 * **/
static FILE *openACLListFile()
{
    IGRint i;
    IGRchar buf[1024];
    FILE *file;

    // Look in local directory
    file = fopen("app_cfg_acl.txt","rt");
    if (file) return file;

    // Look in config directory
    for(i = 0; 1; i++) {

	// Product specific loading
	*buf = 0;
	EX_getpath(i,buf,sizeof(buf),EX_CONFIG_PATH);
	if (*buf == 0) {
	    file = NULL;
	    return file;
	}

	strcat(buf,"config/sets/app_cfg_acl.txt");
	//printf("Directory for app_cfg_acl.txt file is [%s]\n",buf);

	file = fopen(buf,"rt");
	if (file != NULL) return file;
    }
}

/* ----------------------------------------------
 * Get the list of approved ACLs
 * **/
static void getApprAclList(IGRint  *aclCnt,
                           IGRchar ***a_list)
{
    VDASSERT_FN("getApprAclList");

    FILE *file = NULL;
    IGRchar buf[128];
    IGRint  cnt = 0;
    IGRchar *p;
    IGRint  i;
    IGRchar **list = NULL;

    VDASSERTW(aclCnt); *aclCnt = 0;
    VDASSERTW(a_list);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // open the file
    file = openACLListFile();
    if (file == NULL) goto wrapup;

    // Cycle through
    while(fgets(buf,sizeof(buf),file)) {

	if (strncmp(buf,"#",1)) {

	    for(p = buf; *p > ' '; p++); *p = 0;
	    if (*buf) {
		cnt++;
	    } // end of if (*buf)

	} // end of if (strncmp(buf,"#",1))

    } // end of while 

    if (cnt < 1) goto wrapup;
    if (file) fclose(file);
    file = NULL;

    // allocate the list
    list = (IGRchar**) malloc(cnt * sizeof(IGRchar*));
    for (i = 0; i < cnt; i++) {
	list[i] = (IGRchar*) malloc(80 * sizeof(IGRchar));
    }
    
    // open the file
    file = openACLListFile();
    if (file == NULL) goto wrapup;

    // Cycle through
    cnt = 0;
    while(fgets(buf,sizeof(buf),file)) {

	if (strncmp(buf,"#",1)) {

	    for(p = buf; *p > ' '; p++); *p = 0;
	    if (*buf) {

		// get the setType from the access file
		strcpy(list[cnt],buf);
		//*list[cnt] = strdup(buf);
		//printf("ACL <%s>\n",list[cnt]);
		cnt++;


	    } // end of if (*buf)

	} // end of if (strncmp(buf,"#",1))

    }

    *aclCnt = cnt;
    *a_list = list;

    // done

wrapup:
    if (traceFlag) printf(">>> %s %s <%d>\n",ffn(),fn,*aclCnt);
    if (file) fclose(file);
    if (list) {
	for (i = 0; i < cnt; i++) free (list[i]);
	free(list);
    }

    return;
}

/* ----------------------------------------------
 * Get the users list of ACLs from the database
 * **/
static void getUsrAclList(IGRlong userid,
                          IGRint  *usrCnt,
			  IGRchar ***a_list)
{
    VDASSERT_FN("getUsrAclList");

    TVDrisInfo ris;
    IGRchar    sql[1024];
    IGRint     i,j;
    IGRint     cnt = 0;
    IGRchar    **list = NULL;
    
    // Arg check
    VDrisInitInfo( &ris );
    
    VDASSERTW(userid > 0);
    VDASSERTW(usrCnt);  *usrCnt = 0;
    VDASSERTW(a_list);

    // say hi
    if (traceFlag) printf(">>> %s %s <%d>\n",ffn(),fn,userid);

    // build the query
    sprintf(sql,
	    "Select nfmacls.n_aclname, nfmacls.n_aclno from "
	    "nfmacls, nfmaclusers where "
	    "nfmacls.n_aclno = nfmaclusers.n_aclno and "
	    "nfmaclusers.n_userno = %d", userid);

    // query
    VDrisQuery( &ris, sql );
    if (ris.rows < 1) goto wrapup;

    // allocate the list
    list = (IGRchar**) malloc(ris.rows * sizeof(IGRchar*));
    for (i = 0; i < ris.rows; i++) {
	list[i] = (IGRchar*) malloc(80 * sizeof(IGRchar));
    }
    
    // set the list
    for (i = 0; i < ris.rows; i++) {
	j = i * ris.cols;
	strcpy(list[i],ris.buf[j]);
	//*list[i] = strdup(ris.buf[j]);
	//printf("### usrList[%d] <%s>\n",i,list[i]);
	cnt++;
    }

    *usrCnt = cnt;
    *a_list = list;
    // done
wrapup:
    VDrisFreeInfo( &ris );
    if (list) {
	for (i = 0; i < cnt; i++) free (list[i]);
	free(list);
    }
    if (traceFlag) printf("<<< %s %s <%d>\n",ffn(),fn,*usrCnt);
}

/* -------------------------------------------------
 * Check if user has access to modify approved hull config
 * ****/
static IGRstat isUserValidForChgHullApprCfg()
{
    VDASSERT_FN("isUserValidForChgHullApprCfg");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar username[80];
    IGRlong userid;

    IGRchar **usrList = NULL;
    IGRint  usrCnt;
    IGRchar **aclList = NULL;
    IGRint  aclCnt;

    IGRint i,j;
    
    // init
    username[0] = '\0';
    userid      = 0;
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get username and userid
    sts = VDpdmGetUsernameID( username, &userid);
    if (username[0] == '\0') goto wrapup;
    if (userid      < 1 )   goto wrapup;
    if (traceFlag) printf("### username <%s>, userid <%d>\n",username,userid);

    // get the list of ACLs for the user
    usrCnt = 0;
    getUsrAclList(userid,&usrCnt,&usrList);
    if (usrCnt < 1) goto wrapup;

    // get the list of approved ACLs
    aclCnt = 0;
    getApprAclList(&aclCnt,&aclList);
    if (aclCnt < 1) goto wrapup;

    // compare
    for (i = 0; i < usrCnt; i++) {
	//printf("### usrList[%d] <%s>\n",i,usrList[i]);

	for (j = 0; j < aclCnt; j++) {
	//printf("### aclList[%d] <%s>\n",j,aclList[j]);
	
	if (!strcmp(aclList[j],usrList[i])) {
		retFlag = 1;
		goto wrapup;
	    }
	}  // end of acl List
    }  // end of usr list

    // done

wrapup:
    if ((usrList) && (*usrList)) {
	for (i = 0; i < usrCnt; i++) free (usrList[i]);
	free(usrList);
    }
    if ((aclList) && (*aclList)) {
	for (i = 0; i < aclCnt; i++) free (aclList[i]);
	free(aclList);
    }
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
    
/* ------------------------------------------------
 * Set the text in the Local file pull down list
 * this will include active file, and reference files.
 * ***/
static IGRstat setActiveFileText( )
{
    VDASSERT_FN("setActiveFileText");

    IGRstat retFlag = 1;
    IGRstat sts;


    VDASSERTW(s_form);

    // set the status
    VDfrmSetgText(s_form, VDPDM_PART_HULL_STATUS, "Getting Active File info");

    // do it
    VDpdmFillMCFActiveFile( s_form, VDPDM_PART_HULL_G_LOC_FILE, 0 ,1 );

    // done
    VDfrmSetgText(s_form, VDPDM_PART_HULL_STATUS, "Select an Active File");

wrapup:
    return retFlag;
}

/* --------------------------------------------------
 * Initialize settings on form.
 * Need to set up the list for level 1.
 * Need to enable / disable
 * ***/
static IGRstat initPtHullFormSettings( )
{
    VDASSERT_FN("initPtHullFormSettings");
    
    IGRstat retFlag = 1;
    IGRstat sts;
    IGRint  fromPDU = 0;
    IGRchar cat[80],part[80],rev[80];
    
    VDASSERTW(s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // set the default text for active file stuff
    setActiveFileText( );

    // disable on or off the add / remove buttons
    if ( !isUserValidForChgHullApprCfg() ) {
	
	// disable the add button
	VIg_disable( s_form, VDPDM_PART_HULL_ADD );

	// disable the remove button
	VIg_disable( s_form, VDPDM_PART_HULL_REMOVE );

	// disable the execute button
	//VIg_disable( s_form, FI_EXECUTE );
    }
    else {
	VIg_enable( s_form, VDPDM_PART_HULL_ADD );
	VIg_enable( s_form, VDPDM_PART_HULL_REMOVE );
	//VIg_enable( s_form, FI_EXECUTE );

    }

    // fill the purpose list gadget
    VDpdmFillPurposeListGadget( s_form, VDPDM_PART_HULL_G_PURPOSE );

    // fill cat/part/rev if refresh is available
    if (refresh != NULL) {
	if ( refresh->rev_catalog && refresh->rev_partid && refresh->rev_revision )
	{
	    if ( (*refresh->rev_catalog != 0) &&
		    (*refresh->rev_partid != 0 ) &&
		    (*refresh->rev_revision != 0) ) 
	    {
		strcpy(cat, refresh->rev_catalog);
		strcpy(part,refresh->rev_partid);
		strcpy(rev, refresh->rev_revision);
		fromPDU = 1;
	    }
	}

	if ( refresh->new_catalog && refresh->new_partid && refresh->new_revision )
	{
	    if ( (*refresh->new_catalog != 0) &&
		    (*refresh->new_partid != 0 ) &&
		    (*refresh->new_revision != 0) ) 
	    {
		strcpy(cat, refresh->new_catalog);
		strcpy(part,refresh->new_partid);
		strcpy(rev, refresh->new_revision);
		fromPDU = 1;
	    }
	}

	if (fromPDU) {
	    VDfrmSetgText( s_form, VDPDM_PART_HULL_G_CATALOG, cat );
	    VDfrmSetgText( s_form, VDPDM_PART_HULL_G_PART,    part );
	    VDfrmSetgText( s_form, VDPDM_PART_HULL_G_REV,     rev );
	    notifyFileKey( );
	}
    }


wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}


/* ----------------------------------------
 * form notification routine
 * ***/
static IGRint notifyForm(IGRint      f_label,
	                 IGRint      g_label,
			 IGRdouble   value,
			 Form        form)
{
    VDASSERT_FN("notifyForm");

    IGRstat retFlag = 1;
    IGRstat sts;
    IGRchar msg[80];

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    VDASSERTW(s_form);


    // switch on gadget
    switch(g_label) {
      
      case FI_CANCEL:
	  VDpdmKillPtHullForm();
	  break;

      case FI_RESET:
	  sts = initPtHullFormSettings( );
	  break;

      case FI_EXECUTE:
	  sts = notifyDoit( );
	  break;

      case VDPDM_PART_HULL_B_CLASS:
	  
	  sts = VDpdmCmdGetClassLevels(&class);
	  VDpdmClearGadgetList(s_form,VDPDM_PART_HULL_G_CATALOG);
	  VDpdmClearGadgetList(s_form,VDPDM_PART_HULL_G_PART);
	  VDpdmClearGadgetList(s_form,VDPDM_PART_HULL_G_REV);
	  VDfrmSetgText( s_form,VDPDM_PART_HULL_G_FILEKEY,"");
	  VDpdmClearGadgetColumn(form,VDPDM_PART_HULL_APPL_TO);
	  VDpdmClearGadgetColumn(form,VDPDM_PART_HULL_APPR_FOR);
	  notifyCatalog();
	  break;
          
      case VDPDM_PART_HULL_G_CATALOG:
	  
	  VDpdmClearGadgetList(s_form,VDPDM_PART_HULL_G_PART);
	  VDpdmClearGadgetList(s_form,VDPDM_PART_HULL_G_REV);
	  VDfrmSetgText( s_form,VDPDM_PART_HULL_G_FILEKEY,"");
	  VDpdmClearGadgetColumn(form,VDPDM_PART_HULL_APPL_TO);
	  VDpdmClearGadgetColumn(form,VDPDM_PART_HULL_APPR_FOR);
	  sts = notifyCatalog( );
	  
	  break;

      case VDPDM_PART_HULL_G_PART:
	  
	  VDpdmClearGadgetList(s_form,VDPDM_PART_HULL_G_REV);
	  VDfrmSetgText( s_form,VDPDM_PART_HULL_G_FILEKEY,"");
	  VDpdmClearGadgetColumn(form,VDPDM_PART_HULL_APPL_TO);
	  VDpdmClearGadgetColumn(form,VDPDM_PART_HULL_APPR_FOR);
	  sts = notifyPart( );
	  
	  break;
      
      case VDPDM_PART_HULL_G_REV:
	  
	  VDfrmSetgText( s_form,VDPDM_PART_HULL_G_FILEKEY,"");
	  VDpdmClearGadgetColumn(form,VDPDM_PART_HULL_APPL_TO);
	  VDpdmClearGadgetColumn(form,VDPDM_PART_HULL_APPR_FOR);
	  sts = notifyRev( );
	  
	  break;
      
      case VDPDM_PART_HULL_G_FILEKEY:
	  
	  sts = notifyFileKey( );
	  
	  break;
      
      case VDPDM_PART_HULL_ADD:
	  
	  sts = notifyAddApprHull( );
	  
	  break;

	  // CR 5866
      case VDPDM_PART_HULL_SET_ALL:

	  sts = notifySetAll();

	  break;

      case VDPDM_PART_HULL_CLEAR_ALL:

	  sts = notifyClearAll();

	  break;

	  // end of CR5866
      
      case VDPDM_PART_HULL_REMOVE:
	  
	  sts = notifyRemoveApprHull( );
	  
	  break;

      case VDPDM_PART_HULL_G_LOC_FILE:

	  sts = notifyLocalFile( );

	  break;

       
    }

wrapup:
    return retFlag;
}

/* ---------------------------------------------
 * Called by the Main form gadget.
 * ***/
IGRstat VDpdmInitPtHull()
{
    VDASSERT_FN("VDpdmInitPtHull");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;

    traceFlag = traceFlagx = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // should not be called again
    VDASSERTW(!s_form);
    
    // statics
    memset(&class,0,sizeof(TVDpdmClass));

    // wakeup the form
    sts = VDfrmNewForm(777, VDPDM_PART_HULL_F_NAME, notifyForm, 0, &s_form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( s_form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    // Initialize form settings
    sts = initPtHullFormSettings( );

    

wrapup:
    return 0;

}

/* -----------------------------------
 * Form Killer
 * **/
IGRstat VDpdmKillPtHullForm()
{
    VDASSERT_FN("VDpdmKillPtHullForm");

    if (s_form) {
	VDfrmDeleteForm( s_form, 1);
	s_form = NULL;
    }

wrapup:
    return 1;
}
