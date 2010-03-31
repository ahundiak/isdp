/* ###################   APOGEE COMPILED   ################## */
class implementation EMSplane;

/*
History

    AIC  15 Oct 1990 Genesis 2.0.0
    Jack 15 May 1991 Modified for 2.0.1 horizon loop/cusp implementation. 
    NP   19 Aug 1992 Modified for ANSI compliance. Correct typecast in the
                     "om$get_channel_count" macro.
*/


method EMinit_display(IGRlong          *EMmsg;
                      struct GRmd_env  *md_env )

{
  IGRint   sts, 
           ls_count;
  OM_S_CHANSELECT  to_loopset;

  *EMmsg = EMS_S_Success;

  sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
   
  sts = om$get_channel_count(objid = my_id,
                             p_chanselect = &to_loopset,
                             count = (IGRuint *)&ls_count);
  if(! (1 & sts)) goto wrapup;

  if(! ls_count)
    sts = om$send(msg = message EMSsurface.EMmk_nat_bdry(
                                           EMmsg, 
                                          &md_env->md_env, 
                                           NULL),
                  targetid = my_id);

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSplane.EMinit_display")
  return( sts );
}

end implementation EMSplane;
