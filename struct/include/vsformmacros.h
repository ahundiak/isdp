/*
	I/STRUCT
*/
#ifndef vsformmacros_include
#	define vsformmacros_include

extern int	FIg_enable(),
		FIg_disable(),
		FIg_display(),
		FIg_erase(),
		FIg_delete() ;

/*+M
Macro vs$g_enable_gadgets

Abstract
	Enables a list of gadgets.
Arguments
	IN	char	*form		Form pointer.
	IN		list		List of gadget labels, separated by
					commas and surrounded by "`".
-M*/
#omdef vs$g_enable_gadgets( form, list )
	VSg_op_on_gadgets( (form), FIg_enable, list, -1 )
#endomdef

/*+M
Macro vs$g_disable_gadgets

Abstract
	Disables a list of gadgets.
Arguments
	IN	char	*form		Form pointer.
	IN		list		List of gadget labels, separated by
					commas and surrounded by "`".
-M*/
#omdef vs$g_disable_gadgets( form, list )
	VSg_op_on_gadgets( (form), FIg_disable, list, -1 )
#endomdef

/*+M
Macro vs$g_display_gadgets

Abstract
	Displays a list of gadgets.
Arguments
	IN	char	*form		Form pointer.
	IN		list		List of gadget labels, separated by
					commas and surrounded by "`".
-M*/
#omdef vs$g_display_gadgets( form, list )
	VSg_op_on_gadgets( (form), FIg_display, list, -1 )
#endomdef

/*+M
Macro vs$g_erase_gadgets

Abstract
	Erases a list of gadgets.
Arguments
	IN	char	*form		Form pointer.
	IN		list		List of gadget labels, separated by
					commas and surrounded by "`".
-M*/
#omdef vs$g_erase_gadgets( form, list )
	VSg_op_on_gadgets( (form), FIg_erase, list, -1 )
#endomdef

/*+M
Macro vs$g_delete_gadgets

Abstract
	Deletes a list of gadgets.
Arguments
	IN	char	*form		Form pointer.
	IN		list		List of gadget labels, separated by
					commas and surrounded by "`".
-M*/
#omdef vs$g_delete_gadgets( form, list )
	VSg_op_on_gadgets( (form), FIg_delete, list, -1 )
#endomdef

/*+M
Macro vs$draw_section_on_form

Abstract
	Draws a representation of a cross-section on the gadget of a form.
Arguments
	OUT	long		*msg		Completion code.
	IN	char		*form		Form pointer.
	IN	int		gadget		Gadget label.
	IN	VSdspRep	representation	Display representation.
	IN	int		weight		Weight of drawn curve.
	IN	struct GRmd_env	*mod_env	Module environement of section.
	IN	struct GRid	*sectDef	Section definition.
-M*/
#omdef vs$draw_section_on_form(	msg,
				form,
				gadget,
				representation,
				weight = 0,
				mod_env,
				sectDef )

	VSdrawSectionOnForm(	(msg),
				(form),
				(gadget),
				(representation),
				(weight),
				(mod_env),
				(sectDef) )
#endomdef

/*+M
Macro vs$draw_curve_on_form

Abstract
	Draws a curve on the gadget of a form. The curve must be in a plane
	z = constant of the world co-ordinate system.
Arguments
	OUT	long		*msg		Completion code.
	IN	char		*form		Form pointer.
	IN	int		gadget		Gadget label.
	IN	int		weight		Weight of drawn curve.
	IN	IGRpoint	refPoint	Reference point.
	IN	struct GRmd_env	*curveEnv	Module environment of curve.
	IN	struct GRid	*curveId	Id of curve.
	IN	struct GRid	*scaleCvId	Id of scaling curve (optional)
Note
	Maps curve from its position to a rectangular area such that :
	- curve is contained within rectangle (ie. curve is possibly resized to
	fit into the rectangle).
	- the world point `refPoint' coincides with the rectangle point
	`rectPoint' (a point within the rectangle).
	- the curve undergoes a symmetry around the x- and/or y-axis if
	requested.
	If a scaling curve is specified, it will be used to compute the fitting
	of the input curve in the form's area. If not the curve to be drawn
	will be used. This is done in order to be able to draw a composite
	curve on a form and then draw one of its components with a bigger
	weight: to draw the component, the composite curve is used as a scaling
	curve.
-M*/
#omdef vs$draw_curve_on_form(	msg,
				form,
				gadget,
				weight		= 0,
				refPoint,
				curveEnv,
				curveId,
				scaleCvId	= NULL )

	VSdrawCvOnForm(	(msg),
			(form),
			(gadget),
			(weight),
			(refPoint),
			(curveEnv),
			(curveId),
			(scaleCvId) )

#endomdef

/*+M
Macro vs$repaint_gadget

Abstract
	Repaints a form's gadget.
Arguments
	IN	char	*form
	IN	int	gadget
-M*/
#omdef vs$repaint_gadget( form, gadget )
	VSf_repaint_gadget( (form), (gadget) )
#endomdef

#endif
