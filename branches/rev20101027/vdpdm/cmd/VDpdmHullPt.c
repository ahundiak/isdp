/* $Id: VDpdmHullPt.c,v 1.12 2002/05/10 19:33:50 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmHullPt.c
 *
 * Description: Given a Hull, display the files which are approved for that hull
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmHullPt.c,v $
 *      Revision 1.12  2002/05/10 19:33:50  ahundiak
 *      ah
 *
 *      Revision 1.11  2001/10/03 14:02:37  jdsauby
 *      Utilize COset_trace for debug
 *
 *      Revision 1.10  2001/07/16 13:52:50  jdsauby
 *      VDassert working with Z D F
 *
 *      Revision 1.9  2001/04/12 20:41:30  jdsauby
 *      sp 11
 *
 *      Revision 1.8  2001/03/08 14:39:27  jdsauby
 *      Re - organization of VDpdm.h
 *
 *      Revision 1.7  2001/03/07 19:08:15  jdsauby
 *      Added more status comments.  Better Purpose Info.
 *
 *      Revision 1.6  2001/03/05 19:43:26  jdsauby
 *      Finish Purpose Info
 *
 *      Revision 1.5  2001/03/02 21:45:32  jdsauby
 *      Added purpose Info
 *
 *      Revision 1.4  2001/02/23 16:10:13  jdsauby
 *      Just some more changes, nearing completion
 *
 *      Revision 1.3  2001/02/21 13:00:29  jdsauby
 *      CR4088
 *
 *      Revision 1.2  2001/02/11 17:54:47  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/02/05 16:38:01  jdsauby
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

VDASSERT_FFN("vdpdm/cmd/VDpdmHullPt.c");

/* --------------------------------------
 * Use a static to share data between functions.
 * TVDpdmRefList structure will work to store list
 * of Catalog, Part, Rev, Filekey.
 * ***/
static TVDpdmRefList g_list;
static Form          s_form;

/* -------------------------------------
 * Hull is picked, input a default filename
 * ***/
static IGRstat notifyHull( )
{
    VDASSERT_FN("notifyHull");

    IGRstat retFlag = 0;
    IGRchar hull[40];
    IGRchar filename[80];

    VDASSERTW(s_form);
    // init
    *hull = 0;
    
    // get the hull
    VDfrmGetgText( s_form, VDPDM_HULL_PART_G_HULL, hull);
    if (*hull == 0) goto wrapup;

    sprintf(filename,"%s.txt",hull);

    // set it
    VDfrmSetgText( s_form, VDPDM_HULL_PART_G_FILE, filename);

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* --------------------------------------
 * filter the list by the purpose info
 * ***/
static IGRstat filterByPurposeInfo( TVDpdmRefList *list,
	                            IGRchar       *zone,
				    IGRchar       *unit,
				    IGRchar       *system,
				    IGRchar       *purpose )
{
    VDASSERT_FN("filterByPurposeInfo");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRint  i,valid,key;
    TVDpdmPurposeInfo  purpInfo;

    // say hi

    if (list == NULL) goto wrapup;
    if (list->cnt < 1) goto wrapup;

    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    // do it
    for (i = 0; i < list->cnt; i++) {
	// clear it
	valid = 1;

	// query for the purpose info
	key = list->infos[i].filekey;
	if (traceFlag) printf("Key <%d>\n",key);
	VDpdmQryPurposeInfo( key, &purpInfo );
	if (*purpInfo.purpose != 0) {

	    // compare it
	    if( (*zone)    && (strcmp(zone,   purpInfo.zone))    ) valid = 0;
	    if(traceFlag) printf("Zone <%d>\n",valid);

	    if( (*unit)    && (strcmp(unit,   purpInfo.unit))    ) valid = 0;
	    if(traceFlag) printf("Unit <%d>\n",valid);

	    if( (*system)  && (strcmp(system, purpInfo.system))  ) valid = 0;
	    if(traceFlag) printf("System <%d>\n",valid);

	    if( (*purpose) && (strcmp(purpose,purpInfo.purpose)) ) valid = 0;
	    if(traceFlag) printf("Purpose <%d>\n",valid);


	    // add it
	    if (valid) VDpdmAddPartToRefList( &g_list, &list->infos[i] );
	}
    }

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
		
/* --------------------------------------
 * Get the files approved for hull config
 * ***/
static IGRstat getApprCfgFilesForHull(IGRchar    *hull,
	                              IGRchar    *zone,
	                              IGRchar    *unit,
	                              IGRchar    *system,
	                              IGRchar    *purpose)
{
    VDASSERT_FN("getApprCfgFilesForHull");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar sql[256], buf[80];
    TVDrisInfo ris;
    IGRint  i,j;
    TVDpdmInfo info;
    TVDpdmRefList list;

    // init
    VDrisInitInfo( &ris );
    VDpdmInitRefList( &list );
    VDASSERTW(hull[0] != '\0');

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // build the qry
    sprintf(sql,
	    "Select %s,%s,%s,%s from %s where %s='%s' ",
	    VDPDM_HULL_APP_COLN_FILE_KEY,
	    VDPDM_HULL_APP_COLN_CATALOG,
	    VDPDM_HULL_APP_COLN_PART,
	    VDPDM_HULL_APP_COLN_REVISION,
	    VDPDM_HULL_APP_TABLE_NAME,
	    VDPDM_HULL_APP_COLN_HULL_APP, hull );

    // order it
    sprintf(buf,
	    "and %s=%d order by %s;",
	    VDPDM_HULL_APP_COLN_IS_APPROVED, VDPDM_IS_APPROVED,
	    VDPDM_HULL_APP_COLN_CATALOG);
    strcat( sql, buf );

    if (traceFlag) printf("### sql: \n %s\n",sql);

    // do the query
    VDrisQuery( &ris, sql );
    if (ris.rows < 1) goto wrapup;

    // fill g_list
    for (i = 0; i < ris.rows; i++) {
	memset(&info,0,sizeof(info));

	j = i * ris.cols;

	info.filekey = atoi(ris.buf[j]);
	strcpy(info.catalog,ris.buf[j+1]);
	strcpy(info.part,   ris.buf[j+2]);
	strcpy(info.rev,    ris.buf[j+3]);

	// add it to list
	VDpdmAddPartToRefList( &list, &info );

	if (traceFlag) printf("<%d> <%s> <%s> <%s>\n",
		info.filekey, info.catalog, info.part, info.rev);

    }

    // check
    if (list.cnt < 1) goto wrapup;

    // filter down by purpose info
    if ( (*zone) || (*unit) || (*system) || (*purpose) ) {
	if (traceFlag) printf("### Filtering\n");
	
	sts = filterByPurposeInfo( &list, zone, unit, system, purpose );
	retFlag = sts;
	goto wrapup;
    }
    
    // no filtering required
    g_list = list;

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    VDpdmFreeRefList( &list );
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/* ---------------------------------------
 * Do it gadget
 * **/
static IGRstat notifyDoit( )
{
    VDASSERT_FN("notifyDoit");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar hull   [24],
            msg    [80],
	    zone   [12],
	    purpose[80],
	    unit   [12],
	    system [40];

    IGRint      i,j,k;
    IGRchar fkey[40];

    VDASSERTW(s_form);
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init
    *hull    = 0;
    *zone    = 0;
    *unit    = 0;
    *purpose = 0;
    *system  = 0;
    
    // init g_list
    VDpdmInitRefList( &g_list );

    // clear the display area of the form
    VDpdmClearGadgetColumn( s_form, VDPDM_HULL_PART_G_DISPLAY );

    // get the hull
    VDfrmGetgText( s_form, VDPDM_HULL_PART_G_HULL, hull );
    if (*hull == 0) {
	strcpy(msg,"Need to Select a HULL");
	VDfrmSetgText( s_form, VDPDM_HULL_PART_G_STATUS, msg );
	retFlag = 1;
	goto wrapup;
    }

    // get the zone,unit,purpose,system not required
    VDfrmGetgText( s_form, VDPDM_HULL_PART_G_ZONE,    zone );
    if (!strcmp(zone,"")) *zone = 0;
    VDfrmGetgText( s_form, VDPDM_HULL_PART_G_UNIT,    unit );
    if (!strcmp(unit,"")) *unit = 0;
    VDfrmGetgText( s_form, VDPDM_HULL_PART_G_SYSTEM,  system );
    if (!strcmp(system,"")) *system = 0;
    VDfrmGetgText( s_form, VDPDM_HULL_PART_G_PURPOSE, purpose );
    if (!strcmp(purpose,"")) *purpose = 0;

    // query it
    sts = getApprCfgFilesForHull( hull, zone, unit, system, purpose);
    if (!(sts & 1)) goto wrapup;

    // fill the form
    if (g_list.cnt < 1) goto wrapup;
    for( i = 0; i < g_list.cnt; i++ ) {

	sprintf(fkey,"%d",g_list.infos[i].filekey);
	FIfld_set_text(s_form, VDPDM_HULL_PART_G_DISPLAY,
		i, 0, fkey, 0);    
	FIfld_set_text(s_form, VDPDM_HULL_PART_G_DISPLAY,
		i, 1, g_list.infos[i].catalog, 0);
	FIfld_set_text(s_form, VDPDM_HULL_PART_G_DISPLAY,
		i, 2, g_list.infos[i].part, 0);
	FIfld_set_text(s_form, VDPDM_HULL_PART_G_DISPLAY,
		i, 3, g_list.infos[i].rev, 0);
    }

    // done
    retFlag = 1;
    VDfrmSetgText(s_form, VDPDM_HULL_PART_G_STATUS, "Done");

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* --------------------------------------
 * Writes an output file
 * ***/
static IGRstat notifyWrite( )
{
    VDASSERT_FN("notifyWrite");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar filename[128];
    IGRchar delim[20];
    IGRchar hull[40];
    IGRchar zone[40];
    IGRint  i;

    FILE *file = NULL;

    VDASSERTW(s_form);
    // init
    *filename = 0;
    *delim    = 0;
    *hull     = 0;
    *zone     = 0;

    // make sure we have something to write
    if (g_list.infos == NULL) {
	sts = notifyDoit( );
	if (!(sts & 1)) goto wrapup;
    }
    
    // get the filename
    VDfrmGetgText(s_form, VDPDM_HULL_PART_G_FILE, filename);
    if (*filename == 0) {
	VDfrmSetgText(s_form, VDPDM_HULL_PART_G_STATUS, "Please enter filename");
	goto wrapup;
    }

    // get the delimiter
    VDfrmGetgText(s_form, VDPDM_HULL_PART_G_DELIMITOR, delim);

    // get the hull
    VDfrmGetgText(s_form, VDPDM_HULL_PART_G_HULL, hull);
    if (*hull == 0) goto wrapup;

    // open the file
    file = fopen(filename,"wt");
    if (file == NULL) file = stdout;

    // Put in the header info
    fprintf(file,
	    "Parts approved for hull <%s>:\n",hull);
    
    // fill in the rest of the file
    if (*delim == 0) {
	fprintf(file,
		"%-6s %-20s %-20s %-8s\n",
		"Key","Catalog","Part","Rev");
	for (i = 0; i < g_list.cnt; i++) {
	    fprintf(file,
		    "%6d %-20s %-20s %-8s\n",
		    g_list.infos[i].filekey,g_list.infos[i].catalog,
		    g_list.infos[i].part,   g_list.infos[i].rev);
	}
	retFlag = 1;
	goto wrapup;
    }
    
    // with a delimitor
    for (i = 0; i < g_list.cnt; i++) {
	fprintf(file,
		"%d%s%s%s%s%s%s%s\n",
		g_list.infos[i].filekey, delim,
		g_list.infos[i].catalog, delim,
		g_list.infos[i].part,    delim,
		g_list.infos[i].rev,     delim);
    }

    // done
    retFlag = 1;
    VDfrmSetgText(s_form, VDPDM_HULL_PART_G_STATUS, "File Written");

wrapup:
    if ( (file) && (file != stdout) ) fclose(file);
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

    VDASSERTW(s_form);
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // switch on gadget
    switch(g_label) {
      
      case FI_CANCEL:
	  VDpdmKillHullPtForm();
	  break;

      case FI_EXECUTE:
	  sts = notifyDoit();
	  break;

      case VDPDM_HULL_PART_G_HULL:
	  sts = notifyHull();
	  break;

      case VDPDM_HULL_PART_G_WRITE:
	  sts = notifyWrite();
	  break;
      
    }

wrapup:
    return retFlag;
}

/* ---------------------------------------------
 * Called by the Main form gadget.
 * ***/
IGRstat VDpdmInitHullPt()
{
    VDASSERT_FN("VDpdmInitHullPt");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;


    traceFlag = traceFlagx = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);

    VDASSERTW(!s_form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // wakeup the form
    sts = VDfrmNewForm (888, VDPDM_HULL_PART_F_NAME, notifyForm, 0, &s_form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( s_form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    sts = VDpdmFillPurposeListGadget( s_form , VDPDM_HULL_PART_G_PURPOSE );


wrapup:
    return 0;

}

/* -----------------------------------
 * Form Killer
 * **/
IGRstat VDpdmKillHullPtForm()
{
    VDASSERT_FN("VDpdmKillHullPtForm");

    if (s_form) {
	VDfrmDeleteForm( s_form, 1);

	s_form = NULL;
    }

    if (g_list.cnt > 0) VDpdmFreeRefList( &g_list );

wrapup:
    return 1;
}
