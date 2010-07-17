/*
 	I/STRUCT
 	File dependency :	vsdef.h
 				igr.h
 				growner.h
*/
#ifndef vs_include
#	define vs_include

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif
#ifndef gr_include
#	include "gr.h"
#endif
#ifndef growner_include
#	include "growner.h"
#endif
#ifndef vsdef_include
#	include "vsdef.h"
#endif

/*
 * Type of display representation.
 */
typedef unsigned char VSdspRep ;

/*
 * Construction list for VS features.
 */
struct VScnst_list	{
	int			parent_count	;
	struct GRobj_env	*parent_list	;
	char			*feature_att	; /* Specific attributes    */
	VSdspRep		representation	; /* Display representation */
} ;

/*
 * Feature attributes for a division manager.
 * subFeatureClassid	: class id of sub-features to generate.
 * subFeatureAttr	: attributes for sub-features.
 * divInfo		: more info, eg. how to generate joints between sub-
 *			  features.
 */
struct VS_s_divArgs {
	OMuword		subFeatureClassid ;
	void		*subFeatureAttr ;
	void		*divInfo ;
} ;
typedef struct VS_s_divArgs VSdivArgs ;

/*
 * I/O objects of a VS feature.
 */
struct VS_s_ioDef {
	int	count ;
	struct {
		OMuword	*classids ;
		int	*types ;
	} type ;
	char	**names ;
} ;
typedef struct VS_s_ioDef VSioDef ;

/*
 * Structure defining a VS feature : templates (input) , feet (output), or
 * templates in feet (input-to-ouput: i2o), virtual feet (virtual)
 */
struct VS_s_objDef {
	long	info ;		/* Message key of object info	*/
	int	type,
		minInput ;
	VSioDef	input,
		output,
		i2o,
		virtual ;
	/*
	 * Representation(s) which parent must have when it is consumed.
	 * (ORing of mask).
	 */
	VSdspRep	parentRep ;
} ;
typedef struct VS_s_objDef VSobjDef ;

/*
 * Operation history data types.
 */
struct VS_s_Operator {
	OM_S_OBJID	id ;
	OMuword		os,
			type ;
	struct GRmd_env	env ;
} ;
typedef struct VS_s_Operator VSoperator ;

struct VS_s_OpHistory {
	OM_S_OBJID		resultId ;
	OMuword			resultOs,
				opCount ;
	unsigned long		resultType ;
	VSoperator		*opList ;
	struct VS_s_OpHistory	*next ;
	struct GRmd_env		resultEnv ;
} ;
typedef	struct VS_s_OpHistory VSopHistory ;

struct VSgadget	{
	short	label,
		touchable ;
} ;

/*
 * Character buffers for material, grade, etc.
 */
typedef char VSmatTyp[VS_K_MatTypLen] ;
typedef char VSmatGrd[VS_K_MatGrdLen] ;
typedef char VSfamily[VS_K_FamilyLen] ;
typedef char VSprtNum[VS_K_PrtNumLen] ;
typedef char VSusrNot[VS_K_UsrNotLen] ;
typedef char VSmtoSrc[VS_K_MTOSrcLen] ;
typedef char VSmtoStk[VS_K_MTOStkLen] ;
typedef char VSappSts[VS_K_AppStsLen] ;
typedef char VScstSts[VS_K_CstStsLen] ;

/*
 * List of supports.
 */
typedef struct GRobj_env VSsuppList[VS_K_MAXSUPPORTS] ;

/*
 * List of joints between a feature and other features.
 */
struct VS_s_jointList {
	struct GRobj_env	otherFeature,
				joint ;
} ;
typedef struct VS_s_jointList VSjointList ;

struct VS_s_ElemList
{
  IGRint        *pCount;
  struct GRid   **pList;
};

typedef struct VS_s_ElemList VSlistElmtId ;

#endif
