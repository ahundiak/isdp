/* $Id: VDSpath_form.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDSpath_form.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSpath_form.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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

#ifndef VDSpath_form_include
#define VDSpath_form_include

/**********************************************/
/*
/* 	Definition of the gadget labels
/* 	of the form "path" called by the
/*	command object VDSpath.sl
/*
/**********************************************/



#define	SAVE		1
#define	STORE		2
#define	ABORT		3
#define	EXIT		4
#define	MESSAGE_FIELD	10


/* form Directory Path gadget label */


#define	ACT_DIR			30
#define	REFERENCE		31

#define MAIN_BUTTON		12
#define SEARCH_BUTTON		13
#define SET_CURRENT		14
#define READ_BUTTON		19
#define WRITE_BUTTON		20

#define MAIN_NAME_FIELD		22
#define MAIN_PATH_FIELD		32
#define SEARCH_NAME_FIELD	23	
#define SEARCH_PATH_FIELD	33

/* form Path List gadget label */

#define LIST_FIELD		14
#define LOAD_BUTTON		15
#define CREATE_TOG		16
#define SELECT_BUTTON		18
#define SYMB_BUTTON		19
#define DEL_BUTTON		20


/* form Symbology gadget label */

#define LAYER_TOG		22
#define LAYER_FIELD		13
#define LAYER_NAME		20
#define COLOR_TOG		24
#define COLOR_FIELD		15
#define WEIGHT_TOG		25
#define WEIGHT_FIELD		18
#define STYLE_TOG		23
#define STYLE_FIELD		19


#endif

