class implementation GRvg;
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "exmacros.h"
#define MAX_STACK_LEN 10
#define DOUBLE_SIZE 8

#define DEBUG 0

extern OMuword		OPP_EMSsubbs_class_id, OPP_GRcurve_class_id,
			OPP_EMScomposite_class_id, OPP_GRbspline_class_id,
			OPP_EMSsurface_class_id;


int spl_highlight (msg1,select_args,usdata)
IGRlong *msg1 ;
struct LC_select_args *select_args ;
char *usdata ;

{
int  sts ;
struct GRid pln_grid ;
struct GRmd_env mod_info ;
OM_S_CHANSELECT to_owners ;
struct  GRid parent;



	 pln_grid = select_args -> stack ->  entry[0].located_obj ; 

	 mod_info = select_args -> stack  -> entry[0].module_info ;

if (DEBUG)
	printf("objdect selected: %d %d\n", pln_grid.objid, pln_grid.osnum);

	 /* get parent objid */
        om$make_chanselect(channame = "GRconnector.to_owners",
                         p_chanselect = &to_owners);
      
        om$get_objid_at_index(osnum = pln_grid.osnum,
                           objid = pln_grid.objid,
                           p_chanselect = &to_owners,
                           index = 0,
                           objidaddr = &parent.objid,
                           osnumaddr = &parent.osnum);

        /* highlight objects */  
        highlight_obj(&parent,&mod_info,GRhhd);

        set_weight_of_plane(&pln_grid,2);

        highlight_obj(&pln_grid, &mod_info,GRhd);


        /* Now invoke lc$select to do accept/reject */
        sts = lc$select(msg = msg1,args = select_args );

	if( DEBUG )
		printf("after lc$select: %d\n", sts );

        /* unhighlight objects */
        highlight_obj(&pln_grid,&mod_info,GRhe); 

        set_weight_of_plane(&pln_grid,-2);

        highlight_obj(&parent,&mod_info,GRhe);

        return(sts);

}

plane_locate(response_data,prompt_l,loc_obj)
struct GRid *loc_obj ;
char *prompt_l ;
IGRchar *response_data ;

{

  IGRint	i, response,
	        num_objs ;

  IGRlong	stat_OM, msg  ;

  OMuword	rtreeclass[ 2 ];
  OMuword	classes[2];
  struct GRid	dummy_grid ;
  struct GRevent	locev, accev;
  struct GRlc_locate	lc_attr;
  OM_S_CLASSLIST	elig_classes, rtree_classes;

  struct GRlc_stack	lc_stack;

  num_objs = 0;
  dummy_grid.objid = NULL_OBJID;
  dummy_grid.osnum = 0;


  om$get_classid(classname = "EMSsubbs",
	       p_classid = &classes[0]);  

  elig_classes.w_count = 1;
  elig_classes.w_flags = OM_CLST_subclass;
  elig_classes.p_classes = classes;

  rtree_classes.w_flags = OM_CLST_subclass;
  rtree_classes.p_classes = rtreeclass;

  lc_attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
  lc_attr.owner_action = LC_RIGID_COMP | LC_FLEX_COMP;

  strcpy (lc_attr.classes, "EMSsubbs");

  rtree_classes.w_count = 1;
  rtreeclass[0] = OPP_EMSsurface_class_id;

  for (i=0; i < MAX_LCSTACK_LEN; i++)
    lc_stack.entry[ i ].located_obj.objid = NULL_OBJID;

  lc_stack.number_located = 0;
  lc_stack.num_entries = 0;


  stat_OM = lc$locate(rc = &msg, event1 = &locev, event2 = &accev,
		      response = &response, response_data = response_data,
		      locate_prompt = prompt_l,
		      acc_prompt = "accept/reject",
                      select = spl_highlight,
		      relocate_prompt = "",
		      attributes = &lc_attr,
		      stack = &lc_stack,
		      rtree_classes = &rtree_classes,
		      eligible_classes = &elig_classes);

  if (!(stat_OM)) {
    printf("locate error\n");
  };

  if( response == RESET ) 
           return (-1) ;
  

  if( response == D_RESET ) 
           return(-2) ;

  /* msg_loc IS LC_OBJS_IN_STACK */

  *loc_obj = accev . located_object[0].located_obj ;

  return(1);

}


set_weight_of_plane(grid,wt)
struct GRid *grid ;
int wt;
{

   int sts ;
   IGRlong  msg   ;
   struct GRsymbology symb ;
   char unsigned weight ;

   sts = om$send(msg = message GRvg.GRgetsymb(&msg,&symb),
                  targetid = grid -> objid,
                  targetos = grid -> osnum,
                   senderid = NULL_OBJID);

   weight = symb.display_attr.weight + wt ;


   printf("cur weight: %c", weight );


   sts = om$send(msg = message GRvg.GRchgweight(&msg,&weight),
                  targetid = grid -> objid,
                  targetos = grid -> osnum,
                   senderid = NULL_OBJID);

   return(1);
}

highlight_obj(obj,gmdenv,mode)
IGRlong mode;
struct GRid *obj;
struct GRmd_env *gmdenv ;
{
int sts ;
IGRlong  msg_loc ;
enum GRdpmode code ;
  
  code = (enum GRdpmode)mode ;

  sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
					&(gmdenv -> md_env.matrix_type),
					gmdenv -> md_env.matrix,
					&code, &(gmdenv -> md_id)),
          senderid = obj -> objid,
	  targetid = obj -> objid,
	  targetos = obj -> osnum);

  return(1);
}

end implementation GRvg;
