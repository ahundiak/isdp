/* $Id: VDGadgDef.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDGadgDef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDGadgDef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* File VDGadgDef.h */
/* Include file for gadget definition of the form in Place equipment */

#ifndef VDGadgDef_include
#define VDGadgDef_include

/* Name of file containing user command parameters for command derived from */
/* place equipment                                                          */

#define EQUIPCMD_FILE "EquipCmd"    

/* Main title of the form */
#define G_TITLE  19

/* Group of gadgets for catalog selection */
#define G_CATALOG_GRP 49  

#define G_LOAD_COMP   78       /* Load from component gadget */

#define G_TYPE 27
#define G_TYPE_BUTTON 28

#define G_SUB_TYPE_TEXT   44 
#define G_SUB_TYPE    29
#define G_SUB_TYPE_BUTTON 30

#define G_DESCRIP     31
#define G_SEARCH_CAT  33

#define G_LAST_SEL    54

/* text , field ,button are supposed in relation + 1 */ 

#define G_ATT1_TXT    40
#define G_ATT1        41
#define G_ATT1_BUTTON 42

#define G_ATT2_TXT    50
#define G_ATT2        51
#define G_ATT2_BUTTON 52

#define G_ATT3_TXT    60
#define G_ATT3        61
#define G_ATT3_BUTTON 62

#define G_ATT4_TXT    70
#define G_ATT4        71
#define G_ATT4_BUTTON 72

#define G_SHOW_MAC    59 
#define G_DETAIL_MAC  83

#define NB_ATT_GADGET  4 /* Number of attributes gadgets */

/* Group of gadgets for part selection     */
#define G_PART_GRP    26     

#define G_CATA_LIST           20
#define G_DB_LIST             11

#define G_SEARCH            21
#define G_RESET             22
#define G_PLUS              17
#define G_MINUS             24
#define G_NUM_PART          23



/* Gadget for small pop-up form */
#define G_FIELD_LIST        11
#define G_TEXT_INFO         12
#define G_DESC_INFO         13

/*Form state */
#define SELECT_CATALOG 1
#define SELECT_PART    2
#define PLACE_MAC      3
#define STAT_LIST      4 
#define DYN_LIST       5

/* Gadget in the main form */

#define G_MAC_GRP  34

#define G_READ_PDU         33
#define G_DB_SEL           18
#define G_USER_ATT         16
#define G_TEMPLATE_LIST    12
#define G_REPRESENTATION   43
#define G_OPTIONS          47
#define G_NAME             53
#define G_CS_TOGGLE        58

#define G_FAM_DESCRIP      65
#define G_SYSTEM           73
#define G_SCALE            76
#define G_SCALE_TXT        75 
#define G_TAG_NUMBER       74
#define G_ORIGINAL         69  

#define G_UNIT_NUMBER      81

/* Gadget for attributes management */

#define G_ATTRIBUTE_GRP    38
#define G_STATIC_TOG       37
#define G_ATT_LIST         36
#define G_USR_LIST         82

/* Row for att list field */
#define GI_NAM         0 
#define GI_TYP         1
#define GI_VAL         2
 
#define NUM_COL_ATT    3

/* State for modifying or deleting attributes */
#define NORMAL_STATE 1
#define DEL_STATE    2

#define LOCATE_TEMP   500
#define NO_MORE_TEMP  501
#define FORM_MACRO    502
#define FORM_PART     503
#define FORM_CATALOG  504
#define FORM_ATTRIBUT 505
#define NO_CS         506 
#define LOAD_COMP     507


#define VDPLACE_ID           3
#define VDONLY_ONE_PART      5
#define VD_NO_SEL_CATALOG    7 
#define VD_PID_MODEL         9

#define VD_SEL_CATALOG  3
#define VD_SEL_PART     5

/* Max user attributes in collection */
#define NB_MAX_USER_ATT  25


#define WITH_CS_PLACE    1
#define NO_CS_PLACE      2 


#define	DYNCOMP		10
#define DYN_ON          11
#define DYN_OFF         13


#define VD_ID_SIZE      10


/* Constant for creating collection argument of command */
#define DEFAULT_CMD       0   /* Default parameter for command          */ 
#define HISTORY           1   /* Parameter of last selection            */
#define LOAD_CMD          2   /* Load parameter from a given  component */    

/* 3 constants for update of buffer ACrg_collection */


#define VD_ADD_ATTR       1       /* Add    only */
#define VD_MOD_ATTR       2       /* Modify only */
#define VD_MODADD_ATTR    4       /* Modify or Add*/



#endif

