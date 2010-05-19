/* $Id: SMCompForm.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMCompForm.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCompForm.h,v $
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
 * Revision 1.1  1996/03/01  19:59:56  pinnacle
 * created to maintain the vds clix portion of pme
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

/* Defined for command objects of compartments */

#ifndef SMCompForm_include
#define SMCompForm_include

/*
 * Constant defining maximum of attributes
 */
#define SM_MAX_CO_ATTR 120

/*
 * Name of the file containing tightness
 */
#define TIGHTNESS_FILE "Tightness"

/* Type of commands */
#define PLACE        0
#define MODIFY       1
#define PL_COMP_HULL 2
#define MD_COMP_HULL 3

/* Compart constant */
#define SM_VOL_MAX_ATT   4

/* Response to state in form */

#define NO_OBJ_LOCATED   501
#define TO_MUCH_VOL      502
#define BEGIN_ATTR_FORM  503
#define BEGIN_DISP_FORM  504
#define BEGIN_VOL_FORM   505
#define BEGIN_GEOM_FORM  506
#define LOCATE_VOL       507 
#define RELOCATE_OBJ     508
#define ONLY_ONE_PART    509
#define READ_FROM_PDU    510
#define BEGIN_DATA_SEL   511
#define LOAD_DATA_SEL    512 
#define PME_DATA_SEL     513
#define LOAD_PME_DATA    514

  

/* Main Gadgets */

#define G_DATA_SEL       24  /* button database selection */
#define G_READ_PDU       29  /* button Read Pdu review */
#define G_PME_OPT	 44  /* button PME Option */

#define G_COMP_TITLE     11  /* Tittle of the form */

#define GROUP_MAIN       113 /* group : 13, 41, 15, 17, 22, 20, 18, 21, 19 */
                             /* 32, 28 + TIGHTNESS =47                     */


#define G_NAME           13 /* field Name */
#define G_SHORT_DESC     41 /* field Short Desc */
#define G_DESCRIP        15 /* field Desc */
#define G_DEAD_TEXT      17 /* DW (field name) */
#define G_DEAD_LIST      22 /* DW field list   */
#define G_GROUP_LIST     20 /* Grp (field name) */
#define G_GROUP_TEXT     18 /* Grp field list */
#define G_SUB_GROUP_LIST 21 /* S_Grp (field name) */
#define G_SUB_GROUP_TEXT 19 /* S_Grp field list */
#define G_CLASS          28 /* Class field */
#define G_ZONE           32 /* Zone field */
#define G_TIGHTNESS      47


#define G_HULL_LIST      21    /* Hull_list is a synonym for sub_group */
#define G_HULL_TEXT      43    /* Hull Type (title for G_HULL_LIST)   */


/* Gadget for selecting volumes, attributes, disp or geom_info */

#define GROUP_SELECT     38 /* Group: 30, 35, 36, 23  */

#define G_VOLUMES        30
#define G_USER_ATT       35
#define G_DISP_OPT       36
#define G_GEOM_INFO      23

/* Gadget for attributes */

#define GROUP_ATT       54 /* Group: 49, 53, 110, 40, 48, 42 */

#define G_ATT_LIST      49 /* multi column field (name, type, value) */
#define G_DEL_ATT       53 /* Delete Row button */
#define G_STATIC_TOG   110 /* static/dynamic toggle */
#define G_PSEUDO        40 /* Pseudo/Real toggle */
#define G_CALC          48 /* No Calc./For Calc. toggle */
#define G_INSIDE        42 /* Inside/Outside toggle */


/* Gadget for geometric information */
#define GROUP_GEOM      78 /* Group:  55, 56, 59, 58, 60, 62, 61, 63,65,64 */

#define G_UNIT         55  /* Unit field */

#define G_COG_X        56
#define G_COG_Y        59  /* COG fields */
#define G_COG_Z        58

#define G_EXP_AREA     60    
#define G_TOT_AREA     62  /* Area fields */
#define G_FLOOR_AREA   61

#define G_EXP_VOL      63  
#define G_REAL_VOL     65  /* Volume fields */
#define G_SECT_VOL     64 


/* Gadget for volumes */

#define GROUP_VOLUME   37  /* Group: 16, 111, 25, 26, 83, 84 */

#define G_VOL_LIST       16 /* multi col field (volume, * if compart) */

#define G_INCLUDE_TOG    111 /* include/exclude toggle */
#define G_ADD_VOL        25  /* Add button */
#define G_DEL_VOL        26  /* Delete button */

#define G_COEF_COMP_TXT  81 /* title "Struct. Coef:" */
#define G_PERM_COMP_TXT  82 /* title "Permeability:" */
#define G_COEF_COMP      83 /* coef field */
#define G_PERM_COMP      84 /* permeability field */


#define GROUP_VOLUME_TEXT 114  /* Text (name,type... of gadget) */

/* Separate from group volume for prettier view when disable */

/* Gadget for Display */

#define GROUP_DISPLAY   85

#define G_COMP_COG       98
#define G_COMP_NAME      99
#define G_VOL_COG        102
#define G_VOL_NAME       104 
#define G_DX             108
#define G_DY             109

/* Gadget for text justification */
#define GROUP_JUSTIF     112 

#define G_X_POS_Y_POS     88
#define G_X_POS_Y_C       91 
#define G_X_POS_Y_NEG     94
#define G_X_C_Y_POS       87
#define G_X_C_Y_C         90
#define G_X_C_Y_NEG       93
#define G_X_NEG_Y_POS     86
#define G_X_NEG_Y_C       89
#define G_X_NEG_Y_NEG     92

/* Gadget for database */

#define GROUP_DB          127 /* Group: 124, 125, 126, 118, 116, 117, 115 */

#define G_DB_LIST         115    /* List of attributes */
#define G_SEARCH          124
#define G_RESET           125
#define G_LOAD            126
#define G_MINUS           118  
#define G_NUM_PART        116
#define G_PLUS            117 


/* Gadget for PME Stuff */

#define	GROUP_PME	134

#define	G_PMECOMP_NAME	131
#define G_COMP_DESC	132
#define G_SSCS_NO	133
#define G_DEF2150_ATTR	135
#define G_SEL_PMECOMP	136

#define GROUP_PME_SEL	141

/* Who call the attributes (or volumes) form */

#define EMPTY_STATE 0
#define STAT_LIST   1
#define DYN_LIST    2
#define DB_SELECT   3
#define PME_SELECT  4
#define PME_MODIFY  12

#define INC_LIST    5
#define EXC_LIST    6
#define GEOM_INFO   7
#define DISP_OPT    8

/*
 * State of list of attribut
 */
#define NORMAL_STATE   0
#define ADD_STATE      0x0001
#define DEL_STATE      0x0002 

/* Number of columms corresponding to an attribute of volume */
#define NUM_COL_ATT       3

#define GI_NAME           0
#define GI_TYPE           1
#define GI_VAL            2

/* State of compart in case of a modification */
#define NO_CHANGE       0
#define TO_CHANGE_STATE 0x0001
#define TO_REDISPLAY    0x0010 
#define TO_RECOMPUTE    0x0100 

/* Definition to use with set up of compart */

#define COMP_SET_UP_NAME ":IGENOD:CompSetUp"   /* Where is compart object */
#define SYMB_ATT_STR     "AttDriveSymb"       /* Name of attribute driving symbology */

#define TRACKING_STR     "CompartTracking"
#define SETUP_FILE_NAME  "CompartSetup"
#define SAVESTAT_STR     "SaveStatic"



/* Buffer structure for a volume and his attributes */
struct Comp_Volume
{
  struct GRid id;           /* Id of the volume  */
  struct GRmd_env mod_env;  /* Mod env of the volume */ 
  char name[256];           /* Split name of the volume */
  struct GRid rg;           /* Id of the ACrg coll corresponding to the volume */
  struct ACrg_coll ACrg[SM_VOL_MAX_ATT]; /* Attribut for this volume*/
  IGRshort type[SM_VOL_MAX_ATT]; /* SMAN type of attributes (see SMdef.h) */
  int nb_attr;                  /* Number of attribut for this volume */
};

/* Buffer structure for the display  */
struct Disp_Opt
{
  IGRshort opt;			/* Flag definedc in SMCompDef.h */
  IGRshort dx;                  /* Dx for name */
  IGRshort dy;
};

/*
 * Sturcture for needed attributes of an object
 */
struct init_att{
  char *name;        /* Name of attributes      */
  int   type;        /* Type of this attributes (text or double) */
  char *value;       /* Default value */
}; 

#endif

