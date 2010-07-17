#ifndef fersstruct_included
#define	fersstruct_included

#include "FDdef.h"

/* Doc: FErsstruct.h

   Abstract: This header file defines structures used by the job run set-up
   	manager.

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      02-12-88	ahs		Creation
      06-16-88	ahs		Added more options to stat_out struct
      01-25-89	ahs		Added eigen_opts structure
      02-20-89	ahs		Added analysis options to gen_opts
      06-01-89	ahs		Added nodal_forces flag to stat_out
      07-13-90	kk/raj		Added #define FE_LOAD ...and struct lc_usage
      08-05-90	kk/raj		Changed #defines for FE_CONS ...
      10-26-91	kk	2.0.0	Upgraded to 2.0. Changed load_case to fd_case
      				Added fd_type to struct fd_case
      11-11-92	kk	2.2.0	Added FErs_HEAT and FErs_INJPT
      06/08/93	raj	2.2.1	Added FE_CFLOW for analysis_engine.
      10-06-93	ak	3.0.0	Added struct tht_opts. 
*/
/* *****************************H H H H H******************************* */

/* ==================================================================
			S T R U C T U R E S
   ==================================================================
*/

struct fd_case  /* Case structure for load cases and constraint cases */
{
	char	bc_type;	/* Boundary cond type: See below*/
	char	name[FD_MAX_FDCNAME_SIZE];     /* FD case name	*/
	long	num;		/* FD case number		*/
	long	fd_count;	/* Number of fd's in FD case	*/
	char	active;		/* TRUE: Consider in Analysis	*/
};
	
struct gen_opts  /* General options for analysis */
{
	char	node_stab;	/* TRUE: auto node stabilization	*/
	char	min_band;	/* TRUE: minimize bandwidth		*/
	char	static_anal;	/* TRUE: perform static analysis	*/
	char	modal_anal;	/* TRUE: perform modal analysis		*/
	char	timhist_anal;	/* TRUE: perform time history		*/
	char	steady_state;	/* TRUE: perform thermal steady state	*/
	char	transient;	/* TRUE: perform thermal transient	*/
	char	model_type;	/* FE_3D, FE_PL_STRS.. See below	*/
	char	analysis_type;	/* FE_STRUCTURAL, .. See below		*/
	char	analysis_engine;/* FE_INTERNAL ..  See below		*/
};

struct stat_out  /* Static analysis output options */
{
	char	disp;		/* TRUE: output displacements		*/
	char	nodal_forces;	/* TRUE: output nodal reaction forces	*/
	char	nod_stress_avg;	/* TRUE: output nodal average stresses	*/
	char	stress_avg_type;/* TRUE: weighted; FALSE: simple	*/
	char	nd_hvm_prin;	/* TRUE: output Nodal HVM & prin strs	*/
	char	elem_stress;	/* TRUE: output element stresses	*/
	char	str_energy_dens;/* TRUE: output strain energy density	*/
	char	el_hvm_prin;	/* TRUE: output Elem HVM & prin strs	*/
	char	le_end_actions;	/* TRUE: output 1-D element end forces	*/
	char	beam_stress;	/* TRUE: output 4 beam stresses		*/
};

struct eigen_opts  /* Modal analysis output options */
{
	char	sol_meth;	/* Solution method: FE_SUBSPACE,...	*/
	long	num_modes;	/* Number of modes to extract		*/
	double	low_freq_limit;	/* Lower frequency limit		*/
	double	up_freq_limit;	/* Upper frequency limit		*/
	char	sturm_check;	/* Sturm sequence check: TRUE or FALSE	*/
	char	norm_method;	/* FE_NORM_MAX, FE_NORM_NODE, ...	*/
	long	node_uid;	/* If FE_NORM_NODE, this is node user ID*/
	char	norm_dir;	/* If FE_NORM_NODE, 1, 2, or 3 direction*/
	char	massx_active;	/* TRUE: global X mass DOF is active	*/
	char	massy_active;	/* TRUE: global Y mass DOF is active	*/
	char	massz_active;	/* TRUE: global Z mass DOF is active	*/
};

struct tht_opts  /* Transient Heat analysis options */
{
	long    num_step;	/* Number of time step	*/
	double  delta_t;	/* Time increment	*/
};

struct lc_usage
{
	long		lc_id;	/* Load case id : 1 based	*/
	char		in_use;	/* 0: Not in use, 1: In use	*/
};

/* ==================================================================
			D E F I N I T I O N S
   ==================================================================
*/
/*
 *	bc_type argument in struct fd_case ( Boundary condition type )
 */
#define	FErs_LOAD	1
#define	FErs_FIXITY	2
#define	FErs_MASS	3
#define	FErs_HEAT	4
#define	FErs_INJPT	5

/*
 *	General Options
 */
/* Model type : model_type in struct gen_opts */
#define	FE_3D		1
#define	FE_PL_STRESS	2
#define	FE_PL_STRAIN	3
#define	FE_AXI_SYM	4

/* Analysis type : analysis_type in struct gen_opts */
#define	FE_STRUCTURAL	1
#define	FE_THERMAL	2
#define	FE_THERM_STR	3

/* Analysis engine : analysis_engine in struct gen_opts */
#define	FE_INTERNAL	1
#define	FE_RASNA	2
#define	FE_CFLOW	3

/*
 *	Eigen Value Analysis Options
 */
/* Eigen Value Solution Methods	: sol_meth in struct eigen_opts  */
#define	FE_SUBSPACE	1
#define	FE_GIVENS	2
#define	FE_MGIVENS	3
#define	FE_INVERSE	4
#define	FE_LANCZOS	5

/* Eigen Vector Normalization : norm_method in struct eigen_opts */
#define	FE_NORM_MAX	1		
#define	FE_NORM_NODE	2
#define	FE_NORM_MASS	3

/* Used for I/RASNA */
#define FE_CONS		101
#define	FE_STATLD	102
#define	FE_DYNLD	103

/* Bits on gen_opts.node_stab */

#define FE_NODE_STAB	0x1
#define FE_RIGID_MODES	0x2

#endif
