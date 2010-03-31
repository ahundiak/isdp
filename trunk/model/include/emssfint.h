# ifndef emssfint_include
# define emssfint_include 1

/*
 * This structure is used to output additional information generated
 * during the trimming of surface-intersections against the
 * the surface's boundary elements. This structure is associated with 
 * an end-point of the intersection curve. If this end-point was
 * due to a trim against an edge, then this structure yields information
 * about, which edge caused the trimming, and where on the edge 
 * this trim actually take place. If the end-point is not due to a trim,
 * the edge-id returned will be a NULL_OBJID.
 */

struct EMSsfintedpar
  {
  enum EMScvinttype intloc;     /* The type of intersection */

  GRobjid edgeid;               /* The edge object-id with which this
                                   this point is associated, ie edge */

  struct EMSedgebound edgepar;  /* The parameter value on the edge
                                   at which the intersection took place */

  IGRdouble point[2];           /* The intersection point in the parametric 
                                   space */
  IGRchar *info;                /* A character pointer for the purpose
                                   of the user to maintain any specific
                                   information */
  struct EMSsfintedpar *next;   /* Pointer to the next structure that
                                   contains info about another
                                   intersection (NULL-terminated) */
  };



/*
 * This is a special-purposed structure that is used to temporarily
 * hold intersections that might require some post-processing.
 * Post-processing mainly in the area of removal of coincincident
 * interesections.
 */

struct EMSinthold
  {
  IGRint num_inhold;
  IGRint malloc_at;
  struct EMSpypoint *pypts;
  struct EMSsfintedpar *epars;
  };

/*
 * This structure is used to hold the trace information about
 * an surface intersection list made up EMSinters nodes. Each field in
 * this list corresponds exactly to an argument in the EMSsfinttrace
 * function. See EMsfinttrace.I for details.
 */

struct EMSsftracedata
  {
  IGRint num_grps;
  IGRint *num_subgrps_grp;
  IGRint **num_elems_subgrp;
  struct EMSintobj ***elems;
  IGRboolean **subgrp_rev;
  IGRboolean ***elem_rev;
  IGRboolean *grp_closed;
  IGRboolean **subgrp_closed;
  };


/* The following structure holds the output information from the function
   EMsfintloops(). See EMsfintloops.I for details.
*/
struct EMSsfintloopsdata
  {
   GRobjid **loop_sf;
   GRobjid **endedges;
   struct EMSsfintedpar ***intedpars;
   IGRdouble **sfpartolb;
   IGRboolean sfintloops_alloced;
   IGRint numedsplit;
   unsigned char commed_k_exists;
   unsigned char nocommed_k_exists;
  };

struct EMSerror_help
  {
   IGRlong    msg_key;
   struct     GRobjid_set    bad_ids;
   struct     EMSerror_help  *next;
  };

#endif
