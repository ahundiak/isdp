class implementation GRbspline;

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
  IGRdouble dist[20], *point;
  IGRpoint  startpt, endpt, newend;
  IGRint    sts, i, j, num_iter, num_dist;
  IGRlong   status, msg, offset;
  IGRchar   classname[100];
  struct GRmd_env  md_env;
  GRobjid   obj_id = NULL_OBJID;
  struct IGRbsp_curve *cv = NULL;

  in_data = fopen("input/in_dist", "r");
  if (!in_data)
  {
    printf("\n no input data file \n");
    goto quit;
  }

  if ( (tmp_data = fopen("output/masterout", "r")) != NULL )
    tmp_data = fopen("output/newout", "w");
  else
    tmp_data = fopen("output/masterout", "w");

  fscanf(in_data, "%d", &num_iter);

  for (i = 0; i < num_iter; i++)
  {
    fscanf(in_data, "%d", &num_dist);

    for (j = 0; j < num_dist; j++)
       fscanf(in_data, "%lf", &dist[j]);
 
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
    if (!(1&status))
    {
      printf("\n construct_object failed in GRbcdisexten.I test \n");
      goto quit;
    }

    status = om$send(msg = message GRcurve.GRendpts(&msg, 
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           startpt, endpt),
                     senderid = NULL_OBJID,
                     targetid = obj_id,
                     targetos = md_env.md_id.osnum);

    for (j = 0; j < num_dist; j++)
    {
      point = ( (j&1) ? &startpt[0] : &endpt[0] );

      status = om$send(msg = message GRbspline.GRdisextend(&msg, &md_env,
                             point, &dist[j], newend),
                       senderid = NULL_OBJID,
                       targetid = obj_id,
                       targetos = md_env.md_id.osnum);
      if (!(1&status))
      {
        printf("\n GRbspline.GRdisextend failed in GRbcdisexten.I test \n");
        goto quit;
      }

      fprintf(tmp_data, "OUTPUT FROM ITERATION NUMBER %d \n", (i + 1) );

      fprintf(tmp_data, "%d) newend[0] = %lf \n", j+1, newend[0]);
      fprintf(tmp_data, "%d) newend[1] = %lf \n", j+1, newend[1]);
      fprintf(tmp_data, "%d) newend[2] = %lf \n", j+1, newend[2]);

    }

    if (cv)
    {
      BSfreecv(&sts, cv);
      cv = NULL;
    }

    if (obj_id != NULL_OBJID)
    {
      status = om$send(msg = message Root.delete(1),
                       senderid = NULL_OBJID,
                       targetid = obj_id,
                       targetos = md_env.md_id.osnum);
      if (!(1&status))
      {
        printf("\n Root.delete failed in GRbcdisexten.I\n");
      }

      obj_id = NULL_OBJID;
    }

  }  /* end for loop */


quit:
  if (cv)   BSfreecv(&sts, cv);

  if (obj_id != NULL_OBJID)
  {
    status = om$send(msg = message Root.delete(1),
                     senderid = NULL_OBJID,
                     targetid = obj_id,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n Root.delete failed in GRbcdisexten.I\n");
    }

  }

  if (in_data)  fclose(in_data);
  if (tmp_data) fclose(tmp_data);

}

end implementation GRbspline;
