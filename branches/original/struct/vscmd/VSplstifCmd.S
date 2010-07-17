/*
	I/STRUCT
*/
class specification VSplstifCmd (1:0) of VSplbeamCmd ;



#include "growner.h"


instance VSplstifCmd
{
	struct GRobj_env	SideObj ;	/* Side of plate selected.   */
	int			TypeSide ;	/* Bottom or top side of     */
						/* plate.		     */
	struct GRobj_env	PlateObj ;	/* Plate located.	     */
	struct GRobj_env	*SurfLineObj ;	/* Surface or line for	     */
						/* axis's direction.	     */
	struct GRobj_env	StartObj ;	/* Start surface limit.      */
	struct GRobj_env	EndObj ;	/* End surface limit.	     */
	int			CanPlacedAlPl ; /* Stiffener can be placed   */
						/* along plane ?	     */
	double			InternalYOff ;  /* Internal Y offset to have */
						/* the stiffener outside of  */
						/* plate ( set to height of  */
						/* cross section when        */
						/* symmetry is 'XY' or 'X',  */
						/* otherwise, set to 0. ).   */
	struct GRid		exp;		/* expression 		     */
	double			angle[2] ;	/* start/end angles	     */
	char			refType[2] ;	/* reference types 	     */
	char			*rotDefForm ;	/* Twist information form    */
} ;


override sleep ;

override delete ;

override init_cmd ;

override process_fence ;

message store_element( long *msg ; int index ) ;

message store_null_objid( int index ) ;

message hilight_side( int *sts ) ;

message unhilight_side( int *sts ) ;

message swap_side( int *sts ) ;

message construct_axis( long *msg ) ;

message delete_axis( int *sts ) ;

override form_notification ;

message initForm( int *sts ) ;

message sub_form_notification( char *form_ptr ; int gadget_label );

message construct_surface( long *msg ) ;

message	delete_surface(long *msg) ;

message SetLastPlSiId( long *msg ) ;

override get_modifiable_gadgets ;

override load_attributes ;

override load_attributes_from_beam ;

override construct_beam ;

override enable_form ;

override inter_display ;

end specification VSplstifCmd ;

