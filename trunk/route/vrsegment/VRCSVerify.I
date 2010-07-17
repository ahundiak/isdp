/*
     CLASS  NAME: VRCnrlSeg
     METHOD NAMES: VRVerCSTopology

     AUTHOR:  Lori
     DATE:    21-NOV-94


***********************************************************************/
class implementation VRCnrlSeg;

#include <stdio.h>
#include "EXgrid.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "VRcompdef.h"
#include "VRparamdef.h"
#include "AS_status.h"
#include "nddef.h"
#include "VRverify.h"
#include "VRverifymac.h"
#include "VDmem.h"

extern GRclassid OPP_VRGeneric_class_id;
extern GRclassid OPP_VRplane_class_id;
extern GRclassid OPP_VRCptIn_class_id;
extern GRclassid OPP_VRNozzle_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;



method VRVerCSTopology( IGRlong *msg; struct VRvfy_objs *NewObj;
			struct GRmd_env *md_env;
			struct VRvfy_file *FileData;
			IGRboolean bVerbose; IGRint *ErrorCnt)
{

  IGRlong           status, retmsg;
  IGRint            NbParents, NbChildren, NbGeneric, NbPlanes;
  IGRint            i, j, NbComp;
  struct     GRid   *ParentBuffer, *ChildrenBuffer, objects[1];
  GRclassid         ParentClassId, ChildClassId, ObjectClassId;
  IGRdouble         dOrigCoor[3];
  struct ret_struct seg_str;
  IGRboolean        bHasCptIn, bHasNozzle, bFound;

  /*A get the connect point geometry */

  *msg = MSSUCC;

  status = om$send(msg = message NDnode.NDgive_structure
		   ( &retmsg, &seg_str, md_env),
                          targetid = my_id );

  dOrigCoor[0] = seg_str.var.line_st.p1[0];
  dOrigCoor[1] = seg_str.var.line_st.p1[1];
  dOrigCoor[2] = seg_str.var.line_st.p1[2];
  
  if (  !( status & 1 ) || !(retmsg & 1) )
    VR$PrintVerify(Test = (  !( status & 1 ) || !(*msg & 1) ) ,
                   ErrorBuf  = "Error obtaining control segment geometry",
                   Verbose   = bVerbose,
                   object    = my_id, 
                   OrigCoor  = dOrigCoor,
                   ErrorCnt  = ErrorCnt,
                   FileData  = FileData);
  


  /*A Get the children */
  status = om$send( msg = message NDnode.NDget_objects 
		   ( (ND_CHILDREN | ND_IN_BUF), NULL, 0,
		    &ChildrenBuffer, 0, OM_K_MAXINT, &NbChildren),
		   targetid = my_id);
  as$status();

 if (  !( status & 1 ) )
    VR$PrintVerify(Test = (  !( status & 1 ) ) ,
                   ErrorBuf  = "Error obtaining control segment children",
                   Verbose   = bVerbose,
                   object    = my_id, 
                   OrigCoor  = dOrigCoor,
                   ErrorCnt  = ErrorCnt,
                   FileData  = FileData);

  /*A Validate the classes of the children */
  NbGeneric = 0;
  bHasCptIn = FALSE;
  bHasNozzle = FALSE;
  for ( i = 0; i < NbChildren; i++ )
    {
      status =  om$get_classid ( objid = ChildrenBuffer[i].objid,
		       osnum = ChildrenBuffer[i].osnum,
		       p_classid = &ChildClassId);
      as$status();
      
      /*A Count number of generic components */
      if ( om$is_ancestry_valid ( subclassid = ChildClassId,
				  superclassid = OPP_VRGeneric_class_id)
	  == OM_S_SUCCESS )
	{
	  NbGeneric += 1;
	  if ( om$is_ancestry_valid ( subclassid = ChildClassId,
				     superclassid = OPP_VRCptIn_class_id)
	      == OM_S_SUCCESS )
	    bHasCptIn = TRUE;
	  	  if ( om$is_ancestry_valid ( subclassid = ChildClassId,
				     superclassid = OPP_VRNozzle_class_id)
	      == OM_S_SUCCESS )
	    bHasNozzle = TRUE;
	}
	    
    }


  /*A Control Segment should have 2 children subclassed from VRGeneric */

  VR$PrintVerify(Test =  ( NbGeneric != CORRECT_NUM_GENERIC ),
		 ErrorBuf  = "Invalid number of VRGeneric objects as children",
		 OKBuf     = "Valid number of components as children",
		 Verbose   = bVerbose,
		 object    = my_id, 
		 OrigCoor  = dOrigCoor,
		 ErrorCnt  = ErrorCnt,
		 FileData  = FileData);

  /*A Get the parents of the Control Segment */
  status = om$send( msg = message NDnode.NDget_objects 
		   ( (ND_ROOT | ND_IN_BUF), NULL, 0, &ParentBuffer, 0,
		    OM_K_MAXINT, &NbParents ),
		   targetid = my_id);
  as$status();

  if (  !( status & 1 ) )
    VR$PrintVerify(Test = (  !( status & 1 ) ) ,
                   ErrorBuf  = "Error obtaining control segment parents",
                   Verbose   = bVerbose,
                   object    = my_id, 
                   OrigCoor  = dOrigCoor,
                   ErrorCnt  = ErrorCnt,
                   FileData  = FileData);


  /*A  See if we are collecting planes.  If we are the array size will */
  /*A  be greater than zero.  If so, make sure that it is big enough   */
  /*A  to hold the possible new objects                                */
  if (NewObj[PLANE_OBJ_NUM].ArraySize > 0)
    {
      if ((NewObj[PLANE_OBJ_NUM].ArraySize) <= 
          NewObj[PLANE_OBJ_NUM].ObjCount + NbParents )
        {
          NewObj[PLANE_OBJ_NUM].ArraySize = 
            NewObj[PLANE_OBJ_NUM].ArraySize + NbParents + 50;
          NewObj[PLANE_OBJ_NUM].object = (struct GRid *)_REALLOC (NewObj[PLANE_OBJ_NUM].object, (NewObj[PLANE_OBJ_NUM].ArraySize ), struct GRid );
        }
      
      
      if ( !(NewObj[PLANE_OBJ_NUM].object)  )
        {
          *msg = MSFAIL;
          return OM_E_NODYNMEM;
        }
    }


  /*A Validate the classes of the parents */
  NbPlanes = 0;
  for ( i = 0; i < NbParents; i++ )
    {

      status =  om$get_classid ( objid = ParentBuffer[i].objid,
		       osnum = ParentBuffer[i].osnum,
		       p_classid = &ParentClassId);
      as$status();
      /*A Parents should be planes */

      if (  (om$is_ancestry_valid ( subclassid = ParentClassId,
				  superclassid = OPP_VRplane_class_id) 
	  != OM_S_SUCCESS ))
	{
	  VR$PrintVerify(Test      = TRUE,
			 ErrObj    = &ParentBuffer[i],
			 ErrorBuf  = "Parent of control segment should be a Plane",
			 OKBuf     = NULL,
			 Verbose   = bVerbose,
			 object    = my_id, 
			 OrigCoor  = dOrigCoor,
			 ErrorCnt  = ErrorCnt,
			 FileData  = FileData);
	}
      else
	{
	  NbPlanes += 1;

	  /*A  See if we are collecting planes.  If so search the list  */
          /*A  already collected for the current plane and if not found */
          /*A  add it to the current list.                              */
          
	  if (NewObj[PLANE_OBJ_NUM].ArraySize > 0)
            {
              bFound = FALSE;
              
              for (j = 0; j < NewObj[PLANE_OBJ_NUM].ObjCount; j++)
                {
                  if( (NewObj[PLANE_OBJ_NUM].object[j].objid) == 
                     ParentBuffer[i].objid && 
                     (NewObj[PLANE_OBJ_NUM].object[j].osnum == 
                      ParentBuffer[i].osnum ))
                    {
                      bFound = TRUE;
                      break;
                    }
                }
              if ( !bFound ) 
                {
                  
                  NewObj[PLANE_OBJ_NUM].object[NewObj[PLANE_OBJ_NUM].ObjCount].objid = 
                    ParentBuffer[i].objid;
		  NewObj[PLANE_OBJ_NUM].object[NewObj[PLANE_OBJ_NUM].ObjCount].osnum = 
		    ParentBuffer[i].osnum;
                  NewObj[PLANE_OBJ_NUM].ObjCount += 1;
                }
	    }
	}
    }


  /*A Control Segment should have 4 planes as parents */

  if ( !(bHasCptIn) && !(bHasNozzle) )
    {
      VR$PrintVerify(Test =  ( NbPlanes != CORRECT_NUM_PLANE ),
		     ErrorBuf  = "Control Segment has invalid number of planes as parents",
		     OKBuf     = "Control Segment has valid number of planes as parents",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
    }
  else
    {
      VR$PrintVerify(Test =  ( NbPlanes != CORRECT_NUM_PLANE_REF ),
		     ErrorBuf  = "Control Segment has invalid number of planes as parents",
		     OKBuf     = "Control Segment has valid number of planes as parents",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
    }


  status = om$send(msg = message GRowner.GRget_components
		   (&retmsg, md_env, objects, 1, &NbComp, 0, 0),
		   targetid = my_id);

  if ( !(NbComp>0) || !(status & 1) || !(retmsg & 1))
    {
      VR$PrintVerify(Test      = TRUE,
		     ErrorBuf  = "Error obtaining line segment for control segment",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
    }
  else
    {
      status =  om$get_classid ( objid = objects[0].objid,
				osnum = objects[0].osnum,
				p_classid = &ObjectClassId);
      as$status();
      
      
      VR$PrintVerify(Test = ( om$is_ancestry_valid
			     ( subclassid = ObjectClassId,
			      superclassid = OPP_GR3dlineseg_class_id) 
			     != OM_S_SUCCESS),
		     ErrObj    = objects,
		     ErrorBuf  = "owned by control segment should be line segment.",
		     OKBuf     = NULL,
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
    }
  
  
  return OM_S_SUCCESS;


} /* end VRVerifyTopology */


end implementation VRCnrlSeg;













