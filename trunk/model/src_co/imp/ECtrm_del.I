

class implementation ECtrim2;

#include "VCdef.h"
#include "OMminimum.h"

#include "dpmacros.h"
#include "dp.h"
#include "SKmacros.h"
#include "SKdef.h"


# define MAX(x,y)    ((x) < (y) ? (y) :(x))
# define MIN(x,y)    ((x) > (y) ? (y) :(x))
# define ABS(x)      ((x) < 0 ? -(x) : (x))

#define REM_R_TREE  0              /*  remove from r_tree               */
#define ADD_R_TREE -1              /*  add to r_tree                    */
#define REAL_DEL    1              /*  real delete (with members)       */
#define REM_HIGHL   2              /*  remove highlight (with members)  */


#define VCdebug_return    1            /*  test  */


/* imported messages */

from GRgraphics  import GRdisplay;
from SKmgr       import GRremove_components;
from SKgeometry  import SKgetmgr;
from GRgraphics  import GRdelete;             
from GRgraphics  import GRremwrng, GRaddwrng;

extern GRclassid OPP_GRbcsubbc_class_id;
extern GRclassid OPP_GRcompcurve_class_id;
extern GRclassid OPP_SKmgr_class_id;
extern GRclassid OPP_SKgeometry_class_id;
extern GRclassid OPP_GR3dcirarc_class_id;

extern IGRboolean  EFisAncestryValid();










/*  ---------------------------------------------------------------- */
/*  This function deletes/remove/unremove an element (with members)  */
/*  ---------------------------------------------------------------- */
  
IGRlong ECtrm_del(    
                        
            IGRint               task,        /* I  task:                   */
                                              /*    0 = remove for r_tree   */
                                              /*   +1 = delete all          */
                                              /*   -1 = add to r_tree       */
                                              /*   +2 = remove highlight    */
            struct GRid          object,      /* I  work object             */  
            struct GRmd_env      *obj_env)    /* I  work env                */

                             
 
{

   IGRlong              msg;
   IGRlong              sts;
   IGRlong              sts_sk;
   IGRlong              ii;

   OMuword              cur_classid;
   OMuword              obj_classid;
   OMuword              wrk_classid; 
           
   OM_S_CHANSELECT      to_ch_ptr;

   OMuint               chan_count;

   OM_S_OBJECT_LINKAGE  *chan_list;
  
   struct GRid          cur_grid;
   struct GRid          SK_grid;







  /*--- start of executable code ---*/

  /*  get work element class_id  */
  om$get_classid(objid     = object.objid,
                 osnum     = object.osnum,
                 p_classid = &obj_classid);


  /*  find SKmgr id if in use  */
	
  SK_grid.objid = NULL_OBJID;
  sts_sk = om$is_ancestry_valid(subclassid   = obj_classid,
                                superclassid = OPP_SKgeometry_class_id);
  if (sts_sk == OM_S_SUCCESS)
  {
    sts =  om$make_chanselect (channame     = "GRconnector.to_owners",
                               p_chanselect = &to_ch_ptr);
    if (1&sts)
    {
      chan_count = NULL;
      sts = om$get_channel_count(osnum        = object.osnum,
                                 objid        = object.objid,
                                 p_chanselect = &to_ch_ptr,
                                 count        = &chan_count);

      if (chan_count > NULL) 
      {
        chan_list = NULL;
        chan_list = (OM_S_OBJECT_LINKAGE *) malloc(chan_count * sizeof(OM_S_OBJECT_LINKAGE));
        if (!chan_list)  Goto (wrapup);
        sts = om$get_channel_objects(osnum = object.osnum,
                                     objid = object.objid,
                                     p_chanselect = &to_ch_ptr,
                                     list  = chan_list,
                                     size  = chan_count,
                                     count = &chan_count);
        if (!(sts&1)) Goto (wrapup);

        for (ii=0; ii<chan_count; ii++)
        {
          om$get_classid(objid     = chan_list[ii].S_objid,
                         osnum     = chan_list[ii].osnum,
                         p_classid = &wrk_classid);  

          /*  extract element class_id  */
          sts = om$get_classid(objid     = chan_list[ii].S_objid,
                               osnum     = chan_list[ii].osnum,
                               p_classid = &wrk_classid);  

          sts_sk = om$is_ancestry_valid(subclassid   = obj_classid,
                                        superclassid = OPP_SKgeometry_class_id);
          if (sts_sk == OM_S_SUCCESS)
          {
            SK_grid.objid = chan_list[ii].S_objid;
            SK_grid.osnum = chan_list[ii].osnum;
          }
        }
        if (chan_list)  free(chan_list);   /*  release temporary space  */
      }            
    }
  }

  sts =  om$make_chanselect (channame     = "GRcmpowner.to_components",
                             p_chanselect = &to_ch_ptr);
  if (1&sts)
  {
    chan_count = NULL;
    sts = om$get_channel_count(osnum        = object.osnum,
                               objid        = object.objid,
                               p_chanselect = &to_ch_ptr,
                               count        = &chan_count);

    if (chan_count) 
    {
      chan_list = NULL;
      chan_list = (OM_S_OBJECT_LINKAGE *) malloc(chan_count * sizeof(OM_S_OBJECT_LINKAGE));
      if (!chan_list)  Goto (wrapup);
      sts = om$get_channel_objects(osnum        = object.osnum,
                                   objid        = object.objid,
                                   p_chanselect = &to_ch_ptr,
                                   list         = chan_list,
                                   size         = chan_count,
                                   count        = &chan_count);
      if (!(sts&1)) Goto (wrapup);

      for (ii=0; ii<chan_count; ii++)
      {
        cur_grid.objid = chan_list[ii].S_objid;
        cur_grid.osnum = chan_list[ii].osnum;

        /*  extract element class_id  */
        sts = om$get_classid(objid     = cur_grid.objid,
                             osnum     = cur_grid.osnum,
                             p_classid = &cur_classid);

        /*---   element's members handling  ---*/
        switch (task)
        {

          case REM_HIGHL:
          { 
            /*  remove highlight of member / draw  */
            dp$display(msg  = &msg,
                       mode = GRbdhe,
                       oids = &cur_grid); 
            if (!(1&msg))  Goto (wrapup);
            break;
          }   /*  REM_HIGHL...  */


        }   /*  switch (...  */
 
      }  /*    for (ii=0; ii<chan_count; */
    }  /*    if (chan_count...  */
  }  /*  if (1&sts...  */ 


  /*---  main element handling  ---*/
  switch (task)
  {

    case REAL_DEL:
    { 
      if (sts_sk == OM_S_SUCCESS)
      {
        break;
      }
      /*  delete curve element  */
      /*  element must be in rtree for delete  */
      sts = om$send(mode     = OM_e_wrt_object,
                    msg      = message GRgraphics.GRdelete(&msg,
                                                           obj_env),
                    senderid = NULL_OBJID,  
                    targetid = object.objid,
                    targetos = object.osnum);
      if (!(1 & sts & msg)) Goto (wrapup);
      break;
    }


    case REM_R_TREE:
    {
      if (SK_grid.objid == NULL_OBJID)
      {
        /*  erase element  */
        dp$display(msg  = &msg,
                   mode = GRbe,
                   oids = &object);
        if (!(1&msg))  Goto (wrapup);

        /*  remove element from R_tree  */
        sts = om$send(mode     = OM_e_wrt_object,
                      msg      = message GRgraphics.GRremwrng(&msg,
                                                              obj_env),
                      senderid = NULL_OBJID,
                      targetid = object.objid,
                      targetos = object.osnum);      
        if (!(1&(sts&msg)))  Goto (wrapup);

      }
      else 
      {
        /*  erase element  */
        dp$display(msg  = &msg,
                   mode = GRbe,
                   oids = & SK_grid);
        if (!(1&msg))  Goto (wrapup);

        /*  remove element from R_tree  */
        sts = om$send(mode     = OM_e_wrt_object,
                      msg      = message GRgraphics.GRremwrng(&msg,
                                                              obj_env),
                      senderid = NULL_OBJID,
                      targetid = SK_grid.objid,
                      targetos = SK_grid.osnum);      
        if (!(1&(sts&msg)))  Goto (wrapup);
      }
      break;
    }


    case ADD_R_TREE:
    {
      /*  add element to R_tree  */
      if (SK_grid.objid == NULL_OBJID)
      {
        sts = om$send(mode     = OM_e_wrt_object,
                      msg      = message GRgraphics.GRaddwrng(&msg,
                                                              obj_env),
                      senderid = NULL_OBJID,
                      targetid = object.objid,
                      targetos = object.osnum);      
        if (!(1&(sts&msg)))  Goto (wrapup);
      }
      else 
      {
        sts = om$send(mode     = OM_e_wrt_object,
                      msg      = message GRgraphics.GRaddwrng(&msg,
                                                              obj_env),
                      senderid = NULL_OBJID,
                      targetid = SK_grid.objid,
                      targetos = SK_grid.osnum);      
        if (!(1&(sts&msg)))  Goto (wrapup);
      }
      break;
    }

  }    /*  switch (...  */


  return TRUE;


wrapup:
   return FALSE;
}



end implementation ECtrim2;
