/* $Id: VRCorrVerify.I,v 1.2 2001/02/20 01:13:13 build Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrcorrection/VRCorrVerify.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCorrVerify.I,v $
 *	Revision 1.2  2001/02/20 01:13:13  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/12/01  12:08:10  pinnacle
# Replaced: vrcorrection/VRCorrVerify.I for: TR 179802022 by aharihar for route
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	21-NOV-94	Lori		creation date
 *			Anand		Fix for TR 179802022, Added file
 *					header
 *
 ***************************************************************************/



/**********************************************************************
 
     CLASS  NAME: VRCorrection
     METHOD NAMES: VRVerCorrTopology

     AUTHOR:   Lori 
     DATE:     21-NOV-94

***********************************************************************/



class implementation VRCorrection;

#include "EXgrid.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "VRcompdef.h"
#include "VRparamdef.h"
#include "AS_status.h"
#include "nddef.h"
#include "VRverify.h"
#include "VRverifymac.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"
#include "vrdbgmacros.h"


extern GRclassid        OPP_VRComponent_class_id;
extern GRclassid        OPP_VRConcComp_class_id;
extern GRclassid        OPP_VRNozzle_class_id;
extern GRclassid        OPP_VRCptIn_class_id;
extern GRclassid        OPP_VRACrg_collect_class_id;
extern OM_S_CHANSELECT  AS_to_comp;

from VRGeneric import VRGetCptGeom;

method VRVerCorrTopology( IGRlong *msg; struct GRmd_env *md_env; 
			struct VRvfy_file *FileData;
			IGRboolean bVerbose; IGRint *ErrorCnt) 
{

  IGRlong                status, retmsg;
  IGRint                 NbParents, NbCorCmp, NbComponents;
  IGRint                 i;
  struct     GRid        *ParentBuffer;
  GRclassid              ParentClassId;
  IGRdouble              dOrigCoor[3];

  SetProc( VRVerCorrTopology ); Begin 

  /*A get the connect point geometry for location */
  status = om$send( msg = message VRGeneric.VRGetCptGeom
		   ( &retmsg, 1, dOrigCoor,NULL,NULL, md_env), 
		   p_chanselect = &AS_to_comp,
		   from         = 0,
		   to           = 0);

  if(  !(retmsg & 1)  || !( status & 1 ) ) 
    
    VR$PrintVerify(Test = ( !(retmsg & 1)  || !( status & 1 ) ) ,
                   ErrorBuf  = "Error obtaining component geometry",
                   Verbose   = bVerbose,
                   object    = my_id, 
                   OrigCoor  = dOrigCoor,
                   ErrorCnt  = ErrorCnt,
                   FileData  = FileData);
  
  /*A Get Parents of the correction */
  status = om$send( msg = message NDnode.NDget_objects 
		  ( (ND_ROOT | ND_IN_BUF), NULL, 0,
		   &ParentBuffer, 0, OM_K_MAXINT, &NbParents ),
		   targetid = my_id);
  as$status();

  if (  !( status & 1 ) )
    {
      
      VR$PrintVerify(Test = (  !( status & 1 ) ) ,
		     ErrorBuf  = "Error obtaining correction parents",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
    }
  
  
  /*A Validate the classes of the parents */
  NbComponents = 0;

  for ( i = 0; i < NbParents; i++ )
    {
      /*A  valid connections are components, constrainted components, */
      /*A  nozzles, and CptIn                                         */
 
      status =  om$get_classid ( objid = ParentBuffer[i].objid,
		       osnum = ParentBuffer[i].osnum,
		       p_classid = &ParentClassId);

         /*A Count the number of components */
      if ( (om$is_ancestry_valid ( subclassid = ParentClassId,
				  superclassid = OPP_VRComponent_class_id) 
	  == OM_S_SUCCESS ) || 
	  (om$is_ancestry_valid ( subclassid = ParentClassId,
				  superclassid = OPP_VRConcComp_class_id) 
	  == OM_S_SUCCESS ) ||
	  (om$is_ancestry_valid ( subclassid = ParentClassId,
				  superclassid = OPP_VRNozzle_class_id) 
	  == OM_S_SUCCESS ) ||
	  (om$is_ancestry_valid ( subclassid = ParentClassId,
				  superclassid = OPP_VRCptIn_class_id) 
	  == OM_S_SUCCESS ))
	NbComponents += 1;
    }

  /*A Corrections should have 2 components as parents */

  VR$PrintVerify(Test =  ( NbComponents != CORRECT_NUM_COMP ),
		 ErrorBuf  = "Correction has invalid number of components as parents",
		 OKBuf     = "Correction has valid number of components as parents",
		 Verbose   = bVerbose,
		 object    = my_id,
		 OrigCoor  = dOrigCoor,
	         ErrorCnt  = ErrorCnt,
		 FileData  = FileData);
  

  /*A Get the number of components on the to_components channel */
  status = 
  om$get_channel_count(	objid		= my_id,
			p_chanselect	= &AS_to_comp,
			count		= (IGRuint *) &NbCorCmp );
  as$status( action = RET_STATUS );
				
  if (  !( status & 1 ) )
    {
      
      VR$PrintVerify(Test = (  !( status & 1 ) ) ,
		     ErrorBuf  = "Error obtaining number of components",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
      End
      return OM_S_SUCCESS;
    }
  
  __DBGpr_int("number of components from om$get_channel_count",NbCorCmp );
  __DBGpr_int("number of correction components in instance",me->my_NbCorCmp ); 
  

  /*A Number of components on to_components channel should match */
  /*A with instance data     */          

  /* Not necessarily! TR 179802022 indicates that the flow arrows are
   * considered as components and therefore, the number of components
   * need not necessarily match! Check for this first!        - Anand */

  if ( NbCorCmp != me->my_NbCorCmp )
  {
    /* It is possible that flow arrow is displayed. check for it - Anand */

    struct GRid ArrowId;

    status = 
    om$get_objid_at_index ( objid = my_id,
		     p_chanselect = &AS_to_comp,
		     index	  = me->my_NbCorCmp,
		     objidaddr    = &ArrowId.objid,
		     osnumaddr    = &ArrowId.osnum  );
    as$status( action = RET_STATUS );
    __DBGpr_obj("ArrowId",ArrowId);

    VR$PrintVerify(Test = ( ArrowId.objid == NULL_OBJID || !( status & 1 ) ),
		   ErrorBuf  = "NUMBER OF CORRECTION COMPONENTS DOES NOT MATCH INSTANCE DATA!!",
		   OKBuf     = "Number of correction components matches instance data.\n     (NOTE: Flow arrows are displayed)",
		   Verbose   = bVerbose,
		   object    = my_id, 
		   OrigCoor  = dOrigCoor,
		   ErrorCnt  = ErrorCnt,
		   FileData  = FileData);
    End
    return OM_S_SUCCESS;
  }

  VR$PrintVerify(Test = FALSE ,
		 ErrorBuf  = "",
		 OKBuf     = "Number of correction components matches instance data",
		 Verbose   = bVerbose,
		 object    = my_id, 
		 OrigCoor  = dOrigCoor,
	         ErrorCnt  = ErrorCnt,
		 FileData  = FileData);
  End
  return OM_S_SUCCESS;

} /* end VRVerifyTopology */

end implementation VRCorrection;

