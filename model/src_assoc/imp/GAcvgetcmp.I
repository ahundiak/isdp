/* #################   APOGEE  COMPILED   ######################### */
class implementation GAcurve;

#include "OMprimitives.h"
#include "OMmacros.h"
#include "EMSkey.h"
#include "REcurve.h"

from EMSsurface import EMtranslate_id_key;

extern OMuword OPP_EMSboundary_class_id;

method GAget_msc_component(IGRlong *EMmsg; GRobjid *component_id;
                           OMuword *component_os)

/*
Description
  This method returns the associative model-space counterpart's component
(edge or loop) object id and object space number.

Arguments
    name         I/O                         description
---------------- ---   ------------------------------------------------------
  EMmsg           O    Return message; EMS_S_Success if the component is
                       returned, EMS_E_Fail otherwise
  component_id    O    the objid of the edge or loop from which this MSC
                       was created
  component_os    O    the osnum of the edge or loop from which this MSC
                       was created

History
  WBC    05/31/91    Creation
*/
{
    IGRlong OM_stat;
    IGRint info_size,key_size;
    OM_S_CHANSELECT father_chansel;
    struct GRid creator_grid;
    struct EMSobjid_key  edge_id_key;
    struct EMSnoncountkey *noncount_key;
    struct EMSlong_key *long_key;
    struct GRmd_env md_env;

    OM_stat = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;

    switch (ME.EMSassoc->type)
    {
        case EMSmsc_id:
            *component_id= *(OM_S_OBJID *)ME.EMSassoc->info;
            *component_os = OM_Gw_current_OS;
            break;

        case EMSmsc_key:
            /* find the parent of this MSC */

            OM_stat = om$make_chanselect(channame = "NDfather.father",
                                         p_chanselect = &father_chansel);
            EMerr_hndlr(!(1 & OM_stat), *EMmsg, EMS_E_Fail, wrapup);

            OM_stat = om$send(msg = message NDnode.ASreturn_go(
                                     &creator_grid, &md_env.md_env.matrix_type,
                                     md_env.md_env.matrix),
                              p_chanselect = &father_chansel,
                              from = 0,
                              to = 0);
            EMerr_hndlr(!(1 & OM_stat & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

            info_size = om$dimension_of(varray = ME.EMSassoc->info);
	{
		char *pop;
		pop = me^^EMSassoc.info;
            OM_stat = om$send(msg = message EMSsurface.EMtranslate_id_key
                                            (EMmsg, EMS_OPT_ID_FROM_KEY,
                                             &md_env, component_id,
                                              &info_size, 
					      &pop),
                              targetid = creator_grid.objid,
                              targetos = creator_grid.osnum);
	}
            *component_os = creator_grid.osnum;
            break;

        case EMSmsc_id_key:
            edge_id_key = *(struct EMSobjid_key *)ME.EMSassoc->info;
            if(ASMget_splitpart() == TRUE)
             {
	        char  *n_key;

                OM_stat = om$make_chanselect(channame = "NDfather.father",
                                             p_chanselect = &father_chansel);
                EMerr_hndlr(!(1 & OM_stat), *EMmsg, EMS_E_Fail, wrapup);

                OM_stat = om$send(msg = message NDnode.ASreturn_go(
                                      &creator_grid, &md_env.md_env.matrix_type,
                                     md_env.md_env.matrix),
                                  p_chanselect = &father_chansel,
                                  from = 0,
                                  to = 0);
                EMerr_hndlr(!(1 & OM_stat & *EMmsg),*EMmsg, EMS_E_Fail,wrapup);

                info_size = om$dimension_of(varray = ME.EMSassoc->info);

		n_key = (char *)edge_id_key.key_info;
		key_size = info_size - sizeof(struct EMSobjid_key);

                 OM_stat = om$send(msg = message EMSsurface.EMtranslate_id_key
                                            (EMmsg, 
					     EMS_OPT_ID_FROM_KEY|
	 				     EMS_OPT_KEY_FROM_ID,
                                             &md_env, component_id,
                                              &info_size,
                                              &n_key),
                              targetid = creator_grid.objid,
                              targetos = creator_grid.osnum);
	    	 *component_os = OM_Gw_current_OS;
            }
	    else
	    {
            	*component_id = edge_id_key.objid;
            	*component_os = OM_Gw_current_OS;
	     }
            break;

	case EMSmsc_match_failed:
            *EMmsg = EMS_E_Fail;
            break;

	case EMSmsc_noncount_key:
	    noncount_key = (struct EMSnoncountkey *)ME.EMSassoc->info;
	    *component_id = noncount_key->objid;
	    *component_os = OM_Gw_current_OS;
	    break;
	case EMSmsc_long_key:
	    long_key = (struct EMSlong_key *)ME.EMSassoc->info;
            if(ASMget_splitpart() == TRUE)
             {
	        char  *n_key;

                OM_stat = om$make_chanselect(channame = "NDfather.father",
                                             p_chanselect = &father_chansel);
                EMerr_hndlr(!(1 & OM_stat), *EMmsg, EMS_E_Fail, wrapup);

                OM_stat = om$send(msg = message NDnode.ASreturn_go(
                                      &creator_grid, &md_env.md_env.matrix_type,
                                     md_env.md_env.matrix),
                                  p_chanselect = &father_chansel,
                                  from = 0,
                                  to = 0);
                EMerr_hndlr(!(1 & OM_stat & *EMmsg),*EMmsg, EMS_E_Fail,wrapup);

                info_size = om$dimension_of(varray = ME.EMSassoc->info);

		n_key = (char *)long_key->key_info;

		EMcheckfor_offset_corruption(n_key,info_size);
	        if( long_key->noncount_st.offset >0)
		  key_size = long_key->noncount_st.offset - 
			     sizeof(struct EMSlong_key);
		else
		  key_size = info_size - sizeof(struct EMSlong_key);

                 OM_stat = om$send(msg = message EMSsurface.EMtranslate_id_key
                                            (EMmsg, 
					     EMS_OPT_ID_FROM_KEY|
	 				     EMS_OPT_KEY_FROM_ID,
                                             &md_env, component_id,
                                              &info_size,
                                              &n_key),
                              targetid = creator_grid.objid,
                              targetos = creator_grid.osnum);
	    	 *component_os = OM_Gw_current_OS;
            }
            else
	     {
	        *component_id = long_key->objid;
	        *component_os = OM_Gw_current_OS;
	     }
	    break;
        default:
            *EMmsg = EMS_E_Fail;
            break;
    }
    EMerr_hndlr(!(1 & OM_stat & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
  /*
   * Validate the object id, it should be of EMSboundary ancestry
   */
  
  
  if(1& OM_stat & *EMmsg)
  {
    IGRboolean IsEdgeOrLoop = FALSE;
    
    IsEdgeOrLoop = EFisAncestryValid(EMmsg, *component_id, *component_os,
    				     OPP_EMSboundary_class_id, TRUE);
    if(!IsEdgeOrLoop)
    {
#ifdef DEBUG
      printf("Id: %d, Classid: %d not of EMSboundary ancestry\n", *component_id, this_classid);
#endif      
      *EMmsg = EMS_E_Fail;
    }
  }
  
  EMWRAPUP(*EMmsg, OM_stat, "GAcurve.GAget_matching_msc")
  return(OM_stat);
}

end implementation GAcurve;
