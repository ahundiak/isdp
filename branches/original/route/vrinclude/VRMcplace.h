#ifndef VRMcplace_include

#define VRMcplace_include

/***************************************************************************/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VRPlaceAutoComponent __(( 	IGRlong			*msg, 
					IGRint			Product,
					struct GRid		*pCmpId,
					IGRboolean		bDisplay,
					struct GRid		*pSysId,
					struct GRid		*pUsrId, 
					IGRint			NbTopo,
					struct VRTopo		*pTopo,
					struct GRsymbology	*pSymb,
					IGRchar			cRep,
					struct GRmd_env		*pmd_env));

#if defined(__cplusplus)
}
#endif

/***************************************************************************/
/*D
	The macro VR$PlaceAutoComponent, based on the topology description,
	number of segments and orientation, places automatic :

		- Dangle (one segment)
		- Elbow	 (two segments )
		- Tee	 (three segments )

*************************************************************/

#omdef VR$PlaceAutoComponent
		 (	p_lMsg,
			Product,
			p_CmpId,
			bDisplay,
			p_SysId,
			p_UsrId,
			NbTopo,
			p_Topo,
			p_Symb,
			cRep,
			p_MdEnv)

VRPlaceAutoComponent( p_lMsg, Product, p_CmpId, (IGRboolean) bDisplay,
	     p_SysId, p_UsrId, NbTopo, p_Topo, p_Symb, cRep, p_MdEnv )
			
#endomdef





#endif
