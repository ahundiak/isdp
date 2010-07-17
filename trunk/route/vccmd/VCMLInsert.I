/* $Id: VCMLInsert.I,v 1.3 2002/05/08 15:48:23 anand Exp $  */

/*************************************************************************
 * I/CABLE					vim600: fdm=marker:fmr=@<@,@>@
 *
 * File:  vccmd/VCMLInsert.I
 *
 * Description:
 *      Implementation file for place cable command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCMLInsert.I,v $
 *  Revision 1.3  2002/05/08 15:48:23  anand
 *  Files added/modified for sub-cable functionality.
 *
 *  Revision 1.2  2001/02/20 01:09:53  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.3  1999/01/12  11:35:16  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by sbilla for route
#
# Revision 1.2  1999/01/12  04:58:56  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.7  1998/04/26  20:14:36  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by kddinov for route
#
# Revision 1.6  1998/04/03  22:10:16  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by kddinov for route
#
# Revision 1.5  1998/03/31  07:11:46  pinnacle
# Replaced: vccmd/VCMLInsert.I for: TR 179800045 by aharihar for route
#
# Revision 1.4  1998/03/17  13:26:50  pinnacle
# Replaced: vccmd/VCMLInsert.I for: TR 179800045 by aharihar for route
#
# Revision 1.3  1998/03/12  10:17:10  pinnacle
# Replaced: vccmd/VCMLInsert.I for: TR179800045 by aharihar for route
#
# Revision 1.2  1997/11/30  16:07:48  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by r250_int for route
#
# Revision 1.12  1997/11/09  06:52:48  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by apazhani for cabling
#
# Revision 1.11  1997/08/11  21:55:06  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by hverstee for cabling
#
# Revision 1.10  1997/07/14  22:54:20  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by hverstee for cabling
#
# Revision 1.9  1997/05/07  14:20:00  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by hverstee for cabling
#
# Revision 1.8  1997/04/28  22:34:56  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by hverstee for cabling
#
# Revision 1.7  1997/03/12  21:56:20  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/03  18:11:26  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by hverstee for cabling
#
# Revision 1.5  1996/11/06  18:30:44  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by hverstee for cabling
#
# Revision 1.4  1996/10/25  14:33:14  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/26  21:20:08  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:35:36  pinnacle
# Replaced: vccmd/VCMLInsert.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:21:52  pinnacle
# Created: vccmd/VCMLInsert.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *  11/09/97      Alwin   Modified the VCInsertLink, where in check is made to
 *                        whether the cable parents are associative graphic
 *                        objects. Or else connection couldn't establised. This
 *                        problem mainly occurs when terminal is in Ref file.
 *  12 Mar '98    Anand   Information of offset of cable vertex wrt terminal is 
 *                        now stored in the cable instance, using VCCSetOffset.
 *                        The number of terminals and the offset information 
 *                        are sent as additional arguments to VC_CreateCab
 *  17 Mar '98    Anand   Problems in merging of cables that are already
 *                        connected to terminals, were resolved.
 *  27 Mar '98    Anand   VCCGetOffset method was modified to take care of
 *                        possible future revision. Some changes needed to be 
 *                        made here to take care of those modifications.
 *
 * 4-98		KDD	return VCCSetOffset to 2 parameters. 
 * 4-98		KDD	use the env matrix of the located object me->CATenv
 *			for VCGetMatrix calls. 
 * 1-99         Reddy   Estimated length and calculated length are set to zero
 *			whenever the cable length is modified
 *************************************************************************/

class implementation VCCmdPC;

/*
#define MY_DEBUG 
#define vdsDEBUG	1
*/

#include "VDmem.h"
#include "VCproto.h"
#include "vrdbgmacros.h"
#include "VCcreate.h"
#include "VCstructs2.h"
#include "VCCmdSet.h"
#include "vc_param.h"


/***********  EXTERN ***********/

from  VCRoot     import   VCGetInstance;
from  VCRoot     import   VCGetTagNo;
from  VCRoot     import   VCSetTagNo;

from  GRgraphics import   GRdisplay;
from  GRgraphics import   GRdelete;

from  ACpretend  import   ACfind_parent;
from  VCRoot     import   VCGetMatrix;

from  VCCable    import   VCCGetOffset;
from  VCCable    import   VCCbTerm;
from      ACncpx   import   ACgive_structure;
from      ACrg_collect import   ACshow_data;
from  VCRoot	 import	  VCPutExpand;



extern GRclassid OPP_VCTerm_class_id;



method VCInsertLink ( long * sts )
{
    /* Declare variables @<@ */
  IGRint                  status;
  IGRint                  statusMerge;
  IGRint                  statusPlace;
  IGRdouble  		  dEstim, dTail;
  IGRlong                 msg;
  IGRint                  i, iMerge;
  IGRint                  NumPar;
  IGRchar                 szTags1[VC_MAX_TAGNO];
  IGRchar                 szTags2[VC_MAX_TAGNO];

  struct GRid            *parId;
  struct VCGenInfo        gen_info;
  enum   GRdpmode         Mode;
 
  IGRshort                nTermCount=0;
  IGRdouble              *dOffsets=NULL;
  IGRlong		  retcode;  
  struct ACrg_coll	  NewListAttr[1];

  IGRboolean		  bHoldTagByp;
  IGRint		  NumLeads;
  IGRchar		  (*LdNames)[VC_MAX_LEAD_ID];

  SetProc( VCInsertLink ); Begin; /* @>@ */

  VC_INITSTR (szTags1);
  VC_INITSTR (szTags2);

  parId = NULL;

  /* Comp code check @<@ */
  bHoldTagByp = me->bTagByp;
  if( me->bSkSplCab )
      me->bTagByp = TRUE;

  status =
  om$send (msg = message VCCmdCAT.VCATcheck (sts),
      targetid = my_id);

  me->bTagByp = bHoldTagByp;

  if (*sts == VC_RTC_ERROR )
  {
    _put_response (resp = *sts);
    __DBGpr_com(" VCATcheck failed!");
    End;
    return (OM_S_SUCCESS);
  } /* @>@ */

  *sts = me->ret = VC_RTC_ALLOK;

  gen_info.nStat      = VC_STATUS_INIT;
  gen_info.nType      = VC_GEN_CABLE;
  gen_info.nNbAttr    = 2;
  gen_info.nProduct   = me->Product;

  /*C alloc for parId */
  
  NumPar  = gen_info.nNbAttr + me->nPtObjs;
  
  parId   = _MALLOC ( NumPar, struct GRid);

  __DBGpr_int(" Number of points in Cable",me->nMyPnts);
  if( me->nMyPnts < 2 ) goto bypass; /* message to user? */

  status =
  om$send (msg = message VCAT.VCAT_coll (&msg, &parId[0], &parId[1]),
      targetid = my_id);
  __DBGpr_obj("Collector parId[0]",parId[0]);
  __DBGpr_obj("Collector parId[1]",parId[1]);

  /*   save and dummy out tagnumbers of to-be merged lines    */

/* added by alwin for TR179701970 @<@ */
  for(i=0; i<me->nPtObjs; i++)
  {
    IGRboolean bIsRefFile;
    GRclassid parentClassId;
 
    __DBGpr_obj( "Parent Id", me->ptObjs[i] );
 
    status = om$get_classid ( objid = me->ptObjs[i].objid,
                              osnum = me->ptObjs[i].osnum,
                          p_classid = &parentClassId );
 
    bIsRefFile = ( om$is_ancestry_valid (subclassid = parentClassId,
                                       superclassid = OPP_ACpretend_class_id )
                   == OM_S_SUCCESS ) ? 1 : 0;
 
    if( (om$is_ancestry_valid (subclassid = parentClassId,
                           superclassid = OPP_VCTerm_class_id )
                                      == OM_S_SUCCESS) || bIsRefFile )
    {
       struct GRmd_env cur_md_env;
 
       cur_md_env.md_id.osnum = me->ptObjs[i].osnum;
 
       if( ! bIsRefFile )
       {
	   status = VCT_virtualize( &msg, TRUE, &me->ptObjs[i], &cur_md_env,
				    &me->ptObjs[i], &me->ModuleInfo );
     
	   __DBGpr_obj( "Parent Id after Virtualization ", me->ptObjs[i] );
       }
    }
    parId[i+gen_info.nNbAttr]     = me->ptObjs[i];
  }
/* added by alwin for TR179701970 @>@ */

  /* Following lines added by Anand for TR179800045 @<@ */
  for( i=0 ; i<me->nMySect ; i++ )
  {
      IGRboolean bIsRefFile;
      GRclassid parentClassId;
      IGRint ParNdx;

      if( me->mySect[i].type != VCC_TERM_PARENT )
	  continue;

      ParNdx = me->mySect[i].parno;
      __DBGpr_obj("Terminal parent for this section",me->ptObjs[ParNdx]);
 
      status = om$get_classid ( objid = me->ptObjs[ParNdx].objid,
				osnum = me->ptObjs[ParNdx].osnum,
				p_classid = &parentClassId );

      bIsRefFile =
	  ( om$is_ancestry_valid (subclassid = parentClassId,
				  superclassid = OPP_ACpretend_class_id )
						     == OM_S_SUCCESS ) ? 1 : 0;

      if( (om$is_ancestry_valid (subclassid = parentClassId,
				 superclassid = OPP_VCTerm_class_id )
	   != OM_S_SUCCESS) && !bIsRefFile )
	  continue;

      nTermCount++;
      __DBGpr_int(" Nb of Terminal Parents ", nTermCount );

      if( dOffsets )
	  dOffsets = _REALLOC( dOffsets, nTermCount*3, IGRdouble );
      else
	  dOffsets = _CALLOC( nTermCount*3, IGRdouble );
      __CheckPtr( dOffsets, "Allocation error for dOffsets", quit );

      /**** Begin setting the offset vector ******/
      {
	  IGRshort      nConPt=0;
	  IGRdouble     dRefMatrix[16];

	  MAidmx( &msg, dRefMatrix);
	  __DBGpr_mat("dRefMatrix after MAidmx",dRefMatrix);

	  /* Get the Terminal Information( Matrix ) and get the offset
	     values of Ends of the Cable, wrt to Terminal */

	  /* Step 1. Get the Matrix of the Terminal */
	  if( bIsRefFile )
	  {
	      struct GRid TermId;
	      IGRshort mat_type;

	      status =
	      om$send ( msg = message ACpretend.ACfind_parent( &TermId,
							       &mat_type,
							       dRefMatrix ),
			targetid = me->ptObjs[ParNdx].objid,
			targetos = me->ptObjs[ParNdx].osnum);
	      as$status( action = RET_STATUS );

	      /* 4-98 KDD use the environment of the located object */

	      __DBGpr_mat("Located Object environment ",
						   me->CATenv.md_env.matrix);

	      status =
	      om$send( msg	= message VCRoot.VCGetMatrix( &msg , -1,
							      dRefMatrix,
							      &me->CATenv),
		       targetid = TermId.objid,
		       targetos = TermId.osnum);
	      as$status( action = RET_STATUS );

	      __DBGpr_mat(" Matrix of terminal",dRefMatrix);
	  }
	  else
	  {
	      status =
	      om$send( msg = message VCRoot.VCGetMatrix( &msg , -1,
							 dRefMatrix,
							 &me->ModuleInfo),
		       targetid = me->ptObjs[ParNdx].objid,
		       targetos = me->ptObjs[ParNdx].osnum);
	      __DBGpr_mat(" Matrix of terminal",dRefMatrix);
	  }

	  /* Step 2. Get the co-ordinates of end point of cable */

	  /* ASSUMPTION ALERT: Assuming that a VCC_TERM_PARENT can be only at
	   * the extremum points of a cable. - Anand */
	  if( i )
	      nConPt = me->nMyPnts-1;
	  else
	      nConPt = 0;

	  dOffsets[3*nTermCount-3]=me->myPnts[nConPt].xyz[0];
	  dOffsets[3*nTermCount-2]=me->myPnts[nConPt].xyz[1];
	  dOffsets[3*nTermCount-1]=me->myPnts[nConPt].xyz[2];
	  __DBGpr_vec(" coordinates of end point",me->myPnts[nConPt].xyz);

	  /* Step 3. Get the offset vector from this */

	  dOffsets[3*nTermCount-3] -= dRefMatrix[3];
	  dOffsets[3*nTermCount-2] -= dRefMatrix[7];
	  dOffsets[3*nTermCount-1] -= dRefMatrix[11];

	  /* Note: The above lines of code assume that there can be only two
	     terminal parents for a cable. May need to revise later.*/

	  __DBGpr_vec(" Offset from terminal",(dOffsets+3*nTermCount-3));

      }
      /**** End setting the offset vector ******/
  }
  /* Above lines added by Anand for TR179800045 @>@ */

  __DBGpr_int(" nTermCount ", nTermCount );
  for( i=0 ; i < nTermCount ; i=i+1 )
      __DBGpr_vec(" offsets", &dOffsets[3*i] );
  __DBGpr_obj(" 0 line id",me->otherLnId[0]);
  __DBGpr_obj(" 1 line id",me->otherLnId[1]);

/** TR179802447- Setting estimated length and tail length @<@ **/
  {
    IGRint       	FootIndex, intmsg;
    struct ret_struct   p_rs;

	__DBGpr_com( " Calling ACncpx.ACgive_structure for estimated length");
	status =
	om$send ( msg = message ACncpx.ACgive_structure
			( &intmsg, &FootIndex, VC_N_CAB_LENGTH_DB, &p_rs,
			 &me->ModuleInfo),
	     targetid = me->otherLnId[0].objid,
	     targetos = me->otherLnId[0].osnum );

	dEstim = p_rs.var.root_pm_st.value;
	__DBGpr_dbl( " Estimated length=", dEstim );

//  Code for Tail Length
        __DBGpr_com( " Calling ACncpx.ACgive_structure for tail length");
        status =
        om$send ( msg = message ACncpx.ACgive_structure
                        ( &intmsg, &FootIndex, VC_N_TAIL_LENGTH_DB, &p_rs,
                         &me->ModuleInfo),
             targetid = me->otherLnId[0].objid,
             targetos = me->otherLnId[0].osnum );

        dTail = p_rs.var.root_pm_st.value;
        __DBGpr_dbl( " Tail length=", dTail );
  }

/** TR179802447 @>@ **/

  /* Handle merge @<@ */
  for (iMerge=0; iMerge < 2; iMerge++)
  {
    struct GRid	TermId;
    IGRchar sTempTagStr[20];

    __DBGpr_int(" number of other line",iMerge);
    __DBGpr_obj(" Other line id",me->otherLnId[iMerge]);
    if (me->otherLnId[iMerge].objid == NULL_OBJID)
	continue;

    TermId.objid = NULL_OBJID;

    status =
    om$send (msg = message VCRoot.VCGetTagNo (szTags1),
        targetid = me->otherLnId[iMerge].objid,
        targetos = me->otherLnId[iMerge].osnum);

    sprintf(sTempTagStr,"__TO_BE_DEL_%1d_",iMerge);
    status =
    om$send (msg = message VCRoot.VCSetTagNo (sTempTagStr),
        targetid = me->otherLnId[iMerge].objid,
        targetos = me->otherLnId[iMerge].osnum);

    status =
    om$send (msg = message VCCable.VCCbTerm (&msg, 0, &TermId),
        targetid = me->otherLnId[iMerge].objid,
        targetos = me->otherLnId[iMerge].osnum);
    __DBGpr_obj(" Terminal Id (0)",TermId);

    if( TermId.objid == NULL_OBJID )
    {
	status =
	om$send (msg = message VCCable.VCCbTerm (&msg, 1, &TermId),
	    targetid = me->otherLnId[iMerge].objid,
	    targetos = me->otherLnId[iMerge].osnum);
	__DBGpr_obj(" 1 Terminal Id",TermId);
    }

  /* The below if condition is NOT the same as ELSE - Anand */
  
    if( TermId.objid != NULL_OBJID )
    {
	IGRshort nTemp=0,OffsetType=0;
	void *Temp=NULL;

	status =
	om$send (msg = message VCCable.VCCGetOffset( &Temp, &nTemp),
	    targetid = me->otherLnId[iMerge].objid,
            targetos = me->otherLnId[iMerge].osnum);

	__DBGpr_int(" NoOffsets",nTemp);
	__DBGpr_int(" OffsetType",OffsetType);

	if( nTemp )
	{
	    if( !dOffsets )
		dOffsets = _CALLOC( (nTemp+nTermCount)*3, IGRdouble );
	    else 
		dOffsets = _REALLOC( dOffsets, (nTemp+nTermCount)*3,IGRdouble );

	    switch(OffsetType)
	    {
		case 0:
		{
		  struct VCOffset *TEMP;
		  TEMP = (struct VCOffset *) Temp;
 
                  for( i=0 ; i < nTemp ; i=i+1 )
                  {
                      __DBGpr_int(" Offset Index ",(TEMP+i)->Index);
                      __DBGpr_vec(" Offset vector",(TEMP+i)->Offset);
                  }

		  for( i=0 ; i < nTemp ; i=i+1 )
		  {
		      *(dOffsets+3*(nTermCount+i)+0) = (TEMP+i)->Offset[0];
		      *(dOffsets+3*(nTermCount+i)+1) = (TEMP+i)->Offset[1];
		      *(dOffsets+3*(nTermCount+i)+2) = (TEMP+i)->Offset[2];
		      __DBGpr_vec("Offset vector",(dOffsets+3*(nTermCount+i)));
		  }
		  _FREE( TEMP );
		  break;
		}

		  // For modification beyond release 2.5
	  /*
		case 1:
		{
		  struct VCOffsetXXX *TEMP;


		  break;
		}	
	  */
		default:
		  return( OM_E_ABORT );

	    }

	}

	nTermCount += nTemp;
	__DBGpr_int(" no of terminals", nTermCount);
    }
  } /* End Merge @>@ */

  strcpy(gen_info.szCode,me->CompCode);
  strcpy(gen_info.szTagno,me->CompTag);

  gen_info.cRep                   = me->nACTrep;
  gen_info.nNbTopo                = me->nPtObjs;

  gen_info.Attr.Cable.NbVertices  = me->nMyPnts;
  gen_info.Attr.Cable.pVertex     = (IGRdouble *) me->myPnts;

  gen_info.Attr.Cable.NbSections  = me->nMySect;
  gen_info.Attr.Cable.pSect       = me->mySect;

  if( me->bSkSplCab )
  {
      NumLeads = om$dimension_of(varray=me->Leads);
      __DBGpr_int(" Number of leads to be set in sub cable",NumLeads);
      LdNames = calloc( NumLeads, sizeof(*LdNames) );

      for( i=0; i<NumLeads ; i++ )
      {
	  strcpy( LdNames[i], me->Leads[i].LeadNam );
	  __DBGpr_str(" Lead name",LdNames[i]);
      }
  }
  else
  {
      NumLeads = 0;
      LdNames = NULL;
  }

  /*A ----- Create & Place Cable object ----- @<@ */
  
#if defined(vdsDEBUG)
  printf("Product value %d \n",me->Product);

  printf (" nSecPts, nPtObjs %d %d\n",me->nSecPts,me->nPtObjs);

  for (i=0;i<me->nMyPnts;i++)
    printf (" coords %f %f %f\n",me->myPnts[i].xyz[0],
                                 me->myPnts[i].xyz[1],
                                 me->myPnts[i].xyz[2]);
  for (i=0;i<me->nMySect; i++)
    printf (" sections %d %d %d %d %d %d\n",
                                 me->mySect[i].type,
                                 me->mySect[i].iFrom,
                                 me->mySect[i].iTo,
                                 me->mySect[i].numvert,
                                 me->mySect[i].strno,
                                 me->mySect[i].parno);
  for(i=0; i<me->nPtObjs; i++) 
    printf (" parents %d %d\n",me->ptObjs[i].objid,me->ptObjs[i].osnum);
#elif defined(DBG_PROD_NAME)
  if( DBG_Gb_dbg & DBG_PROD )
      fprintf(DBG_Gb_Fp,"Product value %d \n",me->Product);

  if( DBG_Gb_dbg & DBG_PROD )
      fprintf (DBG_Gb_Fp," nSecPts, nPtObjs %d %d\n",me->nSecPts,me->nPtObjs);

  if( DBG_Gb_dbg & DBG_PROD )
      for (i=0;i<me->nMyPnts;i++)
	  fprintf (DBG_Gb_Fp," coord No.%d %f %f %f\n",
				 i+1,me->myPnts[i].xyz[0],
                                 me->myPnts[i].xyz[1],
                                 me->myPnts[i].xyz[2]);
  if( DBG_Gb_dbg & DBG_PROD )
      for (i=0;i<me->nMySect; i++)
	  fprintf (DBG_Gb_Fp," section No.%d %d %d %d %d %d %d\n",i+1,
                                 me->mySect[i].type,
                                 me->mySect[i].iFrom,
                                 me->mySect[i].iTo,
                                 me->mySect[i].numvert,
                                 me->mySect[i].strno,
                                 me->mySect[i].parno);
  if( DBG_Gb_dbg & DBG_PROD ) for(i=0; i<me->nPtObjs; i++) 
    fprintf (DBG_Gb_Fp," parent no.%d %d %d\n",i+1,
				      me->ptObjs[i].objid,me->ptObjs[i].osnum);
#endif

  me->CompId.objid = NULL_OBJID;
  me->CompId.osnum = me->ModuleInfo.md_id.osnum;

  __DBGpr_com( " Calling Fn VC_CreateCab " );
  status = 
  VC_CreateCab (&msg, NumPar, parId, &gen_info, me->ActiveLevel,
                &me->ActiveDisplay, &me->ModuleInfo, &me->CompId,
		nTermCount,dOffsets,me->bSkSplCab,NumLeads,LdNames);
  __DBGpr_obj("Cable object",me->CompId);

  /* Post cable-creation @>@ */
  if (me->CompId.objid == NULL_OBJID)
  {    /*   add failed, restore tagnumbers   @<@    */
    if (me->otherLnId[0].objid != NULL_OBJID)
    {
      status =
      om$send (msg = message VCRoot.VCSetTagNo (szTags1),
          targetid = me->otherLnId[0].objid,
          targetos = me->otherLnId[0].osnum);
    }

    if (me->otherLnId[1].objid != NULL_OBJID)
    {
      status =
      om$send (msg = message VCRoot.VCSetTagNo (szTags2),
          targetid = me->otherLnId[1].objid,
          targetos = me->otherLnId[1].osnum);
    }
  } /* End if compid is null objid @>@ */
  else
  { /*------------------------  MERGE/JOIN section --------------------@<@-*/

    for (iMerge=0; iMerge < 2; iMerge++)
    {
      statusMerge = OM_S_SUCCESS;
      statusPlace = status;

      if( (me->otherLnId[iMerge].objid == NULL_OBJID) ||
          (me->otherLnCpt[iMerge] == -1))                          continue;

      {
        /*C Detach from connector first   */

        /*C Undisplay other */
        Mode = GRbe;
        status = 
        om$send( msg = message GRgraphics.GRdisplay( &msg, 
                                &me->ModuleInfo.md_env.matrix_type,
                                 me->ModuleInfo.md_env.matrix, &Mode,
                                &me->ModuleInfo.md_id ),
            targetid = me->otherLnId[iMerge].objid,
            targetos = me->otherLnId[iMerge].osnum ) ;
        as$status();

#ifdef vdsDEBUG
        printf("calling VCmergelink \n");
	__DBGpr_me();
	__DBGpr_obj(" new cable's id",me->CompId);
#endif

        /*C Merge with other */
        statusMerge = 
        om$send( msg = message VCCmdPC.VCMergeLink( &msg , iMerge),
            targetid = my_id);
        as$status();

        /*C Post-Merge: Redisplay or Delete other */
        if( !(statusMerge & OM_S_SUCCESS) )
        {
          /*C Redisplay other */
          Mode = GRbd;
          status = 
          om$send( msg = message GRgraphics.GRdisplay( &msg, 
                                        &me->ModuleInfo.md_env.matrix_type,
                                         me->ModuleInfo.md_env.matrix, 
                                        &Mode, &me->ModuleInfo.md_id ),
              targetid = me->otherLnId[iMerge].objid,
              targetos = me->otherLnId[iMerge].osnum ) ;
           as$status();
        }   
        else
        {
  
          /*C Delete other */
          status = 
          om$send ( msg = message GRgraphics.GRdelete(&msg, &me->ModuleInfo),
               targetid = me->otherLnId[iMerge].objid,
               targetos = me->otherLnId[iMerge].osnum ) ;
          as$status();

        } /* end Post-Merge */
      } /* end Merge */
    }

    if( (statusPlace & OM_S_SUCCESS) && (statusMerge & OM_S_SUCCESS) )
    {
      /*K Delete GRNUC buffer in order to display the right geometry */
      GRabsg_del_all();

      /*C Display my */
      Mode = GRbd;
      status = 
      om$send( msg = message GRgraphics.GRdisplay( &msg, 
                                        &me->ModuleInfo.md_env.matrix_type,
                                         me->ModuleInfo.md_env.matrix, 
                                        &Mode, &me->ModuleInfo.md_id ),
          targetid = me->CompId.objid,
          targetos = me->CompId.osnum );
      as$status();
    }

    //TR179802447-Setting estimated length to the merged cable object
    {
      struct VCEXpan   ExRec;
      IGRshort     noret;

      ExRec.type = VCEX_DBL;
      ExRec.AT.EXd = dEstim;

      __DBGpr_com( " setting estimated length to the merged cable object");
      status =
      om$send (msg = message VCRoot.VCPutExpand
				(&retcode, (IGRshort) VC_EXIN_ESTIM,
				  &noret, &ExRec),
	targetid = me->CompId.objid,
	targetos = me->CompId.osnum);

      //TR179802447Setting tail length to the merged cable object

      ExRec.type = VCEX_DBL;
      ExRec.AT.EXd = dTail;

      __DBGpr_com( " setting Tail length to the merged cable object");
      status =
      om$send (msg = message VCRoot.VCPutExpand
				(&retcode, (IGRshort) VC_EXIN_TAIL,
				  &noret, &ExRec),
	targetid = me->CompId.objid,
	targetos = me->CompId.osnum);
    }
  } /* End else (merge/join) @>@ */

  bypass:

  /*  dehighlight current os    */

  status =
  dp$erase_hilite (msg = &msg);

  /*   and all os of parents   */

  for(i=0; i<me->nPtObjs; i++) 
    if (me->ptObjs[i].osnum != me->ModuleInfo.md_id.osnum)
    {
      status = dp$erase_hilite (msg = &msg,
                              osnum = me->ptObjs[i].osnum);
    }

  if( me->bToBeSplit==FALSE )
  {
      /*C Forget about this link */
      me->CompId.objid = NULL_OBJID;
      status = 
	  om$send( msg      = message VCCmdPC.VCinit (&msg),
		   targetid = my_id);

      *sts = VCL_LINK_FREE_POINT;
      _put_response( resp = VCL_LINK_FREE_POINT);
  }

  quit:

  _FREE( LdNames );
  _FREE( dOffsets );
  _FREE (parId);
  End
  return OM_S_SUCCESS;
}

end implementation VCCmdPC;



