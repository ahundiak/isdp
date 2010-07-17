/* $Id: VRGraphInfo.I,v 1.5 2002/04/10 19:42:16 louis Exp $  */
/*************************************************************************
 * I/ROUTE
 *
 * File:	vrgeneric / VRGraphInfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRGraphInfo.I,v $
 *	Revision 1.5  2002/04/10 19:42:16  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.4  2001/02/20 01:14:22  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.3  2001/02/02 15:30:52  louis
 *	TR4578-recompute with new misalignment tolerance
 *	
 *	Revision 1.2  2001/01/12 20:44:22  anand
 *	SP merge
 *	
# Revision 1.3  2000/06/27  20:59:22  pinnacle
# Replaced: route/vrgeneric/VRGraphInfo.I for:  by jwfrosch for Service Pack
#
# Revision 1.1  2000/05/23  23:18:24  pinnacle
# Created: route/vrgeneric/VRGraphInfo.I by lawaddel for Service Pack
#
# Revision 1.3  1998/11/13  21:54:34  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/03/17  18:40:38  pinnacle
# Replaced: vrgeneric/VRGraphInfo.I for:  by kddinov for route
#
# Revision 1.3  1998/03/17  14:25:24  pinnacle
# Replaced: vrgeneric/VRGraphInfo.I for:  by kddinov for route
#
# Revision 1.2  1997/07/17  19:09:58  pinnacle
# Replaced: vrgeneric/VRGraphInfo.I for:  by r250_int for route
#
# Revision 1.5  1997/07/07  21:41:34  pinnacle
# Replaced: vrgeneric/VRGraphInfo.I for:  by yzhu for route
#
# Revision 1.4  1997/05/21  20:27:20  pinnacle
# Replaced: ./vrgeneric/VRGraphInfo.I for:  by lawaddel for route
#
# Revision 1.3  1997/02/18  20:10:16  pinnacle
# Replaced: vrgeneric/VRGraphInfo.I for:  by hverstee for route
#
# Revision 1.2  1996/01/17  00:01:58  pinnacle
# Replaced: vrgeneric/VRGraphInfo.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add protoypes
 *	05/20/97	adz&law TR179602393-Installed initialization of output
 *				buffers and debug printouts to prevent crashes
 *				when moving nozzles instead of coordinate
 *				systems.
 *
 * 	3/98		KDD	VRGetPrivateParams method. Use this one to
 *				get (create if needed) unique parameter
 *				collectors. For some reason the collectors are
 *				created not unique by default.
 *      11/13/98        Alwin   Modified method VRGetSupOnCpt to return the
 *                              correct Line Segment, when the Nozzle is in the
 *                              reference file. TR179802347
 *      06/27/00        HF      Fixed memory leak
 *	02/02/01	law	TR4578-relax alignment tolerance for recompute
 *      04/05/02        law     TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/
/*D
     CLASS  NAME: VRGeneric
     METHOD NAMES:VRGetCptOnSup

	* 22 June 94	2.3.1.0
		Manyam
		-	Modified the methods "VRGetCptOnSup()" and
		  	"VRGetNextOnCpt()" to support the processing
			when an eccentric component is placed wrt
			center point justification. Also did some
			cleanup.

	* 15-Nov-91	1.4.3.9

		Bruno
		- VRGetPlanes method now returns NULL_OBJID as planes
		  ids corresponding to a connect point instead of
		  returning an error status in the case the connect
		  point has no planes.

***********************************************************************/

class implementation VRGeneric;

#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "asmacros.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "VDmem.h"
#include "VRMath.h"
#include "VRparamdef.h"
#include "vrtools_pto.h"
#include "vrsegmen_pto.h"
#include "bslenvec.h"
#include "bsmkvec.h"
#include "bsnorvec.h"

//#define	vdsDEBUG	1
//#define	vdserrDEBUG	1

#include "vrdbgmacros.h"
#include "VRutilmacros.h"


extern GRclassid	OPP_VRCorrection_class_id;
extern GRclassid	OPP_VRHanger_class_id;
extern GRclassid	OPP_VRSupport_class_id;
extern GRclassid	OPP_ASsourcein_class_id;


from VRCorrection	import VRGetCptIndex;
from VRCnrlSeg		import VRget_terminators;
from VRCnrlSeg		import VRGetTopo;
from VRCnrlSeg		import VRget_planes;


/***********************************************************************/

method VRGetParams( IGRlong *msg; 	struct GRid *SysParamId;
					struct GRid *UserParamId;
					struct GRid *MissParamId )

{

	/* -- The parameters are the two first templates of the list -- */

	IGRint		status, NbRoots = 0;
	struct GRid	*buffer = NULL;

	SetProc( VRGeneric_VRGetParams ); Begin
	*msg = MSSUCC;

	status =
	om$send( msg	 = message NDnode.NDget_objects(
						ND_ROOT | ND_IN_BUF,
						NULL,
						0,
						&buffer,
						0,
						OM_K_MAXINT,
						&NbRoots ),
	           	targetid = my_id);
	as$status( action = RET_STATUS );

	__DBGpr_int("nbr of templates",NbRoots);
	__DBGpr_int("nbr of attributes",me->nNbAttr);

	if ( NbRoots >= me->nNbAttr && buffer )
	{
	  __DBGpr_obj(" System parameters Id",buffer[0]);
	  __DBGpr_obj(" User parameters Id",buffer[1]);
		if ( SysParamId )	*SysParamId= buffer[0];
		if ( UserParamId )	*UserParamId= buffer[1];
		if ( MissParamId )
		{
			if (me->nNbAttr>2)
			{
				__DBGpr_obj("Missing parameters Id",buffer[2]);
				*MissParamId      = buffer[2];
			}
			else
			{ /*| No Missing parameters' collection */
				MissParamId->objid= NULL_OBJID;
			}
		}/* end return missing parameters */

	}
	else /* No templates */
	{	/*| No Attributes */
		*msg = MSFAIL;
		if ( SysParamId )	SysParamId->objid	= NULL_OBJID;
		if ( UserParamId )	UserParamId->objid	= NULL_OBJID;
		if ( MissParamId )	MissParamId->objid	= NULL_OBJID;

	}
End
return ( OM_S_SUCCESS );

}/* end VRGetParams */

/*------------------------------------------------------------------------------
* 3-98 KDD
*
* method VRGetPrivateParams
*
* Well, That is how it works: By a kludgy design my collector parents may be
* also parents of other components. The result being that my attributes are
* not unique, but shared with other components. Have fun, a?
*
* That is why I created this method to return UNIQUE parent collectors.
* If the collectors are already private it works just like VRGetParams,
* otherwise it creates those private collectors, and reconnects them to my_id.
*----------------------------------------
*
* PARAMETERS:
*
* O: IGRlong              *msg            MSSUC if success and MSFAIL if not.
*
* O: struct GRid          *SysParamId     Returns the system parameters GRid.
*
* O: struct GRid          *UserParamId    Returns the user parameters GRid.
*
* O: struct GRid          *MissParamId    Returns the added parameters GRid.
*
------------------------------------------------------------------------------*/
method VRGetPrivateParams( IGRlong *msg;
                                        struct GRid *SysParamId;
                                        struct GRid *UserParamId;
                                        struct GRid *MissParamId )
{
  int			i, UpdateFlag = 0;

  IGRint		status, NbChildren;

  struct GRid		NewParId[3],
			*OldParId[3],
			*buffer;


SetProc( VRGeneric_VRGetPrivateParams ); Begin

  status = om$send( msg      = message VRGeneric.VRGetParams (msg,
					SysParamId, UserParamId, MissParamId ),
                    targetid = my_id);

  OldParId[0] = SysParamId;
  OldParId[1] = UserParamId;
  OldParId[2] = MissParamId;

if (SysParamId)  __DBGpr_obj("Old SysParamId ", *SysParamId);
if (UserParamId) __DBGpr_obj("Old UserParamId", *UserParamId);
if (MissParamId) __DBGpr_obj("Old MissParamId", *MissParamId);

/*-------------------------
# By default the new parameters are the old ones.
*------------------------*/
  for ( i = 0 ; i < 3; i++ ) {
      if ( OldParId[ i ] ) { NewParId[ i ] = *(OldParId[ i ]); }
      else                 { NewParId[ i ].objid = NULL_OBJID; }
  }

/*-------------------------
# Get unique System, User and Missing parameter collections.
* VR$ModifyCollection will create a brand new collection for us (VR_MERGE_COLL).
*------------------------*/
  for ( i = 0 ; i < 3; i++ ) {

      if ( !OldParId[ i ] || (OldParId[ i ]->objid == NULL_OBJID) ) continue;

      NbChildren = 0;
      status = om$send( msg      = message NDnode.NDget_objects
                                      (ND_CHILDREN | ND_IN_BUF, NULL, 0,
				       &buffer, 0, OM_K_MAXINT, &NbChildren),
                        targetid = OldParId[ i ]->objid,
                        targetos = OldParId[ i ]->osnum );

      if ( NbChildren > 1 ) {
	 UpdateFlag = 1;

	 NewParId[ i ].objid = NULL_OBJID;
         NewParId[ i ].osnum = OldParId[ i ]->osnum;

         VR$ModifyCollection (  p_msg      = msg,
                              Operation    = VR_MERGE_COLL,
                      p_InputCollectionId  = OldParId[ i ],
                     p_OutputCollectionId  = &NewParId[ i ] );

__DBGpr_obj("NewParId ", NewParId[ i ]);
     }
  }


/*-----------------------------------
# Update if Any of My collections is not unique.
*---------------------------------*/
  if (UpdateFlag == 1 ) {
     status = om$send( msg      = message VRGeneric.VRChgParams (msg,
				    &NewParId[0], &NewParId[1], &NewParId[2]),
                       targetid = my_id );

     if ( SysParamId ) *SysParamId = NewParId[0];
     if ( UserParamId) *UserParamId= NewParId[1];
     if ( MissParamId) *MissParamId= NewParId[2];
  }

if (SysParamId)  __DBGpr_obj("New SysParamId ", *SysParamId);
if (UserParamId) __DBGpr_obj("New UserParamId", *UserParamId);
if (MissParamId) __DBGpr_obj("New MissParamId", *MissParamId);


wrapup:
End
return (status);
}



/***********************************************************************/

method VRGetSupports ( IGRlong *msg;
                       IGRint   ArraySize;
                struct GRid     SupIds[];
                       IGRint  *NbSupports)

{

  /* -- The supports are the last templates of the list -- */
  SetProc( VRGeneric_VRGetSupports ); Begin

  *msg = MSSUCC;

  *NbSupports = me->nNbTopo;

  if ( SupIds )
  {
    IGRint            status, i,
                      NbRoots = 0 ;
    struct GRid       *buffer = NULL ;

    status =
    om$send (msg = message NDnode.NDget_objects
                                  (ND_ROOT | ND_IN_BUF, NULL, 0, &buffer,
                                   0, OM_K_MAXINT, &NbRoots ),
        targetid = my_id);

    __DBGpr_int(" NbRoots ", NbRoots );
    __DBGpr_int(" status  ", status );

    if( NbRoots && buffer ){
      for ( i=0; (i<*NbSupports && i<ArraySize); i++){
        SupIds[i]= buffer[NbRoots-(*NbSupports)+i];
        __DBGpr_obj(" Object ", SupIds[i] );
      }
    }
  }
   End
  return ( OM_S_SUCCESS );
}/* end VRGetSupports */

/***********************************************************************/

method VRGetPlanes ( IGRlong *msg;  IGRint ArraySize;
    	struct GRid PlaneIds[]; IGRint *NbPlanes; struct GRmd_env *md_env)

{

	/* -- The planes are the templates of my supports -- */

	IGRint		status;
	register IGRint	i;
	IGRlong		retmsg;
	struct GRid	SegId;

        SetProc( VRGeneric_VRGetPlanes ); Begin
	*msg = MSSUCC;

	__DBGpr_int("no supports",me->nNbCpts*3);

	*NbPlanes = (me->nNbCpts*3);

	if (PlaneIds==NULL)
	{
		*msg = MSSUCC;
		__DBGpr_com ("No planes");
                End
		return OM_S_SUCCESS;
	}
	else if ( ArraySize < (me->nNbCpts*3) )
	{
		*msg = MSFAIL;
		__DBGpr_com("MSFAIL-Array size no match for NbCpts");
                End
		return OM_S_SUCCESS;
	}


	/* -- Buffer is large enough -- */
	__DBGpr_me();
	for ( i=0; i<me->nNbCpts; i++)
	{
		IGRshort	nMyIndex;
		/* -- Get support on connect point -- */
		status =
		om$send ( msg = message VRGeneric.VRGetSupOnCpt
				( &retmsg, (IGRshort) i, &SegId, md_env ),
		targetid = my_id);
		__DBGpr_int("VRGetSupOnCpt return status", status);
		if ( ! (status & 1 & retmsg) )
		{
			/* -- If there is no support on this connect point -- */
			/* -- 	return NULL_OBJID as planes Ids -- */
			PlaneIds[i*3  ].objid=
			PlaneIds[i*3+1].objid=
			PlaneIds[i*3+2].objid= NULL_OBJID;

		}/* end return no planes for connect point */
		else
		{
			__DBGpr_int("cp",i);
			__DBGpr_obj("Segid",SegId);

			/* -- Get my index on the support -- */
			__DBGpr_com("Calling VRGeneric.VRGetIndex");
			status =
			om$send( msg	 = message VRGeneric.VRGetIndex(
							&retmsg,
							&SegId,
							&nMyIndex),
				targetid = my_id);
			__DBGpr_int("VRGeneric.VRGetIndex return status",
                                                                      status);
			as$status ( action = RET_STATUS );

			/*" Position %d on this segment\n",nMyIndex */

			/* -- Get planes from support -- */
                        __DBGpr_com("Calling VRCnrlSeg.VRget_planes");
			status =
			om$send ( msg = message VRCnrlSeg.VRget_planes
				( &retmsg,
				&PlaneIds[i*3],&PlaneIds[i*3+1],
				(nMyIndex)? NULL : &PlaneIds[i*3+2],
				(nMyIndex)? &PlaneIds[i*3+2] : NULL),
			targetid = SegId.objid,
			targetos = SegId.osnum );
			as$status ( action = RET_STATUS );

		}/* end return planes ids of the connect point */

	}/* end loop on cpts */
	 End
	return ( OM_S_SUCCESS );

}/* end VRGetPlanes */

/***********************************************************************/

method VRGetCorrections ( IGRlong *msg;  IGRint ArraySize;
			struct GRid CorIds[]; IGRint *NbCorrections)


{

	/* -- The corrections are lost among the children -- */

	IGRint		status, i,
			NbChildren = 0;
	struct GRid	*buffer = NULL;
	GRclassid	ChildClassId;

	SetProc( VRGeneric_VRGetCorrections ); Begin
	*msg = MSSUCC;

	status =
	om$send( msg	 = message NDnode.NDget_objects(
						ND_CHILDREN | ND_IN_BUF,
						NULL,
						0,
						&buffer,
						0,
						OM_K_MAXINT,
						&NbChildren ),
	           	targetid = my_id);
	as$status( action = RET_STATUS );

	__DBGpr_int(" NbChildren",NbChildren);

	__DBGpr_com(" Find correction objects among children");
	*NbCorrections=0;

	for ( i=0;(i<NbChildren) && buffer; i++)
	{
		/* -- ChildClass == CorrectionClass -> Add in list -- */

		om$get_classid (objid = buffer[i].objid,
				osnum = buffer[i].osnum,
				p_classid = &ChildClassId );

		if ( om$is_ancestry_valid
				( subclassid   = ChildClassId,
				  superclassid = OPP_VRCorrection_class_id )
		     == OM_S_SUCCESS )
		{
			__DBGpr_int(" Correction = child index",i);

			if ( (*NbCorrections < ArraySize) && (CorIds) )
			{
				CorIds[*NbCorrections]= buffer[i];
				__DBGpr_obj("CorIds",CorIds[*NbCorrections]);
			}
			(*NbCorrections)++;
		}/* end test on class */

	}/* end loop on children */

	__DBGpr_int(" Nbr Found correction objects",*NbCorrections);

	if ( (*NbCorrections > ArraySize) && (ArraySize != 0) && (CorIds) )
	{
		__DBGpr_com("ERROR -> Corrections not fully returned");
		*msg = MSFAIL;
	}

	End
	return ( OM_S_SUCCESS );

}/* end VRGetCorrections */

/***********************************************************************/

method VRGetHangers (  IGRlong		*msg;
                       IGRint		ArraySize;
		struct GRid		HangerIds[];
                       IGRint		*NbHangers;
                       IGRdouble	*dCpCoors;
		struct GRmd_env		*md_env)


{

	/* -- The corrections are lost among the children -- */

	IGRint		status,
			NbChildren = 0;

	register IGRint	i;
	struct GRid       *buffer = NULL ;
	GRclassid	ChildClassId;
	IGRlong		retmsg;

        SetProc( VRGeneric_VRGetHangers ); Begin

	*msg = MSSUCC;

	status =
	om$send( msg	 = message NDnode.NDget_objects(
						ND_CHILDREN | ND_IN_BUF,
						NULL,
						0,
						&buffer,
						0,
						OM_K_MAXINT,
						&NbChildren ),
	           	targetid = my_id);
	as$status( action = RET_STATUS );

	__DBGpr_int(" nbr children",NbChildren);

	/* -- Find hanger objects among children -- */

	*NbHangers=0;

	for ( i=0; i<NbChildren && buffer; i++)
	{
		/* -- ChildClass == HangerClass -> Add in list -- */

		om$get_classid (objid = buffer[i].objid,
				osnum = buffer[i].osnum,
				p_classid = &ChildClassId );

		if (( om$is_ancestry_valid
				( subclassid   = ChildClassId,
				  superclassid = OPP_VRHanger_class_id )
		     == OM_S_SUCCESS )                       ||
		    ( om$is_ancestry_valid
				( subclassid   = ChildClassId,
				  superclassid = OPP_VRSupport_class_id )
		     == OM_S_SUCCESS ))
		{
			__DBGpr_int("Hanger = Child Nbr",i);

			if ( (*NbHangers < ArraySize) )
			{
				/*" Id[%d] : <%d,%d>\n",*NbHangers,buffer[i].objid,buffer[i].osnum*/
				if (HangerIds)
				{
				  HangerIds[*NbHangers]= buffer[i];
				  __DBGpr_obj("HangerId",HangerIds[*NbHangers]);
				}
				if (dCpCoors)
				{
					IGRint			Index=-1;
					struct ret_struct	ParamStr;

					status=
					om$send ( msg = message ACncpx.ACgive_structure(
							(IGRint *)&retmsg,&Index, VR_N_LOC_PT,
							&ParamStr, md_env),
						targetid = buffer[i].objid,
						targetos = buffer[i].osnum );
					as$status ( action = RET_STATUS );
					if ( !(retmsg&1) )
                                        {
                                           End
                                           return OM_E_ABORT;
                                        }

					dCpCoors[(*NbHangers)*3]  =ParamStr.var.point_st.pt[0];
					dCpCoors[(*NbHangers)*3+1]=ParamStr.var.point_st.pt[1];
					dCpCoors[(*NbHangers)*3+2]=ParamStr.var.point_st.pt[2];

				}/* end return hanger's origin */

			}/* end return info */

			(*NbHangers)++;
		}/* end test on class */

	}/* end loop on children */

	/* KLUGE : wait for managment inter_OS */

	/*" %d Found hanger objects\n",*NbHangers*/

	if ( (*NbHangers > ArraySize) && (ArraySize != 0) && (HangerIds) )
	{
		__DBGpr_com("ERROR -> Hangers not fully returned");
		*msg = MSFAIL;
	}

	End
	return ( OM_S_SUCCESS );

}/* end VRGetHangers */

/***********************************************************************/

method	VRGetCptOnSup (
	IGRlong			*msg ;
	struct GRid 		*SegId;
	IGRshort 		*nCpNum;
	struct GRmd_env		*md_env	)
{
/* VRGetCptOnSup */

	IGRint		NbPoints;
	IGRdouble	dEndPoints[6],dCpCoor[3],dConAxis[3],dSegVect[3];
	IGRlong		retmsg;
	IGRint		status,i;
	IGRboolean	bCpOnLine=FALSE;
	IGRshort	nMyIndex,nTest;
	IGRshort	nFreeCpt;
	BSrc		rc;
	struct	GRid	MyId;

	/*A To be associated with a support, a connect point must be located
	   on the support and its connection vector must be, depending on
	   the extremity of the support the component is on, equal or
	   opposite to the support's vector */

	SetProc( VRGeneric_VRGetCptOnSup ); Begin

	/*A Verify arguments */
	if ( !SegId || !nCpNum )
	{
		__DBGpr_com("ERROR -> NULL Pointer given");
		*msg = MSFAIL;
		End
		return ( OM_E_INVARG );
	}
/*	__DBGpr_me();  */
	*msg = MSSUCC;
	MyId.objid = my_id;
	MyId.osnum = OM_Gw_current_OS;

	/*A Get my index on segment		*/
	status =
	om$send( msg	 = message VRGeneric.VRGetIndex(
			&retmsg, SegId, &nMyIndex),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	/*A decide the type of test to be made	*/
	if ( nMyIndex ) nTest=VR_OPPOSITE;
	else		nTest=VR_SAME;

     /*   __DBGpr_int("MyIndex", nMyIndex);  */

	/*A Get segment's end points */
	status =
	om$send( msg	 = message VRCnrlSeg.VRget_terminators(
			&retmsg, &NbPoints, md_env,
			dEndPoints, NULL),
		targetid = SegId->objid,
		targetos = SegId->osnum );
	as$status ( action = RET_STATUS );

	/*A Get segment's vector */
	status =
	om$send( msg	 = message VRCnrlSeg.VRGetTopo(
			&retmsg, dSegVect,NULL,
			NULL,NULL,NULL,md_env),
		targetid = SegId->objid,
		targetos = SegId->osnum );
	as$status ( action = RET_STATUS );

/********* DEBUG OUTPUT COMMENTED OUT
	if(nTest == VR_OPPOSITE)
	   __DBGpr_com(" Looking for connection opposite to");
	else
	   __DBGpr_com(" Looking for connection directed as");
	__DBGpr_vec(" ",dSegVect);
*/

	nFreeCpt = -1;

/*	__DBGpr_int("NbCpt",me->nNbCpts);  */

/*	__DBGpr_com("process all my connect points");  */
	for ( i=0 ; i< me->nNbCpts; i++ )
	{
	  __DBGpr_int("connection",i);

	  /*A Get connection axis */
	  status =
	  om$send( msg	 = message VRGeneric.VRGetCptGeom(
			&retmsg, (IGRshort) i, dCpCoor,
			dConAxis, NULL,	md_env),
		targetid = my_id);
	  as$status ( action = RET_STATUS );

/*	  __DBGpr_vec("Cpt Connection",dConAxis);  */
/*	  if ( BSlenvec ( &rc, dConAxis ) < VR_EPSILON ) */
	  if ( BSlenvec ( &rc, dConAxis ) < VRGetTol(VR_DIST_TOL) ) /*TR4578 */
	  {
/*		__DBGpr_int(" Origin = Cpt",i); */
		nFreeCpt = i;
		continue;
	  }


	  if ( bVRTestVect (&retmsg, dSegVect,dConAxis,nTest) )
	  {
		/*A If oriented as the segment */
		IGRdouble		dVect[3];

		/*A Verify that it is on the segment */

		/*A test for eccentric component and for center justifi-
		    cation						*/
		if ( VRIsEccentricComp( &retmsg, &MyId, md_env ) &&
			VRIsCenterJustified( &MyId, SegId, md_env ) )
		{
		  /*A get the origin coordinates	*/
		  status =
		  om$send( msg	= message VRGeneric.VRGetOrigCoor(
				&retmsg, dCpCoor, md_env),
			targetid = my_id);
		  as$status ( action = RET_STATUS );
		}

		BSmkvec ( &retmsg, dVect, dEndPoints, dCpCoor );
/*		if ( BSlenvec ( &retmsg, dVect ) > BSVALLENVEC ) *****/
		if ( BSlenvec ( &retmsg, dVect ) > VRGetTol(VR_DIST_TOL)) /*TR4578*/
		{
/*			__DBGpr_com("A Norme vector (Cpt,SegEndPt)"); */
			BSnorvec ( &retmsg, dVect );
/*DEBUG OUTPUT DISABLED HERE
			__DBGpr_vec("dVect",dVect);
			__DBGpr_vec("dEndPoints",dEndPoints);
			__DBGpr_vec("dCpCoor",dCpCoor);
*/
			if ( bVRTestVect (&retmsg, dSegVect,
					dVect,VR_COLINEAR) )
			{
/*				__DBGpr_com("CpOnLine");  */
				bCpOnLine = TRUE;
				break;
			}

		} else {
			/*A If also well oriented : End */
/*			__DBGpr_com("Found cpt on segment's end point 0"); */
			bCpOnLine = TRUE;
			break;
		}

	  } /*end if oriented same as the segment	*/

	}/* end loop on connect points */

	if ( bCpOnLine )
        {
/*		__DBGpr_int("Cpt found on line",i);  */
		*nCpNum = (IGRshort) i;
        }
	else {
		if ( nFreeCpt >= 0 )
			/*| Return Free point */
			*nCpNum = nFreeCpt;
		else
		{
/*			__DBGpr_com("ERROR -> Connect Point Not Found"); */
			*nCpNum = -1;
			End
			return ( OM_E_ABORT );
		}
	}
	End
	return ( OM_S_SUCCESS );

}/* end VRGetCptOnSup */

/***********************************************************************/

method VRGetSupOnCpt ( IGRlong *msg ; IGRshort nCpNum; struct GRid *SegId;
			struct GRmd_env *md_env)

{


	IGRlong		retmsg;
	IGRint		status, NbSegs = 0,i;
	IGRint		NbSegb = 0;
	IGRboolean	bFound;
	IGRshort	nFoundCp;
	struct GRid    *SegIds=NULL;

	SetProc( VRGeneric_VRGetSupOnCpt ); Begin

/*	__DBGpr_me();  */

	*msg= MSSUCC;

	if ( nCpNum < 0 || nCpNum >= me->nNbCpts )
	{
		__DBGpr_com("ERROR -> Bad Cpt Number");
		End
		return ( OM_E_INVARG );
	}

/*	__DBGpr_com( " Calling VRGetSupports ... " );  */
	status = om$send ( msg = message VRGeneric.VRGetSupports
					( &retmsg, 0, NULL, &NbSegb),
		targetid = my_id);

        NbSegb++;
/*	__DBGpr_int("NbSegb",NbSegb);  */
        SegIds = _MALLOC (NbSegb, struct GRid);

	if( SegIds == NULL )
        {
          End
          return OM_E_NODYNMEM; //added by alwin tr179802345
        }

	status = om$send ( msg = message VRGeneric.VRGetSupports
					( &retmsg, NbSegb, SegIds, &NbSegs ),
		targetid = my_id);
	//as$status ( action = RET_STATUS );
        as$status(); if ( ! (status & 1)){ _FREE (SegIds); return status; }

	/* -- Loop on supports to get the right cpt number -- */
	bFound=FALSE;
	for ( i=0; i<NbSegs && !bFound; i++ )
	{
		/*__DBGpr_int(" Trying segment",i); */
		status = om$send ( msg = message VRGeneric.VRGetCptOnSup
						( &retmsg, &SegIds[i],
						  &nFoundCp, md_env ),
			targetid = my_id);
		if ( !(status&1) || (retmsg!=MSSUCC) ) continue;

		bFound = ( nFoundCp == nCpNum );
	/*	__DBGpr_int("found cpt",nFoundCp); */
	}/* end loop on supports */

	/* -- Return result -- */

	if ( !bFound )
	{	*msg=MSFAIL;
		SegId->objid = NULL_OBJID;
	}
	else
	{
		i--;
		*SegId=SegIds[i];
/*		__DBGpr_obj("Found Seg",*SegId); */
	}

        _FREE (SegIds);

#ifdef UN_COMMENT
        /* Its a rare case if the control reaches this point... what I found
        is. When sketching out of the Nozzle which is in the reference file
        and when you try to find out the LS ( Parent ) connected to it.
        B'cas it will show only the ASsource object in the parent list and not
        VRCnrlSeg object. The solution is get VRCptIn connected to nozzle and
        get the LS thru that. Alwin for TR179802345 */

        if( SegId && SegId->objid == NULL_OBJID )
        {
           IGRint size, ret_size, NbChildren=0, i;
           struct GRid MyId, PretendId;
           struct GRid CptInId, *buffer=NULL;
           struct GRmd_env mod_env;

           MyId.objid = my_id;
           MyId.osnum = OM_Gw_current_OS;

           size = sizeof(mod_env);

           gr$get_module_env( msg    = msg,
                              sizbuf = &size,
                              buffer = &mod_env,
                              nret   = &ret_size );

           status = as$make_source(
                        go_grid = MyId,
                        mod_env = md_env,
                        as_os   = mod_env.md_id.osnum,
                        as_grid = &PretendId );

           __DBGpr_obj( " Prentendin Object Id ", PretendId );

           status =
           om$send( msg  = message NDnode.NDget_objects(
                                                ND_CHILDREN | ND_IN_BUF,
                                                NULL,
                                                0,
                                                &buffer,
                                                0,
                                                OM_K_MAXINT,
                                                &NbChildren ),
                        targetid = PretendId.objid,
                        targetos = PretendId.osnum );
           as$status( action = RET_STATUS );

           __DBGpr_int(" nbr children", NbChildren );

           if( ( !NbChildren ) || ( buffer[0].objid == NULL_OBJID ) )
           {
              *msg=MSFAIL;
              End
              return OM_S_SUCCESS;
           }

           CptInId.objid = NULL_OBJID;
           for( i=0; i<NbChildren; i++ )
           {
                GRclassid Classid;
                extern GRclassid OPP_VRCptIn_class_id;

                status = om$get_classid (
                                        objid = buffer[i].objid,
                                        osnum = buffer[i].osnum,
                                        p_classid = &Classid );
                if( Classid == OPP_VRCnrlSeg_class_id )
                    CptInId = buffer[i];
           }

           if( CptInId.objid == NULL_OBJID )
           {
              SegId->objid = NULL_OBJID;
              *msg=MSFAIL;
              End
              return OM_S_SUCCESS;
           }

           /* Get the Parents list and find out the VRCnrlSeg object which
           is the support we're interested in. Alwin */
           buffer = NULL;
           status =
           om$send( msg  = message NDnode.NDget_objects(
                                                ND_ROOT | ND_IN_BUF,
                                                NULL,
                                                0,
                                                &buffer,
                                                0,
                                                OM_K_MAXINT,
                                                &NbChildren ),
                        targetid = CptInId.objid,
                        targetos = CptInId.osnum );
            as$status( action = RET_STATUS );

            __DBGpr_int( " Nb. of Parents ", NbChildren );

            for( i=0; i<NbChildren; i++ )
            {
                GRclassid Classid;
                extern GRclassid OPP_VRCnrlSeg_class_id;

                status = om$get_classid (
                                        objid = buffer[i].objid,
                                        osnum = buffer[i].osnum,
                                        p_classid = &Classid );

                if( Classid == OPP_VRCnrlSeg_class_id )
                   *SegId = buffer[i];
            }
            __DBGpr_obj( " CnrlSegId ", *SegId );
        }
#endif

End
return ( OM_S_SUCCESS );

}/* end VRGetSupOnCpt */

/***********************************************************************/

method VRGetCorOnCpt ( IGRlong *msg ; IGRshort nCpNum; struct GRid *CorId;
			struct GRmd_env *md_env)

{

	IGRint		status;
register IGRint		i=0;
	IGRlong		retmsg;
	struct GRid    *CorIds;
	struct GRid	MyId;
	IGRboolean	bFound=FALSE;
	IGRint		NbCorrections;
	IGRint		NbCorrectbuf;
	IGRshort	nCorrectedCpNum;

	SetProc( VRGeneric_VRGetCorOnCpt ); Begin
*msg= MSFAIL;

MyId.objid = my_id;
MyId.osnum = OM_Gw_current_OS;

CorId->objid = NULL_OBJID;

	__DBGpr_str("szAABBCC",me->szAABBCC);

	__DBGpr_int(" Looking for correction on Cp#",nCpNum);

	/* -- Get all corrections -- */

	status=
	om$send ( msg = message VRGeneric.VRGetCorrections
			( &retmsg, 0, NULL, &NbCorrectbuf),
		targetid = my_id );

        NbCorrectbuf++;

        CorIds = _MALLOC (NbCorrectbuf, struct GRid);
	status=
	om$send ( msg = message VRGeneric.VRGetCorrections
			( &retmsg, NbCorrectbuf, CorIds, &NbCorrections),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	__DBGpr_int("nbr of correction objects",NbCorrections);
	while ( i<NbCorrections && !bFound )
	{

		status=
		om$send ( msg = message VRCorrection.VRGetCptIndex
				( &retmsg, &MyId, &nCorrectedCpNum),
			targetid = CorIds[i].objid,
			targetos = CorIds[i].osnum );
		as$status ( action = RET_STATUS );

		__DBGpr_int("Correction",i);
		__DBGpr_int("for Cpt",nCorrectedCpNum);
		if ( nCorrectedCpNum == nCpNum )
		{
			bFound = TRUE;
			*msg   = MSSUCC;
			*CorId = CorIds[i];
			__DBGpr_obj(" Correction CorId",*CorId);
		}
		else /* try next correction */
		{
			i++;
		}
	}/* end loop on correction objects */

        _FREE (CorIds);
End
return ( OM_S_SUCCESS );

}/* end VRGetCorOnCpt */

/***********************************************************************/

method	VRGetNextOnCpt (
	IGRlong			*msg ;
	IGRshort		nCpNum;
	struct GRid		*NextId;
	IGRshort		*nNextCpNum;
	IGRshort		nSizBuf;
	IGRshort		*nNbVia;
	struct GRid		*ViaIds;
	IGRshort		*nViaCpNum;
	struct GRmd_env 	*md_env	)
{
/* VRGetNextOnCpt */
	IGRboolean		bValidFound;
	IGRint			status;
	IGRlong			retmsg;
	struct GRid		SegId,CompIds[2],TmpFromId,TmpNextId;
	IGRint			NbComps;
	IGRint			WaitIndex;
	IGRshort		nScanCpNum;
	IGRdouble		dConAxis[3], dCpCoor[3];

	SetProc( VRGeneric_VRGetNextOnCpt ); Begin

	__DBGpr_int(" Get Next comp on cpt#",nCpNum);
	__DBGpr_me();

	*msg= MSFAIL;
	if ( NextId )
		NextId->objid = NULL_OBJID;
	if ( nNextCpNum )
		*nNextCpNum   = -1;

	/*A Get Segment associated with the connect point */
	status =
	om$send ( msg = message VRGeneric.VRGetSupOnCpt(
			&retmsg, nCpNum, &SegId, md_env ),
		targetid = my_id);
	as$status ( action = RET_STATUS );
	if ( retmsg != MSSUCC )
	{
		__DBGpr_com("NO CONNECTION ON THIS CONNECT POINT");
		return ( OM_S_SUCCESS );
	}
	/*A Get connection axis */
	status =
	om$send( msg	 = message VRGeneric.VRGetCptGeom(
			&retmsg, nCpNum, dCpCoor,
			dConAxis, NULL,	md_env),
		targetid = my_id);
	as$status ( action = RET_STATUS );

	__DBGpr_vec("Cpt Connection",dConAxis);

	/*A reverse axis for selection on the next component */
	dConAxis[0] = -dConAxis[0];
	dConAxis[1] = -dConAxis[1];
	dConAxis[2] = -dConAxis[2];

	TmpFromId.objid = my_id; TmpFromId.osnum = OM_Gw_current_OS;

	/*A loop to find Next component with valid connection */

	do
	{
	  __DBGpr_obj(" Progress on segment",SegId);

	  /*A Get segment's children ( should only be component objects) */
	  status =
	  om$send( msg	 = message VRCnrlSeg.VRget_terminators(
				&retmsg, &NbComps, md_env,
				NULL, CompIds),
	           	targetid = SegId.objid,
			targetos = SegId.osnum );
	  as$status( action = RET_STATUS );

	  __DBGpr_int("NUMBER OF COMPONENTS ON SEGMENT",NbComps);

	  if ( NbComps != 2 )
	  {
		__DBGpr_com(
                  "ERROR --> segment has not the right number of components");
		return (OM_S_SUCCESS);
	  }
	  /*A Select the one that is not me*/
	  if ( 	CompIds[0].objid == TmpFromId.objid &&
		CompIds[0].osnum == TmpFromId.osnum )
	  {
		__DBGpr_com("Take second child");
		TmpNextId = CompIds[1];
          }
	  else
	  {
		__DBGpr_com("Take first child");
		TmpNextId = CompIds[0];
	  }
	  /*A process wrt center point if i am an eccentric comp
	      and placed wrt center				*/
	  if ( VRIsEccentricComp( &retmsg, &TmpFromId, md_env ) &&
		VRIsCenterJustified( &TmpFromId, &SegId, md_env ) )
	  {
	    status =
	    om$send( msg	= message VRGeneric.VRGetOrigCoor(
				&retmsg, dCpCoor, md_env),
		targetid = my_id);
	    as$status ( action = RET_STATUS );
	  }

	  status=
	  om$send ( msg = message VRGeneric.VRSelectCptByGeom(
			&retmsg, dCpCoor, dConAxis,
			&nScanCpNum, md_env ),
		targetid = TmpNextId.objid,
		targetos = TmpNextId.osnum );
	  as$status ( action = RET_STATUS );

	  if ( (bValidFound = (retmsg == MSSUCC)) )
	  {
		/*A Valid Next found */
		__DBGpr_com("valid next");

		/*A If the next 's going to be deleted get its next */
		/*C -1 if not waiting */
		status =
		NDis_waiting(	GR_DELETED, 0, &TmpNextId,
				&WaitIndex, NULL, NULL, 1);

		if ( WaitIndex != -1 )
		{
			/*C scan further */
			__DBGpr_com("Next will be deleted, scan further");
			/*A Get its connect point that looks like mine */
			dConAxis[0]=-dConAxis[0];
			dConAxis[1]=-dConAxis[1];
			dConAxis[2]=-dConAxis[2];

			status=
			om$send ( msg = message VRGeneric.VRSelectCptByGeom(
					&retmsg, dCpCoor, dConAxis,
					&nScanCpNum, md_env ),
				targetid = TmpNextId.objid,
				targetos = TmpNextId.osnum );
			as$status ( action = RET_STATUS );

			/*Aif no such connect point => no next component */
			if ( retmsg == MSSUCC )
			{
			  /*A Jump to next component */
			  /*A Get its next component on this connect point*/

			  __DBGpr_int("for next, Scan on cpt",nScanCpNum);
			  status=
			  om$send ( msg = message VRGeneric.VRGetNextOnCpt(
					msg, nScanCpNum, NextId,
					nNextCpNum, nSizBuf, nNbVia,
					ViaIds, nViaCpNum, md_env ),
				targetid = TmpNextId.objid,
				targetos = TmpNextId.osnum );
			  as$status ( action = RET_STATUS );
			}/* end jump to next component */

		}/* end scan further */
		else
		{
			*msg = MSSUCC;

			/*A Next is selected */
			if ( NextId )
			{
				/*A Return the next component	*/
				*NextId = TmpNextId;
			        __DBGpr_obj(" NextId", *NextId);
			}
			if ( nNextCpNum )
			{
				/*A Return the Next comp connect point */
				status=
				om$send ( msg = message VRGeneric.VRGetCptOnSup(
						&retmsg, &SegId,
						nNextCpNum, md_env ),
					targetid = TmpNextId.objid,
					targetos = TmpNextId.osnum );
				as$status ( action = RET_STATUS );
				__DBGpr_int(" NextCp",*nNextCpNum);

			}/* end return next connect point */

		}/* end next wont get deleted */

	  }/* end Valid next found */
	  else
	  {	/*A navigate via supports to ghet the one after */
		IGRboolean	bFound = 0;
		struct GRid    *SegIds = NULL;
		IGRint		NbSegs = 0;
		IGRint		NbSegb = 0;

		__DBGpr_int("invalid next, retmsg",retmsg);
		status = om$send ( msg = message VRGeneric.VRGetSupports
				       (&retmsg, 0, NULL,  &NbSegb),
			targetid = TmpNextId.objid,
			targetos = TmpNextId.osnum );
                as$status ( action = RET_STATUS );

                NbSegb++;
                SegIds = _MALLOC (NbSegb, struct GRid);
                if ( SegIds == NULL ) return OM_E_NODYNMEM;

		/*A Next is not Valid */
		status = om$send ( msg = message VRGeneric.VRGetSupports
				(&retmsg, NbSegb, SegIds, &NbSegs ),
			targetid = TmpNextId.objid,
			targetos = TmpNextId.osnum );
		//as$status ( action = RET_STATUS );
                as$status(); if ( ! (status & 1)){ _FREE (SegIds); return status; }

		/* select the prolongation segment among the Next's supports */
		VRget_segment_to_notify( &retmsg, NbSegs, SegIds,
				&SegId,&SegId, md_env, &bFound );

		__DBGpr_obj("From VRget_segment_to_notify, SegId",SegId);
		__DBGpr_int("bFound", bFound);

		if (!bFound)
		{
			__DBGpr_com("ERROR -> cannot go further in the line");
                        _FREE (SegIds);
                        End
			return OM_E_ABORT;
		}
		/*A Get Next component on segment and return the one skept as via */
		TmpFromId = TmpNextId;
		if (nNbVia)
		{
			if (ViaIds) 	ViaIds[*nNbVia] 	= TmpNextId;
			if (nViaCpNum) 	nViaCpNum[*nNbVia] 	= nScanCpNum;
			*nNbVia += 1;
		}

                _FREE (SegIds);
	  }/* end no valid next found */

	} while ( !bValidFound );

	End
	return ( OM_S_SUCCESS );

}/* end VRGetNextOnCpt */

end implementation VRGeneric;


