/* $Id: VDatStd.I,v 1.4 2001/03/13 00:17:12 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk/VDatStd.I
 *
 * Description: Standard Piece Mark Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatStd.I,v $
 *      Revision 1.4  2001/03/13 00:17:12  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/11 17:40:52  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.2  2001/01/11 20:54:46  art
 *      sp merge
 *
# Revision 1.2  2000/11/27  19:22:20  pinnacle
# ah
#
# Revision 1.1  2000/06/27  17:34:38  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 ***************************************************************************/

class implementation VDatBase;

#include "VDat.h"
#include "VDatPcmk.h"

#include "VDsa.h"
#include "VDobj.h"
#include "VDmac.h"
#include "VDmem.h"
#include "VDobj.h"
#include "VDrisc.h"

#include "VDassert.h"
#include "VDlog.h"

VDASSERT_FFN("vdat/pcmk/VDatStd.I");

#define NEXT_PCMK "ZNEXT_STD_PCMK"

/* -----------------------------------------------------------------
 * Given a key, lookup the actual piece mark
 * Create it if need be
 */
IGRstat VDatGetStdPcmkForKey(IGRchar *key, IGRint *a_pcmk)
{
  VDASSERT_FN("VDatGetStdPcmkForKey");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  pcmk = 0;
  
  IGRchar sql[256];

  TVDrisInfo ris;
  
  // Init
  vdris$InitInfo(info = &ris);

  // Say hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }  
  
  // Arg check
  VDASSERTW(a_pcmk);
  VDASSERTW(key);
 
  // Need a key
  if (*key == 0)    goto wrapup;

  // Make sure logged in
  sts = vdris$IsLoggedIn();
  if (!(sts & 1)) goto wrapup;

  // Look it up
  sprintf(ris.sql,"Select pcmk from std_pcmk where std_key = '%s';",key);
  vdris$Query(info = &ris);
  if (ris.rows > 0) {
    pcmk = atoi(ris.buf[0]);
    retFlag = 1;
    goto wrapup;
  }
  vdris$FreeInfo(info = &ris);
  
  // Need the next number
  sprintf(ris.sql,"Select pcmk from std_pcmk where std_key = '%s';",NEXT_PCMK);
  vdris$Query(info = &ris);

  // Check it
  if (ris.rows > 0) {

    // Update it
    pcmk = atoi(ris.buf[0]);
    sprintf(sql,
	    "Update std_pcmk set pcmk = %d where std_key = '%s';",
	    pcmk + 1,NEXT_PCMK);
    vdris$Execute(sql = sql);
  }
  else {
    // First one
    pcmk = 9000;
    sprintf(ris.sql,
	    "Insert into std_pcmk values ('%s',%d);",
	    NEXT_PCMK,pcmk+1);
    vdris$Execute(sql = sql);
  }
  vdris$FreeInfo(info = &ris);
  
  // Add new pcmk
  sprintf(sql,
	  "Insert into std_pcmk values ('%s',%d);",
	  key,pcmk);
  vdris$Execute(sql = sql);

  // Done
  retFlag = 1;
  
wrapup:

  // Return value
  if (a_pcmk) *a_pcmk = pcmk;
  
  // Just to be safe
  vdris$FreeInfo(info = &ris);
  
  // Say Bi
  if (traceFlag) {
    printf("<<< %s\n",fn);
  }  
  return retFlag;
}

/* -----------------------------------------------------------------
 * Finds the standard piece mark key for the object
 */
IGRstat VDatGetStdPcmkKey(TGRobj_env *pieceOE, IGRchar *key)
{
  VDASSERT_FN("VDatGetStdPcmkKey");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env macOE;
  TGRobj_env srfOE;
  TGRobj_env parent1OE,parent2OE;
  
  IGRchar className[64];
  IGRchar idPcmk[64];
  
  IGRchar type;
  
  TGRid idID,macID;
  TGRid pretendID;
  
  IGRchar macName[64];
  
  IGRchar   family[64];
  IGRchar   grade [64],partNum[64];
  IGRdouble thickness;
  
  IGRchar *out;
  
  IGRint  pcmk;
  IGRchar *p;
  IGRint  cmp;
  
  IGRint  wt_nt;

  // Say Hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }
  
  // Arg check
  VDASSERTW(key);
  *key = 0;
  VDASSERTW(pieceOE);
  
  // Init
  retFlag = 1;
  
  // Only source plates will be handled
  vdobj$Get(objOE = pieceOE, className = className);
  if (strcmp(className,"VSsrcPlate")) {
    goto wrapup;
  }

  // Get the macro it is placed on
  vdobj$GetParent(objOE = pieceOE, idx = 0, parentID = &macID, pretendID = &pretendID);
  
  // Make sure connected through pretend
  if (pretendID.objid == NULL_OBJID) goto wrapup;
  
  // Make sure got the parent macro
  if (macID.objid == NULL_OBJID) goto wrapup;

  // Get a foot named ID
  vdmac$Get(objID = &macID, footName = "ID", footID = &idID);
  if (idID.objid == NULL_OBJID) {

    // Consistency is all
    vdmac$Get(objID = &macID, footName = "id", footID = &idID);

  }
  if (idID.objid == NULL_OBJID) {

    // Consistency is all
    vdmac$Get(objID = &macID, footName = "Id", footID = &idID);

  }
  if (idID.objid == NULL_OBJID) goto wrapup;

  if (traceFlag) {  
    vdobj$Print(objID = &macID);
    vdobj$Print(objID = &idID);
  }
  
  // Get the pcmk attribute
  vdsa$GetStruct(objID = &idID, name = "pcmk",txt = idPcmk);
  if (*idPcmk == 0) {
    vdsa$GetStruct(objID = &idID, name = "pcmk ",txt = idPcmk);
  }
  if (*idPcmk == 0) {

    /* -------------------------------------------
     * Found one case where this happened
     * Code around it because it's still a useful quality check
     */
    vdobj$Get(objID = &macID, macName = macName);
    if (!strcmp(macName,"wt_col_sm")) goto wrapup;
    
    // Warn for rest
    VDlogPrintFmt(VDLOG_ERROR,1,"*** Have an id macro with no pcmk attribute");
    VDlogPrintID (VDLOG_ERROR,1,NULL,&idID);
    VDlogPrintID (VDLOG_ERROR,1,NULL,&macID);
    VDlogPrintOE (VDLOG_ERROR,1,NULL,pieceOE);
    VDlogPrintFmt(VDLOG_ERROR,1,"---\n");
    goto wrapup;
  } 
  if (traceFlag) {    
    printf("ID PCMK Expression '%s'\n",idPcmk);
  }
  
  p = strstr(idPcmk,"SIM");
  if (p) goto wrapup;

  // Filter by macro name
  vdobj$Get(objID = &macID, macName = macName);
  p = strstr(macName,"_id");
  if (p) goto wrapup;
  
  // Get rid of shell collars as well
  p = strstr(macName,"_sh");
  if (p) {
    // printf("Shell %s\n",macName);
    goto wrapup;
  }
  
  type = ' ';
  
  p = strstr(macName,"_col_");
  if (p) {
    type = '0';
    goto got_it;
  }
  
  p = strstr(macName,"_clip_");
  if (p) {
    type = '1';
    goto got_it;
  }
  
  p = strstr(macName,"flush");
  if (p) {
    type = '5';
    goto got_it;
  }

  if (!strcmp(macName,"clip_tee")) {
    type = '1';
    goto got_it;
  }
  
  goto wrapup;
  
got_it:  

  // Tweak for wt collars
  if ((type == '0') || (type == '5')) {

    /* -------------------------------------------
     * ah - 04 Oct 2000
     * Real mystery here.  Used to use strstr to determine
     * if has wt_ or nt_ but it stopped working
     * for the ppl version
     */
    wt_nt = 0;
    cmp = strncmp(macName,"wt_",3);
    if (cmp == 0) wt_nt = 1;
    cmp = strncmp(macName,"nt_",3);
    if (cmp == 0) wt_nt = 2;
        
    if (wt_nt == 2) { 
      if (type == '0') type = '2';
      if (type == '5') type = '6';
    }

    if (wt_nt == 0) {      
      VDlogPrintFmt(VDLOG_ERROR,1,"*** Collar With ID but not a wt_ or nt_ '%s'",macName);
      VDlogPrintOE (VDLOG_ERROR,1,NULL,pieceOE);
      goto wrapup;
    }
  }
  if (traceFlag) {  
    printf("Macro Name %s\n",macName);
  }

  // Little trick to get mod_env (not sure why)
  vdobj$GetTemplate(objOE = pieceOE, nth = 0, templateOE = &srfOE);
  if (srfOE.obj_id.objid == NULL_OBJID) goto wrapup;
  macOE.mod_env = srfOE.mod_env;
  macOE.obj_id  = macID;

  // Get the parents
  vdobj$GetTemplate(objOE = &macOE, nth = 0, templateOE = &parent1OE);
  vdobj$GetTemplate(objOE = &macOE, nth = 1, templateOE = &parent2OE);

  if (traceFlag) {
    vdobj$Print(objOE = &parent1OE);
    vdobj$Print(objOE = &parent2OE);
  }
  
  // Family of penetrated element is also
  vdsa$GetStruct(objOE = &parent1OE, name = "family_name", txt = family);
  if (*family == 0) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** No family for first parent");
    VDlogPrintOE (VDLOG_ERROR,1,NULL,&parent1OE);
    VDlogPrintOE (VDLOG_ERROR,1,NULL,&parent2OE);
    VDlogPrintOE (VDLOG_ERROR,1,NULL,&macOE);
    VDlogPrintOE (VDLOG_ERROR,1,NULL,pieceOE);
    VDlogPrintFmt(VDLOG_ERROR,1,"---");
    goto wrapup;
  }
  
  VDstrlwr(family);
  cmp = strncmp(family,"i_t_",4);
  if (cmp) cmp = strncmp(family,"bulb_",5);
  if (cmp == 0) {
    //printf("Family %s is i_t_ or bulb_\n",family);
    if (type == '0') type = '3';
    if (type == '2') type = '4';
  }
  //else printf("Family %s is NOT i_t_ or bulb_\n",family);
  
  // Only makes sense to use grade from the clip or collar
  vdsa$GetStruct(objOE = pieceOE, name = "grade", txt = grade);
  if (*grade == 0) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** No grade for plate");
    VDlogPrintOE (VDLOG_ERROR,1,NULL,pieceOE);
    goto wrapup;
  }

  // Use the thickness of the actual clip or collar itself
  vdsa$GetStruct(objOE = pieceOE, name = "plate_thk", dbl = &thickness);
  
  // Use the part number from the second parent
  vdsa$GetStruct(objOE = &parent2OE, name = "part_num", txt = partNum);
  if (*partNum == 0) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** No part_num for second parent");
    VDlogPrintOE (VDLOG_ERROR,1,NULL,&parent1OE);
    VDlogPrintOE (VDLOG_ERROR,1,NULL,&parent2OE);
    VDlogPrintOE (VDLOG_ERROR,1,NULL,&macOE);
    VDlogPrintOE (VDLOG_ERROR,1,NULL,pieceOE);
    VDlogPrintFmt(VDLOG_ERROR,1,"---");
    goto wrapup;
  }
  
  // Put it all together
  sprintf(key,"%c %-10s %6.2f %s",type,grade,thickness,partNum);
  if (traceFlag) {  
    printf("KEY %s %s\n",key,macName);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s\n",fn);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Replacement for SA_PPL:pcmk:std_pcmk
 * NOT STANDARD if not a standard
 * STANDARD if standard but not logged in
 * Otherwise, the piece mark
 *
 * Seems to run awfully slow, would expect this to really fly
 * when not logged into pdm
 */
IGRstat VDatGetStdPcmkFromPiece(TGRobj_env *pieceOE, IGRchar *a_pcmk)
{
  VDASSERT_FN("VDatGetStdPcmkFromPiece");
  IGRstat retFlag = 0;

  IGRchar key[128];
  IGRint  pcmk = 0;
  
  // Arg check
  VDASSERTW(a_pcmk);
  strcpy(a_pcmk,"NOT STANDARD");
  VDASSERTW(pieceOE);
  
  // Start by getting key;
  VDatGetStdPcmkKey(pieceOE,key);
  if (*key == 0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Convert to integer
  VDatGetStdPcmkForKey(key,&pcmk);
  if (pcmk == 0) strcpy (a_pcmk,"STANDARD");
  else           sprintf(a_pcmk,"%d",pcmk);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

    
/* -----------------------------------------------
 * Sets one standard piece mark info
 */
IGRstat VDatGetStandardPcmkInfo(TVDatPcmkInfo *info)
{
  IGRstat retFlag = 0;
  IGRchar std_pcmk[40];
  TVDatPcmkLeafInfo *leaf;
  
  // Arg check
  if (info == NULL) goto wrapup;
  leaf = info->leaf;

  VDatGetStdPcmkFromPiece(&leaf->pieceOE,std_pcmk);
  
#if 0
  vdsa$GetStruct(objOE = &leaf->pieceOE,
		 name  = "SA_PPL:pcmk:std_pcmk",
		 txt   =  std_pcmk);
#endif

  // This means it's a standard but not logged into the database
  if (!strcmp(std_pcmk,"STANDARD")) {
    leaf->pcmk2 = leaf->pcmk1;
    if (leaf->pcmk2 < VDAT_PCMK_STD_MIN) leaf->pcmk2 = VDAT_PCMK_STD_UNK;

    // printf("Standard %s\n",leaf->pieceName);
    
    retFlag = 1;
    goto wrapup;
  }

  // If it's not a standard, leave blank
  if (!strcmp(std_pcmk,"NOT STANDARD")) {
    
    // Just leave at zero
    retFlag = 1;
    goto wrapup;
  }
  
  // Got it
  leaf->pcmk2 = atoi(std_pcmk);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Pass through the list of piece marks and determine
 * which pieces are standard
 */
IGRstat VDatGetStandardPcmkInfos(TVDatPcmkInfos *infos)
{
  IGRstat retFlag = 0;
  IGRint  i;
  IGRchar buf[128];
  
  // Arg check
  if (infos == NULL) goto wrapup;
  
  // Loop through
  for(i = 0; i < infos->cnt; i++) {

    // Allow Interrupts
    if (IGEstop()) goto wrapup;

    // Inform
    if ((i % 25) == 0) {
      sprintf(buf,"Getting Standard Piece Info %d of %d...",i,infos->cnt);
      UI_status(buf);
    }

    // Do It
    VDatGetStandardPcmkInfo(&infos->infos[i]);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  UI_status("Done getting standard piece info");
  return retFlag;
}

end implementation VDatBase;





