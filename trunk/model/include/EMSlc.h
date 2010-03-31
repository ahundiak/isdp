#ifndef EMSlc_include
#define EMSlc_include 1

/*
 * This structure is intended for the user to communicate special information
 * to the locate process. A first use of this structure is in the message
 * EMSboundary.EMbdrylocate
 */

struct EMSlcinput
  {
  unsigned short options;     /* This field specifies the exact kind of
                                 locate process that must be performed
                                 on the object. See EMSlcdef.h */
  IGRshort depth;	      /* The depth in a tree upto which the locate
                                 processing should go */
  IGRlong prism_rel;	      /* Information about the relative position
                                 of the prism to geometry. Valid only
                                 in the case of a prism locate */
  IGRboolean (*eligfunc)();   /* A pointer to a function that checks
                                 eligibility of a boundary element for locate.
                                 If return value is TRUE, the element is
                                 eligible. The 3 args to this function are:
                                 a) elem_id (GRobjid of the object being
                                    tested. If not an object then NULL_OBJID),
                                 b) GRlc_cvl structure (pointer to),
                                 c) eligfunc_args field from this structure.
                                 If NULL, the default eligibility check func
                                 is used. See file EMeligfunc.C */
  IGRchar *eligfunc_args;     /* This pointer is passed to the 
                                 eligibility checking function. Can be
                                 NULL */
  IGRchar *more_info;         /* This field is to be used to pass user-specific
                                 information around. It is intended to be 
                                 context-sensitive. It should always be
                                 initialized to NULL */
  };


/*
 * This structure is intended for the locate process to communicate with
 * the caller the results of the locate processing.
 */

struct EMSlcoutput
  {
  unsigned short props;       /* Output: Holds some TRUE/FALSE pieces of 
                                 information about the locate process.
                                 See EMSlcdef.h */
  IGRdouble locdist;          /* Output: The qualifying distance (if relevant)
                                 that made the object a candidate for
                                 locate */
  struct GRlc_info locobj;    /* Output: If an object was located, this
                                 contains information about the object */
  };

/*
 * These enumerated types stand for the various kinds of responses
 * from the user that might be have taken place during a locate
 * process. These are different from the I/O responses in that they
 * are logical abstractions of the physical input.
 */

enum EMSuser_responses
  {
  EMSuser_unknown,    /* If the user action does not fall within
			 the following categories */
  EMSuser_accept,     /* During a locate process the user accepted
                         the object pointed at */
  EMSuser_kill,       /* The user reposnse was to kill the 
                         command */
  EMSuser_stack,      /* The user response was to stack this 
                         command */
  EMSuser_moveon,     /* In a variable length input mode, the user has
			 indicated a no-more input */
  EMSuser_backup,     /* Indication of an intention to go back one
			 step in the input process */
  EMSuser_data,	      /* The data asked for has been 
                         input */
  EMSauto_stack	      /* action handler stacked object(s) without invoking
			 select handler */
  };



/*
 * This structure is intended for communication of precise locate information
 * to and from surface locate methods. If a locate-hit was recognized by the
 * display geometry of the surface, this structure contains information about
 * the exact element where the hit was found. An enumerated type helps
 * designate the type of "hit" that took place.
 */

enum EMSsrfloctype
  {
  EMSsrfloc_null,
  EMSsrfloc_polygon,
  EMSsrfloc_ruleline,
  EMSsrfloc_insedge,
  EMSsrfloc_natedge
  };


struct EMSsrflocinfo 
  {
  IGRboolean valid;
  GRobjid srf_obj;
  GRobjid gradata_obj;
  enum EMSsrfloctype loc_type;
  GRobjid edge_obj;
  };

#endif

