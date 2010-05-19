/* $Id $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include/vdtree.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log $
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/10/97	Yzhu		creation
 *
 * -------------------------------------------------------------------*/

#ifndef vdtree_include
#define vdtree_include


/*
 ****************************************************************************
 * Internal object names for the VDTreeSet.
 */
#define	VD_S_treeSetName	"TrSet_"
#define	VD_TREE_NAME_LEN	30
#define	VD_TREE_SETUP_TABLE	"VDAT_SETUP"
#define	VD_TREE_PIECES_TABLE	"VDAT_PIECES"
#define	VD_TREE_STAGES_TABLE	"VDAT_STAGES"
#define	VD_TREE_U_PROD_TABLE	"VDAT_U_PROD_TABLE"

/* for Command 'Define Assembly Components Set' */
#define	VDAT_MAXTEXT		80
#define	VD_TREE_SET_FRMNAME	"VDTrSetFrm"
#define	VD_TREE_SET_UNTFLD	12
#define	VD_TREE_SET_DELBUTT	13
#define	VD_TREE_SET_UNTNAME	14
#define	VD_TREE_SET_ADDBUTT	15
#define	VD_TREE_SET_REMBUTT	16
#define	VD_TREE_SET_TBLNAME	17
#define	VD_TREE_SET_TBLFLD	18
#define	VD_TREE_SET_TITASS	11
#define	VD_TREE_SET_TITPRD	19

/* reture status of form */
#define	VDAT_LOCATE_STATUS	255
#define	VDAT_LOGIN_NOTOK	256

/* action state */
#define VDAT_ACT_ADD		0
#define VDAT_ACT_REM		1
#define VDAT_ACT_DEL		2


/* command type*/
#define VD_TREE_ASS_SET		0
#define VD_TREE_PRD_SET		1


/*re for store VDAS_SETUP information */
struct VDAT_SETUP_INFO
{
    int		stage_level;     	/* stage level */
    char 	stage_type[20];  	/* stage type: UNIT, PSU ..*/
    char 	stage_syntax[80];  	/* syntax definition:[0-999]*/
    char 	stage_descr[80];  	/* describtion */
    char 	node_name_cons[80];  	/* Name Constraint: Unique in stage: */
    char 	node_path_desc[20];  	/* node path describtion: */
    char 	node_path_sep[2];  	/* seperator between nodes */
    int 	node_path_swap;  	/* indicator to swap with child path.*/
    char 	node_path_prefix[20];  	/* print out control/prefix.  */
};

/* structure for store set information */
struct VDAT_SETLIST
{
    struct GRobj_env    obj_env;    
    char         	set_name[VDAT_MAXTEXT];         
    char         	tbl_name[VDAT_MAXTEXT];         
};


#endif	/* vdtree_include */
