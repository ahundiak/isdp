/* $Id: VCfunc.I,v 1.3 2002/05/08 15:48:23 anand Exp $  */
 
/***************************************************************************
 * I/ROUTE
 *
 * File:        vccable/VCfunc.I
 *
 * Description:
 *
 *		Functions : VCGetCabConnDet
 *			    VCCalOffVector
 *			    VCobjInActiveSpace
 *	are written to support the conversion of files of 2.4.2.20 version
 *	to 2.5.1. The cbl_convert.u ppl is the main function which calls these
 *	supporting functions, to perform the tasks.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCfunc.I,v $
 *      Revision 1.3  2002/05/08 15:48:23  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.2  2001/02/20 01:09:21  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/07/25  12:55:10  pinnacle
# initial revision
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/25/98	Alwin		Creation 
 ***************************************************************************/

class implementation Root;

#include	<stdio.h>
#include 	<stdlib.h>
#include	"OMminimum.h"
#include	"igrtypedef.h"
#include	"OMprimitives.h"
#include	"OMerrordef.h"
#include	"exmacros.h"
#include	"igetypedef.h"
#include	"gr.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"godef.h"
#include	"nddef.h"
#include	"ndmacros.h"
#include 	"AS_status.h"
#include	"VRattr_def.h"
#include	"vc_define.h"
#include	"vc_structs.h"
#include	"VCdefine.h"
#include	"VCDBpar.h"
#include	"VDmem.h"
#include	"vrdbgmacros.h"
#include	"VCstructs.h"

extern struct GRid NULL_GRID;
extern GRclassid OPP_VRCptIn_class_id;
extern GRclassid OPP_VCElCable_class_id;
extern GRclassid OPP_VCFoCable_class_id;
extern GRclassid OPP_ACpretend_class_id;

extern 		GRdpb_get();
extern 	long 	VDobjInActiveSpace();
extern 		NDexec_batch();
extern 		NDwait_batch();

from 	VCTerm  import	VCTembed;
from 	VCCable import	VCConList;
from 	VCCable import	VCGetSignal;
from 	VCCable import	VCCbTerm;
from 	VCRoot  import	VCGetTopology;
from 	VCRoot  import	VCGetCptCoord;
from 	VCRoot  import	VCGetMatrix;
from 	ACncpx  import	ACgive_structure;

IGRlong VCGetCabConnTerm( msg,  CableId, nCpt,
			  nPos, cab_conn, terminal , flag) 

IGRlong 	        *msg;
struct GRid	        CableId;
IGRshort 	        *nPos, nCpt;
struct VCcab_connect	*cab_conn;
struct GRid             *terminal;
IGRboolean              flag;

{
      IGRshort j, nCount, mask;
      IGRlong retmsg, sts, retFlag = 0;
      struct VCpos *cab, *trm;
      struct GRid  termID;

      if(nPos) *nPos        = 0;
      *msg         = MSFAIL;
      trm = cab    = NULL;
      termID.objid = NULL_OBJID;
      nCount       = 0;

       __DBGpr_int("nCpt ", nCpt);
      // first check if there is a terminal present at the specified end
      sts = om$send( msg=message VCCable.VCCbTerm(&retmsg, nCpt, &termID),
               senderid = NULL_OBJID,
               targetos = CableId.osnum,
               targetid = CableId.objid );
/*
      if(!(sts&1)) // retmsg would return MSFAIL if no parent.
      {
        __DBGpr_obj(" VCCable.VCCbTerm failed for", CableId);
        goto wrapup;
      }
*/
      if(termID.objid == NULL_OBJID)
      {
        __DBGpr_obj(" No terminal present for cable", CableId);
        *msg = MSSUCC;
        retFlag = 1;
        goto wrapup;
      }
     
      if(terminal) *terminal = termID;

      if(flag) mask = VC_CBE_CONNECTED | VC_CBE_OPEN;
      else     mask = VC_CBE_CONNECTED;

      if(nPos)
      { 
        /* First get the No. of Cable Leads connected to the Terminal Pins */
        sts = om$send ( msg = message VCCable.VCConList
			  ( &retmsg, nCpt, mask,
			    &nCount, NULL, NULL, NULL, NULL ),
		      senderid = NULL_OBJID,
                      targetid = CableId.objid,
                      targetos = CableId.osnum );

        if(!(sts&retmsg&1))
        {
  	  __DBGpr_obj("VCCable.VCConList failed for", CableId);
	  goto wrapup;
        }

        *nPos = nCount;

        if((*nPos) == 0)
        {
	  __DBGpr_obj("No leads connected to terminal", CableId);
          *msg = MSSUCC;
          retFlag = 1;
	  goto wrapup;
        }
	  
        if(cab_conn)	// Check if cab_connect not being null.
        {
          /* 
           * From the Nb. of Cables Leads connected to the Terminal Pins, 
           * allocate memory so that we can Obtain that information and 
           * set it back to the new cable. 
           */
           cab = _MALLOC(nCount, struct VCpos);
           trm = _MALLOC(nCount, struct VCpos);

           __DBGpr_int( " Nb. of Leads Connected to Terminal ", *nPos );

          sts =
          om$send ( msg = message VCCable.VCConList
                          ( &retmsg, nCpt, mask,
                            &nCount, cab, trm, NULL, NULL ),
		      senderid = NULL_OBJID,
                      targetid = CableId.objid,
                      targetos = CableId.osnum );
          if(!(sts&retmsg&1))
          {
  	    __DBGpr_obj("VCCable.VCConList failed for", CableId);
	    goto wrapup;
          }

	  for( j=0 ; j<nCount ; j++ )
	  {
	      strcpy( cab_conn[j].LeadNam , cab[j].Conn.Cable.szLeadId );
	      strcpy( cab_conn[j].FibEnds[nCpt].szModId,
					     trm[j].Conn.Term.szModId );
	      strcpy( cab_conn[j].FibEnds[nCpt].szPosId,
					     trm[j].Conn.Term.szPosId );
	  }

        }
      }
  //Done
  *msg = MSSUCC;
  retFlag = 1;

wrapup:
  _FREE(cab);
  _FREE(trm);
  return retFlag;
}
IGRlong VCGetCabConnDet( msg,  CableId, nCpt,
				nPos, cab, trm, szSignal ) 
IGRlong 	*msg;
struct GRid	CableId;
IGRshort 	*nPos, nCpt;
struct VCpos	*cab;
struct VCpos	*trm;
IGRchar		**szSignal;
{
      IGRint j;
      IGRlong retmsg, sts;

      SetProc( Fn VCGetCabConnDet ); Begin 
      msg = &retmsg;

      __DBGpr_int( " Connect Point ", nCpt );

      /* Get the Cable Connection details at the Cable '0' th end */
      /* First get the No. of Cable Leads connected to the Terminal Pins */
      sts = om$send ( msg = message VCCable.VCConList
			  ( &retmsg, nCpt, VC_CBE_CONNECTED,
			  nPos, NULL, NULL, NULL, NULL ),
		      senderid = NULL_OBJID,
                      targetid = CableId.objid,
                      targetos = CableId.osnum );

      /* From the Nb. of Cables Leads connected to the Terminal Pins, allocate
      memory so that we can Obtain that information and set it back to the
      new cable. */

      __DBGpr_int( " Nb. of Leads Connected to Terminal ", *nPos );

      if ( (*nPos > 0) && ( cab != NULL ) )
      {
	__DBGpr_int( " Connect Point ", nCpt );
        sts =
        om$send ( msg = message VCCable.VCConList
                        ( &retmsg, nCpt, VC_CBE_CONNECTED,
                        nPos, cab, trm, NULL, NULL ),
		      senderid = NULL_OBJID,
                      targetid = CableId.objid,
                      targetos = CableId.osnum );

        for( j=0; j<*nPos;  j=j+1 )
        {
            __DBGpr_com( " Get the Signal Name " );
            szSignal[j][0] = '\0';
            sts =
            om$send ( msg = message VCCable.VCGetSignal
                                ( &retmsg, &cab[j], szSignal[j] ),
	        senderid = NULL_OBJID,
                targetid = CableId.objid,
                targetos = CableId.osnum );
            __DBGpr_str( " Signal Name ", szSignal[j] );
        }
      }

      End
      return 1;
}

/* This function Calculates the Offset vector from the Terminal Connect Point
informations. Later this Offsets will set to the  Cable Instance data. */

IGRlong VCCalOffVector( msg, CableId, loc_env, dOffsetVector, NbOfOffsets )
IGRlong 	*msg;
struct GRid 	CableId;
struct GRmd_env *loc_env;
IGRdouble 	*dOffsetVector;
IGRint		*NbOfOffsets;
{
  IGRboolean	bFound, bIsEmbedded;
  IGRint 	i, j, FootIndex;
  IGRshort	*nConCp=NULL, nCpt = -1, nTerms;
  IGRdouble	dCIN[3], dRefMatrix[16], dPidScale=1.0;
  IGRlong 	sts, ret;
  struct GRid 	*ConId=NULL, TerminalId[2];
  struct GRmd_env md_env;
  struct ret_struct ParamAttr;

  SetProc( Fn VCCalOffVector ); Begin 

  md_env = *loc_env;
  __DBGpr_obj( " Cable Id ", CableId );

  /* Get the topological details of Cable */
  nTerms = 0;
  sts = om$send ( msg = message VCRoot.VCGetTopology( msg, (IGRshort) -1,
				&nTerms, (struct GRid *) NULL, 
				    (IGRshort *) NULL,
				    NULL, NULL ),
		    	  senderid = NULL_OBJID,
			  targetid = CableId.objid,
			  targetos = CableId.osnum );
  __DBGpr_int( " Nb of Terminals connected to Cable ", nTerms );

  if( nTerms > 0 )
  {
      ConId = _MALLOC( nTerms, struct GRid );
      nConCp = _MALLOC( nTerms, IGRshort );

      if( ( ConId == NULL ) || ( nConCp == NULL ) ) 
      { 
	   printf( "\n Memory Allocation error- ConId || nConCp :-( \n");
	   End
	   return 0;
      } 

      sts = 
      om$send ( msg = message VCRoot.VCGetTopology( msg, (IGRshort) -1,
				    &nTerms, ConId, nConCp,
				    NULL, NULL ),
		    	  senderid = NULL_OBJID,
			  targetid = CableId.objid,
			  targetos = CableId.osnum );
  }
  else 
  {
     *NbOfOffsets = 0;
     __DBGpr_int( " Nb of Offsets ", *NbOfOffsets );
     End
     return OM_S_SUCCESS;
  }

  /* Get the Terminal object connected at the Cable 0 end */
  sts = om$send ( msg = message VCCable.VCCbTerm( msg, (IGRshort ) 0,
			    &TerminalId[0] ),
		    	  senderid = NULL_OBJID,
			  targetid = CableId.objid,
			  targetos = CableId.osnum );
  __DBGpr_obj( " Terminal Id at Cable 0 ", TerminalId[0] );

  if( TerminalId[0].objid != NULL_OBJID )
  {
      bFound = FALSE;
      for( j=0; ( j<nTerms && !bFound ); j=j+1 )
      {
	 if( ( ConId[j].objid == TerminalId[0].objid ) &&
	     ( ConId[j].osnum == TerminalId[0].osnum ) )
	 {
	    nCpt = nConCp[j];
	    bFound = TRUE;
	 }
      }

      __DBGpr_int( " Connect Point Number is ", nCpt );
      sts = om$send ( msg = message VCRoot.VCGetCptCoord( msg, nCpt,
				    dCIN, &md_env ),
			  senderid = NULL_OBJID,
			  targetid = TerminalId[0].objid,
			  targetos = TerminalId[0].osnum );
      __DBGpr_vec( " Connect Point Coordinates ", dCIN );

      sts = om$send( msg = message VCRoot.VCGetMatrix( msg , -1,
				    dRefMatrix, &md_env),
			  senderid = NULL_OBJID,
			  targetid = TerminalId[0].objid,
			  targetos = TerminalId[0].osnum );
      __DBGpr_mat( " Terminal's Matrix ", dRefMatrix );

      ParamAttr.var.root_pm_st.value = 1.0;
 
      bIsEmbedded = FALSE;
      sts = om$send ( msg = message VCTerm.VCTembed( &bIsEmbedded ),
		   senderid = NULL_OBJID,
                   targetid = TerminalId[0].objid,
		   targetos = TerminalId[0].osnum );

      __DBGpr_int( " Is it Embedded? ", bIsEmbedded );
      if( bIsEmbedded )
      {
	  //Get the PID scale of the Terminal and adjust the offset vector 
	  // accodingly. Alwin
	  sts = om$send( msg   = message ACncpx.ACgive_structure ((int*) msg,
                                (int *) &FootIndex,
                                VC_N_PID_SCALE_DB, &ParamAttr, &md_env),
		   senderid = NULL_OBJID,
                   targetid = TerminalId[0].objid,
		   targetos = TerminalId[0].osnum );
      }

      dPidScale = ParamAttr.var.root_pm_st.value;
      __DBGpr_dbl( " Pid Scale Value of Terminal ", dPidScale );

      dOffsetVector[0] = -( dRefMatrix[3] - dCIN[0] ) / dPidScale;
      dOffsetVector[1] = -( dRefMatrix[7] - dCIN[1] ) / dPidScale;
      dOffsetVector[2] = -( dRefMatrix[11] - dCIN[2] ) / dPidScale;
      __DBGpr_vec( " Offset Vector ", dOffsetVector );

      *NbOfOffsets= *NbOfOffsets + 1;
  }

  /* Get the Terminal object connected at the Cable 1 end */
  sts = om$send ( msg = message VCCable.VCCbTerm( msg, (IGRshort ) 1,
			    &TerminalId[1] ),
		      senderid = NULL_OBJID,
		      targetid = CableId.objid,
		      targetos = CableId.osnum );
  __DBGpr_obj( " Terminal Id at Cable 1 ", TerminalId[1] );

  if( TerminalId[1].objid != NULL_OBJID )
  {
      bFound = FALSE;
      for( j=0; ( j<nTerms && !bFound ); j=j+1 )
      {
	 if( ( ConId[j].objid == TerminalId[1].objid ) &&
	     ( ConId[j].osnum == TerminalId[1].osnum ) )
	 {
	    nCpt = nConCp[j];
	    bFound = TRUE;
	 }
      }

      __DBGpr_int( " Connect Point Number is ", nCpt );
      sts = om$send ( msg = message VCRoot.VCGetCptCoord( msg, nCpt,
				    dCIN, &md_env ),
			  senderid = NULL_OBJID,
			  targetid = TerminalId[1].objid,
			  targetos = TerminalId[1].osnum);
      __DBGpr_vec( " Connect Point Coordinates ", dCIN );

      sts = om$send( msg = message VCRoot.VCGetMatrix( msg , -1,
				    dRefMatrix, &md_env),
			  senderid = NULL_OBJID,
			  targetid = TerminalId[1].objid,
			  targetos = TerminalId[1].osnum);
      __DBGpr_mat( " Terminal's Matrix ", dRefMatrix );

      ParamAttr.var.root_pm_st.value = 1.0;
 
      bIsEmbedded = FALSE;
      sts = om$send ( msg = message VCTerm.VCTembed( &bIsEmbedded ),
		   senderid = NULL_OBJID,
                   targetid = TerminalId[1].objid,
		   targetos = TerminalId[1].osnum );

      __DBGpr_int( " Is it Embedded? ", bIsEmbedded );
      if( bIsEmbedded )
      {
	  //Get the PID scale of the Terminal and adjust the offset vector 
	  // accodingly. Alwin
	  sts = om$send( msg   = message ACncpx.ACgive_structure ( (int*)msg,
                                (int *) &FootIndex,
                                VC_N_PID_SCALE_DB, &ParamAttr, &md_env),
		   senderid = NULL_OBJID,
                   targetid = TerminalId[1].objid,
		   targetos = TerminalId[1].osnum );
      }

      dPidScale = ParamAttr.var.root_pm_st.value;
      __DBGpr_dbl( " Pid Scale Value of Terminal ", dPidScale );

      dOffsetVector[ (*NbOfOffsets) * 3] =   -( dRefMatrix[3] - dCIN[0] ) / dPidScale;
      dOffsetVector[ (*NbOfOffsets) * 3+1] = -( dRefMatrix[7] - dCIN[1] ) / dPidScale;
      dOffsetVector[ (*NbOfOffsets) * 3+2] = -( dRefMatrix[11] - dCIN[2] ) / dPidScale;
      __DBGpr_vec( " Offset Vector ", &dOffsetVector[3*(*NbOfOffsets)] );

      *NbOfOffsets= *NbOfOffsets + 1;
  }

  __DBGpr_com( " Freeing the memory " );
  _FREE( ConId );
  _FREE( nConCp );

  __DBGpr_int( " Nb of Offsets ", *NbOfOffsets );

  End
  return sts;
}

/* This is function is same as VDobjInActiveSpace implemented in 
$VDS/vdio/VDfunc.I file. Here I'm modifying this function slightly to provide 
an extra feature to specify one more classes */

IGRlong VCobjInActiveSpace( 	long *msg, 
				int *count, 
				struct GRid **list, 
				OMuword *class,
				IGRint NbClasses )
{
	OMuword 	objClassid,	/* Class of `curObj'		*/
			actOs ; 	/* OS number of active file	*/
	struct GRid	curObj;
	int		i, j,		/* Loop index			*/
			cnt,		/* Count of children		*/
			maxObjs ;	/* Max. of objs in Object Space */
					/* or in given list of parts.	*/
	long		sts = OM_S_SUCCESS ;

	cnt = 0;
	
	ex$get_cur_mod( osnum = &actOs ) ;
	maxObjs = OM_GA_OSDs[actOs]->CurSpaceMapSize ;
	curObj.osnum = actOs ;
		
	*list = _MALLOC ( maxObjs, struct GRid );

	for( i = 0 ; i < maxObjs ; i++ ) 
	{
		curObj.objid = i ;
		sts = om$get_classid(	objid		= curObj.objid,
					osnum		= curObj.osnum,
					p_classid	= &objClassid ) ;
		if( !( sts & 1 ) ) {
			/*
			 * Not an object id.
			 */
			continue ;
		}

		for( j=0; j<NbClasses; j++ )
		{
		    sts = om$is_ancestry_valid(
				    superclassid	= class[j],
				    subclassid		= objClassid ) ;
		    if( sts != OM_S_SUCCESS ) {
			    continue ;
		    } else {
			    (*list)[cnt] = curObj;
			    cnt++;
		    }
		}
	}

	if( cnt) *count = cnt;
	
	return( sts & *msg & 1 );
}

end implementation Root;
