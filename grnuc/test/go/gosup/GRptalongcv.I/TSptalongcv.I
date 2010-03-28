class implementation GRcurve;

#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grmacros.h"
#include "bserr.h"


void GRptalongcv_macro()

{
  FILE  *in_data = NULL, *tmp_data = NULL;
  IGRdouble dist[20], *uparm = NULL, *out_point = NULL;
  IGRpoint  dirpoint;
  IGRint    sts, i, j, flag = 0, num_iter, num_dist;
  IGRlong   status, msg, offset;
  IGRchar   classname[100];
  struct GRmd_env  md_env;
  struct GRid      GRid_in, *cmp_id = NULL;
  GRobjid   obj_id = NULL_OBJID;
  struct IGRbsp_curve *cv = NULL;

  in_data = fopen("input/in_ptalong", "r");
  if (!in_data)
  {
    printf("/n no input data file \n");
    goto quit;
  }

  if ( (tmp_data = fopen("output/masterout", "r")) != NULL )
    tmp_data = fopen("output/newout", "w");
  else
    tmp_data = fopen("output/masterout", "w");
  
  sts = fscanf(in_data, "%d", &num_iter);

  for (i = 0; i < num_iter; i++)
  {
    sts = fscanf(in_data, "%lf", &dirpoint[0]);
    sts = fscanf(in_data, "%lf", &dirpoint[1]);
    sts = fscanf(in_data, "%lf", &dirpoint[2]);

    sts = fscanf(in_data, "%d", &num_dist);

    for (j = 0; j < num_dist; j++)
    {
       sts = fscanf(in_data, "%lf", &dist[j]);
    }

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
      printf("\n om$construct failed in GRptalongcv.I test \n");
      goto quit;
    }

    GRid_in.objid = obj_id;
    GRid_in.osnum = md_env.md_id.osnum;

    uparm = (IGRdouble *) om$malloc(size = sizeof(IGRdouble) * num_dist);

    out_point = (IGRdouble *) om$malloc(size = sizeof(IGRdouble) *
                                                num_dist * 3);

    cmp_id = (struct GRid *) om$malloc(size = sizeof(struct GRid) * num_dist);

    flag = (flag ? 0 : 1);
    status = gr$point_along_curve(GRid_in = GRid_in,
                                  endflag = flag,
                                  dirpoint = dirpoint,
                                  num = num_dist,
                                  dist = dist,
                                  uparm = uparm,
                                  outpoint = out_point,
                                  cmp_id = cmp_id);
    if (!(1&status))
    {
      printf("\n gr$point_along_curve failed in GRptalongcv.I test \n");
      goto quit;
    }

    fprintf(tmp_data, "OUTPUT FROM ITERATION NUMBER %d \n", (i + 1) );

    for ( j = 0; j < num_dist; j++ )
    {
      fprintf(tmp_data, "%d) uparm = %lf \n", j+1, uparm[j]);
      fprintf(tmp_data, "%d) outpoint[0] = %lf \n", j+1, out_point[j*3]);
      fprintf(tmp_data, "%d) outpoint[1] = %lf \n", j+1, out_point[(j*3)+1]);
      fprintf(tmp_data, "%d) outpoint[2] = %lf \n", j+1, out_point[(j*3)+2]);

    }  /* end for j loop */

    if (cv)
    {
      BSfreecv(&sts, cv);
      cv = NULL;
    }

    if (uparm)
    {
      om$dealloc(ptr = uparm);
      uparm = NULL;
    }

    if (out_point)
    {
      om$dealloc(ptr = out_point);
      out_point = NULL;
    }

    if (cmp_id)
    {
      om$dealloc(ptr = cmp_id);
      cmp_id = NULL;
    }

    if (obj_id != NULL_OBJID)
    {
      status = om$send(msg = message Root.delete(1),
                       senderid = NULL_OBJID,
                       targetid = obj_id,
                       targetos = md_env.md_id.osnum);
      if (!(1&status))
      {
        printf("\n Root.delete failed in GRptalongcv.I\n");
      }

      obj_id = NULL_OBJID;
    }

  }  /* end for loop */


quit:
  if (cv)   BSfreecv(&sts, cv);

  if (uparm)
    om$dealloc(ptr = uparm);

  if (out_point)
    om$dealloc(ptr = out_point);

  if (cmp_id)
    om$dealloc(ptr = cmp_id);

  if (obj_id != NULL_OBJID)
  {
    status = om$send(msg = message Root.delete(1),
                     senderid = NULL_OBJID,
                     targetid = obj_id,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n Root.delete failed in GRptalongcv.I\n");
    }

  }

  if (in_data)  fclose(in_data);
  if (tmp_data) fclose(tmp_data);

}

end implementation GRcurve;
