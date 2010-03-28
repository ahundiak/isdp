#ifndef grascopy_h
#define grascopy_h

#define  GR_ASCOPY_SINGLE                   1
#define  GR_ASCOPY_LINEAR                   2
#define  GR_ASCOPY_RECTANGULAR              3
#define  GR_ASCOPY_POLAR                    4
#define  GR_ASCOPY_LINEAR                   5

struct GRptrn_single
{
	double rotation;
};

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
   int 	       num_sweeps;
   double      start_angle;
   double      sweep_angle;
   double      rotation;
   double      Rdelta;
   double      radius;
};

struct GRptrn_along_ele
{
   int          num_copies;
   double       rotation;
   double       start_uparm;
   double       end_uparm;
};

struct GRas_pattern
{
   int type;
   union 
   {
        struct GRptrn_single      single;      
        struct GRptrn_matrix      matrix;      
        struct GRptrn_polar       polar;      
        struct GRptrn_along_ele   linear;
   } var;
};

#endif
