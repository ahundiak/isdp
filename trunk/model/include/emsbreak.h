/*
 * 05/14/87 : rlw : Removed enumerated type declaration from this file.
 */

# ifndef emsbreak_include
# define emsbreak_include 1

/*
 * This block move is defined in order to avoid the painful process
 * of opp'ing files
 */
#define EM_BLOCK_MOVE(S,D,N) blkmv(N,S,D)
/*
 * Define the maximum number of breaks that are possible
 */
#define MAXIMUM_BREAKS 4                /* Three is actually needed */
/*
 * Break information to maintain compatibility between sets of data
 */
enum EMbreak_type
 {
  EMno_break,           /* don't break */
  EMforward_break,      /* break forward (normal case) */
  EMbackwards_break     /* break backwards (needed for overlap) */
 };
/*
 * Break information to maintain compatibility between sets of data
 */
struct EMsegment_breaker
 {
  IGRlong       group_number;           /* group to modify */
  IGRlong       segment_number;         /* segment to modify */
  BSpair        uv1_coordinate;         /* uv space 1 coordinate */
  IGRdouble     line_parameter;         /* parameter value on segment */
  IGRlong       times_to_insert;        /* # times to insert [0,1,2] */
  enum          EMbreak_type break_it;  /* how to break after insertion */
};

# endif
