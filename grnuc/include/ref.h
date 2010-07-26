#ifndef REFERENCE_FILE
#define REFERENCE_FILE 1

/* 	This include file is dependent on the following
 * 	include files:
 *
 *	OMindex.h
 *	OMminimum.h
 * 	igetypedef.h
 *  	igrtypedef.h
 *	igr.h
 */


/* 
 * This structure is used by the GRconstruct method and the 
 * GRattachfile method.  The fields in the structure may be 
 * NULL pointers if the particular field does not apply to 
 * your application.
 */

struct GRrf_info
{
    IGRchar	*filename;	/* ptr to file name			*/
    IGRchar	*named_view;	/* ptr to named view			*/
    IGRchar 	*description;	/* ptr to the description		*/
    struct IGRcv_prism *clip_poly; 
				/* ptr to clipping prism		*/
    IGRchar	*prism_classname; 
				/* the classname describing the 
				   underlying class of the clipping 
			     	   prism. For example, if the prism face
				   is actually a block, the classname
				   would be GR3dorthpoly, GR2iorthpoly ,
				   GR3iorthpoly or GRbcorthpoly depending
				   on the database type			*/
    IGRuint 	*ref_properties;/* reference file properties	*/
    IGRchar	*scale;		/* string to define scale factor 	*/
};

/* 
 * This structure is used by the GRattachfile method.
 * The fields in the structure may be NULL pointers if the 
 * particular field does not apply to your application.
 */

struct GRrf_attach_file_info
{
    IGRchar	*filename;	/* ptr to file name			*/
    IGRchar	*named_view;	/* ptr to named view			*/
    IGRchar 	*description;	/* ptr to the description		*/
    IGRdouble	*origin;	/* origin for attachment in master file */
    IGRuint	*ref_properties;/* reference file properties	*/
    IGRchar	*scale;		/* string to define scale factor 	*/
};

struct GRref_instance_data
{
				/* special reference file properties	*/
    IGRuint ref_properties;

    IGRdouble  range[6];	/* range for pass in reference space	*/

    IGRdouble vw_volume[6];	/* view volume of the saved view	*/
    IGRmatrix vw_rotation;	/* view rotation			*/
    IGRdouble vw_origin[3];	/* view origin				*/

    IGRint    dp_levels[35];	/* levels on in reference file		*/

    IGRmatrix master_to_ref_matrix;/* master file to reference file	*/
    IGRmatrix ref_to_master_matrix;/* reference file to master file	*/
    IGRchar   description[100];	/* optional description			*/
    IGRchar   scale[40];
};

struct GRlocate_args_struct	/* arguments for locate method	*/
{
    struct GRlc_cvl *cvl; 
    OM_p_KEY_DESC   range_key; 
};

struct GRpass_args_struct		/* arguments for pass method	*/
{
    OM_p_MESSAGE msg_to_pass;
    OM_p_KEY_DESC p_select_key;
    char *p_criteria;
    OM_p_KEY_DESC p_target_key;
    int (*user_compare)();
    int *ret;
};

struct GRskew_pass_args_struct	/* arguments for skew pass method*/
{
    OM_p_MESSAGE  msg_to_pass;
    OM_p_SKEW_DESC p_select_key;
    OM_p_KEY_DESC p_target_key;
    char *p_criteria;
    int (*user_compare)();
    int *ret;
};

struct GRinfo_processor
{
     IGRint (*processor_function)();	/* function to handle info	*/
     IGRchar *info;			/* any miscellaneous info	*/
};

/* The following structure is a variable length argument list.  The
 * function/method using it will loop until the variable var is
 * equal to END_INQUIRE_REQUEST.  The user will specify all requests
 * using defines in refdef.h.
 */

struct GRinquire_list	
{
    IGRint  var;			/* request from refdef.h	*/
    IGRchar *var_ptr;			/* buffer to hold requested info*/
    IGRint  num_requested;		/* size of buffer		*/
    IGRint  num_returned;		/* size of info returned	*/
};


/* The following structure is for GRinquireref method argument list
 */

struct GRinquire_args_struct
{
    IGRlong *msg;
    struct GRmd_env *env;
    struct GRinquire_list *inquire_requests;
    IGRint  *which_error;
    IGRboolean *pass_to_other_spaces;
    struct GRinfo_processor *processor;
};

/*
 * The following struct is used by the GRreffile_reports function.
 */
struct GRreport_info 
{
    IGRint (*output_func)();    /* output function for GRreffile_reports func */
    IGRchar *info;              /* info used by the output function           */
};

#endif
