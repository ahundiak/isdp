class specification COtxalel (1:0) of COtext;




instance COtxalel
{
IGRint              num_pts;          /* # of origins and matrices */
IGRint              out_flags;
IGRint              text_direction;   /* 1 -> preferred direction,
                                         0 -> opposite direction   */
IGRpoint            side_pt;
variable IGRpoint   text_origin[];
variable IGRmatrix  orient_matrix[];
variable IGRchar    curve_memory[];
struct IGRbsp_curve *curve_ptr;
};


override wakeup;

override get_construct_attr;

message save_point1 ();

message save_side_point ();

message put_pt_on_queue ();

message construct_text_along ();

message get_curve_geom ();

message get_text_along (int preferred_dir);

message erase_highlight ();

message highlight_text_along ();

end specification COtxalel;
