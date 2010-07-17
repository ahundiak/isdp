/*************************************************************************


Author	: Manyam

Creation: Mar 9 1994

*************************************************************************/


#ifndef VRStSect_include
#define VRStSect_include

struct	VRSection
{
	struct	GRid		StartId;
	IGRshort		nStartCpt;
	struct	GRid		EndId;
	IGRshort		nEndCpt;
	struct	VRcp_attr	CptAttr;
};

struct	VRSectInfo
{
	IGRint			NbCmps;
	struct	GRid		*pCmpIds;
};

#endif

