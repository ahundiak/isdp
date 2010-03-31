/*
  DESCRIPTION

    This file contains the property bits stored in associative entities.
*/

#ifndef EMSasprops_include_
#define EMSasprops_include_

/*
 * These are the properties stored in an EMScnstr object
 */

#define EMScnstr_horizontal		0x0001
#define EMScnstr_clockwise_angle	0x0002
#define EMScnstr_self_constraint	0x0004
#define EMScnstr_negative_axis		0x0008
#define EMScnstr_convert_units		0x0010
#define EMScnstr_direction_validated    0x0020
#define EMScnstr_half_value		0x0040
#define EMScnstr_orig_start             0x0080
#define EMScnstr_meas_start             0x0100

#endif
