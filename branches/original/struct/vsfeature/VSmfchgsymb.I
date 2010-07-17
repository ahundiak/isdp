/*
	I/STRUCT
*/
class implementation VSmodFeature ;

#include "OMmacros.h"
#include "vsdbgmacros.h"

#omdef BUBBLE_UP( Message )
	om$send(	msg	= message VSfeature.VSsendToEveryoneUp(
							&Msg,
							OM_e_wrt_message,
							message Message ),
			targetid= my_id ) ;
#endomdef
/*----------------------------------------------------------------------------*/
method GRchgcolor( long *msg ; unsigned int *rgb ; unsigned short *co ) {
	long	Msg ;
	return BUBBLE_UP( Message = ACncpx.GRchgcolor( msg, rgb, co ) ) ;
} 
/*----------------------------------------------------------------------------*/
method GRchgdp( long *msg ; struct IGRdisplay *dp ) {
	long	Msg ;
	return BUBBLE_UP( Message = ACncpx.GRchgdp( msg, dp ) ) ;
} 
/*----------------------------------------------------------------------------*/
method GRchglevel( long *msg ; short *lv ) {
	long	Msg ;
	return BUBBLE_UP( Message = ACncpx.GRchglevel( msg, lv ) ) ;
} 
/*----------------------------------------------------------------------------*/
method GRchgstyle( long *msg ; unsigned char *st ) {
	long	Msg ;
	return BUBBLE_UP( Message = ACncpx.GRchgstyle( msg, st ) ) ;
} 
/*----------------------------------------------------------------------------*/
method GRchgweight( long *msg ; unsigned char *wt ) {
	long	Msg ;
	return BUBBLE_UP( Message = ACncpx.GRchgweight( msg, wt ) ) ;
} 
/*----------------------------------------------------------------------------*/
method GRputsymb( long *msg ; struct GRsymbology *sb ) {
	long	Msg ;
	return BUBBLE_UP( Message = ACncpx.GRputsymb( msg, sb ) ) ;
} 
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;
