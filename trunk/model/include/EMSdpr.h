#ifndef EMSdpr_include
#define EMSdpr_include

/*
 * Defines follow:
 */

/* bit fields of EMSdprparam->status byte*/
#define STAT_CANT_RECOMPUTE         0x01

/*EFcreate_suppress_id options*/
#define EFcreate_supp_id_CREATE_PARTIAL      0x01

/*EFshow_parent_child_relationship options*/
#define EFshow_par_child_rel_DONT_DISPLAY    0x01
#define EFshow_par_child_rel_DONT_RETURN_IDS 0x02

/*EMdelete_feature options*/
#define EMdel_fea_DELETE_AND_SAVE   0x01
#define EMdel_fea_CLEANUP_DELETED   0x02
#define EMdel_fea_RESTORE_DELETED   0x04
#define EMdel_fea_DELAY_UPDATE      0x08

/* EMfix_creator_id optionss*/
#define EMfix_cr_id_VALIDATE        0x01

/* EMget_tree_top optionss*/
#define EMget_tree_top_FIRST_DPR    0x01

/*BUFF FOR EMgettreepath.*/
#define TREE_PATH_BUFF_INCR          30

/*Flags for EMcheckOverlap.*/
#define EMcheck_overlap_TREAT_SFS_AS_SFMOD  0x01

/*Flags for EMdeactivateState.*/
#define EMdeact_st_KNOWN_DEPENDENT   0x01

/*Options for EMdeactivateState.*/
#define EMdeact_st_ADD_MANAGER       0x01
#define EMdeact_st_IMMEDIATE_OPER    0x02
#define EMdeact_st_DO_DISPLAY        0x04
#define EMdeact_st_UNUSED            0x08
#define EMdeact_st_DELETE_SSI        0x10


/*Options for EMunevaluate.*/
#define EMuneval_ADD_MANAGER              0x01
#define EMuneval_REMOVE_UNEVAL_NODES      0x02
#define EMuneval_DO_DISPLAY               0x04
#define EMuneval_DONT_REDRAW              0x08
#define EMuneval_DELETE_SSI               0x10
#define EMuneval_IMMEDIATE_OPER           0x20


/*Options for EMevaluateOps.*/
#define EMeval_op_EVAL_ALL_SHELLED         0x01
#define EMeval_op_EVAL_GIVEN_SHELLED       0x02
#define EMeval_op_DO_DISPLAY               0x04
#define EMeval_op_NO_ADD_TO_RT             0x08
#define EMeval_op_EVAL_ALL_NONSHELLED      0x10
#define EMeval_op_DONT_CHECK_DEPENDENTS    0x20
#define EMeval_op_NO_REMOVE_FROM_RT        0x40


/*Options for EMevaluate.*/
#define EMeval_EVAL_ALL_SHELLED          0x01
#define EMeval_EVAL_GIVEN_SHELLED        0x02
#define EMeval_DO_DISPLAY                0x04
#define EMeval_DONT_REDRAW               0x08
#define EMeval_EVAL_ALL_NONSHELLED       0x10
#define EMeval_DONT_CHECK_DEPENDENTS     0x20

/*Options for EMreplace.*/
#define EMreplace_DO_DISPLAY             0x01
#define EMreplace_DONT_REDRAW            0x02
#define EMreplace_DONT_EVAL              0x04
#define EMreplace_IMMEDIATE_OPER         0x08


/*Chan size for EMgetCompIndex.*/
#define CHAN_BUFF_INCR                   60

/*Options for EMgetCompIndex.*/
#define EMget_comp_inx_DONT_SEND_UP      0x01

/*Options for EMputCompIndex.*/
#define EMput_comp_inx_DONT_SEND_UP      0x01

/*Options for EMrecompinfodelete.*/
#define RIDEL_DEL_COMP_RI                0x01

/*Options for EMtoggleOrient.*/
#define EMtoggle_orient_FLIP_AS_IF_INACTIVE  0x01

/*Options for EMconnectTopology.*/
#define EMconnect_top_DISCONNECT          0x01
#define EMconnect_top_FREE_ONLY           0x02

/*Options for EMcleanSSI.*/
#define EMclean_ssi_DONT_SEND_UP         0x01

/*Options for EMgetInInfo.*/
#define EMget_in_inf_SHELL_ALL_DEP       0x01
#define EMget_in_inf_NO_SURFS            0x02
#define EMget_in_inf_NO_LOOPS            0x04
#define EMget_in_inf_NO_EDGES            0x08
#define EMget_in_inf_NO_EDGES_FROM_LOOPS 0x10

/*Options for EFfind_created.*/
#define EFfind_created_NO_LOOPS             0x01
#define EFfind_created_NO_EDGES             0x02
#define EFfind_created_NO_EDGES_FROM_LOOPS  0x04


/*Options for EMcleanupComputeInfo.*/
#define EMcleanup_compute_info_FREE_ONLY      0x01
#define EMcleanup_compute_info_DONT_SEND_DOWN 0x02

/*Options for EMputGetChangedId.*/
#define EMputGetChangedId_PUT                 0x01
#define EMputGetChangedId_DELETE              0x02

/*Bit patterns stored in DPR ids vla to indicate the beginning of the 
 * modified/replacing ids.
 * Shall exists as ids[ii] == CHGIDPAT1 && ids[ii+1] == CHGIDPAT2
 */
#define CHGIDPAT1    0xfffffffe 
#define CHGIDPAT2    0xfffffffd

/*max tag value indicates no tag*/
#define EMS_NO_TAG   0xffffffff

/*
 * Structures follow:
 */

struct EMSsflist
{
  IGRint       array_size;        /*Surf_ids array size (#elements).*/
  IGRint       num_surfs;         /*Number of surf objids in array. */
  GRobjid      *surf_ids;         /*List of added surface ids.      */
};

struct EMSlplist
{
  IGRint       array_size;        /*Lopp_ids array size (#elements).*/
  IGRint       num_loops;         /*Number of loop objids in array. */
  GRobjid      *loop_ids;         /*List of added loop ids.         */
};

struct EMSedlist
{
  IGRint       array_size;        /*Edge_ids array size (#elements).*/
  IGRint       num_edges;         /*Number of edge objids in array. */
  GRobjid      *edge_ids;         /*List of added edge ids.         */
};

struct EMSmodlist
{
  /*This structure is used during the unevaluate phase to determine nodes
   * affect by this unevaluation.  This is very special in that the overlap is
   * range only.  This range overlap is important relative to difference
   * operations since the orientation must be reversed if the overlap is found.
   */

  GRobjid      mod_id;     /*Id of modified elements.*/
  GRrange      range;      /*Range of the element.*/
};

/*See note on what is considered an added surface in EMSoutlist comment below*/

struct EMSinlist
{
  struct EMSsflist  sflist;      /*list of surfs in.*/
  struct EMSlplist  lplist;      /*list of loops in.*/
  struct EMSedlist  edlist;      /*list of edges in.*/
  struct EMSmodlist modlist;     /*Id and range of modified hole region.*/
};

struct EMSreplace_info
{
  GRobjid      replacing_id;    /*Ids of modified/inserted elements.*/
  GRrange      range;           /*Range of modified/inserted elements.*/
};

struct EMSrnglist
{
  /*This structure is used during the evaluate phase to determine geometric
   * overlap of replacing nodes to otherwise unaffected nodes.  When this
   * occures then that unaffected node must also evaluate.
   * Note that a modified node is also considered the same as a replacing node.
   */

  IGRint       num_repl_info;     /*Number of modified/inserted elements.*/
  struct EMSreplace_info *replace_info; 
};

/*The sfmodlist field of the outlist structure is for operations which perform
 * BOUNDARY changes to surfaces.  If an operation does a GEOMETRIC change then
 * the surface should go into the inlist.sflist location of the inlist
 * structure.  For example, the lifted surface in the lift face operation
 * should go into the inlist.sflist as a surface added.  However, any trimmed
 * surface thats done by the lift (coincident) should go in the
 * outlist.sfmodlist.
 * AND ADDITIONALLY the surface that has been geometrically modified should
 * go in the rnglist.replace_info list of the outlist.  Then it will
 * be range intersected with other geometry for range overlap checks.
 */

struct EMSoutlist
{
  struct EMSsflist  sflist;      /*list of surfs out.*/
  struct EMSsflist  sfmodlist;   /*list of surfs modified.*/
  struct EMSlplist  lplist;      /*list of loops out.*/
  struct EMSedlist  edlist;      /*list of edges out.*/
  struct EMSrnglist rnglist;     /*Ids and ranges of inserted/mod  element.*/
};

struct EMchanstruct
{
  GRobjid id;       /*The object which has channel in question.*/
  IGRint  chancnt;  /*Current number on channel.        */
  GRobjid *chan;    /*The (simulated) channel.          */
};

#define EMScompute_info_SIZE 50

struct EMScompute_info
{
  GRobjid            computed_id;  /*The computed node.*/
  union EMSssi_table *ssi;     /*ptr to the ssi struct BEFORE the recompute.*/
  union EMSri_table  *ri;      /*ptr to the ri struct BEFORE the recompute.*/
  IGRchar            *con_top; /*ptr to connect topology info before the rc.*/
  struct EMSadded_geom         /*Added surfaces by this node (i.e. localmods)*/
  {
    IGRint       num_added;    
    GRobjid      *added_ids;   
    IGRint       *added_inx;
  } added_geom;
};

/*options for surface & boundary EMstore & EFsend_store_on*/
#define EMstore_opt_MATCH_FAILED        0x01
#define EMstore_opt_DONT_DISPLAY        0x02
#define EMstore_opt_HAS_COMPOSITE_OWNER 0x04
#define EMstore_opt_DONT_ORIENT         0x08

#endif
