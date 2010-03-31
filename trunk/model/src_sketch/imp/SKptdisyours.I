class implementation SKpoint;

/*
  HISTORY

  01/10/94 : Rajiv Agrawal : Removed the unnecessary class checking.  No more
                             GRhhd for GRhd.
*/

method GRdisyourself ( long *msg; short *mx_type; IGRmatrix matrix;  
                       enum GRdpmode *mode; struct IGRaltdisplay *alt_symb;
                       struct DP_information *sp_info; OM_p_KEY_DESC range_key )
{
  /* display my self */
  om$send ( msg = message GR3dpoint.GRdisyourself 
                  ( msg, mx_type, matrix, mode, alt_symb, sp_info, range_key ),
            mode = OM_e_wrt_message,        
            targetid = my_id );
  
  /* if it is for hilite purposes, we want to hilite the arc/circle I am the center of */
  if ((*mode == GRhhd) || (*mode == GRhd) || (*mode == GRbdhd) || (*mode == GRbehd) ||
      (*mode == GRhdo) || (*mode == GRhhdo))
  {
    OM_S_CHANSELECT chan_to_pts, chan_to_geoms;
    int             j;
    OMuint          count_geom;  
    OM_S_OBJID      ptvar, geom;
    GRspacenum      osnum;
    
    EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_pts );

    om$get_objid_at_index( object = me,
                           p_chanselect = &chan_to_pts,
                           index = 0,
                           objidaddr = &ptvar,
                           osnumaddr = &osnum );

    EMmake_chanselect ( SKvariable_to_geometries, &chan_to_geoms );
    count_geom = 0;
    om$get_channel_count ( objid = ptvar, osnum =osnum, 
                           p_chanselect = &chan_to_geoms, count = &count_geom );
    if (count_geom > 1) 
    { 
      for (j = 0; j < count_geom; j++)
      {
        om$get_objid_at_index ( objid = ptvar, osnum = osnum,
                                p_chanselect = &chan_to_geoms, index = j, 
                                objidaddr = &geom, osnumaddr = &osnum );
        if (geom != my_id)
        {
            om$send ( msg = message GRgraphics.GRdisyourself 
                            ( msg, mx_type, matrix, mode, alt_symb, sp_info, range_key ),
                      targetid = geom, targetos = osnum );
        }
      }
    }
  }

  return OM_S_SUCCESS;
}

end implementation SKpoint;
