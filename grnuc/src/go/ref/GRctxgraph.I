class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"
#include "refdef.h"
#include "gr.h"
#include "godef.h"
#include "gocmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "madef.h"

#include "GM.h"
#include "GMdef.h"
#include "GMerrordef.h"
#include "GMmacros.h"
#include <alloca.h>


from GRreffile import GRgetenvironment;

#argsused
GRget_ref_children ( root, dummy, children, nb_children )
                     struct GRid *root	      /* The root		IN  */;
                     char        *dummy	      /* Not used		IN  */;
                     struct GRid **children   /* The children		OUT */;
                     int         *nb_children /* The number of children	OUT */;
/* 
   This method returns the children of a reference file, i.e. the nested files.
   We find the nested files by looking at the GRreffile objects of a given file.
   The list of children is returned in the form ( <osnum>, 0 ).
*/
{
  int             i, status;
  IGRuint         count;
  long            msg;
  OM_S_CHANSELECT mgr;
  struct GRid     super;
  GRobjid         mod_id;

  *nb_children = 0;
  status = om$make_chanselect ( channame = "Super_rfmgr.mgr",
                                p_chanselect = &mgr );
  if (status & 1)
  {
    /* get the module */
    status = di$translate ( osnum = root->osnum, 
                            path = "IGENOD",
                            objname = "MODULE",
                            p_objid = &mod_id );
    if (status & 1)
    {
      super.objid = NULL_OBJID;
      ex$get_super ( mod_id = mod_id,
                     mod_osnum = root->osnum,
                     super_name = "Ref Mgr",
                     create = 0,
                     super_class = "GRreffile",
                     super_id = &super.objid,
                     super_osnum = &super.osnum );
      if ((status & 1) && (super.objid != NULL_OBJID))
      {
        /* get the GRreffile objects */
        status = om$get_channel_count ( objid = super.objid,
                                        osnum = super.osnum,
                                        p_chanselect = &mgr,
                                        count = &count );
        if ((1 & status) && count)
        {
          static struct GRid  *s_children_buffer = NULL;
          OM_S_OBJECT_LINKAGE *link;
          
          if ( ! children )
            *nb_children = count;    /* just return count */
          else
          {
            link = (OM_p_OBJECT_LINKAGE) alloca( sizeof ( OM_S_OBJECT_LINKAGE ) * count );
            if (link)
            {
              unsigned size;

              om$get_channel_objects ( objid = super.objid,
                                       osnum = super.osnum,
                                       p_chanselect = &mgr,
                                       size = count,
                                       list = link,
                                       count = &count );
              size = count * sizeof( struct GRid );
              if (s_children_buffer)
                s_children_buffer = (struct GRid *)realloc ( s_children_buffer, 
                                                             size );
              else
                s_children_buffer = (struct GRid *)malloc ( size );
          
              if (s_children_buffer)
              {
                struct GRid *ptr;

                if ( ! *children )
                  *children = s_children_buffer;   /* return static memory */
                /* else */                         /* use provided memory */

                ptr = *children;
                *nb_children = count;

                for (i = 0; i < count; i++)
                {
                  struct GRmd_env dummy_env, env;
                
                  /* get the osnum represented by that GRreffile */
                  dummy_env.md_env.matrix_type = MAIDMX;
                  om$send ( msg = message GRreffile.GRgetenvironment ( &msg, &dummy_env, &env ),
                            senderid = NULL_OBJID,
                            targetid = link [i].S_objid,
                            targetos = link [i].osnum );
                  ptr [i].objid = 0;
                  ptr [i].osnum = env.md_id.osnum;
                }
              }
              else
                status = OM_E_NODYNMEM;
            }
            else
              status = OM_E_NODYNMEM;
          }
        }
      }
    }    
  }
  
  return status;
}


GRget_nested_files_1 ()
{
  OMuword osnum, *osnums;
  int     i, count;
  long    msg;
    
  printf ( "osnum -> " );
  fflush ( stdout );
  fscanf ( stdin, "%d", &osnum );
  
  printf ( "scanning files for %d...\n", osnum );
  GRget_sorted_nested_files ( &msg, &count, &osnums, osnum );

  if (msg & 1)
  {
    printf ( "osnums for %d are: ", osnum );
    for (i = 0; i < count; i++)
      printf ( "%d ", osnums [i] );
    printf ( "\n" );
  }
  else
    printf ( "IT didn't work\n" );
  
  return 1;
}


GRget_sorted_nested_files ( msg, p_count, p_osnums, osnum )
                            long        *msg       /* return code       OUT */;
                            int         *p_count   /* Number of files	OUT */;
                            OMuword     **p_osnums /* Osnums		OUT */;
                            OMuword     osnum      /* os to start from	IN  */;
{
  struct GRid    root, grid;
  struct GMgraph graph;
  int            sts, i;
  static OMuword *osnums = NULL;
  static int     osnum_size = 0;

  root.osnum = osnum;
  root.objid = 0;  
  *msg = MSSUCC;
  i = 0;
  
  sts = gm$init_graph ( nb_elmt = 20, inc_elmt = 20, p_graph = &graph );
  if (sts == GM_S_SUCCESS)
  {
    sts = gm$get_graph ( successor_fct = GRget_ref_children,
                         l_initial = &root,
                         nb_initial = 1,
                         p_graph = &graph );
    if (sts == GM_S_SUCCESS)
    {
      int desc = GM_FROM_BEGIN;
      
      /* move the graph into the list of osnums */
      sts = gm$list_access_init ( p_graph = &graph, p_desc = &desc );
      for (i = 0; sts == GM_S_SUCCESS; )
      {
        sts = gm$list_access_next ( p_graph = &graph,
                                    p_desc = &desc,
                                    p_object = &grid );
        if (sts == GM_S_SUCCESS)
        {
          if (i == osnum_size)
          {
            if (osnums)
              osnums = (OMuword *)realloc ( osnums, (osnum_size + 1024) * sizeof ( OMuword ) );
            else
              osnums = (OMuword *)malloc ( 1024 * sizeof ( OMuword ) );
            osnum_size += 1024;
            if (!osnums)
            {
              *msg = MSFAIL;
              return OM_E_NODYNMEM;
            }
          }
            
          osnums [i++] = grid.osnum;
        }
      }
    }
    else
      *msg = MSFAIL;

    gm$free_graph ( p_graph = &graph );
    
    *p_count = i;
    *p_osnums = osnums;
  }
  else
    *msg = MSFAIL;
  
  return 1;
}

IGRlong GRconsmodctx(md_env)
struct GRmd_env *md_env;
{
    IGRshort    flag,env_type;
 
    IGRmatrix   env_matrix;

    IGRlong     OMmsg,msg;

    IGRint      count;

    OM_S_CHANSELECT chan,to_chan;

    struct GRid Super, module_context;

    OMmsg = OM_S_SUCCESS;
    msg = MSSUCC;

    OMmsg = ex$get_super(
            mod_id = md_env->md_id.objid,
            mod_osnum = md_env->md_id.osnum,
            super_name = "Ref Mgr",
            super_class = "Super_rfmgr",
            create = 1,
            super_id = &Super.objid,
            super_osnum = &Super.osnum);

        MAidmx(&msg,env_matrix);
        env_type = MAIDMX;

        chan.type = OM_e_name;
        chan.u_sel.name = "Super_rfmgr.to_context";

        om$get_channel_count(p_chanselect = &chan,
                osnum = Super.osnum,
                objid = Super.objid,
                count = (OMuint *)&count);

        if (count == 0)      /* object not  exists                */
        {
             /* construct new module context object
              */

             flag = GRMASTER_CONTEXT;

             OMmsg = om$construct(
                    classname = "GRcontext",
                    p_objid = &module_context.objid,
                    osnum = Super.osnum,
                    msg = message GRcontext.GRloadctx
                      (&msg,&md_env->md_env.matrix_type,
                        md_env->md_env.matrix,&Super.osnum,&flag));

             if ( 1 & OMmsg)
             {
                module_context.osnum = Super.osnum;

                /* connect super and context object
                 */

                to_chan.type = OM_e_name;
                to_chan.u_sel.name = "GRcontext.to_super";

                OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message Root.connect(chan,NULL,
                          module_context.objid,
                          module_context.osnum,to_chan,NULL),
                        senderid = module_context.objid,
                        targetid = Super.objid,
                        targetos = Super.osnum);
            }
        }

    return(OMmsg);

}

end implementation GRcontext;

