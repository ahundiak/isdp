/*
 This file contains the various flags used to signify the eligibility
 of an edge, during plotting/display etc.

  20_jan-88	SM	Creation.
*/

#define EMSeligible_WholeEdge		0x0001
#define EMSeligible_EdgeBeginPt 	0x0002
#deifne EMSeligible_EdgeEndPt		0x0004

#define EMSeligible_NonNatEdge		0x0008   /* Non natural edge ok*/

#define EMSeligible_NonSubEdge		0x0010   /* non Dom edge only */

#define EMSeligible_EdgeWithVert	0x0020

#define EMSeligible_NonSeamEdge		0x0040  /* For seam edges, only
						   the NON SUBORDINATE is
						   eligible instead of both
						*/
						
#define EMSeligible_ParametricGeom	0x0080  /* The parametric space 
						   geometry of an edge
						   should be used.
						   If this option is not
						   specified, model space
						   geometry of the edge will
						   be used by default.
						*/
						
#define EMSeligible_BSplineGeom	        0x0100  /* This option applies only
						   for parametric space
						   geometry processing.
						   If set, it indicates the
						   use of bspline 
						   representation in parametric
						   space. If not set the
						   polyline representation
						   will be used by
						   default. If the option
						   EMSeligible_ParametricGeom
						   is not set, this option
						   is ignored. 
						*/

#define EMSeligible_NonDegenerateEdge	0x0200  /* Only edges which are not
						   degenerate in model space
						   should be processed. The
						   property bit 
						   EMED_DEGENERATE of the
						   edge is used to make the
						   decision.
						*/
						
#define EMSeligible_NoGradata		0x0400  /* No rule lines. */

#define EMSeligible_NonMscEdge		0x0800  /* Only the edges which do
						   not have a model space
						   counterpart should be
						   processed.
						*/

#define EMSeligible_MscEdge		0x1000  /* Only the edges which do
						   have a model space
						   counterpart should be
						   processed.
						*/
						
#define EMSeligible_UseMsc		0x2000  /* When the model space
						   representation of an edge
						   is required, use mscs
						   if possible. This option
						   implies that, 
						   1)New objects are
						   always created for every
						   edge. No shell objects.
						   2)No messages are send
						   (see struct EMScurveinfo).
						*/
						
