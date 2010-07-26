class implementation GRcurve;

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
#include "grmacros.h"
#include "bserr.h"


void GRcvtancrv_macro()

{
  FILE  *in_data = NULL, *tmp_data = NULL;
  IGRdouble uparm[20], radcrv;
  IGRpoint  out_point;
  IGRvector tan;
  IGRint    sts, i, j, num_iter, num_pnt;
  IGRlong   status, msg, offset;
  IGRchar   classname[100];
  struct GRmd_env  md_env;
  struct GRid      GRid_in;
  GRobjid   obj_id = NULL_OBJID;
  struct IGRbsp_curve *cv = NULL;

  in_data = fopen("input/in_tancrv", "r");
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
    sts = fscanf(in_data, "%d", &num_pnt);

    for (j = 0; j < num_pnt; j++)
    {
       sts = fscanf(in_data, "%lf", &uparm[j]);
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
      printf("\n om$construct failed in TScvtancrv.I test \n");
      goto quit;
    }

    GRid_in.objid = obj_id;
    GRid_in.osnum = md_env.md_id.osnum;

    for ( j = 0; j < num_pnt; j++ )
    {
      status = gr$get_curve_tan_radcrv(GRid_in = GRid_in,
                                       uparm = uparm[j],
                                       outpoint = out_point,
                                       tan = tan,
                                       radcrv = &radcrv);
      if (!(1&status))
      {
        printf("\n gr$get_curve_tan_radcrv failed in TScvtancrv.I test \n");
        goto quit;
      }

      fprintf(tmp_data, "OUTPUT FROM ITERATION NUMBER %d \n", (i + 1) );

      fprintf(tmp_data, "%d) outpoint[0] = %lf \n", j+1, out_point[0]);
      fprintf(tmp_data, "%d) outpoint[1] = %lf \n", j+1, out_point[1]);
      fprintf(tmp_data, "%d) outpoint[2] = %lf \n", j+1, out_point[2]);

      fprintf(tmp_data, "%d) tan[0] = %lf \n", j+1, tan[0]);
      fprintf(tmp_data, "%d) tan[1] = %lf \n", j+1, tan[1]);
      fprintf(tmp_data, "%d) tan[2] = %lf \n", j+1, tan[2]);

      fprintf(tmp_data, "%d) radius of curvature = %lf \n", j+1, radcrv);

    }  /* end for j loop */

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
        printf("\n Root.delete failed in TScvtancrv.I\n");
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
      printf("\n Root.delete failed in TScvtancrv.I\n");
    }

  }

  if (in_data)  fclose(in_data);
  if (tmp_data) fclose(tmp_data);

}

end implementation GRcurve;
