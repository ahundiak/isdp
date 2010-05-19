/* $Id: VDrrvDbOps.c,v 1.5 2002/02/28 15:06:31 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvDbOps.C
 *
 * Description: Snapshot command, Database Operations
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/12/01  js      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDfrmc.h"
#include "VDtest.h"

#include "VDctx.h"
#include "VDdoom.h"
#include "VDlog.h"
#include "VDat.h"
#include "VDxml.h"
#include "VDrisc.h"
#include "VDpdm.h"

#include "VDrrvCmd.h"

#include <sys/types.h>
#include <dirent.h>

VDASSERT_FFN("vdcty/rrv/VDrrvDbOps.c");

/* -----------------------------------
 * File Operations data structure
 * **/
typedef struct
{
  IGRchar    hull[64];
  IGRchar    type[64];
  IGRchar    name[64];
  IGRchar    ts  [64];
  IGRint     b_key;
} D_info;

typedef struct
{
  Form    form;
  IGRint  loop;
  IGRchar unit[64];
  IGRint  cnt;
  IGRint  inc;
  IGRint  max;
  D_info  *infos;
} D_infos;

static D_infos db;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

/* --------------------------------------------------
 * Initializes a Db Ops info structure
 */
static IGRstat VDrrvInitDbOpsInfo( D_infos *list )
{
  VDASSERT_FN("VDpdmInitDbOpsInfo");

  IGRstat retFlag = 0;
  Form    form = NULL;

  //printf(">>> %s\n",fn);
  // Argcheck
  if (list == NULL) goto wrapup;

  // save the form if already active
  if (list->form) form = list->form;

  // Clear
  memset(list,0,sizeof(D_infos));

  // Setup
  *list->unit = 0;
  list->loop  = 0;
  list->max   = 5;
  list->inc   = 5;
  list->infos = calloc(list->max,sizeof(D_info));

  if (list->infos == NULL) {
      printf("*** Problem allocating memory for D_infos\n");
      goto wrapup;
  }

  // Done
  if (form) list->form = form;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Frees a Db Ops info structure
 */
static IGRstat VDrrvFreeDbOpsInfo( D_infos *list )
{
    IGRstat retFlag = 0;
    
    IGRint  i;

    // Argcheck
    if (list == NULL) goto wrapup;
    if (list->infos == NULL) goto wrapup;

    //printf(">>> VDrrvFreeFileOpsInfo\n");
    // Free the array of pointers
    free(list->infos);

    // Done
    retFlag = 1;

wrapup:
    if (list) memset(list,0,sizeof(D_infos));
    return retFlag;
}

/* ------------------------------------------------
 * Adds a part to the D_infos structure
 */
static IGRstat VDrrvAddToDbOpsInfo( D_infos  *list,
                                    D_info   *part )
{
    IGRstat retFlag = 0;
    IGRstat traceFlag = 0;

    D_info  *parts;

    // Arg check
    if (part == NULL)        goto wrapup;
    if (list == NULL)        goto wrapup;
    if (list->infos == NULL) goto wrapup;

    // Expand list if necessary
    if (list->cnt == list->max) {

	parts = realloc(list->infos,(list->max + list->inc) * sizeof(D_info));

	if (parts == NULL) {
	    printf("*** Problem allocating D_infos list\n");
	    goto wrapup;
	}
	list->infos = parts;
	list->max  += list->inc;
    }

    // Add it
    list->infos[list->cnt] = *part;
    list->cnt++;

    // Done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* ----------------------------------------------
 * View button was selected
 * **/
static void notifyView()
{
  VDASSERT_FN("notifyView");
  IGRstat sts;

  IGRint  row, sel, j;
  IGRchab filename;

  VDASSERTW(&db);
  VDASSERTW(db.form);
  VDASSERTW(db.infos);

  // get the active selection
  VDfrmGetActiveRow(db.form, VDRRV_FORM_DB_OPS_L_DOOMS, &row, NULL);
  //printf("### row <%d>\n",row);

  // is it selected
  VDfrmGetSelect (db.form, VDRRV_FORM_DB_OPS_L_DOOMS, row, 0, &sel);
  if (!sel) goto wrapup;

  // filename should include path
  sprintf(filename,"/usr/tmp/%s_%s.ss.xml",db.infos[row].type,db.infos[row].name);
  //printf("### filename <%s>\n",filename);

  VDfrmSetgText(db.form, VDRRV_FORM_DB_OPS_STATUS, "Getting Record From DB");

  // get the blob record
  sts = VDrisSelectBlobRecord(db.infos[row].b_key,filename,1,0,UI_status);
  if (!(sts & 1)) {
      VDfrmSetgText(db.form, VDRRV_FORM_DB_OPS_STATUS, "Could Not get Record");
      goto wrapup;
  }
  
  // call the review form to do the work
  VDlogShowCat(filename);
  
  // done
  VDfrmSetgText(db.form, VDRRV_FORM_DB_OPS_STATUS, "Done");

wrapup:
  return;
}
  

/* ----------------------------------------------
 * Load db button was selected
 * **/
static void loadFromDb()
{
  VDASSERT_FN("loadFromDb");
  IGRstat sts;

  IGRint  row, sel, j;
  IGRchab filename;

  VDASSERTW(&db);
  VDASSERTW(db.form);
  VDASSERTW(db.infos);

  // get the active selection
  VDfrmGetActiveRow(db.form, VDRRV_FORM_DB_OPS_L_DOOMS, &row, NULL);
  //printf("### row <%d>\n",row);

  // is it selected
  VDfrmGetSelect (db.form, VDRRV_FORM_DB_OPS_L_DOOMS, row, 0, &sel);
  if (!sel) goto wrapup;

  // filename should include path
  sprintf(filename,"/usr/tmp/%s_%s.ss.xml",db.infos[row].type,db.infos[row].name);
  //printf("### filename <%s>\n",filename);

  VDfrmSetgText(db.form, VDRRV_FORM_DB_OPS_STATUS, "Getting Record From DB");

  // get the blob record
  sts = VDrisSelectBlobRecord(db.infos[row].b_key,filename,1,0,UI_status);
  if (!(sts & 1)) {
      VDfrmSetgText(db.form, VDRRV_FORM_DB_OPS_STATUS, "Could Not get Record");
      goto wrapup;
  }
  
  // call the review form to do the work
  VDrrvLoadFromFile(filename);
  
  // done
  VDfrmSetgText(db.form, VDRRV_FORM_DB_OPS_STATUS, "Done");
wrapup:
  return;
}
  
/* ----------------------------------------------
 * Check to make sure file is a snapshot xml file
 * **/
static IGRstat qryBlobIForInfoBuf(IGRchar    *unit,
                                  IGRchar    *hull,
				  TVDrisInfo *ris)
{
  VDASSERT_FN("qryBlobIForInfoBuf");
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar sql[1024];
  IGRchar buf[128];

  VDASSERTW(*unit != 0);
  VDASSERTW(ris);

  // build it
  sprintf(sql,
	  "Select %s,%s,%s,%s,%s from %s where %s='%s' ",
	  VDRIS_COLN_BLOBI_HULL,     VDRIS_COLN_BLOBI_SET_TYPE,
	  VDRIS_COLN_BLOBI_SET_NAME, VDRIS_COLN_BLOBI_POST_DATE,
	  VDRIS_COLN_BLOBI_BLOB_KEY, VDRIS_TBLN_BLOBI,
	  VDRIS_COLN_BLOBI_SET_NAME, unit );

  if (*hull != 0) {
      sprintf(buf,
	      "and %s='%s' ", VDRIS_COLN_BLOBI_HULL, hull);
      strcat(sql,buf);
  }

  sprintf(buf,"and %s=1;",VDRIS_COLN_BLOBI_SET_CUR);
  strcat (sql,buf);

  // do it
  VDrisQuery( ris, sql );

  // done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get list of snapshots from database matching the unit and hull
 * **/
static IGRstat getDbOpsInfos(IGRchar *unit,
                             IGRchar *hull)
{
  VDASSERT_FN("getDbOpsInfos");
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i,j;

  TVDrisInfo  ris;

  D_info  info;

  VDrisInitInfo( &ris );
  // arg check
  VDASSERTW(*unit != 0);

  // Qry for infos buf
  qryBlobIForInfoBuf(unit, hull, &ris);
  if (ris.rows < 1) goto wrapup;

  // Cycle through
  for (i = 0; i < ris.rows; i++) {
      j = i * ris.cols;

      // set info
      strcpy(info.hull, ris.buf[j]  );
      strcpy(info.type, ris.buf[j+1]);
      strcpy(info.name, ris.buf[j+2]);
      strcpy(info.ts  , ris.buf[j+3]);
      info.b_key = atoi(ris.buf[j+4]);

      // add to infos
      VDrrvAddToDbOpsInfo(&db, &info);
  }

  // done
  retFlag = 1;

wrapup:
  VDrisFreeInfo( &ris );
  return retFlag;
}

/* -----------------------------------------------
 * Fill the Db Ops form
 * **/
static IGRstat VDrrvCmdFillSnapshotDbOps(IGRchar *unit,
                                         IGRchar *hull)
{
  VDASSERT_FN("VDrrvCmdFillSnapshotDbOps");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint i, gadget, row;

  IGRchab name;
  IGRchar *p;
  
  // Arg check
  VDASSERTW(*unit != 0);
  gadget = VDRRV_FORM_DB_OPS_L_DOOMS;
  
  // clear the form
  VDfrmSetNumRows(db.form,gadget,0);
  
  // get F_infos
  getDbOpsInfos(unit,hull);
  if (db.cnt < 1) {
      // set status to no files found in path
      VDfrmSetgText(db.form, VDRRV_FORM_DB_OPS_STATUS, "No Db Records found"); 
      retFlag = 1;
      goto wrapup;
  }

  // loop through, and place on form
  for (i = 0; i < db.cnt; i++) {
      // set MCF text
      VDfrmSetfText(db.form,gadget,i,
	      VDRRV_FORM_DB_OPS_L_DOOMS_HULL,db.infos[i].hull);
      
      VDfrmSetfText(db.form,gadget,i,
	      VDRRV_FORM_DB_OPS_L_DOOMS_TYPE,db.infos[i].type);

      VDfrmSetfText(db.form,gadget,i,
	      VDRRV_FORM_DB_OPS_L_DOOMS_NAME,db.infos[i].name);
      
      VDfrmSetfText(db.form,gadget,i,
	      VDRRV_FORM_DB_OPS_L_DOOMS_TS,  db.infos[i].ts);
  }

  // done
  retFlag = 1;

wrapup:
  VDfrmSetgText(db.form, VDRRV_FORM_DB_OPS_STATUS, "Pick one");
  return retFlag;
}

/* -----------------------------------------------
 * Unit was entered
 * **/
static IGRstat notifyUnit()
{
  VDASSERT_FN("notifyUnit");

  IGRchab hull;
  
  // arg check
  VDASSERTW(db.form);
  *hull = 0;

  VDrrvInitDbOpsInfo( &db );
  VDASSERTW(&db);

  // get the unit
  VDfrmGetgText(db.form, VDRRV_FORM_DB_OPS_G_UNIT, db.unit);
  if (*db.unit == 0) {
      VDfrmSetgText(db.form, VDRRV_FORM_DB_OPS_STATUS, "Must Have a UNIT");
      goto wrapup;
  }

  // get the hull, not a required parameter
  VDfrmGetgText(db.form, VDRRV_FORM_DB_OPS_G_HULL, hull);

  // fill the form
  VDrrvCmdFillSnapshotDbOps(db.unit,hull);

  // done
wrapup:
  return 1;
}

/* ----------------------------------------------
 * Something selected on list
 * **/
static IGRstat notifyShowBlobKey()
{
  VDASSERT_FN("notifyShowBlobKey");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint  row, sel, j;
  IGRchar blob[128];

  VDASSERTW(&db);
  VDASSERTW(db.form);
  VDASSERTW(db.infos);

  // get the active selection
  VDfrmGetActiveRow(db.form, VDRRV_FORM_DB_OPS_L_DOOMS, &row, NULL);

  // is it selected
  VDfrmGetSelect (db.form, VDRRV_FORM_DB_OPS_L_DOOMS, row, 0, &sel);
  if (!sel) goto wrapup;

  // filename should include path
  sprintf(blob,"%d",db.infos[row].b_key);

  // display in status area
  VDfrmSetgText(db.form, VDRRV_FORM_DB_OPS_STATUS, blob);

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * File Operations form notification routine
 * **/
IGRint  VDrrvCmdNotifyDbOps(IGRint    f_label,
                            IGRint    gadget,
                            IGRdouble value,
                            Form      form)
{
  VDASSERT_FN("VDrrvCmdNotifyDbOps");
  IGRstat retFlag = 0;

  // Internal data must be set
  VDASSERTW(&db);
  VDASSERTW(db.form);
  
  //printf(">>> %s\n",fn);
  // Process it
  switch(gadget) {

    case FI_CANCEL:

      // Clean up
      VDrrvCmdKillSnapshotDbOps();
      break;

    case VDRRV_FORM_DB_OPS_G_UNIT:
      notifyUnit();
      break;

    case VDRRV_FORM_DB_OPS_G_HULL:
      notifyUnit();
      break;

    case VDRRV_FORM_DB_OPS_L_DOOMS:
      notifyShowBlobKey();
      break;

    case VDRRV_FORM_DB_OPS_B_LOAD:
      loadFromDb();
      break;

    case VDRRV_FORM_DB_OPS_B_VIEW:
      notifyView();
      break;

  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Bring up the database operations form and init
 *
 */
IGRstat VDrrvCmdInitSnapshotDbOps()
{
  VDASSERT_FN("VDrrvCmdInitSnapshotDbOps");
  IGRstat retFlag = 0;
  IGRstat sts;

  D_infos  list;

  XEvent event;

  // should be logged into database
  sts = VDpdmVerifyLogin();
  if (!(sts & 1)) {
      UI_status("Not Logged into PDM");
      goto wrapup;
  }
  
  // Should not be called recursivily
  VDASSERTW(!db.form);

  // Setup structure
  VDrrvInitDbOpsInfo( &db );
  VDASSERTW(&db);

  // Create the form
  sts = VDfrmNewForm(VDRRV_FORM_DB_OPS_NUM,
		     VDRRV_FORM_DB_OPS_NAME,
		     VDrrvCmdNotifyDbOps,1,&db.form);
  VDASSERTW(sts);
  VDASSERTW(db.form);

  // Display it
  VDfrmDisplayForm(db.form,1,NULL);

  // Fill in form info
  //VDrrvCmdFillSnapshotFileOps(db.unit);

  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Loop on events
 * Usually called from a test routine
 * really need to add prompts and command name here
 */
void VDrrvCmdLoopSnapshotDbOps()
{
  VDASSERT_FN("VDrrvCmdLoopSnapshotDbOps");
  IGRstat sts;

  XEvent event;
  
  //printf(">>> %s\n",fn);
  // Should not be called recursivily
  //VDASSERTW(*fo && fo.form);
  
  // Loop until form told to break out
  db.loop = 1;
  while(db.loop) {
    XNextEvent(_FI_display, &event);
    FI_process_event(&event, 0);
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Shuts down
 * Usually called from the ppl command object on
 * something like clear stack.
 */
void VDrrvCmdKillSnapshotDbOps()
{
  VDASSERT_FN("VDrrvCmdKillSnapshotDbOps");
  
  // Check if running
  //if (*fo == NULL) goto wrapup;
  //printf(">>> %s\n",fn);

  // Free the form if necessary
  if (db.form) VDfrmDeleteForm(db.form,1);

  // Free F_infos
  if (&db) VDrrvFreeDbOpsInfo( &db );

  // Done
  //*fo = NULL;
  
 wrapup:
  return;  
}

