/* $Id: vsedgeattr.h,v 1.1.1.1 2001/01/04 21:09:43 cvs Exp $ */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/include/vsedgeattr.h
 *
 * Description:
 *      Includes gadget defines for form, VSedgeAttr.frm and defines for
 *	commands, Place Edge Attributes, Modify Edge Attributes.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsedgeattr.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.4  1999/05/12  15:01:26  pinnacle
 * (No comment)
 *
 * Revision 1.3  1999/04/30  21:15:28  pinnacle
 * (No comment)
 *
 * Revision 1.2  1999/04/23  18:34:40  pinnacle
 * CR_179900195
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR  DESCRIPTION
 *      10/07/97        ejm     CR179700200: Need ability to place a contin-
 *                              uously changing bevel on plate edge.
 *
 *                              Added defines G_ADD_PLATES, G_DEL_PLATES,
 *				G_NAM_PLATES, G_FLD_PLATES
 *	04/23/99	ejm     Increased ATT_NB_ATT from 20 to 30; added 
 *				definitions ATT_DEL_THK, ATT_IDX_DTHK
 *	05/12/99	ejm     Set ATT_NB_ATT to 21
 ***************************************************************************/


#ifndef vsedgeattr_include
#define vsedgeattr_include

#define  MACRO_NAME    "edge_att"     /* Name of the macro              */

#define  NB_TEMPLATE   3            /* Number of template of the macro  */
#define  NB_FEET       4            /* Number of feet of the macro */
#define  NB_FEET_G     3            /* Number of graphic feet of the macro */
#define  NB_FEET_V     1            /* Number of virtual feet of the macro */

/* Definition of the names of the objects of the macro                        */

#define SURF            "surf"          /* base surface */
#define EDGE_3D         "edge_3d"       /* current edge */
#define SMALL_EDGE      "small_edge"    /* small edge */
#define ATT_BOX         "box"           /* Type of edge */
#define ALLOW_IND       "allow_ind"     /* Allowance indicator */

/* template's indexes */
#define ATT_T_IDX_SURF		0
#define ATT_T_IDX_EDGE_3D	1
#define ATT_T_IDX_BOX		2

/* feet's indexes */
#define ATT_F_IDX_EDGE_3D	0
#define ATT_F_IDX_SMALL_EDGE	1
#define ATT_F_IDX_BOX		2
#define ATT_F_IDX_ALLOW_IND     3

/* #define for the attributes in the rg_collection */
/* Any increase to ATT_NB_ATT will cause Place Edge Attribute and Modify Edge
   Attribute commands to fail unless code for a new attribute is added in files,
     vsedge/VSedapi.I and vscmd/VSpledatCmdi.I.
*/
#define ATT_NB_ATT      21

#define ATT_LO		"LO"
#define ATT_SO		"SO"
#define ATT_LB		"LB"
#define ATT_SB		"SB"
#define ATT_A		"A"
#define ATT_TYPE_ANGLE	"TYPE_ANGLE"
#define ATT_TYPE_CHAMF	"TYPE_CHAMF"
#define ATT_B		"B"
#define ATT_V		"V"
#define ATT_Y		"Y"
#define ATT_X		"X"
#define ATT_H		"H"
#define ATT_C		"C"
#define ATT_N		"N"
#define ATT_T		"T"
#define ATT_ALLOWANCE	"ALLOWANCE"
#define ATT_PROCESS 	"PROCESS"
#define ATT_SPEC_NB 	"SPEC NUMBER"
#define ATT_TYPE 	"TYPE"
#define ATT_ABS         "ABSOLUTE"
#define ATT_DEL_THK	"DTHK"

/* index of attributes */
#define ATT_IDX_LO          0
#define ATT_IDX_SO          1	
#define ATT_IDX_A           2
#define ATT_IDX_TYPE_ANGLE  3
#define ATT_IDX_TYPE_CHAMF  4
#define ATT_IDX_B	    5
#define ATT_IDX_V           6
#define ATT_IDX_Y	    7
#define ATT_IDX_X	    8
#define ATT_IDX_H           9
#define ATT_IDX_C	    10
#define ATT_IDX_N	    11
#define ATT_IDX_T           12
#define ATT_IDX_ALLOWANCE   13
#define ATT_IDX_PROCESS     14
#define ATT_IDX_SPEC_NB     15
#define ATT_IDX_TYPE   	    16
#define ATT_IDX_LB	    17
#define ATT_IDX_SB	    18
#define ATT_IDX_ABS	    19
#define ATT_IDX_DTHK	    20

/* #define for the form's gadgets */

#define G_LO 		128
#define G_SO 		130
#define G_LB		179
#define G_SB		172
#define G_A 		131
#define G_TYPE_ANGLE 	138
#define G_TYPE_CHAMF 	127
#define G_B 		129
#define G_V 		143
#define G_Y 		133
#define G_X 		136
#define G_H 		132
#define G_C 		134
#define G_N 		135
#define G_T 		104
#define G_ALLOWANCE 	137
#define G_PROCESS 	95
#define G_SPEC_NB 	139
#define G_PL_EDGE	113
#define G_MOD_EDGE	96
#define G_SWAP          181
#define G_ABS_TOGG      182 
#define G_COPY_PARM     114
#define G_INCRIMENT     115
#define G_DECRIMENT     121
#define G_FLD_PLATES    183
#define G_NAM_PLATES    184
#define G_ADD_PLATES    185
#define G_DEL_PLATES    186
#define G_BEVEL_CURVES  187

#define G_FI_MSG_FIELD	10


#define DEFAULT_ANGLE   "R"

#define ATT_BASE_THIN    1  
#define ATT_OFFSET_THIN  2   
#define ATT_BASE_FAT     3
#define ATT_OFFSET_FAT   4

struct edge_set {
	IGRchar      groove_type;
	IGRboolean   add_material;
	IGRboolean   is_absolute;
      	IGRdouble    T;
	IGRdouble    H;
	IGRdouble    C;
	IGRdouble    N;
	IGRdouble    X;
	IGRdouble    Y;
	IGRdouble    L_BASE;
	IGRdouble    L_OFF;
	IGRdouble    S_BASE;
	IGRdouble    S_OFF;
	IGRdouble    V;
	IGRdouble    A;
	IGRdouble    B;
	IGRdouble    allowance;
	IGRchar	     process[80];
	IGRchar      spec_ind[80];
	IGRdouble    DTHK;
};

/*+M
Macro vs$place_or_get_edgeattr

Abstract
	Returns the grids of the edge attribute objects IN ORDER after placing 
	'edge_attrval' on the plate. If edge_attrvals=NULL, this macro just
	returns the edge attribute objects IN ORDER, if there are any.

Arguments
	OUT	IGRlong			*msg		Completion code.
	IN      struct GRobj_env        plate           Struct Plate Object.
        IN      struct edge_set         *edge_attrvals  Structure defining edge
                                                        attribute values.
        OUT     IGRint             	*num_edges      Number of edge
							attribute objects.
	OUT	struct GRid             **edge_list     Edge Attribue objects.

Note
	Memory will be allocated by the macro for 'edge_list'.
	User need to free the memory.

	*msg will be
		MSSUCC	if successfull
		MSFAIL	if severe error
-M*/

extern long  
VSplace_edgeattrs_on_plate 
	__((   IGRlong            *msg,
               struct GRobj_env   plate,
               struct edge_set    *edge_attrvals,
               struct GRmd_env    *cst_env,
               IGRint             *num_edges,
               struct GRid        **edge_list  )) ;

#omdef vs$place_or_get_edgeattr( msg,
				 plate,
				 edge_attrvals = NULL,
				 cst_env       = NULL,
				 num_edges     = NULL,
				 edge_list     = NULL  )

	VSplace_edgeattrs_on_plate( (msg), (plate), (edge_attrvals),
    			         (cst_env), (num_edges), (edge_list ) )

#endomdef

/*+M
Macro vs$get_attrvals_from_edge

Abstract
	Returns the edge attribute values, given the edge attribue object.

Arguments
	OUT	IGRlong			*msg		Completion code.
	IN      struct GRid		edge_obj	Edge Attribute object.
        OUT     struct edge_set         *edge_attrvals  Structure defining edge
                                                        attribute values.
Note
	*msg will be
		MSSUCC	if successfull
		MSFAIL	if severe error
-M*/

extern long
VSget_attrvals_from_edge
	__((   	IGRlong            *msg,
		struct GRid        edge_obj,
		struct edge_set    *edge_attrvals ));

#omdef vs$get_attrvals_from_edge( msg,
				  edge_obj,
				  edge_attrvals )

	VSget_attrvals_from_edge( (msg), (edge_obj), (edge_attrvals) )

#endomdef


/*+M
Macro vs$put_attrvals_to_edge

Abstract
	This macro will put the given edge attribute values in the
	given the edge attribue object.

Arguments
	OUT	IGRlong			*msg		Completion code.
	IN      struct GRid		edge_obj	Edge Attribue object.
        IN      struct edge_set         edge_attrvals   Structure defining edge
                                                        attribute values.
Note
	*msg will be
		MSSUCC	if successfull
		MSFAIL	if severe error
-M*/

extern long
VSput_attrvals_to_edge
	__((   	IGRlong            *msg,
		struct GRid        edge_obj,
		struct edge_set    edge_attrvals ));

#omdef vs$put_attrvals_to_edge( msg,
				edge_obj,
				edge_attrvals )

	VSput_attrvals_to_edge( (msg), (edge_obj), (edge_attrvals) )

#endomdef

#endif
