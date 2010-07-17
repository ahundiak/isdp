/* ******************************************************************
Autor	: Karine

Date 	: July-1992

Subject	: Component Manager Class.
	  Class that manages the components,
	
History	:
	06 Oct 93 Manyam 	Added CmpCat, CmpBehavior to instance
	26 Sep 94 Manyam	Added VRValidateXtion() method

***********************************************************************	*/

class specification VRCmpMgr (1:0) of VDB_LOCATE;

#include "bserr.h"
#include "VRattr_def.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "vrdef.h" 
#include "VRdimdef.h"
#include "VRstructs.h"
#include "VRcompdef.h"
#include "VRpriv_attr.h"
#include "VRparamdef.h"
#include "FI.h"
#include "FEI.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "gr.h"
#include "dpdef.h"
#include "VRco.h"
#include "VRmsg.h"
#include "parametric.h"
#include "ndmacros.h"
#include "nddef.h"
#include "VRsketchdef.h"
#include "VRmacros.h"

instance VRCmpMgr
{
  struct	GRid		CmpId;
  IGRmatrix			CmpMatrix;
  IGRchar			CmpAABBCCcode[VR_CODE_LENGTH];
  IGRchar			CmpNumber[80];
  IGRchar			CmpNotes[80];
  IGRchar			CmpNoMtoFlag;
  IGRshort			CmpItemNum;
  IGRshort			CmpStatus;
  IGRshort			CmpOption;
  IGRint			CmpType;
  IGRint			CmpNbCpts;
  IGRint			Flags;
  IGRshort			CptNum;
  IGRint			NbSupports;
  IGRuchar			cRep;
  struct	GRsymbology	Symb;
  struct	GRid		SysParamId;
  struct	GRid		UsrParamId;
  struct	GRid		MissParamId;
  IGRdouble			SupOrientation[3*VR_MAX_CPTS];
  IGRdouble			Angle;
  IGRshort			Product;
  struct	GRmd_env	ModuleEnv;
  IGRint			CmpCat;		
  IGRint			CmpBehavior;
  IGRint			PrevTagNum;
  IGRint                        NextCptNum;

  IGRboolean			bTagNumUsed;	
  IGRboolean			bFlipByCenterPoint;
  IGRboolean                    bCmpReversed;
  IGRboolean                    bIsRotCmd;

  IGRboolean                    bSKF_up;
  IGRchar                      *pSKF;
};


/* ------------------------------------------------------------------- */
message VRInitInstance( IGRlong *sts );

/* ------------------------------------------------------------------- */
message VRGetCompMatrix( IGRlong *sts  );

/* ------------------------------------------------------------------- */
message VREvaluateComp( IGRlong *sts );

/* ------------------------------------------------------------------- */
message VRRotateComponent( IGRlong *sts );

/* ------------------------------------------------------------------- */
message VRReverseComponent( IGRlong *sts );

/* ------------------------------------------------------------------- */
message VRComputeCmpAngle( IGRlong *sts );

/* ------------------------------------------------------------------- */
message VRRotateQuadrant( IGRlong *sts );

/* ------------------------------------------------------------------- */
message VRGetAABBCCCode( IGRlong *sts );

/* ------------------------------------------------------------------- */
message VROrientByAngle( IGRlong *sts );

/* ------------------------------------------------------------------- */
message VRDisplayAngle( IGRlong *sts );

/* ------------------------------------------------------------------- */
message VRValidateXtion( IGRlong *sts );

/* ------------------------------------------------------------------- */
message VRSKF_start( IGRlong *sts );
message VRSKF_fill ( IGRlong *sts );

end specification VRCmpMgr;
