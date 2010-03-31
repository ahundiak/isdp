class implementation ECconstruct;

#include "EMS.h" /* For shared libraries */
/* #include "EMSdpb.h" * For dpb props */
#include <stdio.h>

extern OMuword OPP_ECconstruct_class_id;

method is_associative(IGRint type; IGRlong *associative)
/* ************************************************************************
 
Description
 This method returns whether this command object needs to inherit the
characteristics of an associative command object. The default behaviour
for all command objects which are subclasses from this class is to be
non-associative. If somebody decides to cause an associative element to 
be generated the same should override this message.

*************************************************************************** */
{
 IGRlong sts;
 IGRlong EMmsg;
 IGRboolean state;
 OMuword myclassid;
 extern IGRboolean EMshould_be_associative();

 sts = OM_S_SUCCESS;
 EMmsg = MSSUCC;
 *associative = FALSE;


 gr$get_associative_flag( buffer = &state );

 if (state)
 {
  switch (type)
  {
	case 4: /* Place cone by axis and radii */
  	case 5: /* Place solid right trunc. cone */
	case 6: /* Place cylinder by axis and radius */
	case 7: /* Place solid right circ. cylinder */
	case 8: /* Place torus */	
	case 9: /* Place solid torus */
    case 10:/* Place solid right elliptical cylinder */
    case 11:/* Place solid right elliptical cone */
        case 12: /* Place ellipsoid - foci axis len. */
        case 13: /* Place ellipsoid - ctr. axis rad. */
	case 20: /* Place parallelogram plane by 3 points */
	case 26: /* Place sphere by center and radius */
	case 27: /* Place solid globe */
        case 28: /* Place solid ellipsoid - foci axis len. */
        case 29: /* Place solid ellipsoid - ctr. axis rad. */
	case 35: /* Place plane encompassing planar element */
        case 37: /* Place partial surface */
        case 38: /* Place surface of revolution	*/
        case 39: /* Place solid of revolution */
        case 43: /* Surface by 3 boundaries */
        case 44: /* Surface by 4 boundaries */
	case 45: /* Place offset surface code is moved to 
		    src_testco/imp/ECcsoffseti.I  --sampath */
        case 47: /* Blend 2 surfaces - exterior */
	case 48: /* Place fillet surface */
        case 52: /* Extract iso curves */
        case 76: /* Place solid by capping surface */
        case 83: /* Surface of projection */
        case 84: /* Solid of projection */
        case 85: /* Intersect elements */
	case 109: /* Place solid by offsetting surface */	
        case 116: /* Place fitted curve */
             if ( EMshould_be_associative() )
               *associative = TRUE;
	     else
               *associative = FALSE;
        break;
  }
 }

 return (sts);
}
end implementation ECconstruct;

