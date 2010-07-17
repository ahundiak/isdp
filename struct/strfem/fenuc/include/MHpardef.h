#ifndef	MHpardef_include
#define	MHpardef_include

#include "MHmsdef.h"

/* define recomp_info type for remeshing. */

#define MH_MESH_INFO	1

/* define parameter types at the PRE level
   NOTE: these are also used as channel indices for parameter types */

#define EDG_PAR		0
#define AUTOMESH_PAR	1
#define AMESH_FORMDEF	2
#define MAPMESH_PAR	3

/* define options for smoothing */
#define PROMPT_SMOOTH_OPT	3001
#define AUTO_SMOOTH_OPT		3002
#define	DONT_SMOOTH_OPT		3003


/*
	NOTE: edge active parameters use only struct GRsymbology
	defined in go.h
*/

/*
 * automesh form defaults
*/
struct MHatmesh_formdef {
	struct MHmeshing_info	msinfo;		/* see MHmsdef.h */
	long			smth_opt;	/* smooth/no smooth/prompt */
	long			prompt_pts;	/* if TRUE, prompt for element
						  size (node spacing) by 2 pts*/
	long			sf_on_sol;	/* if TRUE, mesh ems solids
						   with surface elements */
	};

/*
 * automesh parameters
*/

/* define options for updating an associative mesh */

#define SMOOTH		0
#define REMESH		1
#define REMESH_SMOOTH	2

struct MHautomesh_par {
	char	upd_remesh;	/* see values above. */
	char	create_mapedge;	/* if TRUE, create map edges */
	char	mid_smth_uv;	/* if TRUE, smooth midside nodes in uv,
					else smooth in xyz */
	};

/*
 * mapped mesh parameters
*/
struct MHmapmesh_par {
	char	create_mapedge;	/* if TRUE, create map edges */
	char	prmpt_surf;	/* if TRUE, prompt for reference surface */
	};

#endif
