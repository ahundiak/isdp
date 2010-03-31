# ifndef EMSssi_include
# define EMSssi_include

/*
 *
 * NOTE: When impose boundary and make face operations are expanded to work
 *       across surfaces, the EMSsfssi and EMSboolssi structures will be
 *       merged together (remaining EMsfssi).  Also the EMSsfboolean
 *       instance data 'num_composites' will be moved to EMSsfregmod.
 *
 * History	DLB	xx/xx/xx	Creation Date.
 *		SM	11-Feb-88	Modified EMSsfssi_(xxx) structures
 *					to include common edge modifications
 *					during imposing boundaries on a part
 *					of a composite.
 *		SM	05-Oct-88	Added EMSstchssi_(xxx) structures for
 *					stitch save state.
 *              RC      22-Nov-88       Added EMSxsssi_(xxx) structures for
 *                                      cross_section save state.
 *		SS	28-Sep-89	Added the EMSmodobjinfo structure
 *             AMD      08/10/91        Added EMSdbssi_table for
 *                                      Delete surface boundary state
 *             AMD      07/10/92        Added EMSunssi_table for
 *                                      Unite surfaces state
 */

/*
 * Surface save state information table size data.
 */
struct EMSsfssi_size
{
  IGRint    num_surfaces;       /* Number of surfaces modified  */
  IGRint    num_regions_in;     /* Number of regions added      */
  IGRint    num_regions_out;    /* Number of regions removed    */
  IGRint    num_regions;        /* Number of regions modified   */
  IGRint    num_edges_in;       /* Number of edges added        */
  IGRint    num_edges_out;      /* Number of edges removed      */
  IGRint    num_edges_copied;   /* Number of edges copied and replaced*/
};

/*
 * Boolean save state information table size data.
 */
struct EMSboolssi_size
{
  IGRint    num_composites;     /* Number of composites modified    */
  IGRint    num_surfaces_out;   /* Number of surfaces removed       */
  IGRint    num_surfaces;       /* Number of surfaces modified      */
  IGRint    num_regions_in;     /* Number of regions added          */
  IGRint    num_regions_out;    /* Number of regions removed        */
};

/*
 * Delete boundary save state information table size data.
 */
struct EMSdbssi_size
{
  IGRint    num_composites;        /* Number of composites modified    */
  IGRint    num_surfaces_out;      /* Number of surfaces removed       */
  IGRint    num_surfaces;          /* Number of surfaces modified      */
  IGRint    num_regions_out;       /* Number of regions removed        */
  IGRint    num_edges_disconnected;/* Number of edges disconnected     */   
};


/*
 * Unite surfaces save state information table size data.
 */
struct EMSunssi_size
{
  IGRint    num_composites;        /* Number of composites modified    */
  IGRint    num_surfaces_out;      /* Number of surfaces removed       */
  IGRint    num_edges;             /* Number of edges disconnected     */   
};

/*
 * add draft/replace surfaces save state information table size data.
 */
struct EMSaddraftssi_size
{
  IGRint    num_surfaces_out;            /* Number of composites modified    */
  IGRint    num_composites;            /* Number of composites modified    */
  IGRint    num_old_commedge_pairs;  /* Number of commedges disconnected */   
  IGRint    num_new_commedge_pairs;  /* Number of commedges disconnected */   
};

/*
 * Cap solid save state information table size data.
 */

struct EMScapssi_size
{
  IGRint    num_edges;             /* Number of edges disconnected     */   
};


/*
 * Make face save state information table size data.
 */
struct EMSmfssi_size
{
  IGRint    num_surfaces;       /* Number of surfaces modified  */
  IGRint    num_regions_in;     /* Number of regions added      */
  IGRint    num_regions_out;    /* Number of regions removed    */
  IGRint    num_regions;        /* Number of regions modified   */
  IGRint    num_edges_in;       /* Number of edges added        */
  IGRint    num_edges_out;      /* Number of edges removed      */
  IGRint    num_edges_copied;   /* Number of edges copied which */
                                /* are shared by org face and   */
                                /* made face                    */
};


/*
 * Rounding and chamfering  save state information table size data.
 */
struct EMSrndssi_size
{
  IGRint    num_surfaces;       /* Number of surfaces modified  */
  IGRint    num_regions_in;     /* Number of regions added      */
  IGRint    num_regions_out;    /* Number of regions removed    */
  IGRint    num_edges_out;      /* Number of edges removed      */
  IGRint    num_edges_in;       /* Number of edges added        */
  IGRint    num_edges_rounded;  /* Number of edges rounded      */
};


/*
 * Split surface save state information table size data.
 */
struct EMSspssi_size
{
  IGRint    num_srf_owner;          
  IGRint    num_srf;
  IGRint    num_edges; 
};

/*
 * Move save state information table size data.
 */
struct EMSmvssi_size
{
  IGRint    num_loops;
};

/*
 * History save state information table size data.
 */
struct EMShstssi_size
{
  IGRint    num_added;          /* Currently only on state is added at a
                                 * time so this struct is unused.
                                 */
};

/*
 * Lift save state information table size data.
 */

struct EMSlftssi_size
{
  IGRint        num_composites;         /* Num of composites modified   */
  IGRint        num_surfaces_out;       /* Numb of surfaces removed     */
  IGRint        num_sf_lifted;          /* Num surfaces lifted          */
  IGRint        num_sf_affected;        /* Num surfaces affected        */
  IGRint        num_regions_in;         /* Num regions added to activate*/
  IGRint        num_regions_out;        /* Num regions rmvd to activate */
  IGRint        num_eds_rplcd;          /* Num edges replaced to        */
                                        /* activate                     */
  IGRint        num_eds_in;             /* Num edges added to replace   */
                                        /* edges out                    */
  IGRint        num_eds_wcm_md;         /* Num edges where common edges */
                                        /* of the edge and its common   */
                                        /* edge have been changed. There*/
                                        /* will be 4 edges per entry    */
  IGRint        num_ed_wmv_cm;          /* Num Edges whose common edge  */
                                        /* is mpoved to activate. There */
                                        /* will be two entries per edge */
  IGRint        num_eds_wcm_eds;        /* Num edges which did not have */
                                        /* common edges before lift     */
                                        /* process but do after lift is */
                                        /* complete. This will be the   */
                                        /* case in single sf lift. There*/
                                        /* will be 2 entries per edge.  */
};


/* Stitch save state table size data.
*/
struct EMSstchssi_size
{
  IGRint	num_edges_out;
  IGRint	total_num_edges_in;
  IGRint	num_edges_connected;
};

/*
 * Cross section save state information table size data.
 */

struct EMSxsssi_size
{
  IGRint       num_composites;         /* Num of composites modified   */
  IGRint       num_surfaces_out;       /* Numb of surfaces removed     */
  IGRint       num_surfaces;
  IGRint       num_regions_in;
  IGRint       num_regions_out;
};

/*
 * Save state information table size data.
 */
union EMSssiSizeData
{
  struct EMSsfssi_size   sf_info;    /* Simple surface size data     */
  struct EMSboolssi_size bool_info;  /* Boolean size data            */
  struct EMSmfssi_size   mf_info;    /* Make face size data          */
  struct EMSspssi_size   spl_info;   /* Split face size data         */
  struct EMSmvssi_size   mv_info;    /* Move size data               */
  struct EMShstssi_size  hst_info;   /* History size data            */
  struct EMSlftssi_size  lft_info;   /* Lift size data               */
  struct EMSrndssi_size  rnd_info;   /* Round & Chamfer size data    */
  struct EMSstchssi_size stch_info;  /* stitch size data             */
  struct EMSxsssi_size   xs_info;    /* Cross section size data      */
  struct EMSdbssi_size   db_info;    /* Delete boundary size data    */
  struct EMSunssi_size   un_info;    /* Unite surfaces size data     */
  struct EMScapssi_size  cap_info;   /* Cap surfaces size data       */
  struct EMSaddraftssi_size  addrft_info;  /*add draft size data      */
};


/*
 * Simple surface save state information table.
 */
struct EMSsfssi_table
{
  IGRint        num_surfaces;           /* Num surfaces affected        */
  GRobjid       *surface_ids;           /* Affected surface objects     */
  IGRint        *num_regions_in;        /* Num regions per surface that */
                                        /* are added to activate        */
  GRobjid       *region_in_ids;         /* Region object added          */
  IGRint        *num_regions_out;       /* Num regions per surface that */
                                        /* are removed to activate      */
  GRobjid       *region_out_ids;        /* Region objects removed       */
  IGRint        num_regions;            /* Num regions affected         */
  GRobjid       *region_ids;            /* Affected region objects      */
  IGRint        cum_num_edges_out;      /* Num edges affected           */
  IGRint        *num_edges_in;          /* Num edges per edge that      */
                                        /* is taken out to activate     */
  GRobjid       *edge_in_ids;           /* Edge objects added           */
  IGRint        *num_edges_out;         /* Num edges per region that    */
                                        /* are removed to activate      */
  GRobjid       *edge_out_ids;          /* Edge objects removed         */
  IGRint        num_edges_copied;       /* Number of edges copied and   */
                                        /* replaced.		        */
  GRobjid       *ed_cp_ed_ids;          /* Edges and their copied ids   */
};

/*
 * Boolean save state information table.
 */
struct EMSboolssi_table
{
  IGRint        num_composites;         /* Num composites affected.     */
  GRobjid       *composite_ids;         /* Affected composite objects   */
  IGRint        *num_surfaces_out;      /* Num surfaces per composite   */
  GRobjid       *surface_out_ids;       /* Removed surface objects      */
                                        /* that are removed to activate */
  IGRint        *composite_indices;     /* Index of surface removed on  */
                                        /* composites channel.          */

  IGRint        num_surfaces;           /* Num surfaces affected        */
  GRobjid       *surface_ids;           /* Affected surface objects     */
  IGRint        *num_regions_in;        /* Num regions per surface that */
                                        /* are added to activate        */
  GRobjid       *region_in_ids;         /* Region object added          */
  IGRint        *num_regions_out;       /* Num regions per surface that */
                                        /* are removed to activate      */
  GRobjid       *region_out_ids;        /* Region objects removed       */
};

/*
 *  Delete boundary save state information table.
 */
struct EMSdbssi_table
{
  IGRint        num_composites;         /* Num composites affected.     */
  GRobjid       *composite_ids;         /* Affected composite objects   */
  IGRint        *num_surfaces_out;      /* Num surfaces per composite   */
  GRobjid       *surface_out_ids;       /* Removed surface objects      */
                                        /* that are removed to activate */
  IGRint        *composite_indices;     /* Index of surface removed on  */
                                        /* composites channel.          */
  IGRint        num_surfaces;           /* Num surfaces affected        */
  GRobjid       *surface_ids;           /* Affected surface objects     */
  IGRint        *num_regions_out;       /* Num regions per surface that */
                                        /* are removed to activate      */
  GRobjid       *region_out_ids;        /* Region objects removed       */
  IGRint        num_edges_disconnected; /* num edges disconnected       */
  GRobjid       *edges_disconnected;    /* name says it all             */
};


/*
 *  Unite surfaces save state information table.
 */

struct EMSunssi_table
{
  IGRint        num_composites;         /* Num composites affected.     */
  GRobjid       *composite_ids;         /* Affected composite objects   */
  IGRint        *num_surfaces_out;      /* Num surfaces per composite   */
  GRobjid       *surface_out_ids;       /* Removed surface objects      */
                                        /* that are removed to activate */
  IGRint        *composite_indices;     /* Index of surface removed on  */
                                        /* composites channel.          */
  IGRint        num_edges;              /* num edges disconnected       */
  GRobjid       *edges_disconnected;    /* edges disconnected but not   */
                                        /* removed from composite.      */
  GRobjid       *edges_removed;         /* edges removed from composite */ 
  GRobjid       *edges_added;           /* edges added to composite     */ 
};

/*
 *  addraft/replace surfaces save state information table.
 */

struct EMSaddraftssi_table
{
  IGRint        num_composites;         /* Num composites affected.     */
  GRobjid       *composite_ids;         /* Affected composite objects   */
  IGRint        *num_surfaces_out;     /* Num surfaces per composite   */
  GRobjid       *surface_out_ids;       /* Removed surface objects      */
                                        /* that are removed to activate */
  IGRint        *composite_indices;     /* Index of surface removed on  */
                                        /* composites channel.          */
  IGRint       num_old_commedge_pairs;  /* num edges disconnected       */
  IGRint       num_new_commedge_pairs;  /* num edges connected       */
  GRobjid       *old_commedge_pairs1;   /* edges disconnected    */
  GRobjid       *old_commedge_pairs2;   /* edges disconnected    */
  GRobjid       *new_commedge_pairs1;   /* edges connected    */
  GRobjid       *new_commedge_pairs2;   /* edges connected   */
};


/*
 *  Cap solid save state information table.
 */

struct EMScapssi_table
{
  IGRint        num_edges;              /* num edges connected          */
  GRobjid       *edges_connected;       /* edges connected              */
};



/*
 * Make face save state information table.
 */
struct EMSmfssi_table
{
  IGRint        num_surfaces;           /* Num surfaces affected        */
  GRobjid       *surface_ids;           /* Affected surface objects     */
  IGRint        *num_regions_in;        /* Num regions per surface that */
                                        /* are added to activate        */
  GRobjid       *region_in_ids;         /* Region object added          */
  IGRint        *num_regions_out;       /* Num regions per surface that */
                                        /* are removed to activate      */
  GRobjid       *region_out_ids;        /* Region objects removed       */

  IGRint        num_regions;            /* Num regions affected         */
  GRobjid       *region_ids;            /* Affected region objects      */
  IGRint        cum_num_edges_out;      /* Num edges affected           */
  IGRint        *num_edges_in;          /* Num edges per edge that      */
                                        /* is taken out to activate     */
  GRobjid       *edge_in_ids;           /* Edge objects added           */
  IGRint        *num_edges_out;         /* Num edges per region that    */
                                        /* are removed to activate      */
  GRobjid       *edge_out_ids;          /* Edge objects removed         */
  IGRint        num_edges_copied;       /* Number of edges copied which */
                                        /* are shared by org face and   */
                                        /* made face                    */
  GRobjid       *ed_cp_ed_ids;          /* Edges and their copied ids   */
};

/*
 * Rounding and Chamfering save state information table.
 */
struct EMSrndssi_table
{
  IGRint        num_surfaces;           /* Num surfaces affected        */
  GRobjid       *surface_ids;           /* Affected surface objects     */
  IGRint        *num_regions_in;        /* Num regions per surface that */
                                        /* are added to activate        */
  GRobjid       *region_in_ids;         /* Region objects added         */
  IGRint        *num_regions_out;       /* Num regions per surface that */
                                        /* are removed to activate      */
  GRobjid       *region_out_ids;        /* Region objects removed       */
  IGRint        num_edges_out;          /* Num edges per region that    */
                                        /* are removed to activate      */
  GRobjid       *edge_out_ids;          /* Edge objects removed         */
  IGRint        *num_edges_in;          /* Num edges per edge that      */
                                        /* is taken out to activate     */
  GRobjid       *edge_in_ids;           /* Edge objects added           */
  IGRint        num_edges_rounded;      /* Number of edges rounded or   */
                                        /* chamfered                    */
  GRobjid       *rounded_edge_ids;      /* Edge objects rounded         */
};


/*
 * Split surface save state information table.
 */
struct EMSsspssi_table
{
  IGRint        num_srf_owner;
  GRobjid       *srf_owner_ids;
  IGRint        *owner_indices;
  IGRint        num_srf;
  GRobjid       *srf_ids;
  IGRint        num_edges;
  GRobjid       *edge_ids;
};

/*
 * Move save state information table.
 */
struct EMSmvssi_table
{
  IGRint         num_loops;
  GRobjid        *loop_ids;
};

/*
 * History save state information table.
 */
struct EMShstssi_table
{
  GRobjid        added_id;  
  GRobjid        added_on;
};

/*
 * Lift save state information table.
 */

struct EMSlftssi_table
{
  IGRint        num_composites;         /* Num composites affected.     */
  GRobjid       *composite_ids;         /* Affected composite objects   */
  IGRint        *num_surfaces_out;      /* Num surfaces per composite   */
  GRobjid       *surface_out_ids;       /* Removed surface objects      */
                                        /* that are removed to activate */
  IGRint        *composite_indices;     /* Index of surface removed on  */
                                        /* composites channel.          */
  IGRint        num_sf_lifted;          /* Num surfaces lifted          */
  GRobjid       *sf_lifted_ids;         /* Lifted surface objects       */
  IGRint        num_sf_affected;        /* Num surfaces affected        */
  GRobjid       *sf_affctd_ids;         /* Affected surface objects     */
  IGRint        *num_regions_in;        /* Num regions per surface that */
                                        /* are added to activate        */
  GRobjid       *region_in_ids;         /* Region object added          */
  IGRint        *num_regions_out;       /* Num regions per surface that */
                                        /* are removed to activate      */
  GRobjid       *region_out_ids;        /* Region objects removed       */
  IGRint        num_eds_rplcd;          /* Num edges replaced to        */
                                        /* activate                     */
  GRobjid       *ed_rplcd_ids;          /* Edge replaced to activate    */
  IGRint        *num_eds_in;            /* Num edges added per edge     */
                                        /* out to activate              */
  GRobjid       *ed_in_ids;             /* Edges added as replacement   */
                                        /* to activate                  */
  IGRint        num_eds_wcm_md;         /* Num edges where common edges */
                                        /* of the edge and its common   */
                                        /* edge have been changed       */
  GRobjid       *ed_mcm_ed_ids;         /* Edges and its old and new    */
                                        /* common edges. There are 4 ids*/
                                        /* per edge.                    */
  IGRint        num_ed_wmv_cm;          /* Num Edges whose common edge  */
                                        /* is moved to activate.        */
  GRobjid       *ed_ced_ids;            /* Edges between whom common    */
                                        /* edge is moved. There are two */
                                        /* entries per edge. The common */
                                        /* edge of first edge is moved  */
                                        /* to second edge to activate   */
  IGRint        num_eds_wcm_eds;        /* Num edges which did not have */
                                        /* common edges before lift     */
                                        /* process but do after lift is */
                                        /* complete. This will be the   */
                                        /* case in single sf lift. There*/
                                        /* will be 2 entries per edge.  */
  GRobjid       *ed_cm_ed_ids;          /* Edge and its common edge ids.*/
                                        /* Edges are connected to their */
                                        /* common edges to activate     */
};


/* Stitch save state table
*/
struct EMSstchssi_table
{
 IGRint			num_edges_out;
 GRobjid		*edges_out;
 IGRint			*num_edges_in;
 GRobjid		*edges_in;
 IGRint			num_edges_connected;
 GRobjid		*edges_connected;
};


/*
 * Cross section save state information table.
 */

struct EMSxsssi_table
{
  IGRint        num_composites;         /* Num composites affected.     */
  GRobjid       *composite_ids;         /* Affected composite objects   */
  IGRint        *num_surfaces_out;      /* Num surfaces per composite   */
  GRobjid       *surface_out_ids;       /* Removed surface objects      */
                                        /* that are removed to activate */
  IGRint        *composite_indices;     /* Index of surface removed on  */
  IGRint        num_surfaces;           /* Num surfaces affected        */
  GRobjid       *surface_ids;           /* Affected surface objects     */
  IGRint        *num_regions_in;        /* Num regions in per sf        */
  GRobjid       *region_in_ids;         /* Added region objects         */
  IGRint        *num_regions_out;       /* Num regions out per sf       */
  GRobjid       *region_out_ids;        /* Removed region objects       */
};

/*
 * Save state information table.
 */
union EMSssi_table
{
  struct EMSsfssi_table   sf_info;
  struct EMSboolssi_table bool_info;
  struct EMSmfssi_table   mf_info;
  struct EMSsspssi_table  spl_info;
  struct EMSmvssi_table   mv_info;
  struct EMShstssi_table  hst_info;
  struct EMSlftssi_table  lft_info;
  struct EMSrndssi_table  rnd_info;
  struct EMSstchssi_table stch_info;
  struct EMSxsssi_table   xs_info;
  struct EMSdbssi_table   db_info;
  struct EMSunssi_table   un_info;
  struct EMScapssi_table   cap_info;
  struct EMSaddraftssi_table  addrft_info;
};


/*
 * This structure is intended as a vehicle to communicate the changes made
 * on a complex object (EMSdpr) in as fine a detail as possible. The components
 * of the DPR that were modified, combined or split, inactivated or added,
 * are explicitly available in the form of arrays. Fields may not be all in
 * place at this time.
 *
 * Current interpretation:
 * 1) Any object appearing as deleted will NOT have it's components also
 *    appearing as deleted. The object flagged as deleted implies it's
 *    components as deleted. So any post-processing needs to trickle down to
 *    the lowest components. Surface components are loops; Loop components are
 *    edges and Edges do not have components. 
 * 2) Any object appearing as modified may or may not have it's components
 *    modified. If any of the componets are modified they would explicitly
 *    appear in one the arrays. So the post-processing should NOT go down
 *    the component tree.
 */

struct EMSmodobjinfo
  {
  IGRint num_sfsmod;
  GRobjid *sfsmod;
  IGRint num_sfsdel;
  GRobjid *sfsdel;

  IGRint num_lpsmod;
  GRobjid *lpsmod;
  IGRint num_lpsdel;
  GRobjid *lpsdel;

  IGRint num_edsmod;
  GRobjid *edsmod;
  IGRint num_edsdel;
  GRobjid *edsdel;

  IGRint num_ptrs_malloced;
  IGRchar **ptrs_malloced;
  };
 
#endif
