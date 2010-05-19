/* $Id: VDrrvFile.c,v 1.5 2002/02/28 15:07:40 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvFile.C
 *
 * Description: Snapshot Command, File Operations
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
#include "VDlog.h"
#include "VDfrmc.h"
#include "VDtest.h"

#include "VDctx.h"
#include "VDdoom.h"
#include "VDat.h"
#include "VDxml.h"

#include "VDrrvCmd.h"

#include <sys/types.h>
#include <dirent.h>

VDASSERT_FFN("vdcty/rrv/VDrrvFile.c");

/* -----------------------------------
 * File Operations data structure
 * **/
typedef struct
{
  IGRchar    type[64];
  IGRchar    name[64];
  IGRchar    ts  [64];
  IGRchar    file[64];
} F_info;

typedef struct
{
  Form    form;
  IGRint  loop;
  IGRchar path[128];
  IGRint  cnt;
  IGRint  inc;
  IGRint  max;
  F_info  *infos;
} F_infos;

static F_infos fo;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

/* --------------------------------------------------
 * Initializes a File Ops info structure
 */
static IGRstat VDrrvInitFileOpsInfo( F_infos *list )
{
  VDASSERT_FN("VDpdmInitFileOpsInfo");

  IGRstat retFlag = 0;
  Form    form = NULL;

  //printf(">>> %s\n",fn);
  // Argcheck
  if (list == NULL) goto wrapup;

  // save the form if already active
  if (fo.form) form = fo.form;

  // Clear
  memset(list,0,sizeof(F_infos));

  // Setup
  sprintf(list->path,".");
  list->loop = 0;
  list->max  = 5;
  list->inc  = 5;
  list->infos = calloc(list->max,sizeof(F_info));

  if (list->infos == NULL) {
      printf("*** Problem allocating memory for F_infos\n");
      goto wrapup;
  }

  // Done
  if (form) list->form = form;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Frees a File Ops info structure
 */
static IGRstat VDrrvFreeFileOpsInfo( F_infos *list )
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
    if (list) memset(list,0,sizeof(F_infos));
    return retFlag;
}

/* ------------------------------------------------
 * Adds a part to the F_infos structure
 */
static IGRstat VDrrvAddToFileOpsInfo( F_infos  *list,
                                      F_info   *part )
{
    IGRstat retFlag = 0;
    IGRstat traceFlag = 0;

    F_info  *parts;

    // Arg check
    if (part == NULL)        goto wrapup;
    if (list == NULL)        goto wrapup;
    if (list->infos == NULL) goto wrapup;

    // Expand list if necessary
    if (list->cnt == list->max) {

	parts = realloc(list->infos,(list->max + list->inc) * sizeof(F_info));

	if (parts == NULL) {
	    printf("*** Problem allocating F_infos list\n");
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
  IGRchab msg;

  VDASSERTW(&fo);
  VDASSERTW(fo.form);
  VDASSERTW(fo.infos);
  VDASSERTW(fo.path);

  // get the active selection
  VDfrmGetActiveRow(fo.form, VDRRV_FORM_FILE_OPS_L_DOOMS, &row, NULL);
  //printf("### row <%d>\n",row);

  // is it selected
  VDfrmGetSelect (fo.form, VDRRV_FORM_FILE_OPS_L_DOOMS, row, 0, &sel);
  if (!sel) goto wrapup;

  // filename should include path
  sprintf(filename,"%s/%s",fo.path,fo.infos[row].file);
  //printf("### filename <%s>\n",filename);

  // this can take some time, better say it is working
  sprintf(msg,"Opening %s ...",fo.infos[row].file);
  VDfrmSetgText(fo.form, VDRRV_FORM_FILE_OPS_STATUS, msg);

  // call the review form to do the work
  VDlogShowCat(filename);
  
  // done

wrapup:
  return;
}
  

/* ----------------------------------------------
 * Load file button was selected
 * **/
static void loadFromFile()
{
  VDASSERT_FN("loadFromFile");
  IGRstat sts;

  IGRint  row, sel, j;
  IGRchab filename;

  VDASSERTW(&fo);
  VDASSERTW(fo.form);
  VDASSERTW(fo.infos);
  VDASSERTW(fo.path);

  // get the active selection
  VDfrmGetActiveRow(fo.form, VDRRV_FORM_FILE_OPS_L_DOOMS, &row, NULL);
  //printf("### row <%d>\n",row);

  // is it selected
  VDfrmGetSelect (fo.form, VDRRV_FORM_FILE_OPS_L_DOOMS, row, 0, &sel);
  if (!sel) goto wrapup;

  // filename should include path
  sprintf(filename,"%s/%s",fo.path,fo.infos[row].file);
  //printf("### filename <%s>\n",filename);

  // call the review form to do the work
  VDrrvLoadFromFile(filename);
  
  // done

wrapup:
  return;
}
  
/* ----------------------------------------------
 * Check to make sure file is a snapshot xml file
 * **/
static IGRstat isFileaSnapshotFile(IGRchar *fname,
                                   F_info  *info)
{
  VDASSERT_FN("isFileaSnapshotFile");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDctxBaseInfo  baseInfo;
  TGRid           doomID;

  IGRchar     base_info[1024];
  IGRchar     filename [1024];

  VDASSERTW(*fname != 0);
  VDASSERTW(info);

  // init
  doomID.objid = NULL_OBJID;
  doomID.osnum = 2;
  *base_info = 0;
  *filename  = 0;
  
  //printf(">>> %s <%s/%s>\n",fn,fo.path,fname);
  // parse the file to get doomID
  sprintf(filename,"%s/%s",fo.path,fname);
  VDASSERTW(*filename);
  
  VDdoomXmlParseFileForRoot(filename, &doomID);
  if (doomID.objid == NULL_OBJID) goto wrapup;

  // check to see if it has a base_info attribute
  //printf("### get base_info attribute\n");
  VDctxGetTxtAtr(&doomID,VDCTX_ATR_BASE_INFO,base_info);
  if (*base_info == 0) goto wrapup;

  // By now, it should be verified that it is a snapshot file
  // Get the other necessary information to display on form.
  VDctxGetBaseInfo(&doomID,&baseInfo);
  if (*baseInfo.setType == 0) goto wrapup;
  if (*baseInfo.setName == 0) goto wrapup;
  
  VDctxGetTxtAtr(&doomID,VDCTX_ATR_CREATION_TIMESTAMP,info->ts);
  if (*info->ts == 0) goto wrapup;

  // set the rest of info
  strcpy(info->type,baseInfo.setType);
  strcpy(info->name,baseInfo.setName);
  strcpy(info->file,fname);

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}
  
/* -----------------------------------------------
 * List .xml files in path, fill the F_infos data
 * **/
static IGRstat getFileOpsInfos(IGRchar *path)
{
  VDASSERT_FN("getFileOpsInfos");
  IGRstat retFlag = 0;
  IGRstat sts;

  DIR *dp;
  struct dirent *dpx;

  IGRchab name;
  IGRchar *p;
  IGRchar filter[12];

  F_info  info;

  IGRint flag;
  
  // arg check
  if (*path == 0) strcpy(path,".");
  strcpy(filter,".xml");

  //printf(">>> %s\n",fn);
  // Open up
  dp = opendir(path);
  if (dp == NULL) goto wrapup;
  
  // Cycle through
  while((dpx = readdir(dp)))
  {
    strcpy(name,dpx->d_name);

    // Filter
    flag = 0;
    p = strrchr(name,'.');
    if (p && !strcmp(p,filter)) flag = 1;
      
    if (flag) {
      if (isFileaSnapshotFile(name,&info)) {
	VDrrvAddToFileOpsInfo(&fo, &info);
      }
    }    
  }
  closedir(dp);

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Fill the File Ops form
 * **/
static IGRstat VDrrvCmdFillSnapshotFileOps(IGRchar *path)
{
  VDASSERT_FN("VDrrvCmdFillSnapshotFileOps");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint i, gadget, row;

  IGRchab name;
  IGRchar *p;
  
  // Arg check
  VDASSERTW(path);
  gadget = VDRRV_FORM_FILE_OPS_L_DOOMS;
  
  // clear the form
  VDfrmSetNumRows(fo.form,gadget,0);
  
  // get F_infos
  getFileOpsInfos(path);
  if (fo.cnt < 1) {
      // set status to no files found in path
      VDfrmSetgText(fo.form, VDRRV_FORM_FILE_OPS_STATUS, "No file found"); 
      retFlag = 1;
      goto wrapup;
  }

  // loop through, and place on form
  for (i = 0; i < fo.cnt; i++) {
      // set MCF text
      // fo->info[i].type, fo->info[i].name, fo->info[i].ts
      VDfrmSetfText(fo.form,gadget,i,
	      VDRRV_FORM_FILE_OPS_L_DOOMS_TYPE,fo.infos[i].type);

      VDfrmSetfText(fo.form,gadget,i,
	      VDRRV_FORM_FILE_OPS_L_DOOMS_NAME,fo.infos[i].name);
      
      VDfrmSetfText(fo.form,gadget,i,
	      VDRRV_FORM_FILE_OPS_L_DOOMS_TS,  fo.infos[i].ts);
  }

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Path was entered
 * **/
static IGRstat notifyPath()
{
  VDASSERT_FN("notifyPath");

  // arg check
  VDASSERTW(fo.form);

  VDrrvInitFileOpsInfo( &fo );
  VDASSERTW(&fo);

  // get the path
  VDfrmGetgText(fo.form, VDRRV_FORM_FILE_OPS_G_PATH, fo.path);
  if (*fo.path == 0) strcpy(fo.path,".");

  // fill the form
  VDrrvCmdFillSnapshotFileOps(fo.path);

  // done
wrapup:
  return 1;
}

/* ----------------------------------------------
 * Something selected on list
 * **/
static IGRstat notifyShowFileName()
{
  VDASSERT_FN("notifyShowFileName");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint  row, sel, j;
  IGRchar filename[128];

  VDASSERTW(&fo);
  VDASSERTW(fo.form);
  VDASSERTW(fo.infos);

  // get the active selection
  VDfrmGetActiveRow(fo.form, VDRRV_FORM_FILE_OPS_L_DOOMS, &row, NULL);

  // is it selected
  VDfrmGetSelect (fo.form, VDRRV_FORM_FILE_OPS_L_DOOMS, row, 0, &sel);
  if (!sel) goto wrapup;

  // filename should include path
  sprintf(filename,"%s",fo.infos[row].file);

  // display in status area
  VDfrmSetgText(fo.form, VDRRV_FORM_FILE_OPS_STATUS, filename);

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * File Operations form notification routine
 * **/
IGRint  VDrrvCmdNotifyFileOps(IGRint    f_label,
                              IGRint    gadget,
                              IGRdouble value,
                              Form      form)
{
  VDASSERT_FN("VDrrvCmdNotifyFileOps");
  IGRstat retFlag = 0;

  // Internal data must be set
  VDASSERTW(&fo);
  VDASSERTW(fo.form);
  
  //printf(">>> %s\n",fn);
  // Process it
  switch(gadget) {

    case FI_CANCEL:

      // Clean up
      VDrrvCmdKillSnapshotFileOps();
      break;

    case VDRRV_FORM_FILE_OPS_G_PATH:
      notifyPath();
      break;

    case VDRRV_FORM_FILE_OPS_L_DOOMS:
      notifyShowFileName();
      break;

    case VDRRV_FORM_FILE_OPS_B_LOAD:
      loadFromFile();
      break;

    case VDRRV_FORM_FILE_OPS_B_VIEW:
      notifyView();
      break;

  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Bring up the file operations form and init
 *
 */
IGRstat VDrrvCmdInitSnapshotFileOps()
{
  VDASSERT_FN("VDrrvCmdInitSnapshotFileOps");
  IGRstat retFlag = 0;
  IGRstat sts;

  F_infos  list;

  XEvent event;
  
  // Should not be called recursivily
  VDASSERTW(!fo.form);

  // Setup structure
  VDrrvInitFileOpsInfo( &fo );
  VDASSERTW(&fo);

  // Create the form
  sts = VDfrmNewForm(VDRRV_FORM_FILE_OPS_NUM,
		     VDRRV_FORM_FILE_OPS_NAME,
		     VDrrvCmdNotifyFileOps,1,&fo.form);
  VDASSERTW(sts);
  VDASSERTW(fo.form);

  // Display it
  VDfrmDisplayForm(fo.form,1,NULL);

  // Fill in form info
  VDrrvCmdFillSnapshotFileOps(fo.path);

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
void VDrrvCmdLoopSnapshotFileOps()
{
  VDASSERT_FN("VDrrvCmdLoopSnapshotFileOps");
  IGRstat sts;

  XEvent event;
  
  //printf(">>> %s\n",fn);
  // Should not be called recursivily
  //VDASSERTW(*fo && fo.form);
  
  // Loop until form told to break out
  fo.loop = 1;
  while(fo.loop) {
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
void VDrrvCmdKillSnapshotFileOps()
{
  VDASSERT_FN("VDrrvCmdKillSnapshotFileOps");
  
  // Check if running
  //if (*fo == NULL) goto wrapup;
  //printf(">>> %s\n",fn);

  // Free the form if necessary
  if (fo.form) VDfrmDeleteForm(fo.form,1);

  // Free F_infos
  if (&fo) VDrrvFreeFileOpsInfo( &fo );

  // Done
  //*fo = NULL;
  
 wrapup:
  return;  
}

