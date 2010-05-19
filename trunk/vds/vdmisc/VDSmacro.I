/* $Id: VDSmacro.I,v 1.1 2001/01/18 23:08:50 hans Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/VDmiscMacro/VDct1Macro.I
 *
 * Description: Macro operations fixes 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdct1mcro.I 
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/09/00  pn      Creation
 ***************************************************************************/

class implementation VDSroot;

#include "VDfrm.h"
#include "VDct1.h"
#include "VDct1Cmd.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDsa.h"
#include "ACheader.h"
#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "msmacros.h"
#include "AS_status.h"
#include "ACcondit.h"
#include "acmacros.h"
#include "VDchn.h"
#include "nddef.h"
#include "ndmacros.h"
extern OM_S_CHANSELECT 	AS_to_owner;
extern GRclassid	OPP_ACheader_class_id;
extern 	ACfind_macro_defn(), NDwait_batch(), NDget_mod_batch(),
	NDexec_batch(), VD_is_ancestry_valid();
from ACmacro_defn import ACgive_upscan;
from ACmacro_defn import ACgive_temp_desc;
from ACmacro_defn import ACgive_feet_desc;
from ACcpx_defn   import ACgive_name;

// questions
IGRstat VDmrIsMacroUpscanSame(TGRid *oldID,TGRid *newID);
IGRstat VDmrIsMacroTempSame(TGRid *oldID,TGRid *newID);
IGRstat VDmrIsMacroFeetSame(TGRid macroID,TGRid *oldID,TGRid *newID);

#define ND_COMP 0x2

/****************************************************
 * macro object comparison checking function        *
 * checks if the objects match feet,temp etc and    *
 * tells if the object must be updated or not       *
 * the return 0 is no action return 1 is update     *
 * the return -1 is error                           *
 * Valid done 090800 pn                             *
 ****************************************************/ 
IGRstat VDmcUpdateMacroMatch(TGRid macroID, TGRid *oldID, TGRid *newID)
{
  IGRstat        retFlag = 0;
  IGRstat        traceFlag = 0;
  IGRint         sts = 0;

  // say hi
  if(traceFlag) {
    printf("Input macroID [%d] [%d]\n",macroID.osnum,macroID.objid);
    printf(">>> VDmcUpdateMacroMatch\n");
  }

  // args check
  if((!oldID) || (!newID)) goto wrapup;
  if(oldID->objid == NULL_OBJID) goto wrapup;
  if(newID->objid == NULL_OBJID) goto wrapup;
  if((oldID->osnum == newID->osnum) && (oldID->objid == newID->objid)) goto wrapup;
  
  // set the retFlag to an error
  retFlag = -1;
  //#if 0 
  // check if the upscans match 
  sts = VDmrIsMacroUpscanSame(oldID,newID);
  if(sts == -1) goto wrapup;
  // so far a match
  if(sts & 1) {
    // check if the temps match
    sts = VDmrIsMacroTempSame(oldID,newID);
    if(sts == -1) goto wrapup;

    // so far a match
    if(sts & 1) {
      // check if the feet match  
      // loops back if they do and checks each deeper layer of feet
      sts = VDmrIsMacroFeetSame(macroID,oldID,newID);
      if(sts == -1) goto wrapup;
    }
  }
  // tell to update the newID if there was a mis-match 
  if(sts == 0) {
    retFlag = 1;
    goto wrapup;
  }  
  // don't update anything
  retFlag = 0;
wrapup:
  // say bye
  if(traceFlag) {
    printf("<<< VDmcUpdateMacroMatch(%d)\n",retFlag);
  }
  return retFlag;
}  

/****************************************************
 * get the Library information on the local file    *
 * Valid done 090800 pn                             * 
 ****************************************************/

IGRstat VDmcUpdateModelMacro(TGRid *model_mgr)
{
  IGRstat        retFlag = 0;
  IGRstat        traceFlag = 0;
  IGRlong	 loc_msg;
  IGRchar	*mac_name;
  IGRint	 i, j, model_cnt, cn_type, b_mod,sts;
  unsigned int           nb_head;
  TGRid	         macro, def, new_def, header, model_list[1000];
  
  // say hi
  if(traceFlag) printf(">>> VDmcUpdateModelMacro\n");
  
  // args checks
  if(!model_mgr) goto wrapup;
  if(model_mgr->objid == NULL_OBJID) goto wrapup;
  
  cn_type  = ND_COMP;
  mac_name = NULL;
  
  //di.ls
  
  // Get all the models
  sts = vdchn$GetList( objID   = model_mgr,
		       chnName = VDCHN_NAME_TO_COMPONENTS,
		       maxCnt  = 1000,
		       cnt     = &model_cnt,
		       outIDs  = model_list );
  // no models no action
  if(!(sts & 1)) goto wrapup;
  if(model_cnt == 0) goto wrapup;
  for( i=0; i<model_cnt; i=i+1 )
  {
    /* Look number of connected header */
    nb_head = 0;
    om$get_channel_count( objid        = model_list[i].objid,
			  osnum        = model_list[i].osnum,
			   p_chanselect = &AS_to_owner,
			  count        = &nb_head );
    for( j=0; j<nb_head; j=j+1 )
    {
      // Get the header object
      om$get_objid_at_index( objid           = model_list[i].objid,
			     osnum           = model_list[i].osnum,
			     p_chanselect    = &AS_to_owner,
			     index           = j,
			     objidaddr       = &header.objid,
			     osnumaddr       = &header.osnum );
      // If the owner is a ACheader object
      if( VD_is_ancestry_valid( &header, OPP_ACheader_class_id ) )
      {     
	// Get the actual occurrence of this header
	om$get_objid_at_index( objid           = header.objid,
			       osnum           = header.osnum,
			       p_chanselect    = &AS_to_owner,
			       index           = 0,
			       objidaddr       = &macro.objid,
			       osnumaddr       = &macro.osnum );
	// Get the macro definition with which this occurrence is placed
	om$send( msg = message ACcpx.find_macro( &def ),
		 senderid = NULL_OBJID,
		 targetid = macro.objid,
		 targetos = macro.osnum ); 
	if( mac_name != NULL )
	{
	  free( mac_name );
	  mac_name = NULL;
	}
	 // Get the macro name
	om$send(msg = message ACcpx_defn.ACgive_name( &mac_name ),
		senderid = NULL_OBJID,
		targetid = def.objid,
		targetos = def.osnum );
	// Get the latest definition
	ac$find_macro_defn( action          = 1,
			     macro_name      = mac_name,
			    p_macro_defn_id = &new_def );
	// If there is any mismatch between old and new macro defintions
	sts = VDmcUpdateMacroMatch( macro, &def, &new_def );
	if(sts == 1) {
	  // Load the new definition to the macro
	  om$send( msg = message ACcpx.ACload_macro( new_def ),
		   senderid = NULL_OBJID,
		   targetid = macro.objid,
		   targetos = macro.osnum );	
	   // Put the object in the recompute graph
	  nd$wait_batch(    type       = GR_GEOM_POSTED,
			    l_object   = &macro,
			    l_obj_info = &cn_type,
			    nb_obj     = 1 );
	}  
      }
    }
  }
  // Get the assoc update mode
  nd$mod_batch(request     = ND_INQ,
	       p_ret_mode  = &b_mod );
  // If it is not in defer mode, recompute the graph.
  if( b_mod != ND_DEFER )  nd$exec_batch(); 
  
  retFlag = 1;
wrapup:
  if( mac_name != NULL )
  {
     free( mac_name );
     mac_name = NULL;
  }

  // say bye
  if(traceFlag) printf("<<< VDmcGetModelMacro(%d)\n",retFlag);
  return retFlag;
}


/****************************************************
 * get the Macro managers and call the update info  *
 * osnum is to allow access to files of choice      *
 * it probably should always be 2 --> active file   *
 * Valid done 090800 pn                             *
 ****************************************************/


IGRstat VDmcUpdateModelMacros(IGRint osnum)
{
  TGRid     mgrID;
  IGRstat   retFlag = 0;
  IGRstat   traceFlag = 0;
  IGRchar   buf[265],file[256],path[256],lib[256],**libNames,**macNames;
  IGRint    i,j,sts = 0;
  IGRint    libCnt,macCnt;
  TGRid     dirID;
  
  // say hi
  if(traceFlag) printf(">>> VDmcUpdateModelMacros\n");

  // this is toggled to get the correct path name
  sts = di$give_pathname( osnum           = osnum,
			  pathname        = file );
  sprintf(path,"%s:models_lib",file);
  if(traceFlag) printf("--> path [%s] is file[%s]\n",path,file);
  /* Check if directory exist */
  dirID.objid = NULL_OBJID ;
  sts = di$translate( objname = path,
		      p_objid = &dirID.objid,
		      p_osnum = &dirID.osnum);
  if(traceFlag) printf("dirID [%d] [%d]\n",dirID.osnum,dirID.objid);
  // change the directory to the path
  di$cd ( dirname = path);
  // search for a list 
  di$ls (lines = &libNames, 
	 ptr   = &libCnt );
  if(libCnt < 1) goto wrapup;
  // loop through the libraries
  for( i=0; i<libCnt; i++ ) {
    sprintf(lib,"%s%s",libNames[i],"constructs:");
    // change the directory to the lib
    di$cd ( dirname = lib);
      // search for a list of model manager objects
    di$ls (lines = &macNames, 
	   ptr   = &macCnt );
    if(macCnt<1) break;
    for( j=0; j<macCnt; j++ ) {
      sprintf(buf,"%s",macNames[j]);
      // get the list of modelManagerobjects
      sts = di$translate( objname = macNames[j],
			  p_objid = &mgrID.objid,
			  p_osnum = &mgrID.osnum);
      // go find out if we need to update it
      sts = VDmcUpdateModelMacro(&mgrID);
    }
  }
  retFlag = 1;
  
wrapup:
  for( i=0; i<libCnt; i++)  free( libNames[i] );
  free( libNames );
  for( i=0; i<macCnt; i++)  free( macNames[i] );
  free( macNames );
  // say bye
  if(traceFlag) printf("<<< VDmcUpdateModelMacros(%d)\n",retFlag);  
  return retFlag;
}

/****************************************************
 * Upscan Equality Validation                       *
 * Valid done 090800 pn                             *
 ****************************************************/
IGRstat VDmrIsMacroUpscanSame(TGRid *oldID,TGRid *newID)
{
  IGRstat        retFlag = 0;
  IGRstat        traceFlag = 0;
  IGRint         i,sts = 0;
  struct sup    *ups_defO = NULL,*ups_defN = NULL;
  IGRint         ups_numO,ups_numN;
  IGRint         ups_propO,ups_propN;

  // say hi
  if(traceFlag) printf(">>> VDmrIsMacroUpscanSame\n");

  // args check
  if((!oldID) || (!newID)) {
    if(traceFlag) printf("went wrapup an id was absent\n");
    retFlag = -1;
    goto wrapup;
  }
  if((oldID->objid == NULL_OBJID) || (newID->objid == NULL_OBJID)) {
    if(traceFlag) printf("went wrapup an id was null\n");    
    retFlag = -1;
    goto wrapup;
  }
  if((oldID->osnum == newID->osnum) && (oldID->objid == newID->objid)) {
    if(traceFlag) printf("went wrapup the ids were identical\n");    
    retFlag = 1;
    goto wrapup;
  }
  // get the upscan for oldID
  sts = om$send( msg = message ACmacro_defn.ACgive_upscan
		 (&ups_numO,&ups_propO,&ups_defO),
		 senderid = NULL_OBJID,
		 targetid = oldID->objid, 
		 targetos = oldID->osnum );
  // go home if wrong
  if(!(sts & 1)) {
    retFlag = -1;
    goto wrapup;
  }
  // get the upscan for newID
  sts = om$send( msg = message ACmacro_defn.ACgive_upscan
		 (&ups_numN,&ups_propN,&ups_defN),
		 senderid = NULL_OBJID,
		 targetid = newID->objid, 
		 targetos = newID->osnum );
  // go home if wrong
  if(!(sts & 1)) {
    retFlag = -1;
    goto wrapup;
  }
  // if the count does not match
  if(ups_numO != ups_numN) goto wrapup;
  // loop through and check the equalities
  for ( i=0;i<ups_numO;i++ ) {
    if(strcmp(ups_defO[i].prompt,ups_defN[i].prompt))   goto wrapup;
    if(strcmp(ups_defO[i].up_scan,ups_defN[i].up_scan)) goto wrapup;
  }
  retFlag = 1; 
wrapup:
  // say bye
  if(traceFlag) printf("<<< VDmrIsMacroUpscanSame(%d)\n",retFlag);
  return retFlag;
}

/****************************************************
 * Temp Equality Validation                         *
 * Valid done 090800 pn                             *
 ****************************************************/
IGRstat VDmrIsMacroTempSame(TGRid *oldID,TGRid *newID)
{
  IGRstat        retFlag = 0; 
  IGRstat        traceFlag = 0;
  IGRint         i,sts = 0;
  struct stemp  *temp_defO = NULL,*temp_defN = NULL;
  IGRint         temp_numO,temp_numN;
  
  // say hi
  if(traceFlag) printf(">>> VDmrIsMacroTempSame\n");

  // args check
  if((!oldID) || (!newID)) {
    retFlag = -1;
    goto wrapup;
  }
  if((oldID->objid == NULL_OBJID) || (newID->objid == NULL_OBJID)) {
    retFlag = -1;
    goto wrapup;
  }
  if((oldID->osnum == newID->osnum) && (oldID->objid == newID->objid)) {
    retFlag = 1;
    goto wrapup;
  }
  

  // get the temp oldID
  sts = om$send( msg = message ACmacro_defn.ACgive_temp_desc
		 (&temp_numO,&temp_defO),
		 senderid = NULL_OBJID,
		 targetid = oldID->objid, 
		 targetos = oldID->osnum );

  // set the error code
  if(!(sts & 1)) {
    retFlag = -1;
    goto wrapup;
  }
  
  // get the temp newID
  sts = om$send( msg = message ACmacro_defn.ACgive_temp_desc
		 (&temp_numN,&temp_defN),
		 senderid = NULL_OBJID,
		 targetid = newID->objid, 
		 targetos = newID->osnum );

  // set the error code
  if(!(sts & 1)) {
    retFlag = -1;
    goto wrapup;
  }  

  // test if the count is not the same
  if(temp_numO != temp_numN) goto wrapup;
  

  // loop through the structure and check the equalities
  for(i=0;i<temp_numO;i++) {
    if(strcmp(temp_defO[i].name,temp_defN[i].name))           goto wrapup;
    if(strcmp(temp_defO[i].down_scan,temp_defN[i].down_scan)) goto wrapup;
    if(temp_defO[i].back != temp_defN[i].back)                goto wrapup;
  }
  
  retFlag = 1; 
wrapup:

  // say bye
  if(traceFlag) {
    if(retFlag == 0) printf("###### FAILED temp did not match! #####\n");
    if(retFlag == 1) printf("$$$$$$ Success Matched! temp$$$$$$$\n");
    printf("<<< VDmrIsMacroTempSame(%d)\n",retFlag);
  }
  return retFlag;
}

/****************************************************
 * Feet Equality Validation                         *
 * Valid done 090800 pn                             *
 ****************************************************/
IGRstat VDmrIsMacroFeetSame(TGRid macroID,TGRid *oldID,TGRid *newID)
{
  IGRstat        retFlag = 0;
  IGRstat        msg, traceFlag = 0;
  IGRint         i,stat,suc,sts = 0;
  struct myfeet *feet_defO = NULL,*feet_defN = NULL;
  IGRint         feet_numO,feet_numN;
  IGRchar        foot[128],*macroName[128];
  TGRid          testIDO,testIDN,feetID;
  IGRdouble	 matrix[16];  
  IGRshort       matrix_type;

  // say hi
  if(traceFlag) printf(">>> VDmrIsMacroFeetSame\n");

  // args check
  if((!oldID) || (!newID)) {
    retFlag = -1;
    goto wrapup;
  }
  if((oldID->objid == NULL_OBJID) || (newID->objid == NULL_OBJID)) {
    retFlag = -1; 
    goto wrapup;
  }
  if((oldID->osnum == newID->osnum) && (oldID->objid == newID->objid)) {
    retFlag = 1; 
    goto wrapup;
  }
  // get the oldID feet
  sts = om$send( msg = message ACmacro_defn.ACgive_feet_desc
		 (&feet_numO,&feet_defO),
		 senderid = NULL_OBJID,
		 targetid = oldID->objid, 
		 targetos = oldID->osnum );
  if(!(sts & 1)) {
    retFlag = -1;
    goto wrapup;
  }
  // get the newID feet
  sts = om$send( msg = message ACmacro_defn.ACgive_feet_desc
		 (&feet_numN,&feet_defN),
		 senderid = NULL_OBJID,
		 targetid = newID->objid, 
		 targetos = newID->osnum );
  if(!(sts & 1)) {
    retFlag = -1;
    goto wrapup;
  }
  // if the feet number is not the same
  if(feet_numO != feet_numN) {
    goto wrapup;
  }
  // loop through and check the equalities do nothing more if they are found
  for(i=0;i<feet_numO;i++) {
    // compare the feet
    if(strcmp(feet_defO[i].name,feet_defN[i].name))  goto wrapup;
    if(feet_defO[i].chan     != feet_defN[i].chan)   goto wrapup;
    if(feet_defO[i].pos      != feet_defN[i].pos)    goto wrapup;
    if(feet_defO[i].prop     != feet_defN[i].prop)   goto wrapup;
  }
  // no inequalities were found Go check the lower feet macros
  for(i=0;i<feet_numO;i++) { 
    strcpy(foot,feet_defN[i].name); 
    // get its macroID get feetID
    sts = om$send(msg = message NDmacro.ACreturn_foot
		  (
		   &msg,
		   foot,&feetID,&matrix_type,matrix),
		  senderid = NULL_OBJID,
		  targetid = macroID.objid,
		  targetos = macroID.osnum );      
    // Get the macro definition with which this occurrence is placed
    om$send( msg = message ACcpx.find_macro( &testIDO ),
	     senderid = NULL_OBJID,
	     targetid = feetID.objid,
	     targetos = feetID.osnum );
    // Get the macro name
    om$send(msg = message ACcpx_defn.ACgive_name( macroName ),
	    senderid = NULL_OBJID,
	    targetid = testIDO.objid,
	    targetos = testIDO.osnum );     
    // Get the latest definition
    ac$find_macro_defn( action          = 1,
			macro_name      = *macroName,
			p_macro_defn_id = &testIDN );
    // recurse on and get the comparison done again
    if(feetID.objid != NULL_OBJID) {
      sts = VDmcUpdateMacroMatch(feetID,&testIDO,&testIDN);	
      if(sts == 1) {
	retFlag = 0;
	goto wrapup;
      }
      else {
	retFlag = 1;
		goto wrapup;
      }
    }    
  } 
 
  retFlag = 1; 
wrapup:  
  // say bye
  if(traceFlag) printf("\n\n<<< VDmrIsMacroFeetSame(%d)\n\n",retFlag);
  return retFlag;
}


/****************************************************
 * Main operational routine controls all the tests  *
 * Valid done 090800 pn                             * 
 ****************************************************/

IGRstat VDmrMacroMain()
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  IGRint  sts,osnumRef,osnumTest,cnt;
  IGRchar pathTest[1024],pathFile[1024];
  TGRid   macroID, fileID;
  IGRlong        msg;
  IGRint          osnum;
  
  // say hi
  if(traceFlag) printf(">>> VDmrMacroMain\n");

  if(traceFlag) printf("\n\n\n\n^^^^^^^^^^^^^^ Begin macro fix ^^^^^^^^^^^^^^^^\n\n");

   // send off to update the macros
   osnum = 2;
   sts = VDmcUpdateModelMacros(osnum);
   if(!(sts & 1)) {
     printf("VDmcGetModelMacros failed\n\n");
   }
   else {
     if(traceFlag) printf("VDmcGetModelMacros succeded\n\n");

   }
   if(traceFlag) printf("^^^^^^^^^^^^^^ end macro fix [%d] ^^^^^^^^^^^^^^^^\n\n",sts);
  retFlag = 1;
wrapup:
  // say bye
  if(traceFlag) printf("<<< VDmrMacroMain(%d)\n",retFlag);
  return retFlag;
}

end implementation VDSroot;






