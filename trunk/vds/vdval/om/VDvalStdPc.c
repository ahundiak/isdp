/* $Id: VDvalStdPc.c,v 1.2 2002/02/27 16:35:14 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalStdPc.c
 *
 * Description: Standard Piece Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalStdPc.c,v $
 *      Revision 1.2  2002/02/27 16:35:14  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/11/09 15:04:29  ahundiak
 *      ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/07/01  ah      Creation, Started with vdat/pcmk2/VDatStd.c
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDtest.h"

#include "VDlog.h"
#include "VDrisc.h"
#include "VDobj2.h"
#include "VDctx.h"

#include "VDval.h"
#include "VDvalLike.h"

VDASSERT_FFN("vdat/pcmk2/VDatStd.c");

/* -----------------------------------------------------------------
 * Cleanup standard piece mark key errors
 */
static void printGetStdPcmkKeyError(IGRchar    *errorMsg, 
				    TGRobj_env *pieceOE,
				    TGRid      *macroID,
				    TGRid      *idID,
				    TGRobj_env *parent1OE,
				    TGRobj_env *parent2OE)
{
  // Do it
  VDlogPrintFmt(VDLOG_ERROR,1,"*** Problem generating standard piece mark key");
  VDlogPrintFmt(VDLOG_ERROR,1,"    %s",errorMsg);
  VDlogPrintOE (VDLOG_ERROR,1,"    PIECE    ",pieceOE);

  // Optional macro and id foot
  if (macroID) VDlogPrintID(VDLOG_ERROR,1,"    MACRO    ",macroID);
  if (idID)    VDlogPrintID(VDLOG_ERROR,1,"    FOOT ID  ",idID);

  // And the parents
  if (parent1OE) VDlogPrintOE(VDLOG_ERROR,1,"    PARENT 1 ",parent1OE);
  if (parent2OE) VDlogPrintOE(VDLOG_ERROR,1,"    PARENT 2 ",parent2OE);

  // Done
  VDlogPrintFmt(VDLOG_ERROR,1,"---\n");

 wrapup:
  return;
}

/* -----------------------------------------------------------------
 * Finds the standard piece mark key for the object
 */
IGRstat VDvalGetStdPcmk1Key(TGRobj_env *pieceOE, IGRchar *key)
{
  VDASSERT_FN("VDvalGetStdPcmk1Key");
  
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
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(key); *key = 0;
  VDASSERTW(pieceOE);
  
  // Init
  retFlag = 1;

  // Only source plates will be handled
  VDobjGetClassName(pieceOE,NULL,className);
  if (strcmp(className,"VSsrcPlate")) {
    goto wrapup;
  }

  // Get the macro it is placed on
  VDobjGetParent(pieceOE,NULL,0,&macID,NULL,&pretendID);
  
  // Make sure connected through pretend
  if (pretendID.objid == NULL_OBJID) goto wrapup;
  
  // Make sure got the parent macro
  if (macID.objid == NULL_OBJID) goto wrapup;

  // Grab it's name
  VDobjGetMacroName(NULL,&macID,macName);

  // Get a foot named ID
  VDmacGetFoot(&macID,"ID",&idID);
  if (idID.objid == NULL_OBJID) {

    // Consistency is all
    VDmacGetFoot(&macID,"id",&idID);
  }
  if (idID.objid == NULL_OBJID) {

    // Consistency is all
    VDmacGetFoot(&macID,"Id",&idID);
    
  }
  if (idID.objid == NULL_OBJID) goto wrapup;

  if (traceFlag) {  
    VDlogPrintID(VDLOG_INFO,1,NULL,&macID);
    VDlogPrintID(VDLOG_INFO,1,NULL,&idID);
  }
  
  // Get the pcmk attribute
  VDctxGetTxtAtr(&idID,"pcmk",idPcmk);
  if (*idPcmk == 0) {
    VDctxGetTxtAtr(&idID,"pcmk ",idPcmk);
  }
  if (*idPcmk == 0) {

    /* -------------------------------------------
     * Found one case where this happened
     * Code around it because it's still a useful quality check
     */
    if (!strcmp(macName,"wt_col_sm")) goto wrapup;

    /* -------------------------------------------
     * 03 April 2001 Found another case
     */
    if (!strcmp(macName,"nt_flush_col")) goto wrapup;

    // Warn for rest
    printGetStdPcmkKeyError("Macro had id foot but no pcmk attribute",
			    pieceOE,&macID,&idID,NULL,NULL);    
    goto wrapup;
  }
  if (traceFlag) {    
    printf("ID PCMK Expression '%s'\n",idPcmk);
  }
  
  p = strstr(idPcmk,"SIM");
  if (p) goto wrapup;

  // Filter by macro name
  VDobjGetMacroName(NULL,&macID,macName);
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
      printGetStdPcmkKeyError("Collar With id foot but not a wt_ or nt_",
			      pieceOE,&macID,&idID,NULL,NULL);    
      goto wrapup;
    }
  }
  if (traceFlag) printf("Macro Name %s\n",macName);

  // Little trick to get mod_env (not sure why)
  // Macros and the piece really should be in the same file
  VDobjGetTemplate(pieceOE,NULL,0,&srfOE);
  if (srfOE.obj_id.objid == NULL_OBJID) goto wrapup;
  macOE.mod_env = srfOE.mod_env;
  macOE.obj_id  = macID;

  // Get the parents
  VDobjGetTemplate(&macOE,NULL,0,&parent1OE);
  VDobjGetTemplate(&macOE,NULL,1,&parent2OE);

  // Must have
  if (parent1OE.obj_id.objid == NULL_OBJID) {
    printGetStdPcmkKeyError("Unable to locate penetrated parent",
			    pieceOE,&macID,&idID,&parent1OE,&parent2OE);
    goto wrapup;
  }
  if (parent2OE.obj_id.objid == NULL_OBJID) {
    printGetStdPcmkKeyError("Unable to locate penetrating parent",
			    pieceOE,&macID,&idID,&parent1OE,&parent2OE);
    goto wrapup;
  }
  
  if (traceFlag) {
    VDlogPrintOE(VDLOG_INFO,1,NULL,&parent1OE);
    VDlogPrintOE(VDLOG_INFO,1,NULL,&parent2OE);
  }
  
  // Family of penetrated element is also used
  VDctxGetTxtAtr(&parent1OE.obj_id,"family_name",family);
  if (*family == 0) {
    printGetStdPcmkKeyError("Unable to determine family_name for penetrated parent",
			    pieceOE,&macID,&idID,&parent1OE,&parent2OE);
    goto wrapup;
  }

  // Some special cases
  strlwr(family);
  cmp = strncmp(family,"i_t_",4);
  if (cmp) cmp = strncmp(family,"bulb_",5);
  if (cmp == 0) {
    //printf("Family %s is i_t_ or bulb_\n",family);
    if (type == '0') type = '3';
    if (type == '1') type = '7'; // TR3297
    if (type == '2') type = '4';
  }
  //else printf("Family %s is NOT i_t_ or bulb_\n",family);
  
  // Only makes sense to use grade from the clip or collar
  VDctxGetTxtAtr(&pieceOE->obj_id,"grade",grade);
  if (*grade == 0) {
    printGetStdPcmkKeyError("Unable to determine grade for piece",
			    pieceOE,&macID,&idID,&parent1OE,&parent2OE);
    goto wrapup;
  }

  // Use the thickness of the actual clip or collar itself
  VDctxGetDblAtr(&pieceOE->obj_id,"plate_thk",&thickness);
  if (thickness < .1) {
    printGetStdPcmkKeyError("Unable to determine thickness for piece",
			    pieceOE,&macID,&idID,&parent1OE,&parent2OE);
    goto wrapup;
  }
    
  // Use the part number from the second parent
  VDctxGetTxtAtr(&parent2OE.obj_id,"part_num",partNum);
  if (*partNum == 0) {
    printGetStdPcmkKeyError("Unable to determine part_num for penetrating parent",
			    pieceOE,&macID,&idID,&parent1OE,&parent2OE);
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
 * Hardcoded list of macro names
 */
static IGRchar *macNames[] = { 
  "nt_col_bulb",
  "nt_col_tee",
  "wt_col_tee",
  "nt_flush_tee",
  "clip_tee",
  "wt_col_bulb",
  "wt_col_fb",
  "wt_flush_tee",
  "wt_col_FB_IT",
  0
};

/* -----------------------------------------------------------------
 * Finds the standard piece mark information
 */
IGRstat VDvalGetStdPcmk2Info(TGRobj_env *pieceOE, IGRchar *geom_key, IGRchar *grade, IGRchar *thick)
{
  VDASSERT_FN("VDvalGetStdPcmk2Info");
  
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
  
  IGRchar   fam1 [64];
  IGRchar   part1[64];
  IGRchar   fam2 [64];
  IGRchar   part2[64];
  IGRdouble thickness;
  
  IGRchar *out;
  
  IGRint  pcmk;
  IGRchar *p;
  IGRint  cmp;
  
  IGRint  wt_nt;

  IGRint i;
  
  // Say Hi
  // traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(geom_key); *geom_key = 0;
  VDASSERTW(grade);    *grade = 0;
  VDASSERTW(thick)     *thick = 0;
  VDASSERTW(pieceOE);
  
  // Init
  retFlag = 1;

  // Only source plates will be handled
  VDobjGetClassName(pieceOE,NULL,className);
  if (strcmp(className,"VSsrcPlate")) {
    goto wrapup;
  }

  // Get the macro it is placed on
  VDobjGetParent(pieceOE,NULL,0,&macID,NULL,&pretendID);
  
  // Make sure connected through pretend
  if (pretendID.objid == NULL_OBJID) goto wrapup;
  
  // Make sure got the parent macro
  if (macID.objid == NULL_OBJID) goto wrapup;

  // Grab it's name
  VDobjGetMacroName(NULL,&macID,macName);

  // Check for being a valid macro
  for(i = 0; macNames[i] && strcmp(macNames[i],macName); i++);
  if (!macNames[i]) goto wrapup;
  if (traceFlag) {
    printf("Macro %s\n",macName);
  }
#if 0
  /* ---------------------------------------------
   * Try skipping all the sim stuff?
   * Based on the idea that the piece has to undergo
   * a geom check before being declared a standard?
   *
   * Go ahead and keep it for now
   * Maybe do a complete scan and flag any that fail
   * these checks
   */

  // Get a foot named ID
  VDmacGetFoot(&macID,"ID",&idID);
  if (idID.objid == NULL_OBJID) {

    // Consistency is all
    VDmacGetFoot(&macID,"id",&idID);
  }
  if (idID.objid == NULL_OBJID) {

    // Consistency is all
    VDmacGetFoot(&macID,"Id",&idID);
    
  }
  if (idID.objid == NULL_OBJID) goto wrapup;

  if (traceFlag) {  
    VDlogPrintID(VDLOG_INFO,1,NULL,&macID);
    VDlogPrintID(VDLOG_INFO,1,NULL,&idID);
  }
  
  // Get the pcmk attribute
  VDctxGetTxtAtr(&idID,"pcmk",idPcmk);
  if (*idPcmk == 0) {
    VDctxGetTxtAtr(&idID,"pcmk ",idPcmk);
  }
  if (*idPcmk == 0) goto wrapup;
    
  p = strstr(idPcmk,"SIM");
  // if (p) goto wrapup;
#endif

  // Little trick to get mod_env (not sure why)
  // Macros and the piece really should be in the same file
  VDobjGetTemplate(pieceOE,NULL,0,&srfOE);
  if (srfOE.obj_id.objid == NULL_OBJID) goto wrapup;
  macOE.mod_env = srfOE.mod_env;
  macOE.obj_id  = macID;

  // Get the parents
  VDobjGetTemplate(&macOE,NULL,0,&parent1OE);
  VDobjGetTemplate(&macOE,NULL,1,&parent2OE);

  // Must have
  if (parent1OE.obj_id.objid == NULL_OBJID) {
    printGetStdPcmkKeyError("Unable to locate penetrated parent",
			    pieceOE,&macID,NULL,&parent1OE,&parent2OE);
    goto wrapup;
  }
  if (parent2OE.obj_id.objid == NULL_OBJID) {
    printGetStdPcmkKeyError("Unable to locate penetrating parent",
			    pieceOE,&macID,NULL,&parent1OE,&parent2OE);
    goto wrapup;
  }
  
  if (traceFlag) {
    VDlogPrintOE(VDLOG_INFO,1,NULL,&parent1OE);
    VDlogPrintOE(VDLOG_INFO,1,NULL,&parent2OE);
  }
  
  // Family/part of penetrated element
  VDctxGetTxtAtr(&parent1OE.obj_id,"family_name",fam1);
  if (*fam1 == 0) {
    printGetStdPcmkKeyError("Unable to determine family_name for penetrated parent",
			    pieceOE,&macID,NULL,&parent1OE,&parent2OE);
    goto wrapup;
  }
  VDctxGetTxtAtr(&parent1OE.obj_id,"part_num",part1);
  if (*part1 == 0) {
    printGetStdPcmkKeyError("Unable to determine parent for penetrated parent",
			    pieceOE,&macID,NULL,&parent1OE,&parent2OE);
    goto wrapup;
  }
  // Family/part of penetrating element
  VDctxGetTxtAtr(&parent2OE.obj_id,"family_name",fam2);
  if (*fam2 == 0) {
    printGetStdPcmkKeyError("Unable to determine family_name for penetrating parent",
			    pieceOE,&macID,NULL,&parent1OE,&parent2OE);
    goto wrapup;
  }
  VDctxGetTxtAtr(&parent2OE.obj_id,"part_num",part2);
  if (*part2 == 0) {
    printGetStdPcmkKeyError("Unable to determine part_num for penetrating parent",
			    pieceOE,&macID,NULL,&parent1OE,&parent2OE);
    goto wrapup;
  }
  
  // Grade
  VDctxGetTxtAtr(&pieceOE->obj_id,"grade",grade);
  if (*grade == 0) {
    printGetStdPcmkKeyError("Unable to determine grade for piece",
			    pieceOE,&macID,NULL,&parent1OE,&parent2OE);
    goto wrapup;
  }

  // Use the thickness of the actual clip or collar itself
  VDctxGetDblAtr(&pieceOE->obj_id,"plate_thk",&thickness);
  if (thickness < .1) {
    printGetStdPcmkKeyError("Unable to determine thickness for piece",
			    pieceOE,&macID,NULL,&parent1OE,&parent2OE);
    goto wrapup;
  }
  sprintf(thick,"%.2f",thickness);
  
  // Geom key
  VDvalMakeStdGeomKeyFromStuff(macName,fam1,part1,fam2,part2,geom_key);
    
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s\n",fn);
  }
  
  return retFlag;
}

  
/* -----------------------------------------------------------------
 * Looks for anomilies in a potiental standard piece
 * Just a little utility routine
 */
IGRstat VDvalTestStdPcmk2Info(TGRobj_env *pieceOE, IGRchar *results)
{
  VDASSERT_FN("VDvalTestStdPcmk2Info");
  
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
  
  IGRchar   fam1 [64];
  IGRchar   part1[64];
  IGRchar   fam2 [64];
  IGRchar   part2[64];
  IGRchar   grade[64];
  IGRdouble thickness;
  
  IGRchar *out;
  
  IGRint  pcmk;
  IGRchar *p;
  IGRint  cmp;
  
  IGRint  wt_nt;

  IGRint i;
  
  // Say Hi
  // traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(results); *results = 0;
  VDASSERTW(pieceOE);
  
  // Init
  retFlag = 1;

  // Only source plates will be handled
  VDobjGetClassName(pieceOE,NULL,className);
  if (strcmp(className,"VSsrcPlate")) {
    goto wrapup;
  }

  // Get the macro it is placed on
  VDobjGetParent(pieceOE,NULL,0,&macID,NULL,&pretendID);
  
  // Make sure connected through pretend
  if (pretendID.objid == NULL_OBJID) goto wrapup;
  
  // Make sure got the parent macro
  if (macID.objid == NULL_OBJID) goto wrapup;

  // Grab it's name
  VDobjGetMacroName(NULL,&macID,macName);

  // Check for being a valid macro
  for(i = 0; macNames[i] && strcmp(macNames[i],macName); i++);
  if (!macNames[i]) goto wrapup;
  if (traceFlag) {
    printf("Macro %s\n",macName);
  }

  /* ---------------------------------------------
   * Try skipping all the sim stuff?
   * Based on the idea that the piece has to undergo
   * a geom check before being declared a standard?
   *
   * Go ahead and keep it for now
   * Maybe do a complete scan and flag any that fail
   * these checks
   */

  // Get a foot named ID
  VDmacGetFoot(&macID,"ID",&idID);
  if (idID.objid == NULL_OBJID) {

    // Consistency is all
    VDmacGetFoot(&macID,"id",&idID);
  }
  if (idID.objid == NULL_OBJID) {

    // Consistency is all
    VDmacGetFoot(&macID,"Id",&idID);
    
  }
  if (idID.objid == NULL_OBJID) {
    strcpy(results,"Missing ID object\n");
    goto wrapup;
  }
  
  if (traceFlag) {  
    VDlogPrintID(VDLOG_INFO,1,NULL,&macID);
    VDlogPrintID(VDLOG_INFO,1,NULL,&idID);
  }
  
  // Get the pcmk attribute
  VDctxGetTxtAtr(&idID,"pcmk",idPcmk);
  if (*idPcmk == 0) {
    VDctxGetTxtAtr(&idID,"pcmk ",idPcmk);
  }
  if (*idPcmk == 0) {
    strcpy(results,"Missing pcmk attribute in ID\n");
    goto wrapup;
  }
  
  p = strstr(idPcmk,"SIM");
  if (p) {
    strcpy(results,"Have a SIM Flag\n");
    goto wrapup;
  }
  
  // Little trick to get mod_env (not sure why)
  // Macros and the piece really should be in the same file
  VDobjGetTemplate(pieceOE,NULL,0,&srfOE);
  if (srfOE.obj_id.objid == NULL_OBJID) goto wrapup;
  macOE.mod_env = srfOE.mod_env;
  macOE.obj_id  = macID;

  // Get the parents
  VDobjGetTemplate(&macOE,NULL,0,&parent1OE);
  VDobjGetTemplate(&macOE,NULL,1,&parent2OE);

  // Must have
  if (parent1OE.obj_id.objid == NULL_OBJID) {
    strcpy(results,"Missing penetrated parent\n");
    goto wrapup;
  }
  if (parent2OE.obj_id.objid == NULL_OBJID) {
    strcpy(results,"Missing penetrating parent\n");
    goto wrapup;
  }
  
  if (traceFlag) {
    VDlogPrintOE(VDLOG_INFO,1,NULL,&parent1OE);
    VDlogPrintOE(VDLOG_INFO,1,NULL,&parent2OE);
  }
  
  // Family/part of penetrated element
  VDctxGetTxtAtr(&parent1OE.obj_id,"family_name",fam1);
  if (*fam1 == 0) {
    strcpy(results,"Missing family_name for penetrated parent\n");
    goto wrapup;
  }
  VDctxGetTxtAtr(&parent1OE.obj_id,"part_num",part1);
  if (*part1 == 0) {
    strcpy(results,"Missing part_num for penetrated parent\n");
    goto wrapup;
  }
  // Family/part of penetrating element
  VDctxGetTxtAtr(&parent2OE.obj_id,"family_name",fam2);
  if (*fam2 == 0) {
    strcpy(results,"Missing family_name for penetrating parent\n");
    goto wrapup;
  }
  VDctxGetTxtAtr(&parent2OE.obj_id,"part_num",part2);
  if (*part2 == 0) {
    strcpy(results,"Missing part_num for penetrating parent\n");
    goto wrapup;
  }
  
  // Grade
  VDctxGetTxtAtr(&pieceOE->obj_id,"grade",grade);
  if (*grade == 0) {
    strcpy(results,"Missing grade for piece\n");
    goto wrapup;
  }

  // Use the thickness of the actual clip or collar itself
  VDctxGetDblAtr(&pieceOE->obj_id,"plate_thk",&thickness);
  if (thickness < .1) {
    strcpy(results,"Missing thickness for piece\n");    
    goto wrapup;
  }
    
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s\n",fn);
  }
  
  return retFlag;
}
