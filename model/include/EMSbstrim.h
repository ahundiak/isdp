# ifndef EMSbstrim_include
# define EMSbstrim_include 1

#ifndef bsdefs_include
#include "bsdefs.h"
#endif

#define LEFT 1
#define RIGHT 2

#define ZERO 0
#define NEGATIVE -1
#define POSITIVE 1

#define EMIS_TANGENT_VALID 0x0001
#define EMIS_NORMAL_VALID 0x0002
#define EMIS_PARAMETER_VALID 0x0004

#define EMS_INT_RIGHT 0x01
#define EMS_INT_LEFT 0x02
#define EMS_INT_BOUNDARY 0x04
#define EMS_INT_UNKNOWN 0x08

struct EMint_info 
 {
  IGRshort	is_valid;
  IGRdouble     parameter;
  IGRvector	tangent;
  IGRvector 	normal;
 };

struct EMplanar_bezier_curve
{
 struct BSmin_max_box minmax;
 struct IGRbsp_curve curve;
 IGRdouble poles[MAX_ORDER * 3];
 IGRdouble weights[MAX_ORDER];
 IGRdouble knots[MAX_ORDER + MAX_ORDER];
};

struct EMthis_spaninfo
{
  IGRint this_spanindex;
  struct IGRbsp_curve *this_geom;
  IGRdouble knot_tol;
};

# endif
