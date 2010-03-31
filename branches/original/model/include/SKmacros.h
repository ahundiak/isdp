/*

Name
  SKmacros.h

Description
  OM style macros definitions for public software interface to the Profile system.

History
  08/26/93 : Rajiv Agrawal : created

 */

#ifndef SKmacros_include
#define SKmacros_include

/*

Name
  sk$convert_to_profile

Abstract
  Convert a wireframe element into a profile.
  
Synopsis
  long 		  *msg		   o    Return code
  IGRushort   	  options          i	options (see SKdef.h)
  struct GRid 	  geometry	   i 	wireframe element to be converted
  struct GRmd_env *module 	   i    module
  GRobjid 	  *profile 	   o    output profile
  int		  automask         i    auto-constraint mask (defined in comisc.h).    

Description

Return Value
  SK_CONVERT_OK - if everything goes well.
  SK_CONVERT_ELEMENT_NOT_SUPPORTED - some of the composite curve element cannot be converted.
  SK_CONVERT_OUT_MEMORY - ran out of memory
  SK_CONVERT_CYCLE_FOUND - associative cycle detected.
  SK_CONVERT_CURVE_MUST_BE_ON_REF_PLANE - element not on the reference plane
  SK_CONVERT_CURVE_MUST_BE_PLANAR - element is not planar.

Notes
  The options are used as follows:
      SK_CONVERT_NO_AUTO_CONSTRAIN - do not auto-constrain.
      SK_CONVERT_VERBOSE - display error messages.

  Set the automask to SK_AUTO_GEOMETRIC if only geometric constraints are desired.
  By default automask is NULL which means take the global setting from the
  autoconstraint form.

Index

Keywords
  wireframe, profile, convert
  
History
  08/26/93 : Rajiv Agrawal : created

 */

#omdef sk$convert_to_profile( msg, 
                              options = NULL,
                              geometry, 
                              module,
                              profile = NULL,
                              automask = NULL)
  EFconvert_to_profile ( (msg), (options), (geometry), (module) , (profile), (automask))
#endomdef

/*

Name
  sk$create_dimension_constraint

Abstract
  Creates a dimensional constraint (both 2D and 3D).

Synopsis
  long         *msg	o	return code (OUT)
  IGRushort    options  i 	SK_DIMCNSTR_NODISPLAY - no
                                display of any kind will be performed.
  struct GRmd_env *module 	module environment  (IN)
  struct GRid     *dim_grid	GRid of the dimension handle (IN)
  struct GRid     *cnstr_grid 	GRid of the created constraint (OUT)
  IGRushort       *cnstr_type	type of the constraint  (OUT)

Description
  This macro can be used to create a dimensional constraint given a dimension
  handle.
  
Return Value
  EMS_S_Success		- all went well.
  EMS_I_BadElement	- measurement element is not parametric
  EMS_I_BadPlane	- incompatible dimensioning plane
  EMS_I_NotSupported	- dimension constriant not supported
  EMS_I_InvalidCase	- invalid connections found in the graph
  EMS_I_FullyConstrained  - Profile is fully constrained.
  EMS_I_NoSolution	- no solution found.
  EMS_I_Redundant	- conflicting constraints detected.
  EMS_I_NoStackMemory	- insufficient memory
  EMS_I_Cycle 		- cyclic dependency found
  
Notes

Index

Keywords
  dimension, profile, constraint

History
  08/27/93 : Rajiv Agrawal : created

 */

#omdef sk$create_dimension_constraint( msg,
                                       options = NULL,
                                       module,
                                       dim_grid,
                                       cnstr_grid,
                                       cnstr_type = NULL)
  EMcreate_dimension_constraint ((msg), (options), (module), (dim_grid),
                                 (cnstr_grid), (cnstr_type) )

#endomdef
  
#endif

