/*
	I/STRUCT
*/
class implementation GRfm ;

#include <string.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "gr.h"
#include "grmsg.h"
#include "fontdef.h"
#include "fontmacros.h"
#include "EMSmsgdef.h"
#include "vsdrwdef.h"
/*----------------------------------------------------------------------------*/
void VSgetFontMgr( fontMgr ) struct GRid *fontMgr ; {

	/*
	 * Returns the id of the Font Manager.
	 */
	struct GRid	actMod ;

	ex$get_cur_mod(	osnum	= &actMod.osnum,
			id	= &actMod.objid ) ;
	
	ex$get_super(	mod_id		= actMod.objid,
			mod_osnum	= actMod.osnum,
			super_name	= FONTMGR_NO_NAME,
			create		= TRUE,
			super_class	= "GRfm",
			super_id	= &fontMgr->objid,
			super_osnum	= &fontMgr->osnum ) ;
} /* VSgetFomtMgr */
/*----------------------------------------------------------------------------*/
int VSretrieveFont( msg, fontName, fontPos )

long		*msg ;
const char	*fontName ;
short		*fontPos ; {

	/*
	 * Retrieves font whose physical name is specified in `fontName'.
	 * If font does not exist, returns the position of the default font
	 * and sets `*msg' to EMS_I_Fail. Otherwise sets `*msg' to MSSUCC.
	 */
	long				sts ;
	int				i ;
	short				fntPos ;
	char				localName[1+FONT_NAME] ;
	struct GRid			fontMgr ;
	unsigned char			*dfltFnt ;
	enum {
		useDefaultFont,			/* Since it went badly	*/
		tryOtherLcName,			/* Because already used	*/	
		alreadyLoaded,			/* Font already loaded	*/
		loadSuccessful }		/* At leat we did it !	*/
					action ;

	i = 0 ; strcpy( localName, fontName ) ;

	do {
		font$retrieve(	msg		= msg,
				font		= fontName,
				local_font_name	= localName,
				font_position	= &fntPos ) ;

		switch( *msg ) {
		case MSSUCC		: action = loadSuccessful ; break ;
		default			:
		case MSFAIL		:
		case GR_E_MxNoFtLdd	:
		case GR_E_FtNotFnd	: action = useDefaultFont ; break ;
		case GR_E_FtNmeLdd	: action = tryOtherLcName ;
					  sprintf( localName, "%s%d",
					  	   fontName, i ) ;
					  i = 0 ;
					  break ;
		case GR_E_FtLdd		: action = alreadyLoaded  ; break ;
		}
	} while( action == tryOtherLcName ) ;

	switch( action ) {
		case loadSuccessful	:
		case alreadyLoaded	:
			/*
			 * Font position has been returned anyway.
			 */
			*msg = MSSUCC ;
			break ;

		case useDefaultFont	:
			VSgetFontMgr( &fontMgr ) ;

			dfltFnt = (unsigned char *) VS_K_DRW_DFLT_FONT ;
			fntPos = -1 ;
			sts = om$send(	msg	= message GRfm.GRvirt_search(
								msg,
								dfltFnt,
								&fntPos ),
					senderid= fontMgr.objid,
					targetid= fontMgr.objid,
					targetos= fontMgr.osnum ) ;
			if( !( sts & 1 & *msg ) ) fntPos = 0 ;
			*msg = EMS_I_Fail ;
			break ;
	}
	*fontPos = fntPos ;

	return *msg & 1 ;

} /* VSretrieveFont */
/*----------------------------------------------------------------------------*/
int VSgetFontInfo( msg, virtFontNo, fontInfo )

long			*msg ;
short			virtFontNo ;
struct vfont_entry	*fontInfo ; {

	long		sts ;
	struct GRid	fontMgr ;

	*msg = MSFAIL ;

	VSgetFontMgr( &fontMgr ) ;
	sts = om$send(	msg	= message GRfm.GRfm_retdata(	msg,
								&virtFontNo,
								fontInfo ),
			senderid= fontMgr.objid,
			targetid= fontMgr.objid,
			targetos= fontMgr.osnum ) ;

	return sts & 1 & *msg ;

} /* VSgetFontInfo */
/*----------------------------------------------------------------------------*/

end implementation GRfm ;

