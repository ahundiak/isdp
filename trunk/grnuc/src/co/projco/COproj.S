class specification COproj (1:0) of COdpb, COtools, CEO_GSLOCATE;




instance COproj
{
    struct GRid                 from_id;
    IGRdouble                   from_matrix[16];
    IGRdouble                   from_origin[3];
    IGRdouble                   from_normal[3];
    
    struct GRid                 to_id;    
    IGRdouble                   to_matrix[16];
    IGRdouble                   to_origin[3];
    IGRdouble                   to_normal[3];
    
    IGRint                      project_state;
    IGRdouble                   t_matrix[16];
    IGRdouble                   p_matrix[16];
        
    IGRint                      num_objects;
    struct GRlc_info            * objects;

    IGRint                      num_points;
    variable IGRdouble          points[20][3];
};


override arg_name_to_value;

message gather_leaf_objects (IGRint * msg);

message store_view_info (IGRint * msg; IGRint type; struct GRevent * event);

message extract_points (IGRint * msg);

message transform_elements (IGRint * msg);

message project_points (IGRint * msg);

message free_buffer ( IGRchar * buffer );

end specification COproj;
