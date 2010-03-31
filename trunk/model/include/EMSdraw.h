#ifndef EMSdraw_include
#define EMSdraw_include

/*
 * The following indicate types of geometry in the 'draw'
 * command.
 */

#define  EMSD_NULL_GEOM		-1
#define  EMSD_FLOAT_VECTOR	0
#define  EMSD_BOUNDED_LINESEG	1
#define  EMSD_SEMIINFI_LINE	2
#define  EMSD_INFI_LINE		3
#define  EMSD_CIRCLE_ARC	4
#define  EMSD_CIRCLE_CIRCLE	5
#define  EMSD_BOUNDED_CURVE	6

/*
 * Structures used for doing the dynamics and the constraints in the 'draw'
 * command.
 */

struct EMSdynlineseg
{
  IGRpoint firstpt;
};

struct EMSdynperpline
{
  IGRpoint fixedpt;
  IGRvector norvec;
};

struct EMSdyncirarc
{
  IGRpoint center, startpt;
  IGRvector norvec;
};

/*
 * Arc defined by the startpt, starting tangent vector and a plane-normal.
 * The center is computed by intersecting the vector normal to the tangent vector
 * and the perpendicular bisector of the chord defined by the startpt and the 
 * endpt.  Center is used as a return variable for the Place Profile command.
 */
struct EMSdyntanarc
{
  IGRpoint startpt;
  IGRvector tanvec, norvec;
  IGRpoint center;
};

struct EMSdyncircle
{
  IGRpoint circumpt;
  IGRvector norvec;
};

enum EMSdyngeomtype
{
  EMSdynlineseg,
  EMSdynperpline,
  EMSdyncircle,
  EMSdyncirarc,
  EMSdyntanarc
};

union EMSdyngeom
{
  struct EMSdynlineseg lineseg;
  struct EMSdynperpline perpline;
  struct EMSdyncircle circle;
  struct EMSdyncirarc cirarc;
  struct EMSdyntanarc tanarc;
};

struct EMSdyngeomselect
{
  enum EMSdyngeomtype dyngeomtype;
  union EMSdyngeom dyngeom;
};

#endif
