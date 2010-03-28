# ifndef EMSstruct_include
# define EMSstruct_include 1

struct EMScrv_info_sd
{
  GRobjid		crv_id;
  struct GRparms	loc_pt_prj_parms;
  IGRpoint		loc_pt;
  IGRboolean		phy_closed;
  
  enum { CRV_OK, CRV_DISJNT, CRV_AMBIG, CRV_DISCARD}
  			crv_stat;
  /* for composite curves */
  IGRint		chan_count,	/* channel count for composite curves */
  			loc_objix,	/* channel index number */
  			dup_crvix;	/* duplicate curve index, if any */
  GRobjid		pcrv_id;	/* part of curve (segment) id */
};
 
struct EMSradius
{
    IGRlong     select;         /* 0 if radius value is to be used;
                                   otherwise, radius point is */
    union
    {
        IGRpoint        pnt;    /* radius point */
        IGRdouble       value;  /* radius value */
    } input;
};

/*
 * The following structure is used to pass additional information
 * about continuity to the function(s) that link or trace pieces of
 * "string" data together. The raw, unordered pieces of data is assumed to be 
 * passed in as a one-dimensional array.
 */

struct EMStraceinfo
  {
  IGRboolean degenerate;		/* If TRUE, the element is known to 
					   be degenerate */
  IGRboolean known_fwd_cont;            /* If TRUE, the forward continuity
					   element is known in "fwd_cont" */
  IGRboolean known_bwd_cont;            /* If TRUE, the backward continuity
					   element is known in "bwd_cont" */
  IGRint fwd_cont;			/* If "known_fwd_cont" is TRUE,
                                           contains the index of the
					   forward (next) element */
  IGRint bwd_cont;			/* If "known_bwd_cont" is TRUE,
                                           contains the index of the
					   backward (previous) element */
  IGRboolean known_no_fwd_cont;		/* If TRUE, this element has no
					   forward continuity. Else unknown */
  IGRboolean known_no_bwd_cont;		/* If TRUE, this element has no
					   backward continuity. Else unknown */
  IGRint no_fwd_cont;			/* If "known_no_fwd_cont" is TRUE,
                                           contains the index of the
					   forward (next) element that should
                                           NOT be treated as contiguous. A -1
                                           value indicates nothing should be
                                           made contiguous here */
  IGRint no_bwd_cont;			/* If "known_no_bwd_cont" is TRUE,
                                           contains the index of the
					   backward (previous) element that
                                           should NOT be treated as contiguous.
                                           A -1 value indicates nothing should
                                           be made contiguous here */
  };

/*
 * Structure that defines a graphics object fully. Contains the object-id
 * and object-space number along with it's environment matrix to obtain
 * geometry into the user-space.
 */

struct EMSgrobj
  {
  struct GRid grid;           /* The object-id and the object-space number
                                 of the graphics object */
  IGRboolean envptr;          /* If true the pointer field in the union is
			         used to define the environment, else the
                                 field containing the environment be value */
  union
    {
    struct GRmdenv_info *ptr;
    struct GRmdenv_info val;
    } grenv;                  /* Contains the environment of the graphics
                                 object */
  };

# endif /* EMSstruct_include */
