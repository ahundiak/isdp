# ifndef EMSrgmod_include
# define EMSrgmod_include

/*
 * Simple surface regional modification table size data.
 */
struct EMSsfrmt_size
{
  IGRint    num_surfaces;       /* Number of surfaces modified  */
  IGRint    num_regions_in;     /* Number of regions added      */
  IGRint    num_regions_out;    /* Number of regions removed    */
};

/*
 * Composite surface regional modification table size data.
 */
struct EMScsrmt_size
{
  IGRint    num_composites;     /* Number of composites modified    */
  IGRint    num_surfaces_out;   /* Number opf surfaces removed      */
  IGRint    num_surfaces;       /* Number of surfaces modified      */
  IGRint    num_regions_in;     /* Number of regions added          */
  IGRint    num_regions_out;    /* Number of regions removed        */
};

/*
 * Make face regional modification table size data.
 */
struct EMSmfrmt_size
{
  IGRint    num_surfaces;       /* Number of surfaces modified  */
  IGRint    num_regions_in;     /* Number of regions added      */
  IGRint    num_regions_out;    /* Number of regions removed    */
  IGRint    num_regions;        /* Number of regions modified   */
  IGRint    num_edges_in;       /* Number of edges added        */
  IGRint    num_edges_out;      /* Number of edges removed      */
};

/*
 * Regional modification table size data.
 */
union EMSrmtSizeData
{
  struct EMSsfrmt_size  sf_info;    /* Simple surface size data     */
  struct EMScsrmt_size  cs_info;    /* Composite surface size data  */
  struct EMSmfrmt_size  mf_info;    /* Make face size data          */
};


/*
 * Simple surface regional modification table.
 */
struct EMSsfregmod_table
{
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
 * Composite surface regional modification table.
 */
struct EMScsregmod_table
{
  IGRint        num_composites;         /* Num composites affected.     */
  GRobjid       *composite_ids;         /* Affected composite objects   */
  IGRint        *num_surfaces_out;      /* Num surfaces per composite   */
  GRobjid       *surface_out_ids;       /* Removed surface objects      */
                                        /* that are removed to activate */

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
 * Make face regional modification table.
 */
struct EMSmfregmod_table
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
  IGRint	cum_num_edges_out;	/* Num edges affected		*/
  IGRint        *num_edges_in;          /* Num edges per region that    */
                                        /* are added to activate        */
  GRobjid       *edge_in_ids;           /* Edge objects added           */
  IGRint        *num_edges_out;         /* Num edges per region that    */
                                        /* are removed to activate      */
  GRobjid       *edge_out_ids;          /* Edge objects removed         */
};

/*
 * Regional modification table.
 */
union EMSregmod_table
{
  struct EMSsfregmod_table sf_info;
  struct EMScsregmod_table cs_info;
  struct EMSmfregmod_table mf_info;
};

#endif
