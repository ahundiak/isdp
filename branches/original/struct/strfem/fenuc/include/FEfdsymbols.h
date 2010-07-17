#ifndef fdsymstruct_def
#define fdsymstruct_def

#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"godef.h"
#include	"gr.h"
#include	"igr.h"
#include	"igrdp.h"
#include	"go.h"
#include	"FEappsymbols.h"

/* *****************************H H H H H******************************* */
/* Doc: FEfdsymbols.h

   Abstract: This file defines data types used for the structural FD
   	symbols.
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      ??-??-??	kk		Creation
      12-18-88	ahs		Added *symbology and *params
					to ???_init_args	
      04-20-89	ahs		Corrected a typo...
      06-12-89	ahs		Moved arrowparms to FEappsymbols.h
      10-27-89	kk		Added bmofs_init_args structure
      11-02-91	kk	2.0.0	Added FE_*_PAR #defines for parameter
      				channel indexes.
      07/20/92	raj	2.0.1	Added 'txtsmb_init_args' structure.
      10/30/92	raj	2.1.0	Added 'matornt_init_args' structure.
      02/08/93	ak	2.2.0	Added FE_INTEMP_PAR	
      03/22/93	jc	2.2.0	Added FE_SACRIF_PAR
      10/13/93	smt	2.4.0	Added edge_num, face_num to txtsmb_init_args,
      				and edge_num to frc2_init_args, frc3_init_args.
*/
/* *****************************H H H H H******************************* */

/*	The index on which APparam objects on the FEfddpb.to_param channel
 *	are connected.
 */

#define	FE_MATERIAL_PAR		0	/* mp_parms	*/
#define	FE_PROPERTY_PAR		1	/* mp_parms	*/
#define	FE_CONSTRAINT_PAR	2	/* fd_parms	*/
#define	FE_FORCE_PAR		3	/* arrowparms	*/
#define	FE_SPDISP_PAR		4	/* arrowparms	*/
#define	FE_MASS_PAR		5	/* fd_parms	*/
#define	FE_TEMP_PAR		6	/* fd_parms	*/
#define	FE_HSRC_PAR		7	/* fd_parms	*/
#define	FE_CONV_PAR		8	/* fd_parms	*/
#define	FE_RADI_PAR		9	/* fd_parms	*/
#define	FE_INJPT_PAR		10	/* fd_parms	*/
#define	FE_INTEMP_PAR		11	/* fd_parms	*/
#define	FE_SACRIF_PAR		12	/* fd_parms	*/
#define	FE_SACRIF_PAR		12	/* fd_parms	*/
#define	FE_BMOFS_PAR		13	/* mp_parms	*/
#define	FE_BMREL_PAR		14	/* mp_parms	*/


/*	-----------------------------------------------------------------
 *	struct definitions
 */

struct	mp_parms {
   	struct GRsymbology symbology;	/* Symbology to use 		*/
	double		symbol_size;	/* Mat/prop common symbol parms	*/
	};

struct	fd_parms {
   	struct GRsymbology symbology;	/* Symbology to use 		*/
	IGRdouble	symbol_size;	/* size of 'pie chart' for fd	*/
	IGRshort	pies_fontpos;	/* pies font position		*/	
	};

struct	frc_parms {
   	struct GRsymbology	symbology;	/* Symbology to use 	*/
	struct	arrowparms	arrow;		/* See: FEappsymbols.h	*/
	};

/*
 *	(IMPORTANT) Union All Possible Symbol Parameters
*/

union smb_params {
	struct	arrowparms	arrow;
	struct	mp_parms	mp;
	struct	fd_parms	fd;
	struct	frc_parms	frc;
	};

/*
 *	Structures Used in FEgenfdsym.init_geom() message argument arg_list
 */
struct frc1_init_args {
	double		mag[2];
	char		direction;
	char		ref_frame;
	double		dist[2];
	char		abs_dist;
	double		ends[2][3];
	int		num_arrows;
	char		distributed;	/* FALSE: Load is concentrated	 */
	};

struct frc2_init_args {
	double		vector[3];	/* Same as the FD vector	*/
	char		type;		/* Force Type	(NORMAL...)	*/
	char		edge_num;	/* Element edge number		*/
	};
	
struct frc3_init_args {
	char		face_num;	/* Solid element face number	*/
	char		edge_num;	/* Element edge number		*/
	double		vector[3];	/* Same as the FD vector	*/
	char		type;		/* Force Type	(NORMAL...)	*/
	};
	
struct frc_init_args {
	char		load_type;	/* FE_FORCE, FE_BODY,...	*/
	char		pull_or_push;	/* TRUE: Pull, FALSE: Push	*/
	double		vector[3];	/* Load Orientation Vector	*/
	double		mag;		/* Load Magnitude		*/
	char		mult_opt;	/* TRUE: Mult option is on	*/
   	double		origin[3];	/* Point to place symbol at	*/
	struct GRid	domain;		/* For geometry based force	*/
	char		domain_type;	/* Geometry domain type		*/
	union {
		struct frc1_init_args	frc1;
		struct frc2_init_args	frc2;
		struct frc3_init_args	frc3;
		} sp;
	struct frc_parms  *params;	/* Symbol active param (OPTIONAL)*/
	};
	
struct mp_init_args {
	long		category;	/* MAT or PROP _CATEGROY	*/
	char		type;		/* PANPROP_TYPE, ISOMAT_TYPE,...*/
   	double		point[3];	/* Element centroid (or close)	*/
   	double		corner[3];	/* Element corner node coord's	 */
   	double		x_vector[3];	/* Input X-axis orient vector	*/
   	double		y_vector[3];	/* Input Y-axis orient vector	*/
   	double		coords[2][3];	/* 2nd & 3rd node coord's	*/
	struct mp_parms	*params;	/* Symbol active param (OPTIONAL)*/
	};
	
struct con_init_args {
	long		constraint;	/* Bit map for constraints	 */
   	double		origin[3];	/* Point wrt which symbol defined*/
	struct GRid	domain;		/* Feature grid (if geom based)	 */
	char		type;		/* Geometry domain type		*/
	struct fd_parms  *params;	/* Symbol active param (OPTIONAL)*/
	};

struct brel_init_args {
	char		pincode[2];	/* Bit map for constraints	 */
   	double		coords[3][3];	/* Beam element node coord's	 */
   	int		nnodes;		/* Number of element nodes	 */
	struct fd_parms *params;	/* Symbol active param (OPTIONAL)*/
	};

struct bornt_init_args {
   	double		y_vector[3];	/* Beam Y-axis orient vector	*/
   	double		coords[3][3];	/* Beam element node coord's	*/
   	int		nnodes;		/* Number of element nodes	*/
	struct mp_parms	*params;	/* Symbol active param (OPTIONAL)*/
	};

struct bmofs_init_args {
	double		var[4];		/* Beam end offsets		*/
   	double		y_vector[3];	/* Beam Y-axis orient vector	*/
   	double		coords[3][3];	/* Beam element node coord's	*/
   	int		nnodes;		/* Number of element nodes	*/
	struct mp_parms *params;	/* Symbol active param (OPTIONAL)*/
	};

struct matornt_init_args {
	char		proj_axis;	/* Projected axis for 2D	*/
	double		angle[3];	/* x,y,z angles			*/
   	double		origin[3];	/* Point wrt which symbol defined*/
	struct mp_parms *params;	/* Symbol active param (OPTIONAL)*/
	};

struct spd_init_args {
   	double		origin[3];	/* Point wrt which symbol defined*/
   	double		spcdisp[6];	/* Node or point specified disp	 */
	struct GRid	domain;		/* Feature grid (if geom based)	 */
	char		type;		/* Geometry domain type		*/
	struct frc_parms  *params;	/* Symbol active param (OPTIONAL)*/
	};

struct mass_init_args {
   	double		origin[3];	/* Point wrt which symbol defined*/
	struct GRid	domain;		/* Feature grid (if geom based)	 */
	char		type;		/* Geometry domain type		*/
	struct fd_parms   *params;	/* Symbol active param (OPTIONAL)*/
	};

struct temp_init_args {
   	double		origin[3];	/* Point wrt which symbol defined*/
	struct GRid	domain;		/* Feature grid (if geom based)	 */
	char		type;		/* Geometry domain type		*/
	struct fd_parms  *params;	/* Symbol active param (OPTIONAL)*/
	};

struct txtsmb_init_args {
   	double		origin[3];	/* Point wrt which symbol defined*/
	struct GRid	domain;		/* Feature grid (if geom based)	 */
	char		type;		/* Geometry domain type		*/
	char		fd_type;	/* CONSTRAINT_TYPE... See FEfddef.h */
	struct fd_parms  *params;	/* Symbol active param (OPTIONAL)*/
	char		edge_num;	/* Element edge number		*/
	char		face_num;	/* Solid Element face number	*/
	};
/*
 *	(IMPORTANT) Union All Possible Symbol Creation Arguments
*/

union smb_init_args {
	struct frc_init_args	frc;
	struct mp_init_args	mp;
	struct con_init_args	con;
	struct brel_init_args	brel;
	struct bornt_init_args	bornt;
	struct bmofs_init_args	bmofs;
	struct matornt_init_args matornt;
	struct spd_init_args	spd;
	struct mass_init_args	mass;
	struct temp_init_args	temp;
	struct txtsmb_init_args	txtsmb;
	};

#endif
