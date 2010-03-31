/*
  DESCRIPTION

    This is an abstract class that is the super class for all explicit
    constraints that have a value associated with them. Vector dimensional
    parameters are most of these. This excludes 2D variational geometry 
    constraints.

  HISTORY

    SS  :  03/14/91  :  Creation
    PP  :  08/10/91  :  Made modifications to support change of inheritance
                        at EMScnstr
    RA  :  09/27/93  :  Putback the inheritance of NDgive_structure from expression.
*/

class specification EMSexpcnstr (2:0) of expression,EMScnstr;

#include "dimdef.h"
#include "dimdload.h"
#include "dimco.h"
#include "dim.h"
#include "EMSdimdef.h"


message EMputval (IGRlong *msg; IGRushort options;
                  IGRdouble val; IGRchar *rhs);

/*

Name
  EMmanage_expression_vla

Abstract

Synopsis
 options : 0x1 : stores the incoming string into the vla.
           0x2 : copies the string stored in the vla into the
                 incoming field.
 size : Size of the string in question.
 strng : Incoming string. If options is 0x2 and this field is NULL then
         only size is returned.

Description
 This message is used to initialise the expression vla instance data.
 It stores the string that is coming in, into the expression vla.

Return Value
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is failure
 MSINARG : If invalid arguments

Notes

Index

Keywords

History
 Creation : PP :07/30/91
 Inherited more messages from expression. DLB 6/5/92

 */

message EMmanage_expression_vla(IGRlong *msg; 
                              unsigned int options;
                              IGRint *size;
                              IGRchar *strng);

from expression inherit
	NDmake_source,
	NDset_value,
	NDgive_value,
	NDcompute_node, /* standard node message */
	NDprint, 	/* graph printer message */
	NDplace, 	/* ci message:  place(name, syntax) */
	NDprint_root, 	/* graph printer message */
	NDgive_structure, /* return the structure of the object		  */
	NDmove_to_root,	/* to make a constant of myself */ 
	NDcopy_to_root,	/* to copy to a root one	*/
	ACget_context,  /* text does not try to transfer symbology */
	ASreturn_go;  

override
  GRcopy,
/*
 * Override NDmake_source to either create a pretendin if there
 * is a context/return itself.
 */
  NDmake_source,
/*
 * Perform a graph copy.
 */
  NDcopy_graph,
/*
 * Make the connections as if any other non-expression
 * object did not exist as a parent
 */
  NDconnect,
/*
 * Do not disconnect non-expression object while
 * making orphan
 */
  make_orphan,
/*
 * Upon modification of expression to have an expression parent
 * change the style of the dimension (vice versa too)
 */
  modify,
/*
 * inform to children about deletion of myself      - GMK 11/24/93
 */
 GRdelete,
 NDparent_deleted;

end specification EMSexpcnstr;
