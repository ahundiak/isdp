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


void main ()
{
  FILE  *in_data = NULL, *tmp_data = NULL;
  IGRpoint  pt1, pt2;
  IGRshort  num;
  IGRint    sts, i, num_par, num_iter;
  IGRlong   status, msg, size, offset;
  IGRchar   name;
  IGRchar   classname[100];
  struct GRparms  p1, p2;
  struct GRmd_env  md_env;
  GRobjid   c1 = NULL_OBJID, c2 = NULL_OBJID, obj_id = NULL_OBJID;
  struct IGRbsp_curve *cv = NULL, *cv1 = NULL, *cv2 = NULL;

  in_data = fopen("input/2partdel", "r");
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
    sts = fscanf(in_data, "%lf", &pt1[0]);
    sts = fscanf(in_data, "%lf", &pt1[1]);
    sts = fscanf(in_data, "%lf", &pt1[2]);
    sts = fscanf(in_data, "%lf", &pt2[0]);
    sts = fscanf(in_data, "%lf", &pt2[1]);
    sts = fscanf(in_data, "%lf", &pt2[2]);

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
      printf("\n construct_object failed in GRbc2ptpartd.I test \n");
      goto quit;
    }

    status = om$send(msg = message GRvg.EMpratpt(&msg,
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           pt1, &p1.u, &num_par),
                     senderid = NULL_OBJID,
                     targetid = obj_id,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n GRvg.EMpratpt failed in GRbc2ptpartd.I test \n");
      goto quit;
    }

    status = om$send(msg = message GRvg.EMpratpt(&msg,
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           pt2, &p2.u, &num_par),
                     senderid = NULL_OBJID,
                     targetid = obj_id,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n GRvg.EMpratpt failed in GRbc2ptpartd.I test \n");
      goto quit;
    }

    status = om$send(msg = message GRbspline.GR2ptpartdel(&msg, &md_env, pt1,
                           pt2, &p1, &p2, &c1, &c2, &num),
                     senderid = NULL_OBJID,
                     targetid = obj_id,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n GRbspline.GR2ptpartdel failed in GRbc2ptpartd.I test \n");
      goto quit;
    }

    fprintf(tmp_data, "OUTPUT FROM ITERATION NUMBER %d \n", (i + 1) );

    fprintf(tmp_data, "num of objects = %d \n", num);

    if (c1 != NULL_OBJID)
    {
      status = om$send(msg = message GRbspline.GRgetsize(&msg,
                             &md_env.md_env.matrix_type,
                             md_env.md_env.matrix, &size),
                       senderid = NULL_OBJID,
                       targetid = c1,
                       targetos = md_env.md_id.osnum);

      cv1 = (struct IGRbsp_curve *) om$malloc(size = size);

      status = om$send(msg = message GRbspline.GRgetgeom(&msg,
                             &md_env.md_env.matrix_type,
                             md_env.md_env.matrix, (IGRchar *) cv1),
                       senderid = NULL_OBJID,
                       targetid = c1,
                       targetos = md_env.md_id.osnum);

      BSprintbspc(tmp_data, &name, cv1, FALSE);
    }

    if (c2 != NULL_OBJID)
    {
      status = om$send(msg = message GRbspline.GRgetsize(&msg,
                             &md_env.md_env.matrix_type,
                             md_env.md_env.matrix, &size),
                       senderid = NULL_OBJID,
                       targetid = c2,
                       targetos = md_env.md_id.osnum);

      cv2 = (struct IGRbsp_curve *) om$malloc(size = size);

      status = om$send(msg = message GRbspline.GRgetgeom(&msg,
                             &md_env.md_env.matrix_type,
                             md_env.md_env.matrix, (IGRchar *) cv2),
                       senderid = NULL_OBJID,
                       targetid = c2,
                       targetos = md_env.md_id.osnum);

      BSprintbspc(tmp_data, &name, cv2, FALSE);
    }

    if (cv)
    {
      BSfreecv(&sts, cv);
      cv = NULL;
    }

    if (cv1)
    {
      om$dealloc(ptr = cv1);
      cv1 = NULL;
    }

    if (cv2)
    {
      om$dealloc(ptr = cv2);
      cv2 = NULL;
    }

    if (c1 != NULL_OBJID)
    {
      status = om$send(msg = message Root.delete(1),
                       senderid = NULL_OBJID,
                       targetid = c1,
                       targetos = md_env.md_id.osnum);
      if (!(1&status))
      {
        printf("\n Root.delete failed in GRbc2ptpartd.I\n");
      }

      c1 = NULL_OBJID;
    }

    if (c2 != NULL_OBJID)
    {
      status = om$send(msg = message Root.delete(1),
                       senderid = NULL_OBJID,
                       targetid = c2,
                       targetos = md_env.md_id.osnum);
      if (!(1&status))
      {
        printf("\n Root.delete failed in GRbc2ptpartd.I\n");
      }

      c2 = NULL_OBJID;
    }

    if (obj_id != NULL_OBJID)
    {
      status = om$send(msg = message Root.delete(1),
                       senderid = NULL_OBJID,
                       targetid = obj_id,
                       targetos = md_env.md_id.osnum);
      if (!(1&status))
      {
        printf("\n Root.delete failed in GRbc2ptpartd.I\n");
      }

      obj_id = NULL_OBJID;
    }

  }  /* end for loop */



quit:
  if (cv)   BSfreecv(&sts, cv);
  if (cv1)  om$dealloc(ptr = cv1);
  if (cv2)  om$dealloc(ptr = cv2);

  if (c1 != NULL_OBJID)
  {
    status = om$send(msg = message Root.delete(1),
                     senderid = NULL_OBJID,
                     targetid = c1,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n Root.delete failed in GRbc2ptpartd.I\n");
    }
  }

  if (c2 != NULL_OBJID)
  {
    status = om$send(msg = message Root.delete(1),
                     senderid = NULL_OBJID,
                     targetid = c2,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n Root.delete failed in GRbc2ptpartd.I\n");
    }
  }

  if (obj_id != NULL_OBJID)
  {
    status = om$send(msg = message Root.delete(1),
                     senderid = NULL_OBJID,
                     targetid = obj_id,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n Root.delete failed in GRbc2ptpartd.I\n");
    }

  }

  if (in_data)   fclose(in_data);

  if (tmp_data)  fclose(tmp_data);
}

end implementation GRbspline;
