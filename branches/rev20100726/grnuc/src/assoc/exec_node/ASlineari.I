
class implementation ASlinear;


#define AS_DEBUG 1
method GRaddpts(IGRlong *msg; struct GRmd_env *env; 
		 IGRshort *num; IGRdouble *points;
		 IGRshort *option; GRobjid *new_objid)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRmoveseg(IGRlong *msg; struct GRmd_env *env;
		  struct GRparms *seg_locate; IGRpoint from_pt;
		  struct IGRline *boreline)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRsegfind(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		  struct GRparms *ref_parms; IGRpoint point1,point2)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRvtadjseg(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		  struct GRparms *vert_loc; IGRpoint point,vertex; 
		  struct GRparms *seg_id1,*seg_id2)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRgetpolyline(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
        IGRint *action; struct IGRpolyline *polyline)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


end implementation  ASlinear;

