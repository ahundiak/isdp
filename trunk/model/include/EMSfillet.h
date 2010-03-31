# ifndef EMSfillet_include
# define EMSfillet_include 1

#define EMS_ErrorFillet     101 /* error in placing fillet */
#define EMS_RadiusTooBig    201 /* fillet radius is too big */
#define EMS_OverlapCurves   301 /* fillet curves overlap each other */
#define EMS_Fil_NeutralEdge 401	/* edge located is a neutral edge */

struct fil_crv_info_sd
{
  GRobjid    subcrv_id,     /* sub-curve of a linestring or composite */
             fil_id;        /* constructed fillet id */
  IGRboolean is_segment;    /* segment of linestring ? */
  IGRdouble  radius;        /* fillet radius, = 0 if no fillet */
};

 struct fil_info_sd
 {
  IGRpoint	start_pt, end_pt;   /* curve's start and end points */
  IGRdouble	start_par, end_par; /* fillet parameters on the curves */
 };

# endif  /* EMSfillet_include */
