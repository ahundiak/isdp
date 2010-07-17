class specification FEfemfd (1:0) of FEfd;

/* *****************************H H H H H******************************* */

/* Doc: FEfemfd

   Abstract: Parent class of feature descriptors in the 'ISAS' module.
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      07-25-88	kk		Creation
      08-11-88	aap		Added get_domain_uids
      05-22-89	ahs		Override message update
      07-09-89	kk		Added type_count message
      06-22-90	kk		Added get_domain_edges message
      06-23-90	kk		Added get_domain_faces message
      07-13-90	kk/raj		Added is_lc_in_use message
      08-06-90	kk		Changed "type" type from char to long
      02-23-92	kk	2.0.0	Added GEget_domain_vertices message
				Renamed get_domain.. -> GEdte_domain..
      06-24-92	Manyam  2.0.0 	Added cvrt_wakeup, cvrt_process mesaages
      08-30-92	kk	2.1.0	Added domain_index argument to GEget_domain_edges/faces
      04/15/93	raj	2.2.0	Override 'inc_rsman_fd_count'.
*/
/* *****************************H H H H H******************************* */

#include "OMmacros.h"
#include "FEfdstruct.h"
#include "FEfddef.h"
#include "FEfdsymbols.h"

/* ====================================================================== *
 *	G E N E R I C    F D   M E S S A G E S   A T   ISAS		  *
 * ====================================================================== */

message	  get_domain_uids(
	IGRlong		*msg;		/* o - Return Status		*/
	IGRlong		domain_type ;	/* i - 0:nodes, 1:elements	*/
	IGRlong		flag;		/* i - 0:return count,1:return	*/
					/*	uid list and count	*/
	IGRlong		*num_uid;	/* o - number of uids on channel*/
	IGRlong		uid_list[];	/* i/o-array of nd or elem uids	*/
	struct GRid	grid_list[];	/* i/o - array of grid		*/
	IGRshort	*elem_type;	/* o - 0:line, 1:line,2:solid	*/
	struct GRid	el_grids[];	/* i - Translate self if NULL	*/
	long		num_els;	/* i - Number of elem in el_grids*/
);

message	  type_count (
	  struct fefdstats *fd_stats;	 /* i/o  Feature descriptor statistics	*/
);	  

message is_lc_in_use (
	long		*msg;		/* o - return status		*/
	long		type;		/* i - FE_LOAD or FE_CONS. See fersstruct.h */
	struct lc_usage	lc_usag[];	/*i/o- Toggle corresponding flag*/
	long		num_lcs;	/* i - Number of entries in lc_usage */
);

message	on_off (
	IGRshort		action;	/* i - 1: ON,  0: OFF		*/
	char			category;/*i - fd category; NONMP, MAT	*/
	char			type;	/* i - fd type; FORCE, ISO, ...	*/
	);

/* ====================================================================== *
 *	I/RASNA   M E S S A G E S
 * ====================================================================== */

message	GEget_domain_vertices (
	long		*msg;		/* o - return status		*/
	long		**vert_uids;	/* o - Vertex uids		*/
					/*     Ignored if NULL. Caller free */
	OM_S_OBJID	**vert_objids;	/* o - Vertex objids		*/
					/*     Ignored if NULL. Caller free */
	long		*num_vertices;	/* o - Number of vertices	*/
);

message	GEget_domain_edges (
	long		*msg;		/* o - return status		*/
	long		domain_index;	/* i - On FEfd.to_gf channel	*/
					/*     -1 : All domains		*/
	long		**edge_uids;	/* o - Edges as node pairs	*/
					/*     Ignored if NULL. Caller free */
	OM_S_OBJID	**edge_objids;	/* o - Edges as node pairs	*/
					/*     Ignored if NULL. Caller free */
	long		*num_edges;	/* o - Number of edges in list	*/
);

message	GEget_domain_faces (
	long		*msg;		/* o - return status		*/
	long		domain_index;	/* i - On FEfd.to_gf channel	*/
					/*     -1 : All domains		*/
	long		**face_uids;	/* o - faces as node maps[][4]	*/
					/*     Ignored if NULL. Caller free */
	OM_S_OBJID	**face_objids;	/* o - faces as node maps[][4]	*/
					/*     Ignored if NULL. Caller free */
	long		*num_faces;	/* o - Number of faces in list	*/
);

message cvrt_wakeup (
	long		*msg;		/* o - completion code		*/
	);

message cvrt_process (
	long		*msg;		/* o - completion code		*/
	long		*flag;		/* i - 1 from FEmpman 0 from 
						FEstructure		*/
	);

/* ====================================================================== *
 *	O V E R R I D E S   A N D   R E J E C T S
 * ====================================================================== */

override delete,
	 fd_init,
	 setup_smb_args,
	 GRnotifylis,
	 update,
	 inc_rsman_fd_count;

end specification FEfemfd; 
