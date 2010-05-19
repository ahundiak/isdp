/* $Id: VDatStdTest.C,v 1.1 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk/VDatStdTest.C
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatStdTest.C,v $
 *      Revision 1.1  2001/01/11 20:54:46  art
 *      sp merge
 *
 * Revision 1.3  2000/10/15  13:48:36  pinnacle
 * ah
 *
 * Revision 1.2  2000/09/25  17:44:54  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/05  15:15:40  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/04/00  ah      Creation
 ***************************************************************************/

/* -----------------------------------------------
 * 04 Aug 2000
 * This code was written mainly to test a proposed change to the
 * standard piece mark key generation routine.
 *
 * Wanted a means to quickly scan a tree for standard pieces and generated
 * new keys as well as lists of what pieces were in what units.
 *
 * Checked the code in to keep track of it. Be aware however that the real
 * deployed key generator is in the ppl called "pcmk.e".  The routine here was copied
 * from the ppl.
 *
 * 25 Sep 2000
 * More changes to handle _flush macros as well as penetrating i_it/bulb members
 */ 
#include "VDtypedef.h"   
#include "VDat.h"
#include "VDatPcmk.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"
#include "VDmac.h"

/* -----------------------------------------------------------------
 * Generate a standard piece mark key for a plate
 */
IGRstat VDatGenerateStdPcmkKey(TGRobj_env *pieceOE, IGRchar *key)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  
  IGRchar className[32];
  IGRchar idPcmk   [64];
  IGRchar macName  [64];

  IGRchar   family[32];
  IGRchar   grade [32],partNum[64];
  IGRdouble thickness;

  TGRid   macID,pretendID,idID;
  
  TGRobj_env surfOE,macOE,parent1OE,parent2OE;

  IGRchar *p;
  IGRchar  type;
  
  // Arg check
  if (key == NULL) goto wrapup;
  *key = 0;
  if (pieceOE == NULL) goto wrapup;

  // Only source plates will be handled
  vdobj$Get(objOE = pieceOE, className = className);
  if (strcmp(className,"VSsrcPlate")) {
    traceFlag = 0;
    goto wrapup;
  }

  if (traceFlag) {
    printf(">>> VDatGenerateStdPcmkKey\n");
    vdobj$Print(objOE = pieceOE);
  }

  // Get the macro it is placed on
  vdobj$GetParent(objOE = pieceOE, idx = 0, parentID = &macID, pretendID = &pretendID);
  
  // Make sure connected through pretend
  if (pretendID.objid == NULL_OBJID) {
    if (traceFlag) printf("No pretend object\n");
    goto wrapup;
  }
  
  // Make sure got the parent macro
  if (macID.objid == NULL_OBJID) {
    if (traceFlag) printf("No macro object\n");
    goto wrapup;
  }

  if(traceFlag) {  
    vdobj$Print(objID = &macID);
  }
  
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
  if (idID.objid == NULL_OBJID) {
    if (traceFlag) printf("No ID object\n");
    goto wrapup;
  }
  
  if(traceFlag) {  
    vdobj$Print(objID = &idID);
  }
  
  // Get the pcmk attribute
  vdsa$GetStruct(objID = &idID, name = "pcmk",txt = idPcmk);
  if (*idPcmk == 0) {
    vdsa$GetStruct(objID = &idID, name = "pcmk ",txt = idPcmk);
  }
  if (*idPcmk == 0) {
    printf("*** Have an id macro with no pcmk attribute\n");
    vdobj$Print(objOE = pieceOE);
    goto wrapup;
  } 
  if (traceFlag) printf("PCMK '%s'\n",idPcmk);
  p = strstr(idPcmk,"SIM");
  if (p) goto wrapup;

  // Filter by macro name
  vdobj$Get(objID = &macID, macName = macName);
  p = strstr(macName,"_id");
  if (p) goto wrapup;
  
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
  
  if (!strcmp(macName,"clip_tee")) {
    type = '1';
    goto got_it;
  }

  p = strstr(macName,"flush");
  if (p) {
    type = '5';
    goto got_it;
  }

  if (traceFlag) {
    printf("Macro is not a collar or clip\n");
  }
  
  goto wrapup;
  
got_it:  
  if (traceFlag) printf("Macro Name %s\n",macName);
  // Tweak for wt collars
  if ((type == '0') || (type == '5')) {

    p = strstr(macName,"nt_");
    if (p == macName) {
      if (type == '0') type = '2';
      if (type == '5') type = '6';
    }
    
    else {
      p = strstr(macName,"wt_");
      if (p != macName) {
	printf("*** Collar with id but not a wt_ or nt_ '%s'\n",macName);
	vdobj$Print(objOE = pieceOE);
	goto wrapup;
      }
    }
  }
  if (traceFlag) {
    printf("Type so far '%c'\n",type);
  }
  
  // Get the parents
  vdobj$GetTemplate(objOE = pieceOE, nth = 0, templateOE = &surfOE);
  if (surfOE.obj_id.objid == NULL_OBJID) {
    if (traceFlag) printf("Cannot get parent surface\n");
    goto wrapup;
  }
  if (traceFlag) {
    vdobj$Print(objOE = &surfOE);
    fflush(stdout);
  }
  
  macOE.mod_env = surfOE.mod_env;
  macOE.obj_id  = macID;

  vdobj$GetTemplate(objOE = &macOE, nth = 0, templateOE = &parent1OE);
  vdobj$GetTemplate(objOE = &macOE, nth = 1, templateOE = &parent2OE);

  if (traceFlag) {  
    vdobj$Print(objOE = &parent1OE);
    vdobj$Print(objOE = &parent2OE);
    fflush(stdout);
  }
  
  // Family of penetrated element is also
  vdsa$GetStruct(objOE = &parent1OE, name = "family_name", txt = family);
  if (*family == 0) {
    printf("No family for first parent\n");
    goto wrapup;
  }
  
  VDstrlwr(family);
  p = strstr(family,"i_t_");
  if (p != family) {
    p = strstr(family,"bulb_");
  }
  if (p == family) {
    if (type == '0') type = '3';
    if (type == '2') type = '4';
  }
  
  // Only makes sense to use grade from the clip or collar
  vdsa$GetStruct(objOE = pieceOE, name = "grade", txt = grade);
  if (*grade == 0) {
    printf("No grade for plate\n");
    goto wrapup;
  }

  // Use the thickness of the actual clip or collar itself
  vdsa$GetStruct(objOE = pieceOE, name = "plate_thk", dbl = &thickness);
  
  // Use the part number from the second parent
  vdsa$GetStruct(objOE = &parent2OE, name = "part_num", txt = partNum);
  if (*partNum == 0) {
    printf("No part_num for second parent\n");
    goto wrapup;
  }
  
  // Put it all together
  sprintf(key,"%c %-10s %6.2f %s",type,grade,thickness,partNum);
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< VDatGenerateStdPcmkKey %d\n",retFlag);
    fflush(stdout);
  }
  
  return retFlag;
}


/* -----------------------------------------------
 * Lookup key for piece mark from database
 */
IGRstat VDatLookupStdPcmkKey(IGRchar *pcmk, IGRchar *key)
{
  IGRstat retFlag = 0;
  FILE   *file = NULL;
  IGRchar buf[128],*p;
 
  // Arg check
  if (key  == NULL) goto wrapup; *key = 0;
  if (pcmk == NULL) goto wrapup;
  
  // Open
  file = fopen("/usr/tmp/pcmk_std.txt","rt");
  if (file == NULL) goto wrapup;

  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {
       
    //Check pcmk
    p = strchr(buf,' ');
    if (p) *p = NULL;
    if (!strcmp(buf,pcmk)) {
            
      // Got it
      strcpy(key,p+1);
      for(p = key + strlen(key) - 1; (p >= key) && (*p <= ' '); p--);
      *(p+1) = 0;
      retFlag = 1;

      goto wrapup;
      
    }
  }
  
  // Done (no match)
  
 wrapup:
  if (file) fclose(file);
  
  return retFlag;
}

/* -----------------------------------------------
 * Test just one node
 */
IGRstat VDatTestStdPcmkKeysForNodeOne(TGRid *nodeID)
{
  IGRstat retFlag = 1;
  
  TGRobj_env pieceOE;
  IGRchar key [64];
  IGRchar keyx[64];
  IGRchar pcmk[64];
  IGRchar unit[64];
  
  FILE *file;
  
  // Only care about those with pieces
  VDatGetLeafObject(nodeID,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Get the key
  VDatGenerateStdPcmkKey(&pieceOE,key);
  if (*key == NULL) goto wrapup;
  //printf("Key %s\n",key);
  //if (1) goto wrapup;
  
  // Get stored pcmk
  vdsa$GetStruct(objID = nodeID, name = "pcmk", txt = pcmk);
  if (*pcmk == 0) strcpy(pcmk,"XXXX");

  // Nice to know unit used
  VDatGetSetName(nodeID,unit);
  
  // Append to master list
  file = fopen("/usr/tmp/pcmk_list.txt","at");
  if (file) {
    fprintf(file,"%s %s %s\n",pcmk,unit,key);
    fflush (file);
    fclose (file);
  }
  
  // Print
  printf("STANDARD %s %s %s\n",unit,pcmk,key);

  // Is it already in database?
  VDatLookupStdPcmkKey(pcmk,keyx);

  if (*keyx) {
    if (strcmp(key,keyx)) {
      printf("*** %s %s\n",pcmk,  key);
      printf("    %s %s\n","    ",keyx);
    }
  }
  else {
    
    // Add it
    file = fopen("/usr/tmp/pcmk_std.txt","at");
    if (file) {
      fprintf(file,"%s %s\n",pcmk,key);
      fflush (file);
      fclose (file);
    }
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Recurse routine to test standard piece mark stuff
 */
IGRstat VDatTestStdPcmkKeysForNode(TGRid *nodeID)
{
  IGRstat retFlag = 1;

  IGRint i;
  TGRid  childID;
  
  // Test It
  VDatTestStdPcmkKeysForNodeOne(nodeID);
  
  // Recurse though kids
  for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {
    VDatTestStdPcmkKeysForNode(&childID);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Test standard piece mark key generation
 */
IGRstat VDatTestStdPcmkKeys(IGRchar *setName)
{
  IGRstat retFlag = 1;
  
  TGRid setID,treeID;
  
  // Say Hi
  printf("----- Standard PCMK Test %s -----\n",setName);
  
  // Get the set
  VDatGetSetByTypeName("StagingTree",setName,&setID);
  if (setID.objid == NULL_OBJID) {
    printf("*** Unable to get set for %s\n",setName);
    goto wrapup;
  }
  
  // Get the tree
  VDatGetTree(&setID,&treeID);
  if (treeID.objid == NULL_OBJID) {
    printf("*** Unable to get tree for %s\n",setName);
    goto wrapup;
  }

  // Recurse down
  VDatTestStdPcmkKeysForNode(&treeID);
  
  // Make a unique list
  system("/bin/cat /usr/tmp/pcmk_list.txt | /bin/sort -u > /usr/tmp/pcmk_unit.txt");
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


