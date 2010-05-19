/* $Id: VDconfirm.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        $VDS/vdmisc/VDconfirm.I
 *
 * Description: This file contains a function which can create a message
 *		box on the screen.  The box displays the important info.
 *		of selected objects, specially, for the bad objects which
 *		mean that the objects can not be evaluated or described.  The
 *		selected objects will be highlighted.  The maximum number
 *		of objects is 200.
 *
 * Revision History:
 *      $Log: VDconfirm.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/01/24  15:40:02  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1997/02/25  19:46:14  pinnacle
# Created: vdmisc/VDconfirm.I by mdong for vds.241
#
 *
 *
 * History:
 * MM/DD/YY  AUTHOR     DESCRIPTION
 * 02/24/97  Ming Dong  creation
 * 01/24/00  ah         Added VDnotify_box for outfit staging tree
 * -------------------------------------------------------------------*/

/*
	VDconfirm_box()
	Arguments:
	char		*title		The title displayed in the box;
        struct GRid	*bad_object	List of selected objects;
	struct GRmd_env *bad_object_env List of object's modules;
	int		n		Number of selected objects;
	
*/

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "exdef.h"
#include "exmacros.h"
#include "execmsg.h"
#include "madef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "igetypedef.h"  
#include "igrtypedef.h"      
#include "gr.h"
#include "growner.h"
#include "v_miscmacros.h"
/*
#define	vdsDEBUG	1
*/
#include "v_dbgmacros.h"


from	GRgraphics	import	GRgetobjinfo;

extern	IGRint	GRconfirm_box();


IGRint VDnotify_box(char *title)
{
  long sts;

  // Display the message box to the screen

  SetProc( VDnotify_box ); Begin

  if ( ! title ) return MSFAIL ;

  ex$message(msgnumb = EX_F_Var1,type = "%s",var = `title`);

// oh well
  End

wrapup:  
  return MSSUCC;
}

IGRint VDconfirm_box(char		*title,
	       	     struct GRid	*bad_object,
		     struct GRmd_env	*bad_object_env,
		     int		n)
{
	long		msg, sts ;
	int		j;	

	struct GRobj_info
			*bad_object_info;
	char		*error_msg,
			*class_name,
			*error_msg_tmp;

	SetProc( VDconfirm_box ); Begin
/*
	Check if it is empty in the bad object list.
*/
		__DBGpr_com(" Call VDnotify_box ");
		__DBGpr_str(" TITLE ", title );

 		if( n <= 0 ) {
  		  sts = GRconfirm_box ("No object selected!\n");
		  End
		  return (sts);
		}

		bad_object_info = _MALLOC (n+1, struct GRobj_info);
		error_msg = _MALLOC (1000, char);
		error_msg_tmp = _MALLOC (1000, char);
		class_name = _MALLOC (20, char);

		sprintf( error_msg, "WARNING!!\n"); 
		strcat( error_msg, title);
		strcat( error_msg, "\n");

		for( j = 0 ; j < n ; j++) {
/*
	Retrieve the information about the bad objects.
*/
		sts = om$send(msg	= message GRgraphics.GRgetobjinfo(
							&msg,
							&bad_object_info[j] ),
				senderid= bad_object[j].objid,
				targetid= bad_object[j].objid,
				targetos= bad_object[j].osnum ) ;
/*	
	Get the classname(s) of bad objects.
*/
		sts = om$get_classname ( osnum = bad_object[j].osnum,
					 objid = bad_object[j].objid,
					 classname = class_name);
/*
	Print out information about objects in the message box.
*/
	  	sprintf( error_msg_tmp, "%d %d %s %s\n", 
				bad_object[j].objid,
				bad_object[j].osnum,
				class_name,
				bad_object_info[j].type);
		strcat( error_msg, error_msg_tmp);
/*
	Highlight the objects.
*/
		vd_$bulk_display(
                                grids   = &bad_object[j],
				theEnv  = &bad_object_env[j],
                                dpmode  = GRhd ) ;
		}

/*
	Display the message box on the screen.
*/
  		sts = GRconfirm_box (error_msg);

		_FREE( bad_object_info );
                _FREE( error_msg );
                _FREE( error_msg_tmp );
                _FREE( class_name );


	End
	return (sts);

}
end implementation Root ;
