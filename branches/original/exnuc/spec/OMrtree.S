								/*+public*/
class specification OMrtree (2:0) of OMindex;            	/*+cldesc*/

#include "exsysdep.h"
#include <stdio.h>
#include "OMDB.h"


%undef remove


/*     							
Description:
	    This class defines the rtree indexing messages
	
*/								/*-cldesc*/

								/*+clrev*/
/*
Revision History:
	    
*/
								/*-clrev*/

instance OMrtree						/*+clid*/
{


int        count; /* The total number of keys in the tree */
OM_S_OBJID objid; 
char	   tree_page[DB_BYTES_RPAGE];

};								/*-clid*/


							     	/*+clover*/
override add, remove, pass, translate, neighbor, delete;     	/*-clover*/

message OMrtree_constr(unsigned char tree_type; int *ret);    	/*+clmsgs*/

message find_and_remove( OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int (*user_compare)(); int *ret );

message skew_pass( OM_p_MESSAGE msg; OM_p_SKEW_DESC p_key; OM_p_KEY_DESC p_target_key; OM_p_CLASSLIST classlist; int (*user_compare)(); int *ret );

message replace(OM_p_KEY_DESC p_key; OM_p_OBJID p_objid; int dim; OM_S_KEY_DESC new_keys[]; OM_S_OBJID new_objids[]; int *ret);

message get_stat( OM_p_RTREESTAT p_stat; int *ret );
 
message seed(OM_S_KEY_DESC keys[]; int count; int *ret);

message control(char *p_flag; char *p_prev_flag);

message find_key(OM_p_KEY_DESC p_select_key; OM_p_OBJID p_objid; OM_p_KEY_DESC p_target_key; int (*user_compare)(); int *ret );
							     	/*-clmsgs*/


end specification OMrtree;				     	/*-public*/
