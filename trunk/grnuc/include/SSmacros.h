#ifndef SSmacros_include
#define SSmacros_include

/*

Name
  SSmacros.h

Description
  OM style macros definitions for public software interface to Smart Sketch.

Notes
  Dependencies: SSdef.h
  First released in version 2.4 of GRNUC development platform / June 1993.
  Aug. 19, 1993 - ALL symbol/file prefixes changed from "SM" to "SS".
  Sep. 22, 1993 - added SSObjects[] list manipulation macros

 */


/*

Name
  ss$enter()

Abstract
  This macro is called to initialize the Smart Sketch environment, but does
  not invoke the Smart Sketch graphics (see ss$activate()).

Synopsis
  No arguments

Description

Return Value
  OM_S_SUCCESS always

Notes
  It is recommended that this macro be called from a command object's wakeup
  and that ss$exit() be called in the command's sleep method.

Index

Keywords
 smart-sketch,keypoints,constraints

History
  06/23/93 : Shelley R. Heard : created

 */

#omdef ss$enter()
  SSEnter()
#endomdef


/*

Name
  ss$exit()

Abstract
  This macro is called to clear the Smart Sketch environment.  As part of
  this process, it invokes ss$deactivate().

Synopsis
  No arguments

Description

Return Value
  OM_S_SUCCESS always

Notes
  It is recommended that this macro be called from a command object's sleep
  method and that ss$enter() be called in the command's wakeup method.

Index

Keywords
 smart-sketch,keypoints,constraints

History
  06/23/93 : Shelley R. Heard : created

 */

#omdef ss$exit()
  SSExit() 
#endomdef

/*

Name
  ss$activate()

Abstract
  This macro invokes Smart Sketch graphics.  It should be called after a
  call to ss$enter() has been made.  In commands, it is recommended that
  it be called immediately before a call to an input filter, such as 
  co$getevent().  
  
Synopsis
  No arguments

Description

Return Value
  OM_S_SUCCESS always

Notes
  The input filter ex$wait_for_input() does not support Smart Sketch 
  interfaces.  

Index

Keywords
 smart-sketch,keypoints,constraints

History
  06/23/93 : Shelley R. Heard : created

 */

#omdef ss$activate()
  SSActivate() 
#endomdef

    
/*

Name
  ss$deactivate()

Abstract
  This macro is called to initialize the Smart Sketch environment, but does
  not invoke the Smart Sketch graphics (see ss$activate()).

  Called when a command no longer is using the Smart Sketch graphics.  This 
  macro is called from within ss$exit().  It may be called directly when you
  wish Smart Sketch to remain initialized but want the graphics turned off. 

Synopsis
  No arguments

Description

Return Value
  OM_S_SUCCESS always

Notes
  It is recommended that this macro be called from a command object's execute
  method after a filter call to turn Smart Sketch graphics off before the 
  next filter call. This is only necessary if the next filter call does not
  want Smart Sketch graphics.

Index

Keywords
 smart-sketch,keypoints,constraints

History
  06/23/93 : Shelley R. Heard : created

 */

#omdef ss$deactivate()
  SSDeactivate()
#endomdef


/*

Name
  ss$set_new_element( type, points, new_flag )

Abstract
  This macro is called when all but the last data points 
  that define a particular geometry type (e.g. line segment,
  arc) have been entered.  Smart Sketch helps the user enter
  the last data point in these cases.

Synopsis

Description
  int type  (IN)       Type of element being constructed (see SSdef.h).  May 
		       be one of the following:

                         SSLINE  - GR3dlineseg
                         SSPOINT - GR3dpoint
                         SSARC   - GR3dcirarc
                         SSNONE  - deactivates the new-element feature after 
				   it is set

                       Note: SSCIRCLE (GR3dcircle) and SSBSCURVE (GRsubbc) are 
		       not currently supported by ss$set_new_element().


  double *points (IN)  Points (contiguous in memory) that have already been 
		       specified for the particular geometry type.  For 
		       example, if type==SSLINE, then one point is specified
		       (the first point of the line).  If type==SSARC, then 
		       two points are required (on the arc's edge).

  int    new_flag      Element type specific flag (mask) for conveying 
		       additional information about the new element; for 
		       example, if the new element type is SSARC, the Flag
		       is used to indicate CW(0)/CCW(1) sweep rotation.

Return Value
  OM_S_SUCCESS always

Notes
  It is recommended that this macro be called from a command object's execute
  method when the necessary inputs are available to satisfy the arguments.
  Another call to this macro with type = SSNONE and points = NULL to 
  deactivate this "mode" of graphics as is warented.

Index

Keywords
 smart-sketch,keypoints,constraints

History
  06/23/93 : Shelley R. Heard : created

 */
#omdef ss$set_new_element( type     = SSNONE, 
			   points   = NULL,
			   new_flag = 0 )
  SSSetNewElement( type, points, new_flag )
#endomdef


/*

Name
  ss$options()

Abstract
  Invokes the Smart Sketch options form.

Synopsis
  int ss$options( int *origin )

Description
  Invokes (creates and displays) the Smart Sketch Options form.  
  If origin is not specified, then the form is displayed in its 
  default position.  Else, origin[0] is the X coordinate and 
  origin[1] is the y coordinates of the form's origin.

Return Value
  MSSUCC - successful
  MSFAIL - could not create the form

Notes
  This form is a save restore form.

Index

Keywords
 smart-sketch,keypoints,constraints

History
  06/23/93 : Shelley R. Heard : created

 */

#omdef ss$options( origin = NULL )
  SSOptions( origin )
#endomdef


/*
Name
  ss$is_active

Abstract
  This function returns 0 if the Smart Sketch is not active and
  retruns 1 if it is.

Synopsis
  int ss$is_active ()

Description
  no arguments

Return Value
  0 - active
  1 - inactive

Notes
  For this routine to return an "active" status (1):
    1) the DPB's Smart Sketch lock flag must be set ON.
    2) The static flag 'active' must be set to 1.

Index

Keywords
  smart-sketch,dynamics,active

History
  09/03/93 : Shelley R. Heard : ss$is_active() added to SSmacros.h

 */

#omdef ss$is_active()
  SSIsActive ()
#endomdef

/*

Name
  ss$add_to_list

Abstract

Synopsis
  ss$add_to_list ( objid,
                   osnum   = 0,  
                   flag    = SS_NEWEST )

  GRobjid      objid     (IN)  object id of element added to the list
  GRspacenum   osnum     (IN)  object space of element (if 0, master assumed)
  int          flag      (IN) instruction flag (see SSdef.h for settings)

Description

Return Value

Notes

Index

Keywords

History
  09/15/93 : Shelley R. Heard : created

 */
#omdef ss$add_to_list ( objid,
			osnum = 0,
                        flag  = SS_NEWEST )

  SSListAddObject( objid, osnum, flag )

#endomdef


/*
Name
  ss$activate_keypt

Abstract

Synopsis

  #omdef ss$activate_keypt( objid,
                            osnum     = 0,
                            action    = SSSET_KEYPT,
                            mask      = 0x00000000 |
                            index     = 0 |
                            approx_pt = NULL )

  GRobjid      objid     (IN)  object id of element with effected keypoints
  GRspacenum   osnum     (IN)  object space of element (if 0, master assumed)
  int          action    (IN)  what to do with specified keypoint(s)
                                 SSSET_KEYPT      - make active
                                 SSUNSET_KEYPT    - deactivate
                                 SSTOGGLE_KEYPT   - toggle
  int          mask      (IN)  element independent keypt mask (see SSdef.h)
  int          index     (IN)  element specific keypoint index (see SSdef.h)
  double      *approx_pt (IN)  approximate location of key point

Description

Return Value
  
Notes
  Public

Index

Keywords

History
  09/15/93 : Shelley R. Heard : created

 */

#omdef ss$activate_keypt( objid,
                          osnum     = 0,
                          action    = SSSET_KEYPT,
                          mask      = 0x00000000 ^
                          index     = 0 ^
                          approx_pt = NULL )

#if (om$specified(mask))
  SSListKeyptActiveMask ( objid, osnum, action, mask )
#endif

#if (om$specified(index))
  SSListKeyptActiveIndex ( objid, osnum, action, index )
#endif

#if (om$specified(approx_pt))
  SSListKeyptActivePt ( objid, osnum, action, approx_pt )
#endif

#endomdef

/*

Name
  ss$remove_from_list

Abstract
  This macros finds the specifiec object (objid) in the SSObjects[] list
  and removes it. The relative order of the remaining members of the list
  is unchanged.

Synopsis
  ss$remove_from_list ( objid, osnum = 0 )

  GRobjid      objid     (IN)  object id of element to be removed from list 
  GRspacenum   osnum     (IN)  object space of element (if 0, master assumed)

Description
  If the object (objid) is in the list (SSObjects[]), it is removed and
  the other list members are shifted to fill the empty slot.

Return Value
  OM_S_SUCCESS always

Notes
  Public

Index

Keywords

History
  09/22/93 : Shelley R. Heard : created

 */
#omdef ss$remove_from_list( objid, osnum = 0 )

  SSListRemoveObject( objid, osnum )

#endomdef


/*

Name
  ss$update_new_element

Abstract
  This macro is used to modify the "new element" info used by the Smart 
  Sketch when a element is being constructed.  This all presumes that the
  "New Element" info has been set ( see ss$set_new_element ).  If an arg is
  not specified of passed as NULL, the coresponding New Element Parameter 
  will not be modified.

Synopsis
  ss$update_new_element ( point1, point2, point3, p_newflag )

  IGRdouble *point1     IN  Overrides first  new point (NULL if not modified)
  IGRdouble *point1     IN  Overrides second new point (NULL if not modified)
  IGRdouble *point1     IN  Overrides third  new point (NULL if not modified)
  int       *p_newflag  IN  Overrides newflag (NULL if not modified)

Description

Return Value
  OM_S_SUCCESS  success  always

Notes

Index

Keywords
  smart-sketch,dynamics

History
  09/25/93 : Shelley R. Heard : created.

 */
#omdef ss$update_new_element ( point1    = NULL, 
			       point2    = NULL, 
			       point3    = NULL, 
			       p_newflag = NULL )

  SSUpdateNewElement ( point1, point2, point3, p_newflag )

#endomdef

#endif
