
class implementation ASconic;
/* #define DEBUG  off */

method GRaxmodify(IGRlong *msg; struct GRmd_env *md_env;
		   IGRpoint axis_pt,end_pt; GRobjid *new_id)
{
 *msg    = MSFAIL;
 *new_id = NULL_OBJID;

 /*| Don't allow to transform a circle to an ellipse */

 return(OM_S_SUCCESS);
}


method GRgetarc(IGRlong *msg; IGRshort *mx_type; IGRmatrix
		 matrix; struct   IGRarc *geom)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


end implementation ASconic;
