/*********************************************************************

Author	:	Manyam

Creation:	October 1 1993

		This file contains the definition for VRLink

*********************************************************************/

#ifndef	vr_VRDfLink_include

#define	vr_VRDfLink_include

#include "dpstruct.h"

/* data points type stored VRLink's instance data */

#define	VR_NO_PARENT			0
#define	VR_PNT_PARENT			1


/*********************************************************************

Author	:	Jaimin Mehta (Huntsville)

Creation:	September 26, 1993


		This file contains the definition of link command
	
Change History :


		  date	 |  name  |	modification's description
		---------+--------+-----------------------------------
		 10/1/93 l Jaimin l Added union structure GenPoint
		 10/5/93 l Jaimin l Added constants for status form
		         l        l                                   

*********************************************************************/

/*A     new indicators for vertex types       */

/*
#define VR_LN_PT_DATA                  0x00000001
#define VR_LN_PT_OBJID                 0x00000002
*/

#define VR_LN_PT_DATA                  EX_DATA
#define VR_LN_PT_OBJID                 EX_OBJID

/*   For conduit/ flex raceway link    */

#define VR_LN_PT_LINE                  0x00000100
#define VR_LN_PT_LBEG                  0x00000300
#define VR_LN_PT_LEND                  0x00000500


/*   change instance when parent conduit changes   */

#define VR_LN_VTX_DEL                  1
#define VR_LN_VTX_ADD                  2


/*C	variable needed to allocate values and names attributes buffers */

#define VR_MAX_CHAR			80

/*C     Composite links, section types   */

#define VRCL_FREE_STRSEC                    1
#define VRCL_FREE_VERTEX                    2

#define VRCL_DISP_STRSEC                    3

#define VRCL_PART_STRPAR                    4
#define VRCL_FULL_STRPAR                    5
#define VRCL_FULL_SPLPAR                    6
#define VRCL_FULL_PNTPAR                    7
#define VRCL_FULL_CONPAR                    8
#define VRCL_FULL_RWYPAR                    9

/*C     Modification types              */

#define VRML_INS_VERTEX                     0
#define VRML_MOV_VERTEX                     1
#define VRML_DEL_VERTEX                     2

/*C     Connect status                  */

#define VRLN_BEGCONNECTED            0x0001
#define VRLN_ENDCONNECTED            0x0002

/*C	events 	*/

#define EMPTY_STACK			500
#define VR_LINK_FREE_POINT		501
#define VR_LINK_ASSOC_POINT		502
#define VR_LINK_CONN_POINT		503
#define VR_LINK_ENDED			504
#define VR_LINK_ROUTING			505	

#define VR_LINK_ANGLE_SNAPPED		506
#define VR_LINK_ANGLE_SKEWED		507
#define VR_LINK_ANGLE_FREE  		508

#define VR_LINK_NO_PATH			509
#define VR_LINK_OBJECT			510
#define VR_LINK_JOIN			511
#define VR_LINK_HAS_NON_LG		512
#define VR_LINK_END_FREE		513
#define VR_LINK_END_ON_LG		514
#define VR_LINK_END_ON_LG_ONPG		515
#define VR_LINK_END_ON_LG_OFFPG		516
#define VR_LINK_END_ON_NON_LG		517
#define VR_LINK_END_ON_EQ		518
#define VR_LINK_ON_CONDUIT              519

/*C	for command object */

#define VR_LINK_INCRBUF			30
#define VR_LINK_DYN			601
#define VR_LINK_DYN2			602
#define VR_LINK_DYN3			603
#define VR_LINK_DYN4			604

#define VR_MLDYN_LINE                   606
#define VR_MLDYN_CONN                   607
#define VR_MLDYN_MVTX                   608
#define VR_MLDYN_DVTX                   609

#define VR_AS_IS                        857

/*C	forms 	*/

/* VR_LINK_FORM is status form */
#define VR_LINK_LINKING_AIDS_FORM	0
#define VR_LINK_LINKING_AIDS_MINI_FORM	1
#define USR_ATTR_FORM			2

/*C	fields for status form VR_LINK_FORM */

#define	USR_ATTR_BUTTON			44
#define	STAT_ATTR_BUTTON		45
#define	LOAD_CABLE			46

#define	LBL_FROM_CONN_NAME	  	36
#define	FROM_CONN_NAME	  		38

#define	LBL_TO_CONN_NAME	  	37
#define	TO_CONN_NAME	  		39

#define	LBL_FROM_EQUIP_NAME	  	40
#define	FROM_EQUIP_NAME	  		42

#define	LBL_TO_EQUIP_NAME	  	41
#define	TO_EQUIP_NAME	  		43

#define	LBL_LINK_NAME			12
#define	LINK_NAME             		14

#define	LBL_COMP_CODE			16
#define	COMP_CODE			17

#define	LBL_NOTES			32
#define	NOTES				33

#define	LBL_UNIT			19
#define UNIT				18

#define	LBL_CONST_STATUS		20
#define	CONST_STATUS			21

#define	LBL_APPROV_STATUS		22
#define	APPROV_STATUS			23

#define	LBL_NO_MTO			25
#define	NO_MTO				24

#define	LBL_SYMB_SCALE			27
#define	SYMBOL_SCALE			26

#define	LBL_ZONE			13
#define	ZONE				15

#define	LBL_SYSTEM_NAME			28
#define	SYSTEM_NAME			29

#define	LBL_SENSITIVITY			30
#define	SENSITIVITY			31

#define	ELEC_CABLE			906
#define	FOPTIC_CABLE 			907 /* not in Nabil's memo */
#define	MSG			        10

/*C	fields 	for VR_LINK_LINKING_AIDS_FORM */

#define	LINK_FREE_POINT			12
#define	LINK_ON_CONN_POINT		14
#define	LINK_ASSOC_POINT		13
#define	LINK_ANGLE_SNAPPED		15 
#define	LINK_ANGLE_SKEWED		16
#define	LINK_SNAP_ANGLE_LIST		20

/*C	fields 	for VR_LINK_LINKING_AIDS_MINI_FORM */

/* #define	MINIAID_LINK_FREE_POINT			12 */
#define	MINIAID_LINK_ASSOC_POINT		13
#define	MINIAID_LINK_ON_CONN_POINT		14
#define	MINIAID_LINK_OBJECT			16
#define	MINIAID_FREE_DIG   			15
#define MINIAID_CONDUIT                         18

#define MINIAID_DP_TEXT                         19
#define MINIAID_DP_TOGGLE                       20

#define	MINIAID_90-ANGLE   			19
#define	MINIAID_45-ANGLE   			20
#define	MINIAID_FREE_ANGLE  			23


/*C	union of different types of point specifications */
struct VRGenPoint {
	IGRshort typ;	/* EX_DATA or EX_OBJID */
	union {
		IGRpoint	xyz; struct GRid	id;
	} point;
};

/*C    extensions for composite links ......   */

struct VRMLPoint {
               IGRpoint        xyz;
                 };

struct VRmlcndyn_info
{
  IGRint                dynamics; /* type of dynamics in state tbl */
  IGRint                numbuff;  /* actual number of buffers      */
  struct DPele_header   dpele_buff[100];
};

struct VRmlmoddyn_info
{
  IGRint                dynamics; /* type of dynamics in state tbl */
  IGRint                dy_index;
  IGRdouble             dy_value;
  struct DPele_header   dpele_buff;
};

#endif
