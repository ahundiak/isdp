/*
     CLASS  NAME: VRComponent
     METHOD NAMES: VRVerifyToplogy

     AUTHOR:      Lori

     DATE:        21-NOV-94

***********************************************************************/
class implementation VRComponent;


#include "EXgrid.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "VRcompdef.h"
#include "VRparamdef.h"
#include "AS_status.h"
#include "nddef.h"
#include "VRverify.h"
#include "VRverifymac.h"

extern GRclassid         OPP_VRCnrlSeg_class_id;
extern GRclassid         OPP_VRCorrection_class_id;
extern GRclassid         OPP_ACrg_collect_class_id;

/***************************************************************************/
/*  This method will verify the topology of a component.  It verifies its
    channel connections.  It the results of the verifications to reports.
    It has the option of also returning all of the corrections and control
    segments attached to the component so that they may be verified later */
/**************************************************************************/

method VRVerifyTopology( IGRlong *msg; struct GRmd_env *md_env;
			struct VRvfy_objs *NewObj; 
			struct VRvfy_file *FileData;
			IGRboolean bVerbose; IGRint *ErrorCnt;
			IGRdouble *dOrigCoor)
{
  IGRlong           retmsg;
  IGRlong           status;
  IGRint            NbParents, NbCorrection, NbCnrlSeg;
  IGRint            i, j;
  struct     GRid   *ParentBuffer;
  GRclassid         ParentClassId;
  IGRboolean        bFound;

  *msg = MSSUCC;
  i = 0;
  retmsg = 0;
  NbCorrection = 0;
  NbCnrlSeg = 0;

  /*A Get the components parents */
  status = om$send( msg = message NDnode.NDget_objects 
		   ( (ND_ROOT | ND_IN_BUF), NULL, 0,
		     &ParentBuffer, 0, OM_K_MAXINT, &NbParents ),
		   targetid = my_id);

  as$status();
  if ( !( status & 1 ) )
    VR$PrintVerify(Test = (  !( status & 1 ) ) ,
		   ErrorBuf  = "Error obtaining component parents",
		   Verbose   = bVerbose,
		   object    = my_id, 
		   OrigCoor  = dOrigCoor,
		   ErrorCnt  = ErrorCnt,
		   FileData  = FileData);
  
  /*A Verify the number of parents on channel to instance data */

  VR$PrintVerify(Test = (NbParents != (me->nNbAttr + me->nNbTopo)),
		 ErrorBuf  = "Invalid Number of Parents",
		 OKBuf     = "Valid Number of Parents",
		 Verbose   = bVerbose,
		 object    = my_id, 
		 OrigCoor  = dOrigCoor,
		 ErrorCnt  = ErrorCnt,
		 FileData  = FileData);



  /*A if we need to return control segments, check memory allocation */

  if ( NewObj[CS_OBJ_NUM].ArraySize > 0 )
    {
      if ( NewObj[CS_OBJ_NUM].ArraySize <=  
	(NewObj[CS_OBJ_NUM].ObjCount + NbParents) )
	{
	  NewObj[CS_OBJ_NUM].ArraySize += NbParents + 50;
	  NewObj[CS_OBJ_NUM].object = (struct GRid *) om$realloc
	    (ptr = (char *)NewObj[CS_OBJ_NUM].object,
	     size = (NewObj[CS_OBJ_NUM].ArraySize ) * 
		sizeof(struct GRid) );
	}
      
      
      if ( !(NewObj[CS_OBJ_NUM].object)  )
	{
	  *msg = MSFAIL;
	  return OM_E_NODYNMEM;
	}
    }
  
  
  /*A Validate parent classes */
  for ( i = 0; i < NbParents; i++ )
    {
      
      status =  om$get_classid ( objid = ParentBuffer[i].objid,
				osnum = ParentBuffer[i].osnum,
				p_classid = &ParentClassId);
      as$status();

      /*A Verify number and placement on channel of collectors with */
      /*A instance data                                             */

      
      if( i < me->nNbAttr )
	VR$PrintVerify(Test = (om$is_ancestry_valid 
			       ( subclassid = ParentClassId,
			         superclassid = OPP_ACrg_collect_class_id) 
			       != OM_S_SUCCESS ),
		       ErrObj    = &ParentBuffer[i], 
		       ErrorBuf  = "This parent should be an attribute collection",
		       OKBuf     = "This parent is a valid attribute collection",
		       Verbose   = bVerbose,
		       object    = my_id, 
		       OrigCoor  = dOrigCoor,
		       ErrorCnt  = ErrorCnt,
		       FileData  = FileData);
    

      /*A Count Number of Control Segments as parents */

      if ( om$is_ancestry_valid ( subclassid = ParentClassId,
				 superclassid = OPP_VRCnrlSeg_class_id)
	  == OM_S_SUCCESS )
	{
	  
	  NbCnrlSeg += 1;
	  bFound = FALSE;
	  /*A if we need to return control segments, update list */
	  /*A check for duplicates                               */

	  if ( NewObj[CS_OBJ_NUM].ArraySize > 0)
	    {
	      for (j = 0; j < NewObj[CS_OBJ_NUM].ObjCount; j++)
		{
		  if( (NewObj[CS_OBJ_NUM].object[j].objid) == 
		     ParentBuffer[i].objid && 
		     (NewObj[CS_OBJ_NUM].object[j].osnum == 
		      ParentBuffer[i].osnum ))
		    {
		      bFound = TRUE;
		      break;
		    }
		}
	      if ( !bFound ) /*A CS not already found, update list & count */
		{
		  NewObj[CS_OBJ_NUM].object[NewObj[CS_OBJ_NUM].ObjCount++] = 
		    ParentBuffer[i];
		}
	    }
	}
    }
  /*A perform topology verifications common to ConcComp */
  status = om$send(msg = message VRGeneric.VRVerifyChildren
		   (msg, md_env, NewObj, FileData, bVerbose, ErrorCnt,
		    dOrigCoor, NbCnrlSeg),
		   mode = OM_e_wrt_message,
		   targetid = my_id);
  
  return OM_S_SUCCESS;
} /* end VRVerifyTopology */


  
end implementation VRComponent;










