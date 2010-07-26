/*
Name
        GRreffile

Description
	The GRreffile class is a subclass of GRvg and stores all information
	necessary for opening and subsequent retrieval of an object space.  It
	also stores the information necessary to define the transformation
	from the master file to the reference file coordinate system.

History
	
	MAS	08/20/86    Creation date.
	MAS	09/08/87    Altered for Release 1.1
        HGB     12/23/91    Support GRgetosnum
        SCW     05/08/92    ANSI conversion
        jwh     08/04/93    Added support for attached/detached.
        Gang    05/27/93    Added support for shrink/wrap.
        mrm     07/21/93    added override for GRisparent
*/

class specification GRreffile (1:1) of GRvg;

#ifndef BASE_EMS
#include "ref.h"
#endif

/* 
 * Instance data defined for the GRreffile subclass:
 */

instance  GRreffile
{
    channel {(many_to_one,initial=1,increment=1)Super_rfmgr.mgr;} to_mgr;
    channel {(one_to_one)GRreffile.to_clone;} to_clone;
    channel {(one_to_one)GRclippoly.to_attachment;} to_clip;
    channel {(one_to_many,rel_ordered,initial=1,increment=1)
		GRcontext;}to_context;
				/* reference file name			*/
    variable char filename[];
				/* object space name			*/
    variable char osname[];
				/* saved view name			*/
    variable char saved_view[];
				/* special reference file properties	*/
    unsigned long ref_properties;
				/* optional description			*/
    variable char description[];
				/* string to define scale factor	*/
    variable char scale_factor[];

    GRrange   range;		/* range for pass in reference space	*/

    /* information from the saved view */
    double    vw_volume [6];	/* view volume of the saved view	*/
    IGRmatrix vw_rotation;	/* view rotation			*/
    double    vw_origin [3];	/* view origin				*/
    	
    int       dp_levels [32];	/* levels on in reference file		*/

    IGRmatrix master_to_ref_matrix;/* master file to reference file	*/
    IGRmatrix ref_to_master_matrix;/* reference file to master file	*/
};

/* This is the message added for EMS_OLE_SRVR */
message GRrfgetfilename (long *msg; char *filename);

#ifndef BASE_EMS
/* 
 * Method declarations for the GRreffile subclass.
 */

message GRrfinit ( long *msg; IGRboolean *constr_flag; 
	char *logical; GRspacenum *osnum; 
	GRobjid *mod_id; struct GRid *context );

message GRrfclose ( long *msg; long *type );

message GRgetrfprops ( long *msg; unsigned long *ref_properties );

message GRinquireref ( long *msg; struct GRmd_env *env;
	struct GRinquire_list *inquire_requests; int *which_error; 
	IGRboolean *pass_to_other_spaces; struct GRinfo_processor *processor );

message GRgetenvironment ( long *msg; struct GRmd_env *env_path;
	struct GRmd_env *new_env );


message GRgetdescription ( long *msg; IGRshort *flag; char *description );

message GRputdescription(long *msg; IGRshort *flag; char *description);

message GRgetlevels(long *msg; int *levels);

message GRchglevels(long *msg; IGRshort *flag; int *levels);

message GRgetscale(long *msg; double *scale);

message GRputscale(long *msg; char *scale);
	/** The above method alters the scale string of the reffile attachment
	    and transforms the reffile window **/

message GRaltscale(long *msg; struct GRmd_env *md_env; IGRshort *mx_type; 
	IGRmatrix matrix; GRobjid *newobjid; char *scale);
	/** The above method alters the scale string of the reffile attachment
	    and transforms the reffile geometry **/

message GRxformref(long *msg;IGRshort *mx_type; IGRmatrix matrix; 
	IGRmatrix xform_matrix);

message GRselpass(long *msg;	unsigned long *ref_properties_mask;
	IGRshort *pass_to_nested_attachments; OM_p_MESSAGE pass_msg; 
	IGRshort *mx_type; IGRmatrix matrix; GRobjid *module_id; 
	GRspacenum *module_osnum);

message GRgetlbsys(long *msg; IGRshort *mx_type; IGRmatrix matrix; 
	struct IGRlbsys *lbsys);

message GRpostlbsys(long *msg; struct GRmd_env *md_env;
	struct GRpost_info *post_info; struct IGRlbsys *lbsys);

message GRlvdisplay(long *msg; IGRshort *mx_type; IGRmatrix matrix; 
	enum GRdpmode *mode; struct GRid *dp_info;
	int *levels);

message GRupdrefrng(long *msg; IGRshort *mx_type; IGRmatrix matrix);

message GRplotpass(long *msg; OM_S_MESSAGE *plot_msg; int *levels;
	struct IGRcv_prism *prism_array; int *num_prisms; int (*filter_function)(); char *filter_data);

message GRchgfilename(long *msg; char *new_filename; 
	char *new_name);

message GRrfpostinit(long *msg; struct GRid *context_super);

message GRpre_update(long *msg; struct GRmd_env *env;
	char *named_object_name; struct GRid *gragad_id;
	struct DP_information *dp_info);

message GRpost_update(long *msg; char *named_object_name; 
	struct GRid *gragad_id);

message GRchgrfprops(long *msg; IGRshort *flag;
	unsigned long *ref_properties);

message GRgetosnum ( long *msg; GRspacenum *p_osnum );
/*
   This message returns the osnum of the reference file.  That osnum is
   usually different from execution to execution.  It will return failure
   (i.e. MSFAIL) if the file is missing.

   Arguments:

	long *msg		The returned status
        OMuword *p_osnum 	The osnum of the reference file
*/
message GRrfload (IGRlong * msg);
message GRrfunload (IGRlong * msg);

message GRrfupdrtree ( long *msg; struct GRmd_env *md_env);
/*
   This message will update the range of the reference file in the R-tree.
   The new range will be computed from the reference file object space.
   Then it will adjust the clipping polygon with the new range.

   Arguments

       long   *msg                completion code
       struct GRmd_env *md_env    objects's module environment

   Return values

       - MSSUCC if sucessful
       - MSFAIL if failure

*/


override GRchgweight,GRchgcolor,GRchgdp,
	 GRchgstyle, GRchgname, GRputname,
         GRdisyourself,  GRlocate, GRconstruct, GRdelete, 
	 GRgenabsg, GRpostabsg, GRgetobjinfo, GRcopy, 
	 GRfunction, GRxform, GRgetrang, GRptproject, GRlnproject,
	 GRprismrel, GRlocate_processing,
	 GRaddwrng,GRremwrng,GRgetsize,GRgetgeom, GRcptform,
	 GRgeomprops, GRisparent, debug;

#endif
end specification GRreffile;
