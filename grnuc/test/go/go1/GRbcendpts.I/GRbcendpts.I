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
  IGRpoint  startpt, endpt;
  IGRint    sts, i, num_iter;
  IGRlong   status, msg, offset;
  IGRchar   classname[100];
  struct GRmd_env  md_env;
  GRobjid   obj_id = NULL_OBJID;
  struct IGRbsp_curve *cv = NULL;

  in_data = fopen("input/in_endpts", "r");
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
      printf("\n construct_object failed in GRbcendpts.I test \n");
      goto quit;
    }

    status = om$send(msg = message GRbspline.GRendpts(&msg,
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           startpt, endpt),
                     senderid = NULL_OBJID,
                     targetid = obj_id,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n GRbspline.GRendpts failed in GRbcendpts.I test \n");
      goto quit;
    }

    fprintf(tmp_data, "OUTPUT FROM ITERATION NUMBER %d \n", (i + 1) );

    fprintf(tmp_data, "startpt[0] = %lf \n", startpt[0]);
    fprintf(tmp_data, "startpt[1] = %lf \n", startpt[1]);
    fprintf(tmp_data, "startpt[2] = %lf \n", startpt[2]);
    fprintf(tmp_data, "endpt[0] = %lf \n", endpt[0]);
    fprintf(tmp_data, "endpt[1] = %lf \n", endpt[1]);
    fprintf(tmp_data, "endpt[2] = %lf \n", endpt[2]);

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
        printf("\n Root.delete failed in GRbcendpts.I\n");
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
      printf("\n Root.delete failed in GRbcendpts.I\n");
    }

  }

  if (in_data)  fclose(in_data);
  if (tmp_data) fclose(tmp_data);

}

end implementation GRbspline;
