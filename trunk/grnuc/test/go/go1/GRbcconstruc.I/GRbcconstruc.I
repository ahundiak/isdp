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
  IGRint    sts, i, num_iter;
  IGRlong   status, msg, offset;
  IGRchar   classname[100];
  struct GRmd_env  md_env;
  GRobjid   obj_id = NULL_OBJID;
  struct IGRbsp_curve *cv = NULL;
  struct GRvg_construct const_list;
  struct IGRdisplay  display_attr;

  in_data = fopen("input/in_const", "r");
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

    gr$get_module_env(buffer = &md_env);

    display_attr.color = 1;
    display_attr.weight = 0;
    display_attr.style = 0;

    const_list.level = 1;
    const_list.properties = GRIS_NEW;
    const_list.name = 0;
    const_list.display = &display_attr;
    const_list.class_attr = 0;
    const_list.newflag = FALSE;
    const_list.msg = &msg;
    const_list.env_info = &md_env;
    const_list.geometry = (IGRchar *) cv;

    status = om$construct(osnum = md_env.md_id.osnum,
                        classname = classname,
                        p_objid = &obj_id);
    if (!(1&status))
    {
      printf("\n om$construct failed in GRbcconstruc.I test \n");
      goto quit;
    }

    status = om$send(msg = message GRgraphics.GRconstruct(&const_list),
                     senderid = NULL_OBJID,
                     targetid = obj_id,
                     targetos = md_env.md_id.osnum);
    if (!(1&status))
    {
      printf("\n GRbspline.GRconstruct failed in GRbcconstruc.I test \n");
      goto quit;
    }

    fprintf(tmp_data, "OUTPUT FROM ITERATION NUMBER %d \n", (i + 1) );

    fprintf(tmp_data, "msg = %lx \n", const_list.msg[0]);

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
        printf("\n Root.delete failed in GRbcconstruc.I\n");
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
      printf("\n Root.delete failed in GRbcconstruc.I\n");
    }

  }

  if (in_data)  fclose(in_data);
  if (tmp_data) fclose(tmp_data);

}

end implementation GRbspline;
