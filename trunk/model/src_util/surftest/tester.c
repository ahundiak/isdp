/*
HISTORY

 Big Bang	: Creation

 02/09/92  NP	: The function call "EFfix_the_intersections" had an argument
                  missing ("remove_the_edges" argument). I am passing a FALSE
                  for this argument (better than no argument?). Also, changed 
                  the name of this function to "EFfix_the_int". The function
                  name was changed to reflect the addition of another argument.
               

*/
#include <stdio.h>

/* include "igr.h"*/

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */
/* include "gr.h"*/

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

/* end of gr.h replacement */
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSbnddef.h"

main()
{
  IGRchar filename[20];
  IGRboolean stat_func;
  IGRint i, j, num_grps, *numpts_grp, msg_loc;
  IGRdouble **xyzpts, **myuvpts, **otuvpts;
  struct IGRbsp_surface srf1, srf2;
  FILE *fileptr;
  IGRboolean EFfix_the_int();

  printf ("Surface file 1: \n");
  scanf ("%s", filename);
  fileptr = fopen (filename, "r");
  srf1.poles = 0;
  srf1.u_knots = 0;
  srf1.v_knots = 0;
  srf1.weights = 0;
  srf1.bdrys = 0;
  BSreadbsps (fileptr, &srf1);
  fclose (fileptr);

  printf ("Surface file 2: \n");
  scanf ("%s", filename);
  fileptr = fopen (filename, "r");
  srf2.poles = 0;
  srf2.u_knots = 0;
  srf2.v_knots = 0;
  srf2.weights = 0;
  srf2.bdrys = 0;
  BSreadbsps (fileptr, &srf2);
  fclose (fileptr);

  printf ("num groups\n");
  scanf ("%d", &num_grps);
  numpts_grp = (int *) malloc (num_grps * sizeof (int));
  xyzpts = (double **) malloc (num_grps * sizeof (double *));
  myuvpts = (double **) malloc (num_grps * sizeof (double *));
  otuvpts = (double **) malloc (num_grps * sizeof (double *));
  
  printf ("xyz pts file\n");
  scanf ("%s", filename);
  fileptr = fopen (filename, "r");
  for (i=0; i<num_grps; i++)
    {
    fscanf (fileptr, "%d", &numpts_grp[i]);
    xyzpts[i] = (double *) malloc (numpts_grp[i] * 3 * sizeof (double));
    for (j=0; j<numpts_grp[i]*3; j+=3)
      fscanf (fileptr, "%lf %lf %lf", &xyzpts[i][j], &xyzpts[i][j+1], 
       &xyzpts[i][j+2]);
    }
  fclose (fileptr);

  printf ("myuv pts file\n");
  scanf ("%s", filename);
  fileptr = fopen (filename, "r");
  for (i=0; i<num_grps; i++)
    {
    fscanf (fileptr, "%d", &numpts_grp[i]);
    myuvpts[i] = (double *) malloc (numpts_grp[i] * 2 * sizeof (double));
    for (j=0; j<numpts_grp[i]*2; j+=2)
      fscanf (fileptr, "%lf %lf", &myuvpts[i][j], &myuvpts[i][j+1]);
    }
  fclose (fileptr);

  printf ("otuv pts file\n");
  scanf ("%s", filename);
  fileptr = fopen (filename, "r");
  for (i=0; i<num_grps; i++)
    {
    fscanf (fileptr, "%d", &numpts_grp[i]);
    otuvpts[i] = (double *) malloc (numpts_grp[i] * 2 * sizeof (double));
    for (j=0; j<numpts_grp[i]*2; j+=2)
      fscanf (fileptr, "%lf %lf", &otuvpts[i][j], &otuvpts[i][j+1]);
    }
  fclose (fileptr);

  stat_func = EFfix_the_int (NULL, FALSE, &srf1, &srf2, &num_grps, &numpts_grp,
               &xyzpts, &myuvpts, &otuvpts, &msg_loc);
  printf ("stat func %d\n", stat_func);
  printf ("msg_loc  0x%x\n", msg_loc);
}
