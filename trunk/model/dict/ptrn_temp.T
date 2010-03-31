
struct GRptrn_matrix
{
   double   rotation;
   int      rows;
   int      cols;
   double   Xdelta;
   double   Ydelta;
};

struct GRptrn_polar
{
   int         num_copies;
   int         num_sweeps;
   double      start_angle;
   double      sweep_angle;
   double      rotation;
   double      Rdelta;
   double      radius;
}

#template struct GRptrn_matrix matrix_pat_T
#template struct GRptrn_polar polar_pat_T
