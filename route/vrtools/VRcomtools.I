/* $Id: VRcomtools.I,v 1.13 2002/06/03 21:54:14 anand Exp $  */
/***************************************************************************
 * I/ROUTE
 *
 * File:	vrtools/VRcomtools.I
 *
 * Description: Library of functions to evaluate and recompute legacy files
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcomtools.I,v $
 *	Revision 1.13  2002/06/03 21:54:14  anand
 *	TR 6061
 *	
 *	Revision 1.12  2002/04/10 20:44:53  louis
 *	TR5649-Standardize tolerance
 *
 *	Revision 1.11  2001/10/25 19:37:24  louis
 *	Modified to allow for 0 length segments
 *
 *	Revision 1.8  2001/10/01 18:42:45  louis
 *	TR5154-add COz_compoint, VRfixtopo, and COz_fixsegs to Validate Route
 *
 *	Revision 1.7  2001/09/19 15:01:57  louis
 *	initialize count
 *
 *	Revision 1.6  2001/09/18 16:39:26  louis
 *	initialize a variable
 *
 *	Revision 1.5  2001/09/14 18:42:46  louis
 *	Added tests for bad planes on CCOMPs.
 *
 *	Revision 1.4  2001/08/24 17:54:08  louis
 *	deleted unneeded prints to backscreen
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/03/01  law   TR4724-Shifting duct syndrome
 * 09/14/01  law   TR4724-Added tests for bad planes on CCOMPs
 * 09/28/01  law   TR5154-added COz_compoint,VRfixtopo,and COz_fixsegs to the
 *		   Validate Route command.
 * 10/17/01  law   TR5470-Added detection/correction of the offset of the split.
 * 10/17/01  law   TR5650-Modified the evaluation/symbolization interfaces to
 *		   allow offset values to drive the symbolization.
 * 10/25/01  law   TR5650-Allow for 0 length segments
 * 04/08/02  law   TR5649-standardize tolerance with VRGetTol
 * 06/03/02  Anand TR6061 - Some cases of recompute where Control Seg has only
 *		   one component child, has to be specially handled.
 ***************************************************************************/

class implementation Root;

#include <stdio.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "OMminimum.h"
#include "VRdimdef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "AS_status.h"
#include "VRattr_def.h"
#include "vrdbgmacros.h"
#include "exdef.h"
#include "ex.h"
#include "nddef.h"
#include "asbox.h"
#include <math.h>
#include "exmacros.h"
#include "VRmacros.h"
#include "bsdotp.h"
#include "bsparameters.h"
#include "bsdistptpt.h"
#include "bsnorvec.h"
#include "OMerrordef.h"
#include "VRutildef.h"
#include "VRchannel.h"
#include "VRcompdef.h"
#include "vrparameters.h"
#include "v_drw.h"
#include "vddgndef.h"
#include "VRMath.h"
/***
#include "vdVALmacros.h"
***/

#define ORPHAN 0
#define CONSTPLANECLS	1
#define SEGMENTCLS	2
#define COMPOINTCLS	3
#define OTHERCLS	4

extern GRclassid OPP_VRcompoint_class_id;
extern GRclassid OPP_VRConcComp_class_id;
extern GRclassid OPP_VRCnrlSeg_class_id;
extern GRclassid OPP_VRplane_class_id;

extern		VCobjInActiveSpace();
extern		VRskxform();
extern		VDvaladdObject();
extern		VD_drwFreeOutputData();
extern		VDsetAttDrSymb();
extern		VDgetVdCollId();

extern		MAidmx();
from	VRCnrlSeg	import	VRget_terminators,VRGetTopo;
from	NDnode		import	NDget_objects, NDdelete;
from	GRvg		import	GRdelete,GRdetplane,GRgetsymb,GRputsymb;
from	NDnode		import	NDconnect,NDplace,NDchange_connect;
from	NDnode		import	NDcompute_node, ASreturn_go;
from	VRGeneric	import	VRGetOrigCoor, VRGetNumberOfCpts, VRGetStatus;
from	VRGeneric	import	VRGetIndex,VRGetSupOnCpt,VRGetCptGeom;
from	VRGeneric	import	VRGetCptOnSup;
from	VRComponent	import	ACgive_structure;
from	VRConcComp	import	VRGetPlanesOnCpt;
from	VDSroot		import	VDgetAttrDrivenSymb;

/*************************************************************************/
/* Function: VRGetClsType						 */
/* Input: GRid of object						 */
/* Output								 */
/*   *nObjType = (null objid)	   (0)					 */
/*   *nObjType = SEGMENT	   (1)					 */
/*   *nObjType = COMPOINT	   (2)					 */
/*   *nObjType = CONSTPLANE	   (3)					 */
/*   *nObjType = OTHERCLS	   (4)					 */
/* Intended for use by compoint maintenance functions			 */
/*************************************************************************/

IGRlong VRGetClsType( nObjType, OBJ_Id )
IGRint *nObjType;
struct GRid OBJ_Id;
{
  IGRlong sts;
  GRclassid ClassId;

  if( OBJ_Id.objid == NULL_OBJID ) 
  {
     *nObjType = ORPHAN;
     return 1;
  }

  sts = om$get_classid( objid = OBJ_Id.objid,
			osnum = OBJ_Id.osnum,
			p_classid = &ClassId );

   
   if( ClassId == OPP_VRCnrlSeg_class_id )
   {
     *nObjType = SEGMENTCLS;
   }
   else if ( ClassId == OPP_VRcompoint_class_id)
   {
     *nObjType = COMPOINTCLS;
   }
   else if ( ClassId == OPP_VRplane_class_id )
   {
     *nObjType = CONSTPLANECLS;
   }
   else
   {
     *nObjType = OTHERCLS;
   }

   return 1;
}
/********************************************************************/
/* Return the distance between 2 points. Returns 0 for < BS */
/********************************************************************/
IGRlong VRgetdist(firstpt,secndpt,dist)
IGRdouble *firstpt,*secndpt,*dist;
{
  BSrc		  rc;
  if(( fabs(firstpt[0]-secndpt[0]) < VRGetTol(VR_DIST_TOL) ) &&
     ( fabs(firstpt[1]-secndpt[1]) < VRGetTol(VR_DIST_TOL) ) &&
     ( fabs(firstpt[2]-secndpt[2]) < VRGetTol(VR_DIST_TOL) ))
  {
     *dist = 0;
     return 1;
  }
  else
  {
     *dist = BSdistptpt( &rc, firstpt, secndpt );
  }
  return 1;
}
/********************************************************************/
/* Given the CCOMP and segment, identifies the cpt on the ccomp     */
/********************************************************************/
IGRlong VR_find_ccomp_cpt(segid,loc_obj,ccompcpt,gap,ccmppln,md_env)
struct GRid	segid;
struct GRid	loc_obj;  /* CCOMP Id */
IGRshort	*ccompcpt;
IGRdouble	*gap;
IGRint		*ccmppln;
struct GRmd_env *md_env;
{
  IGRlong	sts, msg;
  IGRint	k,closest_cpt;
  IGRdouble	dnEndPoints[6];
  IGRdouble	shrtdist,dist0;
  IGRdouble	CptCoord[3];
  IGRint	endsmatch;
  IGRshort	shrtndx,kshrt;
  IGRint	nCpNum,nbpts;
  IGRmatrix   Matrix,plnmtrx;
  IGRshort mattype;
  struct IGRplane plninfo;
  struct GRid go_planes,planeids[3];
  IGRdouble locpoint[12],locnormal[12];
  IGRdouble tmp_vector[3],plnvec[3];
  IGRdouble dX[3],dY[3];
  IGRlong  retcode;
  BSrc	   bsretcode;
  IGRdouble dotp;


  *ccmppln = 0;  /* default is planes are OK */
     /* Get the no of cpts */
  sts = om$send( msg	  = message VRGeneric.VRGetNumberOfCpts
					      ( &retcode, &nCpNum, md_env ),
		 senderid = NULL_OBJID,
		 targetid = loc_obj.objid,
		 targetos = loc_obj.osnum );
  sts = om$send( msg	  = message VRGeneric.VRGetIndex(
		    &retcode,&segid,&shrtndx),
			senderid = NULL_OBJID,
			targetid = loc_obj.objid,
			targetos = loc_obj.osnum );
  nbpts = 2;
  sts = om$send( msg	 = message VRCnrlSeg.VRget_terminators(
			   &retcode, &nbpts, md_env,
			   dnEndPoints, NULL),
			 senderid = NULL_OBJID,
			 targetid = segid.objid,
			 targetos = segid.osnum);
  kshrt = 0;
  sts = om$send( msg	  = message VRGeneric.VRGetCptGeom
				 ( &retcode, kshrt, CptCoord, NULL,
				   NULL, md_env ),
		      senderid = NULL_OBJID,
		      targetid = loc_obj.objid,
		      targetos = loc_obj.osnum );

  sts = VRgetdist(&dnEndPoints[shrtndx*3],CptCoord,&shrtdist);
  closest_cpt = 0; 
  for(k=1; k<nCpNum; k++)
  {
     kshrt = (IGRshort) k;
     /* Get the segment end closest to my cpt */
     sts = om$send( msg      = message VRGeneric.VRGetCptGeom
			      ( &retcode, kshrt, CptCoord, NULL,
				NULL, md_env ),
		   senderid = NULL_OBJID,
		   targetid = loc_obj.objid,
		   targetos = loc_obj.osnum );
     sts = VRgetdist(&dnEndPoints[shrtndx*3],CptCoord,&dist0);
     if(dist0 < shrtdist)
     {
	shrtdist = dist0;
	closest_cpt = k;
     }
   }
   *gap = shrtdist;
   *ccompcpt = (IGRshort) closest_cpt;
   sts = om$send( msg	   = message VRGeneric.VRGetCptGeom
				 ( &retcode, *ccompcpt, CptCoord, dX,
				   dY, md_env ),
		      senderid = NULL_OBJID,
		      targetid = loc_obj.objid,
		      targetos = loc_obj.osnum );

   plninfo.point = &locpoint[0];
   plninfo.normal = &locnormal[0];

   sts = om$send( msg	   = message  VRConcComp.VRGetPlanesOnCpt(
				       &retcode, *ccompcpt, planeids, md_env), 
		      senderid = NULL_OBJID,
		      targetid = loc_obj.objid,
		      targetos = loc_obj.osnum );

   for(k = 0; k<3; k++)
   {
      sts = om$send( msg      = message NDnode.ASreturn_go
					   ( &go_planes, &mattype, plnmtrx ),
			senderid = NULL_OBJID,
			targetid = planeids[k].objid,
			targetos = planeids[k].osnum );

      sts = om$send(msg = message GRvg.GRdetplane(&retcode,&mattype,
			    plnmtrx, &plninfo),
			senderid = NULL_OBJID,
			targetid = go_planes.objid,
			targetos = go_planes.osnum );

      dotp = BSdotp( &bsretcode, plninfo.normal, dX );
      if(fabs(1- fabs(dotp)) > VRGetTol(VR_ORTHO_TOL))
      {
	if(fabs(dotp) > VRGetTol(VR_ORTHO_TOL))
	{
	  *ccmppln = 1;
	}
      }

   }
   return 1;
}
/*************************************************************************/
/* Function: VREvalCompoints						 */
/* Input:  Model Environ data						 */
/* Output:								 */
/* Collects, analyze, deletes, and returns existing VRcompoints for the  */
/* active object space. It does not rebuild the compoints		 */
/*************************************************************************/
IGRlong VREvalCompoints(md_env,compt,outbuff,badcompt,compid)
  struct GRmd_env	*md_env;
  struct GRid	compt;
  IGRchar *outbuff;
  IGRint *badcompt;
  struct GRid *compid;
{
struct GRid	ObjParents[40],ComParents[40];
IGRint NbParents,NbCParents;
IGRint termnotfound,segfound,oursegnotfound,planenotfound;
IGRint i,j,k,kk,k0,k1;
IGRint childCNT;
struct GRid *childIDs=NULL;
IGRint Nbsegparents,nObjCls,segend,lsegend,nbpts,firstnotfound,segmentsmatch;
IGRint comphassegs,NbPoints,nSgParents,no_plns,shrhit[3],no_segs,no_match;
IGRdouble d0EndPoints[6],dnEndPoints[6],dist0,dist1,dOrigCoor[3];
struct GRid SegParents[40],CompIds[2],loc_obj,PlnParents[10],cmptplane[40];
struct GRid shrpln[40],chkplane[3],cmpid[2];
GRclassid     CompClassId;
IGRlong       sts, msg;
IGRshort     nStatus,ccompcpt;
IGRint plnnotfound;
struct GRid segid;
IGRdouble gapval,endcoord[3];
IGRint endsmatch,jj,no_shared_planes;
IGRlong  retcode;
IGRint badpln,otherend,ccpln[3],notshared;
IGRshort shrtndx;
struct GRid CCmpPlns[20];
struct GRid go_planes;
IGRshort mattype;
IGRdouble plnmtrx[16];
struct IGRplane kplninfo[20];
IGRdouble points[60],normal[60];
IGRdouble vec[3];
     /* Get the parent planes of the compoint */
     sts = om$send( msg = message NDnode.NDget_objects(
				    ND_ROOT, ComParents, 40,
				    NULL, 0, OM_K_MAXINT, &NbCParents ),
			  senderid = NULL_OBJID,
			  targetid = compt.objid,
			  targetos = compt.osnum );

     __DBGpr_obj("Evaluate Compoint ID ",compt);
     if(NbCParents < 1)
     {
       strcpy(outbuff, "Compoint object with no planes should be deleted");
       *badcompt = 1;
       compid->objid = NULL_OBJID;
       compid->osnum = NULL;
       return 1;
     }
     /* Check for any compoint who has only planes for parents */
     termnotfound = 1;
     for(j=0;j<NbCParents && termnotfound;j=j+1)
     {
	sts = VRGetClsType( &nObjCls, ComParents[j] );
	if(nObjCls != CONSTPLANECLS)
	{
	    sprintf(outbuff,
	      "Compoint has non-plane object %d for parent-delete compoint\n",
		      ComParents[j].objid);
	   *badcompt = 1;
	}
	else
	{
	   childIDs = NULL;
	   om$send( msg = message
		   NDnode.NDget_objects( ND_CHILDREN | ND_IN_BUF,
					 NULL,
					 0,
					 &childIDs,
					 0,
					 OM_K_MAXINT,
					 &childCNT ),
			  senderid = NULL_OBJID,
		   targetid = ComParents[j].objid,
		   targetos = ComParents[j].osnum);

	   __DBGpr_com( " processing the Children to planes" );
	   segfound = 0;
	   oursegnotfound = 1;
	   for(k = 0; k < childCNT && oursegnotfound; k = k + 1)
	   {
//printf("Processing child %d of plane being objid %d\n",k,ComParents[j].objid);
	      sts = VRGetClsType( &nObjCls, childIDs[k] );
		 if(nObjCls == SEGMENTCLS)
		 {
		   segfound = 1;
		   /*** is this plane the terminal plane of the segment ***/
		   segid.objid = childIDs[k].objid;
		   segid.osnum = childIDs[k].osnum;
		   __DBGpr_obj("Looking at seg ",segid);
		   sts = om$send( msg = message NDnode.NDget_objects(
				    ND_ROOT, SegParents, 10,
				    NULL, 0, OM_K_MAXINT, &Nbsegparents ),
			  senderid = NULL_OBJID,
			  targetid = segid.objid,
			  targetos = segid.osnum );
		   planenotfound = 1;
		   for(kk=0;kk<Nbsegparents && planenotfound;kk++)
		   {
		     sts = VRGetClsType( &nObjCls, SegParents[kk] );
		     if(nObjCls == CONSTPLANECLS)
		     {
		       planenotfound = 0;
		       if(SegParents[kk].objid == ComParents[j].objid)
		       {
			  __DBGpr_obj("first terminal plane of seg is same as plane of compoint",ComParents[j]);
			 termnotfound = 0;
			 segend = 0;
			 oursegnotfound = 0;
		       }
		       else if(SegParents[kk+3].objid == ComParents[j].objid)
		       {
			  __DBGpr_obj("last terminal plane of seg is same as plane of compoint",ComParents[j]);
			 termnotfound = 0;
			 segend = 1;
			 oursegnotfound = 0;
		       }

		     }
		   }

		 }
	   }
	   if(!segfound)
	   {
	      strcpy(outbuff,
	       "None of the planes of the compoint have a segment-delete compoint");
	      *badcompt = 1;
	      compid->objid = NULL_OBJID;
	      compid->osnum = NULL;
	      return 1;
	   }
	}
     } /* end of j loop */
     if(termnotfound)
     {
	strcpy(outbuff,
	  "component for compoint not identifiable - delete compoint");
	*badcompt = 1;
	compid->objid = NULL_OBJID;
	compid->osnum = NULL;
	return 1;
     }
     CompIds[0].objid = CompIds[1].objid = NULL_OBJID;
     sts = om$send( msg     = message VRCnrlSeg.VRget_terminators(
			   &retcode, &nbpts, md_env,
			   NULL, CompIds),
			 senderid = NULL_OBJID,
			 targetid = segid.objid,
			 targetos = segid.osnum);
//printf("segid %d has component-terminators %d %d\n",segid.objid,CompIds[0].objid,CompIds[1].objid);

     loc_obj = CompIds[segend];
//printf("component %d on segend %d of segment %d is matched to compoint %d\n",loc_obj.objid,segend,segid.objid,compt.objid);

     sts = om$get_classid( p_classid = &CompClassId,
			   objid = loc_obj.objid,
			   osnum = loc_obj.osnum );

     if ( om$is_ancestry_valid( subclassid   = CompClassId,
			     superclassid   = OPP_VRConcComp_class_id )
		  == OM_S_SUCCESS )
     {
	/* component is a CCOMP */
	sts = VR_find_ccomp_cpt(segid, loc_obj,
			&ccompcpt,&gapval,&badpln,md_env);
	*badcompt = 0;
	compid->objid = NULL_OBJID;
	compid->osnum = NULL;
	outbuff[0] = '\0';

	if(badpln)
	{
	   *badcompt = 1;
	   compid->objid = loc_obj.objid;
	   compid->osnum = loc_obj.osnum;

	   strcpy(outbuff, "CCOMP bad planes-replace component");
	   /*** Get the segment planes ***/
	   sts = om$send( msg = message NDnode.NDget_objects(
			     ND_ROOT, PlnParents, 40,
			     NULL, 0, OM_K_MAXINT, &nSgParents ),
			   senderid = NULL_OBJID,
			   targetid = segid.objid,
			   targetos = segid.osnum );
	   /*** Get the CCOMP planes ***/

	   sts = om$send( msg	   = message VRGeneric.VRGetIndex(
			     &retcode,&segid,&shrtndx),
			   senderid = NULL_OBJID,
			   targetid = loc_obj.objid,
			   targetos = loc_obj.osnum );

	   sts = om$send( msg = message VRGeneric.VRGetPlanesOnCpt(
			      &msg, ccompcpt, CCmpPlns, md_env),
			   senderid = NULL_OBJID,
			   targetid = loc_obj.objid,
			   targetos = loc_obj.osnum );
	   /*** Check the segment planes against the CComp ***/
	   /*** If not shared, add to the compoint planes  ***/
	   otherend = 0;
	   no_plns = 0;
	   if(shrtndx == 0) otherend = 3;
	   ccpln[0]=ccpln[1]=ccpln[2]=1;
	   for(k=0; k<4; k++)
	   {
	      notshared = 0;
	      if(k != otherend)
	      {
		 notshared = 1;
		 for (kk=0; kk<3; kk++)
		 {
		    if((CCmpPlns[kk].objid == PlnParents[k].objid) &&
		       (CCmpPlns[kk].osnum == PlnParents[k].osnum))
		    {
		      notshared = 0;
		      ccpln[kk] = 0;
		    }
		 }
	       }
	       if(notshared)
	       {
		  cmptplane[no_plns] = PlnParents[k];
		  no_plns++;
	       }
	     }
	     for(kk=0;kk<3;kk++)
	     {
	       if(ccpln[kk])
	       {
		  cmptplane[no_plns] = CCmpPlns[kk];
		  no_plns++;
	       }
	     }
	 /* Now compare to the original list of planes for the compoint ****/
	 for(k=0; k<NbCParents; k++)
	 {
	    plnnotfound = 1;
	    for( kk=0; kk<no_plns && plnnotfound; kk++)
	    {
	      if(ComParents[k].objid == cmptplane[kk].objid)
	      {
		plnnotfound = 0;
	      }
	    }
	    if(plnnotfound)
	    {
	      sprintf(outbuff,
		"component compoint %d has wrong planes -replace compoint",compt.objid);
	      return 1;
	    }
	 }
       }
       return 1;
     }
     else if ( om$is_ancestry_valid( subclassid   = CompClassId,
			     superclassid   = OPP_VRComponent_class_id )
		  == OM_S_SUCCESS )
     {
	__DBGpr_obj("EVALUATE component id ******************************************",loc_obj);
	for(k=0; k<20; k++)
	{
	   kplninfo[k].point  = &points[3*k];
	   kplninfo[k].normal = &normal[3*k];
	}
	/* process a component */
	sts = om$send( msg	= message VRGeneric.VRGetStatus(&msg,&nStatus),
		    senderid = NULL_OBJID,
		    targetid = loc_obj.objid,
		    targetos = loc_obj.osnum );
	/* Check if component is a correction */
	if ( !(nStatus&VR_CORRECTION) )
	{
	  /* Get the parents of the component */
	  sts = om$send( msg = message NDnode.NDget_objects(
				    ND_ROOT, ObjParents, 40,
				    NULL, 0, OM_K_MAXINT, &NbParents ),
		   senderid = NULL_OBJID,
		   targetid = loc_obj.objid,
		   targetos = loc_obj.osnum );

	  firstnotfound = 1;
	  segmentsmatch = 1;
	  comphassegs = 0;
	  for(j=0; j<NbParents && firstnotfound; j = j + 1)
	  {
	     sts = VRGetClsType( &nObjCls, ObjParents[j] );
	     /*** We only process segments ***/
	     if(nObjCls == SEGMENTCLS)
	     {
		__DBGpr_obj("First seg ",ObjParents[j]);
		comphassegs = 1;
		firstnotfound = 0;
		/* Get the end coordinates of the first segment*/
		om$send( msg	 = message VRCnrlSeg.VRget_terminators(
			  &msg, &NbPoints, md_env,
			  d0EndPoints, cmpid),
		  senderid = NULL_OBJID,
		  targetid = ObjParents[j].objid,
		  targetos = ObjParents[j].osnum );
		/* Get the component origin */
		sts = om$send( msg = message VRGeneric.VRGetOrigCoor ( &msg,
		       dOrigCoor,md_env),
		   senderid = NULL_OBJID,
		   targetid = loc_obj.objid,
		   targetos = loc_obj.osnum );

		/*** Get the planes of the first segment ***/
		sts = om$send( msg = message NDnode.NDget_objects(
			     ND_ROOT, PlnParents, 40,
			     NULL, 0, OM_K_MAXINT, &nSgParents ),
		   senderid = NULL_OBJID,
		   targetid = ObjParents[j].objid,
		   targetos = ObjParents[j].osnum );
		sts = VRgetdist(&d0EndPoints[0],dOrigCoor,&dist0);
		sts = VRgetdist(&d0EndPoints[3],dOrigCoor,&dist1);
		if(cmpid[0].objid == loc_obj.objid)
		{
		   lsegend = 0;
		   gapval = dist0;
		}
		else
		{
		   lsegend = 1;
		   gapval = dist1;
		}

		/* Get the endpoint closest to the origin of the component */

		endsmatch = 1;
		if(gapval > VRGetTol(VR_DIST_TOL))
		   endsmatch = 0;
		cmptplane[0] = PlnParents[lsegend*3];
		__DBGpr_obj("compoint plane 0",cmptplane[0]);
		no_plns = 1;
		/* Get the coordinates of the first segment end */
		for(k=0;k<3;k++) endcoord[k] = d0EndPoints[lsegend*3 + k];
		/*** Get the planes list for the intersection ***/
		shrpln[0] = PlnParents[1];
		shrpln[1] = PlnParents[2];
		shrpln[2] = PlnParents[lsegend * 3];
//printf("shared planes %d %d %d\n",shrpln[0].objid,shrpln[1].objid,shrpln[2].objid);
		/*** Set the hit list for the 2 common planes ***/
		shrhit[0] = shrhit[1] = shrhit[2] = 1;
		no_segs = 1;
		for(k=j+1; k<NbParents; k = k + 1)
		{
		   sts = VRGetClsType( &nObjCls, ObjParents[k] );
		   if(nObjCls == SEGMENTCLS)
		   {
		      __DBGpr_obj("next seg ",ObjParents[k]);
		      /* Get the ends of the next segment*/
		      sts =
			  om$send( msg = message VRCnrlSeg.VRget_terminators(
				  &msg, &NbPoints, md_env,
				     dnEndPoints, cmpid),
			    senderid = NULL_OBJID,
			    targetid = ObjParents[k].objid,
			    targetos = ObjParents[k].osnum );


		      sts = om$send( msg = message NDnode.NDget_objects(
				ND_ROOT, PlnParents, 40,
				NULL, 0, OM_K_MAXINT, &nSgParents ),
			   senderid = NULL_OBJID,
			   targetid = ObjParents[k].objid,
			   targetos = ObjParents[k].osnum );
		      /* if the ends dont match **/
		      sts = VRgetdist(&dnEndPoints[0],dOrigCoor,&dist0);
		      sts = VRgetdist(&dnEndPoints[3],dOrigCoor,&dist1);
		      if(cmpid[0].objid == loc_obj.objid)
		      {
			 lsegend = 0;
			 gapval = dist0;
		      }
		      else
		      {
			 lsegend = 1;
			 gapval = dist1;
		      }
		      if(gapval > VRGetTol(VR_DIST_TOL))
			 endsmatch = 0;

		      no_segs++;
		      chkplane[0] = PlnParents[lsegend*3];
		      chkplane[1] = PlnParents[1];
		      chkplane[2] = PlnParents[2];
//printf("planes of segment are %d %d %d\n",chkplane[0].objid,chkplane[1].objid,chkplane[2].objid);
		      for (jj=0; jj < 3; jj++)
		      {
			no_match = 1;
			for(kk = 0; kk < 3; kk++)
			{
			   if(chkplane[jj].objid == shrpln[kk].objid &&
			     (chkplane[jj].osnum == shrpln[kk].osnum))
			   {
			      shrhit[kk]++;
			      no_match = 0;
			   }
			}
			if( no_match )
			{
			   cmptplane[no_plns] = chkplane[jj];
//printf("compoint plane %d is %d\n",no_plns, cmptplane[no_plns].objid);
			   no_plns++;
			}
		      }
		      if(!endsmatch)
			 segmentsmatch = 0;
		    }
		 }
	      }
	   }
	   if(firstnotfound)
	   {
		strcpy(outbuff,
		  "component has no segments");
		*badcompt = 1;
		compid->objid = loc_obj.objid;
		compid->osnum = loc_obj.osnum;
		return 1;
	   }
	   no_shared_planes = 0;
	   for(k = 0; k<2; k++)
	   {
	      if(shrhit[k] < no_segs)
	      {
		cmptplane[no_plns] = shrpln[k];
//printf("compoint plane %d is %d\n",no_plns, cmptplane[no_plns].objid);
		no_plns++;
	      }
	      else no_shared_planes++;
	   }
	   /* Now compare to the original list of planes for the compoint ****/
	   for(k=0; k<NbCParents; k++)
	   {
	      plnnotfound = 1;
	      for( kk=0; kk<no_plns && plnnotfound; kk++)
	      {
		if(ComParents[k].objid == cmptplane[kk].objid)
		{
		  plnnotfound = 0;
		}
	      }
	      if(plnnotfound)
	      {
		__DBGpr_obj("Could not identify plane in compoint",ComParents[k]); 
		sprintf(outbuff,
		  "component compoint %d has wrong planes -replace compoint",compt.objid);
		*badcompt = 1;
		compid->objid = loc_obj.objid;
		compid->osnum = loc_obj.osnum;
		return 1;
	      }
	   }

	   for(k=0; k<no_plns; k++)
	   {
	      sts =
		 om$send( msg	   = message NDnode.ASreturn_go
					   ( &go_planes, &mattype, plnmtrx ),
			senderid = NULL_OBJID,
			targetid = cmptplane[k].objid,
			targetos = cmptplane[k].osnum );
	      sts =
		 om$send(msg = message GRvg.GRdetplane(&msg,&mattype,
			    plnmtrx, &kplninfo[k]),
			senderid = NULL_OBJID,
			targetid = go_planes.objid,
			targetos = go_planes.osnum );
	   }
	   for(k0 = 0; k0 < no_plns; k0 = k0 + 1)
	   {
	     for(k1 = 0; k1 < no_plns; k1 = k1 + 1)
	     {
	       if (k0 != k1)
	       {
		BScrossp( &retcode, &kplninfo[k0].normal[0], &kplninfo[k1].normal[0], vec );
		if(fabs(vec[0]) < VRGetTol(VR_LENGTH_TOL) &&
		   fabs(vec[1]) < VRGetTol(VR_LENGTH_TOL) &&
		   fabs(vec[2]) < VRGetTol(VR_LENGTH_TOL))
		{
//printf("compt plane %d is same as %d ------------------------------------------\n",cmptplane[k0].objid,cmptplane[k1].objid);
		   sprintf(outbuff,
		  "component compoint %d may have parallel planes",compt.objid);
		   *badcompt = 1;
		   compid->objid = loc_obj.objid;
		   compid->osnum = loc_obj.osnum;
		   return 1;
		}
	       }

	     }
	   }
	   *badcompt = 0;
	   compid->objid = NULL_OBJID;
	   compid->osnum = NULL;
	   outbuff[0] = '\0';
	   return 1;
	}
     }
     strcpy(outbuff,"component for compoint not identifiable - delete compoint")
;
     *badcompt = 1;
     compid->objid = NULL_OBJID;
     compid->osnum = NULL;
     return 1;
}
/**********************************************************************/
/* Deletes any plane with no children				      */
/**********************************************************************/
IGRlong VR_delete_orphan_planes(md_env)
  struct GRmd_env	*md_env;
{ 
  GRclassid Classes[20];
  struct GRid	*loc_obj;
  IGRint count,i;
  TGRid *childIDs;
  IGRint childCNT,delete_ct;
  IGRlong	sts, msg;

  Classes[0] = OPP_VRplane_class_id;

  count = 0;
  delete_ct = 0;
  sts = VCobjInActiveSpace(	 &msg, &count,
					   &loc_obj, Classes, 1 );
  for( i=0; i<count; i=i+1 )
  {
     om$send( msg = message
		   NDnode.NDget_objects( ND_CHILDREN | ND_IN_BUF,
					 NULL,
					 0,
					 &childIDs,
					 0,
					 OM_K_MAXINT,
					 &childCNT ),
			  senderid = NULL_OBJID,
		   targetid = loc_obj[i].objid,
		   targetos = loc_obj[i].osnum);
     if(childCNT < 1)
     {
//	   printf("VRplane %d has no children, deleting as an orphan plane\n",
//		   loc_obj[i].objid);
	 sts = om$send(msg = message GRvg.GRdelete(&msg,md_env),
			  senderid = NULL_OBJID,
		   targetid = loc_obj[i].objid,
		   targetos = loc_obj[i].osnum);
	 delete_ct++;
     }
  }
  UI_status(" ");
  if(delete_ct)
  {
    char status_msg[80];
    sprintf(status_msg,"Deleted %d unattached planes",delete_ct);
    UI_status(status_msg);
  }
  else
    UI_status("No unattached planes found");
  if( count )
  {
	 free( loc_obj );
	 loc_obj = NULL;
  }
   return 1;
}
/********************************************************************/
/* Given 2 segments, returns a flag = 1 if segments not orthogonal  */
/********************************************************************/
IGRlong VRchk_for_skew(seg0,segn,md_env,skew_flg)
struct GRid seg0,segn;
struct GRmd_env *md_env;
IGRint *skew_flg;
{
IGRlong  retcode;
IGRdouble dotpval,MyVector0[3],MyVectorn[3];
BSrc		      bsretcode;
IGRlong status;
   *skew_flg = 1;
   /* Get the vector for seg0 */
   status = om$send( msg      = message VRCnrlSeg.VRGetTopo
			       ( &retcode, MyVector0, NULL, NULL, NULL,
				 NULL, md_env ),
		    senderid = NULL_OBJID,
		    targetos = seg0.osnum,
		    targetid = seg0.objid );

   /* Get the normalized vector for seg0 */
   BSnorvec( &bsretcode, MyVector0 );
   /* Get the vector for segn */
   status = om$send( msg      = message VRCnrlSeg.VRGetTopo
			       ( &retcode, MyVectorn, NULL, NULL, NULL,
				 NULL, md_env ),
		    senderid = NULL_OBJID,
		    targetos = segn.osnum,
		    targetid = segn.objid );

   /* Get the normalized vector for segn */
   BSnorvec( &bsretcode, MyVectorn );
   /* get the dot product */
   dotpval = BSdotp( &bsretcode, MyVector0, MyVectorn);
   __DBGpr_dbl("dotpval",dotpval);
   /* If the dot product is 0,1,or -1 then the segments are orthogonal */
   if((fabs(dotpval) < VRGetTol(VR_DOTPROD_TOL)) || ((1- fabs(dotpval)) < VRGetTol(VR_DOTPROD_TOL)))
   {
      *skew_flg = 0;
   }

   return 1;
}
/********************************************************************/
/* Checks segment ends for gaps/overlaps at components		    */
/********************************************************************/
IGRlong VR_check_seg_comp(loc_obj,md_env,rptfld,bad_intersect,biggap)
struct GRid   loc_obj;
struct GRmd_env *md_env;
IGRchar *rptfld;
IGRint *bad_intersect;
IGRdouble *biggap;
{
  IGRlong	sts, msg;
  IGRint	NbParents,closest_cpt,msgint;
  IGRint	j,k,n,nObjCls;
  IGRint	segend,kfound,badpln;
  struct GRid	ObjParents[20],SupportId;
  IGRdouble	endcoord[3],dist0,dist1,locgap,gap;
  IGRdouble	dOrigCoor[3],CptCoord[3];
  IGRdouble	d0EndPoints[6],dnEndPoints[6];
  IGRdouble	dist_to_orig[20],shrtdist;
  IGRint	nCpNum,nbpts,notfoundcpt,no_segs;
  IGRshort	shrtndx,nStatus,kshrt,nFoundCp,ccompcpt;
  IGRint	NbPoints,firstnotfound,segmentsmatch,endsmatch;
  IGRint chosen, locbadpln;
  IGRchar	szMsg0[180],szMsg[180];
  GRclassid	CompClassId;
  struct GRid endcomp[2];
  extern GRclassid OPP_VRComponent_class_id; 

  sts = om$get_classid( p_classid = &CompClassId,
			   objid = loc_obj.objid,
			   osnum = loc_obj.osnum );

  locgap = 0.0;
  if ( om$is_ancestry_valid( subclassid   = CompClassId,
			     superclassid   = OPP_VRConcComp_class_id )
		  == OM_S_SUCCESS )
  {
     /* Get the no of cpts */
     sts = om$send(msg = message NDnode.NDget_objects
			     ( ND_ROOT, ObjParents, 20, NULL,
			     0, OM_K_MAXINT, &NbParents ),
	      senderid = NULL_OBJID,
	      targetid = loc_obj.objid,
	      targetos = loc_obj.osnum );

     endsmatch = 1;
     locbadpln = 0;
     no_segs = 0;
     for(j=0;j<NbParents; j++)
     {
	sts = VRGetClsType( &nObjCls, ObjParents[j] );

	if(nObjCls == SEGMENTCLS)
	{
	   sts = VR_find_ccomp_cpt(ObjParents[j], loc_obj,
			&ccompcpt,&gap,&badpln,md_env);
	  if(badpln) locbadpln = 1;
	  if(gap > locgap) locgap = gap;
	  if(gap > VRGetTol(VR_DIST_TOL))
	  {
	      endsmatch = 0;
	  }
	  dist_to_orig[no_segs] = gap;
	  no_segs++;
	}
     }
     *biggap = locgap;
     /* if a gap */
     if( !endsmatch)
     {
       /* report the gap */
       strcpy(szMsg0,"CCOMP cpt-segment offsets ");
       for(k=0; k<no_segs; k++)
       {
	   sprintf(szMsg, " %f ",dist_to_orig[k]);
	   strcat(szMsg0,szMsg);
       }
       strcpy(rptfld, szMsg0);
	/* Set the gap flag */
       *bad_intersect = 1;
     }
     /* else no gap */
     else
	/* Set the nogap flag */
	*bad_intersect = 0;

     if(locbadpln)
     {
       strcpy(rptfld,"CCOMP may have bad planes-replace component");
       *bad_intersect = 1;
     }
     return OM_S_SUCCESS;
  }
  else if ( om$is_ancestry_valid( subclassid   = CompClassId,
			     superclassid   = OPP_VRComponent_class_id )
		  != OM_S_SUCCESS )
  {
      *bad_intersect=0;
      return OM_S_SUCCESS;
  }

  /* -- See if it's a correction component -- */
  sts = om$send( msg	  = message VRGeneric.VRGetStatus(&msg,&nStatus),
		    senderid = NULL_OBJID,
		    targetid = loc_obj.objid,
		    targetos = loc_obj.osnum );

  segmentsmatch = 1;
  if ( !(nStatus&VR_CORRECTION) ) /* Do not know if saves time but tried */
  {
	__DBGpr_obj("\n\tNot a CCOMP or correction comp",loc_obj);
       /*** Get the origin coordinates ***/
       sts = om$send( msg = message VRGeneric.VRGetOrigCoor ( &msg,
		       dOrigCoor,md_env),
		   senderid = NULL_OBJID,
		   targetid = loc_obj.objid,
		   targetos = loc_obj.osnum );

	/**** Get segment parents ****/
	sts = om$send( msg = message NDnode.NDget_objects(
				    ND_ROOT, ObjParents, 40,
				    NULL, 0, OM_K_MAXINT, &NbParents ),
			  senderid = NULL_OBJID,
			  targetid = loc_obj.objid,
			  targetos = loc_obj.osnum );

	firstnotfound = 1;
	segmentsmatch = 1;
	n = 0;

	for(j=0; j<NbParents ; j = j + 1)
	{
	   sts = VRGetClsType( &nObjCls, ObjParents[j] );

	   if(nObjCls == SEGMENTCLS)
	   {
	       __DBGpr_obj("Comp's seg parent",ObjParents[j]);
	      dist_to_orig[n] = 0;
	      /* Get the ends of the first segment*/
	      om$send( msg     = message VRCnrlSeg.VRget_terminators(
			&msg, &NbPoints, md_env,
			dnEndPoints, endcomp),
			 senderid = NULL_OBJID,
			 targetid = ObjParents[j].objid,
			 targetos = ObjParents[j].osnum );
	      __DBGpr_objlist("Seg's children",NbPoints,endcomp);

	      /* Get the segment end closest to the origin of the component */
	       if( NbPoints == 2 ) // This check necessary. See comment in else.
	       {
		   if(loc_obj.objid == endcomp[0].objid &&
		      loc_obj.osnum == endcomp[0].osnum )
		       segend = 0;
		   else
		       segend = 1;
	       }
	       else
	       {
		   /* In some stages of recompute, it is possible that the
		    * control segment does not have a child at a particular
		    * end. In such a case, endcomp[0] is loc_obj irrespective
		    * of which end the component is in. Therefore, one has to
		    * figure out this info from the control line and the
		    * component.	     - Anand for TR 6061 (June 2002).
		    */

		   IGRshort CmpIndxAtSeg=-1;

		   sts =
		   om$send( msg = message VRGeneric.VRGetIndex( &msg,
								&ObjParents[j],
								&CmpIndxAtSeg ),
			    senderid = NULL_OBJID,
			    targetid = loc_obj.objid,
			    targetos = loc_obj.osnum );

		   segend = CmpIndxAtSeg;
		   __DBGpr_int("End of only child comp of seg",segend);
	       }
	       sts = VRgetdist(&dnEndPoints[segend*3],dOrigCoor,&dist0);
	       dist_to_orig[n] = dist0;
	       /* Get the coordinates of the first segment end */
		n++;
		if(dist0 > locgap) locgap = dist0;
		if(dist0 > VRGetTol(VR_DIST_TOL))
		{
		      segmentsmatch = 0;
		      __DBGpr_int("Seg end",segend);
		      __DBGpr_vec("Seg end point",&dnEndPoints[segend*3]);
		      __DBGpr_vec("Seg other end pt",&dnEndPoints[3-segend*3]);
		      __DBGpr_vec("Comp's origin",dOrigCoor);
		      __DBGpr_dbl("Distance",dist0);
		}
	   }
	}
   }
   *biggap = locgap;
   if(!segmentsmatch)
   {
       strcpy(szMsg0,"Offsets-comp origin to segment ends ");
       for(j=0; j<n; j = j + 1)
       {
	 sprintf(szMsg,"  %f",dist_to_orig[j]);
	 strcat(szMsg0,szMsg);
       }
       strcpy(rptfld, szMsg0);
       *bad_intersect = 1;
   }
   else
   {
       *bad_intersect = 0;
   }

   return 1;
}


/********************************************************************/
/* Deletes and rebuilds all compoints in the file.		    */
/* Deletes all orphan planes					    */
/* Lists all components with non-intersectin segment ends	    */
/********************************************************************/
IGRlong VR_rbld_compt(Classes,noclasses,md_env)
struct GRmd_env *md_env;
GRclassid *Classes;
IGRint noclasses;
{
  IGRlong	sts, msg,retcode;
  IGRint	count, NbParents, FootIndex;
  IGRint	SgParents,msgint;
  struct GRid	*loc_obj;
  IGRdouble	dOrigCoor[3],xform_matrix[16];
  IGRint	i,j,jj,k,kk,nObjCls;
  GRclassid	Classid[2];
  struct GRid	ObjParents[20],CCmpPlns[3];
  IGRdouble	gapval[10],gap;
  IGRdouble	d0EndPoints[6],dnEndPoints[6];
  IGRint	NbPoints,firstnotfound,segmentsmatch,endsmatch;
  struct ret_struct	  AttrSt;
  struct GRid	ConstId,compid[2];
  struct GRid	cmptplane[20],PlnParents[20];
  IGRint	no_plns,no_segs,segend;
  struct GRid	cmnpln[2];
  IGRdouble	endcoord[3],dist0,dist1;
  struct	GRas		assoc_list;
  IGRint	bad_intersect,comphassegs;
  struct GRid shrpln[3];
  IGRint no_shared_planes,no_match,shrhit[3];
  struct GRid chkplane[3];
  IGRshort	nStatus, ccompcpt,shrtndx;
  IGRint badpln,ccpln[3],notshared;
  IGRshort otherend;
  IGRchar szMsg0[180],szMsg[180],rptfld[180];

  /*** Delete all compoints ***/
  count = 0;
  Classid[0] = OPP_VRcompoint_class_id;
  sts = VCobjInActiveSpace(	 &msg, &count,
					   &loc_obj, Classid, 1 );

  UI_status(" ");
  __DBGpr_int( " Nb. of Compoint Objects to delete ", count );
  if( count > 0 )
  {
     for(i=0;i<count;i++)
     {
//	     printf("deleting compointid %d\n",loc_obj[i].objid);
	   om$send ( msg = message NDnode.NDdelete( md_env ),
			  senderid = NULL_OBJID,
	      targetid = loc_obj[i].objid,
	      targetos = loc_obj[i].osnum );
     }
  }
  if( count )
  {
	 free( loc_obj );
	 loc_obj = NULL;
  }
  /*** Check for orphan planes ***/
  sts = VR_delete_orphan_planes(md_env);

  count = 0;
  sts = VCobjInActiveSpace(	 &msg, &count,
					   &loc_obj, Classes, noclasses );
  __DBGpr_int("Total count of VRComp class objects checked",count);
  if(count)
  {
    for(i=0; i<count; i++)
    {
      __DBGpr_obj("Check component for a compoint",loc_obj[i]);
      /* -- See if it's a correction component -- */
      sts = om$send( msg      = message VRGeneric.VRGetStatus(&msg,&nStatus),
		    senderid = NULL_OBJID,
		    targetid = loc_obj[i].objid,
		    targetos = loc_obj[i].osnum );

      if ( !(nStatus&VR_CORRECTION) ) /* Do not know if saves time but tried */
      {
       /*** Get the origin coordinates ***/
       sts = om$send( msg = message VRGeneric.VRGetOrigCoor ( &msg,
		       dOrigCoor,md_env),
		   senderid = NULL_OBJID,
		   targetid = loc_obj[i].objid,
		   targetos = loc_obj[i].osnum );
       /*** Get the list of parents ***/
       sts = om$send( msg = message NDnode.NDget_objects(
				    ND_ROOT, ObjParents, 40,
				    NULL, 0, OM_K_MAXINT, &NbParents ),
		   senderid = NULL_OBJID,
		   targetid = loc_obj[i].objid,
		   targetos = loc_obj[i].osnum );
       firstnotfound = 1;
       segmentsmatch = 1;
       comphassegs = 0;
       for(j=0; j<NbParents && firstnotfound; j = j + 1)
       {
	  sts = VRGetClsType( &nObjCls, ObjParents[j] );
	  /*** We only process segments ***/
	  if(nObjCls == SEGMENTCLS)
	  {
	     __DBGpr_obj("First seg ",ObjParents[j]);
	     comphassegs = 1;
	     firstnotfound = 0;
	     /* Get the ends of the first segment*/
	     om$send( msg     = message VRCnrlSeg.VRget_terminators(
			  &msg, &NbPoints, md_env,
			  d0EndPoints, compid),
		  senderid = NULL_OBJID,
		  targetid = ObjParents[j].objid,
		  targetos = ObjParents[j].osnum );

	     if(compid[0].objid == loc_obj[i].objid)
	     {
	       sts = VRgetdist(&d0EndPoints[0],dOrigCoor,&dist0);
	       gapval[0] = dist0;
	       segend = 0;
	     }
	     else
	     {
	       sts = VRgetdist(&d0EndPoints[3],dOrigCoor,&dist1);
	       gapval[0] = dist1;
	       segend = 1;
	     }
	     /*** Get the planes of the first segment ***/
	     sts = om$send( msg = message NDnode.NDget_objects(
			     ND_ROOT, PlnParents, 40,
			     NULL, 0, OM_K_MAXINT, &SgParents ),
		   senderid = NULL_OBJID,
		   targetid = ObjParents[j].objid,
		   targetos = ObjParents[j].osnum );

	     endsmatch = 1;
	     if(gapval[0] > VRGetTol(VR_DIST_TOL))
	       endsmatch = 0;
	     cmptplane[0] = PlnParents[segend*3];
	     no_plns = 1;
//printf("compoint plane %d is %d\n",no_plns,cmptplane[0].objid);
	     /* Get the coordinates of the first segment end */
	     for(k=0;k<3;k++) endcoord[k] = d0EndPoints[segend*3 + k];
	     /*** Get the planes list for the intersection ***/
	     shrpln[0] = PlnParents[1];
	     shrpln[1] = PlnParents[2];
	     shrpln[2] = PlnParents[segend * 3];
//printf("shared planes %d %d %d\n",shrpln[0].objid,shrpln[1].objid,shrpln[2].objid);
	     /*** Set the hit list for the 2 common planes ***/
	     shrhit[0] = shrhit[1] = shrhit[2] = 1;
	     no_segs = 1;
	     for(k=j+1; k<NbParents; k = k + 1)
	     {
		sts = VRGetClsType( &nObjCls, ObjParents[k] );
		if(nObjCls == SEGMENTCLS)
		{
		   __DBGpr_obj("Next seg ",ObjParents[k]);
		   /* Get the ends of the next segment*/
		   sts = 
		       om$send( msg = message VRCnrlSeg.VRget_terminators(
			       &msg, &NbPoints, md_env,
				     dnEndPoints, compid),
			    senderid = NULL_OBJID,
			    targetid = ObjParents[k].objid,
			    targetos = ObjParents[k].osnum );


		   sts = om$send( msg = message NDnode.NDget_objects(
			     ND_ROOT, PlnParents, 40,
			     NULL, 0, OM_K_MAXINT, &SgParents ),
			   senderid = NULL_OBJID,
			   targetid = ObjParents[k].objid,
			   targetos = ObjParents[k].osnum );
		   /* if the ends dont match **/
	     if(compid[0].objid == loc_obj[i].objid)
	     {
	       sts = VRgetdist(&dnEndPoints[0],dOrigCoor,&dist0);
	       gapval[no_segs] = dist0;
	       segend = 0;
	     }
	     else
	     {
	       sts = VRgetdist(&dnEndPoints[3],dOrigCoor,&dist1);
	       gapval[no_segs] = dist1;
	       segend = 1;
	     }
	     if(gapval[no_segs] > VRGetTol(VR_DIST_TOL)) endsmatch = 0;
	     no_segs++;
/* Check the end plane against the shared planes if a hit bump the count */
		   chkplane[0] = PlnParents[segend*3];
		   chkplane[1] = PlnParents[1];
		   chkplane[2] = PlnParents[2];
//printf("segment planes %d %d %d\n",chkplane[0].objid, chkplane[1].objid,chkplane[2].objid);
		 for (jj=0; jj < 3; jj++)
		 {
		   no_match = 1;
		   for(kk = 0; kk < 3; kk++)
		   {
		      if(chkplane[jj].objid == shrpln[kk].objid &&
			(chkplane[jj].osnum == shrpln[kk].osnum))
		      {
			 shrhit[kk]++;
			 no_match = 0;
		      }
		   }
		   if( no_match )
		   {
		      cmptplane[no_plns] = chkplane[jj];
//printf("compoint plane %d is %d\n",no_plns,chkplane[jj].objid);
		      no_plns++;
		   }
		 }
		   if(!endsmatch)
		      segmentsmatch = 0;
		}
	     }
	  }
       }
       if(comphassegs)
       {
/*****
       if(!segmentsmatch)
       {
	   strcpy(szMsg0,"Offsets-comp origin to segment ends ");
	   for(k=0; k<no_segs; k++)
	   {
	     sprintf(szMsg,"  %f",gapval[k]);
	     strcat(szMsg0,szMsg);
	   }
	   strcpy(rptfld, szMsg0);
       }
*****/
       /*** Check the first segment common planes */

       no_shared_planes = 0;
       for(k = 0; k<2; k++)
       {
	  if(shrhit[k] < no_segs)
	  {
	    cmptplane[no_plns] = shrpln[k];
//printf("compoint plane %d is %d\n",no_plns,shrpln[k].objid);
	    no_plns++;
	  }
	  else no_shared_planes++;
       }

       assoc_list.parents = cmptplane;
       assoc_list.num_parents = no_plns;
       /*** Create the compoint ***/
       if(no_shared_planes < 2)
       {
	  ConstId.osnum = md_env->md_id.osnum;
	  sts = om$construct(  classid = OPP_VRcompoint_class_id,
				 p_objid = &ConstId.objid,
				 osnum	 = ConstId.osnum,
		msg	= message NDnode.NDplace( &assoc_list, NULL, NULL ) );
	  __DBGpr_obj("Building VRcompoint",ConstId);
       }
       }
      }
    } /*** end of processing components */
  }
  if( count )
  {
	 free( loc_obj );
	 loc_obj = NULL;
  }
  Classid[0] = OPP_VRConcComp_class_id;
  count = 0;
  sts = VCobjInActiveSpace(	 &msg, &count,
					   &loc_obj, Classid, 1 );
  /*** Check if any bad planes are on the ccomps ***/
  if(count > 0)
  {
     for(i=0; i<count; i++)
     {

	/* Get the no of cpts */
	sts = om$send(msg = message NDnode.NDget_objects
			     ( ND_ROOT, ObjParents, 20, NULL,
			     0, OM_K_MAXINT, &NbParents ),
	      senderid = NULL_OBJID,
	      targetid = loc_obj[i].objid,
	      targetos = loc_obj[i].osnum );

	for(j=0;j<NbParents; j++)
	{
	   sts = VRGetClsType( &nObjCls, ObjParents[j] );

	   if(nObjCls == SEGMENTCLS)
	   {
	      sts = VR_find_ccomp_cpt(ObjParents[j], loc_obj[i],
			&ccompcpt,&gap,&badpln,md_env);

	      if(badpln)
	      { 
/***
		 printf("CCOMP %d may have bad planes-replace component\n",loc_obj[i].objid);
****/
		 /*** Get the segment planes ***/
		 sts = om$send( msg = message NDnode.NDget_objects(
			     ND_ROOT, PlnParents, 40,
			     NULL, 0, OM_K_MAXINT, &SgParents ),
			   senderid = NULL_OBJID,
			   targetid = ObjParents[j].objid,
			   targetos = ObjParents[j].osnum );
		 /*** Get the CCOMP planes ***/
		 sts = om$send( msg	 = message VRGeneric.VRGetIndex(
			     &retcode,&ObjParents[j],&shrtndx),
			   senderid = NULL_OBJID,
			   targetid = loc_obj[i].objid,
			   targetos = loc_obj[i].osnum );
		 sts = om$send( msg = message VRGeneric.VRGetPlanesOnCpt(

			      &msg, ccompcpt, CCmpPlns, md_env),
			   senderid = NULL_OBJID,
			   targetid = loc_obj[i].objid,
			   targetos = loc_obj[i].osnum );
		 /*** Check the segment planes against the CComp ***/
		 /*** If not shared, add to the compoint planes  ***/
		 otherend = 0;
		 no_plns = 0;
		 if(shrtndx == 0) otherend = 3;
		 ccpln[0]=ccpln[1]=ccpln[2]=1;
		 for(k=0; k<4; k++)
		 {
		   notshared = 0;
		   if(k != otherend)
		   {
		     notshared = 1;
		     for (kk=0; kk<3; kk++)
		     {
			if((CCmpPlns[kk].objid == PlnParents[k].objid) &&
			   (CCmpPlns[kk].osnum == PlnParents[k].osnum))
			{
			  notshared = 0;
			  ccpln[kk] = 0;
			}
		     }
		   }
		   if(notshared)
		   {
		      cmptplane[no_plns] = PlnParents[k];
		      no_plns++;
		   }
		 } 
		 for(kk=0;kk<3;kk++)
		 {
		   if(ccpln[kk])
		   {
		      cmptplane[no_plns] = CCmpPlns[kk];
		      no_plns++;
		   }
		 }
		 /*** Build the compoint ***/
		 assoc_list.parents = cmptplane;
		 assoc_list.num_parents = no_plns;
		 /*** Create the compoint ***/
		 if(no_plns > 1)

		 {
		    ConstId.osnum = md_env->md_id.osnum;
		    sts = om$construct(  classid = OPP_VRcompoint_class_id,
				 p_objid = &ConstId.objid,
				 osnum	 = ConstId.osnum,
		    msg = message NDnode.NDplace( &assoc_list, NULL, NULL ) );
		    __DBGpr_obj("Building VRcompoint",ConstId);

		 }
	      }
	   }
	}
     }
  }
  if( count )
  {
	 free( loc_obj );
	 loc_obj = NULL;
  }
  return 1;
}
IGRlong VRsetsymb(md_env,compobj)
struct GRmd_env       *md_env;
struct GRid compobj;
{

   struct GRsymbology	   Symbology;
   struct GRid		   collId; /* for symbology collector */
   VD_drwOutputData	   *output = NULL;
   IGRint   status;
   IGRlong  retmsg;

   status =
	om$send( msg = message GRvg.GRgetsymb (&retmsg, &Symbology),
	    senderid = NULL_OBJID,
	    targetid = compobj.objid,
	    targetos = compobj.osnum);
   collId.objid = NULL_OBJID ;
   status =
	VDgetVdCollId( &retmsg, VD_DGNST_DIR_NAME, FALSE, FALSE, &collId );
   if( (status&retmsg&1) )
   {
      status = VDsetAttDrSymb(&retmsg, compobj, md_env, output );
      if( !(status&retmsg&1) )
      {
	 status =
	    om$send(msg = message GRvg.GRputsymb(&retmsg,&Symbology),
		 senderid = NULL_OBJID,
		 targetid = compobj.objid,
		 targetos = compobj.osnum);
      }
      VD_drwFreeOutputData( &output ) ;
    }
    else
    {

       /*    then override this.....	*/
       status = om$send( msg = message VDSroot.VDgetAttrDrivenSymb(
					&retmsg,
					"routeattr.symb",
					md_env,
					&Symbology),
		  senderid = NULL_OBJID,
		  targetid = compobj.objid,
		  targetos = compobj.osnum);

	/*    and store it......	 */
       status =
	   om$send(msg = message GRvg.GRputsymb(&retmsg,&Symbology),
	       senderid = NULL_OBJID,
	       targetid = compobj.objid,
	       targetos = compobj.osnum);
    }

return 1;
}

/*************************************************************************/
/* Routine to query for all bad components and recompute their planes	 */
/*************************************************************************/
IGRlong VRrepair_comp(Classes,noclasses,md_env)
struct GRmd_env       *md_env;
GRclassid *Classes;
IGRint noclasses;
{
  struct GRid	*loc_obj;
  IGRint	count,bad_intersect,NbParents;
  struct GRid	ObjParents[40];
  struct GRid	PlnParents[20];
  IGRint	SgParents;
  IGRdouble	xform_matrix[16],bgap;
  IGRint	i,j,k,nObjCls;
  IGRchar rptfld[180];
  IGRlong	sts, msg;

  count = 0;
  sts = VCobjInActiveSpace(	 &msg, &count,
					   &loc_obj, Classes, noclasses );
  __DBGpr_int("Total count of VRComp class objects checked",count);
  if(count)
  {
    MAidmx(&msg,xform_matrix);
    for(i=0; i<count; i++)
    {
       bad_intersect = 1;
       rptfld[0] = '\0';
       sts = VR_check_seg_comp(loc_obj[i],md_env,rptfld,&bad_intersect,&bgap);

       if(bad_intersect)
       {
	  sts = om$send( msg = message NDnode.NDget_objects(
				    ND_ROOT, ObjParents, 40,
				    NULL, 0, OM_K_MAXINT, &NbParents ),
		   senderid = NULL_OBJID,
		   targetid = loc_obj[i].objid,
		   targetos = loc_obj[i].osnum );

	  for(j=0; j<NbParents; j = j + 1)
	  {
	     sts = VRGetClsType( &nObjCls, ObjParents[j] );
	     /*** We only process segments ***/
	     if(nObjCls == SEGMENTCLS)
	     {
		sts = om$send( msg = message NDnode.NDget_objects(
			     ND_ROOT, PlnParents, 40,
			     NULL, 0, OM_K_MAXINT, &SgParents ),
		      senderid = NULL_OBJID,
		      targetid = ObjParents[j].objid,
		      targetos = ObjParents[j].osnum );
		for(k=0;k<SgParents;k++)
		{
		   VRskxform( &msg, xform_matrix, &PlnParents[k], md_env );
		}
	     }
	  }
	}
     }
  }
  if( count )
  {
	 free( loc_obj );
	 loc_obj = NULL;
  }

  return 1;
}
end implementation Root;
