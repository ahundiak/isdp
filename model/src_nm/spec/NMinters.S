/*
Abstract

	This is an instantiable class, which is purely informational. It
is meant to track surface elements and store there oriented intersection. It 
provides this data upon request, in a standard format. It is an associative 
listener from the intersecting elements.

	Objects of this class are not graphic objects.
	
History

	SM	01-April-91	Genesis
	
*/

class specification NMinters (2:0) of EMScreator, NMassoctrans;

#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSasnuc.h"
#include "EMSasnucdef.h"
#include "EMSasopts.h"
#include "OMmacros.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsbool.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "nmdef.h"
#include "nmchandef.h"
#include "nm.h"
#include "EMcp.h"
#include "nddef.h"
#include "ndmacros.h"

channel int_channel
{
 (one_to_one) NMinters.to_other_int;
};

instance NMinters
{
 enum NMbooltype operation;
 channel int_channel to_other_int;
 IGRint num_inters;
 IGRdouble cht;
 IGRint num_datatypes[4];  /* number of doubles, longs, ints, shorts and
			      chars (in that order) stored in the packed
			      data vla.
			   */
 variable GRobjid storage_objs[]; /* Objects created if the data was
				     other that EMSdata_object. For internal
				     use only.
				  */
 IGRuchar props;
 variable IGRchar data[];
};

/* Reject the EMSassoc instance data and the relevant messages.
*/
override EMSassoc;
override
	EMput_info, EMget_info;


/* Reject the GRvg instance data and relevant messages.
*/
override GRvg;
reject
	GRputattr, GRgetattr, GRchghprops, GRchgcolor, GRchgdp, GRchglevel, 
	GRchgstyle, GRchgweight, GRgetsymb, GRputsymb;


/* Reject the GRconnector instance data and the relevant messages.
*/
override GRconnector;
reject
	GRrigidconn, GRflexconn, GRdisconn;


/* Cannot reject GRgraphics because ME.GRgraphics->properties are directly
   accessed in EMSassoc code, in a lot of places. Decided against numerous
   overrides.
   SM Sept 5, 1991.
*/
/****************
override GRgraphics;
reject
	GRgetprops, GRchgprops, GRgethprops;
******************/

from NDnode inherit NDdelete;

override
	EMinit_associative, 	/* Always set option EMS_no_const_assoc
				   and EMSinit_dont_store_recomp_info.
				*/
	NDget_objects,      /* If no children or all children are in delete
			       batch, put myself in delete batch and do not
			       return any objects.
			    */
	NDupdate,	     /* re-intersect */
	debug, 
	delete, 	    /* delete 'other int' */
	NMget_actid_funcs,    /* Set stopclsid = NMnonmani */
	EMtranslate_id_key;

message NMget_inters(IGRlong *EMmsg; struct EMSinters **inters, **other_inters;
		     struct EMSobject_info *op;
		     struct EMSsftracedata *tracedata;
                     enum NMbooltype *bool_type; IGRdouble *cht;
		     IGRushort options);

message NMput_inters(IGRlong *EMmsg; struct EMSinters *inters, *other_inters;
		     struct EMSobject_info *op;
		     enum NMbooltype *bool_type; IGRdouble *cht;
		     IGRushort options);
		
message NMintersect(IGRlong *EMmsg; enum NMbooltype bool_type;
		    IGRushort bool_opt; struct EMSobject_info *op;
                    struct EMSinters **inters, **vol_inters;
		    struct EMSsftracedata *nm_tracedata, *vol_tracedata;
		    IGRushort intopt;
                    struct GRvg_construct *construct;
		    GRobjid *intobj, *auxobj; IGRchar *status_str);

message NMmatch_inters(IGRlong *EMmsg; 
		       struct EMSinters *old_inters, *new_inters);

message NMdelete_inters(IGRlong *EMmsg; IGRboolean delete_other, do_display);

message NMdelete_storage_objs(IGRlong *EMmsg; IGRboolean delete_other);

message NMprop(IGRlong *EMmsg; IGRuchar options, *props);

message NMintcopy(IGRlong *EMmsg;
                  struct GRmd_env *obj_env;
                  struct GRmd_env *new_mdenv;
                  GRobjid         *newobjid;
                  struct EMcp_info *copy_info;
		  IGRushort nm_opt, bdry_options, sf_options);

end specification NMinters;
