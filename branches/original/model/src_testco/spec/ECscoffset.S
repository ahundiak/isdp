/* ###################   APOGEE COMPILED   ################## */
class specification ECscoffset(1:0) of ECelement;


instance ECscoffset
  {
  IGRdouble               dist1,dist2;
  IGRpoint                pt_on_crv;
  struct    GRid          curv;
  struct    GRid          surf;
  IGRpoint                off_dirpt;  
  IGRboolean              is_linear; 
  IGRboolean              is_not_uniform;
  IGRboolean              right_side;
  IGRvector               vector;
 };

override init, sleep, execute;

end specification ECscoffset;    
