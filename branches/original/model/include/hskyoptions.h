
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hskyoptions_include
#define hskyoptions_include 1
/*

ABSTRACT:
	This include file contains representations of hsurf keyin command
	options and values. Such representations are very useful in 
	parsing aforementioned commands.
HISTORY:
	6/15/89		creation		Mitch Giesy

*/
	
static	struct 	bs_tree		ssp_bstree[] = 
				{ "finish", 1,
				  "finish mode", 2,
				  "reflectance", 3,
				  "reflectance mode", 4,
				  "shading tolerance", 5,
				  "show hidden edges", 6,
				  "style", 7,
				  "style mode", 8,
				  "transparency", 9,
				  "transparency grid", 10,
				  "transparency mode", 11
				};
static	struct	bs_tree		sspas_bstree[] =
				{ "area fill", 1,
				  "constant", 2,
				  "filled raster hidden line", 3,
				  "raster hidden line", 4,
				  "smooth", 5
				};

static	struct	bs_tree		sspm_bstree[] =
				{ "active", 1,
				  "element", 2
				};
static	struct	bs_tree		ssptg_bstree[] =
				{ "narrow", 1,
				  "wide", 2
				};

/*
  sorted command option lists for Set Color Table Parameters 
*/
static	struct	bs_tree		sctp_bstree[] =
				{ "color calibration", 1,
				  "color configuration", 2,
				  "color display mode", 3,
				  "shade calculation mode", 4
				};

static	struct	bs_tree		sctpcl_bstree[] =
				{ "no", 1,
				  "yes", 2 
				};
static	struct	bs_tree		sctpcc_bstree[] =
				{ "colors", 1,
				  "shades", 2,
				  "shading mode", 3
				};
static	struct	bs_tree		sctpcd_bstree[] =
				{ "display", 1,
				  "no display", 2
				};
static	struct	bs_tree		sctpsc_bstree[] =
				{ "calc shades", 1,
				  "use shades", 2
				};
static	struct	bs_tree		sctpccm_bstree[] =
				{ "direct", 1,
				  "halftoned", 2
				};
static	struct	bs_tree		sctptp_bstree[] =
				{ "directional", 1,
				  "point", 2
				};
/*
  sorted command option lists for Change Light Source Parameters
*/
static	struct	bs_tree		clp_bstree[] =
				{ "ambient", 1,
				  "global", 2,
				  "window", 3 
				};
/*
  sizes of command option lists
*/
#define	BST_SIZE	sizeof(struct bs_tree)
#define SSP_SIZE	sizeof(ssp_bstree) / BST_SIZE
#define	SSPAS_SIZE	sizeof(sspas_bstree) / BST_SIZE
#define	SSPM_SIZE	sizeof(sspm_bstree) / BST_SIZE
#define	SSPTG_SIZE	sizeof(ssptg_bstree) / BST_SIZE
#define	SCTP_SIZE	sizeof(sctp_bstree) / BST_SIZE
#define	SCTPCC_SIZE	sizeof(sctpcc_bstree) / BST_SIZE
#define	SCTPCD_SIZE	sizeof(sctpcd_bstree) / BST_SIZE
#define	SCTPSC_SIZE	sizeof(sctpsc_bstree) / BST_SIZE
#define	SCTPCCM_SIZE	sizeof(sctpccm_bstree) / BST_SIZE
#define	SCTPCL_SIZE	sizeof(sctpcl_bstree) / BST_SIZE
#define	SCTPTP_SIZE	sizeof(sctptp_bstree) / BST_SIZE
#define	CLP_SIZE	sizeof(clp_bstree) / BST_SIZE

/* simple knowledge structures for parsing the ssp command */
static	struct 	option_set	ssp_options = 
				{ SSP_SIZE, ssp_bstree };
static	struct	option_set	ssp_asvals =
				{ SSPAS_SIZE, sspas_bstree };
static	struct	option_set	ssp_mvals =
				{ SSPM_SIZE, sspm_bstree };
static	struct	option_set	ssp_tgvals =
				{ SSPTG_SIZE, ssptg_bstree };


/* simple knowledge structures for parsing the sctp command */
static	struct	option_set	sctp_options = 
				{ SCTP_SIZE, sctp_bstree };
static	struct	option_set	sctpcc_options =
				{ SCTPCC_SIZE, sctpcc_bstree };
static	struct	option_set	sctp_clvals =
				{ SCTPCL_SIZE, sctpcl_bstree };
static	struct	option_set	sctp_cdvals =
				{ SCTPCD_SIZE, sctpcd_bstree };
static	struct	option_set	sctp_scvals =
				{ SCTPSC_SIZE, sctpsc_bstree };
static	struct	option_set	sctp_ccmvals =
				{ SCTPCCM_SIZE, sctpccm_bstree };
static	struct	option_set	sctp_tpvals =
				{ SCTPTP_SIZE, sctptp_bstree };


/* simple knowledge structures for parsing the clp command */
static	struct	option_set	clp_options =
				{ CLP_SIZE, clp_bstree };
#endif
