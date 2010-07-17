/*
	I/STRUCT
*/
class specification VSvirtcmp(0:0) of ASsource ;

#ifndef igrdp_include
#	include "igrdp.h"
#endif
#ifndef godef_include
#	include "godef.h"
#endif
#ifndef go_include
#	include "go.h"
#endif

/*+c
	This class implements headers for virtual components. Virtual
	components are temporary components not linked by channel to their
	owner. They, at the longest, live for the duration of a session. The
	need for virtual components arises from the display representation,
	since we want to allow an I/STRUCT object to pretend that, when in
	a simple representation, it has one particular graphic component
	which in fact only exists in a heavier representation.
	When asked for a component that it does not have, an I/STRUCT object
	generates the corresponding graphics and sticks a header of this
	class on it. This header is able to retrieve the I/STRUCT object
	which gave birth to it. The benefits of this method are :

	1) Being able to work with objects in simple display representation
	2) Generate graphics which ordinarily do not exist in this
	   representation.
	   a) If virtual component is used for a read operation then forgotten,
	      it will by itself disappear during the session.
	   b) If virtual component is used a parent of a new associative
	      construction, its re-indexing mechanism will make the software
	      believe that it really is a component of the I/STRUCT object
	      which generated it. It will also disappear during the session.

	Note : the associative complexes which generate virtual components must
	give them an indexing path which they understand.
-c*/

instance VSvirtcmp {
	struct GRid	virtualOwner ;
	GRname		path ;
} ;

override

/*+o
Message	NDmake_source

Abstract
	Return your virtual owner, instead of yourself.
Arguments
	See message NDmake_source of class NDnode.
-o*/
	NDmake_source ;

/*+d
Message VSputVirtualOwner

Abstract
	Stores id of virtual owner.
Arguments
	IN	long		*msg	Completion code.
	IN	struct GRid	*vo	Id of virtual owner.
	IN	char		*path	Path understood by owner which indexes
					the virtual component.
-d*/
message VSputVirtualOwner( long *msg ; struct GRid *vo ; char *path ) ;

/*+d
Message VSgetVirtualOwner

Abstract
	Returns the id of virtual owner.
Arguments
	IN	long		*msg	Completion code.
	OUT	struct GRid	*p_vo	Id of virtual owner.
	OUT	GRname		path	Path associated with virtual component
					and understood by owner.
Note
	If virtual owner has been deleted, `p_vo->objid' will be NULL_OBJID.
-d*/
message VSgetVirtualOwner( long *msg ; struct GRid *p_vo ; GRname path ) ;

end specification VSvirtcmp ;
