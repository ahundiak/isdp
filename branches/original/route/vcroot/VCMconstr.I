
/* $Id: VCMconstr.I,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vcroot / VCMconstr.I
 *
 *          ACconstruct_feet for macro based entities
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCMconstr.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/03/14  20:05:24  pinnacle
# Replaced: vcroot/VCMconstr.I for:  by kddinov for route
#
# Revision 1.2  1998/02/21  19:12:34  pinnacle
# Replaced: vcroot/VCMconstr.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.2  1997/08/11  21:39:20  pinnacle
# Replaced: vcroot/VCMconstr.I for:  by hverstee for cabling
#
# Revision 1.1  1997/07/14  21:59:46  pinnacle
# Created: vcroot/VCMconstr.I by hverstee for cabling
#
 *
 * History:
 *  06/10/96  hv      initial
 *
 *************************************************************************/

class implementation VCMac;

extern GRclassid  OPP_ACheader_class_id;
extern GRclassid  OPP_ACconst_class_id;

/*
#define MY_DEBUG
*/

method ACconstruct_feet( IGRlong    *msg;
                         IGRint      cn_type;
                         IGRint      count;
                  struct GRid       *list; 
                  struct GRmd_env   *md_env;
                         int        *fcount;
                  struct GRid       *feet_list)
{
  IGRlong        retmsg;
  IGRint         status;

  extern IGRboolean   dynamics_in_progress;

  *msg = MSSUCC;

  *fcount  = 0;
  feet_list[0].objid = NULL_OBJID;
  feet_list[0].osnum = OM_Gw_current_OS;

  /*   no graphics for virtual    */

  if (me->nVCType & VC_GEN_VIRTUAL) return (OM_S_SUCCESS);

  /* One graphic will be built */

#ifdef MY_DEBUG
  printf (" Construct term enter\n");
#endif

  /* -- Check whether I am a clone for dynamics or not -- */

  if ( me->nVCStat & VC_CLONE )
  {
    if (  dynamics_in_progress )
    {
      /*| TEMPORARY CLONE*/
      status = 
      om$send (msg = message VCRoot.VCSetStatus (VC_DUMB_DEL, VC_DUMB_DEL),
          targetid = my_id);
    }
    /* -- reset clone status -- */
    status = 
    om$send (msg = message VCRoot.VCSetStatus (VC_CLONE, (~VC_CLONE)),
        targetid = my_id);
  }

  if ( me->nVCStat & VC_ERROR )
  {
    /* -- reset error status -- */
    status = 
    om$send (msg = message VCRoot.VCSetStatus (VC_ERROR, (~VC_ERROR)),
        targetid = my_id);
  }

  /* -------------------- */
  /* -- Build Graphics -- */
  /* -------------------- */

  /*| Place component as a symbol */

  if (me->nVCType & VC_GEN_BITERM)
  { /*   dedicated     for embedding    */
    status =
    om$construct(   classid = OPP_ACconst_class_id,
                    p_objid = &feet_list[0].objid, 
                    osnum   = feet_list[0].osnum );
  }
  else
  { /*   shared        for designfile size   */
    status =
    om$construct(   classid = OPP_ACheader_class_id,
                    p_objid = &feet_list[0].objid, 
                    osnum   = feet_list[0].osnum );
  }

  *fcount = 1;

  if ( !(status & OM_S_SUCCESS) )
  {
    /*| ERROR -> ACheader no created */
    goto VC_BUILD_ERROR;
  }

  /* and place the macro    */

  status=
  om$send ( msg = message VCMac.VCMacroPut (&retmsg, feet_list, md_env),
       targetid = my_id);

  if (retmsg & status & OM_S_SUCCESS)
  {
    status=
    om$send ( msg = message NDnode.NDmove_to_root
                                   (&retmsg, feet_list, md_env),
         targetid = feet_list[0].objid,
         targetos = feet_list[0].osnum);
    as$status ();

  /*" graphics id = %d, %d\n",feet_list[0].objid, feet_list[0].osnum */

    return status;
  }

  /* ------------------------------ */
  /* -- ERROR Graphics treatment -- */
  /* ------------------------------ */


  /*| An ERROR occurred after having placed the macro occurrence*/
  /* -- Delete the macro occurrence before placing the error graphics */

  status=
  om$send ( msg = message NDnode.NDdelete ( md_env ),
       targetid = feet_list[0].objid,
       targetos = feet_list[0].osnum);
  as$status ( );

  feet_list[0].objid = NULL_OBJID;

VC_BUILD_ERROR:

  /*| Get Error graphic */

  /* -- Set status to VC_ERROR -- */
  status = 
  om$send ( msg = message VCRoot.VCSetStatus (VC_ERROR, VC_ERROR),
       targetid = my_id);

  /* -- Build error graphics -- */

  status = 
  om$send ( msg = message VCMac.VCMErrGraphic (&retmsg, feet_list, md_env),
       targetid = my_id);

  return ( OM_S_SUCCESS );

}/* end of ACconstruct_feet */

end implementation VCMac;
