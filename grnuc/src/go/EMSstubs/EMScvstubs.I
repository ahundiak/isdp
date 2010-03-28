/* #######################    APOGEE COMPILED   ######################## */

class implementation GRcurve;
		
method  EMbuild_stack (
	IGRlong 	*msg;		/* completion code */
	IGRpoint	search_pt;	/* point about which search is
					   to be made */
	struct GRid	original_cc;    /* information of composite curve
					   currently being worked upon */
	IGRdouble	generic_tol;    /* search tolerance */
	IGRdouble	closed_tol;     /* tolerance used to filter closed
					   curves */
	IGRint		*active_levels; /* levels currently active */

	struct GRmd_env *module_info;   /* information about module */
	struct GRlc_stack *stack)	/* stack for storing possible
					   candidates */
{
 return (OM_E_ABORT);

}
end implementation GRcurve;
