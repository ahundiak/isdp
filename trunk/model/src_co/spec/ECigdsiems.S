/* ###################   APOGEE COMPILED   ################## */
class specification ECigdsiems (1:0) of COcvigdsige;

/*
DESCRIPTION

This class works like COcvigdsige, used as the IGDS to I/Draft
translator, but uses the extensions of I/EMS to translate more
accurately.

INSTANCE DATA

ints:  general-purpose array of ints; only current use is as an
array of flags to see if we can ignore missing rule arcs (which
probably had zero arc length) when reading a particular type 18
or type 19 element.

ids:  sometimes it is necessary to use a pile of ids and this is
a useful place to declare the pile.

NOTE

Variable array ints comes before variable array ids because I do
not expect ints' size to vary as much as ids'.  I suspect it will
usually be four because, to date, spheres are the only objects
which regularly have missing rule arcs, all of which were
supposed to have had arc lengths of zero.  All these spheres were
supposed to have had four rule arcs for each section:  three of
zero arc length and one of non-zero arc length.

HISTORY

22 Sept 89  pp  Added override for cvt_next_ele to provide logging information
                on demand
10 Apr 1989 jBk Added instance data field "ints" for general use.

02 Feb 1989 rlw Modified to add conditional compilation
                statements for the I/DRAW product.

19 Jul 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.

*/

/* EMSrc */
# include "EMStypedef.h"

/* godef.h gr.h igr.h igrdp.h are needed for go.h */
# include "godef.h"
# include "gr.h"
# include "igr.h"
# include "igrdp.h"

/* GRvg_construct */
# include "go.h"
# define DEBUG_MODE 1

instance ECigdsiems
{
    variable int ints[4];
    variable struct GRid ids[20];
};

# ifndef IDRAW
override cvt_type2;
# endif

/*
MOTIVATION

This is necessary to achieve translation of certain unnamed
orphan cells as bounded surfaces instead of cells.  The cells are
supposed to contain only shapes, complex shapes, ellipses and
circles.

NOTES

In truth, this is not exactly what this method implementation
does.  The parent's method flattens nested cells and appears to
be incapable of reading cells with complex shapes and strings. 

Therefore, this is a kluge which, if it is not a nested cell,
tries to test the input cell header, resend the message with
respect to parent, test the resultant cell, and change it into a
bounded surface if it appears to have been an unnamed orphan cell
containing only coplanar, closed curves.

When the igds-to-ige people change their command object,
COcvigdsiems, to do cells properly, then this method will need
change.  There may be other modifications and enhancements
necessary, too.  The easiest, but not necessarily the best,
change to all of this might be to remove the check for nesting
from this implemention.

FILE

ECcvty2.I
*/

override cvt_type1214;
/*
MOTIVATION

Instead of making a graphic group from the elements of the
complex string or shape, I intend to make a composite curve. 
This composite curve will be closed in the case of the complex
shape.

NOTE

If it is not possible to make all the component curves into a
single composite curve, I shall return a graphic group of the
composite curve(s) and remaining simple curves.

FILE

ECcvty1214.I
*/

# ifndef IDRAW
override cvt_type1819;
# endif

/*
MOTIVATION

Because it is part of I/Draft where surfaces and solids are not
known classes, only a stub for this message is offered by the
parent class.  The stub simply makes a graphic group the
component elements of this element.  This implementation actually
translates surfaces (and solids) of revolution and projection,
along with cones, cylinders, tabulated cylinders, and warped and
convoluted surfaces.

FILE

ECcvty1819.I
*/

# ifndef IDRAW
override cvt_type23;
# endif

/*
MOTIVATION

Because it is part of I/Draft where surfaces and solids are not
known classes, the implementation I override does not make a cone
or cylinder at any time.  This implementation translates right
circular cones and cylinders as such.  This implementation also
makes solids where appropriate in all cases.

FILE

ECcvty23.I
*/

message ECcomplexString (
    EMSrc *rc;
    struct GRid *element;
    IGRshort igdsCount;
    IGRboolean oughtClose;
    IGRboolean tryToClose;
    struct GRvg_construct *list
);
/*
DESCRIPTION

This message causes the object to try to change the curves stored
in the graphic group input via the argument, element, to a
complex curve.

ARGUMENTS

rc:  return value of either MSSUCC or MSFAIL.

element:  on input, a graphic group of curves.  On output, a
composite curve or, if unable to complete, a graphic group of as
many composites as were possible and the leftover curves.  If
there was only one curve in the graphic group, only that curve is
output, not a composite curve.

igdsCount:  number of curves IGDS thinks ought to be in the
composite and should be in the graphic group.

oughtClose:  TRUE if the composite curve is supposed to be closed
(e.g., it was a complex shape in IGDS).

tryToClose:  TRUE if the closure of the composite curve is not
known, but it is desirable to try to close the curve if its end
points are within chord height tolerance of one another.

list:  construction parameters list.

FILE

ECcpxStr.I
*/

# ifndef IDRAW
message ECsurfaceOfProjection (
    EMSrc *rc;
    struct GRid universalGroup;
    IGRint count;
    IGRboolean oughtToClose;
    IGRint is_solid;
    IGRint numSections;
    struct GRid firstBoundaryGroup;
    struct GRid boundaryGroup;
    struct GRid ruleArcGroup;
    struct GRid crossSectionGroup;
    struct GRvg_construct *list;
    struct GRid *surface
);
# endif

/*
DESCRIPTION

Construct a surface of projection using the groups of elements
gathered by ECigdsiems.cvt_type1819.

ARGUMENTS

rc:

universalGroup:  A graphic group containing all the read
elements.

count:  The number of elements in firstBoundaryGroup.

oughtToClose:  TRUE if the curve to be created from the
firstBoundaryGroup (and projected to make the surface) ought to
be closed.

numSections:  The number of groups of boundary elements in
boundaryGroup.

firstBoundaryGroup:  A graphic group containing only those
elements in the first boundary.

boundaryGroup:  A graphic group containing the elements from all
other boundaries.

ruleArcGroup:  A graphic group containing the rule lines and
arcs.

crossSectionGroup:  A graphic group containing the cross
sectioning elements.

list:  A list of parameters for construction.

surface:  The completed surface.

NOTE:  If this message is successful, all the groups shall have
been delete.

FILE

ECigdsPjS.I
*/

# ifndef IDRAW
message EC1819rightCircularCone (
    EMSrc *rc;
    struct GRid universalGroup;
    IGRint count;
    IGRint numSections;
    struct GRid firstBoundaryGroup;
    struct GRid boundaryGroup;
    struct GRid ruleArcGroup;
    struct GRid crossSectionGroup;
    struct GRvg_construct *list;
    struct GRid *surface
);
# endif

/*
DESCRIPTION

Construct a right circular cone using the groups of elements
gathered by ECigdsiems.cvt_type1819.

FILE

ECigdsRCCn.I
*/

# ifndef IDRAW
message ECsurfaceOfRevolution (
    EMSrc *rc;
    struct GRid universalGroup;
    IGRint count;
    IGRint is_solid;
    IGRint numSections;
    struct GRid firstBoundaryGroup;
    struct GRid boundaryGroup;
    struct GRid ruleArcGroup;
    struct GRid crossSectionGroup;
    struct GRvg_construct *list;
    struct GRid *surface
);
# endif

/*
DESCRIPTION

Construct a surface of revolution using the groups of elements
gathered by ECigdsiems.cvt_type1819.

FILE

ECigdsRvS.I
*/

# ifndef IDRAW
message ECconvolutedOrWarpedSurface (
    EMSrc *rc;
    struct GRid universalGroup;
    IGRint count;
    IGRint numSections;
    struct GRid firstBoundaryGroup;
    struct GRid boundaryGroup;
    struct GRid ruleArcGroup;
    struct GRid crossSectionGroup;
    struct GRvg_construct *list;
    struct GRid *surface
);
# endif

/*
DESCRIPTION

Construct a convoluted or warped surface using the groups of
elements gathered by ECigdsiems.cvt_type1819.

FILE

ECigdsWarp.I
*/

# ifndef IDRAW
message ECnumSections (
    EMSrc *rc;
    IGRint firstBoundaryGroupCount;
    struct GRid boundaryGroup;
    IGRint *numSections
);
# endif

/*
DESCRIPTION

Determine the number of groups of boundary elements for a type
18 or type 19.

ARGUMENTS

rc:

firstBoundaryGroupCount:  the number of elements in the first
boundary group.

boundaryGroup:  the graphic group containing all but the first
group of boundary elements.

numSections:  pointer to returned number of groups of boundary
elements.

FILE

ECigdsNrBd.I
*/

message ECmoveToErrorLayer (
    EMSrc *rc;
    struct GRid element;
    struct GRid environ
);

/*
DESCRIPTION

Change the layer of the given element to be that of the error
layer (100).

NOTE

Currently, this message also changes the active layer to the
error layer as well as turning off all other layers.

ARGUMENTS

rc:  returned as pointer to MSSUCC or MSFAIL.

element:  element to move to the error layer.

environ:  module in which the element resides.

FILE

ECmvToErLy.I
*/

# ifndef IDRAW
message ECcreate1819 (
    EMSrc *rc;
    OMuword sClassid;
    struct GRid *surface;
    struct GRid *compcv;
    OM_p_MESSAGE creationMessage;
    struct GRmd_env *p_envInfo;
    struct GRid universalGroup;
    struct GRid firstBoundaryGroup;
    struct GRid boundaryGroup;
    struct GRid ruleArcGroup;
    struct GRid crossSectionGroup;
);
# endif

/*
DESCRIPTION

This message takes as input a composite curve or a graphic group
of possibly composite curves and performs constructs a new
element (or group of elements) of the input class using the input
construction message.

ARGUMENTS

rc:  if EMS_E_NoIntersection or EMS_E_Closed on input, it will be
EMS_W_Fail on output.  EMS_E_NoIntersection on input indicates to
the recipient of this message that firstBoundaryGroup does not
represent a single composite curve.  EMS_E_Closed on input
indicates to the recipient that firstBoundaryGroup is a single
composite curve that is probably supposed to be closed, but was
not.

sClassid:  the desired class of surface.

surface:  pointer to the constructed surface or, in the event
firstBoundaryGroup is not a single composite curve, to the
resultant group of surfaces.

compcv:  pointer to the curve used in the construction message. 
Must be distinct from firstBoundaryGroup.

creationMessage:  the message to use for construction.

universalGroup, firstBoundaryGroup, boundaryGroup, ruleArcGroup,
crossSectionGroup:  these are explained sufficiently in above
messages.  However, firstBoundaryGroup might be a composite curve
or a modified version of the read firstBoundaryGroup wherein some
of the curves have been grouped into composite curves.  This is
because the sender of this message is supposed to have tried to
make a single composite curve of the curves it received as input
in firstBoundaryGroup.

NOTES

rc must be the same as that used in creationMessage.

Not only must compcv be distinct from firstBoundaryGroup, but it
must point to the same place to which is pointed by the curve
GRid pointer in the creationMessage.

FILE

ECcrea1819.I
*/

#ifndef IDRAW
 override cvt_next_ele;
#endif

/*
 *To provide logging information on demand. All this does is it checks to
 *see if logging has been turned on and if so prints debug info to stderr
 *and sends the message with respect to parent to itself.
 *
 *FILES
 *ECcnvtnxel.I
 *
 */ 
end specification ECigdsiems;
