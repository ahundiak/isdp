
/* $Id: VCCmdPJ.h,v 1.1.1.1 2001/01/04 21:12:34 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vcinclude/VCCmdPJ.h
 *
 * Description:
 *
 *      Constants and structures defined for VC Jumper command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmdPJ.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/02/18  18:25:04  pinnacle
 * Replaced: vcinclude/VCCmdPJ.h for: CR 179701619 by aharihar for route
 *
 * Revision 1.1  1999/01/19  09:42:40  pinnacle
 * Created: vcinclude/VCmdPJ.h by aharihar for route
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *    19 Jan 1999  Anand	Constants related to Jumpers
 *    18 Feb 1999  Anand	Constants for View Jumper form in S C C command
 *
 *************************************************************************/

#ifndef	VCCmdPJ_include

#define	VCCmdPJ_include

/*C	forms indexes	*/

#define		VC_X_JUMP_MAX_POSITION	79

/* parameters form is status form */
#define VCC_PJ_CONTROL_FORM             0
#define VCC_PJ_USR_ATTR_FORM            1

/* these are two values which defines the object being referred is Jumper */
#define VC_GEN_JUMPER       0x0100      
#define VC_JUMPER_TYPE      6 	


/* "Set Terminal Connections"  form name and Gadget Numbers in order  */
#define VCPJUMPER_FORMNAME                    "VCPJumper"

#define VCPJ_MSGFLD			      10
#define VCPJ_TERMTAG                          14
#define VCPJ_EQPTAG                           15
#define VCPJ_COMPCODE                         16
#define VCPJ_TERMPOS                          17
#define VCPJ_BOM                              21
#define VCPJ_PLACEJUMP                        24
#define VCPJ_MAXCONN                          25
#define VCPJ_MAXPOS                           29
#define VCPJ_MODJUMP                          31
#define VCPJ_REMJUMP                          35
#define VCPJ_NEWJUMPDES                       37
#define VCPJ_POSUSED                          38
#define VCPJ_CANCELJUMP                       39
#define VCPJ_EXISTJUMP                        40
#define VCPJ_NEWJUMPREM                       44
#define VCPJ_UNSELROWS                        45 
#define VCPJ_OLDJUMPREM                       46
#define VCPJ_OLDJUMPDES                       48
#define VCPJ_TITLE_NEWJUMP                    50
#define VCPJ_TITLE_MODJUMP                    51
#define VCPJ_MODIFY                           52


#define VC_MODCOLNO			       0
#define VC_POSCOLNO			       1


/* Gadget Labels of "Review Terminal Connections"  form */

#define VCVJ_JUMPFLD                          40
#define VCVJ_JUMPDESC                         48
#define VCVJ_JUMPREMK                         46


#endif
