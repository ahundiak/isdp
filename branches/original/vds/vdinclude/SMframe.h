/* $Id: SMframe.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMframe.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMframe.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/12/02  08:54:12  pinnacle
 * Replaced: vdinclude/SMframe.h for:  by ksundar for vds
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
 *	12/02/97	Sundar		Added the structure nm_sect_info
 *					& gadgets needed for Names Form
 * -------------------------------------------------------------------*/

/* Definition for modify sect frame command */

#ifndef SMframe_include
#define SMframe_include

/* Gagdget for the modified frame section definition */

#define DEPANDANCE_FIELD    13
#define NEWLIST_FIELD       14
#define DEFAULT_FIELD       22


/* The position of the columm in the DEPANDANCE_FIELD */
#define DEP_OLD_N           0
#define DEP_OLD_X           1
#define DEP_DEP             2
#define DEP_NEW_N           3
#define DEP_NEW_X           4

#define NB_DEP_COL          5

/* The position of the columm in the NEWLIST_FIELD */
#define NEWFR_NEW_N           0
#define NEWFR_NEW_X           1

#define NB_NEW_COL            2

/* Some return code */
#define BAD_ELEMENT_LOCATED 507
#define OLD_FRAME_SYSTEM    511
#define NOT_SAME_SECTION    512
#define NEED_NO_CHANGE      513
#define NOT_SAME_SYSTEM     514
#define NO_MORE_FRAME       515
#define MOD_SECT            516
#define NO_DEPANDANCE       517
#define POS_NEG_SECTION     518
#define EGAL_BOTH_FRAME     519

#define NEAR_DIST_STRING    "Near Dist"
#define NO_DEFAULT_SRING    "No Default"


#define NO_FRAME   -9999
#define NO_OFFSET  -9999
#define NO_REINF   -999999
#define NO_SPACING  0

#define NO_REV_DIST -999999

#define NB_MAX_SECTION 100

#define NAME_BY_NUMBER  1
#define NAME_BY_DIST    2

/* These defines are uses with the status field of the struct "frame_obj"
/* specifying the status of each frame.
/* */
#define SAME_FRAME 	0x00000000
#define CRT_FRAME 	0x00000001
#define MOD_FRAME 	0x00000010
#define DEL_FRAME 	0x00000100
#define DISP_FRAME	0x00001000
#define COMP_FRAME	0x00010000
#define NAME_FRAME	0x00100000




/* Definition used by VDPlMdFrm.sl and VDFrm_utili.h   */

#define MAIN 0       /* number of main form */
#define SECTION 1   /* number of section parameter form */
#define NAMES 2   /* number of names form */

/* The command type */
#define PLACE 0
#define MODIFY 1

/* The return of state */
#define NEXT 505
#define COORDINATE 506
#define MY_ERROR 507
#define LOADC 508
#define BDELETE 509
#define ERASE_SECTION 509
#define DISPLAY_SECTION 510
#define OLD_FRAME_SYSTEM 511
#define RELOCATE_FRAME   512

/* Gadgets for the Main Form */


#define SECTION_BUTTON 13
#define LOADC_BUTTON 25
#define CS_BUTTON 19
#define CS_FIELD 60
#define NAME_FIELD 17
#define TOTAL_FIELD 15
#define NB_SECTION_FIELD 20
#define LOWEST_FRAME_FIELD 23
#define HIGHEST_FRAME_FIELD 24
#define X_BUTTON 27
#define Y_BUTTON 28
#define Z_BUTTON 29
#define ORIENTATION_TOGGLE 32
#define REVERSE_TOGGLE  16
#define REVERSE_VALUE_FIELD  40
#define REGULAR_LIST 36
#define REGULAR_VALUE_FIELD 39
#define REINFORCED_LIST 37
#define REINFORCED_VALUE_FIELD 38
#define OFFSET_FIELD 44
#define JUSTIF1_FIELD 46
#define JUSTIF2_FIELD 56
#define N1_BUTTON 50
#define C1_BUTTON 51
#define P1_BUTTON 52
#define N2_BUTTON 54
#define C2_BUTTON 55
#define P2_BUTTON 58
#define ANNOTATION_FIELD 43
#define NAME_TOGGLE      62
#define FRAME_NAMES_BUTTON      63

/* Gadget for the section parameter form */
#define SECTION_FIELD 11
#define DEL_BUTTON    17
#define INSERT_BUTTON 22
#define REINF_FIELD   16
#define REVERSE_FIELD 19
#define MODE_TOGGLE   26
#define UNIT_FIELD    27

/* The number of row for the section field */
#define NB_ROW_SECTION_FIELD 6

/* The column of the section_field */
#define FROM 0
#define TO 1
#define SPACING 2
#define OFFSET 6
#define X1     3
#define X2     4
#define NUMBER 5 

/* Gadgets for the Main Form */

#define DEFAULT_FR_NAME 16
#define FRAME_NO_NAME 15
#define MESSAGE_NAME 17

/* The column of the frame name field  */
#define FR_NO 0
#define FR_NAME 1
#define FR_DISPLAY 2

/* String in regular plane size and reinforced plane size*/
#define EMS_STRING "Ems"   

/* Some (default) Value */

#define MAX_VALUE_FROM_FIELD 300.0
#define MIN_VALUE_FROM_FIELD -300.0

#define NO_VALUE -99999.0
#define NO_DIST   -99998.0
#define NO_NUMBER -9999

#define DEFAULT_SPACING_VALUE 0.0
#define DEFAULT_OFFSET_VALUE 0
#define DEFAULT_REINF_VALUE 0

#define MY_MSG_LEN  80  /* Lenght of the buffer of MSG_FIELD */

#define CLASS_CS    1
#define CLASS_PLANE 2

struct nm_sect_info
 {
  IGRint 		fr;
  IGRint                to; 
  IGRchar		name[12];
  IGRshort		dorn;
 }; 

struct sect_info
 {
  IGRint 		fr;
  IGRint                to; 
  IGRdouble		spacing;
  IGRint		reinf; 
  IGRshort		offset;
 }; 
 
/*The number of cut for reverse string and reinf to be in the ACrg */  
#define NB_CUT_STR 5  

struct main_info
 {
  IGRchar 		axis;
  IGRchar		orient;
  IGRchar		justif[3];
  IGRchar		annot[10];
  IGRdouble		rev_dist;
  IGRdouble		plane_size;
  IGRdouble		reinf_size;
  IGRdouble		offset_dist;
  IGRchar               reinfstr[NB_CUT_STR * ATTR_TXT];  /* String containing expression */
  IGRchar               revstr[NB_CUT_STR * ATTR_TXT];    /* String containing reverse */
  IGRchar               unit[ATTR_TXT];  /* Unit section of frame system    */
  IGRint                name_type; /* Type name of a frame            */
 };

struct frame
 {
  IGRint		number;
  IGRchar		name[16];
  IGRdouble		rel_pos;
  IGRdouble		abs_pos;
  IGRshort		offset_layer;
  IGRint		reinf;
  IGRshort              reverse; 
 };

struct frame_def
 {
  IGRint 		 nb_sect;
  struct main_info 	 main_info;
  struct sect_info	*sect_info;
  IGRint 		 nb_nm_sect;
  struct nm_sect_info	*nm_sect_info;
 };


struct frame_obj
 {
  IGRint	status;
  IGRint	new_frame_number;
  IGRint	old_frame_number;
  IGRchar	frame_name[16];
  struct GRid	frame;
  struct GRid	expression;
 };

struct glob_frame_obj
 {
  struct GRid		cs;
  struct GRid		frame_def;
  struct GRid		frame_info;
  struct frame_obj     *frame_obj;
 };

struct main_param_buffer
{
  	
  char axis ;         /* x,y or z axis */
  int orient_toggle; 
  int reverse_toggle;   /* 1 if positive orientation else 0 */
  double reverse_field;    /* Rev dist if negative orientation */
  char regular_list[20];
  double regular_field;    /* Use only if regular_list != 0 */
  char reinforced_list[20];
  double reinforced_field; /* Use only if reinforced_list != 0 */
  double offset_field;
  char annotation_field[10]; 
  char justification[2]; 
  struct GRid cs;          /* Active coordinate system */
  char name_cs[DI_PATH_MAX];  /* name of the coordinate system */
  char name_fr[DI_PATH_MAX];   /* Name of the frame system */
  int  class_cs;    /* Class of object for cs: CLASS_CS or CLASS_PLANE */
  int name_toggle;   /* If 1 it's NAME_BY_DIST else NAME_BY_NUMBER  */ 
  char unit[ATTR_TXT]; /* Unit of the section */
};

/* A buffer struct when sections are enter with distance */
struct sect_dist
{
  double             Xa;
  double             Xb;
  int	             nb;  /* Nb intervalle between X1 and X2 */
};

/* A buffer for this strings */
struct frame_str
{
  char reinf[NB_CUT_STR * ATTR_TXT];
  char rev[NB_CUT_STR * ATTR_TXT];
};

#endif
