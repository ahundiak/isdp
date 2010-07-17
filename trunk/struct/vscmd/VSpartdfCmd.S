/*
	I/STRUCT
*/
class specification VSpartdfCmd (1:0) of VSlocateCmd ;

#include "growner.h"
#include "vsqryrdbdef.h"

instance VSpartdfCmd {
	int			flag ;
	unsigned long		partType ;	     /* Part type	      */
	char			*beamForm,	     /* Beam form ptr	      */
				*plateForm,	     /* Plate form ptr	      */
				*usrAttrForm ;
	struct GRobj_env	partObj ;	     /* Part Id + Env	      */
	struct GRid		face ;		     /* Id of selected face   */
	char			mat[VS_K_MAXDBNAME], /* Part's material       */
				fam[VS_K_MAXDBNAME], /* Part's family         */
				num[VS_K_MAXDBNAME]; /* Part's number         */
} ;

override	wakeup,
		sleep,
		form_notification,
		initial_form_notification,
		window_notification ;

message initCmd() ;

message cleanUp() ;

message toggleCommand() ;

message store_part( long *msg ) ;

message display_work_form( long *msg ) ;

message create_form( long *msg; char *form_name ) ;

message fill_form( long *msg ) ;

message fill_section_parameters( long *msg ) ;

message fill_section_area_and_length() ;

message draw_section();

message hiliteBeamFace(	struct GRobj_env	*beam ;
			char			*faceName ;
			enum GRdpmode		mode ) ;


end specification VSpartdfCmd ;
