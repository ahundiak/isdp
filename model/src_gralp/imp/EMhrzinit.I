/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
/*
  EMhrzinit.I

  Horizon (graphics loop) init.
  
  History:
   JJC & SCW  3-18-91  Created from feature loop.
   AIC	      11-15-91 Do the graloop stuff, then set the creator id.

*/
class implementation EMShorizon;

method EMglpinit( IGRlong               *EMmsg;
                  IGRushort      props;
                  struct EMSpartolbasis *partolbasis; 
                  GRobjid                surf_id )
{
  IGRlong	sts;

  sts = om$send(msg = message EMSgraloop.EMglpinit(EMmsg, props, partolbasis,
  		surf_id), mode = OM_e_wrt_message, targetid = my_id);
  if(! (1 & sts)) goto wrapup;
  
  me->creator_id = my_id;

wrapup:
  EMWRAPUP( *EMmsg, sts, "In EMShorizon.EMglpinit" )
  return( sts );
}

end implementation EMShorizon;
