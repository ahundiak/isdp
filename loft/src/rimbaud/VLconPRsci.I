/* $Id: VLconPRsci.I,v 1.2 2001/02/20 01:06:20 build Exp $  */

/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        src/rimbaud/VLconPRsci.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:

# Revision 1.1  1994/11/14  22:42:32  pinnacle
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION

        12/04/95        Ch. Rama Rao

*************************************************************************/

class implementation VLabstract;



#include <stdio.h>
#include <math.h>
#include "vlprototype.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "EMSstruct.h"
#include "maerr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "grmacros.h"
#include "growner.h"
#include "nddef.h"
#include "macro.h"
#include "asmacros.h"
#include "asbox.h"
#include "graph.h"
#include "ndmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "vsdef.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsbmaxisdef.h"
#include "EMSssprops.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "vlplatejig.h"
#include "vlmark.h"
#include "vlstructure.h"
#include "vlsdl.h"
#include "vlsdlmacros.h"
#include "vledgeattr.h"
#include "vsdrwmacros.h"

#include "bstrans1.h"		// extern IGRboolean BStrans1();
#include "bsnorvec.h"


/************************** internal definitions************************/

#include "vlalma.h"

#define         VL_NUM_ALMA_EDGE 11
/************************** internal definitions************************/


/********************** for DEBUGGING*********************************

#ifndef CONVTOALDEBUG

#define CONVTOALDEBUG 1

#define vsDEBUG         1
#define vserrDEBUG      1

#endif

********************** end DEBUGGING*********************************/

#include "vldbgmacros.h"

//c     External Functions ****/
//c defined in include files */

//c *************** External Methods ***********************/

from  ACcpx_defn        import  ACgive_name;
from  ACrg_collect	import  AClist_attribute;

extern OMuword	OPP_nci_macro_class_id;

static int    NumEdges;

struct edgeChamfId{
	struct GRid edgeId;
	int	    chamfId;
	};
typedef struct edgeChamfId VLedgeChamfIdMap;
%safe
static VLedgeChamfIdMap *edgeChamfIdMap = NULL;
%endsafe

int VLwritePRsection (
			struct GRid	*UnWrap_id,
			struct GRmd_env *md_env,
			char		*ini_fileid,
			VLsdlContext 	*CtxCast 	)

{
  	IGRint			status = OM_S_SUCCESS;
  	IGRint		  	chanf_id;
  	IGRint		  	i,j,k,numObjects,num=0;
  	IGRlong		  	msg,sts;
  	IGRboolean		match;
  	IGRdouble		tmp[7][12];
  	struct ACrg_coll        ACrg[20];
  	struct GRid		ids[10], AssocGrid, *GridBuffer=NULL;
  	struct  GRid		attBox;
  	struct GRid 		EdgeMacId,
		          	MacroDefId;
  	char 			*theMacroName	= NULL ;
  	OMuword		  	id_cl;

			// make sure have the assoc object = subclass of NDnode
	sts = as$make_source(	go_grid	= *UnWrap_id,
				mod_env	= md_env,
				as_grid	= &AssocGrid );
 	CheckRC( sts, 1 );
 	__DBGpr_obj(" object from make_source: ", AssocGrid );

 	sts = om$send ( msg =  message NDnode.NDget_objects( 
			ND_IN_BUF | ND_CHILDREN,
			(struct GRid *)NULL,
			0,
			&GridBuffer,
		        0,
			OM_K_MAXINT,
			&numObjects),
		senderid 	= NULL_OBJID,
		targetid 	= AssocGrid.objid,
		targetos 	= AssocGrid.osnum);
	__CheckRC( sts, 1, " NDnode.NDget_objects ", wrapup );

 	// keep the nci_macros

	i		= 0;
	k		= 0;
	NumEdges	= 0;

	while ( i<numObjects && GridBuffer )	// HF: 06/04/96 TR#: 179602089
	{
 	  sts = om$get_classid(	osnum		= GridBuffer[i].osnum,
				objid		= GridBuffer[i].objid,
				p_classid	= &id_cl	) ;
  
	  __CheckRC( sts, 1, "get_classid", NextSuccessor );

 	  sts = om$is_ancestry_valid( superclassid = OPP_nci_macro_class_id,
			      	  subclassid   =id_cl  ) ;
	  __CheckRC( sts, 1, " it's not a nci_macro", NextSuccessor );

	  sts   = om$send ( msg = message ACcpx.find_macro( &MacroDefId ),
			senderid 	= NULL_OBJID,
			targetid 	= GridBuffer[i].objid,
			targetos 	= GridBuffer[i].osnum);
	  __CheckRC( sts, 1, "find_macro", NextSuccessor );

	  sts  = om$send ( msg = message ACcpx_defn.ACgive_name(&theMacroName),
			senderid 	= NULL_OBJID,
			targetid 	= MacroDefId.objid,
			targetos 	= MacroDefId.osnum);
	  __CheckRC( sts, 1, "ACgive_name", NextSuccessor );

 	  // keep only the 'edge_att' nci_macro
	  // MACRO_NAME  is  "edge_att" in vledgeattr.h

	  if (!strcmp( theMacroName, MACRO_NAME )) {
		EdgeMacId.objid 	=  GridBuffer[i].objid;
		EdgeMacId.osnum 	=  GridBuffer[i].osnum;
		++(NumEdges) ;
	  }
	  else if (!strcmp(theMacroName,"edge2D_att"))	{

		__DBGpr_com( "** find the 3D edge_att ***" );
	  	sts   = om$send ( msg = message ACcpx.ACfind_exp_temp_obj(
								&status,
								0,
								&EdgeMacId ),
			senderid 	= NULL_OBJID,
			targetid 	= GridBuffer[i].objid,
			targetos 	= GridBuffer[i].osnum);
	  	__CheckRC( sts, 1, "ACfind_exp_temp", NextSuccessor );
		++(NumEdges)  ;
	  }  // if 2D edge_att 

	  ids[k]=EdgeMacId;
	  ++k;

NextSuccessor :
	  theMacroName="";
          ++i ;

 	}

	if ( NumEdges ) {
	  if (fprintf((FILE*)ini_fileid, "*PR\n") < 0 ) {
	    sts = OM_E_WRITE_ERROR;
	    goto  wrapup;
	  }
	  if ( edgeChamfIdMap ) free ( edgeChamfIdMap );
	  edgeChamfIdMap = (VLedgeChamfIdMap *)om$malloc
         	        ( size = NumEdges*sizeof( VLedgeChamfIdMap ) );
	}
	chanf_id = 0;

	for(i=0; i<NumEdges; ++i)
 {
  	sts   = om$send ( msg = message ACcpx.ACfind_exp_temp_obj(
							&status,
							2,
							&attBox ),
			senderid 	= NULL_OBJID,
			targetid 	= ids[i].objid,
			targetos 	= ids[i].osnum);
	__CheckRC( sts, 1, "ACcpx.ACfind_exp_temp_obj", wrapup );

        sts = om$send(msg = message ACrg_collect.AClist_attribute
                                        (&msg, 20,ACrg,&num),
		       senderid = NULL_OBJID,
                       targetid = attBox.objid,
                       targetos = attBox.osnum);
	__CheckRC( sts, 1, "ACrg_collect.AClist_attribute", wrapup );

        if ((j=VLseekFields(ACrg,num,ATT_TYPE_CHAMF)) != -1) {
           tmp[i][0] = ACrg[j].desc.value.att_exp;
        }
        if ((j=VLseekFields(ACrg,num,ATT_L)) != -1) {
           tmp[i][1] = ACrg[j].desc.value.att_exp;
        }
        if ((j=VLseekFields(ACrg,num,ATT_S)) != -1) {
           tmp[i][2] = ACrg[j].desc.value.att_exp;
        }
        if ((j=VLseekFields(ACrg,num,ATT_A)) != -1) {
           tmp[i][3] = ACrg[j].desc.value.att_exp;
        }
        if ((j=VLseekFields(ACrg,num,ATT_V)) != -1) {
           tmp[i][4] = ACrg[j].desc.value.att_exp;
        }
        if ((j=VLseekFields(ACrg,num,ATT_Y)) != -1) {
           tmp[i][5] = ACrg[j].desc.value.att_exp;
        }
        if ((j=VLseekFields(ACrg,num,ATT_X)) != -1) {
           tmp[i][6] = ACrg[j].desc.value.att_exp;
        }
        if ((j=VLseekFields(ACrg,num,ATT_H)) != -1) {
           tmp[i][7] = ACrg[j].desc.value.att_exp;
        }
        if ((j=VLseekFields(ACrg,num,ATT_C)) != -1) {
           tmp[i][8] = ACrg[j].desc.value.att_exp;
        }
        if ((j=VLseekFields(ACrg,num,ATT_N)) != -1) {
           tmp[i][9] = ACrg[j].desc.value.att_exp;
        }
        if ((j=VLseekFields(ACrg,num,ATT_T)) != -1) {
           tmp[i][10] = ACrg[j].desc.value.att_exp;
        }

	match = FALSE;
	for(j=0; j<i; ++j)
	{
		for(k=0; k<VL_NUM_ALMA_EDGE; ++k)
		{
			if(fabs(tmp[j][k]-tmp[i][k]) > 0.0001) break;
			if(k== VL_NUM_ALMA_EDGE-1) { match = TRUE; break; }
		}
		if ( match ) break;
	}

	if ( !match )
	{
	   ++ chanf_id;

	   if (fprintf((FILE*)ini_fileid, "CHANFR %d", chanf_id) < 0 ) {
	      sts = OM_E_WRITE_ERROR;
	      goto  wrapup;
	   }

           if ( CtxCast->systTxt.out ) {	// if using strudel file

	   VSdrwOutputData *outPutInit = NULL ;

	   struct IGRplane	Plane ;
	   struct IGRlbsys	LBSys ;
	   IGRvector		Vector ;

	   status = vs$drwExecConfig ( msg    	       = &msg ,
                                       elmId           = &ids[i],
                                       elmEnv          = md_env,
                                       drwPlane        = &Plane ,
                                       viewPlane       = &Plane ,
                                       viewVector      = Vector,
                                       drwEnv          = md_env ,
                                       drwLbsys        = &LBSys ,
                                       selCount        = 0 ,
                                       selList         = NULL,
                                       filename        = "AlmaEdgeAttrs", 
                                       appData         = CtxCast ,
                                       output          = &outPutInit );
	   CheckRC( status , msg ) ;

  	   }		// if strudel active

	}

	edgeChamfIdMap[i].edgeId  = ids[i];

	if ( match )
	    edgeChamfIdMap[i].chamfId = edgeChamfIdMap[j].chamfId;
	else
	    edgeChamfIdMap[i].chamfId = chanf_id;
 }
	if (fprintf((FILE*)ini_fileid, "*GE\n") < 0 )
		sts = OM_E_WRITE_ERROR;
wrapup :

	return sts;

}	// end write to file.ini


IGRint	VLgetChamfId (
			struct GRid	*edgeId,
			int		*chamfId	)
{
	IGRint	i;

	if( NumEdges )
	{
		for(i=0; i<NumEdges; ++i)
		if( edgeId->objid == edgeChamfIdMap[i].edgeId.objid ) break;
		if(i == NumEdges ) return MSFAIL;
		*chamfId = edgeChamfIdMap[i].chamfId;
	}
	else    *chamfId = 0;
	return MSSUCC;
}

end implementation VLabstract;
