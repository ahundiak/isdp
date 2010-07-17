/*************************************************************************


Author	: VdM

Creation: Dec. 12, 1989

   Unions structurs for I/ROUTE

Change History

	 Date	    |   name  | modification's description
        ------------+---------+------------------------------------------
	20 April 1990   PW	Add equipment to union structure.
				Requires include of VDequistr.h
        20 Sep   1993   HV      Added support for Connector object
	01 Oct	 1993	Manyam	Added VRLinkInfo structure

*************************************************************************/


#ifndef VRstructs_include
#define VRstructs_include

#include "VRdef.h"
#include "VRdimdef.h"
#include "VRDfCn.h"

struct     VRConnInfo
{
  IGRshort        nVRConn_type;     	/*  connector type      */
  IGRdouble       rpars[VRC_num_dbls];  /* coords - angles  */
  IGRchar         macname[17];  	/* macro name       */
  IGRint          product;   		/* product code (VR_PIPING,       */
                             		/* VR_HVAC ..... etc.             */
};

struct	VRcp_attr 
{
   IGRdouble 	   width;	/* diameter in piping */
   IGRdouble       depth;
   IGRchar         section_mask;   /* bit4 : VR_IN/VR_OUT
                                   bit5 : VR_RED/VR_GREEN
                                   bit0 to 3 : VR_ROUND,VR_OVAL,VR_RECT
				   */
   IGRint          end_prep;
   IGRdouble       pressure;
   IGRdouble       cp_offset;
};


struct VRcache_comp 
{
	/* CACHE ATTRIBUTES INFO */

   IGRshort   cp_number;
   IGRchar cp_geometry;
   IGRchar component_type;
   struct VRcp_attr  *cp_attr;
   IGRchar macro_name[17];   /* name of macro or ci_macro*/

   union
   {
      IGRdouble	throat_rad; /* hvac */
      IGRshort 	modifier; /* piping */
   } misc;
}; 





/* =============== NEW PRODUCT ================== */


struct VRCompDescriptor 
    {
    IGRshort nItemNum;
    };


struct VRCompOrientation 
    {
    IGRshort nPriIndex;		/* Index of segment defining the Primary */
    IGRdouble dPrimary;		/* If (nPriIndex != -1) : (+/- 1) to specify 
				   the relative orientation to the primary
				   axis 
				   Else specifies an angle to the common
				   plane */

    IGRshort nSecIndex;		/* Index of segment defining the Secondary */
    IGRdouble dSecondary;	/* If (nSecIndex != -1) : (+/- 1) to specify 
				   the relative orientation to the Secondary
				   axis 
				   Else specifies an angle to the common
				   plane */
    };

struct VRCompInfo
{
   IGRshort			nIndex[VR_MAX_CPTS]; /* index of component on its
							segments */
   struct VRCompOrientation 	Orientation;
   struct VRCompDescriptor 	Desc;
};

struct VRCCompInfo
{
   IGRshort  nOrienToPlanes[VR_MAX_CPTS*3];	/* Orientation of the
						   component's connect points
						   referentials relatively to
						   their associated planes */
   IGRdouble dAngleToCommon;			/* Angle of the Y axis 
						   relatively to the common
						   plane */ 
   IGRshort  nIndex[VR_MAX_CPTS]; 		/* index of component on its
						   segments */
};

struct VRNozzInfo
{
   IGRdouble			dSecAngle;
};

struct VREquipInfo
{
   IGRchar			*EquipNumber;
};

struct VRSuppInfo
{
   IGRdouble			dOrientation[3];
   IGRdouble			dFactor;
};

struct	VRMLinkInfo
{
	IGRint		CbStat;
        IGRint          NbVertices;
        IGRdouble      *pVertex;
        IGRint          NbSections;
 struct VRCL_sectmap   *pSect;
};

struct  VRLinkInfo
{
        IGRint          NbVertices;
        IGRshort        *pPntType;
};

struct  VRGuideInfo
{
        IGRint          GdType;
        IGRdouble       dSize1;
        IGRdouble       dSize2;
};

union tagAttr
{
  struct VRCompInfo	Comp;
  struct VRNozzInfo	Nozz;
  struct VRSuppInfo	Supp;
  struct VRCCompInfo	CComp;
  struct VREquipInfo	Equip;
  struct VRConnInfo     Conn;
  struct VRGuideInfo    Guide;
  struct VRLinkInfo	Link;
  struct VRMLinkInfo	MLink;
};

struct tagVRSupAttr	
    {
    IGRchar	szTagNumber [20];
    IGRdouble	dSize;
    IGRint	Type;
    IGRchar	szDetailNumber [20];
    IGRdouble	dWeight;
    IGRchar	szRemarks [40];
    IGRint	ApprvStatus;
    IGRint	ConstrStatus;
    IGRchar	cNoMtoFlag;
    };

struct VRGenInfo
{
   IGRshort		nStatus;	/* values are defined in VRdef.h */
	/* component attributes */
   IGRchar 		szAABBCC[VR_CODE_LENGTH];	/* component code */
   IGRshort 		nOption; 	/* component option code */
   IGRchar 		szNumber[13]; 	/* component number */
   IGRchar		szNotes[30];	/* component notes */
   IGRchar		cNoMtoFlg;	/* no MTO flag */
   IGRshort 		nNbAttr;	/* number of attribute templates */
   union tagAttr 	Attr;		/* specific attributes */
   struct tagVRSupAttr 	VRSupAttr;	/* relative to support element 	*/
	/* graphic info */
   IGRshort 		nNbTopo; 	/* number of topologic templates */
   IGRshort 		nJustif;	/* placement connect point number */
   struct GRid		GraphicsId;	/* Components' graphic object (optional) */
   IGRchar 		cRep;		/* vds representation */
};


/*     structure to keep counters of connect positions   */

struct VR_posctr {
                   IGRshort  nPos1;
                   IGRshort  nPos2;
                   IGRshort  nEnt;
                 };

/*     return structure connections tracer    */

struct   VR_contrace  {
                        IGRshort      nCpt;
                        GRclassid     ClassId;
                        VRConstring   szOutId;
                        struct GRid   OutGRid;
                      };

#endif

