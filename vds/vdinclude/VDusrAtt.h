/* $Id: VDusrAtt.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDusrAtt.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDusrAtt.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/07/29  15:59:52  pinnacle
 * CR 179602470: Added "Copy Attributes" capability to "Modify User Attributes" form
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
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	07/28/97	EJM	CR# 179602470: added VD_K_COPY_ATTRS_BTN
 *
 * -------------------------------------------------------------------*/


#ifndef vdusr_att_include
#     define vdusr_att_include


#include "ACrg_collect.h"


/*
 * Gadget labels on root (parent) form.
 */
#define VD_K_ORI_ATTR_FLD       12
#define VD_K_DEL_ATTR_FLD       16
#define VD_K_MOD_ATTR_FLD       17
#define VD_K_NEW_ATTR_FLD       18
#define VD_K_MOD_ATTR_BTN       32
#define VD_K_REV_ATTR_BTN       31
#define VD_K_DEL_ATTR_BTN       19
#define VD_K_UND_ATTR_BTN       20
#define VD_K_ROL_PLUS_BTN       29
#define VD_K_ROL_MNUS_BTN       28
#define VD_K_DEL_LIST_BTN       11
#define VD_K_ROL_THRU_FLD       33
#define VD_K_ROL_THRU_GRP       34

#define VD_K_UATT_NAM_FLD       35
#define VD_K_UATT_TYP_FLD       36
#define VD_K_UATT_VAL_FLD       37
#define VD_K_UATT_GRP           39

#define VD_K_DFLTS_BTN          15
#define VD_K_COPY_ATTRS_BTN     40

/* Index for the 4 multicolumn fields on the form. */

#define ORG        0
#define MOD        1
#define DEL        2
#define NEW        3

/* Structure to store the list of attributes on the form */

struct VDusrAtt
{
     struct ACrg_coll *att[4];
     IGRint           nb[4];
};

#endif
