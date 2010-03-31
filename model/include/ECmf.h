struct ele_stack
  {
  struct GRid ele_grid;
  IGRint elem_type;        /* SPH_ELEMENT or FIL_ELEMENT as per ECmfdef.h */
  struct IGRbsp_surface *objs_surf;
  IGRdouble hot_edge;         /* set to v (of hot edge) for a fillet, 
                              edge_loc (0, 1,or 2) for sph patch */
  struct GRid open_edges[3];
  IGRdouble marked_edges[3];
  struct GRid model_surf[3];
  };

