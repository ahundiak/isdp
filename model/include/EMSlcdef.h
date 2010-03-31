# ifndef EMSlcdef_include
# define EMSlcdef_include

# define HIT        1
# define MISS       -1

# define OUTSIDE         0
# define INSIDE          1
# define OVERLAP         2
# define BAD_RELATION   -1

# define CURVE_PRISM_SUPPORTED 1

# define RETRIEVE_PRISM_TYPE   0
# define SET_PRISM_TYPE        1

# define EMSlocateRigidComponent(cvl) \
  ((cvl->attributes.obj_attr.owner_action & LC_RIGID_COMP) AND \
   (! (cvl->attributes.type IS GR_rp_loc) OR \
      (cvl->attributes.type IS GR_cv_loc)))

/*
 * Options to call the EMS-defined locate messages and functions.
 * eg: message EMSboundary.EMbdrylocate, function EMhitcvbuff
 * A subset of these options might apply to a given message or
 * function. See it's documentation.
 */

#define EMSlcopt_hitormiss	0x01   /* The locate stops the moment
					  a hit is encountered */
#define EMSlcopt_xyzelem	0x02   /* Process to locate the model-space
					  counterpart of a boundary element */
#define EMSlcopt_uvelem	        0x04   /* Process to locate the parametric
					  space elements */
#define EMSlcopt_rangechk	0x10   /* Perform a range check to trivially
                                          reject the element as a candidate */
#define EMSlcopt_noassoc	0x20   /* Process to return object without
					  concern for associativity */
#define EMSlcopt_nonatedge	0x40   /* Omit natural edges from the
					  processing */
#define EMSlcopt_nodgnedge	0x40   /* Omit degenerate edges from the
					  processing */
#define EMSlcopt_existingmsc	0x80   /* Process only the existing model-space
					  counterpart */
#define EMSlcopt_touchmsc      0x100   /* On processing the model-space
					  counterpart, update it to be the
					  most recently used. */
#define EMSlcopt_skipgeomchk   0x200   /* Do not conduct a geometric check
                                          in the current context */
#define EMSlcopt_nocommon      0x400   /* Do not process the common edge
                                          in this context */
#define EMSlcopt_debug         0x800   /* With this option on, debug "print"
					  statements are output on stderr */

/*
 * The property bits used to communicate to the outside world
 * some TRUE/FALSE information learnt during the locate processing.
 * eg: used in the properties field of the EMSlcoutput structure.
 */

#define EMSlcoutput_located	0x01     /* The locate succeeded in finding
					    an element or a hit */
#define EMSlcoutput_inside	0x02     /* The explanation for this bit
					    is to be filled in */
#define EMSlcoutput_outside	0x04     /* The explanation for this bit
					    is to be filled in */
#define EMSlcoutput_overlap     0x08     /* The explanation for this bit
					    is to be filled in */
# endif
