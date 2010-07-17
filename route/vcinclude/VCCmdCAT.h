
 /* $Id: VCCmdCAT.h,v 1.1.1.1 2001/01/04 21:12:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcinclude/VCCmdCAT.h
 *
 * Description:
 *
 *  Include file for cabling parameters form
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdCAT.h,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *     Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.5  1997/01/20  20:11:02  pinnacle
 * Replaced: vcinclude/VCCmdCAT.h for:  by hverstee for cabling
 *
 * Revision 1.4  1997/01/03  14:08:50  pinnacle
 * Replaced: vcinclude/VCCmdCAT.h for:  by hverstee for cabling
 *
 * Revision 1.3  1996/10/03  18:04:56  pinnacle
 * Replaced: vcinclude/VCCmdCAT.h for:  by hverstee for cabling
 *
 * Revision 1.2  1996/09/25  21:52:46  pinnacle
 * Replaced: vcinclude/VCCmdCAT.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:41:48  pinnacle
 * Created: vcinclude/VCCmdCAT.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *
 * -------------------------------------------------------------------*/


#ifndef VCCmdCAT_include

#define VCCmdCAT_include

/*    command types         */

#define VCCAT_TYPE_NONE     0
#define VCCAT_TYPE_ADD      1
#define VCCAT_TYPE_EDIT     2
#define VCCAT_TYPE_REV      3

/*    forms names           */

#define VCCAT_PAR_FORM         "VCParGen"
#define VCCAT_PAR_USR          "VCusrpar"

#define VCSA_MAINFORM       0
#define VCSA_SUBFORM        1

#define VCCAT_MFL_USRPAR            12

/*C Cable group  */

#define VCCAT_GROUP_CABLE            30

#define VCCAT_LBL_FROM_EQUIP_NAME    40
#define VCCAT_FROM_EQUIP_NAME        42

#define VCCAT_LBL_TO_EQUIP_NAME      41
#define VCCAT_TO_EQUIP_NAME          43

#define VCCAT_LBL_FROM_CONN_NAME     36
#define VCCAT_FROM_CONN_NAME         38

#define VCCAT_LBL_TO_CONN_NAME       37
#define VCCAT_TO_CONN_NAME           39

/*C Term group  */

#define VCCAT_GROUP_TERM             51
#define VCCAT_TRM_EQUIP_NAME         50

/*C General  */

#define VCCAT_DESC_FIELD             47

#define VCCAT_USR_ATTR_BUTTON        44
#define VCCAT_LOAD_CABLE             46

#define VCCAT_LBL_LINK_NAME          12
#define VCCAT_LINK_NAME              14

#define VCCAT_LBL_COMP_CODE          16
#define VCCAT_COMP_CODE              17

#define VCCAT_LBL_NOTES              32
#define VCCAT_NOTES                  33

#define VCCAT_LBL_UNIT               19
#define VCCAT_UNIT                   18

#define VCCAT_LBL_CONST_STATUS       20
#define VCCAT_CONST_STATUS           21

#define VCCAT_LBL_APPROV_STATUS      22
#define VCCAT_APPROV_STATUS          23

#define VCCAT_LBL_NO_MTO             25
#define VCCAT_NO_MTO                 24

#define VCCAT_LBL_SYMB_SCALE         27
#define VCCAT_SYMBOL_SCALE           26

#define VCCAT_LBL_ZONE               13
#define VCCAT_ZONE                   15

#define VCCAT_LBL_SYSTEM_NAME        28
#define VCCAT_SYSTEM_NAME            29

#define VCCAT_LBL_PARTNUM            54
#define VCCAT_PARTNUM                55

#define VCCAT_LBL_CHGREC             53
#define VCCAT_CHGREC                 52

#define VCCAT_MSG                    10

#endif
