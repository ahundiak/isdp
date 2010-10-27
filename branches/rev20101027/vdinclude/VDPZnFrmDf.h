/* I/VDS
 *
 * File:        vdpinclude/VDPZnFrmDf.h
 *
 * Description:  Default data selection form
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/22/95            MSM             Creation
 */


#ifndef VDPZnFrmDf_include
#define VDPZnFrmDf_include

#define VD_FP0		me^^CEO.forms[0].form_ptr
#define	VD_FP1		me^^CEO.forms[1].form_ptr

/* State of the form */

#define		S_DEFINE		1
#define		S_MODIFY		2

/* Gadget Definitions for Zone forms */


/* Main Zone form */

#define		G_MAIN_GROUP		19

#define		G_MCF			12
#define 	G_DEFINE_BTN		13
#define 	G_DISPLAY_BTN		14
#define		G_VALIDATE_BTN		15
#define		G_RELNSHIP_BTN		20
#define		G_MODIFY_BTN		21
#define		G_DELETE_BTN		22

/* Sub-zone form */

#define		G_ZONE_GEOMETRY		13
#define		G_ZONE_SUBTYPE		14
#define		G_ZONE_NAME		15
#define		G_DESCRIPTION		23

#endif

