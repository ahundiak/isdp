class implementation VDPCmdPMDef;

#include "VDtypedef.h"
#include "VDdir.h"
#include "VDobj.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "VDCmdDef.h"
#include "VDmem.h"
#include "PDUstr.h"
#include "VDPtrTbl.h"
#include "vdparmacros.h"
#include "vdbmacros.h"

#include "VDrisc.h"
#include "VDship.h"
#include "VDPaimUtil.h"

#define VDP_GET_REV  	121
#define VDP_UPDATE_HA  	128

from ACrg_collect import ACset_list_attribute;
from ACrg_collect import ACmod_list_attribute;
from ACrg_collect import ACadd_list_attribute;

from VDPtrTbl import VDPinit;
from VDPtrTbl import VDPAddtoTrTable;
from VDPtrTbl import VDPprintTransTable;

from VDPenabObj import VDPgetPMenabledList;

extern struct PDUrefresh *refresh;

#define FILE_PRINT if (dm2_err) fprintf

/* --------------------------------------------
 * Posting enhancements, change type 0 M to DM
 * Only make the change if not doing diagrams
 */
void VDPaimChangeMtoDM()
{
  TGRid  dadID,listID;
  IGRint asirFileType;

  /* Grab the file type collector */
  VDPaimGetDADCollector(NULL_OSNUM,0,&dadID);
  if (dadID.objid == NULL_OBJID) goto wrapup;

  /* And the file type */
  VDcollGetIntAttr(&dadID,SIR_FILE_TYP,&asirFileType);
  if (asirFileType != VDP_ASIR_FILE_TYPE_MODEL) goto wrapup;

  /* Set to DM */
  if (!VDshipDoDiagrams()) {
    VDcollSetIntAttr(&dadID,SIR_FILE_TYP, VDP_ASIR_FILE_TYPE_DM);
  }

  /* Blow away any enabled items */
  VDPaimGetEnabledItemListObject(NULL_OSNUM,0,&listID);
  if (listID.objid != NULL_OBJID)
  {
    om$send(msg = message Root.delete(1),
            senderid = NULL_OBJID,
            targetid = listID.objid,
            targetos = listID.osnum);
  }
  /* Blow away transaction list */
  VDPaimGetTransactionListObject(NULL_OSNUM,0,&listID);
  if (listID.objid != NULL_OBJID)
  {
    om$send(msg = message Root.delete(1),
            senderid = NULL_OBJID,
            targetid = listID.objid,
            targetos = listID.osnum);
  }
  /* Blow away saved transaction list */
  VDPaimGetSavedTransactionListObject(NULL_OSNUM,0,&listID);
  if (listID.objid != NULL_OBJID)
  {
    om$send(msg = message Root.delete(1),
            senderid = NULL_OBJID,
            targetid = listID.objid,
            targetos = listID.osnum);
  }

wrapup:
  return;
}

/* ----------------------------------------------
 * These 4 functions should probably be moved
 * to their own reconnect file
 * All should be static except VDPReconnectDAD
 */
IGRint VDPUpdSeqNoforUid(IGRint SrMaxUid );

IGRint VDPSaveReconDefaults(FILE *dm2_err, char *FileName, char *outbuf, long *msg );
IGRint VDPRestorePlacmts   (FILE *dm2_err, char *FileName, long *msg, char *MdcObid, char *ftype);

IGRint VDPReconnectDAD();

/* ----------------------------------------------
 * This is being called from 
 * VDPquerydm2.I  SrDetectFileRev if an aim mdc exists but no collector
 * SrDetectFileRev is in turn called from form_notification in VDCmdChkIni.I
 *
 * Seems a bit shakey to actually try to reconnect everything at the time of posting
 * need to verify when (if ever) the code is actually kicked off.
 */
/*************************************************************************
 Added by Anjani
 The function is written to reconnect the MDC information from AIM,
 in case the DAD is corrupted in ISDP. This function sends part 
 info as inbuf and gets the Mdc info as outbuf.
 	Inbuf : catalog, part, revision
	outbuf: mdcobid, ctxtype, ctxname, ctxrev, ctxdesc, ctxobid, ftype 
	
************************************************************************/

IGRint VDPReconnectDAD()
{
    int code = 0, index = 0, index1 = 0, inlen = 0, outlen = 0, i = 0;
    int dstat = 0, mfail = 0, status = 0;
    long msg;

    char inbuf[100];
    char FileName[250], TmpFileName[260];
    char *outbuf;
    char *token;
    char *errmsg = NULL;
    FILE *dm2_err = NULL;
    time_t  ltime;
    char aim_user[50], aim_server[15], aim_env[15];

    SetProc(VDPCmdPMDefi.DADReconnect); Begin

    FileName[0]='\0';
    TmpFileName[0]='\0';
    aim_user[0]='\0';
    aim_server[0]='\0';
    aim_env[0]='\0';
    
	for ( i=0; i<100; i++ )
             inbuf[i]='\0';
    
	VDPGetAimInfo(aim_user, aim_server, aim_env);
	
    	get_local_fname(refresh->act_catalog,
             refresh->act_partid,
             refresh->act_revision,
             FileName );
	token = strtok(FileName, ".");
	sprintf( TmpFileName, "%s", token );
        strcat( TmpFileName, "_recon.log" );	
	time( &ltime );
	dm2_err = (FILE *)fopen(TmpFileName,"a");
       if( dm2_err == NULL )
	 printf( "Cannot open file %s\n", TmpFileName);
       FILE_PRINT(dm2_err, "\n\t-------------------------------------------------------------------\n");
       FILE_PRINT( dm2_err, "\n\tReconnect Process Started %s\n", ctime(& ltime));
       FILE_PRINT(dm2_err, "\n\tUser Name is %s\n", aim_user);
       FILE_PRINT(dm2_err, "\n\tSever Name is %s\n", aim_server);
	FILE_PRINT(dm2_err, "\n\tEnvironment Name is %s\n", aim_env);	 

    	code = VDP_MDC_RECONNECT;
	__DBGpr_int(" code ", code);
	 memcpy( &inbuf[index], &code, sizeof(int) );
	inlen += sizeof(int);
	  index = inlen;
	strcpy( &inbuf[index],refresh->act_catalog);
	inlen = inlen + strlen(refresh->act_catalog ) +1;
	  index = inlen;
	strcpy( &inbuf[index],refresh->act_partid); 
	inlen = inlen + strlen(refresh->act_partid)+1;
	  index = inlen;
	strcpy(&inbuf[index], refresh->act_revision);
	inlen = inlen + strlen(refresh->act_revision) + 1;
	index = inlen;

	dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
					    inbuf,
					    &outlen,
				            &outbuf,
				             &mfail,
				             &errmsg );
	if(dstat || mfail)
	{
		if(dstat == 12345 )
    		{
			printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        		//strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        		//ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
    		}
	 	FILE_PRINT(dm2_err, "\n\tIn Reconnect Process\n");
      	 	FILE_PRINT( dm2_err, "\n\t%s\n", errmsg);
       		FILE_PRINT( dm2_err, "\n\tdstat is %d\n",dstat);
		FILE_PRINT( dm2_err, "\n\tmfail is %d\n",mfail);
	}	
	if(outlen != 0)
	        status = VDPSaveReconDefaults(dm2_err, TmpFileName, outbuf, &msg );		
	else
		printf("<S-Home>Failed to query AIM Infor\n");
	fclose(dm2_err);	
wrapup :
 //if(dm2-err)
  //fclose(dm2_err);
   
End
     return OM_S_SUCCESS;
}

/* ----------------------------------------------
 * This is ONLY called from VDPSaveReconDefaults(
 */
/**************************************************************************
 * Added by Anjani, 
 * This function is written to restore all the placements from AIM after 
 * DAD is reconnected. This function sends the Mdcobid and hullapp as inbuf
 * and gets all the placements related to Mdc as outbuf. 
 * After restoring and posting the parts
 * 1. The primary relations with Mdc will be modified
 * 2. The existing 3D relations are deleted and new relations will be created
 * 3. The hull applicability for Mdc is updated in AIM
 * **********************************************************************/

IGRint VDPRestorePlacmts(FILE *dm2_err, char *FileName, long *msg, char *MdcObid, char *ftype)
{
	int index = 0, outlen = 0, inlen = 0, status = 0, code = 0, dstat = 0;
	int index1 = 0, nbplacmts = 0, MaxUid=0, mfail = 0, i = 0, seqnum = 0;
	char *outbuf;
	char inbuf[1000];
	char *errmsg = NULL;
	char *lpdvalue[12];

  	char LpdDesc[50]; /* Really the hull app string */

	char FSIClass[15];
	struct GRid *list, EnabListId, trTblId;
  	Tret_struct rs;
	OMuword     curOs;
	IGRlong     stat = OM_S_SUCCESS;

	int objcount = 0, size = 0, objctr = 0, nbObjs = 0, nobjs_unposted = 0;
	int ret_size, siruidsize = 0, notUsed, ret_msg;
	int  FSI = -1;
	extern GRclassid    OPP_VDSroot_class_id;
	char class_name[80], exp[20];
        IGRchar *sirobid=NULL, siruid[30];
	struct SIRPlacmtsInfo *SrPlacmts = NULL;
	struct SIRuidinfo *SIR_uid = NULL;
	struct VDPtrObjList   *GlTrTbl = NULL;
	struct      ACrg_coll       Coll;
	struct      GRmd_env        MdEnv;
	struct GRobj_env    *listObjs = NULL;
	struct VDPtrObjList  TrRow;
	IGRboolean        flag=TRUE;
	 time_t  	ltime;

  /* ----------------------------------------------
   * 23 May 2003 2 New attributes added to placement data
   */
  IGRchar comp_tagx[128];
  IGRchar comp_path[128];

	SetProc( VDPCmdPMDefi.RestorePlacmts); Begin

	for(i = 0; i<1000; i++) inbuf[i]='\0';

        VDPaimGetHullApp(refresh->act_catalog, 
                         refresh->act_partid,
                         refresh->act_revision, 
                         LpdDesc);

	code = VDP_PLACMT_RECONNECT;
	memcpy(&inbuf[index], &code, sizeof(int));
	inlen = inlen + sizeof(int);	 
	index = inlen;
	strcpy(&inbuf[index], MdcObid);
	inlen = inlen + strlen(MdcObid) + 1;
	index = inlen;
	strcpy(&inbuf[index], LpdDesc);
	inlen = inlen + strlen(LpdDesc) + 1;
	index = inlen;

	dstat = POSTMAN_REQUEST_ON_CLIX(inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg);

	if(dstat || mfail)
   	{
	  if(dstat == 12345 )
    	  {
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	//strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        	//ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
    	  }	
    	 FILE_PRINT( dm2_err, "\n\tIn Restore Placements Process\n");
	 FILE_PRINT(dm2_err, "\n\t%s\n", errmsg);
    	 FILE_PRINT( dm2_err, "\n\tdstat is %d\n", dstat);
    	 FILE_PRINT( dm2_err, "\n\tmfail is %d\n", mfail);
   	} 	
	
	memcpy(&nbplacmts, &outbuf[index1], sizeof(int));
	index1 = index1 + sizeof(int);

   	if(nbplacmts != 0)
	{
	   SrPlacmts = _MALLOC(nbplacmts, struct SIRPlacmtsInfo);

		if(SrPlacmts == NULL)
		{
			UI_status("No Dynamic Memory.");
			return OM_E_NODYNMEM;
		}
	}
	
    for(i = 0; i<nbplacmts; i++)
	{
             strcpy(SrPlacmts[i].uid, &outbuf[index1]);
		     index1 = index1 + strlen(&outbuf[index1]) + 1; 
		     SrPlacmts[i].obid =  atoi(&outbuf[index1]);
		     index1 = index1 + strlen(&outbuf[index1]) + 1;

  strcpy(comp_tagx, &outbuf[index1]);
  index1 = index1 + strlen(&outbuf[index1]) + 1;
  strcpy(comp_path, &outbuf[index1]);
  index1 = index1 + strlen(&outbuf[index1]) + 1;


			 strcpy(SrPlacmts[i].class, &outbuf[index1]);
			 index1 = index1 + strlen(&outbuf[index1]) + 1;
			 strcpy(SrPlacmts[i].reltype, &outbuf[index1]);
			 index1 = index1 + strlen(&outbuf[index1]) + 1;
	}
    //printf("FileName in Restoreis %s\n", FileName);
    if(nbplacmts == 0)
      FILE_PRINT(dm2_err, "\n\tNo Placements found to Restore\n");
    else
    {
     //	printf("I am in else\n");
    	FILE_PRINT( dm2_err, "\n\t%d Placements Restored Successfully\n", nbplacmts);
    }

	memcpy(&MaxUid, &outbuf[index1], sizeof(int)); 

	if(nbplacmts == 0)
		MaxUid = 0;	
	status = VDPUpdSeqNoforUid(MaxUid);


         //get the Transaction list id
         VDPGetTrTblId ( msg, &trTblId );      
		//get the initial size of transaction list  	 
         size = VDgetTrSize();
        if(size > 0)
		{
            _VD_SEND_OBJN ( trTblId, Root.delete (1));
        }
        VDPGetTrTblId ( msg, &trTblId );
        //To initialize transaction table
       _VD_SEND_OBJN(trTblId, VDPtrTbl.VDPinit(msg));

	//Remove the initial enabledlist
	ex$get_cur_mod(osnum = &curOs);

                status = VDPGetEnabledListId ( msg, curOs, &EnabListId );

                if(EnabListId.objid == NULL_OBJID )
                {
                   printf("\n failed to get EnabListId.\n");
                   goto wrapup;
                }
                /* Get all the PME Enabled OBJID's */

           status =
            om$send ( msg = message VDPenabObj.VDPgetPMenabledList (
                                                msg,
                                                &nbObjs,
                                                &listObjs ),
                     senderid = NULL_OBJID,
                     targetid = EnabListId.objid,
                     targetos = EnabListId.osnum );
	if (nbObjs == 0 )
                {
                __DBGpr_com("No objects found in Enabled List\n");
               // goto wrapup;
                }

	 for( objctr  = 0; objctr < nbObjs; objctr = objctr+1)        
			status = VDPDisableObject(msg, listObjs[objctr].obj_id);
             
	list = _MALLOC(1, struct GRid);

	for(i = 0; i<nbplacmts; i++)
	{
            class_name[0]='\0';
		    TrRow.VDSobjid = SrPlacmts[i].obid;
		    TrRow.oldVDSobjid = SrPlacmts[i].obid;
		    TrRow.PMEobid[0] = '\0';

		    //Get Object Class Name
   		    status = om$get_classname( objid = SrPlacmts[i].obid,
               			                osnum = 2,
                               			classname = class_name );

			FSIClass[0] = '\0';
			
		if(!strcmp(class_name, "VDequipment") || !strcmp(class_name, "VREquipment"))
			strcpy(FSIClass, "SrEquip");
		else if(!strcmp(class_name, "VRPComp"))
			strcpy(FSIClass, "SrPiping");
		else if(!strcmp(class_name, "VRRComp"))
			strcpy(FSIClass, "SrRway");
		else if(!strcmp(class_name, "VRHComp"))
			strcpy(FSIClass, "SrHvac");

		if(!strcmp(FSIClass, SrPlacmts[i].class) && !strcmp("P", SrPlacmts[i].reltype))

		{		
			if(!strcmp(ftype, "A"))
			  continue;
		     
                    size = sizeof( struct GRmd_env );
			
		    gr$get_module_env( msg = msg,
                                       sizbuf = &size,
                                       buffer = &MdEnv,
                                       nret = &ret_size );
	       

			list[0].objid = SrPlacmts[i].obid;
			list[0].osnum = 2;

			
                   //Get the Uid attribute of the object
                    strcpy( Coll.name, "sirid" );
                    Coll.desc.type = AC_ATTRIB_TEXT;
                    strcpy ( Coll.desc.value.att_txt, "" );
		    status = vd$review_params ( pMsg = msg,
                                               pComponent = &list[0],
                                               pMdEnv = &MdEnv,
                                               pList = &Coll,
                                               NbParams = 1 );

                    CheckRC (status, *msg);
        __DBGpr_str("The UID value is %s", Coll.desc.value.att_txt);

		    if(strlen( Coll.desc.value.att_txt)==0)
	        {
            	 	__DBGpr_com("UID is NULL");

            	   	// Set UID value for the Placment object 
		         strcpy( Coll.desc.value.att_txt, SrPlacmts[i].uid );
            		strcpy( Coll.name, "sirid" );
            		Coll.desc.type = AC_ATTRIB_TEXT;
				
            		status = VDmodUsrAttrs(msg,list[0],&MdEnv,1,&Coll);
			
          	}//UID is set
          	__DBGpr_str("Object UID =", Coll.desc.value.att_txt);


	      status = VDPEnableObject( msg, list[0] );
                CheckRC ( status, *msg );

                /* Get all the PME Enabled OBJID's */

           status =
            om$send ( msg = message VDPenabObj.VDPgetPMenabledList (
                                                msg,
                                                &nbObjs,
                                                &listObjs ),
                     senderid = NULL_OBJID,
                     targetid = EnabListId.objid,
                     targetos = EnabListId.osnum );
		if (nbObjs == 0 )
                {
                __DBGpr_com("No objects found in Enabled List\n");
               // goto wrapup;
                }

		//To initialize TrRow
		
		TrRow.ActionCode = VDP_MODIFY;

	   //Add to Transaction table

	  status = _VD_SEND_OBJN(trTblId, VDPtrTbl.VDPAddtoTrTable(msg, TrRow));
                   // CheckRC( status, *msg );
	  status = _VD_SEND_OBJN(trTblId, VDPtrTbl.VDPprintTransTable (msg));
          GlTrTbl = (struct VDPtrObjList *)VDgetTrTable();
                size = VDgetTrSize();

	setPostingStatus(&GlTrTbl[size-1].ActionCode, VDP_MODIFY);
	FILE_PRINT(dm2_err, "\nF S I  : [%d/%d]", list[0].osnum, list[0].objid);
	FILE_PRINT(dm2_err, "\t%s", SrPlacmts[i].uid);
	FILE_PRINT(dm2_err, "\t %s", class_name);
	FILE_PRINT(dm2_err, "\t Reconnect[MODIFY]\n");
	//FILE_PRINT(dm2_err, "\n\tThe Placement with UID value %s is Posted with MODIFY status\n", SrPlacmts[i].uid);

		}//end of class_name check
		else
		{
			//to init TrRow

                        TrRow.ActionCode = VDP_DELETE;

			//Delete from Transaction table

                      status = _VD_SEND_OBJN(trTblId, VDPtrTbl.VDPAddtoTrTable(msg, TrRow));
                   // CheckRC( status, *msg );
                     status = _VD_SEND_OBJN(trTblId, VDPtrTbl.VDPprintTransTable (msg));
                      GlTrTbl = (struct VDPtrObjList *)VDgetTrTable();
                      size = VDgetTrSize();
		     FILE_PRINT(dm2_err, "\nF S I  : [%d/%d]", list[0].osnum, list[0].objid);
	FILE_PRINT(dm2_err, "\t%s", SrPlacmts[i].uid);
	FILE_PRINT(dm2_err, "\t %s", class_name);	
	FILE_PRINT(dm2_err, "\t Reconnect[DELETE]\n");
		}
		
    }//Placment For loop
	if(nbplacmts == 0)
	 FILE_PRINT( dm2_err, "\n\tNo Placements found to post\n");
	else
	{
	 //printf("I am in else2\n");
	 FILE_PRINT( dm2_err, "\n\t%d Placements Posted Successfully\n", nbplacmts );
	}
	//printf("End of Restore Placements\n");

	//fclose(dm2_err);
	UI_status("Placements are restored successfully");

wrapup :
//if(dm2_err)
 //fclose(dm2_err);
if(SrPlacmts)
_FREE(SrPlacmts);

  if(GlTrTbl != NULL)
    _FREE( GlTrTbl );

End
 return OM_S_SUCCESS;

}

/* ----------------------------------------------
 * This function is ONLY called from VDPReconnectDAD
 * Does some cm stuff in addition to dad
 *
 Would like to save refactoring until know the routine is used.
 */
/************************************************************************
  Added by Anjani
  The method to store the context information in collector in DAD
  reconnect process
 ***********************************************************************/
IGRint VDPSaveReconDefaults(FILE *dm2_err, char *FileName, char *outbuf, long *msg )
{
   IGRlong		status = VD_SUCCESS;
   struct GRid		DirId, CollId;
   IGRchar		DirName[DI_PATH_MAX],
			CollName[DI_PATH_MAX];
   OMuword		curOs;
   struct ACrg_coll	*coll;
   int		index = 0, dstat = 0, code = 0;
   char		SrCtxRev[5], mdcobid[30], ftype[5], MdcRev[15]; 
   IGRboolean	IsDADExists=FALSE;
    time_t  	ltime;

   SetProc( VDPCmdPMDef.VDPSaveReconDefaults ); Begin

   SrCtxRev[0]='\0';
   mdcobid[0]='\0';
   ftype[0]='\0';

   ex$get_cur_mod( osnum = &curOs );

   /* get directory path name */

   status = di$give_pathname(  osnum           = curOs,
                               pathname        = DirName );

   __CheckRC( status, 1, "di$give_pathname", wrapup );
   __DBGpr_str( "Path name", DirName );

   strcat( DirName, SIR_GLOBAL_DIR );

   status =
   di$translate ( objname = DirName,
                  p_objid = &DirId.objid,
                  p_osnum = &DirId.osnum ) ;

   __DBGpr_obj( "Dir Id", DirId );

   /*A create PME_GLOBAL if it does not exist     */
   if ( status != DIR_S_SUCCESS )
   {
	DirId.objid = NULL_OBJID;

	status =
	di$mkdir( dirname = DirName,
		  p_dirid = &DirId.objid,
		  p_osnum = &DirId.osnum );

	__DBGpr_obj( "Dir Id", DirId );

	if( status != DIR_S_SUCCESS ) 
	{
		/*A Cannot create directory*/
		di$report_error( sts = status ) ;
		goto    wrapup;
	}
   }

   sprintf( CollName, "%s%s", DirName, SIR_REQ_DATA );
   __DBGpr_str( "Collector name", CollName );

   status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &CollId ); 
   /*if( !(status & *msg & 1))
	UI_status("Error in creating Collector ");*/
   if(CollId.objid == NULL_OBJID)
   {
	//printf("Collector is not found. Creating...\n");
   status = VDgetVdCollId ( msg, CollName, TRUE, TRUE, &CollId ); 
   IsDADExists=TRUE;
   }


   __CheckRC( status, *msg, "VDgetVdCollId", wrapup );

   __DBGpr_obj( "Collector Id", CollId );

   /* Intialize the Collector */
   coll = _MALLOC ( 7, struct ACrg_coll );

   /* set up the coll values */
   strcpy( coll[0].name, SIR_CNTX_ID );
   coll[0].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[0].desc.value.att_txt, &outbuf[index] );
   index = index + strlen(coll[0].desc.value.att_txt) + 1;

   strcpy( coll[1].name, SIR_CNTX_NAME );
   coll[1].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[1].desc.value.att_txt, &outbuf[index] );
   index = index + strlen(coll[1].desc.value.att_txt) + 1;
   
   strcpy( coll[2].name, SIR_CNTX_DESC );
   coll[2].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[2].desc.value.att_txt, &outbuf[index] );
   index = index + strlen(coll[2].desc.value.att_txt) + 1;
   
   strcpy( coll[3].name, SIR_CNTX_TYP );
   coll[3].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[3].desc.value.att_txt, &outbuf[index] );
   index = index + strlen(coll[3].desc.value.att_txt) + 1;
   
   /*strcpy( coll[4].name, CTX_REVISION );*/
   /*coll[4].desc.type = AC_ATTRIB_TEXT;*/
   strcpy( SrCtxRev, &outbuf[index] );
   index = index + strlen(SrCtxRev) + 1;

   strcpy( coll[4].name, SIR_MODCX_ID );
   coll[4].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[4].desc.value.att_txt, &outbuf[index] );
   strcpy( mdcobid, &outbuf[index]);
   index = index + strlen(coll[4].desc.value.att_txt) + 1;

   strcpy( coll[5].name, SIR_FILE_TYP );
   coll[5].desc.type = AC_ATTRIB_DOUBLE;
   //coll[4].desc.value.att_exp = atoi(&outbuf[index]);
   strcpy( ftype, &outbuf[index]);
   index = index + strlen(ftype) + 1;

   if(!strcmp(ftype, "M"))
      coll[5].desc.value.att_exp = 0;
   if(!strcmp(ftype, "D"))
      coll[5].desc.value.att_exp = 1;
   if(!strcmp(ftype, "A"))
      coll[5].desc.value.att_exp = 2; 

   
   strcpy( coll[6].name, SIR_SEQ_NO );
   coll[6].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[6].desc.value.att_txt, "1");

   /* store in collector */
   if(IsDADExists==TRUE)
   {
    status =
   _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute( 
					msg, 
					7,
					coll ) );
    }
    else
    {
   status =
   _VD_SEND_OBJN( CollId, ACrg_collect.ACmod_list_attribute( 
					msg, 
					7,
					coll ) );
    }

    //dm2_err = (FILE *)fopen(FileName, "a");
    //printf("File Name in SaveRecon is %s\n", FileName);
    FILE_PRINT( dm2_err, "\n\tPart is Successfully Reconnected to Mdcobid %s\n", mdcobid);

    //Added by Anjani on 26Aug2000
    //Updating the Context revision in Sirpdmtable after reconnecting the DAD 
    MdcRev[0]='\0';
    // TLS - 03/26/01 - Changed to to reflect correct function in aim
    code = VDP_GET_REV;
    status = VDPGetRevFromOBID(code, mdcobid, &MdcRev);
    __DBGpr_str( "MdcRev in Reconnect is", MdcRev );
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
      	  	        refresh->act_revision, "mdc_rev",MdcRev);
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
      	  	        refresh->act_revision, "ctx_type",coll[3].desc.value.att_txt);
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
      	  	        refresh->act_revision, "ctx_name",coll[1].desc.value.att_txt);
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
      	  	        refresh->act_revision, "ctx_rev",SrCtxRev); 

   dstat = VDPRestorePlacmts(dm2_err, FileName, msg, mdcobid, ftype);
   
   //fclose(dm2_err);

wrapup:
   //if(dm2_err)
    //fclose(dm2_err);
if(coll)
_FREE(coll);
  End
 return OM_S_SUCCESS;
}

/* ----------------------------------------------
 * ah - Refactor, don't know if it's used or not but
 * need some routines to update the dad collector anyways
 * so this is a good test
 *
 * Tested via ppl.
 *
 * This is called ONLY from VDPRestorePlacmts
 */
/* VDPUpdSeqNoforUid()
 * Seq no is updated in default data collector.  In DAD Reconnect process,
 * Maximum Uid value is retreived from AIM and stored in the DAD
 * collector.
 *
 * */
IGRint VDPUpdSeqNoforUid(IGRint SrMaxUid )
{
  IGRlong status = OM_S_SUCCESS;
  IGRint  fileType = -1;

  IGRchar seqNum[32];
  TGRid   dadID;

  /* Grab the dad collector */
  VDPaimGetDADCollector(NULL_OSNUM,0,&dadID);
  if (dadID.objid == NULL_OBJID)     
  {
    UI_status("SIR Required Data not set");
    status = OM_E_ABORT;
    goto wrapup;
  }
  /* Need file type */
  VDcollGetIntAttr(&dadID,SIR_FILE_TYP,&fileType);
  switch(fileType)
  {
    /* Do not understand the logic */
    case VDP_ASIR_FILE_TYPE_DIAGRAM:
    case VDP_ASIR_FILE_TYPE_ARR:
    case VDP_ASIR_FILE_TYPE_ASM:

      sprintf(seqNum,"%d",SrMaxUid+1);
      VDcollSetTextAttr(&dadID,SIR_SEQ_NO,seqNum);
      break;
  }

wrapup:
  return status;
}
/* ----------------------------------------------
 * This returns a string of the applicable hulls
 * for a given part, it replaces the old PDMReadHullApp
 * the garbage used to turn it's results into a string
 */
int VDPaimGetHullApp(char *cat, char *part, char *rev, char *app)
{
  int retFlag = 0;

  char hulls[256];
  int  hullNumMin;
  int  hullNumMax;
  int  numHulls;
  int  i;

  char buf[128];
  char sql[256];

  TVDrisInfo ris;

  /* Init */
  *app = 0;
  VDrisInitInfo(&ris);

  /* Build select clause */
  VDshipGetHulls(hulls);
  if (*hulls == 0) goto wrapup;

  /* Build the query */
  sprintf(sql,
    "SELECT %s FROM %s WHERE n_itemname='%s' AND n_itemrev='%s';",
    hulls,cat,part,rev);

  VDrisQuery( &ris, sql );
  if (ris.rows != 1) goto wrapup;

  /* Cycle through */
  VDshipGetMinHullNum(&hullNumMin);
  VDshipGetMaxHullNum(&hullNumMax);
  numHulls = hullNumMax - hullNumMin + 1;
  for(i = 0; i < numHulls; i++) {
    if (!strcasecmp(ris.buf[i],"Y")) {
      if (*app) strcat(app,",");
      sprintf(buf,"%d",i+hullNumMin);
      strcat(app,buf);
      if ((hullNumMin + i) == hullNumMax) strcat(app,"AF");
    }
  }

  /* Done */
  retFlag = 1;

wrapup:
  VDrisFreeInfo(&ris);
  return retFlag;
}

/* ----------------------------------------------
 * Refactor and probably delete
 * added code Pullabhotla -- Function to query Hull Applicability from PDU
 *
 * This really needs to die a horrible death
 * Pretty sure it's leaking big time
 * Need to replace several calls so leave for now
 */
int PDMReadHullApp(char *catalog, char *partid, char *revision, 
                   char *lpdvalue1[12])
{
  printf("*** Obsolete call to PDMReadHullApp %s,%s,%s\n",
         catalog,partid,revision);
  return 0;
}

#if 0
The old ReadHullAPP code
static char lpdval[256];

 char searchst[70];
 char **bufst;
 int num;
 int status=0, sts=1;
 int i;

 static char lpdnum[100] = { "lpd17,lpd18,lpd19,lpd20,lpd21,lpd22,lpd23,lpd24,lpd25,lpd26,lpd27,lpd28" }; 
 

 sprintf(searchst, "n_itemname = '%s' and n_itemrev = '%s'",
    		     partid, revision);

status =
   vdb$RisSelect(select=lpdnum,
            	 table_name = catalog, 
		 where = searchst,
		 numselect = 12,
		 p_numrows = &num,
		 p_buffer = &bufst);


  if(status != 1 || num == 0)
          return 1;
 

  for(i=0;i<=11;i++)
  { 
   

   sts = vdb$RisExtractValue( nbrows = num,
                              nbcolumns = 12,
			      buffer = bufst,
			      row = 0,
			      column = i,
			      value = &lpdval[i]);
  
   lpdvalue1[i] = &lpdval[i];   
  } 

  vdb$RisFreeBuffer( buffer = bufst, size = 1 * num );     

  return 0;
}
#endif

/* ----------------------------------------------
 * added code Pullabhotla -  
 * Function to Insert Attributes into SIR_PDM_TABLE
 */
int PDMInsertSirTable(char *Refcat, char *Refpart, char *Refrev)
{
  
  int  i, status;
  char sql[1024];
  char MdcRev[10], CntxtRev[10], CntxtName[10], CntxtType[30];

  TVDrisInfo  ris;

  // first, check to see if it is already inserted
  VDrisInitInfo( &ris );

  // the sql
  sprintf(sql,
	  "Select * from SIR_PDM_TABLE where %s='%s' and %s='%s' and %s='%s';",
	  "pdu_catalog",Refcat,"pdu_part",Refpart,"pdu_revision",Refrev);

  // the check
  VDrisQuery( &ris, sql );
  if (ris.rows > 0) goto wrapup;

  // it does not exist, so insert it
  strcpy(MdcRev, "");
  strcpy(CntxtRev,"");
  strcpy(CntxtName,"");
  strcpy(CntxtType,"");

  sprintf(sql, "INSERT INTO SIR_PDM_TABLE values('%s','%s','%s','%s','%s','%s', '%s')",
          Refcat, Refpart, Refrev, MdcRev, CntxtRev, CntxtName, CntxtType );
  VDrisExecute(sql);
  
wrapup:
  VDrisFreeInfo( &ris );
  return 0;
}
/* ----------------------------------------------
 * Replaced with VDPaimGetServerInfo
 * Stub it out
 */
int SrVDPGetAIMInfo(int *code, char **aim_user, char **aim_server,
                      char **aim_env) 
{
  printf("*** Called obsolete function  SrVDPGetAIMInfo\n");
  return 1;
}
/* ---------------------------------------------- 
 * TLS: -- Function to set the new HA in AIM on a given object 
 * 03/28/01
 *
 * ah - Does not appear to be called from anywhere.
 */
int SrUpdateHAOnOBID(char *classname, char *obid, char *newHA)
{
     int status=0, index=0, inlen=0, dstat=0, mfail, outlen, code;
     char *outbuf=NULL, *errmsg = 0;
     char inbuf[100], err[180];
     char srerrmsg[70];

     __DBGpr_com("START SrUpdateHAOnOBID");

     code = VDP_UPDATE_HA;

     memcpy( &inbuf[index], &code, sizeof(int));
     inlen += sizeof(int);
     index = inlen;

     __DBGpr_str("classname", classname);
     strcpy( &inbuf[index], classname );
     inlen += strlen(classname) +1;
     index = inlen;

     __DBGpr_str("obid", obid);
     strcpy( &inbuf[index], obid );
     inlen += strlen(obid) +1;
     index = inlen;

     __DBGpr_str("newHA", newHA);
     strcpy( &inbuf[index], newHA );
     inlen += strlen(newHA) +1;
     index = inlen;

     __DBGpr_int("trying to talk with AIM for VDP_UPDATE_HA code", code)
;
     UI_status("Updating HA in AIM.");
     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

     if(dstat != 0)
     {
      if(dstat == 12345)
      {
  	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
       }
       __DBGpr_int("dstat ", dstat);
       if(errmsg) __DBGpr_str("errmsg ", errmsg );
       UI_status("Could not Update HA in AIM.");
       status = 1;
       goto wrapup;
     }

     if (mfail != 0 )
     {
       if(errmsg)
       {
        __DBGpr_str("ERROR 2", errmsg );
       }
       __DBGpr_int("mfail ", mfail);
       status = mfail;
	printf("mfail = <%d>\n", mfail);
       UI_status("Could not Update HA in AIM.");
       status = 1;
       goto wrapup;
     }


wrapup:
     __DBGpr_com("END SrUpdateHAOnOBID");
     return status;
}

/* ----------------------------------------------
 * Obsolete
 */
method VDPCheckDM2Conn(long *msg)
{  
  printf("*** VDPCmdPMDef.VDPCheckDM2Conn ***\n");
  *msg = MSFAIL;
  return OM_E_ABORT;
}
method VDPValidateInput(long *msg)
{
  printf("*** VDPCmdPMDef.VDPValidateInput ***\n");
  *msg = MSFAIL;
  return OM_E_ABORT;
}
method VDPSaveDefaults(long *msg)
{  
  printf("*** VDPCmdPMDef.VDPSaveDefaults ***\n");
  *msg = MSFAIL;
  return OM_E_ABORT;
}
method VDPqueryPMData(long *msg)
{   
  printf("*** VDPCmdPMDef.VDPqueryPMData ***\n");
  *msg = MSFAIL;
  return OM_E_ABORT;
}
method VDPqueryClass(long *msg; IGRchar *ClassName)
{
  printf("*** VDPCmdPMDef.VDPqueryClass ***\n");
  *msg = MSFAIL;
  return OM_E_ABORT;
}
/* ----------------------------------------------
 * Updates the form from the DAD collector
 * This should be obsolete
 */
method VDPGetDefaults(long *msg)
{  
  printf("*** VDPCmdPMDef.VDPGetDefaults ***\n");
  *msg = MSFAIL;
  return OM_E_ABORT;
}

#if 0
   IGRlong		status = VD_SUCCESS;
   struct ACrg_coll	coll;
   IGRchar		CtxTypeName[VDPNAME_LEN + 128];

   char searchst[XX_LEN], ctxrev[XX_LEN], ctxrev_value[XX_LEN];
   char **bufst;
   int num;
   int status1=0, sts=1;
   

   SetProc( VDPCmdPMDef.VDPGetDefaults ); Begin

   strcpy( coll.name, SIR_CNTX_NAME );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Context Name ", coll.desc.value.att_txt );

 /* FIfld_set_text( VD_FP, G_VEW_CTX, 0, 0, coll.desc.value.att_txt, FALSE );
   */
 
  FIfld_set_text( VD_FP, G_FLD_MULTICOL, 0, 0, coll.desc.value.att_txt, FALSE );
  
/* to query ctxrev from PDU --  07/07/2000 */
   

   strcpy( coll.name, SIR_CNTX_DESC );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Context Desc. ", coll.desc.value.att_txt );

 /*  FIfld_set_text( VD_FP, G_VEW_CTX_DESC, 0, 0, coll.desc.value.att_txt, FALSE ); */

  FIfld_set_text( VD_FP, G_FLD_MULTICOL, 0, 2, coll.desc.value.att_txt, FALSE );

    FIg_disable( VD_FP, G_FLD_MULTICOL );
   
   strcpy( coll.name, SIR_CNTX_TYP );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Context Type ", coll.desc.value.att_txt );

/*   FIfld_set_text( VD_FP, G_VEW_CTX_TYP, 0, 0, coll.desc.value.att_txt, FALSE ); */

    FIfld_set_text( VD_FP, 21, 0, 0, coll.desc.value.att_txt, FALSE );

    
   //get the filetype from collector and set the toggle accordingly.
   //disable the toggle  CR # 17801371 SSR
   strcpy( coll.name, SIR_FILE_TYP );
   coll.desc.value.att_exp = 2;
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __DBGpr_int( "FILE Type ", coll.desc.value.att_exp );

   if (!(*msg&1))
   {
     // old file version, set defa file type to Non arrangement 
     FIg_set_state_off( VD_FP, G_TG_FILE_TYP);
     /* TLS 01/23/02 - AMDC Enhancements */
     FIg_set_state_off( VD_FP, G_TG_ASSEM_FILE);
   }
   else
   {
     if ( coll.desc.value.att_exp == A_FILE )
     {
       FIg_set_state_on( VD_FP, G_TG_FILE_TYP);
       /* TLS 01/23/02 - AMDC Enhancements */
       FIg_set_state_off( VD_FP, G_TG_ASSEM_FILE);
     }
     else
     {
       FIg_set_state_off( VD_FP, G_TG_FILE_TYP);
       /* TLS 01/23/02 - AMDC Enhancements */
       if ( coll.desc.value.att_exp == ASM_FILE )
       	 FIg_set_state_on( VD_FP, G_TG_ASSEM_FILE);
       else
         FIg_set_state_off( VD_FP, G_TG_ASSEM_FILE);
     }
   }

	sprintf(searchst, "pdu_catalog = '%s' and pdu_part = '%s' and pdu_revision = '%s'", refresh->act_catalog, refresh->act_partid, refresh->act_revision); 

 __DBGpr_str("Searchst is", searchst);
 
     status1 =
          vdb$RisSelect(select="ctx_rev",
                        table_name = "SIR_PDM_TABLE", 
    		        where = searchst,
			numselect = 1,
			p_numrows = &num,
			p_buffer = &bufst);
     
 if(status1 != 1 || num == 0)
                return 1;

    sts = vdb$RisExtractValue( nbrows = num,
                               nbcolumns = 1,
			       buffer = bufst,
			       row = 0,
			       column = 0,
			       value = ctxrev_value);


       vdb$RisFreeBuffer( buffer = bufst, size = 1 * num );     
         
          FIfld_set_text( VD_FP, G_FLD_MULTICOL, 0, 1, ctxrev_value, FALSE );
	   

wrapup:
   End
   return status;
}
#endif
long VDPgetCfgItms(long   *msg,
                   int    *nbCfgItms,
                   struct  VDPCfgItms **CfgItms)
{
  *msg = MSFAIL;
  *nbCfgItms = 0;
  *CfgItms = NULL;
  return OM_E_ABORT;
}
long VDPgetHulls(long  *msg,
                 char  *CfgName,
                 int   *nbHull,
                 struct VDPhulls **Hulls)
{
  *msg = MSFAIL;
  *nbHull = 0;
  *Hulls = NULL;
  return OM_E_ABORT;
}
end implementation  VDPCmdPMDef;
