class specification OMindex (1:0) of Root;

#include "OMindex.h"

message add( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret );

message remove( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret );

message pass( OM_p_MESSAGE msg; OM_p_KEY_DESC p_select_key; OM_p_CLASSLIST classlist; OM_p_KEY_DESC p_target_key; int (*user_compare)(); int *ret );
message translate( OM_p_OBJARRAY p_objarray; OM_p_KEY_DESC p_key; char *p_criteria; int (*user_compare)(); int *ret );

message neighbor( OM_p_KEY_DESC p_select_key; OM_p_OBJID p_objid; int (* user_compare)(); int *ret );


end specification OMindex;
