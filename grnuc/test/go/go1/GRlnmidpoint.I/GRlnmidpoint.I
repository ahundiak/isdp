class implementation GRlinear;

#include <stdio.h>
#include <stdlib.h>
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "bserr.h"


void main()

{
  FILE  *in_data = NULL, *tmp_data = NULL;
  IGRpoint  midpoint;
  IGRint    sts, i, j, num_iter, num_par;
  IGRlong   status, msg, offset;
  IGRchar   classname[100];
  struct GRparms  p1[20];
  struct GRmd_env  md_env;
  GRobjid   obj_id = NULL_OBJID;
  struct IGRbsp_curve *cv = NULL;
  extern void   BSreadcv();


  in_data = fopen("input/in_lnmidpoint", "r");
  if (!in_data)
  {
    printf("\n no input data file \n");
    goto quit;
  }

  if ( (tmp_data = fopen("output/masterout", "r")) != NULL )
    tmp_data = fopen("output/newout", "w");
  else
    tmp_data = fopen("output/masterout", "w");

  sts = fscanf(in_data, "%d", &num_iter);

  for (i = 0; i < num_iter; i++)
  {
    fscanf(in_data, "%d", &num_par);

    for (j = 0; j < num_par; j++)
       fscanf(in_data, "%lf", &p1[j].u);

    offset = ftell(in_data);

    fscanf(in_data, "%s", classname);

    fseek(in_data, offset, 0);

    BSreadcv(in_data, &cv, &sts);
    if ( BSERROR(sts) )
    {
      printf("\n error reading in the curve structure \n");
      goto quit;
    }

    status = construct_object(&msg, (IGRchar *) cv, classname, &md_env,
                              &obj_id);
    if (!(1 & status & msg))
    {
      printf("\n construct_object failed in GRlnmidpoint.I test \n");
      goto quit;
    }

    for (j = 0; j < num_par; j++)
    {
      status = om$send(msg = message GRlinear.GRmidpoint(&msg,
                             &md_env.md_env.matrix_type, md_env.md_env.matrix,
                             &p1[j], midpoint),
                       senderid = NULL_OBJID,
                       targetid = obj_id,
                       targetos = md_env.md_id.osnum);
      if (!(1&status))
      {
        printf("\n GRlinear.GRmidpoint failed in GRlnmidpoint.I test \n");
        goto quit;
      }

      fprintf(tmp_data, "OUTPUT FROM ITERATION NUMBER %d \n", (i + 1) );

      fprintf(tmp_data, "%d) midpoint[0] = %g \n", (j+1), midpoint[0]);
      fprintf(tmp_data, "%d) midpoint[1] = %g \n", (j+1), midpoint[1]);
      fprintf(tmp_data, "%d) midpoint[2] = %g \n", (j+1), midpoint[2]);

    }  /* end for j loop */

    if (cv)
    {
      BSfreecv(&sts, cv);
      cv = NULL;
    }

  }  /* end for loop */



quit:
  if (cv)   BSfreecv(&sts, cv);

  if (in_data)   fclose(in_data);

  if (tmp_data)  fclose(tmp_data);

}

end implementation GRlinear;
