class implementation OMindex;



method add( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret )
{
return(1);
}



method pass( OM_p_MESSAGE msg; OM_p_KEY_DESC p_select_key; OM_p_CLASSLIST classlist; OM_p_KEY_DESC p_target_key; int (*user_compare)(); int *ret )
{
return(1);
}



method translate( OM_p_OBJARRAY p_objarray; OM_p_KEY_DESC p_key; char *p_criteria; int (*user_compare)(); int *ret )
{
return(1);
}



method remove( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret )
{
return(1);
}



method neighbor( OM_p_KEY_DESC p_select_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret )
{
return(1);
}



end implementation OMindex;
