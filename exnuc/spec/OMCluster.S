class specification OMCluster (4:0) of Root;

#include 	"OMminimum.h"
#include	"OMcluster.h"
#include	<stdio.h>


%undef remove


instance OMCluster
{

/* active_oid_list is only used when the cluster is being written out */
variable OMuint i_filed_oid_list[];	/*oids belonging to this cluster*/
variable OMuword w_filed_classid_list[];  /* classid's of those oids.. */

/*
/* 'active' means in a currently running system. 'filed' is as it existed
/* in a filed OS at load time and as it will exist at unload time .
*/
OMuint  i_my_file_ptr;		/*where this cluster DESCRIPTOR is on disk */

OMuint  i_fil_num_objects;      /* the number of objects as I existed in a 
				/* file */
OMuint  i_fil_byte_size;	/* size in bytes of the cluster as 
				/* it was filed */

channel {(many_to_one) OMObjSpace;} to_OSO;
OM_S_LCD  lcd;			/* logical cluster descriptor.
				/* defined in OMminimum.h  */
};

override delete, debug;

message fault(int fp);
message adjust_spacemap();
message clwrite(int fp; OM_S_OSHOLE *free_list; OM_p_CSD csd;
	OMuint *bytes_to_file);
message init_OMCluster(OMuword *cluster_num);

message merge(OMuword clusterid);
message move(OMuword clusterid; char *list);
	/* !!! must define structure for list of oids to be moved */

message remove();


end specification OMCluster;
