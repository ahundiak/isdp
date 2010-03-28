 struct GRxhatchln
   {
      struct   IGRdisplay  line_symbology; 
      IGRdouble            perp_dist_next_line;
   };

 struct GRxhatchpass
   {
      IGRdouble            angle;
      IGRshort             num_lines;
      struct GRxhatchln    lines[9];
   };

 struct GRxhatchpat
   {
      IGRchar               descrip_of_pattern[80];
      IGRint                num_angles;
      IGRshort              level;
      struct GRxhatchpass   pass[3];
   };

