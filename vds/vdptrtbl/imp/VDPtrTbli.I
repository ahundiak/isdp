/* $Id */

/* I/Vds
 *
 *
 * File:        vdptrtbl/imp/VDPtrTbli.I
 *
 * Description:
 *      Implementation of the following methods for VDPtrTbl.S
 *
 * Dependencies:
 *
 * History:
 *
 *      09/26/95        MSM        Creation
 *      09/23/96        MRA        Added code in post module to handle the
 *                                 difference in terminology between VDS and
 *                                 PME attr names.
 *	10/03/96	MSM	   Fix TR # 179603132
 *	10/08/96	MRA	   Added fix for TR#179603260
 *	10/09/96	MSM	   Fix for TR #179603375
 *	10/21/96	MSM	   Placing a single compartment & posting it
 *				   immediately fails.
 *	10/23/96	MSM	   Deleting a compartment and deleting other
 *				   items fails.
 *      11/05/96        Ravi       Added the methods VDPBatchpostPMEData and
 *                                 VDPtrtblcopy for Batch posting.
 *
 *	Apr 13 1998	SSR	TR # 179800959 Modified postpmedata to take care
 *				 of piping, struct, equipment objects. 
 *				comparison of NFM and seedfile units, 
 *				accordingly convert weight and compute net 
 * 				weight. the value goin into buffer for ppme 
 *				shopuld be in compliance with seedfile units.
 *
 *  Aug 07 1998    Shailesh        Changes for SIR, Modified foll methods
 *                                 VDPAddtoTrTable    and VDPpostPMEdata
 *                                 New function       VDPpostObjectToSIR
 *                                 removed some never referenced variables.
 *  Aug 31 1998    Shailesh        Changes in logfile generation in 
 *                                 SIR posting
 *  Sep 03  98     Shailesh        TR # 179801619 Increased mino[]
 *  Sep 04  98     ah              Added string.h for clix
 *                                 Initialized units in VDPpostPMEdata
 *  Sep 14  98     Shailesh        TR # 179801647 mapped VRPNozz to SrPiping
 *  sep 24  98     Shailesh        TR # 179801647 commented mapping of 
 *                                 VRPNozz. Recommendation of CCB. 
 *                                 Comments should be removed when requested.
 *  Sep30 1998     Shailesh        Added VDaimGetpostyes()
 *                                 to show posting status on ststus bar
 *  Oct 15 98      Shailesh        Modified log messages.
 *  Nov 24 98	SSR		CR#179801693 new functions to put and extract
 *  				posting status from action code All the
 *  				references of action code had to be changed to
 *  				the extracted action code.
 *  				CR#179801371 Changes in buffer preparation for
 *  				SIR, read file type from collector also.
 *  				CR#179802035 VREquipment ampped to SrEquip.
 *
 *  Dec 29 98	SSR		TR#179802506 entries of deleted or disabled 
 *  				items appear in logfile. This was because these
 *  				objects get entered in trans table. 
 *  				The code added was to identify whether the 
 *  				object was created in current session, if yes 
 *  				remove it from transtable. After the object is
 *  				removed from trans table, it won't get posted
 *  				and no entry in logfile.
 *  Feb 25 99	SSR		Disallowed Tag_number and Eqp_number as "null"
 *  				CR#179900381
 *  Feb 25 99	Rajendra	Chenged log file message TR#179900164
 *  Aug 27 99	SSR		New funcions for CM AIM integration
 *  Oct 29 99	SSR		moved in CMget_wflow_name from another file
 *  Nov 25 99	SSR		TR 696 Posting HVAC attribites.
 *  NOV 25 99	SSR		TR 1379 Posting 2D files with references
 *  				attached.
 *  NOV 25 99 SSR		TR 1527 modified CMget_wflow_name()
 *  Feb 11 00 SSR		Memory mgmnt changes in CheckUid.
 * 
 * *******************************************************************/

class implementation VDPtrTbl;

/*
#define vaimDEBUG
#define vaimerrDEBUG
*/

#include <stdio.h>
#include <time.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"
#include "execmsg.h"
#include "MEMstruct.h"

#include "VDPdef.h"
#include "v_miscmacros.h"
#include "vadbgmacros.h"
#include "v_datamacros.h"
#include "VDtypedef.h"

#include "grdpbmacros.h"
#include "grdpbdef.h"

#include "ACdb_info.h"
#include "ACcheckin.h"
#include "ACrg_collect.h"
#include "ACattrib.h"

#include "VDScheckdef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "vdparmacros.h"
#include "vdbmacros.h"
#include "VDPdm2.h"
#include "VDSutil.h"
#include "PDUstr.h"
#include "PDUerror.h"

#include "VDPtrTbl.h"
//include "Avon.h"
#include "VDsa.h"
#include "igrtypedef.h"
#include "PDMmacros.h"
#include "vdbmacros.h"
#include "SQLerrordef.h"

#include "VDpdm.h"  // SAUBY added for new sirid generation stuff
#include "VDPaimUtil.h"

#include "VDctx.h"

//TLS TR 6230
#include "VDos.h"

#define FILE_PRINT	if (dm2_log) fprintf
#define PRINT_FILE      if (fp) fprintf

#define INCH3_TO_METER3 1.63871e-05
#define INCH_TO_METER   0.0254
#define METER_TO_FOOT   3.28084
#define POUND_TO_KG     0.453592
#define DENSITYE_TO_DENSITYM    16.0185


// Added by meghani
#define cube(x) ((x)*(x)*(x))
#define cnv_fact1 0.0833
#define cnv_fact3 (1.0/115.212462) 
#define cnv_fact2 (1.0/671.9684863)
#define cnv_fact4 0.001
#define cnv_fact5 (cube(.0254)/0.453)
#define cnv_fact6 (1.0/cube(12.0))
#define cnv_fact8 (0.453/cube(304.0))
#define cnv_fact7 (1.0/cube(1000.0))

// added by Eswar
#define VDP_SUCCESS	0
#define VDP_UNPOSTED	1
#define VDP_ERROR	2
#define VDP_DUP_ERR	3

from	NDmacro	import	ACtest_consumed;
from VDPenabObj         import VDPIsObjEnabled;
from ACrg_collect import ACget_named_attribute,
                         ACset_list_attribute;
from VDSroot import ACgive_db_structure;
from VDPenabObj import VDPgetPMenabledList;


extern GRclassid	OPP_VDSroot_class_id;
extern int VDDelEBOMsir( );
extern int VDpostPart2SIR( );
extern int VDaddPart4SIR( );
extern int VDgetSrError( );
extern int* VDaimGetpostyes();
extern int* VDaimGetpostno();
extern struct PDUrefresh   *refresh;
%safe
static struct VDPtrObjList *GlTrTbl = NULL; // CR # 179801693
static int TrTblSize = 0;
static struct SIRRefInfo   *SIR_Diag_Info = NULL;
static int GRefSize = 0;
%endsafe
/*
extern int CumPartVar;
extern struct SRPartStat *partcount;
*/

struct SIRRefInfo *VDGetDiagInfo()
{
  return SIR_Diag_Info;
}

struct VDPtrObjList *VDgetTrTable() // CR # 179801693
{
  return GlTrTbl;
}

int VDgetTrSize() // CR # 179801693
{
  return TrTblSize;
}

int VDgetRefSize() //Global Variable to give Ref file size 
{
  return GRefSize;
}
/*+me
  Public Message VDPinit

  Abstract
        This message initialises the Object created.

  Algorithm
        1. Check for arguments.
        2. Set the size in instance data to 0.

  Arguments
        IGRlong          *msg     I/O    return message
                                         MSSUCC/MSFAIL.

  Notes/Remarks

  Examples

  Status/Return Code
      status == OM_S_SUCCESS    if success;
      status == OM_E_xxx        ...

-me*/

method VDPinit( IGRlong *msg )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDPtrTbl.VDPinit ); Begin
    if( !msg )
        return OM_E_INVARG;

    *msg = MSSUCC;

    om$vla_set_dimension( varray = me->transObj, size = 0 );

    End
    return status;
}

/*+me
  Public Message VDPAddtoTrTable

  Abstract
	This mesage adds a row to the trObjList table. Depending on the action 
  code and the previous entries in the table appropriate processing is done.

  Algorithm

  Consider different cases:

  If a new object is created or placed from the placement list:
	Add an entry to the trans table.

  If an object is being modified:
	If the last action done performed on the object is Version then add
	to the trans list.
	If nothing was done in the current design session then add to the List.
	Else ignore.

  If an object is replaced.
	if the object is created in the current session then delete the 
	created entry from the trans table, and set action code to CREATE
	instead of replaced for the new object.
	if the object is not created in the current session then add to trans
	tbl.

  If an object is deleted.
	If the object is created in the current session then delete from the
	trans table.
	If the object is not created or not modified or not versioned in the 
	current session then add to the trans table.
	If the object is modified, versioned or replaced, then save the object's
	information elsewhere to be retrieved during posting.

  If an object is versioned.
	Add to the transtable, but also store the set of attribute values at 
	the time of versioning.

  Arguments

  Notes/Remarks

  Examples

  Status/Return Code
     status == OM_S_SUCCESS if success;

-me*/

method VDPAddtoTrTable ( IGRlong *msg; struct VDPtrObjList  TrRow )
{
    IGRlong             status = OM_S_SUCCESS;
    IGRint		i, row_to_delete, size, ii, new_size;
    struct GRid		Obj, trTblId;
    IGRint		localVar = 0, Ext_ActCode = 0;
    struct VDPtrObjList *temptrtblist = NULL;

    SetProc( VDPtrTbl.VDPAddtoTrTable ); Begin
  
    if( !msg )
      return OM_E_INVARG; 
    
    *msg = MSSUCC; 
    
    size = om$dimension_of ( varray = me->transObj );
    __DBGpr_int ( "Size of Trans List : ", size );
    localVar = getActionCode(TrRow.ActionCode); // CR # 179801693
    //   __DBGpr_int( " TrRow.ActionCode ", TrRow.ActionCode);
    __DBGpr_int( " Extracted action code", localVar);
    //    switch( TrRow.ActionCode )
  
    //switch(localVar) Switch depending on Extracted Action code( localVar) First half of TrRow.ActionCode has posting status and other half is Action code.  CR # 179801693
    switch(localVar)
    {
     case VDP_CREATE :
     case VDP_FRPLLST :
	 size++;
	 om$vla_set_dimension( varray = me->transObj, size = size ); 
		/* Add to the Transaction List */
		// me->transObj[size-1].ActionCode = TrRow.ActionCode; 
	 me->transObj[size-1].ActionCode = 0; // Initialise
	 /* setActionCode and setPostingStatus, will set the action code and
	  * posting status in correct half of the int TrRow.ActionCode so in
	  * every case the setting of both codes is done thro these functions */
	 setActionCode(&me->transObj[size-1].ActionCode, localVar); //CR179801693
	 me->transObj[size-1].VDSobjid = TrRow.VDSobjid;
	 me->transObj[size-1].oldVDSobjid = TrRow.oldVDSobjid;
	 strcpy(me->transObj[size-1].PMEobid, TrRow.PMEobid);
	 me->transObj[size-1].posted = FALSE;
	 setPostingStatus(&me->transObj[size-1].ActionCode, VDP_UNPOSTED); //CR179801693
	 __DBGpr_com( " posted flag set to false "); 
	 break; 
   
     case VDP_MODIFY :
       /* Check if the last action on the object was versioning */
	 i = size-1;
	 while( i >= 0 && me->transObj[i].VDSobjid != TrRow.VDSobjid )
	   i--;
       //if (i < 0 || me->transObj[i].ActionCome->transObj[de == VDP_VERSION  )
	 if (i<0 || getActionCode(me->transObj[i].ActionCode)==VDP_VERSION  ) //CR179801693
	 {
	   size++;
	   om$vla_set_dimension( varray = me->transObj, size = size );
		//    me->transObj[size-1].ActionCode = TrRow.ActionCode;
	   setActionCode(&me->transObj[size-1].ActionCode, localVar); //CR179801693
	   me->transObj[size-1].VDSobjid = TrRow.VDSobjid;
	   me->transObj[size-1].oldVDSobjid = TrRow.oldVDSobjid;
	   strcpy(me->transObj[size-1].PMEobid, TrRow.PMEobid);
	   me->transObj[size-1].posted = FALSE;
	   setPostingStatus(&me->transObj[size-1].ActionCode, VDP_UNPOSTED); //CR179801693
	   __DBGpr_com( " posted flag set to false ");
	 }
	 else
	   setPostingStatus(&me->transObj[i].ActionCode, VDP_UNPOSTED);  //CR179801693
	 break;
	
     case VDP_REPLACE :
	 /* Check if the object that is being replaced is created in the current session */
	 i = size-1; 
	 while ( i >= 0 && me->transObj[i].VDSobjid != TrRow.VDSobjid )
	   i--; 
	 //if (i >= 0 && me->transObj[i].ActionCode == VDP_CREATE ) 
	 if (i >= 0 && getActionCode(me->transObj[i].ActionCode) == VDP_CREATE ) //CR179801693
		/* The last action was creation of the object */
	 {
	   row_to_delete = i;
	   for ( i = row_to_delete; i < size-1; i++ )
	     memcpy(&me->transObj[i], &me->transObj[i+1],
		 sizeof( struct VDPtrObjList ));
	   //TrRow.ActionCode = VDP_CREATE;
	   setActionCode(&TrRow.ActionCode, VDP_CREATE); // CR#179801693
	   memcpy( &me->transObj[size-1], &TrRow,
	       sizeof( struct VDPtrObjList )); 
	   break;
	 }
	 else
	   //if( i >= 0 && me->transObj[i].ActionCode == VDP_REPLACE )
	   if( i >= 0 &&
	       getActionCode(me->transObj[i].ActionCode) == VDP_REPLACE ) //CR#179801693
		/* The last action was replacement of the object */
	   {
	     row_to_delete = i;
	     for ( i = row_to_delete; i < size-1; i++ )
	       memcpy(&me->transObj[i], &me->transObj[i+1],
		   sizeof( struct VDPtrObjList ));
	     memcpy(&me->transObj[size-1],&TrRow,
		 sizeof( struct VDPtrObjList ));
	     me->transObj[size-1].posted = FALSE;
	     setPostingStatus(&me->transObj[size-1].ActionCode, VDP_UNPOSTED); //CR#179801693
	     __DBGpr_com( " posted flag set to false ");
	     break;
	   } 
	 
	 size++;
	 om$vla_set_dimension( varray = me->transObj, size = size );
	 memcpy( &me->transObj[size-1], &TrRow,
	     sizeof( struct VDPtrObjList ));
	 me->transObj[size-1].posted = FALSE;
	 setPostingStatus(&me->transObj[size-1].ActionCode, VDP_UNPOSTED); //CR#179801693
	 __DBGpr_com( " posted flag set to false "); 
	 break;

     case VDP_DELETE :
	 // Added to find whether object was created in this session. TR #
	 // 179802506 to avoid entries of disabled FSIs.
	 __DBGpr_int( " tr table size ", size );
	 i = size-1; 

	 while ( i >= 0 && me->transObj[i].VDSobjid != TrRow.VDSobjid )
	   i--; 

	 // This i th item is to be deleted.
	 __DBGpr_int( " row_to_delete", i);
	   row_to_delete = i;
	 if (i >= 0 && getActionCode(me->transObj[i].ActionCode) == VDP_CREATE )
	 {
           // SSR 10 AUG we can test is the object is modified in this session
           // If yes, delete the entry.
	   // i th item is created in current session; so remove the entry.
	   temptrtblist = _MALLOC ( size, struct VDPtrObjList);
	   for ( ii = 0; ii < size; ii++)
	   {
	     memcpy(&temptrtblist[ii], &me->transObj[ii],
		 sizeof(struct VDPtrObjList));
	   }
	   // if tr table has only 1 item, delete the list.
	   if(size == 1)
	   {
	     VDPGetTrTblId ( msg, &trTblId );
	     _VD_SEND_OBJN ( trTblId, Root.delete (1));
	     break;
	   }

	   new_size = size - 1;
	   om$vla_set_dimension ( varray = me->transObj, size = new_size);

	   // Remove the deleted item from TrTable List.
	   for ( ii = 0; ii < row_to_delete; ii++ )
	     memcpy(&me->transObj[ii], &temptrtblist[ii],
		 sizeof(struct VDPtrObjList));
	   
	   for ( i = row_to_delete; i < new_size; i++ )
	     memcpy(&me->transObj[i], &temptrtblist[i+1],
		 sizeof( struct VDPtrObjList));

	   __DBGpr_int( " new size ", om$dimension_of(varray=me->transObj) );
	   break;
	 }
	 
	 size++;
	 om$vla_set_dimension( varray = me->transObj, size = size ); 
		 //   me->transObj[size-1].ActionCode = TrRow.ActionCode;
	 setActionCode(&me->transObj[size-1].ActionCode, localVar);
	 //CR#179801693
	 me->transObj[size-1].VDSobjid = TrRow.VDSobjid;
	 me->transObj[size-1].oldVDSobjid = TrRow.oldVDSobjid;
	 strcpy(me->transObj[size-1].PMEobid, TrRow.PMEobid);
	 me->transObj[size-1].posted = FALSE;
	 setPostingStatus(&me->transObj[size-1].ActionCode, VDP_UNPOSTED);
	 //CR#179801693
	 __DBGpr_com( " posted flag set to false "); 
	 break; 
   
     case VDP_DEL_COMP :
	 i = 0;

	 if ( size != 0 )
	 {
	   while ( i < size && me->transObj[i].VDSobjid != TrRow.VDSobjid )
	     i++;
	   /* if the item to be deleted is not found in the list, then 
		i == size, we should not break, instead continue.
		if ( i == size && i != 0 ) break; */
		
	 /*if(i >=0&& i < size && (me->transObj[i].ActionCode == VDP_CREATE ||
	  *	me->transObj[i].ActionCode == VDP_MODIFY ||
	  *	me->transObj[i].ActionCode == VDP_FRPLLST ))*/

	   Ext_ActCode = getActionCode(me->transObj[i].ActionCode); //CR#179801693

	   if (i >= 0 && i < size && (Ext_ActCode == VDP_CREATE ||
				Ext_ActCode == VDP_MODIFY ||
				Ext_ActCode == VDP_FRPLLST )) 
		/* It is created in this session and not versioned */
	   {
	     row_to_delete = i;
	     for ( i = row_to_delete; i < size-1; i++ )
	       memcpy(&me->transObj[i], &me->transObj[i+1],
		   sizeof( struct VDPtrObjList ));
	     size--;
	     om$vla_set_dimension( varray = me->transObj, size = size );
	     /* * If the Object is placed from placement list, you want to
	      * * mark delete fron the PME server.  */ 
	     /* * If the object is created in this session and deleted,
	      * * then no need to add to transaction list.  */
	     //if( TrRow.ActionCode == VDP_CREATE)
	     if( localVar == VDP_CREATE) 
	       break;
	   }

		/* This case should never happen ?? but just in case if it
		 * is deleted and a NDdelete is sent twice 
		 */

/*		if (i >= 0 && TrRow.ActionCode == VDP_DELETE )
		  break;
*/
	 
	 } 
	 size++;
	 om$vla_set_dimension( varray = me->transObj, size = size );
	 memcpy( &me->transObj[size-1], &TrRow, sizeof( struct VDPtrObjList ));
	 me->transObj[size-1].posted = FALSE;
	 setPostingStatus(&me->transObj[size-1].ActionCode, VDP_UNPOSTED);  //CR#179801693
	 __DBGpr_com( " posted flag set to false "); 
	 
	 break; 
   
     case VDP_VERSION :
       /* Save the Object's instance data */
		
	 Obj.objid = TrRow.VDSobjid;
	 Obj.osnum = OM_Gw_current_OS;
	 status = VDPsavePmeItemInfo( msg, Obj );

	 __CheckRC ( status, *msg , "VDPsavePmeItemInfo", wrapup ); 
	 /* Add to the List */
	 size++;
	 om$vla_set_dimension( varray = me->transObj, size = size );

	 //me->transObj[size-1].ActionCode = TrRow.ActionCode;
	 setActionCode(&me->transObj[size-1].ActionCode, localVar); //CR#179801693
	 me->transObj[size-1].VDSobjid = TrRow.VDSobjid;
	 me->transObj[size-1].oldVDSobjid = TrRow.oldVDSobjid;
	 strcpy(me->transObj[size-1].PMEobid, TrRow.PMEobid);
	 //me->transObj[size-1].posted = FALSE;
         setPostingStatus(&me->transObj[size-1].ActionCode, VDP_UNPOSTED); //CR#179801693
	 __DBGpr_com( " posted flag set to false "); 
	 break; 
   
     default :
	 break;
	 
    }

wrapup :
    if(temptrtblist)
      _FREE(temptrtblist);
    End
    return status;
}

/*+me
  Public Message VDPpostPMEdata

  Abstract
	This method retrieves the data from object and sends to the PME server.
  Depending upon the action code further processing is done on the DM2 side.

  For CREATE, MODIFY, REPLACE or FROM_PLACEMENTLIST all the attributes are
  posted.
  In case of delete only the VDS object id is sent to the DM2 server.
  In case of versioning only the VDS object id is sent to the DM2 server.

-me*/

method VDPpostPMEdata( IGRlong *msg; IGRboolean	 *allPosted )
{
    IGRlong             	status = OM_S_SUCCESS;
    struct GRid			Obj, DefDat;
    struct ACobj_info_1         ObjInfo;
    IGRint                      i, count, size, ObjType=0,
				nbObjects, ret_size, nbAttr=0, ii,
				i_fam_beam =  -1, i_prt_beam =  -1,
				i_fam_plate = -1, i_prt_plate = -1,
				i_desc      = -1, i_wt = -1,i_lt = -1, j;
    struct ACrg_coll		*Coll = NULL;

    struct ACrg_coll		*TableAttr[8]; /* Different Types of 
						  Occurrences = 7 + 1 for
						  compartment.		 */
    struct ACrg_coll            unitColl, DefColl;
    IGRint			*AttrType[8];
    IGRint			nbClassAttr[8];
    IGRdouble			dValue=0.0;

    struct VDPtrObjList		TrRow;
    struct GRmd_env		MdEnv;
    IGRchar			Message[256];
    FILE			*dm2_log=NULL;
    
    IGRchar                     Material[125],Grade[125],Density[40],
    				DefDirName[DI_PATH_MAX], DirName[DI_PATH_MAX];
    char                        ** buf;
    char                        search[256],length_txt[20],unit_txt[10];
    int                         num,sts, FileType;
    IGRdouble                   length=1,m_weight,density_value,volume,units;
    IGRint                      n_items,  objcount = 0, objctr;
    struct GRid			*list = NULL;
    OMuword			curOs;
    struct GRid			EnabId;
    IGRboolean			flag = FALSE;
    IGRchar			FileName[257];
    IGRchar			TmpFileName[270] ; 
    IGRchar			*token;
    time_t			ltime;
    IGRint 			*yespost=0, *nopost=0;
    int               ref  = 0, sclindex = 0, compindex = 0, frindex = 0, n = 0;
    char                 compnum[30], fwdfrnum[30]; 

  // Added by ah for globals
  struct SRPartStat *partcount = (struct SRPartStat *)VDaimGetPartCount();
    
  int CumPartVar = VDaimGetCumPartVar();

  // Added by meghani , index to keep track of wet_weight in a structure
  IGRint i_wwt = -1 ;
  IGRint i_ewt = -1;

  char seed_units[4];
    
  SetProc( VDPtrTbl.VDPpostPMEdata ); Begin

  if( !msg ) return OM_E_INVARG;
  *msg = MSSUCC;
  ObjInfo.quantity = 0;

  units = 0;            // Added by ah to avoid uninitted ref
  seed_units[0]='\0';
  FileName[0] = '\0';
  TmpFileName[0] = '\0';

  /* Verify file type is ARR or DM */
  VDPaimGetDADCollector(NULL_OSNUM,0,&DefDat);
  if (DefDat.objid == NULL_OBJID)
  {
    *msg = MSFAIL;
    return OM_E_ABORT;
  }
  VDcollGetIntAttr(&DefDat,SIR_FILE_TYP,&FileType);
  switch(FileType)
  {
    case VDP_ASIR_FILE_TYPE_ARR: break;
    case VDP_ASIR_FILE_TYPE_DM:  break;
    default:
      *msg = MSFAIL;
      return OM_E_ABORT;
  }


  /* Build log file */
  get_local_fname(refresh->act_catalog, 
                  refresh->act_partid,
                  refresh->act_revision,
		  FileName );
    
  token = strtok ( FileName, "." );
  sprintf( TmpFileName, "%s", token );
  strcat ( TmpFileName, "_post.log" );
  __DBGpr_str( " file ", TmpFileName );

  time ( &ltime );

  dm2_log = (FILE *)fopen(TmpFileName,"a");
  if( dm2_log == NULL )
    printf( "Cannot open file <%s>.\n",TmpFileName ); 

  /* ----------------------------------------------
   * Sir posting Code
   */
  for ( i=0; i < 8; i++ )
  {
    nbClassAttr[i] = 0;
    AttrType[i] = NULL;
    TableAttr[i] = NULL;
  } 
  //get the size of enble list. 
  ex$get_cur_mod( osnum = &curOs ); 

  nbObjects = om$dimension_of ( varray = me->transObj );
  __DBGpr_int ( "Size of Trans List : ", nbObjects );

  /* --------------------------------------------
   * Occurence Templates 
   */
  status = VDPgetOccTemplate1( msg, VDP_SIR_EQUIP_CLASS, 
			      &nbClassAttr[VDP_EQUIP],
			      &AttrType[VDP_EQUIP],
			      &TableAttr[VDP_EQUIP] );
  CheckRC ( status, *msg );

  status = VDPgetOccTemplate1( msg, VDP_SIR_PIPING_CLASS, 
			      &nbClassAttr[VDP_PIPING], 
			      &AttrType[VDP_PIPING],
			      &TableAttr[VDP_PIPING] );
  CheckRC ( status, *msg );

  status = VDPgetOccTemplate1( msg, VDP_SIR_HVAC_CLASS, 
    			      &nbClassAttr[VDP_HVAC],
			      &AttrType[VDP_HVAC],
			      &TableAttr[VDP_HVAC] );
  CheckRC ( status, *msg );

  status = VDPgetOccTemplate1( msg, VDP_SIR_RWAY_CLASS, 
			      &nbClassAttr[VDP_RWAY],
			      &AttrType[VDP_RWAY],
			      &TableAttr[VDP_RWAY] );
  CheckRC ( status, *msg );

  /* Cycle through transaction list */
  for ( i = 0; i < nbObjects; i++ )  // if trans list existt
  {
  if ( me->transObj[i].posted == TRUE ) continue; 
      
      Obj.objid = me->transObj[i].VDSobjid;
      Obj.osnum = OM_Gw_current_OS; 
      
      ObjInfo.quantity = 0; /* Initialising it to 0. 10.23.96 */

       /* add a check to see it error code is for duplicate UID;
        * If ERROR DUP; skip the object */
	/*
	 * If the object for some reason is deleted and it does not figure
	 * in the trans list, then set it as deleted.
	 */

      if ((om$is_objid_valid ( objid = Obj.objid )) != OM_S_SUCCESS) 
	setActionCode(&me->transObj[i].ActionCode, VDP_DELETE);
	memcpy( &TrRow, &me->transObj[i], sizeof( struct VDPtrObjList ));

	__DBGpr_int ( "Action Code  in me-> :", getActionCode(me->transObj[i].ActionCode) );
	__DBGpr_obj ( "Processing Object :", Obj );

	FILE_PRINT(dm2_log, "\nF S I  : [%d/%d]", Obj.osnum, Obj.objid);
	printf("\nF S I  : [%d/%d]", Obj.osnum, Obj.objid);//ssr18may

	sprintf( Message, "Processing F S I  #%d %d \0", i, Obj.objid );
	UI_status( Message );

//	if ((me->transObj[i].ActionCode) != VDP_DELETE )
	if ((getActionCode(me->transObj[i].ActionCode)) != VDP_DELETE ) // CR#179801693
	{
	  count = 1;
	  /* Get DB info & quantity */
	  status = VdsGet_db_info( &Obj, &ObjInfo, count );
	  __DBGpr_int( " ObjInfo.quantity ", ObjInfo.quantity);

	  if (ObjInfo.quantity == EQUIPMENT_OBJ ) ObjType = VDP_EQUIP;
	  else if (ObjInfo.quantity == PIPING_OBJ) ObjType = VDP_PIPING;
	  // changed hvac_OBJ to SCH_HVAC_OBJ TR 696
	  else if (ObjInfo.quantity == SCH_HVAC_OBJ) ObjType = VDP_HVAC;
	  else if (ObjInfo.quantity == RWAY_OBJ) ObjType = VDP_RWAY;
        // Commented to stop posting of nozzles to SIR as suggested by CCB
		// refer TR # 179801647
		//else if (ObjInfo.quantity == PID_PIPENOZ_OBJ)
         //ObjType = VDP_PIPING;//-103
      
	  else if (ObjInfo.quantity == PID_EQUIP_OBJ)
	    ObjType = VDP_PIPING;//-102
	  else if (ObjInfo.quantity == PID_PIPING_OBJ)
	    ObjType = VDP_PIPING;     //-101 
	}

	__DBGpr_int( " code " ,getActionCode(me->transObj[i].ActionCode));

	switch( getActionCode(me->transObj[i].ActionCode) )//CR#17980169
	{
	 case VDP_MODIFY :
	 case VDP_CREATE : 
	     
	     nbAttr = nbClassAttr[ObjType];
	     __DBGpr_int("NbAttr :", nbAttr );
	     if ( nbAttr )
	       Coll = _MALLOC ( (nbAttr + 9), struct ACrg_coll);
	     if ( Coll == NULL )
	     {
	       UI_status("Error no dynamic memory");
	       return OM_E_NODYNMEM;
	     }
	     memcpy(Coll, TableAttr[ObjType], nbAttr*sizeof(struct ACrg_coll ));
            
	     strcpy( Coll[nbAttr].name, "macro_name");
	     Coll[nbAttr].desc.type = AC_ATTRIB_TEXT;
	     strcpy(Coll[nbAttr].desc.value.att_txt, "");

	     strcpy( Coll[nbAttr+1].name, "system_name");
	     Coll[nbAttr+1].desc.type = AC_ATTRIB_TEXT;
	     strcpy(Coll[nbAttr+1].desc.value.att_txt, "");

	     strcpy( Coll[nbAttr+2].name, "tag_number");
	     Coll[nbAttr+2].desc.type = AC_ATTRIB_TEXT; 
	     strcpy(Coll[nbAttr+2].desc.value.att_txt, "");
	    
	     strcpy( Coll[nbAttr+3].name, "eqp_partno");
	     Coll[nbAttr+3].desc.type = AC_ATTRIB_TEXT; 
	     strcpy(Coll[nbAttr+3].desc.value.att_txt, "");
	    
	     strcpy( Coll[nbAttr+4].name, "mino");
	     Coll[nbAttr+4].desc.type = AC_ATTRIB_TEXT;
	     strcpy(Coll[nbAttr+4].desc.value.att_txt, "");
             
	     strcpy( Coll[nbAttr+5].name, "cage");
	     Coll[nbAttr+5].desc.type = AC_ATTRIB_TEXT; 
	     strcpy(Coll[nbAttr+5].desc.value.att_txt, "");

	     strcpy( Coll[nbAttr+6].name, "eqp_number");
	     Coll[nbAttr+6].desc.type = AC_ATTRIB_TEXT; 
	     strcpy(Coll[nbAttr+6].desc.value.att_txt, "");
	     
	     strcpy( Coll[nbAttr+7].name, "sirid");
	     strcpy(Coll[nbAttr+7].desc.value.att_txt, "");
	     Coll[nbAttr+7].desc.type = AC_ATTRIB_TEXT;

	     strcpy( Coll[nbAttr+8].name, "fwd_fr");
             strcpy(Coll[nbAttr+8].desc.value.att_txt, "");
             Coll[nbAttr+8].desc.type = AC_ATTRIB_TEXT;

             nbAttr = nbAttr + 9;

	    //added for equipment location enhancements
 
	     for(n = 0; n < nbAttr; n++)
             {
                 if(!strcmp(Coll[n].name, "compt_number"))
                     compindex = n;
                 if(!strcmp(Coll[n].name, "fwd_fr"))
                     frindex = n;
                 if(!strcmp(Coll[n].name, "SCLSISeqp_loc"))
                     sclindex = n;
              }

	     __DBGpr_com ("Memory Allocated for Coll");
	     size = sizeof( struct GRmd_env ) ;

	     gr$get_module_env(  msg    = msg,
		 sizbuf = &size,
		 buffer = &MdEnv,
		 nret   = &ret_size );

	     status = vd$review_params(   pMsg            = msg,
				    pComponent      = &Obj,
				    pMdEnv          = &MdEnv,
				    pList           = Coll,
				    NbParams        = nbAttr );

	     __DBGpr_int ( "Nb Attr : ", nbAttr );

	      //added to get the value dynamically for the SILSISequipment
	     //location attribute from compartment number and forword frame
	     //attributes.

	      compnum[0] = '\0';
              fwdfrnum[0] = '\0';

              if((strlen(Coll[frindex].desc.value.att_txt) == 0)||
                (strlen(Coll[compindex].desc.value.att_txt) == 0))
              {
                  strcpy(Coll[sclindex].desc.value.att_txt, " ");
                  Coll[sclindex].desc.type = AC_ATTRIB_TEXT;
              }
              else
              {
		  strcpy(compnum, Coll[compindex].desc.value.att_txt);
                  strcpy(fwdfrnum, Coll[frindex].desc.value.att_txt);
                  token = strtok(compnum, "-");
                  while(token != NULL)
                  {
                       ref++;
                       if(ref == 2)
                       {
                          strcat(Coll[sclindex].desc.value.att_txt, "-");
                           strcat(Coll[sclindex].desc.value.att_txt, fwdfrnum);
                       }
                       else
                       {
                           if(ref == 1)
                              strcpy(Coll[sclindex].desc.value.att_txt, token);
                           else
                           {
                              strcat(Coll[sclindex].desc.value.att_txt, "-");
                              strcat(Coll[sclindex].desc.value.att_txt, token);
                           }
                       }
		       token = strtok(NULL, "-");
                  }

                  if(ref == 1)
                     strcpy(Coll[sclindex].desc.value.att_txt, " ");

                  Coll[sclindex].desc.type = AC_ATTRIB_TEXT;
              }

	     break; 
	 
	 case VDP_DELETE :
	     nbAttr = 0;
	     break; 
	} // end switch on action code

	sprintf( Message, "Posting Object #%d %d \0", i, Obj.objid );
	UI_status( Message );

	status = VDPpostObjectToSIR( msg, 
				ObjInfo.quantity, 
				TrRow, 
				nbAttr, 
				AttrType[ObjType], 
				Coll, 
				dm2_log );
	CheckRC( status, *msg );

	if ( !(status & *msg & 1 ))
	{
          __DBGpr_int("msg", *msg);
	  setPostingStatus(&me->transObj[i].ActionCode, VDP_ERROR );//CR#179801693
          if(*msg == 46)
            //setPostingStatus(&me->transObj[i].ActionCode, VDP_ERROR);
            setPostingStatus(&me->transObj[i].ActionCode, VDP_DUP_ERR);
	  fflush(dm2_log);
	  me->transObj[i].posted = FALSE;
	}
	else
	{
	  setPostingStatus(&me->transObj[i].ActionCode, VDP_SUCCESS);//CR#179801693
	  fflush(dm2_log );
	  me->transObj[i].posted = TRUE;
	}
	_FREE( Coll );


    } // end if trans exists
    /* The transaction List object should be deleted by the caller */

    *allPosted = TRUE;
    for ( i = 0; i < nbObjects; i++ )
    {      
      if (me->transObj[i].posted == FALSE )
      {
	*allPosted = FALSE;
	break;
      }
    } 
    
    nopost  = VDaimGetpostno();
    yespost = VDaimGetpostyes();
    FILE_PRINT(dm2_log,"\n %d Objects Posted, %d Errors.", *yespost, *nopost );
    printf("\n %d Objects Posted, %d Errors.\n", *yespost, *nopost );//ssr18may
    sprintf(Message,"%d Objects Posted, %d Errors.", *yespost, *nopost );
    UI_status(Message);

wrapup:

for ( i =0; i < 7; i++ )
{
  _FREE( AttrType[i] );
  _FREE( TableAttr[i] );
}
   
  fprintf( dm2_log, "\n" );
  fclose ( dm2_log ); 

  if ( list )
   _FREE( list );

    End
    return status;
}


method VDPprintTransTable( IGRlong *msg )
{
    IGRlong             status = OM_S_SUCCESS;
    IGRint		size, i;

    SetProc( VDPtrTbl.VDPprintTransTable ); Begin
    if( !msg )
	return OM_E_INVARG;

    size = om$dimension_of ( varray = me->transObj );
    __DBGpr_int ( "Size of Trans List : ", size );

    GlTrTbl = _MALLOC ( size, struct VDPtrObjList );
    if ( GlTrTbl == NULL )
    {
      UI_status("Error no dynamic memory");
      return OM_E_NODYNMEM;
    }
    
    
    TrTblSize = size;
    for ( i = 0; i < size; i++ )
    {
      memcpy( &GlTrTbl[i], &me->transObj[i], sizeof( struct VDPtrObjList ));//CR#179801693
      //printf("\n act Code %d", GlTrTbl[i].ActionCode);
	//printf(" i = %d ::\t ActionCode = %d, VDSobjid = %d, oldVDSobjid = %d, PMEobid = %s\n",
	//	i,
	//	me->transObj[i].ActionCode, 
	//	me->transObj[i].VDSobjid, 
	//	me->transObj[i].oldVDSobjid, 
	//	me->transObj[i].PMEobid );
    }
    End
    return status;
}

/*+me
  Public Message VDPBatchpostPMEdata

  Abstract
	This method retrieves the data from object and calls the function
  VDPprepareASCIIFile. It prepares the ascii file which is required for
  Batch posting.  
  Depending upon the action code further processing is done on the DM2 side.

  For CREATE, MODIFY, REPLACE or FROM_PLACEMENTLIST all the attributes are
  posted.
  In case of delete only the VDS object id is sent to the DM2 server.
  In case of versioning only the VDS object id is sent to the DM2 server.

-me*/

method VDPBatchpostPMEdata( IGRlong *msg; IGRchar  *FileName )
{
    IGRlong             	status = OM_S_SUCCESS;
    struct GRid			Obj;
    struct ACobj_info_1         ObjInfo;
    IGRint                      i, count, size, ObjType=0,
				nbObjects, ret_size, nbAttr=0, ii,
				i_fam_beam =  -1, i_prt_beam =  -1,
				i_fam_plate = -1, i_prt_plate = -1,
				i_desc      = -1;
    struct ACrg_coll		*Coll = NULL;

    struct ACrg_coll		*TableAttr[7]; /* Different Types of 
						  Occurrences = 6 + 1 for
						  compartment.		 */
    IGRint			*AttrType[7];
    IGRint			nbClassAttr[7];
    IGRdouble			dValue=0.0;

    struct VDPtrObjList		TrRow;
    struct GRmd_env		MdEnv;
    IGRchar			Message[256];
    IGRchar			tmpstr[80];
    OMuword             	curOs;
    char                	FileId[VDPOBID_LEN];
    FILE			*fp=NULL;

    SetProc( VDPtrTbl.VDPBatchpostPMEdata ); Begin
    if( !msg )
	return OM_E_INVARG;

    *msg = MSSUCC;
    ObjInfo.quantity = 0;

    fp = (FILE *)fopen(FileName,"w");
    if( fp == NULL ) 
    {
	sprintf( Message,"Cannot open file <%s>.\n", FileName );
        UI_status( Message );
        exit(0); 

    }
    ex$get_cur_mod( osnum = &curOs );
    UI_status("Preprocessing....");

    status = VDPGetFileId( msg, curOs, FileId );
    if( ! status & 1 )
    {
      __DBGpr_int( "VDPGetFileId Failed in", __LINE__ );
      __DBGpr_str( " in file", __FILE__ );
      
    }
    __DBGpr_str( "FileId:",FileId );
    CheckRC (status, *msg);
    sprintf(tmpstr,"%s%s","POSTING_STARTED|",FileId );
    PRINT_FILE( fp,"%s\n",tmpstr );
    fflush(fp);
    /* Query DM2 database for the attribute information */

    for ( i=0; i < 7; i++ )
    {
	nbClassAttr[i] = 0;
	AttrType[i] = NULL;
	TableAttr[i] = NULL;
    }

    status = VDPgetOccTemplate1( msg, VDP_EQUIP_CLASS,&nbClassAttr[VDP_EQUIP],
				 &AttrType[VDP_EQUIP],&TableAttr[VDP_EQUIP] );
    CheckRC ( status, *msg );

    status = VDPgetOccTemplate1( msg, VDP_PIPING_CLASS,&nbClassAttr[VDP_PIPING],
				 &AttrType[VDP_PIPING],&TableAttr[VDP_PIPING] );
    CheckRC ( status, *msg );

    status = VDPgetOccTemplate1( msg, VDP_HVAC_CLASS, &nbClassAttr[VDP_HVAC],
				 &AttrType[VDP_HVAC],&TableAttr[VDP_HVAC] );
    CheckRC ( status, *msg );

    status = VDPgetOccTemplate1( msg, VDP_RWAY_CLASS, &nbClassAttr[VDP_RWAY],
				 &AttrType[VDP_RWAY],&TableAttr[VDP_RWAY] );
    CheckRC ( status, *msg );

    status = VDPgetOccTemplate1( msg, VDP_BEAM_CLASS, &nbClassAttr[VDP_BEAM],
				 &AttrType[VDP_BEAM],&TableAttr[VDP_BEAM] );
    CheckRC ( status, *msg );

    status = VDPgetOccTemplate1( msg, VDP_PLATE_CLASS, &nbClassAttr[VDP_PLATE],
				 &AttrType[VDP_PLATE], &TableAttr[VDP_PLATE] );
    CheckRC ( status, *msg );

    status = VDPgetOccTemplate( msg,VDP_COMPART_CLASS,&nbClassAttr[VDP_COMPART],
			 &AttrType[VDP_COMPART],&TableAttr[VDP_COMPART] );
    CheckRC ( status, *msg );


    nbObjects = om$dimension_of ( varray = me->transObj );
    __DBGpr_int ( "Size of Trans List : ", nbObjects );

    for ( i = 0; i < nbObjects; i++ )
    {
	if ( me->transObj[i].posted == TRUE )
	    continue;
        UI_status("Preprocessing....");

	Obj.objid = me->transObj[i].VDSobjid;
	Obj.osnum = OM_Gw_current_OS;

	/*
	 * If the object for some reason is deleted and it does not figure
	 * in the trans list, then set it as deleted.
	 */

	if ((om$is_objid_valid ( objid = Obj.objid )) != OM_S_SUCCESS &&
	    me->transObj[i].ActionCode != VDP_DEL_COMP )
	    me->transObj[i].ActionCode = VDP_DELETE;

	memcpy( &TrRow, &me->transObj[i], sizeof( struct VDPtrObjList ));

	__DBGpr_int ( "Action Code :", me->transObj[i].ActionCode );
	__DBGpr_obj ( "Processing Object :", Obj );

        if( me->transObj[i].ActionCode != VDP_DEL_COMP )
        {
            status = _VD_SEND_OBJ( Obj, NDmacro.ACtest_consumed ( msg ));
            if (*msg & 1 )
            {
                me->transObj[i].ActionCode = VDP_DELETE;
                memcpy( &TrRow, &me->transObj[i], sizeof(struct VDPtrObjList ));
            }
        }


	if ((me->transObj[i].ActionCode) != VDP_DELETE && 
			 (me->transObj[i].ActionCode) != VDP_DEL_COMP )
	{
	    count = 1;
	    /* Get DB info & quantity */
	    status = VdsGet_db_info( &Obj, &ObjInfo, count );

	    if (ObjInfo.quantity == EQUIPMENT_OBJ ) ObjType = VDP_EQUIP;
	    else if (ObjInfo.quantity == PIPING_OBJ) ObjType = VDP_PIPING;
	    else if (ObjInfo.quantity == HVAC_OBJ) ObjType = VDP_HVAC;
	    else if (ObjInfo.quantity == RWAY_OBJ) ObjType = VDP_RWAY;
	    else if (ObjInfo.quantity == STRUCT_BEAM_OBJ) ObjType = VDP_BEAM;
	    else if (ObjInfo.quantity == STRUCT_PLATE_OBJ) ObjType = VDP_PLATE;
	    else if (ObjInfo.quantity == COMPARTMENT_OBJ) ObjType = VDP_COMPART;
            else  /* Nozzles & other objects can also be enabled. After
                   * implementing it in PME, they will be posted
                   */
            {
                me->transObj[i].posted = TRUE; continue;
            }
	}
        if ((me->transObj[i].ActionCode) == VDP_DEL_COMP )
            ObjInfo.quantity = COMPARTMENT_OBJ;
        __DBGpr_int ( "Quantity ", ObjInfo.quantity );


	switch( me->transObj[i].ActionCode )
	{
	    case VDP_CREATE :
	    case VDP_FRPLLST :
	    case VDP_MODIFY :
	    case VDP_REPLACE :

		/* get the corresponding Collector */
		nbAttr = nbClassAttr[ObjType];
		__DBGpr_int("NbAttr :", nbAttr );
		if ( nbAttr )
		    Coll = _MALLOC ( nbAttr, struct ACrg_coll );
		if ( Coll == NULL )
		{
		    UI_status("Error no dynamic memory");
		    return OM_E_NODYNMEM;
		}
		memcpy (Coll, TableAttr[ObjType], 
					nbAttr*sizeof(struct ACrg_coll ));
		__DBGpr_com ("Memory Allocated for Coll");
		size = sizeof( struct GRmd_env ) ;

		gr$get_module_env(  msg    = msg,
				    sizbuf = &size,
				    buffer = &MdEnv,
				    nret   = &ret_size );

		/* Change attribute types obtained from PME to ones that are
		   understood by VDS objects.  */

		if( ObjType == VDP_BEAM )
		{
	  	  /* Change attribute name beam_type to family_name.
		     Change section_name to part_num.*/
		  for(ii=0; ii < nbAttr; ii++)
		  {
		    if( strcmp(Coll[ii].name, "beam_type") == 0 )
		    {
		      strcpy( Coll[ii].name, "family_name" );
		      i_fam_beam = ii;
		    } else if( strcmp(Coll[ii].name, "sect_name") == 0 ) {
		     	   strcpy( Coll[ii].name, "part_num" );
			   i_prt_beam = ii;
		    }

		  }/* end for */
		}
                __DBGpr_int( "ObjType:", ObjType ); 

		if( ObjType == VDP_PLATE )
		{
		  /*Change attribute name plate_type to family_name.
		    Change plate_thk to part_num.*/
		  for(ii=0; ii < nbAttr; ii++)
		  {
		    if( strcmp(Coll[ii].name, "plate_type") == 0 )
		    {
		      strcpy( Coll[ii].name, "family_name" );
		      i_fam_plate = ii;
		    }
		    else if( strcmp(Coll[ii].name, "plate_thk") == 0 )
			 {
		     	   strcpy( Coll[ii].name, "part_num" );
			   i_prt_plate = ii;
			 }
		  }/* end for */
		}

                if( ObjType == VDP_EQUIP )   
                {/*Change attribute name PmDesc to n_itemdesc.*/
                  for(ii=0; ii < nbAttr; ii++)
                  {
                    if( strcmp(Coll[ii].name, "PmDesc") == 0 )
                    {
                      strcpy( Coll[ii].name, "n_itemdesc" );
                      i_desc = ii;
                    }
                  }/* end for */
                }
		
                __DBGpr_int( "ObjType:", ObjType ); 
		status =
		vd$review_params(   pMsg            = msg,
				    pComponent      = &Obj,
				    pMdEnv          = &MdEnv,
				    pList           = Coll,
				    NbParams        = nbAttr );
                __DBGpr_int( "ObjType:", ObjType ); 

		if( ObjType == VDP_BEAM )
		{/** Change the attribute names back to what they were
		  originally.*/
		  strcpy( Coll[i_fam_beam].name, "beam_type" );
		  strcpy( Coll[i_prt_beam].name, "sect_name" );
		}

		if( ObjType == VDP_PLATE )
		{/** Change the attribute names back to what they were
		  originally.*/
		  strcpy( Coll[i_fam_plate].name, "plate_type" );
		  strcpy( Coll[i_prt_plate].name, "plate_thk" );
		  Coll[i_prt_plate].desc.type = AC_ATTRIB_DOUBLE;
		  dValue = atof(Coll[i_prt_plate].desc.value.att_txt);
		  Coll[i_prt_plate].desc.value.att_exp = dValue;
		}

                if( ObjType == VDP_EQUIP )
                {/** Change the attribute name back to what it was
                  originally.*/
                  strcpy( Coll[i_desc].name, "PmDesc" );
                }

		CheckRC( status, *msg ); 
		__DBGpr_int ( "Nb Attr : ", nbAttr );

		/* 
		 * If attribute is not defined, vd$review_params overwrites
		 * the type to NOT_DEFINED.  Reset them to the default types
		 */

		break;
	    case VDP_VERSION :
		break;

	    case VDP_DELETE :
	    case VDP_DEL_COMP :
		break;
	}
	UI_status(" Preparing the ASCII file" );
	status = VDPprepareAsciiFile( msg, ObjInfo.quantity, TrRow, nbAttr, 
						AttrType[ObjType], Coll, fp );
	CheckRC( status, *msg );
        
	_FREE( Coll );
    }
    sprintf(tmpstr,"%s%s\n","POSTING_COMPLETED|",FileId );
    PRINT_FILE( fp,"%s",tmpstr );
    fflush(fp);

    /* The transaction List object should be deleted by the caller */



    for ( i =0; i < 7; i++ )
    {
    	_FREE( AttrType[i] );
	_FREE( TableAttr[i] );
    }
    fclose ( fp );
    End
    return status;
}

/*+me
  Public Message VDPtrtblcopy

  Abstract
     This method copies the Transaction list object to uptain a copy of it.
-me*/
     

method VDPtrtblcopy( IGRlong *msg;  GRobjid  *newobjid )
{
  
   IGRlong  status;
   *msg = MSSUCC;
    
   status = om$construct_and_copy( object = me,
			           obj_osnum = OM_Gw_current_OS,
				   p_objid =  newobjid ); 	

   return status;
}

/* ------------------------------------------------
 * Get the PDM part from the SrUID.  
 * SAUBY added this because of the change to sirid attribute
 * in shuttle II requirements, CR 5522.
 * ***/
static IGRstat getUIDpart( char *sirid,
	                   char *uidpart )
{
    int  retFlag = 0;
    char buf[80];
    char *p;
    int  new_style;
    char part_key[80];
    char f_part[80],f_cat[80],f_rev[80];
    int  f_key = 0;

    // arg check
    if (*sirid == 0) goto wrapup;
    if (uidpart == NULL) goto wrapup;
    *uidpart = 0;

    // set buf
    strcpy(buf,sirid);

    // determine whether sirid has part or file_key, get part or filekey
    p = strchr(buf,'-');
    if (p) {
	*p = 0;
	strcpy(part_key,buf);
	strcpy(buf,p+1);
    }

    // have part of file_key, which is it
    // new_style <file_key-seqno-1> old_style <partno-seqno>
    new_style = 0;
    p = strchr(buf,'-');
    if (p) new_style = 1;

    // set uidpart according to new style
    if (new_style) 
    {
	*f_part = 0;
	f_key = atoi(part_key);
	VDpdmGetCPRForFilekey(&f_key, f_cat, f_part, f_rev);
	if (*f_part == 0) goto wrapup;
	strcpy(uidpart,f_part);

    }
    else
    {
	strcpy(uidpart,part_key);
    }

    // done
    if (*uidpart != 0) retFlag = 1;

wrapup:
    return retFlag;
}

    

    

int     VDPpostObjectToSIR( long                *msg,
			    int                 ObjType,
    			    struct VDPtrObjList TrRow,
			    int                 nbAttr,
		            int                 *AttrType,
			    struct  ACrg_coll   *Coll,
			    FILE                *dm2_log )

{
  long                status = OM_S_SUCCESS;
  char                *inbuf=NULL, *token=NULL;
  char			Macro[20], ClassName[15], TagNum[20], SysName[20],
			SrTagNo[40], mino[31], cage[6], EqpNum[20],
			EqpPartNo[40], SrUID[30], UIDmdc[25], UIDpart[80];
  OMuword		curOs;
  int			code, i, inlen = 0, index = 0, outlen, dstat, mfail,localVar = 0 ,j;
  char			tmpstr[81], VDSobjid[10], MdCxId[25],
    				DefDirName[DI_PATH_MAX], DirName[DI_PATH_MAX];
  int			attrIndex, actualAttr, *ActCode = 0, diagCtl = 0,
                	attrcode = 0;
  char			*outbuf, *errmsg=0, FileTyp[2];
  char			srerrmsg[200], warn[210], class_name[80];
  int           	*nopost=0, *yespost=0, attravail=0, nbFiles=0, num=0, gnum=0;
  struct GRid		DefDat;
  struct ACrg_coll      DefColl;
  struct SIRRefPDMInfo  *SrRefInfo;
  int RefAttached = FALSE;

  //TLS TR 6230
  TVDpdmInfo    	pdmInfo;
  IGRchar		curFilename[257];
  IGRchar		curFilekey[128];
  IGRchar		*UIDfilekey=NULL;

  IGRchar qtyText[ 32];
  IGRchar hullApp[128];

  TGRid objID;

  SetProc ( VDPpostObjectToSIR  ); Begin
	
  UI_status(" Posting FSIs to SIR");

  for (i = 0; i<20; i++)
  {
    TagNum[i] = '\0';
    SysName[i] = '\0';
    EqpNum[i] = '\0';
    Macro[i] = '\0';
  }

  for (i = 0; i<31; i++) mino[i] = '\0';
  for (i = 0; i<6; i++) cage[i] = '\0';
  for (i = 0; i<40; i++) EqpPartNo[i] = '\0';
  SrUID[0] = '\0';

  /* Approximately 80+25 per attribute */
  inbuf = _MALLOC ( 106 * nbAttr + 100, char );

  if( inbuf == NULL )
  {
    UI_status ( "No Dynamic memory available" );
    return OM_E_ABORT;
  }

  __DBGpr_int ( "ObjType", ObjType );
  ClassName[0] = '\0';

  ex$get_cur_mod( osnum = &curOs );

  objID.osnum = curOs;
  objID.objid = TrRow.VDSobjid;

  status = om$get_classname ( objid = TrRow.VDSobjid, 
				osnum = curOs, 
				classname = class_name );


  if( !(status & 1 ))
  {
     // Object would have been deleted
     __DBGpr_com( " Object not found ! " );
     strcpy( ClassName, "" );
     FILE_PRINT ( dm2_log, " \tObject is deleted " );
     printf (" \tObject is deleted " );//ssr18may

  }

  else
  {
    __DBGpr_str( " classname ", class_name );
    FILE_PRINT( dm2_log, "\t [%s]", class_name);
    printf("\t [%s]", class_name);//ssr18may

    if ( !strcmp(class_name, "VDequipment" ) )
    {
      strcpy ( ClassName, "SrEquip" );
      attrcode = 1; // SrTagNo = equ_num
      // attrcode = 0 SrtagNo = Sys_name-tag_num
    }

    else if ( !strcmp( class_name, "VRPComp" ) )
      strcpy ( ClassName, "SrPiping" );

    else if ( !strcmp( class_name, "VRHComp" ) )
      strcpy ( ClassName, "SrHvac" );

    else if ( !strcmp( class_name, "VRRComp" ) )
      strcpy ( ClassName, "SrRway" );
    
    else if ( !strcmp( class_name, "VREquipment" ) ) // TR # 179801450
    {
      //strcpy ( ClassName, "SrPiping" ); TR # 179802035
      strcpy ( ClassName, "SrEquip" );
      attrcode = 1;
    }

    // Commented to stop posting of nozzles to SIR
	// suggested by CCB refer TR # 179801647
	//else if ( !strcmp( class_name, "VRPNozz" ) ) // TR # 179801450
      //strcpy ( ClassName, "SrPiping" );


  }

  code = VDP_POST_PLACMNT;   // 106 
  __DBGpr_int( "Code VDP_POST_PLACMNT: ", code );

  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;

  //  ActCode = &TrRow.ActionCode;
  localVar = getActionCode(TrRow.ActionCode);//CR#179801693
printf("Delete code %d %d\n",VDP_DELETE,localVar);
  ActCode = &localVar;
  //  memcpy( &inbuf[index], ActCode, sizeof(int));
  memcpy( &inbuf[index], &localVar, sizeof(int));
  inlen += sizeof(int);
  index = inlen;
  __DBGpr_int( " ActionCode",localVar );

   status = VDgetDiagCtlPar(msg, &diagCtl );
   CheckRC( status, *msg );
  status = di$give_pathname( osnum = curOs,
      			pathname = DirName );

  sprintf(DefDirName, "%s%s%s\0", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA);//CR#179801371
  status = di$translate(objname = DefDirName,
      			p_objid = &DefDat.objid,
			p_osnum = &DefDat.osnum);


   if ( DefDat.objid == NULL_OBJID)
       {
	 UI_status ( "AIM Default Data not Set.");
	 __DBGpr_com("AIM Default Data not Set. ");
	 return OM_E_ABORT;
       }

  strcpy(DefColl.name, SIR_FILE_TYP);
  status = om$send(msg = message ACrg_collect.ACget_named_attribute(msg,
							&DefColl),
      			senderid = NULL_OBJID,
			targetid = DefDat.objid,
			targetos = DefDat.osnum );
  __DBGpr_int( " FILETYPE ", DefColl.desc.value.att_exp);
   FileTyp[0] = '\0';

     if ( !(*msg&1))
     {
       //Old file//CR#179801371
       if(diagCtl == M_FILE )
	 strcpy(FileTyp, "M");//CR#179801371
       if(diagCtl == D_FILE)
	 strcpy(FileTyp, "D");
     }
     else
     {
       // NEW file
       if(DefColl.desc.value.att_exp == D_FILE)
	 strcpy(FileTyp, "D");
       else if(DefColl.desc.value.att_exp == M_FILE)
	 strcpy(FileTyp, "M");
       else if(DefColl.desc.value.att_exp == A_FILE)
	 strcpy(FileTyp, "A");
       else if(DefColl.desc.value.att_exp == DM_FILE)
	 strcpy(FileTyp, "DM");
        else
	 printf("\n Missing Filetype");
     }

    /* TR 986 check for DSP and file type, if inconststant; ERROR out */
    if((diagCtl == D_FILE) && (DefColl.desc.value.att_exp != D_FILE)|| 
        (diagCtl != D_FILE) && (DefColl.desc.value.att_exp == D_FILE)  )
    {
      FILE_PRINT(dm2_log, "\nERROR : D S P and AIM Default Data File types doesn't match, Exiting posting.");
      printf("\nERROR : D S P and AIM Default Data File types don't match, Exiting posting.");
      return OM_E_ABORT;
      //goto wrapup;
    }  

 strcpy( &inbuf[index], FileTyp );
 inlen += strlen(FileTyp) +1;
 index = inlen;
 __DBGpr_str(" filetyp ", FileTyp);

  sprintf(VDSobjid,"%d\0", TrRow.VDSobjid );
  __DBGpr_str ( " VDS objid ", VDSobjid );
   strcpy( &inbuf[index], VDSobjid );
   inlen += strlen(VDSobjid) + 1;
   index = inlen;

   status = VDPGetMdCxId( msg, curOs, MdCxId);
   CheckRC (status, *msg);

   strcpy( &inbuf[index], MdCxId );
   inlen += strlen(MdCxId) +1;
   index = inlen;

   strcpy( &inbuf[index], ClassName );
   inlen += strlen(ClassName) + 1;
   index = inlen;
  __DBGpr_str ( " ClassName ", ClassName );

   if ( !strcmp(ClassName, "" )) goto step1;
   //Added for Restore placements to delete Mdc relaions in AIM
   //Added on 22 aug 2000
   if ( nbAttr == 0) goto step1;

   for ( i =0; i < nbAttr; i++ )

   {

     if( !strcmp(Coll[i].name, "macro_name"))
     {
       strcpy(  Macro , Coll[i].desc.value.att_txt );
       __DBGpr_str( " Macro ", Macro );
       FILE_PRINT( dm2_log, "\t[%s]", Macro);
       printf("\t[%s]", Macro);//ssr18may
     }

    if( !strcmp(Coll[i].name, "tag_number"))
    {
	strcpy(  TagNum , Coll[i].desc.value.att_txt);
       __DBGpr_str( " TagNum ", TagNum);

       if(( strlen( TagNum ) == 0 ) || !strcasecmp ( TagNum, "null"))
	 //Added strcasecmp SSR 25Feb CR# 179900381
        {
          //FILE_PRINT( dm2_log, "\ntag_number is incorrect or not available");
          //printf("\nERROR : tag_number is incorrect or not available");//ssr18may
          //UI_status("tag_number is incorrect or not available");
          //return OM_E_ABORT;
          //attravail = 1; // attr mising SSR 13 Oct
        }
    }
     
    if( !strcmp(Coll[i].name, "system_name"))
    {
      strcpy(  SysName , Coll[i].desc.value.att_txt);
     __DBGpr_str( " SysName ", SysName);
     
     if( strlen( SysName ) == 0 )
      {
        //FILE_PRINT( dm2_log, "\nsystem_name is incorrect or not available");
        //printf("\nsystem_name is incorrect or not available");//ssr18may
        //UI_status("system_name is incorrect or not available");
        //return OM_E_ABORT;
        //attravail = 1; // attr mising SSR 13 Oct
      }
    }

    if( !strcmp(Coll[i].name, "mino"))
    {
      if(strcmp(class_name, "VDequipment") 
    	  && strcmp(class_name, "VREquipment"))
       {
	strcpy(  mino , Coll[i].desc.value.att_txt );
	__DBGpr_str( " mino ", mino );
	if( strlen( mino ) == 0 ) 
	{
	  FILE_PRINT( dm2_log, "\nERROR : mino is incorrect or not available");
	  printf("\nERROR : mino is incorrect or not available");//ssr18may
	  UI_status("ERROR:mino is incorrect or not available");
	  attravail = 1; // attr mising SSR 13 Oct
	}
      }
    } 
    
    if( !strcmp(Coll[i].name, "cage"))
    {
      if(strcmp(class_name, "VDequipment") 
	  && strcmp(class_name, "VREquipment"))
      {
	strcpy(  cage , Coll[i].desc.value.att_txt );
	__DBGpr_str( " cage ", cage );
	if( strlen( cage ) == 0 ) 
	{
	  FILE_PRINT( dm2_log, "\nERROR : cage is incorrect or not available");
	  printf("\nERROR : cage is incorrect or not available");//ssr18may
	  UI_status("ERROR:cage is incorrect or not available");
	  attravail = 1; // attr mising SSR 13 Oct
	}
      }
    }
     if( !strcmp(Coll[i].name, "eqp_number"))
     {
       strcpy(  EqpNum , Coll[i].desc.value.att_txt );
       __DBGpr_str( " EqpNum ", EqpNum );
       if(( strlen( EqpNum ) == 0 ) || !strcasecmp ( EqpNum, "null"))
	 //Added strcasecmp SSR 25Feb CR# 179900381
       {
         //FILE_PRINT( dm2_log, "\neqp_number is incorrect or not available");
         //printf("\neqp_number is incorrect or not available");//ssr18may
         //UI_status("eqp_number is incorrect or not available");
         //return OM_E_ABORT;
         //attravail = 1; // attr mising SSR 13 Oct
       }
     }
    
     //CR # 179900380
     if( !strcmp(Coll[i].name, "eqp_partno"))
     {
       if(!strcmp(class_name, "VDequipment") 
	   || !strcmp(class_name, "VREquipment"))
       {
	 strcpy(  EqpPartNo , Coll[i].desc.value.att_txt );
	 __DBGpr_str( "EqpPartNo ", EqpPartNo);
	 if(( strlen( EqpPartNo ) == 0 ) || !strcasecmp ( EqpPartNo, "null"))
	    {
	   FILE_PRINT( dm2_log,
	       "\nERROR : eqp_partno is incorrect or not available");
	   printf("\nERROR : eqp_partno is incorrect or not available");//ssr18may
	   UI_status("ERROR:n_itemname is incorrect or not available");
	   attravail = 1;
	 }
       }
     }

     /* read SrUID from Coll and write to buffer */
     if(! strcmp(Coll[i].name, "sirid"))
     {
       strcpy( SrUID, Coll[i].desc.value.att_txt );
       __DBGpr_str( "2 UID", SrUID );
       if(( strlen( SrUID ) == 0 ) || !strcasecmp ( SrUID, "null"))
       {
         printf("\nERROR : sirid is incorrect.");
         FILE_PRINT(dm2_log, "\nERROR : sirid is incorrect.");
	   attravail = 1;
       }
     }
     /* -----------------------------------------
      * comp_tagx and comp_path
      */
     if (!strcmp(Coll[i].name,"comp_tagx"))
     {
       VDctxGetCompTagx(&objID,Coll[i].desc.value.att_txt);
       Coll[i].desc.type = AC_ATTRIB_TEXT;
      }
     if (!strcmp(Coll[i].name,"comp_path"))
     {
       VDctxGetCompPath(&objID,Coll[i].desc.value.att_txt);
       Coll[i].desc.type = AC_ATTRIB_TEXT;
     }
   }   // end for nbattrs

   if ( attravail == 1) return OM_E_ERROR; 

   //for( i = 0; i < 80; i ++ ) SrTagNo[i] = '\0';
   SrTagNo[0] = '\0';

   if ( attrcode == 1 )
   {
     if ( strlen(EqpNum)!=0 && strcasecmp(EqpNum, "null") )
     {  
       strcpy(SrTagNo, EqpNum);
     }
     else strcpy(SrTagNo, " " );
   }

   else
   {
     if ( strlen(SysName) != 0 && strlen(TagNum)!=0 
         && strcasecmp(SysName, "null") && strcasecmp(TagNum, "null") )
     {
       strcpy(SrTagNo, SysName);
       strcat(SrTagNo, "-");
       strcat(SrTagNo, TagNum);
     }
     else strcpy(SrTagNo, " ");
   }

   //CR#179900380
   if(!strcmp(class_name, "VDequipment") 
       || !strcmp(class_name, "VREquipment"))
   {
     token = strtok(EqpPartNo, "-");
     if(token != NULL)
       strcpy(cage, token);
     token = strtok(NULL, "\n");
     if(token != NULL)
       strcpy(mino, token); 
   }
   
   
     if((strlen(cage)==0)||(strlen(cage)>5))
     {
       FILE_PRINT(dm2_log, "\n ERROR : Value for cage is incorrect"); 
       printf("\n ERROR : Value for cage is incorrect");//sssr18may
       UI_status("ERROR:Value for cage is incorrect"); 
     }
     
     if((strlen(mino)==0)||(strlen(mino)>30))
     {
       FILE_PRINT(dm2_log, "\n ERROR : Value for mino is incorrect");
       printf("\n ERROR : Value for mino is incorrect");//ssr18may
       UI_status("ERROR:Value for mino is incorrect");
     }

   /* Convert cage and mino to upper case */

   for(i=0; i<6; i++)
   {
      if(cage != NULL)
      	cage[i] = toupper( cage[i] );
   }

   for(i=0; i<31; i++)
   {
    	if(mino != NULL)
      	mino[i] = toupper( mino[i] );
   }

   
   strcpy( &inbuf[index], SrTagNo );
   inlen += strlen(SrTagNo) + 1;
   index = inlen;
   __DBGpr_str ( " SrTagNo ", SrTagNo );
   
   
   strcpy( &inbuf[index], mino );
   inlen += strlen(mino) + 1;
   index = inlen;
   __DBGpr_str ( " mino ", mino );
   FILE_PRINT( dm2_log, "\t MINO : %s", mino );
   printf("\t MINO : %s", mino );

   strcpy( &inbuf[index], cage );
   inlen += strlen(cage) + 1;
   index = inlen;
   __DBGpr_str ( " cage ", cage );
   FILE_PRINT( dm2_log, "\t CAGE : %s", cage );
   printf("\t CAGE : %s", cage );//ssr18may

   strcpy( &inbuf[index], SrUID );
   inlen += strlen(SrUID) + 1;
   index = inlen;
   __DBGpr_str ( " 3 SrUID ", SrUID );
   FILE_PRINT( dm2_log, "\t SrUID : %s", SrUID );
   printf("\nUID : %s\n", SrUID );//ssr18may

   /* -------------------------------------------
    * SIR_PE The object being posted will always
    * be int he current file so all this nonsense goes away
    */
   strcpy(UIDmdc, MdCxId);
#if 0
   /* Initialize UID MDC value to current MDCOBID */
   if(MdCxId != NULL) 
     strcpy(UIDmdc, MdCxId);
   __DBGpr_str("The UIDmdc is", UIDmdc);
   
   status = VDPGetRefFileList(  &nbFiles, &SrRefInfo);
   __DBGpr_int("The number of Reffiles are", nbFiles);
   
   if(SrUID != NULL) 
   {
  	//UIDpart = strtok(SrUID, "-");
	getUIDpart(SrUID,UIDpart);
        __DBGpr_str("SrUID is", SrUID);
        __DBGpr_str("UIDpart is", UIDpart);

	//TLS TR 6230 - need to get the filekey from the UID
	//TLS - this is parseing the UID value to get the filekey
        //UIDfilekey = strtok(SrUID, "-");
        //__DBGpr_str("UIDfilekey is", UIDfilekey);
    }
  
  /* 25 NOV 1379*/

  __DBGpr_str("UIDpart is", UIDpart);
  __DBGpr_str(" refresh->act_partid is", refresh->act_partid);
  if(strcmp(UIDpart, refresh->act_partid) != 0)
  {
    __DBGpr_com("the UIDpart and curFilekey do not match");
    // if UIDpart is not active part check ref files
    if(nbFiles == 0 )
    {
      // no ref files are attached! ERROR
      FILE_PRINT(dm2_log, "Part <%s> is not attached as reference.", UIDpart);
      printf("Part <%s> is not attached as reference.\n", UIDpart);
      status = OM_E_ERROR;
      goto wrapup;
    }
    else
    {
      for(num =0; num< nbFiles; num++)
      {
  	__DBGpr_str("SrRefInfo[num].RefPart", SrRefInfo[num].RefPart);
  	__DBGpr_str("UIDpart is", UIDpart);
        if(!strcmp(SrRefInfo[num].RefPart, UIDpart))
	{
	  RefAttached = TRUE;
	  break;
	}
      }

      if(RefAttached == FALSE)
      {
        /* required file not attachde */
        FILE_PRINT( dm2_log, "Part <%s> is not attached as a reference.",
	  			UIDpart);
	printf( "Part <%s> is not attached as a reference.\n",UIDpart);
	status = OM_E_ERROR;
	goto wrapup;
      }

      for(gnum =0; gnum<GRefSize; gnum ++)
      {
   	//TLS TR6230 - changed to filekey
	//TLS - the value in SIR_Diag_Info[gnum].PdmPart is really the filekey
	//TLS - change code to compare filekeys not parts
        //TLS 4-8-02, changed back to part id

  	__DBGpr_str("SIR_Diag_Info[gnum].PdmPart", SIR_Diag_Info[gnum].PdmPart);
        //UIDfilekey = strtok(SrUID, "-");
	//if(!strcmp(SIR_Diag_Info[gnum].PdmPart, UIDfilekey))
	if(!strcmp(SIR_Diag_Info[gnum].PdmPart, UIDpart))
	{
	  if(SIR_Diag_Info[gnum].UpdFlag == 0)
	    strcpy(UIDmdc, SIR_Diag_Info[gnum].Mdcobid);
	  if(SIR_Diag_Info[gnum].UpdFlag == 1)
	    strcpy(UIDmdc, SIR_Diag_Info[gnum].UpdMdcobid);
	  break;
	} 
      } 

    } // end else nonzero reference files are attached 
  } // end if UIDpart == actual part
#endif
   __DBGpr_str("UID MDCOBID", UIDmdc );
   __DBGpr_str("MDC in the buffer is", UIDmdc);

   strcpy( &inbuf[index], UIDmdc );
   inlen += strlen(UIDmdc) + 1;
   index = inlen;
   __DBGpr_str ( " UID mdcobid", UIDmdc );

  /* ---------------------------------------------
   * SIR_PE Add in hull_app and qty
   */
#if 0
   VDPaimFIGetHullApp(NULL,hullApp);
printf("Post Hul App %s\n",hullApp);
   strcpy( &inbuf[index], hullApp );
   inlen += strlen(hullApp) + 1;
   index = inlen;
#endif
   strcpy(qtyText,"1");
   strcpy( &inbuf[index], qtyText);
   inlen += strlen(qtyText) + 1;
   index = inlen;
 
 /* ---------------------------------------------
  * Add in the occurance placements
  */
 if ( localVar != VDP_DELETE ) //CR#179801693
  {
  memcpy( &inbuf[index], &nbAttr, sizeof(int));
  attrIndex = index;
  inlen += sizeof(int);
  index = inlen;

    actualAttr = nbAttr;
   for ( i =0; i < nbAttr; i++ )

   {
      if ( Coll[i].desc.type == AC_ATTRIB_TEXT )
      {
printf(">>> TXT ATTR %s\n",Coll[i].name);

       strcpy( &inbuf[index], Coll[i].name );
       inlen += strlen(Coll[i].name) + 1;
       index = inlen;
	__DBGpr_str( "Attrib Name", Coll[i].name );

       strcpy( &inbuf[index], Coll[i].desc.value.att_txt );
       __DBGpr_str(" Attribute Text :", Coll[i].desc.value.att_txt);
       inlen += strlen(Coll[i].desc.value.att_txt ) + 1;
       index = inlen;
      }
      else if ( Coll[i].desc.type == AC_ATTRIB_DOUBLE )
      {
printf(">>> DBL ATTR %s\n",Coll[i].name);

        strcpy( &inbuf[index], Coll[i].name );
	__DBGpr_str( "Attrib Name", Coll[i].name );
	 inlen += strlen(Coll[i].name) + 1;
	 index = inlen;

	 sprintf( tmpstr,"%lf\0", Coll[i].desc.value.att_exp );
	 __DBGpr_str ( "Attrib Double :", tmpstr );
	 strcpy( &inbuf[index], tmpstr );
	 inlen += strlen(tmpstr) + 1;
	 index = inlen;
      }
      else if ( AttrType[i] == SM_ATTRIB_INT &&
			Coll[i].desc.type != AC_ATTRIB_TYPE_NOT_DEF )
      {
printf(">>> INT ATTR %s\n",Coll[i].name);


      strcpy( &inbuf[index], Coll[i].name );
      __DBGpr_str( "Attrib Name", Coll[i].name );
      inlen += strlen(Coll[i].name) + 1;
      index = inlen;
      sprintf( tmpstr,"%lf\0", Coll[i].desc.value.att_exp );
      if(tmpstr != NULL)
      	strtok ( tmpstr,".");
      __DBGpr_str ( "Attrib Integer :", tmpstr );
      strcpy( &inbuf[index], tmpstr );
      inlen += strlen(tmpstr) + 1;
      index = inlen;
      }

      else
      {
      actualAttr--;
       __DBGpr_str(" Unknown Attribute Type for ", Coll[i].name );
       }

   }  // end for loop
   __DBGpr_int( " actualAttr ", actualAttr);
  memcpy( &inbuf[attrIndex], &actualAttr, sizeof(int));

  } // end if transc code niot delete 

 __DBGpr_int( "Total length of inbuf", inlen );
  
 step1: // SSR 13 Oct
#if 0
 dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
				     inbuf,
				  &outlen,
				  &outbuf,
				  &mfail,
				  &errmsg );
#endif
#if 1
  _FREE( inbuf );
  if (1) return OM_E_ABORT;
#endif
// printf("Posted %d %d\n",mfail,dstat);
  if( mfail )
  {
    __DBGpr_int("mfail:", mfail );
    __DBGpr_str("errmsg:", errmsg );
    status = VDgetSrError( mfail, srerrmsg );
    sprintf(warn,"%s\0", srerrmsg );
    UI_status( warn );
    FILE_PRINT( dm2_log, "\n\t%s\n", warn );
    printf("\n\t%s\n", warn );//ssr18may
    if ( strlen(errmsg ) > 63 )
      errmsg[63] = '\0';
    UI_status( errmsg );
    FILE_PRINT( dm2_log, "\t%s", errmsg );
    printf("\t%s", errmsg );//ssr18amy

    nopost = VDaimGetpostno();
   *nopost+=1;
    _FREE( inbuf );
    *msg = mfail;
    //goto wrapup;
    return OM_E_ABORT;
  }
  if(dstat )
  {
    __DBGpr_int("dstat:", dstat );
    __DBGpr_str("errmsg:", errmsg );
    if(dstat == 12345 )
    {
      UI_status("AIM connection was reset by server.");
      printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
      strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
      ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
    }
    if(!errmsg || (errmsg && !errmsg[0]))
      errmsg="No error msg but should be";
    FILE_PRINT( dm2_log, "\n\t%s", errmsg );
    printf("\n\t%s", errmsg );//ssr18may
 
    if ( strlen(errmsg ) > 63 )
      errmsg[63] = '\0';
    UI_status( errmsg );
    FILE_PRINT( dm2_log, "\n\t%s", errmsg );
    printf("\n\t%s", errmsg );//ssr18may

    nopost = VDaimGetpostno();
    *nopost+=1;

    _FREE( inbuf );
    return dstat;
  }

  yespost = VDaimGetpostyes();
 *yespost+=1;

  __DBGpr_int("dstat:", dstat );
  __DBGpr_int("mfail:", mfail );
  __DBGpr_str("errmsg:", errmsg );

wrapup :
   
  _FREE ( inbuf );
  End

  return OM_S_SUCCESS;

}


  /*New function to set the posting status in the action code CR#179801693   */
int setPostingStatus(int *pAction, int Error)
{
  int left = 0;

	// setting left value
  left = Error;
  left = left<<16;

  *pAction = *pAction & 0177777; //erase any previous posting status
  *pAction = *pAction + left; // set the present status
  return 0;
}


/* New funtion to set the action code in action code CR#179801693  */
int setActionCode(int* pAction, int value)
{

  *pAction = *pAction & 017777600000; // mask right value
  *pAction = *pAction + value; // add the present action code value
  return 0;
}

/* Function to extract the action code from action code CR#179801693       */
int getActionCode(int Action)
{
  int right = 0;
	// mask left for getting right value
  right = Action & 0177777; // octal mask
  return right;
}


/*New funtion to extract the posting status from action code CR#179801693*/
int getPostingStatus(int Action)
{
  int left = 0;
	// mask right for getting left value
  left = Action & 017777600000; // octal mask
  left = left>>16;
  return left;
}

/*This function gets the Part name from the UID
* UID is in form PartNo-PartRev-seqno
*only thing to be done here is return the firsrt part of UID.*/

int VDPGetPartFromUID( char UID, char *Part )
{
  char *token; 

  token = strtok ( &UID, "-" );
  sprintf( Part, "%s", token );
  //printf("\nVDPGetPartFromUID.Part %s", Part);


  return 0;
}

/*Given a part name, serach for the revision from diag list.
* If the diag list is empty, add the partname into the list
* also add a dummy entry for rev and mdcobid*/

int VDPGetPdmRevFromDiagList( char *PdmPart, int *ListIndex, char **PdmRev)
{
  long  status = OM_S_SUCCESS;
  int	i=0,AddFile=0;
  int	dummysz=0;

  SetProc(VDPtrTbli.I.VDPGetPdmRevFromDiagList); Begin

  __DBGpr_int("The Diagram File size is", GRefSize);

  if(GRefSize) // If diag info exists
  {
    __DBGpr_com("a diag infor exist");
    for(i=0;i<GRefSize;i++)
    {
      if(!strcmp(SIR_Diag_Info[i].PdmPart, PdmPart))
      {
   	__DBGpr_com("compare SIR_Diag_Info[i].PdmPart and PdmPart");
        *PdmRev = _MALLOC( ((strlen(SIR_Diag_Info[i].PdmRev))+1), char);
        strcpy(*PdmRev, SIR_Diag_Info[i].PdmRev);
   	__DBGpr_str("SIR_Diag_Info[i].PdmPart = ", SIR_Diag_Info[i].PdmPart);
   	__DBGpr_str("PdmPart = ", PdmPart);
        *ListIndex = i;
        //printf("\n entry found in global strivture at %d", ListIndex);
        AddFile = 1;
      }
    }

    //Create a dummy entry in SIR_Diag_Info
    if(AddFile == 0)
    {
      __DBGpr_com(" part not in global list");
      //increase the size
      SIR_Diag_Info = _REALLOC(SIR_Diag_Info, 
                               GRefSize + 1, 
                               struct SIRRefInfo);
      if( SIR_Diag_Info == NULL )
      {
        status = OM_E_NODYNMEM;
        goto wrapup;
      }
      
      //Update the Global variable
      __DBGpr_int("The Global variable is", GRefSize);
      *PdmRev = _MALLOC( ((strlen("DUMMY"))+1), char);
      strcpy(*PdmRev, "DUMMY");// dummy
      strcpy(SIR_Diag_Info[GRefSize].PdmPart, PdmPart);//PdmPart
      SIR_Diag_Info[GRefSize].PdmRev[0]='\0';
      strcpy(SIR_Diag_Info[GRefSize].PdmRev, "DUMMY");//PdmRev dunmmy
      strcpy(SIR_Diag_Info[GRefSize].Mdcobid, "DUMMY");//MDCOBID dummy
      SIR_Diag_Info[GRefSize].UpdFlag = 0;
      strcpy(SIR_Diag_Info[GRefSize].UpdRev, "DUMMY");//PdmRev dunmmy
      strcpy(SIR_Diag_Info[GRefSize].UpdMdcobid, "DUMMY");//MDCOBID dummy
      *ListIndex = GRefSize;
      GRefSize=GRefSize+1;
      __DBGpr_int("The new global is", GRefSize);
    }
  }//endd if diag info exists
  else// If diag info not exist, create
  {
    __DBGpr_com("Creating diag info ");
    
    SIR_Diag_Info = _MALLOC(2, struct SIRRefInfo);
    if(SIR_Diag_Info == NULL)
    {
      status = OM_E_NODYNMEM;
      goto wrapup;
    }
    
    dummysz = strlen("DUMMY");
    __DBGpr_int("dummysz", dummysz);

    *PdmRev = _MALLOC( (dummysz + 1), char);
    strcpy(*PdmRev, "DUMMY");// dummy
    __DBGpr_str("PdmRev", *PdmRev);

    __DBGpr_int("Global Index", GRefSize);

    SIR_Diag_Info[GRefSize].PdmPart[0]='\0';
    strcpy(SIR_Diag_Info[GRefSize].PdmPart, PdmPart);//PdmPart
    __DBGpr_str("Part entry in global is", SIR_Diag_Info[GRefSize].PdmPart);

    SIR_Diag_Info[GRefSize].PdmRev[0]='\0';
    //strcpy(SIR_Diag_Info[GRefSize].PdmRev, *PdmRev);//PdmRev dunmmy
    strcpy(SIR_Diag_Info[GRefSize].PdmRev, "DUMMY");//PdmRev dunmmy
    __DBGpr_str("Revision entry in global is", SIR_Diag_Info[GRefSize].PdmRev);
    //printf("Revision entry in global is %s\n", SIR_Diag_Info[GRefSize].PdmRev);

    SIR_Diag_Info[GRefSize].Mdcobid[0]='\0';
    //strcpy(SIR_Diag_Info[GRefSize].Mdcobid, *PdmRev);//MDCOBID dummy
    strcpy(SIR_Diag_Info[GRefSize].Mdcobid, "DUMMY");//MDCOBID dummy
    __DBGpr_str("MDC entry in global is", SIR_Diag_Info[GRefSize].Mdcobid);

    //__DBGpr_str("writing in global structure", *PdmRev);
    //strcpy(SIR_Diag_Info[GRefSize].PdmRev, "DUMMY");

    *ListIndex = GRefSize;
    //Initializing the global variable  
     GRefSize=1;
  }
  __DBGpr_int("Returning index", *ListIndex );
  __DBGpr_str("PdmPart", PdmPart);

  
  wrapup:
    End
    return status;
}


/* Function to get a list of local file names of reference files */
IGRint VDPGetRefFileList( int *nos, struct SIRRefPDMInfo **SrRefFileInfo)
{
  long status = OM_S_SUCCESS;
  char curdir[DI_PATH_MAX];
  char newdir[DI_PATH_MAX];
  GRspacenum    cur_os;
  char          dir_name[DI_PATH_MAX], ori_name[DI_PATH_MAX];
  char		RCat[128], RPart[128], RRev[128], RFile[128], *token = NULL;
  struct        GRid RefFiles;
  int j;
  char **lines, **cat_lines, **att_lines, **data;
  int cat_nos, catctr, attctr, att_nos;
  MEMptr trial;
  //TLS TR 6230
  TVDosnum	refos;
  TVDpdmInfo    pdmInfo;

  SetProc(VDPtrTbli.I.VDPGetRefFileList); Begin
  *nos = 0;
  cat_nos = 0;
  *SrRefFileInfo = NULL;
  *curdir = 0;
  /* Get current directory */
  status = di$pwd(dirname = curdir);
  __DBGpr_str("current dir %s", curdir);

/* change to refnames directory to read the list of files attached */
  ex$get_cur_mod( osnum = &cur_os );
  di$give_pathname(osnum=cur_os,pathname=dir_name);
  strcpy(ori_name, dir_name);
  strcat(dir_name,":ref:refnames");
  RefFiles.objid = NULL_OBJID;

  status = di$translate( objname=dir_name,
                        p_objid = &( RefFiles.objid ),
                        p_osnum = &( RefFiles.osnum ));
  if(RefFiles.objid == NULL_OBJID)
  {
    __DBGpr_com("ERROR : No ref files!");
    goto wrapup;
  }

  status = di$cd(dirname = dir_name);
  if(status != DIR_S_SUCCESS)
    goto wrapup;

  status = di$pwd(dirname = newdir);
  lines = NULL;
  status = di$ls(regexp = "*",
               lines = &lines,
               ptr = nos,
               options = NULL);
  __DBGpr_int(" Ref file nos", *nos);
   if(*nos) 
   *SrRefFileInfo = _MALLOC(*nos, struct SIRRefPDMInfo);


 
  for (j=0; j<*nos; j=j+1)
  {
    lines[j] = strrchr(lines[j],':' ) + sizeof(char);
    __DBGpr_str("ref file ", lines[j]);
    status=PDMGetPartInfoGivenFileName(lines[j], RCat, RPart, RRev);
   
    /* TLS TR 6230 - get the os for the ref file */
    VDosGetFileNameOS( lines[j], &refos );

    /* TLS TR 6230 - get the filekey for the ref file */
    vdpdm$GetPdmInfo(osnum = refos, pdmInfo = &pdmInfo);
    if (pdmInfo.filekey < 1)
    {
        //TLS - 02-13-02 - TR#6016 Added this print statement and set the
        //                         status to bad so we know that we couldn't
        //                         get a filekey.
        __DBGpr_com ("WE DO NOT HAVE A FILEKEY...");
        UI_status( "Failed to get Filekey...");
        status = OM_E_ABORT;
        goto wrapup;
    }
   
    __DBGpr_int ("The Filekey is", pdmInfo.filekey);

    strcpy((*SrRefFileInfo)[j].RefFileName, lines[j]);
    strcpy((*SrRefFileInfo)[j].RefCat, RCat);
    strcpy((*SrRefFileInfo)[j].RefPart, RPart);
    strcpy((*SrRefFileInfo)[j].RefRev, RRev);
    sprintf((*SrRefFileInfo)[j].RefFilekey, "%d", pdmInfo.filekey);
   
  }
 
  strcat(ori_name, ":parts");
  status = di$cd( dirname = ori_name );
  if(status != DIR_S_SUCCESS)
    goto wrapup;

  status = di$ls(regexp = "*",
                 lines = &cat_lines,
                 ptr = &cat_nos,
                 options = NULL );
  __DBGpr_int("No of Catalogs.", cat_nos);

  for(catctr = 0; catctr < cat_nos; catctr ++)
  {
    __DBGpr_str("Catalog", cat_lines[catctr]);
    /* this is full path of the catalog; so take the last value */
    di$cd( dirname = cat_lines[catctr]);
    if(status != DIR_S_SUCCESS)
      goto wrapup;

    cat_lines[catctr] = strrchr(cat_lines[catctr], ':') + sizeof(char);
    strcpy(RCat, cat_lines[catctr]);

    status = di$ls(regexp = "*",
                 lines = &att_lines,
                 ptr = &att_nos,
                 options = NULL );
    __DBGpr_int("No of Attachments.", att_nos);
    for(attctr = 0; attctr<att_nos; attctr++)
    {
      __DBGpr_str("Attachment", att_lines[attctr]);
      att_lines[attctr] = strrchr( att_lines[attctr], ':') + sizeof(char);
      token = strtok( att_lines[attctr], "!");
      strcpy(RPart, token);
      token = strtok( NULL, "\n");
      strcpy(RRev, token);
      __DBGpr_str("cat", RCat);
      __DBGpr_str("Part", RPart);
      __DBGpr_str("Revision", RRev);
      PDMi_find_cofilename(RCat, RPart, RRev, RFile);
      __DBGpr_str("File", RFile);
    }
  }

  wrapup:
    /* Change the directory to origina;l */
    di$cd(dirname = "~");
    End
    return status;
}

int VDPGetPdmRevFromDL( char *PdmPart, int *ListIndex, char **PdmRev)
{
  long 	status = OM_S_SUCCESS;
  int	dummysz=0;
  int	i=0,AddFile=0;
  char  f_part[80],f_cat[80],f_rev[80];
  int   f_key = 0;

  struct SIRRefPDMInfo	*cmpSrRefInfo = NULL;
  int			refFiles=0;

  SetProc(VDPtrTbli.I.VDPGetPdmRevFromDL); Begin

  __DBGpr_int("The Diagram File size is", GRefSize);

  if(GRefSize) // If diag info exists
  {
    __DBGpr_com("a diag list exist");
    
/*
    __DBGpr_com("make sure it is a valid DL structure before using it");
    
    //get the attached reference files
    status = VDPGetRefFileList(  &refFiles, &cmpSrRefInfo);

    //compare the diag list with the ref file list
    //and remove whats not correct.
    for(x=0; x<GRefSize; x++)
    {
	//now get the 1st ref file
	for(y=0; y<refFiles; y++)
	{
	  // now compare
	  if(!strcmp(SIR_Diag_Info[x].PdmPart, SrRefInfo[i].RefPart)) 
	 

    __DBGpr_com("now continue processing the structure");
*/
    for(i=0;i<GRefSize;i++)
    {
      //TLS 4-8-02 - check to see if the diagram list is using a filekey
      //             if so, change it to part id
      f_key = atoi(SIR_Diag_Info[i].PdmPart);
      VDpdmGetCPRForFilekey(&f_key, f_cat, f_part, f_rev);
      if(f_part[0] != '\0')
      {
	//change what's in the DL to part id 
	SIR_Diag_Info[i].PdmPart[0]='\0';
        strcpy(SIR_Diag_Info[i].PdmPart, f_part);//PdmPart
        __DBGpr_str("Part entry in global is", SIR_Diag_Info[i].PdmPart);
      }

      __DBGpr_com("comparing SIR_Diag_Info[i].PdmPart and PdmPart");
      if(!strcmp(SIR_Diag_Info[i].PdmPart, PdmPart))
      {
        __DBGpr_com("SIR_Diag_Info[i].PdmPart and PdmPart match");
	__DBGpr_str("SIR_Diag_Info[i].PdmPart = ", SIR_Diag_Info[i].PdmPart);
	__DBGpr_str("PdmPart = ", PdmPart);

        *PdmRev = _MALLOC( ((strlen(SIR_Diag_Info[i].PdmRev))+1), char);
        strcpy(*PdmRev, SIR_Diag_Info[i].PdmRev);
	__DBGpr_str("SIR_Diag_Info[i].PdmRev = ", SIR_Diag_Info[i].PdmRev);
	__DBGpr_str("PdmRev = ", *PdmRev);
        *ListIndex = i;
        //printf("\n entry found in global strivture at %d", ListIndex);
        __DBGpr_com("entry found in global structure");
        AddFile = 1;
      }
    }

    //Create a dummy entry in SIR_Diag_Info
    if(AddFile == 0)
    {
      __DBGpr_com(" part not in global list");
      //increase the size
      SIR_Diag_Info = _REALLOC(SIR_Diag_Info, 
                               GRefSize + 1, 
                               struct SIRRefInfo);
      if( SIR_Diag_Info == NULL )
      {
        status = OM_E_NODYNMEM;
        goto wrapup;
      }
      
      //Update the Global variable
      __DBGpr_int("The Global variable is", GRefSize);
      *PdmRev = _MALLOC( ((strlen("DUMMY"))+1), char);
      strcpy(*PdmRev, "DUMMY");// dummy
      strcpy(SIR_Diag_Info[GRefSize].PdmPart, PdmPart);//PdmPart
      SIR_Diag_Info[GRefSize].PdmRev[0]='\0';
      strcpy(SIR_Diag_Info[GRefSize].PdmRev, "DUMMY");//PdmRev dunmmy
      strcpy(SIR_Diag_Info[GRefSize].Mdcobid, "DUMMY");//MDCOBID dummy
      SIR_Diag_Info[GRefSize].UpdFlag = 0;
      strcpy(SIR_Diag_Info[GRefSize].UpdRev, "DUMMY");//PdmRev dunmmy
      strcpy(SIR_Diag_Info[GRefSize].UpdMdcobid, "DUMMY");//MDCOBID dummy
      *ListIndex = GRefSize;
      GRefSize=GRefSize+1;
      __DBGpr_int("The new global is", GRefSize);
    }
  }
  else// If diag info not exist, create
  {
    __DBGpr_com("Creating diag info ");
    SIR_Diag_Info = NULL;
    SIR_Diag_Info = _MALLOC(2, struct SIRRefInfo);
    if(SIR_Diag_Info == NULL)
    {
      status = OM_E_NODYNMEM;
      goto wrapup;
    }
    
    dummysz = strlen("DUMMY");
    __DBGpr_int("dummysz", dummysz);

    *PdmRev = _MALLOC( (dummysz + 1), char);
    strcpy(*PdmRev, "DUMMY");// dummy
    __DBGpr_str("PdmRev", *PdmRev);

    __DBGpr_int("Global Index", GRefSize);

    SIR_Diag_Info[GRefSize].PdmPart[0]='\0';
    strcpy(SIR_Diag_Info[GRefSize].PdmPart, PdmPart);//PdmPart
    __DBGpr_str("Part entry in global is", SIR_Diag_Info[GRefSize].PdmPart);

    SIR_Diag_Info[GRefSize].PdmRev[0]='\0';
    //strcpy(SIR_Diag_Info[GRefSize].PdmRev, *PdmRev);//PdmRev dunmmy
    strcpy(SIR_Diag_Info[GRefSize].PdmRev, "DUMMY");//PdmRev dunmmy
    __DBGpr_str("Revision entry in global is", SIR_Diag_Info[GRefSize].PdmRev);
    //printf("Revision entry in global is %s\n", SIR_Diag_Info[GRefSize].PdmRev);

    SIR_Diag_Info[GRefSize].Mdcobid[0]='\0';
    //strcpy(SIR_Diag_Info[GRefSize].Mdcobid, *PdmRev);//MDCOBID dummy
    strcpy(SIR_Diag_Info[GRefSize].Mdcobid, "DUMMY");//MDCOBID dummy
    __DBGpr_str("MDC entry in global is", SIR_Diag_Info[GRefSize].Mdcobid);

    //__DBGpr_str("writing in global structure", *PdmRev);
    //strcpy(SIR_Diag_Info[GRefSize].PdmRev, "DUMMY");

    *ListIndex = GRefSize;
    //Initializing the global variable  
     GRefSize=1;
  }
  
  __DBGpr_int("Returning index", *ListIndex );
  __DBGpr_str("PdmPart", PdmPart);

  wrapup:
	End	
  	return status;
};

/*function to Update Diag list in fact this is the global structure to update */

IGRint VDPUpdateDiaglist( FILE *dm2_log )
{
  long status = OM_S_SUCCESS, msg=MSSUCC;

  struct GRid       *list = NULL;
  struct GRid        EnabListId;

  struct ACrg_coll	*Coll = NULL;
  struct GRmd_env	MdEnv;
  struct SIRRefPDMInfo	*SrRefInfo = NULL;
  Tret_struct rs;
  IGRchar		cur_filedescr[OM_K_MAXOSNAME_LEN];
  IGRchar		class_name[80], *temp=NULL, PdmPart[128];
  IGRchar		*PdmRev=NULL, *RefMdcObid=NULL;
  IGRchar		*SrFileName = NULL;
  IGRchar		SrPart[128],UIDPart[128];
  IGRchar		SrUID[128];
  int			notUsed,ret_msg;	
  IGRchar		AttrName[128], SrRefPart[128], SrRefRev[128];
  int 			nbDiagFiles=0,j=0, nbRefIndex=0;
  int			objcount, objctr, size,ret_size, nbObjs;
  int			DiagIndex=0, nbFiles=0, i=0, nbDiagSize=0;
  OMuword               curOs;
  struct GRobj_env      *listObjs = NULL;
  //TLS TR 6230
  TVDpdmInfo          	pdmInfo;
  int			refFiles=0;
  char			filekey[128], catalog[80], part[80], rev[80];
  int			iFilekey=0;
  IGRstat 		sts;

  IGRint retFlag = OM_E_ABORT;

  SetProc( VDPtrTbli.I. VDPUpdateDiaglist); Begin
  SrUID[0]='\0';

  /* Get the attached reference list for the active file*/
  status = VDPGetRefFileList(  &nbFiles, &SrRefInfo);
  __DBGpr_int("Ref files are %d", nbFiles);
  refFiles = nbFiles;
  __DBGpr_int("refFiles", refFiles);

  if(nbFiles == 0)
  {
    __DBGpr_com("No reference files attached.");
    retFlag = OM_S_SUCCESS;
    goto wrapup;
  }
  /* Get the Reference PDM File Info */

  for(i=0; i<nbFiles; i++)
  {  
    __DBGpr_int("The Reference file name found at", i); 
    __DBGpr_str("The Reference file name is %s", SrRefInfo[i].RefFileName); 
    __DBGpr_str("REF CATALOG NAME is", SrRefInfo[i].RefCat);
    __DBGpr_str("REF PART NUMBER is", SrRefInfo[i].RefPart);
    __DBGpr_str("REF PART REVISION is", SrRefInfo[i].RefRev);
    __DBGpr_str("REF PART FILEKEY is", SrRefInfo[i].RefFilekey);
  } 
  
  /* Instead of scanning whole Onject Space, just get Eabled list and 
   *  work with It */
  ex$get_cur_mod( osnum = &curOs );
  status = VDPGetEnabledListId ( &msg, curOs, &EnabListId );
  CheckRC( status, msg );
  
  if(EnabListId.objid == NULL_OBJID )
  {
    printf("\n failed to get EnabListId.");
    goto wrapup;
  }
  __DBGpr_obj( "Enabled List Id", EnabListId ); 
  
  /* Get all the PME Enabled OBJID's */ 
  status = om$send ( msg = message VDPenabObj.VDPgetPMenabledList (
				&msg,
				&nbObjs,
				&listObjs ),
      		senderid = NULL_OBJID,
		targetid = EnabListId.objid,
		targetos = EnabListId.osnum );
  __DBGpr_int( "No of objects located", nbObjs );
  __CheckRC( status, msg, "VDPgetPMenabledList", wrapup );
  
  if (nbObjs == 0 )
  {
    __DBGpr_com("No objects found in Enabled List");
    retFlag = OM_S_SUCCESS;
    goto wrapup;
  } 
  
  for( objctr  = 0; objctr < nbObjs; objctr = objctr+1)
  {
    __DBGpr_obj ( "object", listObjs[objctr].obj_id);
        //Get FSI attribute value for the given objid				
    __DBGpr_com ("Initializing Coll"); 
    size = sizeof( struct GRmd_env );
    gr$get_module_env( msg = &msg,
			sizbuf = &size,
			buffer = &MdEnv,
			nret = &ret_size ); 
    
    memset(&rs,0,sizeof(Tret_struct));
    strcpy(AttrName, "sirid");
    status = om$send(msg = message VDSroot.ACgive_db_structure(&ret_msg,
	  					&notUsed,
						AttrName,
						&rs,
						&MdEnv),
			senderid = NULL_OBJID,
			targetid = listObjs[objctr].obj_id.objid,
			targetos = listObjs[objctr].obj_id.osnum); 
    if (!(status & ret_msg & 1))
    {
      printf("ACgive_structure failed\n");
      continue;
    } 
    
    __DBGpr_str("The UID value is %s", rs.var.text_st.text_string);
    strcpy(SrUID, rs.var.text_st.text_string);
    strcpy(UIDPart, SrUID);
    temp = strtok(UIDPart, "-");
    //PdmPart[0]='\0';
    //sprintf(PdmPart, "%s", temp);
    filekey[0]='\0';
    sprintf(filekey, "%s", temp);
    __DBGpr_str("temp", temp ); 
    __DBGpr_str("filekey from UID", filekey ); 

    iFilekey = atoi(filekey);
    __DBGpr_int("iFilekey", iFilekey ); 

    catalog[0]  = '\0';
    part[0]     = '\0';
    rev[0]      = '\0';

    //Get the part id from the filekey in the UID
    sts = VDpdmGetCPRForFilekey(&iFilekey, catalog, part, rev);

    __DBGpr_str("Catalog from filekey", catalog ); 
    __DBGpr_str("Part from filekey", part ); 
    __DBGpr_str("Rev from filekey", rev ); 

    PdmPart[0]='\0';
    sprintf(PdmPart, "%s", part);
    __DBGpr_str("PdmPart", PdmPart ); 
    
    /* TLS - Added to get the filekey for active part */
    vdpdm$GetPdmInfo(osnum = curOs, pdmInfo = &pdmInfo);
    if (pdmInfo.filekey < 1)
    {
        //TLS - 02-13-02 - TR#6016 Added this print statement and set the
        //                         status to bad so we know that we couldn't
        //                         get a filekey.
        __DBGpr_com ("WE DO NOT HAVE A FILEKEY...");
        UI_status( "Failed to get Filekey...");
        status = OM_E_ABORT;
        goto wrapup;
    }
   
    __DBGpr_int ("The Filekey for active part is", pdmInfo.filekey);

    //TLS TR 6230 - replaced with filekey
    //TLS 4-8-02 Decided to leave it partid
    strcpy(SrPart, refresh->act_partid);
    //sprintf(SrPart, "%d", pdmInfo.filekey);
    __DBGpr_str("Active Part is", SrPart);

    __DBGpr_com("Comparing PdmPart and SrPart");
/* ----------------------------------------------
 * ah - This really should check catalog as well
 *      Parts can be the same especially during testing
 */
    if(!strcmp(PdmPart, SrPart)) 
    {
      __DBGpr_com("Part from UID and Active Part are same");
      continue;
    }
    __DBGpr_int("nbFiles", nbFiles);

    //__DBGpr_str("REF PART FILEKEY is", SrRefInfo[0].RefFilekey);
    __DBGpr_str("PdmPart", PdmPart ); 

    PdmRev = NULL;
    //status = VDPGetPdmRevFromDiagList( PdmPart, &DiagIndex, &PdmRev);
    status = VDPGetPdmRevFromDL(PdmPart, &DiagIndex, &PdmRev);

    __DBGpr_str("PdmPart", PdmPart ); 
    __DBGpr_int("DiagIndex", DiagIndex ); 
    
    __DBGpr_str("After VDPGetPdmRevFromDL, Rev", PdmRev);

    nbRefIndex=0;
    SrRefPart[0]='\0';

    //Run the loop thru the reflist to get the revision
    __DBGpr_int("nbFiles", nbFiles);
    __DBGpr_int("refFiles", refFiles);

    for(j=0; j<refFiles; j++)
    {
      //TLS TR 6230 - replaced with filekey 
      //TLS 4-8-02, Change backed to part id

      //if(!strcmp(PdmPart, SrRefInfo[j].RefPart))
      //__DBGpr_com("comparing PdmPart and RefFilekey");
      __DBGpr_com("comparing PdmPart and RefPart");
      __DBGpr_int("j", j);
      //__DBGpr_str("PdmPart (filekey) from UID", PdmPart ); 
      __DBGpr_str("PdmPart", PdmPart ); 
      //__DBGpr_str("REF PART FILEKEY is", SrRefInfo[j].RefFilekey);
      __DBGpr_str("REF PART is", SrRefInfo[j].RefPart);

      //if(!strcmp(PdmPart, SrRefInfo[j].RefFilekey))
      if(!strcmp(PdmPart, SrRefInfo[j].RefPart))
      {
        //__DBGpr_com("PdmPart and RefFilekey match");
        __DBGpr_com("PdmPart and RefiPart match");
	strcpy(SrRefPart, SrRefInfo[j].RefPart);	
	strcpy(SrRefRev, SrRefInfo[j].RefRev);	
	nbRefIndex=j;
	break;
      }
    } 
    
    __DBGpr_com("checking length of SrRefPart");
    if(strlen(SrRefPart)==0)
    {
      __DBGpr_com("No Reference file matched with UID Part value");
      continue;
    }
    __DBGpr_str("For the Reference File the info is...", SrRefInfo[nbRefIndex].RefFileName);

    __DBGpr_com("comparing PdmRev and SrRefRev");
    __DBGpr_str("PdmRev", PdmRev);
    __DBGpr_str("SrRefRev", SrRefRev);
    if(strcmp(PdmRev, SrRefRev))
    {
      __DBGpr_com("Revisions mismatch");
      status = VDPGetMdcobidFromRefPart(SrRefInfo[nbRefIndex].RefFileName, &RefMdcObid);
      if(RefMdcObid) 
	__DBGpr_str("Referece mdc is %s", RefMdcObid);
      __DBGpr_str("PdmRev", PdmRev);
      //printf("PdmRev = <%s>\n", PdmRev);
      if(!strcmp(PdmRev,"DUMMY") )
      {
	__DBGpr_com("Updateing the diag list");
	FILE_PRINT(dm2_log, "\nUpdating MDC Placement Relations for object <%d>",listObjs[objctr].obj_id.objid); 
	//printf("\nUpdating MDC Placement Relations for object <%d>\n",listObjs[objctr].obj_id.objid); 
	__DBGpr_int("Updating MDC Placement Relations for object ",listObjs[objctr].obj_id.objid); 
	status = VDPUpdatePlacMdcReln( SrUID, RefMdcObid);
	if(status != 0)
	{
	  if(status == 45)
	  {
	    FILE_PRINT(dm2_log, "\nObject<%d> was not found in attached 2D MDC,Deleted existing relation.", listObjs[objctr].obj_id.objid); 
	    printf("\nObject<%d> was not found in attached 2D MDC,Deleted existing relation.", listObjs[objctr].obj_id.objid); 
	    VDPPmeUpdate(&msg,listObjs[objctr].obj_id,listObjs[objctr].obj_id );
	  }
	  else if(status == 21)
	  {
	    FILE_PRINT(dm2_log, "\nObject<%d> is not related to Current MDC.", listObjs[objctr].obj_id.objid);
	    //printf("\nObject<%d> is not related to Current MDC.\n", listObjs[objctr].obj_id.objid);
	    __DBGpr_int("Object is not related to Current MDC", listObjs[objctr].obj_id.objid);
	    VDPPmeUpdate(&msg,listObjs[objctr].obj_id,listObjs[objctr].obj_id );
	  }
	  else
	  {
	    FILE_PRINT(dm2_log, "\nCouldnot update MDC Placement relation in AIM for object<%d>", listObjs[objctr].obj_id.objid);
	    printf("\nCouldnot update MDC Placement relation in AIM for object<%d>", listObjs[objctr].obj_id.objid);
	    VDPPmeUpdate(&msg,listObjs[objctr].obj_id, listObjs[objctr].obj_id );
	    /* SSR 10 AUG if 2D relation is deleted; write the error in translog */
	  }
	}
      }

      if(SIR_Diag_Info)
      {
	__DBGpr_int("Glogal Index", DiagIndex);
	strcpy(SIR_Diag_Info[DiagIndex].UpdRev, SrRefRev);
	strcpy(SIR_Diag_Info[DiagIndex].UpdMdcobid, RefMdcObid);
	SIR_Diag_Info[DiagIndex].UpdFlag = 1;
      }					
    }//Revision mismatch					

    __DBGpr_int("The Global Diagram size is %d", GRefSize);

    if(GRefSize == 0 )
    {
      __DBGpr_com("No SIR_Diag_Info.");
      retFlag = OM_S_SUCCESS;
      goto wrapup;
    }

   /* for(nbDiagFiles = 0; nbDiagFiles<GRefSize; nbDiagFiles++ )
    {
      __DBGpr_str("DIAG.PART %s", SIR_Diag_Info[nbDiagFiles].PdmPart );
      __DBGpr_str("DIAG.REV %s", SIR_Diag_Info[nbDiagFiles].PdmRev );
      __DBGpr_str("DIAG.MDCID %s", SIR_Diag_Info[nbDiagFiles].Mdcobid );
    }*/ 
  }// end for loop of objects in enabled list
  retFlag = OM_S_SUCCESS;

wrapup:
  if(list) _FREE(list);

  /* ---------------------------------------------
   * Sorry but this is an arugment and I don't see how you close
   * it here
   */
  // if(dm2_log) fclose(dm2_log);

  if(SrRefInfo) _FREE(SrRefInfo);
  if(listObjs) _FREE(listObjs);
  End
  return retFlag;
}

/* New function for SIR
 * Search the object space
 * if Attribute FSI = TRUE for VDequipment and VRequipment,
 * object can be enabled
 * add the eligible object to PMEenabled list if the object is new to list
 * */

long VDPEnableFSIs( FILE *dm2_log, struct GRid object, char *uid )
{ 

  IGRlong             msg = 1, status = OM_S_SUCCESS;
  OMuword             curOs;
  struct GRid         EnabListId;
  IGRint              i, nbObjs = 0;
  struct GRobj_env    *listObjs = NULL;
  struct GRmd_env     MdEnv;
  int                 size, ret_size, diagCtl;
  struct ACrg_coll    Coll;
  IGRchar sirid[128];
 
  SetProc (VDPCmdEnab.VDPEnableFSIs); Begin
  msg=MSSUCC;

  /* Get the Enabled List ID */

  EnabListId.objid = NULL_OBJID;
  __DBGpr_obj("Checking for Object ", object);
  if( uid )
    __DBGpr_str("Object has uid", uid);
  if ( uid == NULL )
  {
    /* UID can be NULL if FSI is placed in 3D file */
    __DBGpr_com("UID is NULL ");
    status = VDPPmeEnable( &msg, object, NULL);
    goto wrapup;
  }

  ex$get_cur_mod( osnum = &curOs ); 
  status = VDPGetEnabledListId ( &msg, curOs, &EnabListId );
  __CheckRC( status, msg, "VDPGetEnabledListId", wrapup );
  if(EnabListId.objid == NULL_OBJID)
  {
    status = VDPPmeEnable( &msg, object, NULL);
    goto wrapup;
  }
  __DBGpr_obj( "Enabled List Id", EnabListId );

  /* Get all the PME Enabled OBJID's */

  status = om$send ( msg = message VDPenabObj.VDPgetPMenabledList (
                                                &msg,
                                                &nbObjs,
                                                &listObjs ),
                     senderid = NULL_OBJID,
                     targetid = EnabListId.objid,
                     targetos = EnabListId.osnum );
  
  __DBGpr_int( "No of objects located", nbObjs );
  __CheckRC( status, msg, "VDPgetPMenabledList", wrapup ); 

  if( nbObjs == 0 )
  {
    status = VDPPmeEnable( &msg, object, NULL );
    goto wrapup;
  }
  
  size = sizeof( struct GRmd_env ); 
  gr$get_module_env( msg = &msg,
                      sizbuf = &size,
                      buffer = &MdEnv,
                      nret = &ret_size );
  //Coll = (struct ACrg_coll *) malloc(sizeof(struct ACrg_coll)*1); 
  //Coll = _MALLOC ( 1, struct ACrg_coll );
  
  //if (Coll == NULL)
  //{
  //  UI_status("ERROR: No Dynamic memory");
  //  return OM_E_NODYNMEM;
  //}
  strcpy( Coll.name, "sirid" );
  Coll.desc.type = AC_ATTRIB_TEXT;
  Coll.desc.value.att_txt[0] = '\0';

  for(i=0; i<nbObjs; i++)
  {
    __DBGpr_obj("querying obj", listObjs[i].obj_id);
    if(listObjs[i].obj_id.objid == object.objid)
    {
      __DBGpr_com("Object already Enabled.");
      goto wrapup;
    }
    status = vd$review_params ( pMsg = &msg,
                                pComponent = &listObjs[i].obj_id,
                                pMdEnv = &MdEnv,
                                pList = &Coll,
                                NbParams = 1 );
    if(msg == AC_ATTRIB_TYPE_NOT_DEF)
    {
      __DBGpr_com("AC_ATTRIB_TYPE_NOT_DEF" );
      continue;
    } 
    if(strlen(Coll.desc.value.att_txt) ==0)
    {
      __DBGpr_com("couldnot get value of sirid");
      continue;
      //goto wrapup;
    }
    __DBGpr_str("uid is ", Coll.desc.value.att_txt);
    if(!strcmp(uid, Coll.desc.value.att_txt))
    {
      /* Found a duplicate.
      *  Check if file is of 2D
      *  For a 2D file, genetare UID and modify attribute
      */
      status = VDgetDiagCtlPar( &msg, &diagCtl );
      if(diagCtl != D_FILE)
      {
        FILE_PRINT(dm2_log,"\nERROR : Duplicate sirid; Objects %d and %d have same uid.",object.objid, listObjs[i].obj_id.objid);
        break;
      }
      VDPaimGetNextSirid(NULL_OSNUM,1,sirid);

      /* Set UID value for the Placment object */
      strcpy( Coll.desc.value.att_txt, sirid );
      strcpy( Coll.name, "sirid" );
      Coll.desc.type = AC_ATTRIB_TEXT;

      status = VDmodUsrAttrs(&msg, object,&MdEnv,1,&Coll);
      FILE_PRINT(dm2_log, "\nObjects <%d> and <%d> had same uid; Uid generated for object <%d>.", object.objid, listObjs[i].obj_id.objid, object.objid);
      printf("\nObjects <%d> and <%d> had same uid; Uid generated for object <%d>.", object.objid, listObjs[i].obj_id.objid, object.objid);
      break;

    }
  }
  //if(DupUid==1)
  //  goto wrapup;

  status = VDPPmeEnable( &msg, object, NULL);
  
  wrapup:

   //if(Coll) _FREE(Coll);
    End
    return status;
}
/* ----------------------------------------------
 * 27 Feb 2004 - Art
 * The code was still enabled when delivered to Avondale
 * as part of the posting enhancements.
 * It's a bit confusing because it's called after the
 * posting takes place.  I think it was bing used to validate
 * sirid's that may have been copied.
 *
 * In any event, for lhar the diagram/model dependency
 * has been rewritten.  So I am going to not call
 * this routine anymore and see what happens.
 */
int CheckUid( IGRlong *msg, FILE *dm2_log)
{
  OMuword     curOs;
  TACrg_coll  SridColl, RefColl, FileColl, RefSizeColl;
  TGRid       *list=NULL, CollId, DirId, DefCollId, RefCollId;
  TGRmd_env   MdEnv;
  IGRlong     retmsg;
  IGRchar     class_name[80], exp[20];
  IGRchar     DirName[DI_PATH_MAX];
  IGRchar     CollName[DI_PATH_MAX];
  IGRint      j,  size, objcount=0 , objctr;
  IGRint      ret_size, nbRefNo;
  IGRint      status=OM_S_SUCCESS, FSI = -1;
  IGRint      CreateDiagramList, DupUID=0;
  IGRint      k=0;
  TGRid       AttId;
  TGRobj_env  AttrObjEnv;
  IGRchar filen[80];

  TVDpdmInfo curPdmInfo;
  TVDpdmInfo siridPdmInfo;
  IGRchar    sirid[128];
  IGRint     siridFileKey;

  TGRid   objID;
  IGRchar mino[128];
  IGRchar cage[128];
  IGRchar comp_code[128];
  IGRint  isNotFSI;

  IGRstat retFlag = OM_E_ABORT;

  //Set Flag to FALSE
  SetProc(VDPquerydm2.I.CheckUid); Begin
  CreateDiagramList = 0;
  DirName[0] = '\0';
  CollName[0] = '\0';
  *msg = MSSUCC;

  /* Get the current file information */
  ex$get_cur_mod( osnum = &curOs );
  VDpdmGetPdmInfo(curOs,&curPdmInfo);

  FILE_PRINT( dm2_log, "\n\tChecking Uid of ISDP objects");

  //Get Objects in the Object Space
  status = VDobjInActiveSpace (msg, &objcount, &list, OPP_VDSroot_class_id);
  CheckRC ( status, *msg );

  __DBGpr_int( "objcount", objcount);

  if (objcount == 0)
  {
    __DBGpr_com("No Objects in the Active Space.");
    goto wrapup;
  }

  for( objctr  = 0; objctr < objcount; objctr = objctr+1)
  {
    __DBGpr_int ( "object", list[objctr].objid );

    //Get Object Class Name
    status = om$get_classname( objid = list[objctr].objid,
                               osnum = list[objctr].osnum,
                               classname = class_name );

    __DBGpr_str( " class_name", class_name);

    //Check FSI and Uid for only VDequipment and VRequipment classes
    if( !strcmp(class_name, "VDequipment") ||
        !strcmp(class_name, "VREquipment") ||
        !strcmp(class_name, "VRPComp") ||
        !strcmp(class_name, "VRRComp") ||
        !strcmp(class_name, "VRHComp") )
    {
      /* ----------------------------------------
       * AIM_PE The routines for testing FSI give spurious
       * warnings if the item does not have cage or mino
       * at least the ones at Intergraph do.
       *
       * Filter out objects without mino or cage and see what happens
       */
      if (strcmp(class_name, "VDequipment") &&
          strcmp(class_name, "VREquipment"))
      {

        objID = list[objctr];
        VDobjGetTxtAtr(NULL,&objID,"comp_code",comp_code);
        if (!strcmp(comp_code,"dangle")) 
        {
          /* printf("Filtered dangle\n"); */
          continue;
        }
      }

      //Prepare the expression for querying
      exp[0] = '\0';
      __DBGpr_str("classes are", class_name);
      if( !strcmp(class_name, "VDequipment") )
        strcpy( exp, "SA_EXP:FSI_equip" );
      if( !strcmp(class_name, "VREquipment") )
        strcpy( exp, "SA_EXP:FSI_equip" );
      if( !strcmp(class_name, "VRRComp") )
        strcpy( exp, "SA_EXP:FSI_rway" );
      if( !strcmp(class_name, "VRPComp") )
        strcpy( exp, "SA_EXP:FSI_pipe" );
      if( !strcmp(class_name, "VRHComp") )
        strcpy( exp, "SA_EXP:FSI_hvac" );

      size = sizeof( struct GRmd_env );

      gr$get_module_env( msg = msg,
                         sizbuf = &size,
                         buffer = &MdEnv,
                         nret = &ret_size );

      /* Get FSI from Smart table */
      AttId.objid = list[objctr].objid;
      AttId.osnum = list[objctr].osnum;
      AttrObjEnv.obj_id = AttId;
      AttrObjEnv.mod_env = MdEnv;
      status = vdsa$GetStruct( objOE = &AttrObjEnv,
                               name = exp,
                               jnt = &FSI );
      __DBGpr_obj("Querying smart FSI for object",list[objctr]);
      __DBGpr_int("FSI value is", FSI);

      if(!status)
      {
        FILE_PRINT(
          dm2_log, 
          "\nNo entry of object %d found in database table <static_additional> for expression <%s>.", 
          list[objctr].objid, exp);
        continue;
      }
      if( FSI == 1 )
      {
        //Get the Uid attribute of the object
        strcpy( SridColl.name, "sirid" );
        SridColl.desc.type = AC_ATTRIB_TEXT;
        strcpy ( SridColl.desc.value.att_txt, "" );

        status = vd$review_params ( pMsg = msg,
                                    pComponent = &list[objctr],
                                    pMdEnv = &MdEnv,
                                    pList = &SridColl,
                                    NbParams = 1 );

        CheckRC (status, *msg);
/* ----------------------------------------------
 * Want to verify that any existing sirid belongs to
 * the current cat.part and was not generated from
 * an attached diagram file.  This is mainly part of the
 * posting enhancement process but is also a good
 * error check against copying attributes from objects in
 * a reference file
 */
  strcpy(sirid,SridColl.desc.value.att_txt);
  if (*sirid)
  {
    siridFileKey = atoi(sirid);
    if (siridFileKey != curPdmInfo.filekey)
    {
      VDpdmGetCPRForFilekey(&siridFileKey,
                             siridPdmInfo.catalog,
                             siridPdmInfo.part,
                             siridPdmInfo.rev);
      if (strcmp(curPdmInfo.catalog,siridPdmInfo.catalog) ||
          strcmp(curPdmInfo.part,   siridPdmInfo.part)) 
      {
        /* --------------------------------------
         * Whack it
         * Also need to delete out of aim enabled items
         * and the transaction list if one exists
         */
        *SridColl.desc.value.att_txt = 0;
      }
    }
  }
/* ----------------------------------------------
 * And back to the regulary scheduled abortion
 */
        if(strlen(SridColl.desc.value.att_txt) ==0)
        {

          //Check the ISDP Design File Type
          /* Get the file type from collctor */
          /* Prepare the collector name */
          status = di$give_pathname(  osnum           = curOs,
                                      pathname        = DirName );
          __CheckRC( status, 1, "di$give_pathname", wrapup );
          __DBGpr_str( "Path name", DirName );
          strcat( DirName, SIR_GLOBAL_DIR );
          status = di$translate ( objname = DirName,
                                  p_objid = &DirId.objid,
                                  p_osnum = &DirId.osnum ) ;

          __DBGpr_obj( "Dir Id", DirId );
          /* Verify the SIR directory exists  */
          if ( status != DIR_S_SUCCESS )
          {
            di$report_error( sts = status ) ;
            printf("\n Default Data not Set");
            goto    wrapup;
          }
          sprintf( CollName, "%s%s", DirName, SIR_REQ_DATA );
          __DBGpr_str( "Collector name", CollName );

          status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &DefCollId );
          __DBGpr_obj( " Collector Id ", DefCollId );

          strcpy( FileColl.name, SIR_FILE_TYP );
          FileColl.desc.type = AC_ATTRIB_DOUBLE;
          FileColl.desc.value.att_exp = 0.0;
          status = om$send(msg = message ACrg_collect.ACget_named_attribute
                                                   ( msg, &FileColl),
                           senderid = NULL_OBJID,
                           targetid = DefCollId.objid,
                           targetos = DefCollId.osnum);
          __DBGpr_int( "FILE Type ", FileColl.desc.value.att_exp );

/* ----------------------------------------------
 * SIR_PE Changed D_FILE to DM_FILE
 */
          if ( FileColl.desc.value.att_exp == DM_FILE ||
            FileColl.desc.value.att_exp == A_FILE )
          {

            VDPaimGetNextSirid(NULL_OSNUM,1,sirid);
            if (*sirid == 0)
	    {
            	__DBGpr_com("Failed to get UID");
		UI_status( "Failed to get UID...");
	    	status = OM_E_ABORT;		       
		goto wrapup;
	    }	
            /* Set UID value for the Placment object */
            strcpy( SridColl.desc.value.att_txt, sirid );
            strcpy( SridColl.name, "sirid" );
            SridColl.desc.type = AC_ATTRIB_TEXT;

            status = VDmodUsrAttrs(msg,list[objctr],&MdEnv,1,&SridColl);
          }
          else
          {
            //Can't placee New FSIs in a 3D File
            printf("\nERROR : UID Can't be set for 3D");
          }

        } // UID not available
        else
        {
          /* Check if active file is owner of Placement */
/* ----------------------------------------------
 * SIR_PE
 * Don't create this list anymore because the whole
 * notion of linking to sirid in a diagam file has gone
 * bye bye
 */
#if 0
          CreateDiagramList = 1;  /* This should be corrected */
#endif
          strcpy(sirid, SridColl.desc.value.att_txt);
          __DBGpr_str("found sirid", sirid);
        }

        /* --------------------------------------
         * This seems kind of bad if you happened to be
         * in a M or ASM file with no assigned sirid
         * this get's called with the previous sirid
         */
        status = VDPEnableFSIs( dm2_log, list[objctr], sirid );
        CheckRC( status, *msg );

     }// end if FSI == TRUE
     else
     {
       FILE_PRINT(dm2_log,"\nFSI is NULL or FALSE for [%d]\n",list[objctr].objid);
       //printf("\n FSI is NULL for <%d>", list[objctr].objid);
     }

   }//End if class_name

  }//End of for loop

  //Check the flag to crete SIR_DIAG_LIST
  if(CreateDiagramList == 1)
  {
   /* get directory path name */

   status = di$give_pathname( osnum = curOs, pathname = DirName );
   __CheckRC( status, 1,"di$give_pathname", wrapup );
   __DBGpr_str( "Path name", DirName );
   strcat( DirName, SIR_GLOBAL_DIR );
   strcat( DirName, SIR_DIAG_LST );
   __DBGpr_str( "Directory name", DirName );

   /* Get the Directory Id if it is already created */
   status = di$translate ( objname = DirName,
                           p_objid = &DirId.objid,
                           p_osnum = &DirId.osnum ) ;

   __DBGpr_obj( "Dir Id", DirId );

   /*A create SIR_DIAG_LST if it does not exist     */
   if ( status != DIR_S_SUCCESS )
   {
     DirId.objid = NULL_OBJID;
     status = di$mkdir( dirname = DirName,
                        p_dirid = &DirId.objid,
                        p_osnum = &DirId.osnum );
     __DBGpr_obj( "Dir Id", DirId );

     if( status != DIR_S_SUCCESS )
     {
       di$report_error( sts = status ) ;
       goto    wrapup;
     }
   }

   sprintf( CollName, "%s:Files", DirName );
   __DBGpr_str( "Collector name", CollName );

   status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &CollId );
   CheckRC(status, *msg);
   /* set up the coll values */
   strcpy( RefSizeColl.name, SIR_REF_SIZE );
   RefSizeColl.desc.type = AC_ATTRIB_DOUBLE;
   RefSizeColl.desc.value.att_exp = 0.0 ;

   if(CollId.objid == NULL_OBJID)
   {
     status = VDgetVdCollId ( msg, CollName, TRUE, TRUE, &CollId );
     __CheckRC( status, *msg, "VDgetVdCollId", wrapup );
     __DBGpr_obj( "Collector Id", CollId );

   status = om$send(msg = message ACrg_collect.ACset_list_attribute
       					( msg, 1, &RefSizeColl),
                          senderid = NULL_OBJID,
                          targetid = CollId.objid,
                          targetos = CollId.osnum);
   __CheckRC(status, *msg, "Intializing RefSize", wrapup);
   }//Created the Collector

   /*Checking the variable value in the collector*/
   status = om$send(msg = message ACrg_collect.ACget_named_attribute
       					( msg, &RefSizeColl),
                          senderid = NULL_OBJID,
                          targetid = CollId.objid,
                          targetos = CollId.osnum);
   __CheckRC(status, *msg, "Reading RefSize", wrapup);

   __DBGpr_int("The value is %d", RefSizeColl.desc.value.att_exp);
   if( RefSizeColl.desc.value.att_exp != 0 )
   {
     //TTT
     //Delete the existing collector if it exist
     __DBGpr_com ("Checking to see if the Global Structure EXIST");
     if (SIR_Diag_Info != NULL)
     {
	__DBGpr_com ("Global Structure EXIST - free it");
	free(SIR_Diag_Info);
	__DBGpr_com ("the Global Structure is free");
     }

     SIR_Diag_Info = NULL;

     /*Read the collector and make a copy of global struct */
     SIR_Diag_Info = _MALLOC(RefSizeColl.desc.value.att_exp, struct SIRRefInfo);

     if (SIR_Diag_Info == NULL)
     {
       UI_status("ERROR: No Dynamic memory");
       return OM_E_NODYNMEM;
     }

     __DBGpr_com ("Memory Allocated for Global Structure");
     GRefSize=RefSizeColl.desc.value.att_exp;

     __DBGpr_com ("Memory Allocated for RefColl");

     /*Write into the SIR_Diag_Info */
     for( nbRefNo=0; nbRefNo<GRefSize; nbRefNo++)
     {
       /* Prepare Collector */
       CollName[0] = '\0';
       sprintf(CollName, "%s:File%d", DirName, nbRefNo);
       __DBGpr_str( "Collector name", CollName );

       status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &RefCollId );
       __DBGpr_obj( " Collector Id ", RefCollId );
       if(RefCollId.objid==NULL_OBJID)
       {
         __DBGpr_int("Missing Collector at", nbRefNo);
         continue;
       }
       /* Initialize Collector members */
       RefColl.desc.type=AC_ATTRIB_TEXT;
       RefColl.desc.value.att_txt[0]='\0';
       strcpy(RefColl.name, SIR_REF_PART);
       /* Get Collector values */
       status = _VD_SEND_OBJN(RefCollId, ACrg_collect.ACget_named_attribute(msg, &RefColl));
       CheckRC(status, *msg);
       strcpy(SIR_Diag_Info[nbRefNo].PdmPart, RefColl.desc.value.att_txt);
       __DBGpr_str("diaginfo part", SIR_Diag_Info[nbRefNo].PdmPart);
       /* Write Collector values in the Global Diagram Info Matrix */
       strcpy(RefColl.name, SIR_REF_REV );
       /* Get Collector values */
       status = _VD_SEND_OBJN(RefCollId, ACrg_collect.ACget_named_attribute(msg, &RefColl));
       CheckRC(status, *msg);
       strcpy(SIR_Diag_Info[nbRefNo].PdmRev, RefColl.desc.value.att_txt);
       __DBGpr_str("diaginfo rev", SIR_Diag_Info[nbRefNo].PdmRev);
       /* Write Collector values in the Global Diagram Info Matrix */
       strcpy(RefColl.name, SIR_REF_MDC );
       /* Get Collector values */
       status = _VD_SEND_OBJN(RefCollId, ACrg_collect.ACget_named_attribute(msg, &RefColl));
       CheckRC(status, *msg);
       /* Write Collector values in the Global Diagram Info Matrix */
       strcpy(SIR_Diag_Info[nbRefNo].Mdcobid, RefColl.desc.value.att_txt);

       __DBGpr_str("diag info mdcobid", SIR_Diag_Info[nbRefNo].Mdcobid);
       SIR_Diag_Info[nbRefNo].UpdFlag = 0;
       __DBGpr_int("diag info flag", SIR_Diag_Info[nbRefNo].UpdFlag);
       strcpy(SIR_Diag_Info[nbRefNo].UpdRev, "DUMMY");
       __DBGpr_str("diag info UpdRev", SIR_Diag_Info[nbRefNo].UpdRev);
       strcpy(SIR_Diag_Info[nbRefNo].UpdMdcobid, "DUMMY");
       __DBGpr_str("diag info UpdMdcobid", SIR_Diag_Info[nbRefNo].UpdMdcobid);
     }//Writing in Global structure for loop
   }//no reference files
   else
   { //make sure global values are being reset
     //because the diag list does not exist in the collector

     //TTTT
     //Delete the existing structure if it exist
     __DBGpr_com ("Checking to see if the Global Structure EXIST");
     if (SIR_Diag_Info != NULL)
     {
	__DBGpr_com ("Global Structure EXIST - Free It");
	free(SIR_Diag_Info);
	SIR_Diag_Info=NULL;
	__DBGpr_com ("the Global Structure is free");

	__DBGpr_com ("Global Structure Size EXIST - set it to 0");
	GRefSize = 0;
     }
   }
  }

  retFlag = OM_S_SUCCESS;

wrapup:
  if ( list ) _FREE(list);
End
return retFlag;
}

/*****************************************************************
* Function SrVDGetCMattrs( )
* query the three attributes from NFM tables for a given catalog, part, rev
* attributes are Is_AR_selected
*                Is_CM_managed
*                Is_DCC_selected
******************************************************************/

int SrVDGetCMattrs ( char *catalog, 
                     char *partid, 
                     char *revision,
                     char *ARselec,
                     char *CMmngd,
                     char *DCCsel,
                     char *Mdc,
                     char *IsSuper )
{

   char search[70], ar[2], cmm[2], dcc[2], state[2], super[20];
   int  num;
   char **buf;
   long status=0, sts=1;

  SetProc(VDPquerydm2.I.SrVDGetCMattrs); Begin
   //printf("\n in with %s, %s, %s", catalog, partid, revision );
   sprintf(search, "n_itemname = '%s' and n_itemrev = '%s'", partid, revision);
   __DBGpr_str( "Serach", search );
   status = vdb$RisSelect(select="p_mrpstruct, p_mrppart, p_explode, p_incpartrpt, p_mrpfieldupd",
                          table_name = catalog,
                          where = search,
                          numselect = 5,
                          p_numrows = &num,
                          p_buffer = &buf);
   if(status != 1 || num == 0 )
     return 1;

  //printf("\n reading ar ");
   sts = vdb$RisExtractValue ( nbrows = num,
                         nbcolumns = 5,
                         buffer = buf,
                         row = 0,
                         column = 0,
                         value = ar);
   if(status!=1) return 1;

   sts = vdb$RisExtractValue ( nbrows = num,
                         nbcolumns = 5,
                         buffer = buf,
                         row = 0,
                         column = 1,
                        value = cmm);
   if(status!=1) return 1;

   sts = vdb$RisExtractValue ( nbrows = num,
                         nbcolumns = 5,
                         buffer = buf,
                         row = 0,
                         column = 2,
                         value = dcc);
   if(status!=1) return 1;

   sts = vdb$RisExtractValue ( nbrows = num,
                         nbcolumns = 5,
                         buffer = buf,
                         row = 0,
                         column = 3,
                         value = state);
   if(status!=1) return 1;

   sts = vdb$RisExtractValue ( nbrows = num,
                         nbcolumns = 5,
                         buffer = buf,
                         row = 0,
                         column = 4,
                         value = super);
   if(status!=1) return 1;
   vdb$RisFreeBuffer( buffer = buf, size = 5 * num);

   //printf("\n ar %s, cmm %s, dcc %s, Mdc %s, super? %s", ar, cmm, dcc, state, super );
   strcpy( ARselec, ar);
   strcpy( CMmngd, cmm);
   strcpy( DCCsel, dcc);
   strcpy( Mdc, state);
   strcpy( IsSuper, super);
   //printf("\n ARS %s", ARselec );

   End
   return 0;
}

/***************************************************************
* SrVDUpdCMattrs writes the values in catalog table attributes wrriten are 
* for CM management purpose
**************************************************************/
int SrVDUpdCMattrs ( char *catalog, 
                     char *partid, 
                     char *revision, 
                     char *Attr,
                     char *Value )
{

   char query[1024], err[60];
   int status=0, ris_err_code=0;

   SetProc(VDPtrTbli.I.SrVDUpdCMattrs ); Begin
   query[0] = '\0';
   err[0] = '\0';
   sprintf(query, "UPDATE %s SET %s ='%s' WHERE n_itemname = '%s' AND n_itemrev = '%s'", catalog, Attr, Value, partid, revision);
   __DBGpr_str( "Statement", query );
   pdm$ris_stmt(status = &status,
                statement = query,
                ris_err_code = &ris_err_code);

   if( status != SQL_S_SUCCESS)
   {
     //printf("\n stat %d, ris err %d", status, ris_err_code);
     __DBGpr_com("Not got SQL_S_SUCCESS");
     sprintf(err, "ERROR : Couldnot Update nfmattribute <%s>.", Attr );
     UI_status( err );
     return  1;
   }
   End
   return 0;
}

IGRint VDPGetCtxId( char *Ctx, char *obid)
{
   IGRchar             DirName[DI_PATH_MAX], CollName[DI_PATH_MAX];
   struct GRid         CollId;
   IGRlong             status = 0;
   struct ACrg_coll    coll;
   OMuword             curOs;
   long msg;

   SetProc( VDPGetCtxId ); Begin
   ex$get_cur_mod( osnum = &curOs );

   /* get directory path name */
   status = di$give_pathname( osnum           = curOs,
                              pathname        = DirName );

   CheckRC( status, 1 );
    __DBGpr_str( "Path name", DirName );

    sprintf( CollName,"%s%s%s", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId ( &msg, CollName, TRUE, FALSE, &CollId );
    CheckRC( status, msg );
    if (!(status & msg & 1) || CollId.objid == NULL_OBJID )
    {
        UI_status("SIR Required Data not set");
        return 1;
    }
    __DBGpr_obj ( "Collector Id ", CollId );


    strcpy( coll.name, Ctx );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( &msg, &coll ));
    __DBGpr_str( "SIR_CX_ID", coll.desc.value.att_txt );

    strcpy( obid, coll.desc.value.att_txt );


wrapup:
    End
    return 0;

}

int SrVDGetCMState( char *catalog, char *part, char *rev, char *state )
{

   char search[70], st[5], search1[70], statetbl[15];
   int  num, nstate;
   char **buf, **buf1;
   long status=0, sts=1;

  SetProc(VDPquerydm2.I.SrVDGetCMState); Begin
   sprintf(search, "n_itemname = '%s' and n_itemrev = '%s'", part, rev);
   __DBGpr_str( "Serach", search );
   status = vdb$RisSelect(select="n_stateno",
                          table_name = catalog,
                          where = search,
                          numselect = 1,
                          p_numrows = &num,
                          p_buffer = &buf);
   if(status != 1 || num == 0 )
     return 1;

   sts = vdb$RisExtractValue ( nbrows = num,
                         nbcolumns = 1,
                         buffer = buf,
                         row = 0,
                         column = 0,
                         value = st);
   vdb$RisFreeBuffer( buffer = buf, size = 1 * num);

   sprintf(search1, "n_stateno = %s", st);
   __DBGpr_str( "Serach1", search1 );
   strcpy(statetbl, "nfmstates");

   status = vdb$RisSelect(select="n_statename", table_name = statetbl,
                          where = search1, numselect = 1,
                          p_numrows = &num, p_buffer = &buf1);
   if(status != 1 || num == 0 )
     return 1;

   sts = vdb$RisExtractValue ( nbrows = num,
                         nbcolumns = 1,
                         buffer = buf1,
                         row = 0,
                         column = 0,
                         value = state);
   vdb$RisFreeBuffer( buffer = buf1, size = 1 * num);

   End
   return 0;
}

/* Function to read the workflow name of the part. given a cat part rev info
 * find out the workflow name.
 * get n_stateno from <catalog>
 * get n_workflowno from nfmstates for n_stateno
 * get n_workflowname from nfmworkflow for n_workflowno
 * for TR 1527; instead of getting n_workflow name get cm_wf_enabled
 * */
 
int CMget_wflow_name( char *cat, char *part, char *rev, char *w_flow)
{
  char searchst[256], st[5], searchwf_no[100], wf_no[10], searchwf_name[100];
  char query[190], wf_name[20];
  char **bufst, **bufwf_no, **bufwf_name;
  int  num, rows, ris_err_code;
  long status=0, sts=1;
  char *output_buffer; 
  
  SetProc(VDPCmdEnabi.I.CMget_wflow_name); Begin
  
  /* Get the state no for cat part rev */
  sprintf(searchst, "n_itemname = '%s' and n_itemrev = '%s'", part, rev); 
  __DBGpr_str( "Serach1", searchst );
  
  status = vdb$RisSelect(select="n_stateno",
    			table_name = cat,
			where = searchst,
			numselect = 1,
			p_numrows = &num,
			p_buffer = &bufst);
  if(status != 1 || num == 0 )
    return 1;
  
  sts = vdb$RisExtractValue ( nbrows = num,
    			nbcolumns = 1,
			buffer = bufst,
			row = 0,
			column = 0,
			value = st);
  
  vdb$RisFreeBuffer( buffer = bufst, size = 1 * num);
  __DBGpr_str( " State ", st);
  
  /* find workflow no of the state no */
  sprintf(searchwf_no, "n_stateno = %s", st);
  __DBGpr_str( "Serach2", searchwf_no );
  
  status = vdb$RisSelect(select="n_workflowno",
    			table_name = "nfmstates",
			where = searchwf_no,
			numselect = 1,
			p_numrows = &num,
			p_buffer = &bufwf_no);
  if(status != 1 || num == 0 )
    return 1; 
  
  sts = vdb$RisExtractValue ( nbrows = num,
    			nbcolumns = 1,
			buffer = bufwf_no,
			row = 0,
			column = 0,
			value = wf_no);
  
  vdb$RisFreeBuffer( buffer = bufwf_no, size = 1 * num);
  __DBGpr_str( " w_flow_no ", wf_no);
  
  /* get the workflow name from workflow no */
  sprintf(searchwf_name, "n_workflowno = %s", wf_no);
  __DBGpr_str( "Serach3", searchwf_name );
  
  /* change for TR 1527
   * instead of getting name get the CM_WF_enabled flag */
  status = vdb$RisSelect(select="cm_wf_enabled",
    			table_name = "nfmworkflow",
			where = searchwf_name,
			numselect = 1,
			p_numrows = &num,
			p_buffer = &bufwf_name);
  if(status != 1 || num == 0 )
    return 1;
  
  sts = vdb$RisExtractValue ( nbrows = num,
    			nbcolumns = 1,
			buffer = bufwf_name,
			row = 0,
			column = 0,
			value = wf_name);
  
  vdb$RisFreeBuffer( buffer = bufwf_name, size = 1 * num);
  __DBGpr_str( " w_flow_name ", wf_name);
 
  /*return the workflow name */
  strcpy(w_flow, wf_name);

  End
  return 0;
}

/***************************************************************
 * Added by Anjani
 * SirVDUpdCMAttrs updates the values in the SirPdmtable attributes 
 * which are written for CM management purpose
 * **************************************************************/
int SirVDUpdCMAttrs ( char *catalog, 
                       char *partid, 
		       char *revision, 
		       char *Attr,
                       char *Value )
{
       
       char query[1024], err[60];
       int status=0, ris_err_code=0;
       char Table[15];

          SetProc(VDPtrTbli.I.SirVDUpdCMAttrs ); Begin
	     query[0] = '\0';
	     err[0] = '\0';
	     Table[0] = '\0';
	     strcpy(Table, "SIR_PDM_TABLE");
        sprintf(query, "UPDATE %s SET %s ='%s' WHERE pdu_catalog = '%s' AND pdu_part = '%s' AND pdu_revision = '%s'", Table, Attr, Value, catalog, partid, revision);
	   __DBGpr_str( "Statement", query );
          pdm$ris_stmt(status = &status,
	                statement = query,
	                ris_err_code = &ris_err_code);

	  if( status != SQL_S_SUCCESS)
	  {
	   //printf("\n stat %d, ris err %d", status, ris_err_code);
		__DBGpr_com("Not got SQL_S_SUCCESS");
	      sprintf(err, "ERROR : Couldnot Update nfmattribute <%s>.", Attr );
	       UI_status( err );
	      return  1;
	  }
	  End
	 return 0;
}	
	                           
end implementation VDPtrTbl;

