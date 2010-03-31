class implementation EMSsubbs;

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
#include "mdmacros.h"
#include "EMSbnddef.h"

void EMsftancrv_macro()

{
  FILE      *in_data = NULL, *tmp_data = NULL;
  IGRdouble parm_pnt[20][2], crv, near_pnt[MAX_LOCATED_EDGES][2];
  IGRpoint  out_point;
  IGRvector tan[2];
  IGRint    sts, i, j, k, num_iter, num_pnt, loc_flag;
  IGRshort  num_edges;
  unsigned int    crv_type;
  IGRlong   status, msg, offset;
  IGRchar   classname[100];
  struct GRmd_env  md_env;
  struct GRid      GRid_in;
  GRobjid          edge_id[MAX_LOCATED_EDGES], obj_id = NULL_OBJID;
  struct IGRbsp_surface sf;
  extern void BSreadbsps();

  in_data = fopen("input/in_sftancrv", "r");
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
       sts = fscanf(in_data, "%lf", &parm_pnt[j][0]);
       sts = fscanf(in_data, "%lf", &parm_pnt[j][1]);
    }

    offset = ftell(in_data);

    fscanf(in_data, "%s", classname);

    fseek(in_data, offset, 0);

    sf.poles = NULL;
    sf.u_knots = NULL;
    sf.v_knots = NULL;
    sf.weights = NULL;
    sf.bdrys = NULL;
    BSreadbsps(in_data, &sf);

    status = construct_object(&msg, (IGRchar *) &sf, classname, &md_env,
                              &obj_id);
    if (!(1&status))
    {
      printf("\n om$construct failed in TSsftancrv.I test \n");
      goto quit;
    }

    GRid_in.objid = obj_id;
    GRid_in.osnum = md_env.md_id.osnum;

    for ( j = 0; j < num_pnt; j++ )
    {
      crv_type = (j < 6 ? j : 5);
      status = md$get_surf_tan_crv_ptloc(GRid_in = GRid_in,
                                         parm_pnt = &parm_pnt[j][0],
                                         outpoint = out_point,
                                         tan = tan,
                                         crv_type = crv_type,
                                         crv = &crv,
                                         pt_location_flag = &loc_flag,
                                         num_edges = &num_edges,
                                         edge_id = edge_id,
                                         near_pt = near_pnt);

      if (!(1&status))
      {
        printf("\n md$get_surf_tan_crv_ptloc failed in TSsftancrv.I test \n");
        goto quit;
      }

      fprintf(tmp_data, "OUTPUT FROM ITERATION NUMBER %d \n", (i + 1) );

      fprintf(tmp_data, "%d) outpoint[0] = %lf \n", j+1, out_point[0]);
      fprintf(tmp_data, "%d) outpoint[1] = %lf \n", j+1, out_point[1]);
      fprintf(tmp_data, "%d) outpoint[2] = %lf \n", j+1, out_point[2]);

      fprintf(tmp_data, "%d) utan[0] = %lf \n", j+1, tan[0][0]);
      fprintf(tmp_data, "%d) utan[1] = %lf \n", j+1, tan[0][1]);
      fprintf(tmp_data, "%d) utan[2] = %lf \n", j+1, tan[0][2]);

      fprintf(tmp_data, "%d) vtan[0] = %lf \n", j+1, tan[1][0]);
      fprintf(tmp_data, "%d) vtan[1] = %lf \n", j+1, tan[1][1]);
      fprintf(tmp_data, "%d) vtan[2] = %lf \n", j+1, tan[1][2]);

      fprintf(tmp_data, "%d) curvature = %lf \n", j+1, crv);

      fprintf(tmp_data, "%d) location flag = %d \n", j+1, loc_flag);

      fprintf(tmp_data, "%d) number of edges = %d \n", j+1, num_edges);

      for ( k = 0; k < num_edges; k++ )
      {
        fprintf(tmp_data, "%d) near_pnt[%d][0] = %lf \n", j+1, k,
                near_pnt[k][0]);
        fprintf(tmp_data, "%d) near_pnt[%d][1] = %lf \n", j+1, k,
                near_pnt[k][1]);
      }

    }  /* end for j loop */

    if (obj_id != NULL_OBJID)
    {
      status = om$send(msg = message Root.delete(1),
                       senderid = NULL_OBJID,
                       targetid = obj_id,
                       targetos = md_env.md_id.osnum);
      if (!(1&status))
      {
        printf("\n Root.delete failed in TSsftancrv.I\n");
      }

      obj_id = NULL_OBJID;
    }

  }  /* end for loop */


quit:
  if (obj_id != NULL_OBJID)
  {
    status = om$send(msg = message Root.delete(1),
                     senderid = NULL_OBJID,
                     targetid = obj_id,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n Root.delete failed in TSsftancrv.I\n");
    }

  }

  if (in_data)  fclose(in_data);
  if (tmp_data) fclose(tmp_data);

}

end implementation EMSsubbs;
