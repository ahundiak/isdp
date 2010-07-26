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
  IGRpoint  center;
  IGRint    sts, num, i, j, num_iter;
  IGRlong   status, msg, offset;
  IGRchar   classname[100];
  struct GRmd_env  md_env;
  struct GRparms   *p = NULL;
  GRobjid   obj_id = NULL_OBJID;
  struct IGRbsp_curve *cv = NULL;

  in_data = fopen("input/in_cent", "r");
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
    fscanf(in_data, "%d", &num);

    p = (struct GRparms *) om$malloc(size = (sizeof(struct GRparms) * num) );

    for (j = 0; j < num; j++)
      fscanf(in_data, "%lf", &p[j].u);

    offset = ftell(in_data);

    fscanf(in_data, "%s", classname);

    fseek(in_data, offset,  0);

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
      printf("\n construct_object failed in GRbccentcurv.I test \n");
      goto quit;
    }

    fprintf(tmp_data, "OUTPUT FROM ITERATION NUMBER %d \n", (i + 1) );

    for (j = 0; j < num; j++)
    {
      status = om$send(msg = message GRbspline.GRcentcurv(&msg,
                             &md_env.md_env.matrix_type, md_env.md_env.matrix,
                             &p[j], center),
                       senderid = NULL_OBJID,
                       targetid = obj_id,
                       targetos = md_env.md_id.osnum);
      if (!(1&status))
      {
        printf("\n GRbspline.GRcentcurv failed in GRbccentcurv.I test \n");
        goto quit;
      }

      fprintf(tmp_data, "%d center[0] = %lf \n", j, center[0]);
      fprintf(tmp_data, "%d center[1] = %lf \n", j, center[1]);
      fprintf(tmp_data, "%d center[2] = %lf \n", j, center[2]);
    }

    if (cv)
    {
      BSfreecv(&sts, cv);
      cv = NULL;
    }

    if (p)
    {
      om$dealloc(ptr = p);
      p = NULL;
    }

    if (obj_id != NULL_OBJID)
    {
      status = om$send(msg = message Root.delete(1),
                       senderid = NULL_OBJID,
                       targetid = obj_id,
                       targetos = md_env.md_id.osnum);
      if (!(1&status))
      {
        printf("\n Root.delete failed in GRbccentcurv.I\n");
      }

      obj_id = NULL_OBJID; 
    }

  }  /* end for loop */


quit:
  if (cv)   BSfreecv(&sts, cv);
  if (p)    om$dealloc(ptr = p);

  if (obj_id != NULL_OBJID)
  {
    status = om$send(msg = message Root.delete(1),
                     senderid = NULL_OBJID,
                     targetid = obj_id,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n Root.delete failed in GRbccentcurv.I\n");
    }

  }

  if (in_data)  fclose(in_data);
  if (tmp_data) fclose(tmp_data);

}

end implementation GRbspline;
