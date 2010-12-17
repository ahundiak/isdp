/*************************************************************************
 *                                                                       *
 *     Module:    PDMattr.c                                              *
 *     Author:    Glenn Scott                                            *
 *     Date:      17 August 1989                                         *
 *     Modified   25 oct 1990 by Kumar Narayanan                         *
 *                                                                       *
 *************************************************************************/

#include <stdio.h>
#include "MEMstruct.h"
#include "NFMstruct.h"
#include "NFMerrordef.h"
#include "PDUris_incl.h"
#include "PDMexec.h"
#include "PDMtypes.h"
#include "PDUerror.h"
#include "ERR.h"
#include "WFstruct.h"


extern int      PDMdebug_on;
extern struct WFstruct WFinfo;
extern char     PDM_DEBUG_FILE[];
static char     s[1024];
static long     status;
extern PDMexec_ptr PDMexec;
extern long NFM_PL_LOCK;
extern struct NFMglobal_st NFMglobal;




int PDMsget_table_attributes(attribute_buffer, data_buffer, list_buffers)
        MEMptr          *attribute_buffer;
        MEMptr          *data_buffer;
        MEMptr          *list_buffers;
{
	/*************************************************************

	  This function returns the attribute buffer,
	  data buffer and any list buffers associated with the table

	**************************************************************/
	char            *fn = "PDMsget_table_attributes";

        MEMptr          application = NULL;
/*added to support drawing sheets */
        char            sql_str [512];
/*
        MEMptr          application1 = NULL;
        MEMptr          application2 = NULL;
*/


	char            loc_name[25];
/* APOGEE START
	char            lop_name[25];
	char            cit_name[25];
  * APOGEE END */
	char            pdctable[50];


	sprintf(s, "PDMsget_table_attributes: operation = <%d>\n",
		PDMexec->operation);
	PDMdebug(s);
	sprintf(s, "PDMsget_table_attributes: entity = <%d>\n",
		PDMexec->entity);
	PDMdebug(s);

	/* initialize return buffers */
	*attribute_buffer = NULL;
	*data_buffer = NULL;
	*list_buffers = NULL;

	/* Determine which table to get attributes for  */

	switch (PDMexec->entity) {
	case PDM_LOGIN:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_TABLE:
		case QUERY_TABLE:
		case MODIFY_TABLE:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}
/* APOGEE START break; APOGEE END */

	case PDM_USER:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_TABLE:
		case QUERY_TABLE:
		case MODIFY_TABLE:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

/* APOGEE START		break; APOGEE END */

	case PDM_PROJECT:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_TABLE:
		case QUERY_TABLE:

sprintf (sql_str, "UPDATE %s SET n_itemlock = 'N' WHERE n_itemname = '%s' AND n_itemrev = '%s'", PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
      SQLstmt(sql_str);

/* Mychelle changed 4/20/93 - pass PDMexec->project */
			if ((PDMexec->NFMstatus = NFMquery_project_members
			     (PDMexec->user_id, PDMexec->project,
			attribute_buffer, data_buffer)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
				 "NFMquery_project_members status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
                               ERRget_specific_number (NFM, &status);
                            return(status);
			}
sprintf (sql_str, "UPDATE %s SET n_itemlock = 'Y' WHERE n_itemname = '%s' AND n_itemrev = '%s'", PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
      SQLstmt(sql_str);
			break;

		case MODIFY_TABLE:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_LOC:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_TABLE:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		case QUERY_TABLE:

			/* Get the attributes from the nfmcatalogs table  */

			if ((PDMexec->NFMstatus = NFMquery_loc_definition
			     (PDMexec->user_id, loc_name, attribute_buffer)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
				  "NFMquery_loc_definition status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				return (PDM_E_GET_ATTRIBUTES);
			}
			/* Get the attributes from the pdmcatalogs table  */

			if ((PDMexec->NFMstatus = NFMquery_table_definition
			     (PDMexec->user_id, "pdmcatalogs", "pdmcatalogs",
			      attribute_buffer)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
				"NFMquery_table_definition status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		case MODIFY_TABLE:
			if ((PDMexec->NFMstatus =
			     NFMquery_change_table_information
			     (PDMexec->user_id, "pdmcatalogs", "pdmcatalogs",
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
				 "NFMquery_change_table_information = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		default:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;
/* added for drawing sheet support */

        case PDM_DRAW_CATALOG:

                /* Determine which buffer format to use  */
                switch (PDMexec->operation) {
                case ADD_TABLE:
                status = PDMcreate_application1(&application);
                if(status != NFM_S_SUCCESS) {
                       return(PDM_E_GET_ATTRIBUTES);
                       }
                if ((PDMexec->NFMstatus = NFMquery_catalog_template_n
                             ( attribute_buffer, data_buffer, list_buffers,
                                            application)) != NFM_S_SUCCESS) {
                        _PDMdebug (fn,
                         "NFMquery_template_information status = <%d>\n",
                                PDMexec->NFMstatus);
                        MEMclose(attribute_buffer); MEMclose(data_buffer);
                        MEMclose(list_buffers);
                                return (PDM_E_GET_ATTRIBUTES);
                        }
                break;

                case QUERY_TABLE:
/* We have to use PDMexec->catalog instead of dcatalog Bcos
   PDMRsend function automatically loads it during get table attributes
   In PDU */
                if ((PDMexec->NFMstatus = NFMquery_catalog_definition
                     (PDMexec->user_id, PDMexec->catalog,
                      attribute_buffer)) != NFM_S_SUCCESS) {
                        _PDMdebug (fn,
                        "NFMquery_catalog_definition status = <%d>\n",
                                PDMexec->NFMstatus);
                        MEMclose(attribute_buffer);
                        return (PDM_E_GET_ATTRIBUTES);
                        }
                break;

                case MODIFY_TABLE:
                if ((PDMexec->NFMstatus = NFMquery_change_catalog_information
                     (PDMexec->user_id, PDMexec->catalog, attribute_buffer,
                       data_buffer, list_buffers)) != NFM_S_SUCCESS) {
                        _PDMdebug (fn,
                        "NFMquery_change_catalog_information status = <%d>\n",
                                PDMexec->NFMstatus);
                        MEMclose(attribute_buffer);
                        MEMclose(data_buffer);
                        MEMclose(list_buffers);
                        return (PDM_E_GET_ATTRIBUTES);
                        }
                    break;

                default:
                _PDMdebug (fn, "unknown operation <%d>\n", PDMexec->operation);
                return (PDM_E_INVALID_INPUT);
                }
        break;
/* end of addition for drawing sheet support */


	case PDM_CATALOG:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_TABLE:
                        status = PDMcreate_application(&application);
                           if(status != NFM_S_SUCCESS)
                           {
                              return(PDM_E_GET_ATTRIBUTES);
                           }
		if ((PDMexec->NFMstatus = NFMquery_catalog_template_n
			     ( attribute_buffer, data_buffer, list_buffers, application)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
					"NFMquery_template_information status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		case QUERY_TABLE:
			if ((PDMexec->NFMstatus = NFMquery_catalog_definition
			     (PDMexec->user_id, PDMexec->catalog,
			      attribute_buffer)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
					"NFMquery_catalog_definition status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		case MODIFY_TABLE:
			if ((PDMexec->NFMstatus =
			     NFMquery_change_catalog_information
			     (PDMexec->user_id, PDMexec->catalog,
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
					"NFMquery_change_catalog_information status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		default:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;
	case PDM_DYNAMIC:

		/* Determine which buffer format to use */ 

			sprintf(pdctable, "%s", PDMexec->catalog);
		switch (PDMexec->operation) {
		case ADD_TABLE:
                        status = PDMcreate_application(&application);
                          if(status != NFM_S_SUCCESS)
                           {
                             return(PDM_E_GET_ATTRIBUTES);
                           }
			if ((PDMexec->NFMstatus = NFMquery_catalog_template_n
			     ( attribute_buffer, data_buffer, list_buffers,application)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
					"NFMquery_template_information status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		case QUERY_TABLE:
			if ((PDMexec->NFMstatus = NFMquery_catalog_definition
			     (PDMexec->user_id, pdctable,
			      attribute_buffer)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
					"NFMquery_catalog_definition status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		case MODIFY_TABLE:
			if ((PDMexec->NFMstatus =
			     NFMquery_change_catalog_information
			     (PDMexec->user_id, pdctable,
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
					"NFMquery_change_catalog_information status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		default:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}
		break;

	case PDM_CIT:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_TABLE:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		case QUERY_TABLE:

			/* Get the attributes from the nfmcit table  */
			/*
			 * if ((PDMexec->NFMstatus = NFMquery_cit_definition
			 * (PDMexec->user_id, cit_name, attribute_buffer))
			 * != NFM_S_SUCCESS) { PDMdebug
			 * ("PDMsget_table_attributes: "); sprintf (s,
			 * "NFMquery_cit_definition status = <%d>\n",
			 * PDMexec->NFMstatus); PDMdebug (s); MEMclose
			 * (attribute_buffer); return
			 * (PDM_E_GET_ATTRIBUTES); }
			 */
			/* Get the attributes from the pdmcit table  */

			if ((PDMexec->NFMstatus = NFMquery_table_definition
			     (PDMexec->user_id, "pdmcit", "pdmcit",
			      attribute_buffer)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s, "NFMquery_table_definition = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		case MODIFY_TABLE:
			if ((PDMexec->NFMstatus =
			     NFMquery_change_table_information
			     (PDMexec->user_id, "pdmcit", "pdmcit",
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
				 "NFMquery_change_table_information = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		default:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_BOMCONTENT:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_TABLE:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		case QUERY_TABLE:
			if ((PDMexec->NFMstatus =
			     NFMquery_template_definition ( "t_appltable", "bom_template", "BOM" ,attribute_buffer)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s, "NFMquery_template_definition = <%d>\n", PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;
		case MODIFY_TABLE:
			if ((PDMexec->NFMstatus =
			     NFMquery_change_template_information
			("t_appltable", "bom_template", "BOM",
			 attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
					"NFMquery_change_template_information = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		default:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_VIEWS:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_TABLE:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		case QUERY_TABLE:
			if ((PDMexec->NFMstatus = NFMquery_table_definition
			     (PDMexec->user_id, "pdmviews", "pdmviews",
			      attribute_buffer)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s, "NFMquery_table_definition = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		case MODIFY_TABLE:
			if ((PDMexec->NFMstatus =
			     NFMquery_change_table_information
			     (PDMexec->user_id, "pdmviews", "pdmviews",
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
				 "NFMquery_change_table_information = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		default:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_BOMS:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_TABLE:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		case QUERY_TABLE:
			if ((PDMexec->NFMstatus = NFMquery_table_definition
			     (PDMexec->user_id, "pdmboms", "pdmboms",
			      attribute_buffer)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s, "NFMquery_table_definition = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;

		case MODIFY_TABLE:
			if ((PDMexec->NFMstatus =
			     NFMquery_change_table_information
			     (PDMexec->user_id, "pdmboms", "pdmboms",
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_attributes: ");
				sprintf(s,
				 "NFMquery_change_table_information = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_ATTRIBUTES);
			}
			break;
		default:
			PDMdebug("PDMsget_table_attributes: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}
		break;


/* added for add_parametric_part support 8/30/92 - mac*/

        case PDM_PARAMETRIC_PART:

                /* Determine which buffer format to use  */

           switch (PDMexec->operation) {
           case ADD_DATA:
           _PDMdebug (fn, "PDM_PARAMETRIC_PART: ADD_DATA\n");

           if ( (!strcmp (PDMexec->revision, "P"))
    /* Added to support new parametric external catalog type MaC 010194*/
                 || (!strcmp (PDMexec->revision, "PXT")) ) {
/*
           if ((PDMexec->NFMstatus = NFMquery_add_item_attributes 
                                        (PDMexec->user_id, 
                                         PDMexec->catalog, 
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers)) != NFM_S_SUCCESS) {
            _PDMdebug (fn, 
              "NFMquery_add_item_attributes = <%d>\n", PDMexec->NFMstatus);
*/
            PDMexec->NFMstatus = PDMquery_parm_catalog_attributes ( 
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers);
                if (PDMexec->NFMstatus != PDM_S_SUCCESS) {
            _PDMdebug (fn, 
              "PDMquery_parm_catalog_attributes = <%d>\n", PDMexec->NFMstatus);
                  MEMclose(attribute_buffer);
                  MEMclose(data_buffer);
                  MEMclose(list_buffers);
                  if (PDMexec->NFMstatus == NFM_E_NO_ACLS_FOUND)
                      return (PDM_E_NOT_IN_ACL);
                   else
                      return (PDM_E_GET_DATA);
                  }
                 }
            else if (!strcmp (PDMexec->revision, "CID")) {
/*PDMexec->NFMstatus = PDMget_attr_of_view (table_type, table_name, identifier, attr_list, data_list, value_list);*/
            PDMexec->NFMstatus = PDMget_attr_of_view (PDMexec->revision, 
                                         PDMexec->catalog, 
                                         "PDM",
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers);
                if (PDMexec->NFMstatus != NFM_S_SUCCESS) {
                     _PDMdebug (fn, "NFMquery_add_item_attributes = <%d>\n", 
                                   PDMexec->NFMstatus);
                     MEMclose(attribute_buffer);
                     MEMclose(data_buffer);
                     MEMclose(list_buffers);
                     return (PDM_E_GET_DATA);
                      }
 
             }
             else
                {
              _PDMdebug (fn, "Invalid Catalog Type [%s]\n", PDMexec->revision);
                    }
                  break;

             case QUERY_DATA:

           _PDMdebug (fn, "PDM_PARAMETRIC_PART: QUERY_DATA\n");
             if ((PDMexec->NFMstatus = NFMquery_item_attributes 
                                        (PDMexec->user_id, 
                                         PDMexec->dcatalog, 
                                         PDMexec->drawing, 
                                         PDMexec->drevision, 
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers)) != NFM_S_SUCCESS) {
                   _PDMdebug (fn, "NFMquery_item_attributes = <%d>\n",
                                        PDMexec->NFMstatus);
                    MEMclose(attribute_buffer);
                    MEMclose(data_buffer);
                    MEMclose(list_buffers);
                    return (PDMexec->NFMstatus);
                    }
               break;
                case MODIFY_DATA:
           _PDMdebug (fn, "PDM_PARAMETRIC_PART: MODIFY_DATA\n");
           /*if (!strcmp (PDMexec->revision, "P"))  */
           if ( (!strcmp (PDMexec->revision, "P"))
    /* Added to support new parametric external catalog type MaC 010194*/
                 || (!strcmp (PDMexec->revision, "PXT")) ) {
/*
           if ((PDMexec->NFMstatus = NFMquery_add_item_attributes 
                                        (PDMexec->user_id, 
                                         PDMexec->catalog, 
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers)) != NFM_S_SUCCESS) {
            _PDMdebug (fn, "NFMquery_add_item_attributes = <%d>\n", PDMexec->NFMstatus);
                  MEMclose(attribute_buffer);
                  MEMclose(data_buffer);
                  MEMclose(list_buffers);
                  return (PDM_E_GET_DATA);
                  }
*/
            PDMexec->NFMstatus = PDMquery_parm_catalog_attributes ( 
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers);
                if (PDMexec->NFMstatus != PDM_S_SUCCESS) {
            _PDMdebug (fn, 
              "PDMquery_parm_catalog_attributes = <%d>\n", PDMexec->NFMstatus);
                  MEMclose(attribute_buffer);
                  MEMclose(data_buffer);
                  MEMclose(list_buffers);
                  if (PDMexec->NFMstatus == NFM_E_NO_ACLS_FOUND)
                      return (PDM_E_NOT_IN_ACL);
                   else
                  return (PDM_E_GET_DATA);
                  }

                 }
            else if (!strcmp (PDMexec->revision, "CID")) {
/*PDMexec->NFMstatus = PDMget_attr_of_view (table_type, table_name, identifier, attr_list, data_list, value_list);*/
            PDMexec->NFMstatus = PDMget_attr_of_view (PDMexec->revision, 
                                         PDMexec->catalog, 
                                         "PDM",
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers);
                if (PDMexec->NFMstatus != NFM_S_SUCCESS) {
                     _PDMdebug (fn, "PDMget_attr_of_view  = <%d>\n", 
                                   PDMexec->NFMstatus);
                     MEMclose(attribute_buffer);
                     MEMclose(data_buffer);
                     MEMclose(list_buffers);
                     return (PDM_E_GET_DATA);
                      }
 
             }
             else
                {
              _PDMdebug (fn, "Invalid Catalog Type [%s]\n", PDMexec->revision);
                    }
/*
               PDMexec->NFMstatus = PDMget_list_for_modify (attribute_buffer,
                                         data_buffer, PDMexec->revision);
                if (PDMexec->NFMstatus != PDM_S_SUCCESS) {
                     _PDMdebug (fn, "PDMget_list_for_modify = <%d>\n",
                                   PDMexec->NFMstatus);
                     MEMclose(attribute_buffer);
                     MEMclose(data_buffer);
                     MEMclose(list_buffers);
                     return (PDM_E_GET_DATA);
                      }
*/
                 break;
                default:
                        _PDMdebug (fn, "unknown operation <%d>\n",
                                PDMexec->operation);
                        return (PDM_E_INVALID_INPUT);
                }
                break;


/* End of additions for PDMparametric support */



	default:
		sprintf(s, "PDMsget_table_attributes: unknown entity <%d>\n",
			PDMexec->entity);
		PDMdebug(s);
		return (PDM_E_INVALID_INPUT);
	}

	PDMdebug("PDMsget_table_attributes: returning SUCCESS\n");
	return (PDM_S_SUCCESS);
}


int PDMsget_table_data(attribute_buffer, data_buffer, list_buffers)
	
        MEMptr          *attribute_buffer;
        MEMptr          *data_buffer;
        MEMptr          *list_buffers;
{
	/*************************************************************

	  This function returns the attribute buffer,
	  data buffer and any list buffers associated with the table

	**************************************************************/

	char            *fn = "PDMsget_table_data";
	char            loc_name[25];
        int             catno,command_no;
         char           sql_str[512];
	MEMptr          wf_buffer = NULL;

	sprintf(s, "PDMsget_table_data: operation = <%d>\n", PDMexec->operation);
	PDMdebug(s);
	sprintf(s, "PDMsget_table_data: entity = <%d>\n", PDMexec->entity);
	PDMdebug(s);

	/* Determine which table to get attributes for  */

	switch (PDMexec->entity) {
/*
	case PDM_LOGIN:

		switch (PDMexec->operation) {
		case ADD_DATA:
			if ((PDMexec->NFMstatus = NFMquery_login_attributes("PDM", "pdme_", attribute_buffer, data_buffer, list_buffers, &wf_buffer)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s,
				"NFMquery_login_attributes status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case QUERY_DATA:
		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;
*/

	case PDM_USER:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case QUERY_DATA:
			if ((PDMexec->NFMstatus = NFMquery_add_user_attributes
			     (PDMexec->user_id,
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s,
					"NFMquery_add_user_attributes status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_PROJECT:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case QUERY_DATA:
			/*
			 * if ((PDMexec->NFMstatus = NFMquery_lop_attributes
			 * (PDMexec->user_id, lop_name, "",
			 * attribute_buffer, data_buffer, list_buffers))
			 * != NFM_S_SUCCESS) { PDMdebug ("PDMsget_table_data:
			 * "); sprintf (s, "NFMquery_lop_attributes =
			 * <%d>\n", PDMexec->NFMstatus); PDMdebug (s);
			 * MEMclose (attribute_buffer); MEMclose
			 * (data_buffer); MEMclose (list_buffers); return
			 * (PDM_E_GET_DATA); }
			 */
			break;

		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_LOC:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:

			/* Get the attributes from the nfmcatalogs table  */

			if ((PDMexec->NFMstatus =
			     NFMquery_addto_loc_attributes (PDMexec->user_id, loc_name, attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s,
					"NFMquery_addto_loc_attributes status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			/* Get the attributes from the pdmcatalogs table  */

                  /*
			if ((PDMexec->NFMstatus = NFMquery_table_attributes
			     (PDMexec->user_id, "pdmcatalogs", "pdmcatalogs",
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMquery_table_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
*/
			break;

		case QUERY_DATA:

			/* Get the attributes from the nfmcatalogs table  */

			if ((PDMexec->NFMstatus =
			     NFMquery_addto_loc_attributes
			     (PDMexec->user_id, loc_name, 
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s,
					"NFMquery_addto_loc_attributes status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			/* Get the attributes from the pdmcatalogs table  */

			if ((PDMexec->NFMstatus = NFMquery_table_attributes
			     (PDMexec->user_id, "pdmcatalogs", "pdmcatalogs",
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMquery_table_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case MODIFY_DATA:

			/* Get the attributes from the nfmcatalogs table  */

			if ((PDMexec->NFMstatus =
			     NFMquery_changeto_loc_attributes
			     (PDMexec->user_id, loc_name, PDMexec->catalog,
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s,
					"NFMquery_changeto_loc_attributes status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			/* Get the attributes from the pdmcatalogs table  */

			/*
			 * if ((PDMexec->NFMstatus =
			 * NFMquery_table_attributes (PDMexec->user_id,
			 * "pdmcatalogs", "pdmcatalogs", attribute_buffer,
			 * data_buffer, list_buffers)) != NFM_S_SUCCESS) {
			 * PDMdebug ("PDMsget_table_data: "); sprintf (s,
			 * "NFMquery_table_attributes = <%d>\n",
			 * PDMexec->NFMstatus); PDMdebug (s); MEMclose
			 * (attribute_buffer); MEMclose (data_buffer);
			 * MEMclose (list_buffers); return (PDM_E_GET_DATA);
			 * }
			 */
			break;


		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

/* added for add_drawing support 1/30/92 - mac*/

        case PDM_DRAWING:

                /* Determine which buffer format to use  */

                switch (PDMexec->operation) {
                case ADD_DATA:

                    if ((PDMexec->NFMstatus = NFMquery_add_item_attributes (PDMexec->user_id, PDMexec->dcatalog, attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
                                PDMdebug("PDMsget_table_data: ");
            sprintf(s, "NFMquery_add_item_attributes = <%d>\n", PDMexec->NFMstatus);
                                PDMdebug(s);
                                MEMclose(attribute_buffer);
                                MEMclose(data_buffer);
                                MEMclose(list_buffers);
                                return (PDM_E_GET_DATA);
                        }
                        break;

                case QUERY_DATA:

                        if ((PDMexec->NFMstatus = NFMquery_item_attributes (PDMexec->user_id, PDMexec->dcatalog, PDMexec->drawing, PDMexec->drevision, attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
                                PDMdebug("PDMsget_table_data: ");
                                sprintf(s, "NFMquery_item_attributes = <%d>\n",
                                        PDMexec->NFMstatus);
                                PDMdebug(s);
                                MEMclose(attribute_buffer);
                                MEMclose(data_buffer);
                                MEMclose(list_buffers);
                                return (PDMexec->NFMstatus);
                        }
                        break;
                case MODIFY_DATA:
             status = PDMsvalidate_user_access_cl(PDMexec->user_id,
                         "PDMChange Part", "", PDMexec->project, 
                      PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
                  if(status != PDM_S_SUCCESS)
                  {
        _PDMdebug ("", "PDMsvalid_user_access failed status -> %d \n", status);
                   if (status == SQL_I_NO_ROWS_FOUND || 
                        status == SQL_E_MESSAGE ||
                         status == SQL_E_UNKNOWN_RELATION) {
                      _PDMdebug (fn, "Sql error encountered...\n");
                      return(PDM_E_NOT_IN_ACL);
                      }
                   else {
                      return(status);
                      }
                    /*return(PDM_E_NOT_IN_ACL);*/
                   }
                   NFM_PL_LOCK = NFMglobal.NFMuserid;
                        if ((PDMexec->NFMstatus = NFMprepare_update_item (PDMexec->user_id, PDMexec->dcatalog, PDMexec->drawing, PDMexec->drevision, attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
                                PDMdebug("PDMsget_table_data: ");
                                sprintf(s, "NFMprepare_update_item = <%d>\n",
                                      PDMexec->NFMstatus);
                                PDMdebug(s);
                                MEMclose(attribute_buffer);
                                MEMclose(data_buffer);
                                MEMclose(list_buffers);
                                return (PDM_E_GET_DATA);
                        }
                        break;
                default:
                        PDMdebug("PDMsget_table_data: ");
                        sprintf(s, "unknown operation <%d>\n",
                                PDMexec->operation);
                        PDMdebug(s);
                        return (PDM_E_INVALID_INPUT);
                }
                break;




        case PDM_DRAW_CATALOG:

                /* Determine which buffer format to use  */

                switch (PDMexec->operation) {
                case QUERY_DATA:
                        if ((PDMexec->NFMstatus = NFMquery_catalog_information (PDMexec->user_id, PDMexec->catalog, attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
                                PDMdebug("PDMsget_table_data: ");
                                sprintf(s, "NFMquery_catalog_information = <%d>\
n",
                                      PDMexec->NFMstatus);
                                PDMdebug(s);
                                MEMclose(attribute_buffer);
                                MEMclose(data_buffer);
                                MEMclose(list_buffers);
                                return (PDM_E_GET_DATA);
                        }
                        break;
                 case ADD_DATA:
                case MODIFY_DATA:
                        if ((PDMexec->NFMstatus = NFMquery_catalog_attributes (PDMexec->user_id, PDMexec->catalog, attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
                                PDMdebug("PDMsget_table_data: ");
                          sprintf(s, "NFMquery_catalog_attributes = <%d>\n ", PDMexec->NFMstatus);
                                PDMdebug(s);
                                MEMclose(attribute_buffer);
                                MEMclose(data_buffer);
                                MEMclose(list_buffers);
                                return (PDM_E_GET_DATA);
                        }
                        break;

                default:
                        PDMdebug("PDMsget_table_data: ");
                        sprintf(s, "unknown operation <%d>\n",
                                PDMexec->operation);
                        PDMdebug(s);
                        return (PDM_E_INVALID_INPUT);
                }

                break;
/* end of addition for drawing support*/


	case PDM_PART:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:

			if ((PDMexec->NFMstatus = NFMquery_add_item_attributes
			     (PDMexec->user_id, PDMexec->catalog,
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMquery_add_item_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case QUERY_INFO:
			if ((PDMexec->NFMstatus = NFMquery_item_attributes
			     (PDMexec->user_id, PDMexec->catalog,
			      PDMexec->part_num, PDMexec->revision,
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMquery_item_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDMexec->NFMstatus);
			}
			break;
		case QUERY_DATA:

                   status = PDMris_get_catno(PDMexec->catalog,&catno);
                   status = PDMget_commandno("Add Item", &command_no);
                    if(status != PDM_S_SUCCESS)
                     {
                    sprintf(s,"PDMget_command_no failed status %d\n",status);
                    PDMdebug(s);
                    return(PDM_E_GET_DATA);
                     }

                            WFinfo.command = command_no;
                            WFinfo.catalog_no = catno;

/*
			if ((PDMexec->NFMstatus = NFMquery_item_attributes
			     (PDMexec->user_id, PDMexec->catalog,
			      PDMexec->part_num, PDMexec->revision,
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMquery_item_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}

  */

                   NFM_PL_LOCK = NFMglobal.NFMuserid;
			if ((PDMexec->NFMstatus = NFMprepare_update_item
			     (PDMexec->user_id, PDMexec->catalog,
			      PDMexec->part_num, PDMexec->revision,
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMprepare_update_item = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
                        status = PDMload_state_name(*data_buffer);
			break;

		case MODIFY_DATA:
                   NFM_PL_LOCK = NFMglobal.NFMuserid;
			if ((PDMexec->NFMstatus = NFMprepare_update_item
			     (PDMexec->user_id, PDMexec->catalog,
			      PDMexec->part_num, PDMexec->revision,
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMprepare_update_item = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;
		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}
		break;

	case PDM_CATALOG:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case QUERY_DATA:
			if ((PDMexec->NFMstatus = NFMquery_catalog_information
			     (PDMexec->user_id, PDMexec->catalog,
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMquery_catalog_information = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;
		case ADD_DATA:
		case MODIFY_DATA:
			if ((PDMexec->NFMstatus = NFMquery_catalog_attributes
			     (PDMexec->user_id, PDMexec->catalog,
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMquery_catalog_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_CIT:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case QUERY_DATA:

			/* Get the attributes from the nfmcit table  */
			/*
			 * if ((PDMexec->NFMstatus = NFMquery_cit_attributes
			 * (PDMexec->user_id, cit_name, attribute_buffer,
			 * data_buffer, list_buffers)) != NFM_S_SUCCESS) {
			 * PDMdebug ("PDMsget_table_data: "); sprintf (s,
			 * "NFMquery_cit_attributes status = %d\n",
			 * PDMexec->NFMstatus); PDMdebug (s); MEMclose
			 * (attribute_buffer); MEMclose (data_buffer);
			 * MEMclose (list_buffers); return (PDM_E_GET_DATA);
			 * }
			 */
			/* Get the attributes from the pdmcit table  */

			if ((PDMexec->NFMstatus = NFMquery_table_attributes
			     (PDMexec->user_id, "pdmcit", "pdmcit",
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMquery_table_attributes status = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_BOMCONTENT:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		case QUERY_DATA:
			if ((PDMexec->NFMstatus = NFMquery_template_attributes
			( "t_appltable","bom_template","BOM",attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMquery_template_attributes = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;
		case MODIFY_DATA:
			if ((PDMexec->NFMstatus =
			     NFMquery_change_template_information
			("t_appltable", "bom_template","BOM",
			 attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s,
					"NFMquery_change_template_information = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;
		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_VIEWS:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case QUERY_DATA:
			if ((PDMexec->NFMstatus = NFMquery_table_attributes
			     (PDMexec->user_id, "pdmviews", "pdmviews",
			      attribute_buffer, data_buffer, list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data: ");
				sprintf(s, "NFMquery_table_attributes status = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_BOMS:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case QUERY_DATA:
		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

/* APOGEE START	break; APOGEE END */

	case PDM_TRANSITION:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case MODIFY_DATA:

			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		case QUERY_DATA:
                              
                           /* This is done to get NFM work*/
                       status = NFMreset_file_information(PDMexec->catalog,
                          PDMexec->part_num,PDMexec->revision);
                           if(PDMexec->NFMstatus != NFM_S_SUCCESS)
                            {
				sprintf(s, "NFMquery_item_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(attribute_buffer);
				MEMclose(data_buffer);
				MEMclose(list_buffers);
				return (PDM_E_FROM_MAKE_TRANS);
			}
          sprintf( sql_str,"UPDATE %s SET n_itemlock = 'N' WHERE n_itemname = '%s' AND n_itemrev = '%s'",PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
            SQLstmt(sql_str);

                if ((PDMexec->NFMstatus = PDMquery_make_transition
                     (PDMexec->user_id, &attribute_buffer,
                      &data_buffer)) != PDM_S_SUCCESS) {
                        PDMdebug("PDMsget_table_data: ");
                        _PDMdebug (fn, "PDMquery_make_transition = <%d>\n",
                                PDMexec->NFMstatus);
                        MEMclose(attribute_buffer);
                        if (PDMexec->NFMstatus == NFM_E_TO_MAKE_TRANS)
                                        return (PDM_E_TO_MAKE_TRANS);
                        else if (PDMexec->NFMstatus == NFM_E_FROM_MAKE_TRANS)
                                        return (PDM_E_FROM_MAKE_TRANS);
                        else if (PDMexec->NFMstatus == NFM_E_NO_TRANSITIONS)
                                        return (PDM_E_NO_TRANSITIONS);
                        else if (PDMexec->NFMstatus == NFM_E_BAD_TRANSITION)
                                        return (PDM_E_BAD_TRANSITION);
                        else if (PDMexec->NFMstatus == NFM_E_ITEM_NOT_READY_IN)
                                        return (PDM_E_PART_NOT_CHECKEDIN);
                        else if (PDMexec->NFMstatus == NFM_E_BAD_STATE)
                                        return (PDM_E_BAD_STATE);
                        else if (PDMexec->NFMstatus == NFM_E_BAD_CLASS)
                                        return (PDM_E_BAD_CLASS);
                        return (PDMexec->NFMstatus);
                        }

      
          sprintf( sql_str,"UPDATE %s SET n_itemlock = 'U' WHERE n_itemname = '%s' AND n_itemrev = '%s'",PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
            SQLstmt(sql_str);
             /*
                  status = NFMset_wf_state ("PDM", PDM_S_SUCCESS, "Successful completion");
                   if(status != NFM_S_SUCCESS) {
                              MEMclose(&wf_buffer);
                  PDMdebug ("WFset_to_state failed status - \n");
                         return(PDM_E_SET_TO_STATE);
                           }
                */
			break;
		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}
		break;


/* added for add_parametric_part support 1/30/92 - mac*/

        case PDM_PARAMETRIC_PART:

                /* Determine which buffer format to use  */

           switch (PDMexec->operation) {
           case ADD_DATA:
           /*if (!strcmp (PDMexec->revision, "P")) */
           if ( (!strcmp (PDMexec->revision, "P"))
    /* Added to support new parametric external catalog type MaC 010194*/
                 || (!strcmp (PDMexec->revision, "PXT")) ) {
           if ((PDMexec->NFMstatus = NFMquery_add_item_attributes 
                                        (PDMexec->user_id, 
                                         PDMexec->catalog, 
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers)) != NFM_S_SUCCESS) {
            _PDMdebug (fn, "NFMquery_add_item_attributes = <%d>\n", PDMexec->NFMstatus);
                  MEMclose(attribute_buffer);
                  MEMclose(data_buffer);
                  MEMclose(list_buffers);
                  return (PDM_E_GET_DATA);
                  }
                 }
            else if (!strcmp (PDMexec->revision, "CID")) {
/*PDMexec->NFMstatus = PDMget_attr_of_view (table_type, table_name, identifier, attr_list, data_list, value_list);*/
            PDMexec->NFMstatus = PDMget_attr_of_view (PDMexec->revision, 
                                         PDMexec->catalog, 
                                         "PDM",
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers);
                if (PDMexec->NFMstatus != NFM_S_SUCCESS) {
                     _PDMdebug (fn, "NFMquery_add_item_attributes = <%d>\n", 
                                   PDMexec->NFMstatus);
                     MEMclose(attribute_buffer);
                     MEMclose(data_buffer);
                     MEMclose(list_buffers);
                     return (PDM_E_GET_DATA);
                      }
 
             }
             else
                {
              _PDMdebug (fn, "Invalid Catalog Type [%s]\n", PDMexec->revision);
                    }
                  break;

             case QUERY_DATA:

             if ((PDMexec->NFMstatus = NFMquery_item_attributes 
                                        (PDMexec->user_id, 
                                         PDMexec->dcatalog, 
                                         PDMexec->drawing, 
                                         PDMexec->drevision, 
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers)) != NFM_S_SUCCESS) {
                   _PDMdebug (fn, "NFMquery_item_attributes = <%d>\n",
                                        PDMexec->NFMstatus);
                    MEMclose(attribute_buffer);
                    MEMclose(data_buffer);
                    MEMclose(list_buffers);
                    return (PDMexec->NFMstatus);
                    }
               break;
                case MODIFY_DATA:
           /*if (!strcmp (PDMexec->revision, "P")) */
           if ( (!strcmp (PDMexec->revision, "P"))
    /* Added to support new parametric external catalog type MaC 010194*/
                 || (!strcmp (PDMexec->revision, "PXT")) ) {
           if ((PDMexec->NFMstatus = NFMquery_add_item_attributes 
                                        (PDMexec->user_id, 
                                         PDMexec->catalog, 
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers)) != NFM_S_SUCCESS) {
            _PDMdebug (fn, "NFMquery_add_item_attributes = <%d>\n", PDMexec->NFMstatus);
                  MEMclose(attribute_buffer);
                  MEMclose(data_buffer);
                  MEMclose(list_buffers);
                  return (PDM_E_GET_DATA);
                  }
                 }
            else if (!strcmp (PDMexec->revision, "CID")) {
/*PDMexec->NFMstatus = PDMget_attr_of_view (table_type, table_name, identifier, attr_list, data_list, value_list);*/
            PDMexec->NFMstatus = PDMget_attr_of_view (PDMexec->revision, 
                                         PDMexec->catalog, 
                                         "PDM",
                                         attribute_buffer, 
                                         data_buffer, 
                                         list_buffers);
                if (PDMexec->NFMstatus != NFM_S_SUCCESS) {
                     _PDMdebug (fn, "NFMquery_add_item_attributes = <%d>\n", 
                                   PDMexec->NFMstatus);
                     MEMclose(attribute_buffer);
                     MEMclose(data_buffer);
                     MEMclose(list_buffers);
                     return (PDM_E_GET_DATA);
                      }
 
             }
             else
                {
              _PDMdebug (fn, "Invalid Catalog Type [%s]\n", PDMexec->revision);
                    }
/*
               PDMexec->NFMstatus = PDMget_list_for_modify ( attribute_buffer,
                                         data_buffer,
					 PDMexec->revision);
                if (PDMexec->NFMstatus != PDM_S_SUCCESS) {
                     _PDMdebug (fn, "PDMget_list_for_modify = <%d>\n",
                                   PDMexec->NFMstatus);
                     MEMclose(&attribute_buffer);
                     MEMclose(&data_buffer);
                     MEMclose(&list_buffers);
                     return (PDM_E_GET_DATA);
                      }
*/
                 break;
                default:
                        _PDMdebug (fn, "unknown operation <%d>\n",
                                PDMexec->operation);
                        return (PDM_E_INVALID_INPUT);
                }
                break;


/* End of additions for PDMparametric support */




	default:
		sprintf(s, "PDMsget_table_data: unknown entity <%d>\n",
			PDMexec->entity);
		PDMdebug(s);
		return (PDM_E_INVALID_INPUT);
	}

	if (PDMexec->operation == PDM_PART)
        {
	/* Make sure there is a data buffer  */

	if (*data_buffer == NULL) {
		if ((PDMexec->MEMstatus = MEMopen(data_buffer, 0)) != MEM_S_SUCCESS) {
			MEMclose(attribute_buffer);
			MEMclose(data_buffer);
			MEMclose(list_buffers);
			sprintf(s, "PDMsget_table_data: MEMopen status = <%d>\n",
				PDMexec->MEMstatus);
			PDMdebug(s);
			return (PDM_E_OPEN_BUFFER);
		}
	}
	/* Append the buffers together  */

	if ((PDMexec->MEMstatus = MEMappend
	     (*data_buffer, *attribute_buffer)) != MEM_S_SUCCESS) {
		MEMclose(attribute_buffer);
		MEMclose(data_buffer);
		MEMclose(list_buffers);
		sprintf(s, "PDMsget_table_data: MEMappend status = <%d>\n",
			PDMexec->MEMstatus);
		PDMdebug(s);
		return (PDM_E_APPEND_BUFFER);
	}
	if (*list_buffers == NULL) {
		if ((PDMexec->MEMstatus = MEMopen(list_buffers, 0)) != MEM_S_SUCCESS) {
			MEMclose(attribute_buffer);
			MEMclose(data_buffer);
			sprintf(s, "PDMsget_table_data: MEMopen status = <%d>\n",
				PDMexec->MEMstatus);
			PDMdebug(s);
			return (PDM_E_OPEN_BUFFER);
		}
	}
	if (*list_buffers != NULL) {
		if ((PDMexec->MEMstatus = MEMappend
		 (*list_buffers, *attribute_buffer)) != MEM_S_SUCCESS) {
			MEMclose(attribute_buffer);
			MEMclose(data_buffer);
			MEMclose(list_buffers);
			sprintf(s, "PDMsget_table_data: MEMappend status = <%d>\n",
				PDMexec->MEMstatus);
			PDMdebug(s);
			return (PDM_E_APPEND_BUFFER);
		}
	}
	if (wf_buffer != NULL) {
		if ((PDMexec->MEMstatus = MEMappend
		     (wf_buffer, *attribute_buffer)) != MEM_S_SUCCESS) {
			MEMclose(attribute_buffer);
			MEMclose(data_buffer);
			MEMclose(list_buffers);
			MEMclose(&wf_buffer);
			sprintf(s, "PDMsget_table_data: MEMappend status = <%d>\n",
				PDMexec->MEMstatus);
			PDMdebug(s);
			return (PDM_E_APPEND_BUFFER);
		}
	}
	/* Close the local buffers  */

/*
	MEMclose(data_buffer);
	MEMclose(list_buffers);
	*data_buffer = NULL;
	*list_buffers = NULL;
*/
        }

	PDMdebug("PDMsget_table_data: returning SUCCESS\n");
	return (PDM_S_SUCCESS);
}


int 
PDMget_table_template(PDMexec)
	PDMexec_ptr     PDMexec;
{
	/*************************************************************

	  This function returns the attribute buffer with no rows

	**************************************************************/

	if ((PDMexec->NFMstatus = NFMquery_table_template
	  (PDMexec->user_id, &(PDMexec->return_buffer))) != NFM_S_SUCCESS) {
		MEMclose(&(PDMexec->return_buffer));
		PDMdebug("PDMget_table_template: ");
		sprintf(s, "NFMquery_table_template status = <%d>\n",
			PDMexec->NFMstatus);
		PDMdebug(s);
		return (PDM_E_QUERY_TABLE_TEMPLATE);
	}
	PDMdebug("PDMget_table_template: returning SUCCESS\n");
	return (PDM_S_SUCCESS);
}

int 
PDMquery_template_information(PDMexec)
	PDMexec_ptr     PDMexec;
{
	MEMptr          attribute_buffer = NULL;
	MEMptr          data_buffer = NULL;
	MEMptr          list_buffers = NULL;
        MEMptr          application = NULL;

        
	PDMdebug("ENTER:PDMquery_template_information\n");
         status = PDMcreate_application(&application);
          if (status != NFM_S_SUCCESS)
           {
              return(NFM_E_MEM);
            }
	status = NFMquery_catalog_template_n
		( &attribute_buffer, &data_buffer, &list_buffers, application);
	if (status != NFM_S_SUCCESS) {
		sprintf(s,
		   "NFMquery_template_information status = <%d>\n", status);
		PDMdebug(s);
		MEMclose(&attribute_buffer);
		MEMclose(&data_buffer);
		MEMclose(&list_buffers);
		return (PDM_E_GET_ATTRIBUTES);
	}
	status = MEMappend(data_buffer, attribute_buffer);
	if (status != MEM_S_SUCCESS) {
		sprintf(s,
			"MEMappend status = <%d>\n", status);
		PDMdebug(s);
		MEMclose(&attribute_buffer);
		MEMclose(&data_buffer);
		MEMclose(&list_buffers);
		return (PDM_E_APPEND_BUFFER);
	}
	if (list_buffers != NULL) {
		status = MEMappend(list_buffers, attribute_buffer);
		if (status != MEM_S_SUCCESS) {
			sprintf(s,
				"MEMappend status = <%d>\n", status);
			PDMdebug(s);
			MEMclose(&attribute_buffer);
			MEMclose(&data_buffer);
			MEMclose(&list_buffers);
			return (PDM_E_APPEND_BUFFER);
		}
	}
	PDMexec->return_buffer = attribute_buffer;
	MEMclose(&data_buffer);
	MEMclose(&list_buffers);
	PDMdebug("EXIT:PDMquery_template_information\n");
        return(PDM_S_SUCCESS);
}

int 
PDMsquery_table_definition(attribute_buffer)
	MEMptr          *attribute_buffer;
{
	int             table_no;

	PDMdebug("ENTER:PDMsquery_table_defintion\n");

	*attribute_buffer = NULL;

	status = PDMget_table_no(PDMexec->catalog, PDMexec->part_num, &table_no);
	if (status != PDM_S_SUCCESS) {
       status = PDMget_table_no(PDMexec->catalog, "pdmview",  &table_no);
	if (status != PDM_S_SUCCESS) {
		sprintf(s,
			"PDMget_table_no status = <%d>\n", status);
		PDMdebug(s);
		MEMclose(attribute_buffer);
		return (PDM_E_UNKNOWN_TABLE);
            }
	}
	status = NFMquery_table_definition(
					   PDMexec->user_id,
					   PDMexec->part_num,
					   PDMexec->catalog,
					   attribute_buffer);

	if (status != NFM_S_SUCCESS) {
	status = NFMquery_table_definition(
					   PDMexec->user_id,
					   "pdmview",
					   PDMexec->catalog,
					   attribute_buffer);
	if (status != NFM_S_SUCCESS) {
		sprintf(s,
			"NFMquery_table_definition status = <%d>\n", status);
		PDMdebug(s);
		MEMclose(attribute_buffer);
		return (PDM_E_GET_ATTRIBUTES);
           }
	}
	PDMdebug("EXIT:PDMsquery_table_definition\n");
        /* APOGEE START */
        return(PDM_S_SUCCESS);
        /* APOGEE END */
}

/* This function gets attributes for the dynamic table associated
   with the catalog in the refresh structure.
   Mod:
      1. Now it no longer assumes that dyn table is y_catalog
         and makes a specific query (Thro' PDmdyntable_for_catalog)
         to get the dynamic table. MaC 011193 
 */

int PDMquery_dynamic_attributes(attribute_buffer, data_buffer, list_buffer,
		            assm_bufr)
MEMptr          *attribute_buffer;
MEMptr          *data_buffer;
MEMptr          *list_buffer;
MEMptr          *assm_bufr;
{
	char		*fn = "PDMquery_dynamic_attributes";
	char            *pdc_tbl;
        char            low_pdc_tbl[21];
	char            s[1024];
	char            p_explode[2];
	int             p_tableno;

	PDMdebug("ENTER:PDMquery_dynamic_attributes\n");

	*assm_bufr = NULL;

        status = PDMdyntable_for_catalog(&pdc_tbl);
	if (status != PDM_S_SUCCESS) {
	    _PDMdebug (fn, "PDMdyntable_for_catalog status = <%d>\n", status);
            if (pdc_tbl) free (pdc_tbl);
	    MEMclose(attribute_buffer);
	    return (PDM_E_GET_ATTRIBUTES);
	}

        /*if ( !( (strlen (pdc_tbl) > 0) || (!strcmp (pdc_tbl, "")) )) */
        if ( ( pdc_tbl == NULL ) || (!strcmp (pdc_tbl, "")) )  {
          _PDMdebug (fn, "NO dynamic table mapped for this catalog\n");
          /* return (PDM_I_ATTR_NOT_FOUND);    */
          return (PDM_S_SUCCESS);
         }

       _PDMdebug (fn, "dynamic_table [%s]\n", pdc_tbl);

	status = PDMquery_table_no(pdc_tbl, &p_tableno);
	if (status != PDM_S_SUCCESS)
         {
           PDMconvert_to_lower(pdc_tbl,low_pdc_tbl);
	   status = PDMquery_table_no(low_pdc_tbl, &p_tableno);
	      if (status != PDM_S_SUCCESS)
              {
	   _PDMdebug (fn, "PDMquery_table_no status = <%d>\n", status);
               return(status);
              }
/*
	    status = NFMquery_table_attributes( PDMexec->user_id,
	                                         low_pdc_tbl, 
                                                 low_pdc_tbl, 
                                                 attribute_buffer,
                                                 data_buffer,
                                                 list_buffer);
		if (status != NFM_S_SUCCESS) {
		   _PDMdebug (fn,
		   "NFMquery_table_definition status = <%d>\n", status);
		   MEMclose(attribute_buffer);
		   MEMclose(data_buffer);
		   MEMclose(list_buffer);
		   return (PDM_E_GET_ATTRIBUTES);
		}
*/
             status = PDMget_dyn_upd_attr(p_tableno,attribute_buffer,data_buffer);
             if (status != PDM_S_SUCCESS)
              {
                PDMdebug(fn,"PDMget_dyn_upd_attr failed <0x%.8x> \n",status);
                MEMclose(attribute_buffer);
                MEMclose(data_buffer);
                return(PDM_E_GET_ATTRIBUTES);
              }

              *list_buffer = NULL;
	} else {
		/*
		 * BETH the table name and the type should be the same status
		 * = NFMquery_table_definition( PDMexec->user_id, "catalog",
		 * pdc_tbl, attribute_buffer);
		 */
/*
	    status = NFMquery_table_attributes( PDMexec->user_id,
	                                         pdc_tbl, 
                                                 pdc_tbl, 
                                                 attribute_buffer,
                                                 data_buffer,
                                                 list_buffer);
		if (status != NFM_S_SUCCESS) {
		   _PDMdebug (fn,
		   "NFMquery_table_definition status = <%d>\n", status);
		   MEMclose(attribute_buffer);
		   MEMclose(data_buffer);
		   MEMclose(list_buffer);
		   return (PDM_E_GET_ATTRIBUTES);
		}
*/
             status = PDMget_dyn_upd_attr(p_tableno,attribute_buffer,data_buffer);
             if (status != PDM_S_SUCCESS)
              {
                PDMdebug(fn,"PDMget_dyn_upd_attr failed <0x%.8x> \n",status);
                MEMclose(attribute_buffer);
                MEMclose(data_buffer);
                return(PDM_E_GET_ATTRIBUTES);
              }
              *list_buffer = NULL;
	}
	status = MEMopen(&assm_bufr, 512);
	if (status != MEM_S_SUCCESS) {
	   _PDMdebug (fn, "MEMopen failed status %d\n", status);
	   return (PDM_E_OPEN_BUFFER);
	}
	status = MEMwrite_format(assm_bufr, "p_explode", "char(1)");
	if (status != MEM_S_SUCCESS) {
	   _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
	   return (PDM_E_WRITE_FORMAT);
	}
	p_explode[0] = '\0';
        /* JBP - added check for computable for partnum */
        if (strcmp(PDMexec->part_num, "computable") != 0){
	   status = PDMfind_p_explode(PDMexec->catalog, PDMexec->part_num,
	      			            PDMexec->revision, p_explode);
	   if (status != PDM_S_SUCCESS) {
	      _PDMdebug (fn, "PDMfind_p_explode failed status %d\n", status);
	      return (status);
	      }
        s[0] = '\0';
	sprintf(s, "%s\1", p_explode);
        }
         else 
	     sprintf(s, "%s\1", "");
	status = MEMwrite(assm_bufr, s);
	if (status != MEM_S_SUCCESS) {
	   MEMclose(&assm_bufr);
	   _PDMdebug (fn, "MEMwrite failed status %d\n", status);
	   return (PDM_E_WRITE_ROW);
	}

	/* Make sure there is a attribute buffer  */

	if (*attribute_buffer == NULL) MEMopen(attribute_buffer, 0);
	if (*data_buffer == NULL) MEMopen(data_buffer, 0);
	if (*list_buffer == NULL) MEMopen(list_buffer, 0);
	if (*assm_bufr == NULL) MEMopen(assm_bufr, 0);
        if (pdc_tbl) free (pdc_tbl);

PDMdebug("PDMget_dynamic_attributes: returning SUCCESS\n");
return (PDM_S_SUCCESS);
}


int 
PDMget_pdcattr_buffer
(
char *pdc_tbl,
MEMptr *attr_bufr
)
{
        char          *fname = "PDMget_pdcattr_buffer";
	char          **column_ptr;
	char          **format_ptr;
	char          **data;
        char          low_pdc_tbl[21];
	int             i, nxi, a1 = -1, a2 = -1;
	MEMptr          attribute_buffer = NULL;
	int             p_tableno;

	_PDMdebug(fname,"ENTER\n");

        low_pdc_tbl [0] = '\0';

	status = PDMquery_table_no(pdc_tbl, &p_tableno);
	if (status != PDM_S_SUCCESS && status != PDM_E_NO_CAT_ENTRY) {
         _PDMdebug(fname, "PDMquery_table_no status = <%d>\n", status);
	return (PDM_E_SQL_QUERY);
	}
/* fix to check to see if the table name is in lower case */

        if (status != PDM_S_SUCCESS) {
           PDMconvert_to_lower(pdc_tbl, low_pdc_tbl);
	   status = PDMquery_table_no(low_pdc_tbl, &p_tableno);
	   if (status != PDM_S_SUCCESS) {
            _PDMdebug(fname, "PDMquery_table_no status = <%d>\n", status);
	   return (PDM_E_UNKNOWN_TABLE);
           }
	}
	status = NFMquery_table_definition(
					   PDMexec->user_id,
					   pdc_tbl,
					   pdc_tbl,
					   &attribute_buffer);
	if (status != NFM_S_SUCCESS) {
             PDMconvert_to_lower(pdc_tbl,low_pdc_tbl);
	status = NFMquery_table_definition(
					   PDMexec->user_id,
					   low_pdc_tbl,
					   low_pdc_tbl,
					   &attribute_buffer);
	if (status != NFM_S_SUCCESS) {
	  _PDMdebug(fname, "NFMquery_table_definition status = <%d>\n", status);
		MEMclose(&attribute_buffer);
		return (PDM_E_GET_ATTRIBUTES);
          }
	}
	status = MEMbuild_array(attribute_buffer);
	if (status != MEM_S_SUCCESS) {
		_PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
		return (PDM_E_BUILD_ARRAY);
	}
	status = MEMopen(attr_bufr, 1024);
	if (status != MEM_S_SUCCESS) {
         _PDMdebug(fname, "MEMopen failed status %d\n", status);
		return (PDM_E_OPEN_BUFFER);
	}
	column_ptr = (char **) attribute_buffer->column_ptr;
	data = (char **) attribute_buffer->data_ptr;
	format_ptr = (char **) attribute_buffer->format_ptr;
	for (i = 0; i < attribute_buffer->columns; i++) {
		if (!strcmp(column_ptr[i], "n_name"))
			a1 = i;
		if (!strcmp(column_ptr[i], "n_datatype"))
			a2 = i;
	}
	status = MEMwrite_format(*attr_bufr, "p_childno", "char(20)");
	if (status != MEM_S_SUCCESS) {
	_PDMdebug(fname, "MEMwrite_format1 failed status %d\n", status);
		return (PDM_E_WRITE_FORMAT);
	}
	for (i = 0; i < attribute_buffer->rows; i++) {
		nxi = i * attribute_buffer->columns;
		status = MEMwrite_format(*attr_bufr,
					 data[nxi + a1], data[nxi + a2]);
		if (status != MEM_S_SUCCESS) {
		_PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
			return (PDM_E_WRITE_FORMAT);
		}
	}
	if (PDMdebug_on) 
	MEMprint_buffer("dynamic attr bufr", *attr_bufr, PDM_DEBUG_FILE);
	MEMclose(&attribute_buffer);
	_PDMdebug(fname,"EXIT:\n");
	return (PDM_S_SUCCESS);
}


int PDMfast_query_table_def(attribute_buffer)
	MEMptr          *attribute_buffer;
{
	int             table_no;
        char            sql[50];
        char            sql_str[512];

	PDMdebug("ENTER:PDMfast_query_table_defintion\n");

	*attribute_buffer = NULL;

 if(!strcmp(PDMexec->catalog,"nfmcatalogs")) {
sql[0]='\0'; sprintf(sql,"NFMSYSATTRIBUTES");
status = PDMget_table_no(PDMexec->catalog, "nfmsystem", &table_no);
        if (status != PDM_S_SUCCESS) {
                sprintf(s,
                        "PDMget_table_no status = <%d>\n", status);
                PDMdebug(s);
                MEMclose(attribute_buffer);
                return (PDM_E_UNKNOWN_TABLE);
        }
        }
      else
        {
sql[0]='\0'; sprintf(sql,"NFMATTRIBUTES");
status = PDMget_table_no(PDMexec->catalog, "catalog", &table_no);
        if (status != PDM_S_SUCCESS) {
                sprintf(s,
                        "PDMget_table_no status = <%d>\n", status);
                PDMdebug(s);
                MEMclose(attribute_buffer);
                return (PDM_E_UNKNOWN_TABLE);
        }
         }
         
         sql_str[0] = '\0';
      sprintf(sql_str,"SELECT n_name, n_synonym,n_datatype,n_read FROM \
  %s where n_tableno = %d AND n_name != 'n_itemno'",sql,table_no);
       status = SQLquery(sql_str,attribute_buffer,512);
	if (status != SQL_S_SUCCESS) {
		sprintf(s,
			"SQLquery failed status = <%d>\n", status);
		PDMdebug(s);
		MEMclose(attribute_buffer);
		return (PDM_E_GET_ATTRIBUTES);
	}
	PDMdebug("EXIT:PDMfast_query_table_definition\n");
        return(PDM_S_SUCCESS);
}


int PDMcreate_application(application)
MEMptr *application;
{
 char  str[100], s[300];
 
       PDMdebug("ENTER: PDMcreate_application\n");

status = MEMopen (application, 512);
      if (status != MEM_S_SUCCESS)
        {
          MEMclose (application);
          sprintf (s, "NFMRquery_addto_loc_attributes : MEMopen : <0x%.8x>", status);
          PDMdebug (s) ;
          return (status);
        }


      status = MEMwrite_format (*application, "n_type", "char(20)");
      if (status != MEM_S_SUCCESS)
        {
          MEMclose (application);
          sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite_format : <0x%.8x>", status);
          PDMdebug (s) ;
          return (status);
      }

    status = MEMwrite_format (*application, "value", "char(20)");
    if (status != MEM_S_SUCCESS)
      {
        MEMclose (application);
        sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite_format : <0x%.8x>", status);
        PDMdebug (s) ;
        return (status);
      }

      strcpy (str, "t_basic\001PDM\001") ;

      status = MEMwrite (*application, str);
      if (status != MEM_S_SUCCESS)
        {
          MEMclose (application);
          sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite : <0x%.8x>", status) ;
          return (NFM_E_MEM) ;
        }
    
       PDMdebug("EXIT: PDMcreate_application\n");
       return(NFM_S_SUCCESS);

}

int PDMcreate_application_PDM0(application)
MEMptr *application;
{
 char  str[100], s[300];
 
       PDMdebug("ENTER: PDMcreate_application_PDM0\n");

status = MEMopen (application, 512);
      if (status != MEM_S_SUCCESS)
        {
          MEMclose (application);
          sprintf (s, "NFMRquery_addto_loc_attributes : MEMopen : <0x%.8x>", status);
          PDMdebug (s) ;
          return (status);
        }


      status = MEMwrite_format (*application, "n_type", "char(20)");
      if (status != MEM_S_SUCCESS)
        {
          MEMclose (application);
          sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite_format : <0x%.8x>", status);
          PDMdebug (s) ;
          return (status);
      }

    status = MEMwrite_format (*application, "value", "char(20)");
    if (status != MEM_S_SUCCESS)
      {
        MEMclose (application);
        sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite_format : <0x%.8x>", status);
        PDMdebug (s) ;
        return (status);
      }

      strcpy (str, "t_appltable\001PDM0\001") ;

      status = MEMwrite (*application, str);
      if (status != MEM_S_SUCCESS)
        {
          MEMclose (application);
          sprintf (s, "NFMRquery_addto_loc_attributes : MEMwrite : <0x%.8x>", status) ;
          return (NFM_E_MEM) ;
        }
    
       PDMdebug("EXIT: PDMcreate_application_PDM0\n");
       return(NFM_S_SUCCESS);

}
/* added for drawing sheet support */

int PDMcreate_application1(application)
MEMptr *application;
{
 char  str[100], s[300];

       PDMdebug("ENTER: PDMcreate_application1\n");

status = MEMopen (application, 512);
      if (status != MEM_S_SUCCESS) {
          MEMclose (application);
          sprintf (s, " PDMcreate_application1 : MEMopen : <0x%.8x>",
                status);
          PDMdebug (s) ;
          return (status);
        }


      status = MEMwrite_format (*application, "n_type", "char(20)");
      if (status != MEM_S_SUCCESS) {
          MEMclose (application);
          sprintf (s,
         " PDMcreate_application1 : MEMwrite_format : <0x%.8x>", status);
          PDMdebug (s) ;
          return (status);
      }

    status = MEMwrite_format (*application, "value", "char(20)");
    if (status != MEM_S_SUCCESS) {
        MEMclose (application);
        sprintf (s,
         " PDMcreate_application1 : MEMwrite_format : <0x%.8x>", status);
        PDMdebug (s) ;
        return (status);
      }

      strcpy (str, "t_basic\001PDMDWG\001") ;

      status = MEMwrite (*application, str);
      if (status != MEM_S_SUCCESS) {
          MEMclose (application);
sprintf (s,
          " PDMcreate_application1 : MEMwrite : <0x%.8x>", status) ;
          return (NFM_E_MEM) ;
        }

       PDMdebug("EXIT: PDMcreate_application1\n");
       return(NFM_S_SUCCESS);

}

int PDMcreate_application2(application)
MEMptr *application;
{
 char  str[100], s[300];

       PDMdebug("ENTER: PDMcreate_application2\n");

status = MEMopen (application, 512);
      if (status != MEM_S_SUCCESS) {
          MEMclose (application);
          sprintf (s,
          "PDMcreate_application2 : MEMopen : <0x%.8x>", status);
          PDMdebug (s) ;
          return (status);
        }


      status = MEMwrite_format (*application, "n_type", "char(20)");
      if (status != MEM_S_SUCCESS) {
          MEMclose (application);
          sprintf (s,
          "PDMcreate_application2 : MEMwrite_format: <0x%.8x>", status);
          PDMdebug (s) ;
          return (status);
      }

    status = MEMwrite_format (*application, "value", "char(20)");
    if (status != MEM_S_SUCCESS) {
        MEMclose (application);
        sprintf (s,
         "PDMcreate_application2 : MEMwrite_format : <0x%.8x>", status);
        PDMdebug (s) ;
        return (status);
      }

      strcpy (str, "t_basic\001PDMDWG\001") ;
status = MEMwrite (*application, str);
      if (status != MEM_S_SUCCESS) {
          MEMclose (application);
          sprintf (s,
          "PDMcreate_application2 : MEMwrite : <0x%.8x>", status) ;
          return (NFM_E_MEM) ;
        }

       PDMdebug("EXIT: PDMcreate_application2\n");
       return(NFM_S_SUCCESS);

}

int PDMquery_dynamic_table_information(attribute_buffer, data_buffer,
				       list_buffers)
        MEMptr          *attribute_buffer;
        MEMptr          *data_buffer;
        MEMptr          *list_buffers;
{
        char            *fn = "PDMquery_dynamic_table_information";
        char            *pdc_tbl;
        char            low_pdc_tbl[21];

        PDMdebug("ENTER:PDMquery_dynamic_table_information\n");

        /* initialize return buffers */
      
        *attribute_buffer = NULL;
        *data_buffer = NULL;
        *list_buffers = NULL;

   /* Modification added  because:
       if the dyn table is already known, then
       PDMdyntable_for_catalog is unnecessary.
       This condition is encountered during change catalog
       when user keys in the dynamic table name which
       is already associated with another catalog MaC 112993 */

     if (!strcmp (PDMexec->dcatalog, "")) {
        status = PDMdyntable_for_catalog(&pdc_tbl);
	if (status != PDM_S_SUCCESS) {
	    _PDMdebug (fn, "PDMdyntable_for_catalog status = <%d>\n", status);
            if (pdc_tbl) free (pdc_tbl);
	    MEMclose(attribute_buffer);
	    return (PDM_E_GET_ATTRIBUTES);
	}
	else if (pdc_tbl == NULL) {
	    _PDMdebug (fn, "PDMdyntable_for_catalog status = <%d>\n", status);
	    return (PDM_E_GET_ATTRIBUTES);
	}
	else if (strcmp(pdc_tbl,"") == 0) {
	    _PDMdebug (fn, "PDMdyntable_for_catalog status = <%d>\n", status);
	    return (PDM_E_GET_ATTRIBUTES);
	}
       } 
       else {
         pdc_tbl = (char *) malloc (40);
         pdc_tbl[0] = '\0';
         strcpy (pdc_tbl, PDMexec->dcatalog);
        }

       _PDMdebug (fn, "dynamic_table [%s]\n", pdc_tbl);

     status = NFMquery_change_table_information (PDMexec->user_id, 
                                                          pdc_tbl, 
                                                          pdc_tbl, 
                                                          attribute_buffer, 
                                                          data_buffer, 
                                                          list_buffers);
            if (status  != NFM_S_SUCCESS) 
            {
              PDMconvert_to_lower(pdc_tbl,low_pdc_tbl);
             status = NFMquery_change_table_information (PDMexec->user_id, 
                                                          low_pdc_tbl, 
                                                          low_pdc_tbl, 
                                                          attribute_buffer, 
                                                          data_buffer, 
                                                          list_buffers);
            if (status  != NFM_S_SUCCESS) 
            {
              
		PDMdebug("PDMquery_dynamic_table_information: ");
		sprintf(s, "NFMquery_change_table_information = %d\n",
					status);
		PDMdebug(s);
		MEMclose(attribute_buffer);
		MEMclose(data_buffer);
		MEMclose(list_buffers);
		return (PDM_E_GET_ATTRIBUTES);
            } 
        }
        if (pdc_tbl) free (pdc_tbl);
        PDMdebug("EXIT:PDMquery_dynamic_table_information\n");
         return(PDM_S_SUCCESS);
}

int PDMsget_table_data1(return_buffer)
	
        MEMptr          *return_buffer;
{
	/*************************************************************

	  This function returns the attribute buffer,
	  data buffer and any list buffers associated with the table

	**************************************************************/

	char            *fn = "PDMsget_table_data1";
	char            loc_name[25];
        int             catno,command_no;
         char           sql_str[512];
	MEMptr          wf_buffer = NULL;
	MEMptr          attribute_buffer = NULL;
	MEMptr          data_buffer = NULL;
	MEMptr          list_buffers = NULL;

	sprintf(s, "PDMsget_table_data1: operation = <%d>\n", PDMexec->operation);
	PDMdebug(s);
	sprintf(s, "PDMsget_table_data1: entity = <%d>\n", PDMexec->entity);
	PDMdebug(s);

	/* Determine which table to get attributes for  */

	switch (PDMexec->entity) {
/*
	case PDM_LOGIN:

		switch (PDMexec->operation) {
		case ADD_DATA:
			if ((PDMexec->NFMstatus = NFMquery_login_attributes("PDM", "pdme_",&attribute_buffer, &data_buffer, &list_buffers, &wf_buffer)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s,
				"NFMquery_login_attributes status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case QUERY_DATA:
		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;
*/

	case PDM_USER:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case QUERY_DATA:
			if ((PDMexec->NFMstatus = NFMquery_add_user_attributes
			     (PDMexec->user_id,
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s,
					"NFMquery_add_user_attributes status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_PROJECT:


		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case QUERY_DATA:
			/*
			 * if ((PDMexec->NFMstatus = NFMquery_lop_attributes
			 * (PDMexec->user_id, lop_name, "",
			 * attribute_buffer, data_buffer, list_buffers))
			 * != NFM_S_SUCCESS) { PDMdebug ("PDMsget_table_data:
			 * "); sprintf (s, "NFMquery_lop_attributes =
			 * <%d>\n", PDMexec->NFMstatus); PDMdebug (s);
			 * MEMclose (attribute_buffer); MEMclose
			 * (data_buffer); MEMclose (list_buffers); return
			 * (PDM_E_GET_DATA); }
			 */
			break;

		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

		/* Determine which buffer format to use  */
/*
		switch (PDMexec->operation) {
		case ADD_DATA:

		case QUERY_DATA:

		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;
*/

	case PDM_LOC:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:

	/* Get the attributes from the nfmcatalogs table  */

			if ((PDMexec->NFMstatus =
			     NFMquery_addto_loc_attributes (PDMexec->user_id, loc_name,&attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s,
					"NFMquery_addto_loc_attributes status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}

			break;

		case QUERY_DATA:

		/* Get the attributes from the nfmcatalogs table  */

			if ((PDMexec->NFMstatus =
			     NFMquery_addto_loc_attributes
			     (PDMexec->user_id, loc_name, 
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s,
					"NFMquery_addto_loc_attributes status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			/* Get the attributes from the pdmcatalogs table  */

			if ((PDMexec->NFMstatus = NFMquery_table_attributes
			     (PDMexec->user_id, "pdmcatalogs", "pdmcatalogs",
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s, "NFMquery_table_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case MODIFY_DATA:

			/* Get the attributes from the nfmcatalogs table  */

			if ((PDMexec->NFMstatus =
			     NFMquery_changeto_loc_attributes
			     (PDMexec->user_id, loc_name, PDMexec->catalog,
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s,
					"NFMquery_changeto_loc_attributes status = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;


		default:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

/* added for add_drawing support 1/30/92 - mac*/

        case PDM_DRAWING:

                /* Determine which buffer format to use  */

                switch (PDMexec->operation) {
                case ADD_DATA:

                    if ((PDMexec->NFMstatus = NFMquery_add_item_attributes (PDMexec->user_id, PDMexec->dcatalog,&attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
                                PDMdebug("PDMsget_table_data1: ");
            sprintf(s, "NFMquery_add_item_attributes = <%d>\n", PDMexec->NFMstatus);
                                PDMdebug(s);
                                MEMclose(&attribute_buffer);
                                MEMclose(&data_buffer);
                                MEMclose(&list_buffers);
                                return (PDM_E_GET_DATA);
                        }
                        break;

                case QUERY_DATA:

                        if ((PDMexec->NFMstatus = NFMquery_item_attributes (PDMexec->user_id, PDMexec->dcatalog, PDMexec->drawing, PDMexec->drevision,&attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
                                PDMdebug("PDMsget_table_data1: ");
                                sprintf(s, "NFMquery_item_attributes = <%d>\n",
                                        PDMexec->NFMstatus);
                                PDMdebug(s);
                                MEMclose(&attribute_buffer);
                                MEMclose(&data_buffer);
                                MEMclose(&list_buffers);
                                return (PDMexec->NFMstatus);
                        }
                        break;
                case MODIFY_DATA:
status = PDMsvalidate_user_access_cl(PDMexec->user_id,
                         "PDMChange Part", "", PDMexec->project,
                      PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
                  if(status != PDM_S_SUCCESS)
                  {
        _PDMdebug (fn, "PDMsvalid_user_access failed status -> %d \n", status);
                   if (status == SQL_I_NO_ROWS_FOUND || 
                        status == SQL_E_MESSAGE ||
                         status == SQL_E_UNKNOWN_RELATION) {
                      _PDMdebug (fn, "Sql error encountered...\n");
                      return(PDM_E_NOT_IN_ACL);
                      }
                   else {
                      return(status);
                      }
                    /*return(PDM_E_NOT_IN_ACL);*/
                   }
                   NFM_PL_LOCK = NFMglobal.NFMuserid;
                        if ((PDMexec->NFMstatus = NFMprepare_update_item (PDMexec->user_id, PDMexec->dcatalog, PDMexec->drawing, PDMexec->drevision,&attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
                                PDMdebug("PDMsget_table_data1: ");
                                sprintf(s, "NFMprepare_update_item = <%d>\n",
                                      PDMexec->NFMstatus);
                                PDMdebug(s);
                                MEMclose(&attribute_buffer);
                                MEMclose(&data_buffer);
                                MEMclose(&list_buffers);
                                return (PDM_E_GET_DATA);
                        }
                        break;
                default:
                        PDMdebug("PDMsget_table_data1: ");
                        sprintf(s, "unknown operation <%d>\n",
                                PDMexec->operation);
                        PDMdebug(s);
                        return (PDM_E_INVALID_INPUT);
                }
                break;




        case PDM_DRAW_CATALOG:

                /* Determine which buffer format to use  */

                switch (PDMexec->operation) {
                case QUERY_DATA:
                        if ((PDMexec->NFMstatus = NFMquery_catalog_information (PDMexec->user_id, PDMexec->catalog,&attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
                                PDMdebug("PDMsget_table_data1: ");
                                sprintf(s, "NFMquery_catalog_information = <%d>\
n",
                                      PDMexec->NFMstatus);
                                PDMdebug(s);
                                MEMclose(&attribute_buffer);
                                MEMclose(&data_buffer);
                                MEMclose(&list_buffers);
                                return (PDM_E_GET_DATA);
                        }
                        break;
                 case ADD_DATA:
                case MODIFY_DATA:
                        if ((PDMexec->NFMstatus = NFMquery_catalog_attributes (PDMexec->user_id, PDMexec->catalog,&attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
                                PDMdebug("PDMsget_table_data1: ");
                          sprintf(s, "NFMquery_catalog_attributes = <%d>\n ", PDMexec->NFMstatus);
                                PDMdebug(s);
                                MEMclose(&attribute_buffer);
                                MEMclose(&data_buffer);
                                MEMclose(&list_buffers);
                                return (PDM_E_GET_DATA);
                        }
                        break;

                default:
                        PDMdebug("PDMsget_table_data1: ");
                        sprintf(s, "unknown operation <%d>\n",
                                PDMexec->operation);
                        PDMdebug(s);
                        return (PDM_E_INVALID_INPUT);
                }

                break;
/* end of addition for drawing support*/


	case PDM_PART:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:

			if ((PDMexec->NFMstatus = NFMquery_add_item_attributes
			     (PDMexec->user_id, PDMexec->catalog,
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s, "NFMquery_add_item_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case QUERY_INFO:
                     status = PDMsvalidate_user_access_cl(PDMexec->user_id,
                                                   "PDMCopy and Change Part",
                                                   "", PDMexec->project,
                                                   PDMexec->catalog,
                                                   PDMexec->part_num,
                                                   PDMexec->revision);
                      if(status != PDM_S_SUCCESS) {
                        _PDMdebug ("",
                            "PDMsvalid_user_access failed status 0x%.8x \n",
                              status);
                   if (status == SQL_I_NO_ROWS_FOUND || 
                        status == SQL_E_MESSAGE ||
                         status == SQL_E_UNKNOWN_RELATION) {
                      _PDMdebug (fn, "Sql error encountered...\n");
                      return(PDM_E_NOT_IN_ACL);
                      }
                   else {
                      return(status);
                      }
                    /*return(PDM_E_NOT_IN_ACL);*/
                       }
                     NFM_PL_LOCK = NFMglobal.NFMuserid;

			if ((PDMexec->NFMstatus = NFMquery_item_attributes
			     (PDMexec->user_id, PDMexec->catalog,
			      PDMexec->part_num, PDMexec->revision,
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s, "NFMquery_item_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDMexec->NFMstatus);
			}
			break;
		case QUERY_DATA:

                   status = PDMris_get_catno(PDMexec->catalog,&catno);
                   status = PDMget_commandno("Add Item", &command_no);
                    if(status != PDM_S_SUCCESS)
                     {
                    sprintf(s,"PDMget_command_no failed status %d\n",status);
                    PDMdebug(s);
                    return(PDM_E_GET_DATA);
                     }

                            WFinfo.command = command_no;
                            WFinfo.catalog_no = catno;

/*
			if ((PDMexec->NFMstatus = NFMquery_item_attributes
			     (PDMexec->user_id, PDMexec->catalog,
			      PDMexec->part_num, PDMexec->revision,
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s, "NFMquery_item_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}

  */
status = PDMsvalidate_user_access_cl(PDMexec->user_id,
                         "PDMChange Part", "", PDMexec->project,
                      PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
                  if(status != PDM_S_SUCCESS)
                  {
        _PDMdebug ("", "PDMsvalid_user_access failed status -> %d \n", status);
                   if (status == SQL_I_NO_ROWS_FOUND || 
                        status == SQL_E_MESSAGE ||
                         status == SQL_E_UNKNOWN_RELATION) {
                      _PDMdebug (fn, "Sql error encountered...\n");
                      return(PDM_E_NOT_IN_ACL);
                      }
                   else {
                      return(status);
                      }
                    /*return(PDM_E_NOT_IN_ACL);*/
                   }
                   NFM_PL_LOCK = NFMglobal.NFMuserid;

			if ((PDMexec->NFMstatus = NFMprepare_update_item
			     (PDMexec->user_id, PDMexec->catalog,
			      PDMexec->part_num, PDMexec->revision,
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s, "NFMprepare_update_item = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
                        status = PDMload_state_name(data_buffer);
			break;

		case MODIFY_DATA:
status = PDMsvalidate_user_access_cl(PDMexec->user_id,
                         "PDMChange Part", "", PDMexec->project,
                      PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
                  if(status != PDM_S_SUCCESS)
                  {
        _PDMdebug ("", "PDMsvalid_user_access failed status -> %d \n", status);
                   if (status == SQL_I_NO_ROWS_FOUND || 
                        status == SQL_E_MESSAGE ||
                         status == SQL_E_UNKNOWN_RELATION) {
                      _PDMdebug (fn, "Sql error encountered...\n");
                      return(PDM_E_NOT_IN_ACL);
                      }
                   else {
                      return(status);
                      }
                    /*return(PDM_E_NOT_IN_ACL);*/
                   }
                   NFM_PL_LOCK = NFMglobal.NFMuserid;
			if ((PDMexec->NFMstatus = NFMprepare_update_item
			     (PDMexec->user_id, PDMexec->catalog,
			      PDMexec->part_num, PDMexec->revision,
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s, "NFMprepare_update_item = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;
		default:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}
		break;

	case PDM_CATALOG:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case QUERY_DATA:
			if ((PDMexec->NFMstatus = NFMquery_catalog_information
			     (PDMexec->user_id, PDMexec->catalog,
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s, "NFMquery_catalog_information = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;
		case ADD_DATA:
		case MODIFY_DATA:
			if ((PDMexec->NFMstatus = NFMquery_catalog_attributes
			     (PDMexec->user_id, PDMexec->catalog,
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s, "NFMquery_catalog_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		default:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_CIT:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case QUERY_DATA:

			/* Get the attributes from the pdmcit table  */

			if ((PDMexec->NFMstatus = NFMquery_table_attributes
			     (PDMexec->user_id, "pdmcit", "pdmcit",
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s, "NFMquery_table_attributes status = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_BOMCONTENT:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		case QUERY_DATA:
			if ((PDMexec->NFMstatus = NFMquery_template_attributes
			( "t_appltable","bom_template","BOM",&attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s, "NFMquery_template_attributes = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;
		case MODIFY_DATA:
			if ((PDMexec->NFMstatus =
			     NFMquery_change_template_information
			("t_appltable", "bom_template","BOM",
			 &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s,
					"NFMquery_change_template_information = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;
		default:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_VIEWS:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case QUERY_DATA:
			if ((PDMexec->NFMstatus = NFMquery_table_attributes
			     (PDMexec->user_id, "pdmviews", "pdmviews",
			      &attribute_buffer, &data_buffer, &list_buffers)) != NFM_S_SUCCESS) {
				PDMdebug("PDMsget_table_data1: ");
				sprintf(s, "NFMquery_table_attributes status = %d\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_GET_DATA);
			}
			break;

		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

		break;

	case PDM_BOMS:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case QUERY_DATA:
		case MODIFY_DATA:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		default:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}

/* APOGEE START	break; APOGEE END */

	case PDM_TRANSITION:

		/* Determine which buffer format to use  */

		switch (PDMexec->operation) {
		case ADD_DATA:
		case MODIFY_DATA:

			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "operation <%d> not implemented\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);

		case QUERY_DATA:
/*
                PDMexec->NFMstatus = WFvalidate_user_access(PDMexec->user_id,
                   "PDMApprove Part","","",PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
                           if(PDMexec->NFMstatus != NFM_S_SUCCESS)
                            {
				sprintf(s, "NFMquery_item_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (status);
			}
                              
                            This is done to get NFM work
                       status = NFMreset_file_information(PDMexec->catalog,
                          PDMexec->part_num,PDMexec->revision);
                           if(PDMexec->NFMstatus != NFM_S_SUCCESS)
                            {
				sprintf(s, "NFMquery_item_attributes = <%d>\n",
					PDMexec->NFMstatus);
				PDMdebug(s);
				MEMclose(&attribute_buffer);
				MEMclose(&data_buffer);
				MEMclose(&list_buffers);
				return (PDM_E_FROM_MAKE_TRANS);
			}
*/
          sprintf( sql_str,"UPDATE %s SET n_itemlock = 'N' WHERE n_itemname = '%s' AND n_itemrev = '%s'",PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
            SQLstmt(sql_str);
                              
                if ((PDMexec->NFMstatus = PDMquery_make_transition
                     (PDMexec->user_id, &attribute_buffer,
                      &data_buffer)) != PDM_S_SUCCESS) {
                        PDMdebug("PDMsget_table_data: ");
                        _PDMdebug (fn, "PDMquery_make_transition = <%d>\n",
                                PDMexec->NFMstatus);
                        MEMclose(&attribute_buffer);
                        if (PDMexec->NFMstatus == NFM_E_TO_MAKE_TRANS)
                                        return (PDM_E_TO_MAKE_TRANS);
                        else if (PDMexec->NFMstatus == NFM_E_FROM_MAKE_TRANS)
                                        return (PDM_E_FROM_MAKE_TRANS);
                        else if (PDMexec->NFMstatus == NFM_E_NO_TRANSITIONS)
                                        return (PDM_E_NO_TRANSITIONS);
                        else if (PDMexec->NFMstatus == NFM_E_BAD_TRANSITION)
                                        return (PDM_E_BAD_TRANSITION);
                        else if (PDMexec->NFMstatus == NFM_E_ITEM_NOT_READY_IN)
                                        return (PDM_E_PART_NOT_CHECKEDIN);
                        else if (PDMexec->NFMstatus == NFM_E_BAD_STATE)
                                        return (PDM_E_BAD_STATE);
                        else if (PDMexec->NFMstatus == NFM_E_BAD_CLASS)
                                        return (PDM_E_BAD_CLASS);
                        return (PDMexec->NFMstatus);
                        }

      
          sprintf( sql_str,"UPDATE %s SET n_itemlock = 'U' WHERE n_itemname = '%s' AND n_itemrev = '%s'",PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
            SQLstmt(sql_str);
			break;
		default:
			PDMdebug("PDMsget_table_data1: ");
			sprintf(s, "unknown operation <%d>\n",
				PDMexec->operation);
			PDMdebug(s);
			return (PDM_E_INVALID_INPUT);
		}
		break;


/* added for add_parametric_part support 1/30/92 - mac*/

        case PDM_PARAMETRIC_PART:

                /* Determine which buffer format to use  */

           switch (PDMexec->operation) {
           case ADD_DATA:
           /*if (!strcmp (PDMexec->revision, "P")) */
           if ( (!strcmp (PDMexec->revision, "P"))
    /* Added to support new parametric external catalog type MaC 010194*/
                 || (!strcmp (PDMexec->revision, "PXT")) ) {
           if ((PDMexec->NFMstatus = NFMquery_add_item_attributes 
                                        (PDMexec->user_id, 
                                         PDMexec->catalog, 
                                         &attribute_buffer, 
                                         &data_buffer, 
                                         &list_buffers)) != NFM_S_SUCCESS) {
            _PDMdebug (fn, "NFMquery_add_item_attributes = <%d>\n", PDMexec->NFMstatus);
                  MEMclose(&attribute_buffer);
                  MEMclose(&data_buffer);
                  MEMclose(&list_buffers);
                  return (PDM_E_GET_DATA);
                  }
                 }
            else if (!strcmp (PDMexec->revision, "CID")) {
/*PDMexec->NFMstatus = PDMget_attr_of_view (table_type, table_name, identifier, attr_list, data_list, value_list);*/
            PDMexec->NFMstatus = PDMget_attr_of_view (PDMexec->revision, 
                                         PDMexec->catalog, 
                                         "PDM",
                                         &attribute_buffer, 
                                         &data_buffer, 
                                         &list_buffers);
                if (PDMexec->NFMstatus != NFM_S_SUCCESS) {
                     _PDMdebug (fn, "NFMquery_add_item_attributes = <%d>\n", 
                                   PDMexec->NFMstatus);
                     MEMclose(&attribute_buffer);
                     MEMclose(&data_buffer);
                     MEMclose(&list_buffers);
                     return (PDM_E_GET_DATA);
                      }
 
             }
             else
                {
              _PDMdebug (fn, "Invalid Catalog Type [%s]\n", PDMexec->revision);
                    }
/*
               PDMexec->NFMstatus = PDMget_list_for_modify ( attribute_buffer,
                                         data_buffer,
					 PDMexec->revision);
                if (PDMexec->NFMstatus != PDM_S_SUCCESS) {
                     _PDMdebug (fn, "PDMget_list_for_modify = <%d>\n",
                                   PDMexec->NFMstatus);
                     MEMclose(&attribute_buffer);
                     MEMclose(&data_buffer);
                     MEMclose(&list_buffers);
                     return (PDM_E_GET_DATA);
                      }
  */
                  break;

           case QUERY_DATA:

             if ((PDMexec->NFMstatus = NFMquery_item_attributes 
                                        (PDMexec->user_id, 
                                         PDMexec->dcatalog, 
                                         PDMexec->drawing, 
                                         PDMexec->drevision, 
                                         &attribute_buffer, 
                                         &data_buffer, 
                                         &list_buffers)) != NFM_S_SUCCESS) {
                   _PDMdebug (fn, "NFMquery_item_attributes = <%d>\n",
                                        PDMexec->NFMstatus);
                    MEMclose(&attribute_buffer);
                    MEMclose(&data_buffer);
                    MEMclose(&list_buffers);
                    return (PDMexec->NFMstatus);
                    }
               break;
           case MODIFY_DATA:
           /*if (!strcmp (PDMexec->revision, "P")) */
           if ( (!strcmp (PDMexec->revision, "P"))
    /* Added to support new parametric external catalog type MaC 010194*/
                 || (!strcmp (PDMexec->revision, "PXT")) ) {
           if ((PDMexec->NFMstatus = NFMquery_add_item_attributes 
                                        (PDMexec->user_id, 
                                         PDMexec->catalog, 
                                         &attribute_buffer, 
                                         &data_buffer, 
                                         &list_buffers)) != NFM_S_SUCCESS) {
            _PDMdebug (fn, "NFMquery_add_item_attributes = <%d>\n", 
                                                 PDMexec->NFMstatus);
                  MEMclose(&attribute_buffer);
                  MEMclose(&data_buffer);
                  MEMclose(&list_buffers);
                  return (PDM_E_GET_DATA);
                  }
                 }
            else if (!strcmp (PDMexec->revision, "CID")) {
            PDMexec->NFMstatus = PDMget_attr_of_view (PDMexec->revision, 
                                         PDMexec->catalog, 
                                         "PDM",
                                         &attribute_buffer, 
                                         &data_buffer, 
                                         &list_buffers);
                if (PDMexec->NFMstatus != NFM_S_SUCCESS) {
                     _PDMdebug (fn, "NFMquery_add_item_attributes = <%d>\n", 
                                   PDMexec->NFMstatus);
                     MEMclose(&attribute_buffer);
                     MEMclose(&data_buffer);
                     MEMclose(&list_buffers);
                     return (PDM_E_GET_DATA);
                      }
 
             }
             else
                {
              _PDMdebug (fn, "Invalid Catalog Type [%s]\n", PDMexec->revision);
                    }
/*
               PDMexec->NFMstatus = PDMget_list_for_modify ( attribute_buffer,
                                         data_buffer,
					 PDMexec->revision);
                if (PDMexec->NFMstatus != PDM_S_SUCCESS) {
                     _PDMdebug (fn, "PDMget_list_for_modify = <%d>\n",
                                   PDMexec->NFMstatus);
                     MEMclose(&attribute_buffer);
                     MEMclose(&data_buffer);
                     MEMclose(&list_buffers);
                     return (PDM_E_GET_DATA);
                      }
  */

                 break;
                default:
                        _PDMdebug (fn, "unknown operation <%d>\n",
                                PDMexec->operation);
                        return (PDM_E_INVALID_INPUT);
                }
                break;


/* End of additions for PDMparametric support */




	default:
		sprintf(s, "PDMsget_table_data1: unknown entity <%d>\n",
			PDMexec->entity);
		PDMdebug(s);
		return (PDM_E_INVALID_INPUT);
	}

	/* Make sure there is a data buffer  */

	if (data_buffer == NULL) {
		if ((PDMexec->MEMstatus = MEMopen(&data_buffer, 0)) != MEM_S_SUCCESS) {
			MEMclose(&attribute_buffer);
			MEMclose(&data_buffer);
			MEMclose(&list_buffers);
			sprintf(s, "PDMsget_table_data1: MEMopen status = <%d>\n",
				PDMexec->MEMstatus);
			PDMdebug(s);
			return (PDM_E_OPEN_BUFFER);
		}
	}


	/* Append the buffers together  */

	if ((PDMexec->MEMstatus = MEMappend
	     (data_buffer, attribute_buffer)) != MEM_S_SUCCESS) {
		MEMclose(&attribute_buffer);
		MEMclose(&data_buffer);
		MEMclose(&list_buffers);
		sprintf(s, "PDMsget_table_data1: MEMappend status = <%d>\n",
			PDMexec->MEMstatus);
		PDMdebug(s);
		return (PDM_E_APPEND_BUFFER);
	}
	if (list_buffers == NULL) {
		if ((PDMexec->MEMstatus = MEMopen(&list_buffers, 0)) != MEM_S_SUCCESS) {
			MEMclose(&attribute_buffer);
			MEMclose(&data_buffer);
			sprintf(s, "PDMsget_table_data1: MEMopen status = <%d>\n",
				PDMexec->MEMstatus);
			PDMdebug(s);
			return (PDM_E_OPEN_BUFFER);
		}
	}
	if (list_buffers != NULL) {
		if ((PDMexec->MEMstatus = MEMappend
		 (list_buffers ,attribute_buffer)) != MEM_S_SUCCESS) {
			MEMclose(&attribute_buffer);
			MEMclose(&data_buffer);
			MEMclose(&list_buffers);
			sprintf(s, "PDMsget_table_data1: MEMappend status = <%d>\n",
				PDMexec->MEMstatus);
			PDMdebug(s);
			return (PDM_E_APPEND_BUFFER);
		}
	}
	if (wf_buffer != NULL) {
		if ((PDMexec->MEMstatus = MEMappend
		     (wf_buffer, attribute_buffer)) != MEM_S_SUCCESS) {
			MEMclose(&attribute_buffer);
			MEMclose(&data_buffer);
			MEMclose(&list_buffers);
			MEMclose(&wf_buffer);
			sprintf(s, "PDMsget_table_data1: MEMappend status = <%d>\n",
				PDMexec->MEMstatus);
			PDMdebug(s);
			return (PDM_E_APPEND_BUFFER);
		}
	}
	/* Close the local buffers  */

    *return_buffer = attribute_buffer;

	MEMclose(&data_buffer);
	MEMclose(&list_buffers);

	PDMdebug("PDMsget_table_data1: returning SUCCESS\n");
	return (PDM_S_SUCCESS);
}

/* ALR  9/2/93  Function to retrieve dynamic updatable attributes
   from nfmattributes for a dynamic table no.
*/

int PDMget_dyn_upd_attr(dyn_tab_no, attr_buff, data_buff)
int dyn_tab_no;
MEMptr *attr_buff;
MEMptr *data_buff;
{

   long status;
   int attrno, nxi, i;
   char sql_str[180], **data_ptr;
   MEMptr attribute_buffer = NULL;
   MEMptr data_buffer = NULL;

   PDMdebug("PDMget_dyn_upd_attr: Enter \n");

   sprintf(sql_str,"select n_attrno, n_name, n_datatype, n_synonym, n_write, n_null from nfmattributes where (n_tableno = %d) and (n_write = 'Y')\0",dyn_tab_no);

   status = SQLquery(sql_str,&attribute_buffer,MEM_SIZE);
   if (status != SQL_S_SUCCESS)
    {
        sprintf(s,"%s failed <0x%.8x> \n",sql_str,status);
        PDMdebug(s); 
        return(status);
     }

   status = MEMbuild_array(attribute_buffer);
   if (status != MEM_S_SUCCESS)
   {
      sprintf(s,"MEMbuild_array failed <0x%.8x> \n",status);
      PDMdebug(s);
      return(status);
   }

MEMprint_buffer("attr buffer",attribute_buffer,"/usr/tmp/pdm.dbg");

   data_ptr = (char **)attribute_buffer->data_ptr;

   for (i=0; i < attribute_buffer->rows; i++)
   { 
     nxi = i * attribute_buffer->columns;
     attrno = atoi(data_ptr[nxi]);

     sprintf(sql_str,"select n_defaultvalue, n_listno, n_maxvalue, n_minvalue from nfmvalues where n_attrno = %d \0",attrno);
     status = SQLquery(sql_str,&data_buffer,MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        if (status == SQL_I_NO_ROWS_FOUND)
         {
           status = MEMwrite(data_buffer,"\1\1\1\1");
           if (status != MEM_S_SUCCESS)
            {
              sprintf(s,"PDMget_dyn_upd_attr: MEMwrite failed %d \n",status);
              PDMdebug(s);
              MEMclose(&data_buffer);
              return(status);
            }
            status = MEMbuild_array(data_buffer);
            if (status != MEM_S_SUCCESS)
             {
                sprintf(s,"PDMget_dyn_upd_attr: MEMbuild_array failed %d \n",status);
                PDMdebug(s);
                MEMclose(&data_buffer);
                return(status);
             }
         }
         else
         {
          sprintf(s,"%s failed <0x%.8x> \n",sql_str,status);
          PDMdebug(s);
          return(status);
         }
      }
   }

   status = MEMbuild_array(data_buffer);
   if (status != MEM_S_SUCCESS)
    {
      sprintf(s,"MEMbuild_array failed <0x%.8x> \n",status);
      PDMdebug(s);
      return(status);
    }

MEMprint_buffer("data buff",data_buffer,"/usr/tmp/pdm.dbg");

   *attr_buff = attribute_buffer;
   *data_buff = data_buffer;

   PDMdebug("PDMget_dyn_upd_attr: Exit \n");

   return(PDM_S_SUCCESS);
}

/* ALR   9/3/93   Function to retrieve the list buffer associated with
   an attribute. */

int PDMget_list_buffer(cat_name, attr_name, list_buffer)
char *cat_name, *attr_name;
MEMptr *list_buffer;
{
   long status, tabno, attno, listno;
   char sql_str[180], **tab_data, **att_data, **list_data, dyn_name[30];
   MEMptr tmp_buff = NULL;
  
   PDMdebug("PDMget_list_buffer : Enter\n"); 

   status = PDMget_dyntable_for_catalog(cat_name,dyn_name);
   if (status != PDM_S_SUCCESS)
    return(status);

   sprintf(sql_str,"select n_tableno from nfmtables where n_tablename = '%s'\0",dyn_name);
   status = SQLquery(sql_str,&tmp_buff,MEM_SIZE);
   if (status != SQL_S_SUCCESS)
    {
      sprintf(s,"PDMget_list_buffer: %s failed <0x%.8x>\n",sql_str,status);
      PDMdebug(s);
      return(status); 
    } 

   status = MEMbuild_array(tmp_buff);
   if (status != MEM_S_SUCCESS)
    {
      sprintf(s,"PDMget_list_buffer: MEMbuild_array failed <0x%.8x> \n",status);
      PDMdebug(s);
      return(status);
    } 

    tab_data = (char **)tmp_buff->data_ptr;
    tabno = atoi(tab_data[0]);
    MEMclose(&tmp_buff);

    sprintf(sql_str,"select n_attrno from nfmattributes where n_tableno = %d and n_name = '%s'\0",tabno,attr_name);
    status = SQLquery(sql_str,&tmp_buff,MEM_SIZE);
    if (status != SQL_S_SUCCESS)
     {
       sprintf(s,"PDMget_list_buff: %s failed <0x%.8x> \n",sql_str,status);
       PDMdebug(s);
       return(status);
     } 

     status = MEMbuild_array(tmp_buff);
     if (status != MEM_S_SUCCESS)
      {
       sprintf(s,"PDMget_list_buff: MEMbuild_array failed <0x%.8x> \n",status);
       PDMdebug(s);
       return(status);
      }

      att_data = (char **)tmp_buff->data_ptr;
      attno = atoi(att_data[0]);
     
      MEMclose(&tmp_buff);

      sprintf(sql_str,"select n_listno from nfmvalues where n_attrno = %d \0",attno);
      status = SQLquery(sql_str,&tmp_buff,MEM_SIZE);
      if (status != SQL_S_SUCCESS)
       {
        sprintf(s,"PDMget_list_buff: %s failed <0x%.8x> \n",sql_str,status);
        PDMdebug(s);
        return(status);
       } 

       status = MEMbuild_array(tmp_buff);
       if (status != MEM_S_SUCCESS)
        {
         sprintf(s,"PDMget_list_buff: MEMbuild_array failed <0x%.8x> \n",status);
         PDMdebug(s);
         return(status);
        } 
 
        list_data = (char **)tmp_buff->data_ptr;
        if (list_data[0])
         listno = atoi(list_data[0]);
        else
         {
           list_buffer = NULL;
           MEMclose(&tmp_buff);
           PDMdebug("PDMget_list_buff: EXIT");
           return(PDM_S_SUCCESS);
         }

        MEMclose(&tmp_buff);

        sprintf(sql_str,"select n_value from nfmlists where n_listno = %d \0",listno);
        status = SQLquery(sql_str,list_buffer,MEM_SIZE);
        if (status != SQL_S_SUCCESS)
          {
            sprintf(s,"PDMget_list_buff: %s failed <0x%.8x> \n",sql_str,status);
            PDMdebug(s);
            return(status);
          } 

        status = MEMbuild_array((*list_buffer));
        if (status != MEM_S_SUCCESS)
         {
           sprintf(s,"PDMget_list_buff: MEMbuild_array failed <0x%.8x> \n",status);
            PDMdebug(s);
            return(status);
         }

        PDMdebug("PDMget_list_buff: EXIT");

        return(PDM_S_SUCCESS);
} 
