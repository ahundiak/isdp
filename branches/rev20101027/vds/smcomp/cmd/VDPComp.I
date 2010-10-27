/* ----------------------------------------------------------------------------
 * I/VDS
 *
 * File :       vds/smcomp/cmd/VDPComp.I
 *
 * Description:
 *      Implementation of the following methods.
 *
 * Dependencies:
 *
 * History:
 *
 *      12/19/95        MSM             Creation
 *	09/18/96	msm		TR # 179603074
 *	Feb 19 '98	SSR		Chenges in load2150 for UOM on PME
 *
 * --------------------------------------------------------------------------*/

class implementation SMCmdComp;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "grmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griomacros.h"

#include "vdsmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDCmdDef.h"
#include "VDPdef.h"
#include "VDPzone.h"

#include "FI.h"

#define VD_FP             me^^CEO.forms[me->idx_form].form_ptr

method SMqueryCompartments ( long *msg )
{
    IGRint                      i,row, nbCtx=0;
    IGRlong                     status = OM_S_SUCCESS;
    struct  VDPcomp 		*Contexts;
    IGRchar			tmpstr[300];

    SetProc( SMCmdComp.VDPqueryCompartments ); Begin

    *msg = MSSUCC;

    status = VDPgetCompContexts( msg, &nbCtx, &Contexts );

    /* status = VDPgetZoneContexts( msg, "PmFPZone", &nbCtx, &Contexts ); */
    __CheckRC ( status, *msg, "VDPgetContexts", wrapup );

    __DBGpr_int("Number of contexts :", nbCtx );

    status = om$vla_set_dimension( varray = me->CompNameDesc,
                                  size    = nbCtx );
    CheckRC( status, 1 );

    memcpy (me->CompNameDesc, Contexts, nbCtx * sizeof (struct VDPcomp));

    row = 0;
    for( i = 0; i < nbCtx; i++ )
    {
	sprintf(tmpstr,"%-15.14s:%-81.80s:%s\0", me->CompNameDesc[i].SSCSnum,
					 me->CompNameDesc[i].Name,
					 me->CompNameDesc[i].Description );

	FIfld_set_list_text( VD_FP, G_SEL_PMECOMP, row++,0, tmpstr, FALSE );
    }

wrapup :
    _FREE(Contexts);

    End
    return status;

}

method load2150data( long *msg )
{
    IGRlong		status = OM_S_SUCCESS;
    IGRint		i,j,nbAttr=0;
    struct ACrg_coll	*Coll=NULL;

    SetProc( SMCmdComp.load2150data ); Begin

    *msg = MSSUCC;
    UI_status("Loading 2150 data ..");

    /* Access the PME database with the comp_name as the key to retrieve all
       attributes */

    status = VDPgetCompAttr( msg, me->CompPMObid, &nbAttr, &Coll ); 
    CheckRC( status, *msg );

    /* PME enabled flag is being stored as an attribute called pme_enabled */

    strcpy(me->save_att[0].name,"pme_enabled");
    me->save_att_type[0] = SM_STATIC_ATT | SM_USER_ATT ;
    me->save_att[0].desc.type = AC_ATTRIB_DOUBLE;
    me->save_att[0].desc.value.att_exp = 1.0;

    /*  This whole attributes thing is a Big mess. The previous implementation
	had a concept of needed attributes. So in order to accommodate that we
	have to do some Kludges. In PME not all attributes can be modified. 
	Only a few can be modified and posted.
    */

    for ( i = 0, j=1; i < nbAttr; i++ )
    {
	__DBGpr_str( "Attribute ", Coll[i].name );

	if( !strcmp( Coll[i].name, "sscs" ) ||
	    !strcmp( Coll[i].name, "cp_name" ) ||
            !strcmp( Coll[i].name, "title" ) ||
            !strcmp( Coll[i].name, "cog_x" ) ||
            !strcmp( Coll[i].name, "Ecog_x" )||  //These E, M attributes added
            !strcmp( Coll[i].name, "Mcog_x" )||  //for UOM in PME
            !strcmp( Coll[i].name, "cog_y" ) ||
            !strcmp( Coll[i].name, "Ecog_y" ) ||
            !strcmp( Coll[i].name, "Mcog_y" ) ||
            !strcmp( Coll[i].name, "cog_z" ) ||
            !strcmp( Coll[i].name, "Ecog_z" ) ||
            !strcmp( Coll[i].name, "Mcog_z" ) ||
            !strcmp( Coll[i].name, "floor_area" ) ||
            !strcmp( Coll[i].name, "Efloor_area" ) ||
            !strcmp( Coll[i].name, "Mfloor_area" ) ||
            !strcmp( Coll[i].name, "volume" ) ||
            !strcmp( Coll[i].name, "Evolume" ) ||
            !strcmp( Coll[i].name, "Mvolume" ) ||
            !strcmp( Coll[i].name, "FileObid" ) ||
            !strcmp( Coll[i].name, "VDSobjid" ))
	{
	    continue;
	} 
	
	strcpy( me->save_att[j].name,Coll[i].name );

	/* Something special for struct_coefficient */

	if( !strcmp ( Coll[i].name, "struct_coef" ) )
	    me->save_att_type[j] = SM_STATIC_ATT | SM_SYST_ATT;
	else
	    me->save_att_type[j] = SM_STATIC_ATT | SM_USER_ATT ;

	me->save_att[j].desc.type = Coll[i].desc.type;
	if (Coll[i].desc.type == AC_ATTRIB_DOUBLE || Coll[i].desc.type == SM_ATTRIB_INT)
	{
	    me->save_att[j].desc.value.att_exp = Coll[i].desc.value.att_exp;
	    __DBGpr_dbl ( "Value ", me->save_att[j].desc.value.att_exp );
	}
	else if (Coll[i].desc.type == AC_ATTRIB_TEXT )
	{
	    strcpy( me->save_att[j].desc.value.att_txt, Coll[i].desc.value.att_txt );
	    __DBGpr_str("Text ", me->save_att[j].desc.value.att_txt );
	}
	j++;
    }

    me->save_nb_att = j;

    UI_status(" ");

    End
    return OM_S_SUCCESS;
}

method set_compart_dbtype( long *sts )
{
    int       type;
    IGRdouble val_db;

    SetProc( SMCmdComp.set_compart_dbtype ); Begin

    *sts = OM_S_SUCCESS;


    if(SMGetAttr("pme_enabled",me->work_att,me->work_att_type,me->work_nb_att,
              &type,&val_db,(char *)NULL,(IGRshort *)NULL))
    {
	if (val_db > 0.9999 && me->mytype == MODIFY )
	{
	    me->select_opt = PME_MODIFY;
	    me->form_state = PME_MODIFY;
	}
	else if ( me->mytype == PLACE )
	    me->select_opt = DB_SELECT;
    }
    else
	me->select_opt = DB_SELECT;

    End
    return OM_S_SUCCESS;
}

end implementation SMCmdComp;
