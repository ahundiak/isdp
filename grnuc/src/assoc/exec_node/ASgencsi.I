
class implementation ASgencs;



method GRinitialize (IGRlong *msg;
                      IGRchar *csname;
                      IGRchar *csdesc;
                      struct GRvg_construct *p_arglist)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method GRget_query_info (IGRlong *msg;
                          IGRchar *cstype;
                          IGRshort *num_inputs;
                          struct GRcsquery_info **query_info)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method GRcvt_to_wld_coords (IGRlong *msg;
                             IGRchar *cstype;
			     IGRint npts;
                             IGRdouble *input_values;
                             IGRdouble *wld_coords)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method GRcvt_to_lcl_coords (IGRlong *msg;
                             IGRchar *cstype;
			     IGRint npts;
                             IGRdouble *input_values;
                             IGRdouble *lcl_coords)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method GRget_oid_from_name (IGRlong *msg;
                             IGRchar *csname;
                             GRobjid *csobjid)
{

IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRgetmatrix (IGRlong *msg; IGRdouble *matrix)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

end implementation ASgencs;
