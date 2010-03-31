/*
  DESCRIPTION
    
    This file contains any general purpose defined constants for the
    associative system in EMS.
*/

#ifndef EMSasnucdef_h
#define EMSasnucdef_h

/*
 * The following definitions are used while sending a EMget_parent_info
 * message to an associative object to cause the same to unravel the
 * parents depending on the parent type that is passed in. These same types
 * are used to indicate to the default naming function, what prefix to
 * use.
 */

#define EMSpoint 1
#define EMSgrid  2
#define EMSdistance 3
#define EMSscalar 4
#define EMSangle 5
#define EMSlcinfo 6
#define EMSvector 7
#define EMSinfplane 8
#define EMSraddist 9

/*
 * The following bitmask indicate the kinds of parameters expected
 * or obtained in some operation
 */

#define EMSparam_point		0x01
#define EMSparam_vector		0x02
#define EMSparam_plane		0x04
#define EMSparam_virtualpars	(EMSparam_point | EMSparam_vector | \
                                 EMSparam_plane)
#define EMSparam_value		0x08
#define EMSparam_grid		0x10
#define EMSparam_displayable	(EMSparam_virtualpars | EMSparam_grid)

/*
 * Certain constants used in the system
 */

#define DISPAXIS_FACTOR		0.05

/*
 *  Options for EFattack/detach track pt
 */
#define EFtrack_pt_func_NO_STATE_PARENTS 0x1

#endif
