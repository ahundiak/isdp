class implementation ECexpldassy;

#include "OMerrordef.h"
#include "OMmacros.h"
#include "msdef.h"
#include <DItypedef.h>
#include <DIglob.h>
#include <DIprims.h>
#include "growner.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include <grerr.h>
#include "grsymmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "parametric.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "refdef.h"
#include "tabledef.h"
#include "table.h"

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

from GRtable import GRcreate, GRnum_columns, GRget_column, GRget_expression;
from GRtable import GRnum_rows, GRget_row, GRget_cell, GRrem_row;
from GRtable import GRadd_column, GRmod_cell, GRadd_row;
from NDnode  import NDget_objects, NDgive_structure;


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_table                                                     |
 |                                                                           |
 | This function returns the table for the input feature.                    |
 |                                                                           |
 | Input:   struct GRid     * feature_id       Associative object.           |
 |                                                                           |
 | Output:  IGRlong         * msg              Return code.                  |
 |          struct GRid     * table_id         Default table.                |
 |                                                                           |
 | Return:  MSSUCC            Constructed sucessfully.                       |
 |          MSFAIL            Catostrophic error.                            |
 |                                                                           |
 *---------------------------------------------------------------------------*/
IGRint EMget_table (IGRlong        * msg,
                     struct GRid    * feature_id,
                     struct GRid    * table_id)
{
    IGRlong           om_msg = OM_S_SUCCESS;
    IGRchar           pathname[DI_PATH_MAX], name[DI_PATH_MAX];
    IGRchar	      tmpname[DI_PATH_MAX];
    struct GRid       dir_id;
    
    *msg = MSSUCC;

    name[0] = '\0';
    pathname[0] = '\0';
    
    /*
     * Get the path to the table directory.
     */
    di$give_pathname (osnum = feature_id->osnum,
                      pathname = pathname);
    
    strcat (pathname, ":tables");

    /*
     * Make sure that directory is there.
     */
    if (di$translate (objname = pathname,
                      p_osnum = &dir_id.osnum,
                      p_objid = &dir_id.objid) != DIR_S_SUCCESS)
    {
        *msg = MSFAIL;
        goto quit;
    }
    
    /*
     * See if the graphic is named in the tables directory.
     * Changed this for assemblies - KK, donot use the path for searching
     * since, the filepart is named as :definition.
     */
    if (di$untranslate (objid = feature_id->objid,
                        osnum = feature_id->osnum,
/*                        path = pathname,*/
                        objname = tmpname) != DIR_S_SUCCESS)
    {
        *msg = MSFAIL;
        goto quit;
    }

    /* added this for assys */
    di$split (pathname = tmpname,
              name = name);

    /*
     * Get the table that cooresponds to the feature.
     */
    strcat (name, "_tbl");

    strcat (pathname,":");
    strcat (pathname,name);

    if (di$translate (objname = pathname,
                      p_objid = &table_id->objid,
                      p_osnum = &table_id->osnum) != DIR_S_SUCCESS)
    {
        *msg = MSFAIL;

        /*
         * Remove the feature's name in the tables directory.
         */
        di$rm_name (regexp = name);

        goto quit;
    }
    
 quit:
    
    return om_msg;
}

IGRint EMcreate_default_table( msg, env, tableid )
IGRlong *msg;
struct GRmd_env *env;
struct GRid *tableid;
{
int OMmsg;
struct GRid filprt, dir_id;
char pathname[DI_PATH_MAX], filprtname[DI_PATH_MAX];

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    OMmsg = asm$get_file_part (msg = msg,
                                mod_env = env,
                                part_id = &filprt);

    if( !( OMmsg & *msg & 1 ))
    {
        verbose(printf("Design file not a part\n"));
        goto quit;
    }

    if (di$untranslate (objid = filprt.objid,
                        osnum = filprt.osnum,
                        objname = pathname) != DIR_S_SUCCESS)
    {
        *msg = MSFAIL;
        verbose(printf("untranslate partname failed\n"));
        goto quit;
    }

    di$split (pathname = pathname,
              name = filprtname );

    tableid->osnum = env->md_id.osnum;    
    OMmsg = om$construct( classname = "GRtable",
			  osnum = tableid->osnum,
			  p_objid = &tableid->objid );

    if (!(OMmsg & 1))
    {
        verbose(printf("construct GRtable failed\n"));
        goto quit;
    }

    OMmsg = om$send ( msg = message GRtable.GRcreate (msg,
                                                      0,
                                                      NULL,
                                                      0,
                                                      NULL,
                                                      NULL),
                          senderid = NULL_OBJID,
                          targetid = tableid->objid,
			  targetos = tableid->osnum );

    if (!(OMmsg & *msg & 1))
    {
        verbose(printf("GRtable.GRcreate failed\n"));
        goto quit;
    }

    /* Name the table and associate it with the file_part */

    /*
     * Get the path to the table directory.
     */
    di$give_pathname (osnum = tableid->osnum,
                      pathname = pathname);

    strcat (pathname, ":tables");
    
    if (di$translate (objname = pathname,
                      p_osnum = &dir_id.osnum,
                      p_objid = &dir_id.objid) != DIR_S_SUCCESS)
    {
        strcat (pathname, ":");
        
        if (di$mkpath (pathname = pathname,
                       p_osnum = &dir_id.osnum) != DIR_S_SUCCESS)
        {
            *msg = MSFAIL;
            goto quit;
        }
        
        pathname[strlen(pathname)] = '\0';
    }

    /*
     * Name the table as partnumber_rev_tbl
     */

    strcat (filprtname, "_tbl");
    strcat (pathname,":");
    strcat (pathname,filprtname);
    
    if (di$add_name (objname = pathname,
                     objid = tableid->objid,
                     osnum = tableid->osnum) != DIR_S_SUCCESS)
    {
	verbose(printf("add_name failed\n"));
        *msg = MSFAIL;
    }

quit:
     return( OMmsg );
}

IGRint EMprint_table( table_id )
struct GRid *table_id;
{
int OMmsg = OM_S_SUCCESS;
IGRlong msg = MSSUCC;
int num_columns, num_rows, i, j;
GRtable_column_info   column;
GRtable_row_info      row;
GRtable_cell_info     cell;


    OMmsg = om$send (msg = message GRtable.GRnum_columns(&msg, &num_columns),
                      senderid = NULL_OBJID,
                      targetid = table_id->objid,
                      targetos = table_id->osnum);

    for (i=0; i<num_columns; i=i+1)
    {
        OMmsg = om$send (msg = message GRtable.GRget_column (&msg,     
                                                              &i,
                                                              NULL,
                                                              &column),
                          senderid = NULL_OBJID,
                          targetid = table_id->objid,
                          targetos = table_id->osnum);
    
    }

    OMmsg = om$send (msg = message GRtable.GRnum_rows(&msg, &num_rows),
                      senderid = NULL_OBJID,
                      targetid = table_id->objid,
                      targetos = table_id->osnum);
    
    for (i=0; i<num_rows; i=i+1)
    {
        OMmsg = om$send (msg = message GRtable.GRget_row (&msg,
                                                           &i,
                                                           NULL,
                                                           &row),
                          senderid = NULL_OBJID,
                          targetid = table_id->objid,
                          targetos = table_id->osnum);

        
        for (j=0; j<num_columns; j=j+1)
        {
            OMmsg = om$send (msg = message GRtable.GRget_cell (&msg,
                                                                i, j,
                                                                &cell),
                              senderid = NULL_OBJID,
                              targetid = table_id->objid,
                              targetos = table_id->osnum);

        }
    }

    return( OMmsg );
}

IGRint EMadd_def_row( msg, tblid, col, row, cell, numcol )
IGRlong *msg;
struct GRid *tblid;
GRtable_column_info * col;
GRtable_row_info    * row;
GRtable_cell_info   * cell;
int numcol;
{
int i, om_msg = OM_S_SUCCESS, number;
    
    *msg = MSSUCC;
    for( i = 0; i < numcol; i++ )
    {
        om_msg = om$send( msg = message GRtable.GRadd_column ( msg,
                                                          &col[i],
                                                          &number),
                                senderid = NULL_OBJID,
                                targetid = tblid->objid,
                                targetos = tblid->osnum );
    }
    om_msg = om$send( msg = message GRtable.GRadd_row ( msg,
                                                       row,
                                                       &number ),
                                senderid = NULL_OBJID,
                                targetid = tblid->objid,
                                targetos = tblid->osnum );

    if( !(om_msg & *msg & 1 ))
    {
        verbose(printf("add row failed\n"));
        goto quit;
    }

    number = 0;
    for( i = 0; i < numcol; i++ )
    {
        om_msg = om$send( msg = message GRtable.GRmod_cell ( msg,
                                                            number,
                                                            i,
                                                            &cell[i]),
                                senderid = NULL_OBJID,
                                targetid = tblid->objid,
                                targetos = tblid->osnum );

        if( !(om_msg & *msg & 1 ))
        {
            verbose(printf("mod cell %d failed\n", i));
            goto quit;
        }
     }

quit:

    return( om_msg );
}

IGRint EMadd_row_with_vals( msg, tblid, row, rownum )
IGRlong *msg;
struct GRid *tblid;
GRtable_row_info    * row;
int  rownum;
{
int i, om_msg = OM_S_SUCCESS;
int num_cols;
struct GRid expid;
GRtable_cell_info cell;
struct ret_struct ret_data;
struct GRmd_env mod_env;

    *msg = MSSUCC;

    om_msg = om$send( msg = message GRtable.GRadd_row ( msg,
                                                       row,
                                                       &i ),
                                senderid = NULL_OBJID,
                                targetid = tblid->objid,
                                targetos = tblid->osnum );

    if( !(om_msg & *msg & 1 ))
    {
        verbose(printf("add row failed\n"));
        goto quit;
    }

    /* First get the number of columns in the table, 
        then get the expression ids and their values,
        then update the cells of the rownum with the values.
    */ 

    om_msg = om$send (msg = message GRtable.GRnum_columns(msg, &num_cols),
                      senderid = NULL_OBJID,
                      targetid = tblid->objid,
                      targetos = tblid->osnum);

    for( i = 0; i < num_cols; i++ )
    {
        om_msg = om$send (msg = message GRtable.GRget_expression (msg,
                                                                  i,
                                                                  &expid),
                      senderid = NULL_OBJID,
                      targetid = tblid->objid,
                      targetos = tblid->osnum);

        if( !(om_msg & *msg & 1))
        {
            verbose(printf("GRget_expresssion failed for %d column\n",i));
            goto quit;
        }
#ifdef DEBUG
printf("table expid = %d\n", expid.objid );
#endif
        om_msg = om$send (msg = message NDnode.NDgive_structure (msg,
                                                                 &ret_data,
                                                                 &mod_env),
                              senderid = NULL_OBJID,
                              targetid = expid.objid,
                              targetos = expid.osnum);

        if (!(om_msg & *msg & 1))
            goto quit;
            
        cell.d = ret_data.var.root_pm_st.value;
#ifdef DEBUG
printf("expval = %lf\n", cell.d );
#endif
        om_msg = om$send( msg = message GRtable.GRmod_cell ( msg,
                                                            rownum,
                                                            i,
                                                            &cell),
                                senderid = NULL_OBJID,
                                targetid = tblid->objid,
                                targetos = tblid->osnum );

        if( !(om_msg & *msg & 1 ))
        {
            verbose(printf("mod cell %d failed\n", i));
            goto quit;
        }
    }

quit:
    if( !( om_msg & 1 ) ) 
    {
        /* delete the added row */
        om$send( msg = message GRtable.GRrem_row( msg, &rownum, row->name ),
                                senderid = NULL_OBJID,
                                targetid = tblid->objid,
                                targetos = tblid->osnum );
    }
    return( om_msg );
}
end implementation ECexpldassy;
