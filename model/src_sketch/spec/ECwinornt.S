/* ###################   APOGEE COMPILED   ################## */
class specification ECwinornt (2:0) of ECelements;

instance ECwinornt
  { 
  IGRpoint origpt;
  IGRvector zvec;
  IGRboolean planar_ele;
  IGRpoint xaxis_pt1, xaxis_pt2;
  IGRvector xvec;
  };

override get_locate_criteria, execute;

end specification ECwinornt;

