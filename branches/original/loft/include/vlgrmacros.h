/*
		I/LOFT graphical macros.
*/

#ifndef vlgrmacros_include
#define	vlgrmacros_include

#include	"gr.h"
#include	"igrdp.h"
#include	"go.h"

/* ************************************************************************** */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern	IGRlong	VLminRectangle	__((	struct	GRid		*curve,
		     			struct	GRmd_env	*environ,
		     			struct	GRvg_construct	*cst,
		     				IGRint		option,
		     				IGRdouble	ratio,
		     				IGRdouble	margin,
		     				IGRdouble	*length,
		     				IGRdouble	*width,
		     			struct	GRid		*frame,
		     			struct	GRid		*text,
		     				IGRlong		*msg	));

#if defined(__cplusplus)
}
#endif

/*
Macro vl$minrect()

Abstract
	Construct the minimum rectangle of a closed & planar curve.
Arguments
	IN	struct	GRid		*curve	 Closed & planar curve.
	IN	struct	GRmd_env	*environ Environement.
	IN	struct	GRvg_construct	*cst	 Construction list.
	IN		IGRint		option	 Method from <vlgrdef.h>.
	IN		IGRdouble	ratio	 Ratio used.
	IN		IGRdouble	margin	 Margin used.
	OUT		IGRdouble	*length	 Length of minimal rectangle.
	OUT		IGRdouble	*width	 Width of minimal rectangle.
	OUT	struct	GRid		*frame;	 Minimal rectangle frame ID.
	OUT	struct	GRid		*text;	 Minimal rectangle text ID.
	OUT		IGRlong		*msg	 Completion code.
Notes
	- If [cst] is set to null the current construction list is taken.
	- If [frame] is set to null the graphics aren't computed (nor displayed)
	  and the minimal rectangle [length] & [width] are returned.
	- If [text] is set to null the text isn't computed (nor displayed). If
	  [frame] isn't set to null the minimal rectangle is computed and
	  displayed without the text showing [length] & [width] values.
*/
/* ************************************************************************** */
#omdef vl$minrect ( curve,
		    environ,
		    cst		= NULL,
		    option	= B_BESTOF,
		    ratio	= 1.0,
		    margin	= 0.0,
		    length,
		    width,
		    frame	= NULL,
		    text	= NULL,
		    msg )

	VLminRectangle ( curve,
		         environ,
		         (struct GRvg_construct *) cst,
		         (IGRint) option,
		         (IGRdouble) ratio,
		         (IGRdouble) margin,
		         length,
		         width,
		         (struct GRid *) frame,
		         (struct GRid *) text,
		         msg )
#endomdef
/* ************************************************************************** */
#endif
