class implementation Root;
#include "stdio.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "tools.h"
#include "FI.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <gr.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "nddef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "griodef.h"
#include "asbox.h"
#include "asmacros.h"
#include "griomacros.h"
#include "refdef.h"
#include "EMSasnucdef.h"

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"
#include "assemconstr.h"

from NDnode     import NDget_objects;
from EMdescribe import EMget_memb, EMget_type, EMget_props, EMpass;
from EMinstance import EMget_incident_constr;

extern OMuword OPP_EMconstr_class_id;

typedef struct cnstr_prts_info_st 
{
    struct GRid prt_id;
    int         depth;
    long	props;
}EMcprt_info;

%safe
static EMcprt_info * EMcprts = NULL;
static IGRshort      EMcprts_mem_size = 0;
static IGRshort      EMcprts_count = 0;
static IGRshort      EMcprts_max_depth = 0;
%endsafe

typedef struct EMprt_pass_info_st
{
    int inq_type;
    int max_depth;
    struct GRmd_env env;
}EMprt_pass_info;

/*
 * This is the pass_function sent to the EMdescribe objects to collect
 * all the constrained instances.
 */
IGRlong EMget_cnstr_prts (IGRlong   * msg,
                    struct GRmd_env * mod_env,
                    IGRint            depth,
                    IGRchar         * info,
                    struct GRid     * desc_id)

{
    IGRlong     om_msg = OM_S_SUCCESS;
    IGRuint	props;
    IGRint      type, cnstr_found = FALSE;
    EMprt_pass_info *prt_info = ( EMprt_pass_info * )info;
    
    *msg = ASM_S_SUCCESS;

    if( prt_info->inq_type & INQ_MAX_DEPTH ) /* Interested only in MAX_DEPTH */
    if (depth > EMcprts_max_depth)
    {
        EMcprts_max_depth = depth;
        return(OM_S_SUCCESS);
    }

    if(( prt_info->max_depth != -1 ) && (depth > prt_info->max_depth))
        return( OM_I_STOP_SENDING );

    /*
     * Get the type and props of the describe obj.
     */
    om_msg = om$send (msg = message EMdescribe.EMget_type (msg, &type),
                      senderid = NULL_OBJID,
                      targetid = desc_id->objid,
                      targetos = desc_id->osnum);

    if( !(om_msg & *msg & 1 ))
    {
        goto quit;
    }

#ifdef DEBUG
    printf("descobjid = %d osnum = %d",desc_id->objid, desc_id->osnum);
    printf("  at depth=%d of type=%d\n", depth, type);
#endif

    if( prt_info->inq_type & INQ_PROPS )
    {
        om_msg = om$send (msg = message EMdescribe.EMget_props (msg, &props),
                      senderid = NULL_OBJID,
                      targetid = desc_id->objid,
                      targetos = desc_id->osnum);
    
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }
        
    if (type & EM_REFERENCE_PART) 
    {
    IGRint num_inc;
    struct GRid inc_constr[MAX_INCIDENT_CONSTR];

        if( prt_info->inq_type & INQ_PRT_WITH_INC_CNSTR )
        {
            /*
             * Check to see that atleast one constraint is into this object.
             */
            om_msg = om$send( msg = message EMinstance.EMget_incident_constr( msg,
                                                                &num_inc,
                                                                inc_constr ),
		                    senderid = NULL_OBJID,
                                 targetid = desc_id->objid,
                                 targetos = desc_id->osnum );
            if( om_msg & *msg & 1 )
            {
                if( num_inc > 0 )
                {
                    cnstr_found = TRUE;
#ifdef DEBUG
printf("part %d ( os = %d ) has INC constr\n", desc_id->objid, desc_id->osnum);
#endif
                    if ( EMcprts_count == (EMcprts_mem_size - 1))
                    {
                        EMcprts_mem_size += 10;
                        EMcprts = (EMcprt_info *)realloc( EMcprts, 
		    		    EMcprts_mem_size * sizeof( EMcprt_info ));
                    }

                    EMcprts[EMcprts_count].depth = depth;    
		    if (depth > EMcprts_max_depth)
		    {
		        EMcprts_max_depth = depth;
		    }

                    if( prt_info->inq_type & INQ_PROPS )
                        EMcprts[EMcprts_count].props = props;    
                    EMcprts[EMcprts_count].prt_id.objid = desc_id->objid;
                    EMcprts[EMcprts_count++].prt_id.osnum = desc_id->osnum;
                }
            }
        }
        if( !cnstr_found )
        if( prt_info->inq_type & INQ_PRT_WITH_OUT_CNSTR )
        {
        struct GRid *list;
        int cnt, i;
        OMuword classid;

            om_msg = om$send( msg = message NDnode.NDget_objects(ND_CHILDREN|
                                                                 ND_IN_BUF,
                                        NULL,0,&list,0,OM_K_MAXINT,&cnt),
                     senderid = NULL_OBJID,
                     targetid = desc_id->objid,
                     targetos = desc_id->osnum);

            if (om_msg & 1)
            {
                for (i = 0; i < cnt; i++)
                {
                    om$get_classid (objid = list[i].objid, 
                                    osnum = list[i].osnum,
                                    p_classid = &classid);

                    if (om$is_ancestry_valid (subclassid = classid,
                        superclassid = OPP_EMconstr_class_id) == OM_S_SUCCESS)
                    {
                        cnstr_found = TRUE;
#ifdef DEBUG
printf("part %d ( os = %d ) has OUT constr\n", desc_id->objid, desc_id->osnum);
#endif
                        if ( EMcprts_count == (EMcprts_mem_size - 1))
                        {
                            EMcprts_mem_size += 10;
                            EMcprts = (EMcprt_info *)realloc( EMcprts, 
		    		    EMcprts_mem_size * sizeof( EMcprt_info ));
                        }

                        EMcprts[EMcprts_count].depth = depth;    
	                if (depth > EMcprts_max_depth)
		        {
		            EMcprts_max_depth = depth;
		        }

                        if( prt_info->inq_type & INQ_PROPS )
                            EMcprts[EMcprts_count].props = props;    
                        EMcprts[EMcprts_count].prt_id.objid = desc_id->objid;
                        EMcprts[EMcprts_count++].prt_id.osnum = desc_id->osnum;

			break; /* Found a constraint, so break */
                    }
                }
            }
        }
    }

quit:

    return om_msg;
}

IGRboolean EMis_prt_constrainable(struct GRmd_env * mod_env,
                         IGRint            depth,
                         IGRchar         * info,
                         struct GRid     * desc_id)
{
    IGRlong      om_msg, msg = OM_S_SUCCESS;
    IGRboolean   select = TRUE;
    IGRint       type = 0;

    info = NULL; depth = 0; mod_env = NULL; /* Done to quiet compiler. */
    
    om_msg = om$send (msg = message EMdescribe.EMget_type (&msg, &type),
                      senderid = NULL_OBJID,
                      targetid = desc_id->objid,
                      targetos = desc_id->osnum);
    
    if (!(om_msg & msg & 1) ||
        !(type & (EM_LOCAL_PART | EM_CACHED_PART | EM_FILE_PART)))
    {
        select = FALSE;
    }

#ifdef DEBUG
    if( select )
      printf("selected type=%d\n",type);
#endif
    return select;

}

/* It is the responsibility of the caller to free the memory allocated
 * to the list being returned.
 *
 * The I/O variable inq_depth is used differently as follows:
 *
 *          1. When options is set with INQ_MAX_DEPTH, the OUTPUT maximum
 *             depth is returned in this variable and NO cpart_list is returned.
 *          2. When options is NOT set with INQ_MAX_DEPTH, the INPUT maximum
 *             depth in this variable is used to form the cpart_list.
 */

IGRlong EMget_cpart_list( struct GRid *first_level_part, /* I */
			  struct GRmd_env *part_env,     /* I */
			  int *inq_depth,                /* I/O */
			  int options,			 /* I */
			  struct GRid **cpart_list,      /* O */
                          int *cpart_count               /* O */
			)
{
int i, om_msg;
IGRlong msg;
EMprt_pass_info info;

    if( EMcprts == NULL )
    {
        EMcprts = ( EMcprt_info * )malloc( sizeof( EMcprt_info ) * 10 );

        EMcprts_mem_size = 10;
    }

    if( !options )
	info.inq_type = INQ_PROPS | INQ_ALL_PRT_WITH_CNSTR;
    else
	info.inq_type = options;

    info.max_depth = *inq_depth;
    om_msg = om$send (msg = message EMdescribe.EMpass (&msg,
                                                       part_env,
                                                       0,
                                                       EMget_cnstr_prts,
                                                       (char *)&info,
                                                       EMis_prt_constrainable),
                          senderid = NULL_OBJID,
                          targetid = first_level_part->objid,
                          targetos = first_level_part->osnum);

    if( options & INQ_MAX_DEPTH )
    {
        *inq_depth = EMcprts_max_depth;
        EMcprts_max_depth = 0; /* reinitialise the static */
        return( OM_S_SUCCESS );
    }

#ifdef DEBUG
printf("Total Number of parts with constraint in/out = %d\n", EMcprts_count);
for(i=0;i<EMcprts_count;i++)
printf("cprts[%d].objid=%d (os = %d)\n", i, EMcprts[i].prt_id.objid,
                                            EMcprts[i].prt_id.osnum );
#endif

    *cpart_list = (struct GRid *)malloc( EMcprts_count * sizeof( struct GRid));

    for ( i = 0; i < EMcprts_count ; i++ )
    {
        (*cpart_list)[i].objid = EMcprts[i].prt_id.objid;
        (*cpart_list)[i].osnum = EMcprts[i].prt_id.osnum;
    }
    *cpart_count = EMcprts_count;

    free( EMcprts );

    /* REINITIALISE THE STATICS */
    EMcprts = NULL;
    EMcprts_mem_size = 0;
    EMcprts_count = 0;
    EMcprts_max_depth = 0;

    return( OM_S_SUCCESS );
}
end implementation Root;
