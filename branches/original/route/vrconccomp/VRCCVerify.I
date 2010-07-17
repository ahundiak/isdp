/*
     CLASS  NAME: VRComponent
     METHOD NAMES: VRVerifyTopology 


***********************************************************************/
class implementation VRConcComp;


#include "EXgrid.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "VRcompdef.h"
#include "VRparamdef.h"
#include "AS_status.h"
#include "VRverify.h"
#include "VRverifymac.h"
#include "nddef.h"

extern GRclassid OPP_VRplane_class_id;
extern GRclassid OPP_VRCnrlSeg_class_id;
extern GRclassid OPP_VRCorrection_class_id;
extern GRclassid OPP_ACrg_collect_class_id;

method VRVerifyTopology(IGRlong *msg; struct GRmd_env *md_env;
			struct VRvfy_objs *NewObj; 
			struct VRvfy_file *FileData;
			IGRboolean bVerbose; IGRint *ErrorCnt;
			IGRdouble *dOrigCoor) 
{

  IGRlong           status;
  IGRint            NbParents, NbCnrlSeg, NbPlanes;
  struct     GRid   *ParentBuffer;
  GRclassid         ParentClassId;
  IGRint            i,j;
  IGRchar           OKBuf[150], ErrorBuf[150];
  IGRboolean        bFound;

  *msg  = MSSUCC;
  NbCnrlSeg = 0;
  status = om$send( msg = message NDnode.NDget_objects 
		   ( (ND_ROOT | ND_IN_BUF), NULL, 0, &ParentBuffer, 0,
		    OM_K_MAXINT, &NbParents ),
		   targetid = my_id);
  as$status();

  /* Error Check */
  if ( !( status & 1 ) )
    VR$PrintVerify(Test = (  !( status & 1 ) ) ,
		   ErrorBuf  = "Error obtaining component parents",
		   Verbose   = bVerbose,
		   object    = my_id, 
		   OrigCoor  = dOrigCoor,
		   ErrorCnt  = ErrorCnt,
		   FileData  = FileData);

  /* if we need to return control segments check memory allocation */
  if ( NewObj[CS_OBJ_NUM].ArraySize > 0 )
    {
      if ((NewObj[CS_OBJ_NUM].ObjCount + NbParents) >= NewObj[CS_OBJ_NUM].ArraySize)
	{
	  NewObj[CS_OBJ_NUM].ArraySize += NbParents + 50;
	  NewObj[CS_OBJ_NUM].object = (struct GRid *) om$realloc
	    (ptr = (char *)NewObj[CS_OBJ_NUM].object,
	     size = (NewObj[CS_OBJ_NUM].ArraySize ) *
	     sizeof( struct GRid) );
	}
      
      if ( !(NewObj[CS_OBJ_NUM].object)  )
	{
	  *msg = MSFAIL;
	  return OM_E_NODYNMEM;
	}
    }
   
  /* Validate parents */
  NbPlanes = 0;
  for ( i = 0; i < NbParents; i++ )
    {
      
      status =  om$get_classid ( objid = ParentBuffer[i].objid,
				osnum = ParentBuffer[i].osnum,
				p_classid = &ParentClassId);
      as$status();
      
      /* check for collections as 1st nNbAttr parents */
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
    

       if ( om$is_ancestry_valid ( subclassid = ParentClassId,
				 superclassid = OPP_VRCnrlSeg_class_id)
	  == OM_S_SUCCESS )
	{
	  
	  NbCnrlSeg += 1;

	  /* if we need to return control segments, search for them in the */
          /* current list, if not found add                                */
	  if ( NewObj[CS_OBJ_NUM].ArraySize > 0 )
	    {
	      bFound = FALSE;
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
	      
	      if ( !bFound ) /* we don't already have this CS, add to list */ 
		{
		  NewObj[CS_OBJ_NUM].object[NewObj[CS_OBJ_NUM].ObjCount++] = 
		    ParentBuffer[i];
		}
	    }
	}
      /* count number of planes */
      if ( om$is_ancestry_valid ( subclassid = ParentClassId,
				 superclassid = OPP_VRplane_class_id)
	  == OM_S_SUCCESS )
	NbPlanes += 1;
    }

  sprintf(ErrorBuf, "Incorrect number of planes as parents (%d)", NbPlanes);
  sprintf(OKBuf, "Correct number of planes as parents (%d)", NbPlanes);

  /* validate number of planes */
  VR$PrintVerify( Test      = (NbPlanes != 3 * (me->nNbCpts)),
		 ErrorBuf  = ErrorBuf,
		 OKBuf     = OKBuf,
		 Verbose   = bVerbose,
		 object    = my_id, 
		 OrigCoor  = dOrigCoor,
		 ErrorCnt  = ErrorCnt,
		 FileData  = FileData);

  /* validate number of parents */
  VR$PrintVerify(Test = (NbParents != (me->nNbAttr + me->nNbTopo + NbPlanes)),
		 ErrorBuf  = "Invalid Number of Parents",
		 OKBuf     = "Valid Number of Parents",
		 Verbose   = bVerbose,
		 object    = my_id, 
		 OrigCoor  = dOrigCoor,
		 ErrorCnt  = ErrorCnt,
		 FileData  = FileData);

  /* perform rest of topology verifications */
  status = om$send(msg = message VRGeneric.VRVerifyChildren
		   (msg, md_env, NewObj, FileData, bVerbose, ErrorCnt,
		    dOrigCoor, NbCnrlSeg),
		   targetid = my_id);

  return OM_S_SUCCESS;
}


end implementation VRConcComp;


