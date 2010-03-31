/*
 This file contains the structure(s) used in plotting of the surface
 by way of plotting all its displayed curves.
*/

#define	emssfcvs_include	1

#include "gr.h"

struct EMScurveinfo
{
  OM_S_MESSAGE		*messg_linestr;		/* message to be applied
						   to each curve of order
						   2 . If no
						   message should be NULL
						*/
  OM_S_MESSAGE		*messg_gencrv;		/* message to be applied
						   to each general curve. If no
						   message should be NULL
						*/

  struct GRvg_construct *construct_list;	/* For the curve(s) */
  struct GRid linestr;				/* Shell id if the same
						   objid is to be
						   reused. If new object
						   is to be constructed
						   for each curve, this
						   must be NULL_OBJID.
						*/
						
  struct GRid gencrv;				/* Same as above */

  IGRlong linestr_counter, gencrv_counter;      /* These counters apply
						   to the shell object
						   and indicate how many
						   times each has been
						   used.
						*/
						
  struct GRid **curves;				/* If a new object is
						   constructed for each curve
						   the ids are returned
						   via this pointer. 
						   A decision to construct
						   a new object is based
						   on whether a shell object
						   is supplied or not.
						*/
						
  IGRlong     *buf_size;			/* Indicates amount of memeory
						   available for curve
						   ids.
						*/
						
  IGRlong     *num_curves;			/* Applies to number of
						   curve ids being
						   returned.
						*/
  IGRdouble   *view_vector;                     /* Added this since I need
                                                   the view vector in the
                                                   EMShorizon impl. of
                                                   EMexecuteCurveFunction and
                                                   I didn't want to add an
                                                   arguement to that method.
                                                   -- Jack 08/30/91
                                                 */  

};


struct EMSwireframe_mscinfo
{
 struct GRmd_env *old_env;
 struct EMScurveinfo *curve_info;
};


#define EMSexecCvF_Edge		0x10
#define EMSexecCvF_FirstEdge	0x20
#define EMSexecCvF_RuleLine	0x40

struct EMSinvoker_info
{
 IGRint	flags;			/* type of function invoker */
 struct GRid obj;		/* GRid of invoker if applicable */
 unsigned char *cvtype;
};

