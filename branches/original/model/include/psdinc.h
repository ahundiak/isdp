# ifndef psdinc_include
# define psdinc_include 1

# ifndef EMSbnddef_include
# include "EMSbnddef.h"
# endif

#ifndef bsdefs_include
#include "bsdefs.h"
#endif

#define MAX_NO_OF_FACES 10    /* used in establishing topology during
                                 constructions */
#define NO_OF_EDGES_PER_FACE 4

#define REVERSED EMED_REVERSE_CONNECT
#define SEAM_EDGE (EMED_REVERSE_CONNECT | EMED_SEAM)
#define NOT_REVERSED 0

#define LEFT 1
#define RIGHT 2

#define ZERO 0
#define NEGATIVE -1
#define POSITIVE 1

#define EMIS_TANGENT_VALID 0x0001
#define EMIS_NORMAL_VALID 0x0002
#define EMIS_PARAMETER_VALID 0x0004

#define EMS_GET_POS_ORIENT 0x0001
#define EMS_SET_POS_ORIENT 0x0002
#define EMS_POINT_OUT_OF_SOLID 0x0004

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
 IGRdouble *unweighted_poles;
 struct IGRbsp_curve curve;
};

# endif
