/* ###################   APOGEE COMPILED   ################## */
class specification ECtubesur (1:0) of ECelement;

/*
HISTORY

15 May 1989 jBk Removed wakeup override.
*/

instance ECtubesur
{
  IGRdouble lentol;
  IGRint  num_vertices;
  variable IGRdouble vertices[][3];
  variable IGRdouble radii[];
  IGRint curr_inx;
};

override execute,
         wakeup;

end specification ECtubesur;
