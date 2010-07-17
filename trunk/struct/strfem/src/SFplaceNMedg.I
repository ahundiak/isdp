class implementation  Root;
/* -------------------------------------------------------------------------
   Doc : SFplaceNMedges

   Description : This function places nonmanifold edges on the given surfaces
		 with the given curves.
   History :
   06-20-1994	Raju	Creation
------------------------------------------------------------------------- */

#include  "OMminimum.h"
#include  "OMprimitives.h"
#include  "OMerrordef.h"
#include  "igrtypedef.h"
#include  "igetypedef.h"
#include  "gr.h"
#include  "igr.h"
#include  "godef.h"
#include  "igrdp.h"       /* IGRdisplay */
#include  "go.h"
#include  "emsdattyp.h"   /* EMSdataselect */
#include  "grdpbdef.h"
#include  "grdpbmacros.h"
#include  "emsmapdef.h"
#include  "nmdef.h"

extern  OMuword  OPP_NMnonmanibnd_class_id;

from    NMnonmanibnd	import	NMcreate_boundaries;

long  SFplaceNMedges(
  long 		*msg,			/* O - return status		*/
  int		num_sfs,		/* I - no. of surfaces		*/
  struct GRid	*surfid,		/* I - object ids of surfaces	*/
  int		*num_cvs_persf,		/* I - no. of curves on each surface */
  struct GRid	*cvs,			/* I - object ids of curves	*/
  struct GRmd_env *ModEnv )		/* I - Mod Env of surfaces and curves*/
{

struct  EMSdataselect	*curves;
struct  GRvg_construct	cnst;
IGRushort		map_options,
			nm_options;
char			*status_str = "Processing";
struct  GRid		nmid;
int			numberOfBytes,
			BytesReceived;
int			ii, total_cvs;
short			ActiveLevel;
struct IGRdisplay	ActiveDisplay;
long			sts;


	*msg = 1;
	total_cvs = 0;
	for( ii=0; ii<num_sfs; ii++)
	   total_cvs += num_cvs_persf[ii];

	curves = ( struct EMSdataselect *) malloc ( sizeof(struct EMSdataselect)
							*  total_cvs );

	for(ii=0; ii<total_cvs; ii++)
	{
	   curves[ii].datatype = EMSdata_object;
	   curves[ii].data.object = &cvs[ii];
	}

	numberOfBytes = sizeof ( ActiveLevel );
	gr$get_active_layer( msg    = msg,
			     sizbuf = &numberOfBytes,
			     buffer = &ActiveLevel,
			     nret   = &BytesReceived );

	numberOfBytes = sizeof ( ActiveDisplay );
	gr$get_active_display( msg    = msg,
			       sizbuf = &numberOfBytes,
			       buffer = &ActiveDisplay,
			       nret   = &BytesReceived );

	cnst.msg = msg;
	cnst.env_info = ModEnv;
	cnst.newflag = FALSE;
	cnst.geometry = NULL;
	cnst.class_attr = NULL;
	cnst.level = ActiveLevel;
	cnst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	cnst.display = &ActiveDisplay;
	cnst.name = NULL;

	map_options =   EMMapBnd_WantBadCurves |
			EMMapBnd_StrokeIfNeeded | EMMapBnd_NoValidate |
			EMMapBnd_NoFixing | EMMapBnd_ClipBdryArea |
			EMMapBnd_NoRmvColEds;

	nm_options = NULL;
/* if not associative then */
	nm_options |=  NMcreatebnd_NoCurveAssoc;

	sts = om$construct(osnum = surfid[0].osnum,
			   classid = OPP_NMnonmanibnd_class_id,
			   p_objid = &nmid.objid,
			   msg = message NMnonmanibnd.NMcreate_boundaries(
						msg, num_sfs, surfid,
						num_cvs_persf, curves,
						ModEnv,
						&cnst,
						map_options, nm_options,
						status_str));
	if ( !(sts & *msg & 1) )
	 printf("SFplaceNMedges : NMnonmanibnd.NMcreate_boundaries faulire\n");

	if ( curves ) free (curves);
	return sts;

}

end implementation Root;
