class implementation DEso;

#include <stdio.h>
#include <memory.h>
#include <limits.h>
#include <sys/types.h>
#include <alloca.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "DEso.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "madef.h"
#include "refdef.h"
#include "ref.h"

#include "DEsomacros.h"

#define MIN_X -1300.0
#define MIN_Y -1000.0

#define MAX_X 1300.0
#define MAX_Y 1000.0

from GRcontext import GRgetmodule_env;


main ()
/*
   Call all the test routines for symbology override.
*/
{
  long              msg;
  int               status, master;
  char              my_file [DI_PATH_MAX];
  struct GRmd_env   md_env;
  struct IGRdisplay symb;
  struct IGRlbsys   lbsys;
  FILE              *fet;
  struct GRid       ref_id;
  
  /* we need to create the reference file (save the current file as f1) */
  ex$filename ( name = my_file, len = DI_PATH_MAX );
  status = ex$save_module ( ftype = EX_visible,
                            filename = my_file, 
                            newfilename = "f1" ) ;
  if (status != 1)
  {
    fprintf ( stderr, "CANNOT save module as f1\n" );
    return 0;
  }
  
  /* first attach the reference file */
  ex$get_cur_mod ( id = &md_env.md_id.objid, 
                   osnum = &md_env.md_id.osnum );
  md_env.md_env.matrix_type = MAIDMX;
  symb.color = 0;
  symb.style = 0;
  symb.weight = 0;
  lbsys.matrix [0] = 1.0; lbsys.matrix [1] = 0.0; lbsys.matrix [2] = 0.0;
  lbsys.matrix [3] = -3600.0; 
  lbsys.matrix [4] = 0.0; lbsys.matrix [5] = 1.0; lbsys.matrix [6] = 0.0; 
  lbsys.matrix [7] = 1300.0; 
  lbsys.matrix [8] = 0.0; lbsys.matrix [9] = 0.0; lbsys.matrix [10] = 1.0; 
  lbsys.matrix [11] = 0.0; 
  lbsys.matrix [12] = 0.0; lbsys.matrix [13] = 0.0; lbsys.matrix [14] = 0.0; 
  lbsys.matrix [15] = 1.0;

  GRattach_file ( &msg, &ref_id, "f1", &md_env, &symb, 0, 0, "window", "1", &lbsys );
  if (msg == MSSUCC)
  {
    lbsys.matrix [3] = 2600.0; 
    lbsys.matrix [7] = 1300.0; 
    GRattach_file ( &msg, &ref_id, "f1", &md_env, &symb, 0, 0, "window", "1", &lbsys );
    if (msg == MSSUCC)
    {    
      lbsys.matrix [3] = 2600.0; 
      lbsys.matrix [7] = -1300.0; 
      GRattach_file ( &msg, &ref_id, "f1", &md_env, &symb, 0, 0, "window", "1", &lbsys );
      if (msg == MSSUCC)
      {    
        lbsys.matrix [3] = -2600.0; 
        lbsys.matrix [7] = -1300.0; 
        GRattach_file ( &msg, &ref_id, "f1", &md_env, &symb, 0, 0, "window", "1", &lbsys );
        if (msg == MSSUCC)
        {    
          DEtst_ref_place ( 200 );
          DEtst_ref_linestr ( 200 );
          DEtst_ref_arc ( 200 );
          DEtst_ref_modify ();
          DEtst_ref_retrieve ( 200 );
        }
        else
         printf ( "%s at %d: cannot attach reference file\n", __FILE__, __LINE__ );
      }
      else
        printf ( "%s at %d: cannot attach reference file\n", __FILE__, __LINE__ );
    }
    else
      printf ( "%s at %d: cannot attach reference file\n", __FILE__, __LINE__ );
  }
  else
    printf ( "%s at %d: cannot attach reference file\n", __FILE__, __LINE__ );

  /* we need to delete f1 */
  unlink ( "f1" );

  /* as a final test, we dump the SO table into masterout/newout */
  if (fet = fopen ( "output/masterout", "r" ))
  {
    fclose ( fet );
    fet = fopen ( "output/newout", "w" );
  }
  else
  {
    fet = fopen ( "output/masterout", "w" );
    master = 1;
  }
  
  if (!fet)
    fprintf ( stderr, "CANNOT open masterout/newout\n" );
  else
  {
    struct GRid soo;
    int         i, osnum, count;
    DEsoe       *soes;
    
    for (osnum = 2; (OMuword) osnum < OM_Gw_maxOS; osnum++)
    {
      DEget_soo ( &soo.objid, &soo.osnum, osnum );
      if (soo.objid != NULL_OBJID)
      { 
        om$send ( msg = message DEso.DEdump ( &count, &soes, 1 ),
                  senderid = NULL_OBJID, 
                  targetos = soo.osnum,
                  targetid = soo.objid );
        for (i = 0; i < count; i++)
          if (soes [i].type != DE_DELETED && soes [i].type != DE_EMPTY)
            fprintf ( fet, "%d - %d - %d - %lf - %lf - %d - %d - %d\n",
                      soes [i].type, soes [i].view, soes [i].context,
                      soes [i].u1, soes [i].u2, soes [i].osymb.color, 
                      soes [i].osymb.style, soes [i].osymb.weight );
          else
            fprintf ( fet, "%d\n", soes [i].type );
      }
    }

    fclose ( fet );
  }

  return OM_S_SUCCESS;
}


GRattach_file ( msg, p_ref_id, fname, md_env, symb, level, name, view, scale, lbsys )
                long              *msg    /* return code		OUT */;
		struct GRid	  *p_ref_id /* GRid for ref file        OUT */;
                char              *fname  /* file to attach		IN  */;
                struct GRmd_env   *md_env /* module environment		IN  */;
                struct IGRdisplay *symb   /* symbology of the file	IN  */;
                int               level	  /* level of the file		IN  */; 
                char              *name	  /* name of attachment		IN  */;
                char              *view	  /* saved view name 		IN  */;
                char              *scale  /* scale of the attachment	IN  */; 
                struct IGRlbsys   *lbsys  /* local bounded system	IN  */;
{
  int	                status = OM_S_SUCCESS;
  struct GRvg_construct const_list;
  struct GRrf_info      rf_info;
  IGRmatrix             window_rotation;
  unsigned int          properties;
  enum GRdpmode         mode;
  struct GRid		dummygrid;

  /* this takes care of the function being called with a null */
  /* pointer to GRid */
   
  if (p_ref_id == NULL) 
    p_ref_id = &dummygrid;

  /* Set up the construct arguments. */
  const_list.env_info = md_env;
  const_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  const_list.geometry = (char *)lbsys;
  const_list.display = symb;
  const_list.level = level;
  const_list.newflag = FALSE;
  const_list.name = name;
  const_list.class_attr = (char *)&rf_info;
  const_list.msg = msg;

  rf_info.filename = fname;
  rf_info.named_view = view;
  rf_info.clip_poly = NULL;
  rf_info.prism_classname = NULL;
  rf_info.description = NULL;
  rf_info.ref_properties = &properties;
  properties = GRRF_IS_READ_ONLY;
  rf_info.scale = scale;

  p_ref_id->osnum = md_env->md_id.osnum;
  status = om$construct ( osnum = p_ref_id->osnum,
                          classname = "GRreffile",
                          p_objid = &p_ref_id->objid );
  if (status & 1)
    status = om$send ( msg = message GRgraphics.GRconstruct ( &const_list ),
                       senderid = NULL_OBJID,
                       targetid = p_ref_id->objid,
                       targetos = p_ref_id->osnum );
  if ( status & *msg & 1 )
  {
#if 0
    /* Activate any symbology overrides. */
    if (view [0])
    {
      struct GRid win_id;

      win_id.objid = COref->origin_event.event.button.objid;
      win_id.osnum = COref->origin_event.event.button.osnum;

      /* Activate any symbology overrides attached to 
         the reference file's saved view. */
       /*DEref_view_recalled ( &msg, &ref_id, &win_id ); */
    }
#endif

    /* Display the constructed object. */
    mode = GRbd;
    om$send ( msg = message GRgraphics.GRdisplay ( msg, 
                                                   &md_env->md_env.matrix_type,
                                                   md_env->md_env.matrix,
                                                   &mode, 
                                                   &md_env->md_id ),
              senderid = NULL_OBJID,
              targetid = p_ref_id->objid,
              targetos = p_ref_id->osnum );
  }
  else
  {
    long msg;

    /* delete the object */
    om$send ( msg = message GRgraphics.GRdelete ( &msg, md_env ),
              senderid = NULL_OBJID,
              targetos = p_ref_id->osnum,
              targetid = p_ref_id->objid );
  }

  return OM_S_SUCCESS;
}


DEtst_ref_place ( max )
                  int max;
/*
   This function tests the placement of SO in a reference file.
   In order for this function to work properly, a file called f1 must
   be attached to the master and that file must contain a directory
   :usr:lines containing at least one graphics objects.
*/
{
  int               i, j, status, count;
  long              msg;
  char              window_name [DI_PATH_MAX], dir_name [DI_PATH_MAX];
  GRspacenum        osnum, ref_os;
  GRobjid           soo, md_id;
  struct GRid       window, *lines, *grids;
  struct IGRdisplay symb;
  struct GRmd_env   md_env;
    
  _DEinit ();
  ex$get_cur_mod ( id = &md_id, osnum = &osnum );

  /* let's find the window */
  DIstmocpy ( window_name, "views", "regviews", "GRviews", "*", 0, osnum );
  status = di$dump ( regexp = window_name, grids = (DIgrid **)&grids, 
                     options = 0, ptr = &count );
  if (!(status & 1))
    di$report_error ( sts = status, 
                      comment = "cannot dump windows" );
  window = grids [0];
  free ( grids );

  /* initialize the md_env with the first attachment */
  {
    GRobjid         attachment, context;
    OM_S_CHANSELECT chanselect;  
    
    status = di$translate ( osnum = osnum,
                            path = "ref:refnames",
                            objname = "f1",
                            p_objid = &attachment );
    if (status != OM_S_SUCCESS)
    {
      printf ( "%s at %d: cannot get attachment\n", __FILE__, __LINE__ );
      return OM_E_ABORT;
    }
   
    chanselect.type = OM_e_num;
    om$get_channel_number ( channame = "GRreffile.to_context",
                            p_channum = &chanselect.u_sel.number );
    status = om$get_objid_at_index ( osnum = osnum,
                                     objid = attachment,
                                     p_chanselect = &chanselect,
                                     index = 0,
                                     objidaddr = &context,
                                     osnumaddr = &osnum );
    status = om$send ( msg = message GRcontext.GRgetmodule_env ( &msg, &md_env ),
                       senderid = NULL_OBJID,
                       targetos = osnum,
                       targetid = context );
    if (status != OM_S_SUCCESS)
    {
      om$report_error ( sts = status );
      printf ( "%s at %d: cannot get md_env\n", __FILE__, __LINE__ );
      return OM_E_ABORT;
    }  
  }

  /* let's create the soo for that space */
  ref_os = md_env.md_id.osnum;
  de$create_soo ( msg = &status, osnum = ref_os, p_objid = &soo );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  /* let's create max line(s) in that file */
  lines = (struct GRid *)alloca ( max * sizeof ( struct GRid ) );
  for (i = 0; i < max; i++)
  {
    lines [i].osnum = ref_os;
    DEplace_line ( &msg, &lines [i].objid, &window,
                   MIN_X + i * (MAX_X - MIN_X) / max, MIN_Y, 0.0,
                   MIN_X + (i + 1) * (MAX_X - MIN_X) / max, MAX_Y, 0.0, 
                   &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in GRlineseg construction\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  for (i = 0; i < max; i++)
  {
    symb.color = i % 5;
    symb.style = i % 10;
    symb.weight = i % 10;
    status = om$send ( msg = message DEso.DEadd 
                             ( &msg, i % 2 ? DE_SOE | DE_HIDDEN : DE_SOE, 
                               lines [i].objid, 0.1 + (0.6 / max) * i, 
                               0.4 + (0.6 / max) * i, &symb, &window, 
                               NULL_INDEX, &md_env, NULL_INDEX ),
                       targetid = soo,
                       targetos = osnum,
                       senderid = NULL_OBJID );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }
  
  /* add multiple overrides */
  for (i = 1; i < max / 8; i++)
  {
    symb.color = 2;
    symb.style = 0;
    symb.weight = 0;
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.2 - i / max,
                                 u2 = 0.6 + i / max,
                                 go_grid = &lines [i],
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  /* add multiple overrides */
  for (i = max / 2; i < 7 * max / 8; i++)
  {
    symb.color = 0;
    symb.style = 0;
    symb.weight = 10.0;
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.4 - i / max,
                                 u2 = 0.6 + i / max,
                                 go_grid = &lines [i],
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  /* let's remove of few of the ones we put */
  for (i = 0; i < max; i += 2)
  {
    if (i < 7 * max / 8)
    {
      status = de$delete_by_objid ( msg = &msg, 
                                    osnum = lines [i].osnum, 
                                    objid = lines [i].objid );
      if (!(status & 1))
      {
        printf ( "%s at %d: error in soo remove_by_objid\n", 
                 __FILE__, __LINE__ );
        om$report_error ( sts = status );
      }  
      if (msg != MSSUCC)
        printf ( "%s at %d: error in soo remove_by_objid\n", 
                 __FILE__, __LINE__ );
    }
    else
    {
      symb.color = i % 5;
      symb.style = i % 10;
      symb.weight = i % 10;
    
      status = de$delete_override ( msg = &msg, 
                                    go_grid = &lines [i],
                                    u1 = 0.1 + (0.6 / max) * i, 
                                    u2 = 0.4 + (0.6 / max) * i,
                                    symbology = &symb,
                                    window_grid = &window, 
                                    module = &md_env  );
      if (!(status & 1))
      {
        printf ( "%s at %d: error in soo remove\n", 
                 __FILE__, __LINE__ );
        om$report_error ( sts = status );
      }  
      if (msg != MSSUCC)
        printf ( "%s at %d: error in soo remove\n", 
                 __FILE__, __LINE__ );
    }
  }
  
  status = om$send ( msg = message DEso.DEremove_by_objid ( &msg, lines [0].objid ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo remove_by_objid\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      printf ( "%s at %d: remove_by_objid was supposed to fail\n", 
               __FILE__, __LINE__ );

  status = om$send ( msg = message DEso.DEremove 
                           ( &msg, 1 % 2 ? DE_SOE | DE_HIDDEN : DE_SOE, 
                             lines [1].objid, 0.0, 0.0, &symb, &window, &md_env  ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo remove\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      printf ( "%s at %d: remove was supposed to fail\n", 
               __FILE__, __LINE__ );

  status = om$send ( msg = message DEso.DEremove 
                           ( &msg, 0 % 2 ? DE_SOE | DE_HIDDEN : DE_SOE, 
                             lines [0].objid, 0.5, 1.0 / (max - 1), 
                             &symb, &window, &md_env  ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo remove\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      printf ( "%s at %d: remove was supposed to fail\n", 
               __FILE__, __LINE__ );

  /* delete the window
  status = om$send ( msg = message Root.delete ( 1 ),
                     senderid = NULL_OBJID,
                     targetid = window.objid,
                     targetos = window.osnum );
  */

  return OM_S_SUCCESS;
}


DEtst_ref_linestr ( max )
                    int max	/* number of objects to add		IN */;
/*
   This function tests the placement of SO on linestring in reference files.
*/
{
  int               i, j, status, count;
  long              msg;
  char              window_name [DI_PATH_MAX];
  GRspacenum        ref_os, osnum;
  GRobjid           soo, objid, mod_id;
  struct GRid       window, *grids;
  struct GRid       grid;
  double            *points;
  struct IGRdisplay symb;
  struct GRmd_env   md_env;
    
  _DEinit ();
  points = (double *)alloca ( sizeof ( double ) * max * 6 );
  ex$get_cur_mod ( id = &mod_id, osnum = &osnum );

  /* let's find the window */
  DIstmocpy ( window_name, "views", "regviews", "GRviews", "*", 0, osnum );
  status = di$dump ( regexp = window_name, grids = (DIgrid **)&grids, 
                     options = 0, ptr = &count );
  if (!(status & 1))
    di$report_error ( sts = status, 
                      comment = "cannot dump windows" );
  window = grids [0];

  /* let's create the soo for that space */
  /* initialize the md_env with the second attachment */
  {
    GRobjid         attachment, context;
    OM_S_CHANSELECT chanselect;  
    
    status = di$translate ( osnum = osnum,
                            path = "ref:refnames",
                            objname = "f1",
                            p_objid = &attachment );
    if (status != OM_S_SUCCESS)
    {
      printf ( "%s at %d: cannot get attachment\n", __FILE__, __LINE__ );
      return OM_E_ABORT;
    }
   
    chanselect.type = OM_e_num;
    om$get_channel_number ( channame = "GRreffile.to_context",
                            p_channum = &chanselect.u_sel.number );
    status = om$get_objid_at_index ( osnum = osnum,
                                     objid = attachment,
                                     p_chanselect = &chanselect,
                                     index = 0,
                                     objidaddr = &context,
                                     osnumaddr = &osnum );
    status = om$send ( msg = message GRcontext.GRgetmodule_env ( &msg, &md_env ),
                       senderid = NULL_OBJID,
                       targetos = osnum,
                       targetid = context );
    if (status != OM_S_SUCCESS)
    {
      om$report_error ( sts = status );
      printf ( "%s at %d: cannot get md_env\n", __FILE__, __LINE__ );
      return OM_E_ABORT;
    }  
  }

  /* let's create the soo for that space */
  ref_os = md_env.md_id.osnum;
  de$create_soo ( msg = &status, osnum = ref_os, p_objid = &soo );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  /* let's add max objects */
  for (i = 0, j = 0; i < max; j += 6, i++)
  {
    points [j] = MIN_X + i * (MAX_X - MIN_X) / max;
    points [j + 1] = MIN_Y;
    points [j + 2] = 0.0;
    points [j + 3] = MIN_X + (i + 1) * (MAX_X - MIN_X) / max;
    points [j + 4] = MAX_Y;
    points [j + 5] = 0.0;
  }
  
  DEplace_line_str ( &msg, &objid, &window, max, points, &md_env );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in GRlineseg construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  symb.color = 2;
  symb.style = 0;
  symb.weight = 0;
  grid.osnum = ref_os;
  grid.objid = objid;
  for (i = 0; i < max; i += 2)
  {
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.2 + i * 0.7 / max, 
                                 u2 = 0.8 + i * 0.15 / max,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }
  
  /* add multiple overrides */
  symb.color = 2;
  symb.style = 0;
  symb.weight = 10;

  for (i = 1; i < max / 4; i++)
  {
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.4 - i / max,
                                 u2 = 0.6 + i / max,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  /* add multiple overrides */
  symb.color = 3;
  status = de$place_override ( msg = &msg,
                               symbology = &symb,
                               u1 = 0.1,
                               u2 = 0.2,
                               go_grid = &grid,
                               window_grid = &window,
                               module = &md_env );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  symb.color = 3;
  status = de$place_override ( msg = &msg,
                               symbology = &symb,
                               u1 = 0.8,
                               u2 = 1.0,
                               go_grid = &grid,
                               window_grid = &window,
                               module = &md_env );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  status = om$send ( msg = message DEso.DEremove_by_objid ( &msg, -1 ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo remove_by_objid\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      printf ( "%s at %d: remove_by_objid was supposed to fail\n", 
               __FILE__, __LINE__ );

  status = om$send ( msg = message DEso.DEremove ( &msg, DE_SOE, objid, 
                                                   0.0, 0.0, &symb, &window, 
                                                   &md_env ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo remove\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      printf ( "%s at %d: remove was supposed to fail\n", 
               __FILE__, __LINE__ );

  status = om$send ( msg = message DEso.DEremove ( &msg, DE_SOE, objid, 
                                                   0.5, 1.0 / (max - 1), 
                                                   &symb, &window, &md_env ),
                     targetid = soo,
                     targetos = osnum,
                     senderid = NULL_OBJID );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo remove\n", 
             __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }
  else
    if (msg == MSSUCC)
      printf ( "%s at %d: remove was supposed to fail\n", 
               __FILE__, __LINE__ );

  return OM_S_SUCCESS;
}


DEtst_ref_modify ()
/*
   This function tests the modify capability for SO in reference files
   by changing the weight of all existing overrides.
*/
{
  GRobjid           soo, md_id;
  DEsoe             *buffer, *tmp;
  int               i, j, count, status;
  long              msg;
  uword             ref_os, osnum;
  struct GRmd_env   md_env;
  struct IGRdisplay symb;
  
  _DEinit ();
  ex$get_cur_mod ( id = &md_id, osnum = &osnum );

  /* initialize the md_env with the third attachment */
  {
    GRobjid         attachment, context;
    OM_S_CHANSELECT chanselect;  
    
    status = di$translate ( osnum = osnum,
                            path = "ref:refnames",
                            objname = "f1",
                            p_objid = &attachment );
    if (status != OM_S_SUCCESS)
    {
      printf ( "%s at %d: cannot get attachment\n", __FILE__, __LINE__ );
      return OM_E_ABORT;
    }
   
    chanselect.type = OM_e_num;
    om$get_channel_number ( channame = "GRreffile.to_context",
                            p_channum = &chanselect.u_sel.number );
    status = om$get_objid_at_index ( osnum = osnum,
                                     objid = attachment,
                                     p_chanselect = &chanselect,
                                     index = 0,
                                     objidaddr = &context,
                                     osnumaddr = &osnum );
    status = om$send ( msg = message GRcontext.GRgetmodule_env ( &msg, &md_env ),
                       senderid = NULL_OBJID,
                       targetos = osnum,
                       targetid = context );
    if (status != OM_S_SUCCESS)
    {
      om$report_error ( sts = status );
      printf ( "%s at %d: cannot get md_env\n", __FILE__, __LINE__ );
      return OM_E_ABORT;
    }  
  }

  /* let's create the soo for that space */
  ref_os = md_env.md_id.osnum;
  de$create_soo ( msg = &status, osnum = ref_os, p_objid = &soo );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  /* get all the soo entries */
  status = om$send ( msg = message DEso.DEdump ( &count, &tmp, 0 ),
                     senderid = NULL_OBJID,
                     targetid = soo,
                     targetos = osnum );
  
  /* move temp memory into secure area */
  buffer = (DEsoe *)alloca ( count * sizeof ( DEsoe ) );
  memcpy ( buffer, tmp, count * sizeof ( DEsoe ) );
           
  /* modify each soo entry */
  for (i = 0; i < count; i++)
  {
    struct                 GRid window;
    extern OM_S_CHANSELECT DEso_to_windows_chanselect;
    
    /* increase the weight */
    symb = buffer [i].osymb;
    symb.weight++;
    om$get_objid_at_index ( objid = soo,
                            osnum = osnum,
                            p_chanselect = &DEso_to_windows_chanselect,
                            index = buffer [i].view,
                            objidaddr = &window.objid,
                            osnumaddr = &window.osnum );
    
    status = om$send ( msg = message DEso.DEmodify ( &msg, buffer [i].type,
                                               &buffer [i].osymb, 
                                               buffer [i].u1, 
                                               buffer [i].u2, 
                                               &window, 
                                               &md_env, 
                                               buffer [i].type, 
                                               &symb,
                                               buffer [i].u1,
                                               buffer [i].u2,
                                               buffer [i].objid,
                                               &window, 
                                               &md_env,
                                               1 ),
                       targetid = soo,
                       targetos = osnum,
                       senderid = NULL_OBJID );
    if (!(status & 1))
    {
      printf ( "%s at %d: DEmodify problem\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }

    if (msg != MSSUCC)
      printf ( "%s at %d: DEmodify problem\n", __FILE__, __LINE__ );
  }
  
  /* get all the soo entries */
  status = om$send ( msg = message DEso.DEdump ( &count, &tmp, 0 ),
                     senderid = NULL_OBJID,
                     targetid = soo,
                     targetos = osnum );
  if (!(status & 1))
    printf ( "%s at %d: dump problem\n", __FILE__, __LINE__ );
  
  /* make sure that's what it is supposed to */
  if (i != count)
    printf ( "%s at %d: bad count\n", __FILE__, __LINE__ );
      
  for (i = 0; i < count; i++)
  {
    for (j = 0; j < count; j++)
      if (buffer [i].type == tmp [j].type &&
          buffer [i].view == tmp [j].view &&
          buffer [i].osymb.color != tmp [j].osymb.color &&
          buffer [i].osymb.weight != tmp [j].osymb.weight &&
          buffer [i].osymb.style != tmp [j].osymb.style &&
          buffer [i].u1 == tmp [j].u1 &&
          buffer [i].u2 == tmp [j].u2)
        continue;
      else
        break;
    if (j == count)
      printf ( "%s at %d: entry is missing\n", __FILE__, __LINE__ );
  }
  
  return OM_S_SUCCESS;
}


DEtst_ref_arc ( max )
                int max	/* number of objects to add		IN */;
/*
   This function tests the placement of SO in reference files.
*/
{
  int               i, j, status, count;
  long              msg;
  char              window_name [DI_PATH_MAX];
  GRspacenum        osnum, ref_os;
  GRobjid           soo, *arcs, md_id;
  struct GRid       window, *grids;
  struct IGRdisplay symb;
  struct GRmd_env   md_env;
    
  _DEinit ();
  arcs = (GRobjid *)alloca ( sizeof ( GRobjid ) * max );
  ex$get_cur_mod ( id = &md_id, osnum = &osnum );
  /* let's find the window */
  DIstmocpy ( window_name, "views", "regviews", "GRviews", "*", 0, osnum );
  status = di$dump ( regexp = window_name, grids = (DIgrid **)&grids, 
                     options = 0, ptr = &count );
  if (!(status & 1))
    di$report_error ( sts = status, 
                      comment = "cannot dump windows" );
  window = grids [0];

  /* let's create the soo for that space */
  /* initialize the md_env with the fourth attachment */
  {
    GRobjid         attachment, context;
    OM_S_CHANSELECT chanselect;  
    
    status = di$translate ( osnum = osnum,
                            path = "ref:refnames",
                            objname = "f1",
                            p_objid = &attachment );
    if (status != OM_S_SUCCESS)
    {
      printf ( "%s at %d: cannot get attachment\n", __FILE__, __LINE__ );
      return OM_E_ABORT;
    }
   
    chanselect.type = OM_e_num;
    om$get_channel_number ( channame = "GRreffile.to_context",
                            p_channum = &chanselect.u_sel.number );
    status = om$get_objid_at_index ( osnum = osnum,
                                     objid = attachment,
                                     p_chanselect = &chanselect,
                                     index = 0,
                                     objidaddr = &context,
                                     osnumaddr = &osnum );
    status = om$send ( msg = message GRcontext.GRgetmodule_env ( &msg, &md_env ),
                       senderid = NULL_OBJID,
                       targetos = osnum,
                       targetid = context );
    if (status != OM_S_SUCCESS)
    {
      om$report_error ( sts = status );
      printf ( "%s at %d: cannot get md_env\n", __FILE__, __LINE__ );
      return OM_E_ABORT;
    }  
  }

  /* let's create the soo for that space */
  ref_os = md_env.md_id.osnum;
  de$create_soo ( msg = &status, osnum = ref_os, p_objid = &soo );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  /* let's add max objects */
  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    
    DEplace_arc ( &msg, &arcs [i], &window, 0.0, 6.27, 300.0 + i * 20.0, 
                  0.0, 0.0, 0.0, &md_env );
    grid.osnum = ref_os;
    grid.objid = arcs [i];
    
    symb.color = 2;
    symb.style = 0;
    symb.weight = 4;

    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.25,
                                 u2 = 0.75,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    
    grid.osnum = ref_os;
    grid.objid = arcs [i];
    
    symb.color = 2;
    symb.style = 0;
    symb.weight = 8;

    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.4,
                                 u2 = 0.6,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.0,
                                 u2 = 0.1,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.9,
                                 u2 = 1.0,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }
  
  return OM_S_SUCCESS;
}


DEtst_ref_retrieve ( max )
                     int max	/* number of objects to add		IN */;
/*
   This function tests the retrieval of symbology overrides in reference files.
*/
{
  int               i, j, status, count;
  long              msg;
  char              window_name [DI_PATH_MAX];
  GRspacenum        osnum, ref_os;
  GRobjid           soo, *arcs, md_id;
  struct GRid       window, *grids;
  struct IGRdisplay symb;
  struct GRmd_env   md_env;
    
  _DEinit ();
  arcs = (GRobjid *)alloca ( sizeof ( GRobjid ) * max );
  ex$get_cur_mod ( id = &md_id, osnum = &osnum );
  /* let's find the window */
  DIstmocpy ( window_name, "views", "regviews", "GRviews", "*", 0, osnum );
  status = di$dump ( regexp = window_name, grids = (DIgrid **)&grids, options = 0, ptr = &count );
  if (!(status & 1))
    di$report_error ( sts = status, 
                      comment = "cannot dump windows" );
  window = grids [0];

  /* initialize the md_env with the first attachment */
  {
    GRobjid         attachment, context;
    OM_S_CHANSELECT chanselect;  
    
    status = di$translate ( osnum = osnum,
                            path = "ref:refnames",
                            objname = "f1",
                            p_objid = &attachment );
    if (status != OM_S_SUCCESS)
    {
      printf ( "%s at %d: cannot get attachment\n", __FILE__, __LINE__ );
      return OM_E_ABORT;
    }
   
    chanselect.type = OM_e_num;
    om$get_channel_number ( channame = "GRreffile.to_context",
                            p_channum = &chanselect.u_sel.number );
    status = om$get_objid_at_index ( osnum = osnum,
                                     objid = attachment,
                                     p_chanselect = &chanselect,
                                     index = 0,
                                     objidaddr = &context,
                                     osnumaddr = &osnum );
    status = om$send ( msg = message GRcontext.GRgetmodule_env ( &msg, &md_env ),
                       senderid = NULL_OBJID,
                       targetos = osnum,
                       targetid = context );
    if (status != OM_S_SUCCESS)
    {
      om$report_error ( sts = status );
      printf ( "%s at %d: cannot get md_env\n", __FILE__, __LINE__ );
      return OM_E_ABORT;
    }  
  }

  /* let's create the soo for that space */
  ref_os = md_env.md_id.osnum;
  de$create_soo ( msg = &status, osnum = ref_os, p_objid = &soo );
  if (!(status & 1))
  {
    printf ( "%s at %d: error in soo construction\n", __FILE__, __LINE__ );
    om$report_error ( sts = status );
  }  

  /* let's add max objects */
  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    
    DEplace_arc ( &msg, &arcs [i], &window, 0.0, 6.27, 300.0 + i * 20.0, 
                  300.0, 0.0, 0.0, &md_env );
    grid.osnum = ref_os;
    grid.objid = arcs [i];
    
    symb.color = 2;
    symb.style = 0;
    symb.weight = 4;

    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 u1 = 0.25,
                                 u2 = 0.75,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  /* let's make sure we can retrieve them */
  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    int         type;
    double      u1, u2;

    grid.osnum = ref_os;
    grid.objid = arcs [i];
    status = de$retrieve_override ( msg = &msg,
                                    p_type = &type,
                                    p_u1 = &u1,
                                    p_u2 = &u2,
                                    go_grid = &grid,
                                    window_grid = &window,
                                    module = &md_env,
                                    u = 0.5 );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo retrieve\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }
    if (msg != MSSUCC)
      printf ( "%s at %d: bad msg in soo retrieve\n", __FILE__, __LINE__ );
    if (u1 > 0.5 || u2 < 0.5 || type != DE_SOE)
      printf ( "%s at %d: inconsistency in soo retrieve\n", __FILE__, __LINE__ );

    status = de$delete_by_objid ( msg = &msg, 
                                  osnum = ref_os, 
                                  objid = arcs [i] );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo remove_by_objid\n", 
               __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
    if (msg != MSSUCC)
      printf ( "%s at %d: error in soo remove_by_objid\n", 
               __FILE__, __LINE__ );

    status = de$retrieve_override ( msg = &msg,
                                    p_type = &type,
                                    p_u1 = &u1,
                                    p_u2 = &u2,
                                    go_grid = &grid,
                                    window_grid = &window,
                                    module = &md_env,
                                    u = 0.5 );
    if (msg == MSSUCC)
    {
      printf ( "%s at %d: soo retrieve should have failed\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }
  }
  
  /* let's try a few total overrides */
  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    
    grid.osnum = ref_os;
    grid.objid = arcs [i];
    symb.color = 2;
    symb.style = 0;
    symb.weight = 4;

    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 type = DE_SOE | DE_OVERLAP,
                                 u1 = 0.75,
                                 u2 = 1.0,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  

    status = de$place_override ( msg = &msg,
                                 symbology = &symb,
                                 type = DE_SOE | DE_OVERLAP,
                                 u1 = 0.0,
                                 u2 = 0.25,
                                 go_grid = &grid,
                                 window_grid = &window,
                                 module = &md_env );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo add\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
  }

  /* let's make sure we can retrieve them */
  for (i = 0; i < max; i++)
  {
    struct GRid grid;
    int         type;
    double      u1, u2;

    grid.osnum = ref_os;
    grid.objid = arcs [i];
    status = de$retrieve_override ( msg = &msg,
                                    p_type = &type,
                                    p_u1 = &u1,
                                    p_u2 = &u2,
                                    go_grid = &grid,
                                    window_grid = &window,
                                    module = &md_env,
                                    u = i % 2 ? 0.0 : 1.0 );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo retrieve\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }
    if (msg != MSSUCC)
      printf ( "%s at %d: bad msg in soo retrieve\n", __FILE__, __LINE__ );
    if (i % 2)
    {
      if (u1 != 0.0 || u2 != 0.25 || type != (DE_SOE | DE_OVERLAP))
        printf ( "%s at %d: inconsistency in soo retrieve\n", __FILE__, __LINE__ );
    }
    else
      if (u1 != 0.75 || u2 != 1.0 || type != (DE_SOE | DE_OVERLAP))
        printf ( "%s at %d: inconsistency in soo retrieve\n", __FILE__, __LINE__ );

    status = de$next_override ( msg = &msg,
                                p_type = &type,
                                p_u1 = &u1,
                                p_u2 = &u2 );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo next\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }
    if (msg != MSSUCC)
      printf ( "%s at %d: bad msg in soo next\n", __FILE__, __LINE__ );
    if (i % 2)
    {
      if (u1 != 0.75 || u2 != 1.0 || type != (DE_SOE | DE_OVERLAP))
        printf ( "%s at %d: inconsistency in soo retrieve\n", __FILE__, __LINE__ );
    }
    else
      if (u1 != 0.0 || u2 != 0.25 || type != (DE_SOE | DE_OVERLAP))
        printf ( "%s at %d: inconsistency in soo retrieve\n", __FILE__, __LINE__ );

    status = om$send ( msg = message GRgraphics.GRdelete ( &msg, &md_env ),
                       senderid = NULL_OBJID,
                       targetid = arcs [i],
                       targetos = ref_os );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in GRdelete\n", 
               __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }  
    if (msg != MSSUCC)
      printf ( "%s at %d: error in NDdelete\n", 
               __FILE__, __LINE__ );

    status = de$retrieve_override ( msg = &msg,
                                    p_type = &type,
                                    p_u1 = &u1,
                                    p_u2 = &u2,
                                    go_grid = &grid,
                                    window_grid = &window,
                                    module = &md_env,
                                    u = 0.0 );
    if (msg == MSSUCC)
    {
      printf ( "%s at %d: soo retrieve should have failed\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    }
  }

  return OM_S_SUCCESS;
}


end implementation DEso;
