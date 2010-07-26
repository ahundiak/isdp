/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	This is the class specification for the abstract class 
	GRbspline which is a subclass of GRcurve. This class 
	encompasses all of the standard non-complex curve-based 
	graphic objects supported within the nucleus system.
Notes
	None

History
	RDH     03/25/86 : Design date.
	MAS	09/03/87 : Altered for 1.0 release
        Jack    02/01/92 : Added declaration of GRlineproj.
*/

class specification GRbspline (1:1) of GRcurve;
override
        GRdetplane,GRgetsize,GRgetgeom,GRendpts;
#ifndef BASE_EMS

override GRdisyourself, GRxform, GRptproject, 
	GRlnproject, GRmidpoint, GRkeypoint, GRptextend, 
	GRdisextend,  GRptseqspace, GRptalong,  
	GRarclength,  GRmodify, GRgetrang, 
	GRgetattr, GR2ptpartdel, GR3ptpartdel, GRsplit, GRconstruct, 
	GRprismrel, GRclip, GRarea, GRtotlength,GRcentcurv,
	GRstretch, GRcpparallel, EMcvtanorm, EMcvoffset, 
	EMpartofcv, EMcvradcrv, EMcrvcrvint, GRrevparm, EMcrvslfint, 
	EMpratpt,EMptatpr;

override GRadd_to_display_list;

/* #ifndef IDRAW ( No longer needed: 6 Aug 90 -- Madhu) */

override GRfragment, GRinplane, EMintplane, EMgetpoles;

/* #endif  IDRAW */


/* 
Motivation

The motivation for overriding all of these methods is because the
parent class declaration for the method was a method declaration
only (MDO) and returns an error.  The method is implemented at this
class.

*/ 


message EMbctobz ( struct GRvg_construct *construct_list;
	GRobjid **bz_objid; IGRint *nbezier; IGRlong *msg );

message EMgetbcdef (IGRlong *msg; struct IGRbsp_curve *crv);

message GRlinesegproj(
  IGRlong       *msg;                   /* Error return code */
  IGRshort      *matrix_type;           /* My matrix type */
  IGRmatrix     matrix;                 /* My module matrix */
  struct        IGRline_seg *line_seg;  /* The line segment */
  IGRpoint      lineseg_pt;             /* Point on the line segment */
  IGRpoint      curve_pt;               /* Point on the curve */
  IGRdouble     *t;                     /* Line segment parameter */
  struct        GRparms *proj_parms);   /* The projected parms */

    
#endif
end specification GRbspline;
    
