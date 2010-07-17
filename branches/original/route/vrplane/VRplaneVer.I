/*
     CLASS  NAME: VRCorrection
     METHOD NAMES: VRVerPlaneTopology

     AUTHOR:   Lori 
     DATE:     21-NOV-94


***********************************************************************/
class implementation VRplane;

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

extern GRclassid OPP_VRCnrlSeg_class_id;

method VRVerPlaneTopology( IGRlong *msg; struct VRvfy_file *FileData;
			 IGRboolean bVerbose; IGRint *ErrorCnt)
{

  IGRlong              status;
  IGRdouble            dOrigCoor[3];
  IGRint               NbChildren, NbCnrlSeg; 
  struct     GRid      *ChildrenBuffer;
  GRclassid            ChildClassId;
  IGRint               i;

  dOrigCoor[0] = me->origin[0];
  dOrigCoor[1] = me->origin[1];
  dOrigCoor[2] = me->origin[2];

  /*A Get the children */

  *msg = MSSUCC;

  status = om$send( msg = message NDnode.NDget_objects 
                   ( (ND_CHILDREN | ND_IN_BUF), NULL, 0,
                    &ChildrenBuffer, 0, OM_K_MAXINT, &NbChildren),
                   targetid = my_id);
  as$status();

 if (  !( status & 1 ) )
    VR$PrintVerify(Test = (  !( status & 1 ) ) ,
                   ErrorBuf  = "Error obtaining plane children",
                   Verbose   = bVerbose,
                   object    = my_id, 
                   OrigCoor  = dOrigCoor,
                   ErrorCnt  = ErrorCnt,
                   FileData  = FileData);

  /*A Validate the classes of the children */

  NbCnrlSeg = 0;
  for ( i = 0; i < NbChildren; i++ )
    {
      status =  om$get_classid ( objid = ChildrenBuffer[i].objid,
                       osnum = ChildrenBuffer[i].osnum,
                       p_classid = &ChildClassId);
      as$status();
      
      /*A Count number of control segments */
      if ( om$is_ancestry_valid ( subclassid = ChildClassId,
                                  superclassid = OPP_VRCnrlSeg_class_id)
          == OM_S_SUCCESS )
        {
          NbCnrlSeg += 1;

	}
    }

  /* plane should have a control segment as child */

  VR$PrintVerify(Test =  ( NbCnrlSeg == 0  ),
                 ErrorBuf  = "Plane has no control segments as children",
                 OKBuf     = "Plane has at least 1 control segment as child",
                 Verbose   = bVerbose,
                 object    = my_id, 
                 OrigCoor  = dOrigCoor,
                 ErrorCnt  = ErrorCnt,
                 FileData  = FileData);
  
  return OM_S_SUCCESS;
}

end implementation VRplane;	
	 


