#ifndef VPext_include
#define VPext_include

#ifndef   vlprototype_include
#include "vlprototype.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ------------------------------------------------------
 * Internal Prototypes
 */

typedef struct unw_obj_plat Tunw_obj_plat;
typedef struct mise_a_plat  Tmise_a_plat;
typedef struct EdgeMatch    TEdgeMatch;

extern IGRstar VPextPlateRollLine __((Tunw_obj_plat   *unwrapDEV,
				      TGRobj_env      *plateOE,
				      TGRvg_construct *cst,
				      TGRmd_env       *curENV,
				      TGRid           *rollID));

extern IGRstar VPextPlateRollLines __((Tunw_obj_plat   *unwrapDEV,
				       TGRobj_env      *plateOE,
				       TGRvg_construct *cst,
				       TGRmd_env       *curENV));
  
extern IGRstar VPextPlateMarkingLine __((Tunw_obj_plat   *unwrapDEV,
					 TGRobj_env      *plateOE,
					 TGRvg_construct *cst,
					 TGRmd_env       *curENV,
					 TGRid           *rollID));

extern IGRstar VPextPlateMarkingLines __((Tunw_obj_plat   *unwrapDEV,
					  TGRobj_env      *plateOE,
					  TGRvg_construct *cst,
					  TGRmd_env       *curENV));
  

extern IGRstar VPextProcessPlate __((TGRobj_env *plateOE, TGRobj_env *plateOE1));


// -------------------------
#if defined(__cplusplus)
}
#endif

#endif








