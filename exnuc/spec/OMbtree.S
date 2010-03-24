class specification OMbtree (2:0) of OMindex;		/*+cldesc*/

#include "OMDB.h"
/* This class contains the Btree indexing messages */	/*-cldesc*/

instance OMbtree					/*+clid*/
{

int	     count; /* The total number of keys in the tree */
OM_S_OBJID   objid;
char         btree_page[DB_BYTES_BPAGE];

};							/*-clid*/

							/*+clover*/
override add, remove, pass, translate, neighbor, delete; /*-clover*/

message OMbtree_constr(unsigned char tree_type; int *ret );  /*+clmsg*/

message seqpass( int count; OM_S_OBJID objid; OM_p_KEYNAME key_array; int *ret );

message btree_contents( int start_key_num; int *num_keys; OM_p_BTREE_CONTENTS keyobj_array; int *ret );

message range_pass( OM_p_MESSAGE msg; OM_p_KEY_DESC p_key_low; OM_p_KEY_DESC p_key_high; char *p_criteria; int (*user_compare)(); int *ret );
							     /*-clmsg*/
message btree_dump( unsigned char tree_type );


end specification OMbtree;
