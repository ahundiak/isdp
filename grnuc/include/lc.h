




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 



#ifndef lc_include

#define lc_include

/*
Name
        lc.h

Description
        This file contains structures used by the locate subsystem.

Dependencies
	igr.h
	gr.h
	igrdp.h
	dp.h
	go.h
	lcdef.h
	grio.h

History
        rc      ??/??/??    creation
        mrm     09/07/89    added value_type and scale_flag to LC_select_args
        spr     06/28/93    add GR_dlist_upd_loc locate type for display lists
*/

enum GRlocate_types {GR_pt_loc, GR_bl_loc, GR_upd_loc,
                     GR_nam_loc, GR_rp_loc, GR_cv_loc, GR_crit_loc,
                     GR_dlist_upd_loc};


struct GRlc_locate
{
		char			classes[256];
		unsigned long 		properties;  /* values are.....*/
/*		... .... .... ..00	ignore locate bit check        */
/*		... .... .... ..01	locate locatable objects only  */
/*		... .... .... ..10	locate non-locatable objects   */
/*		... .... .... ..11	locate both types of objects   */
/*		... .... .... 00..	ignore read-write bit check    */
/*		... .... .... 01..	locate read only objects       */
/*		... .... .... 10..	locate write only objects      */
/*		... .... .... 11..	locate both types of objects   */
/*		... .... ..00 ....	ignore display bit check       */
/*		... .... ..01 ....	locate displayable objects only*/
/*		... .... ..10 ....	locate invisible objects only  */
/*		... .... ..11 ....	locate both types of objects   */
/*		... .... 00.. ....	ignore new-modified bit check  */
/*		... .... 01.. ....	locate new objects only        */
/*		... .... 10.. ....	locate modified objects only   */
/*		... .... 11.. ....	locate both types of objects   */
/*		... ..00 .... ....	ignore planar bit check        */
/*		... ..01 .... ....	locate planar objects only     */
/*		... ..10 .... ....	locate nonplanar objects only  */
/*		... ..11 .... ....	locate both types of objects   */
		unsigned long 		owner_action;  /* values are...*/
/*		... .... .... ...0	don't locate rigid component   */
/*		... .... .... ...1	      locate rigid component   */
/*		... .... .... ..0.	don't locate rigid owner       */
/*		... .... .... ..1.	      locate rigid owner       */
/*		... .... .... .0..	don't locate flexable component*/
/*		... .... .... .1..	      locate flexable component*/
/*		... .... .... 0...	don't locate flexable owner    */
/*		... .... .... 1...	      locate flexable owner    */
/*		... .... ...1 ....	locate objects with owners     */
/*		... .... ...0 ....	don't locate orphans           */
};


struct GRlc_upd_loc
{
		IGRlong		msg;
    enum	GRdpmode	mode;
    struct	IGRdisplay	*alt_symb;
    struct	DP_information	*sp_info;		
		GRrange		upd_range;
		GRrange		upd_range2;
		IGRint		is_ortho;
		IGRvector       view_vector;
};

struct GRlc_nm_loc
{
    struct      GRlc_locate	obj_attr;
		GRname		name;
};

struct	GRlc_parms
{
    enum	GRlocate_types	type;		/* type of locate    */
    struct	GRlc_locate	obj_attr;	/* object attributes */
		IGRpoint	acc_point;	/* accept point      */
    struct	IGRline		acc_line;	/* accept line       */
		IGRdouble	acc_tolerance;	/* accept tolerance  */
    struct	IGRrt_prism	acc_rt_prism;
    struct 	IGRcv_prism	acc_cv_prism;
};

struct GRlc_stack
{
     IGRint 		num_entries;
     struct GRid        module;			/* module in which   */
						/* window is 	     */
     struct GRid        window; 		/* window where      */
 						/* locate point      */
     struct GRlc_info   entry[MAX_LCSTACK_LEN];
     IGRshort           state;
     IGRshort           number_located;
};

struct GRlc_cvl
{
		IGRlong		msg;		/* completion code   */
    struct	GRmd_env	module;	        /* identifies:       */
						/* who is locating   */
						/* how their locating*/
    struct	GRlc_parms	attributes;	/* functional attr.  */
    		IGRint		(*action_handler)();
						/* action routine    */
		IGRchar		*act_parms;	/* parameters for the*/
                      			/* action handler    */
    struct	EX_button	button;
		IGRint		*levels;	
                OM_p_CLASSLIST  classes;
    struct      LC_action_args	*locate_args;
                IGRlong		prism_attr;
                OM_p_CLASSLIST  r_classes;
                IGRchar         *data;
 };

struct GRlc_pt_loc
{
    struct 	GRlc_locate     obj_attr;
		IGRdouble	tolerance;
    struct	EX_button	datapoint;
		GRrange		upd_range;
};

struct GRlc_bl_loc
{
    struct      GRlc_locate	obj_attr;
		IGRdouble	tolerance;
    struct 	EX_button	datapoint;
    struct	IGRline		boreline;
		GRrange		upd_range;
		GRrange		skew_range;
		IGRint		is_ortho;
};

struct GRlc_rp_loc
{
    struct      GRlc_locate	obj_attr;
		IGRdouble	tolerance;
    struct 	EX_button	datapoint;
    struct	IGRrt_prism	rt_prism;
		GRrange		upd_range;
		GRrange		skew_range;
		IGRvector	view_vector;
		IGRint		is_ortho;
		IGRlong		prism_attr;
};

struct GRlc_cp_loc
{
    struct      GRlc_locate	obj_attr;
		IGRdouble	tolerance;
    struct 	EX_button	datapoint;
    struct	IGRcv_prism	cv_prism;
		GRrange		upd_range;
		GRrange		skew_range;
		IGRvector	view_vector;
		IGRint		is_ortho;
		IGRlong		prism_attr;
};

struct GRlc_dynamics
{
     IGRint            (*GRlc_dyn)();
     struct GRid       GRlc_object;
     struct GRevent    GRlc_event;
     IGRchar           *add_info;
};

struct GRlc_act_info
{
    struct GRlc_stack	*stack;
    enum GRlocate_types type;    
    IGRlong             is_regex;
    struct GRid         gs_id;
    struct GRid         sv_id;
    IGRint              located;
};

struct GRlc_classes {
	OM_p_CLASSLIST      rtree_classes;
        OM_p_CLASSLIST      eligible_classes;
};

typedef  struct  GRlc_classes  *GRlc_classptrs;

struct LC_select_args
{
       IGRchar         		*response_data;
       IGRchar          	*obj_hilighted;
       IGRchar	        	*acc_prompt;
       IGRlong			acc_key;
       IGRchar 	        	*relocate_prompt;
       IGRlong			relocate_key;
       IGRboolean               *is_bore;
       IGRint                   *eventsize;
       IGRint                   *response;
       IGRlong                  eventmask;
       IGRlong                  display_flag;
       IGRdouble                tolerance;
struct GRlc_stack       	*stack;
struct GRlc_dynamics    	*dyn;        
struct GRevent         		*accept_event;
struct GRevent   	        *acc_event1;
enum   GRdpmode                 mode;
enum   GRdpmode                 hilight_mode;
       IGRint                   *nbytes;
       IGRchar                  *value_type;
       IGRint                   scale_flag;
};

struct LC_action_args
{
       IGRlong			*rc;
struct GRlc_stack		*stack;
enum   GRlocate_types		type;
       IGRlong                  is_regex;
struct GRid                     gs_id;
struct GRid                     sv_id;
       IGRint                   located;       
       IGRint			max_entries;
       IGRint			(*select)();
       IGRchar			*select_args;
struct LC_select_args           *loc_select_args;
       IGRint                   (*action)();
};

/*
 *  This structure is used for communication between simple graphic objects 
 *  and owners during the locate process.
 */
 
struct GRlc_path
{
   IGRint               call_action_handler;
   IGRint               result;
   IGRint               name_entry;
   enum GRlocate_action action;
   struct GRlc_info     lc_info;
   IGRint		object_info;
};

#endif
