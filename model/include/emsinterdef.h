#ifndef emsinterdef_include
#define emsinterdef_include 1

/*
 * Options masks for requesting special characteristics in interesction
 * methods/functions. All of these masks may not be applicable to particular
 * methods/functions.
 *
 * ??		??		Creation.
 * SM		12-Sep-89	Added EMS_INTER_NOISO
 */

#define EMS_INTER_BDRYISAREA	0x01   /* The boundary is to be treated as
                                          area. If not set, to be treated as
                                          hole. Good only with trim methods
					  that compute cutting intersections */
#define EMS_INTER_CUTTING	0x02   /* The interesection is computed only
				          if there is a toggle between
                                          hole and area. If not set, a
					  normal intersection is computed.
					  Good only where this choice is 
                                          allowed. */
#define EMS_INTER_STARTPT	0x04   /* Return an intersection on the start
                                          point regardless of "cutting
                                          intersection" option */
#define EMS_INTER_STOPPT	0x08   /* Return an intersection on the stop
                                          point regardless of "cutting
                                          intersection" option */
#define EMS_INTER_REMZEROEND    0x10   /* Ignore intersections at the
                                          extremities (endpoints) when
                                          the element, at these locations,
                                          traverses immediately into or out
                                          of a hole region. This might
                                          override the above two options when
                                          such a condition occurs */
#define EMS_INTER_MOREPRECISE	0x20   /* Intersection computation with
					  greater precision. Speed is not
                                          critical */

#define EMS_INTER_NO_MOREPRECISE 0x40  /* Do not attempt intersection 
					  computation with greater precision
					  even if the need to do so is
					  diagnosed */
#define EMS_INTER_CLOSEOVERRIDE 0x80   /* This option indicates that even
					  if the geometry is closed ignore
					  this fact. Used first in
					  EMSedge.EMtrimyourself */
#define EMS_INTER_MATCHEDINTDAT 0x100  /* This option indicates that even
					  geometry-pair of the intersection is
					  (or should be) matched. Used first in
					  EMSloopset.EMlsfulltrim */
#define EMS_INTER_PROCOVERLAP   0x200  /* Process the intersection with special
                                          attention for overlapping 
                                          conditions. The effect of this option
                                          is described in the documentation for
                                          the intersection function/method. */
#define EMS_INTER_MINPOINTS	0x400  /* If the processing has an option to
                                          generate more or less points as in
                                          coincident points, generate less
                                          points. Used in EMlsfulltrim.I */
#define EMS_INTER_NOISO		0x800  /* If it comes down to
					  determining isoness of an 
					  intersection callers judgment
					  is overriding */
#define EMS_INTER_HANDLESTOP   0x1000  /* If set the STOP-interrupt is handled
                                          in that the processing is halted */
#define EMS_INTER_ONEOFTWO     0x2000  /* If set, out of a pair of duplicate
                                          intersections one of them is
                                          retained. Used in
                                          EMint_afterprocess() */
#define EMS_INTER_BSPCURVES    0x4000  /* The output may be in the form of
                                          B-spline curves */
#define EMS_INTER_USECHTTOL    0x8000  /* When a basis-tol is present, convert
                                          it to a cht-tol and use it */
					
/*
 * Options mask for the curve-curve intersection
 * method - EMcrvcrvint, declared at GRcurve.
 */

#define EMS_CVINT_NOENDCOINC	0x01	/* If set, those intersections that
				           occur at the end-points are not
					   to be considered */
#define EMS_CVINT_ZEROZDEPTH	0x02	/* If set, the curves are first
					   flattened to Z=0 plane (zeroing
					   out the Z-values in the poles)
					   before interscetion is performed
					   but the model-space output
					   will be evaluated on one of the
					   curves */

#endif
