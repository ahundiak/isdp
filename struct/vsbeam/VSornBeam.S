/*
	I/STRUCT
*/
class specification VSornBeam(0:0) of VSmodBeam ;

#include "OMmacros.h"
#include "emsbool.h"
#include "vs.h"
#include "vsbeamdef.h"
#include "vsbeam.h"

/*+c
	Class of a re-oriented beam, that is the result of a beam which from
	now on will pretend to have the reverse orientation of the orientation
	it had before.
-c*/

override

/*+o
Message NDdelete

Abstract
	Sends message VSdelete of class VSfeature to self.
Arguments
	See message NDdelete of class NDnode.
-o*/
	NDdelete,

/*+o
Message ACconstruct_feet

Abstract
	A re-orientated beam has one parent : a beam (subclass of VSbeam).
	which is going to be consumed.
Arguments
	See message ACconstruct_feet of class ACncpx.
-o*/
	ACconstruct_feet,

/*+o
Message ACreturn_foot

Abstract
	Takes into account the fact that it has a reversed orientation with
	respect to its parent beam's, ie. returns the symmetric output of the
	one being asked for.
Arguments
	See message ACreturn_foot of class NDmacro.
-o*/
	ACreturn_foot,

/*+o
Message ACgive_path

Abstract
	Takes into account the fact that it has a reversed orientation with
	respect to its parent beam's, ie. returns the symmetrized name of
	the input output.
Arguments
	See message ACgive_path of class ACcpx.
-o*/
	ACgive_path,
	VSgetObjDef,

/*+o
Message VSgetSegmentEnds

Abstract
	Returns end points in the opposite order of the order in which
	consumed parent beam would have returned them.
Arguments
	See message VSgetSegmentEnds of class VSbeam.
-o*/
	VSgetSegmentEnds,

/*+o
Message VSgetOrientation

Abstract
	Returns an orientation which is the reverse of parent's.
Arguments
	See message VSgetOrientation of class VSpart.
-o*/
	VSgetOrientation,

/*+o
Message VShasOrientation

Abstract
	A re-oriented beam can figure out its orientation.
Arguments
	See message VSgetOrientation of class VSpart.
-o*/
	VShasOrientation ;

/*+d
Message VSsymmetrizeName

Abstract
	Finds symmetric name of output of a given name of output according
	to symmetries object represents.
Arguments
	OUT	long		*msg		Completion code.
	IN	GRname		nameOfOutput	Name of output.
	OUT	GRname		symmName	Name of symmetric output.

-d*/
message VSsymmetrizeName(	long		*msg ;
				GRname		NameOfOutput,
						symmName ) ;

end specification VSornBeam ;
