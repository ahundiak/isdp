#include <stdio.h>
#include "MEMstruct.h"
#include <PDMcommand.h>
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "PDUfile_def.h"
#include "MEMerrordef.h"
#include "PDMmessage.h"
#include <PDUproto.h>
#include <PDMproto.h>

static char s[1024];
extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;

/* 
   The BOM content is first defined during PDM initialization.
   Later on, the content of the BOM can be modified. The ws_buffer 
   contains all the three buffers from a previous call to 
   NFMquery_change_template_attributes(). All the attributes 
   that have a 2 nd character == "_" are expected to be not
   touched by the user. But the synonyms may be changed. The 
   user defined attributes can be modified, added, or dropped 

   PDMget_table_attribute(..."pdmbomcontent","MODIFY" ...).
   Subsequently it can call PDMmodify_bom_content() with these 
   attr_bufr and data_bufr buffers.

   Note that the attr_bufr works as follows

   (1) To add a NEW user defined attribute
	   keyin user def attr name into n_name   &
	      the datatype to go along withit into n_datatype
   (2) To DROP existing stuff key in "DROP" into new_n_name
   (3) To CHANGE an existing user defined attribute
	   keyin NEW user def attr name into new_n_name   &
	  the NEW datatype to go along withit into new_n_datatype
 
*/

int PDMmodify_bom_content(attr_bufr,data_bufr,list_bufr, map_bufr)
MEMptr		attr_bufr;
MEMptr		data_bufr;
MEMptr		list_bufr;
MEMptr		map_bufr;
{
	int		status;
	_pdm_debug("ENTER:PDMmodify_bom_content", 0);

if(PDMdebug_on)
{
	MEMprint_buffer("attr_bufr",attr_bufr,PDU_DEBUG_FILE);
	MEMprint_buffer("data_bufr",data_bufr,PDU_DEBUG_FILE);
}

	/* load exec structure */
	PDUload_exec_structure("","", "", "", "","","",0, 0);

	/*if (attr_bufr == NULL) MEMopen(&attr_bufr, 512);
	if (data_bufr == NULL) MEMopen(&data_bufr, 512);
	if (list_bufr == NULL) MEMopen(&list_bufr, 512);
	if (map_bufr == NULL) MEMopen(&map_bufr, 512);*/

	_pdm_debug("calling PDMsmodify_bom_content", 0);
	status = PDMsmodify_bom_content(attr_bufr, data_bufr, list_bufr,
					map_bufr);
	_pdm_status("PDMsmodify_bom_content", status);

	if (status != PDM_S_SUCCESS)
	  {
	  PDUmessage(status, 's');
	  return(status);
	  }

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug("EXIT:PDMmodify_bom_content", 0);
	return (status);
}

/*
	 This function returns attr_bufr in MODIFY buffer format 
     It contains all the attributes in pdmbomcontent
     PDM req + user defined attrbs.
     The lower half of the buffer contains the mapped names
     for the catalog.
*/

int PDMget_bommap_attributes(catalog,attr_bufr)
char		*catalog;
MEMptr		*attr_bufr;
{
	int	status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMget_bommap_attributes", 0);

	/* load exec structure */
	PDUload_exec_structure("", catalog, "", "", "","","",0, 0);

	_pdm_debug("calling PDMsget_bommap_attributes", 0);
	status = PDMsget_bommap_attributes(attr_bufr);
	_pdm_status("PDMsget_bommap_attributes", status);
	
	if (status != PDM_S_SUCCESS)
          {
	  PDUmessage(status, 's');
	  MEMclose(attr_bufr);
	  return(status);
	  }

	_pdm_debug("EXIT:PDMget_bommap_attributes", 0);
	return(PDUsts->PDMrstatus);
}

/*
		type = 2 for BOTH
		type = 1 for REVIEW BOM
		type = 0 for ACTIVE BOM
*/

int PDMrdelete_bom (catalog,n_itemname,n_itemrev)
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  {
	int	status = PDM_S_SUCCESS;

	sprintf (s, "PDMrdelete_bom: catalog = <%s>\n", catalog);
	_pdm_debug (s, 0);
	sprintf (s, "PDMrdelete_bom: n_itemname = <%s>\n", n_itemname);
	_pdm_debug (s, 0);
	sprintf (s, "PDMrdelete_bom: n_itemrev = <%s>\n", n_itemrev);
	_pdm_debug (s, 0);

	/* load exec structure */
	PDUload_exec_structure("", catalog, n_itemname,n_itemrev, "","","",0,0);

	_pdm_debug("calling PDMdelete_bom", 0);
	status = PDMdelete_bom();
	_pdm_status("PDMdelete_bom", status);

	if (status != PDM_S_SUCCESS)
	  {
	  PDUmessage(status, 's');
	  return(status);
	  }

	_pdm_debug ("PDMrdelete_bom: returning SUCCESS", 0);
        PDUmessage(status, 's');
	return (status);
 }

/*
	Generates the BOM PARTS LIST

	INPUT:
			catalog
			n_itemname
			n_itemrev
			level      -> default should be 1
						  specifies the level to which the 
						  report should be generated

	OUTPUT:
	
			bom_name	-> BOM table name
			table_name  -> temp table name

			Columns in table_name:
	
			n_catalogname,n_itemname,n_itemrev,p_level
			p_seqno,p_tagno,p_qty

	p_qty is in integer specifying the number of times a 
	part is placed
*/

int PDMprepare_bomparts_list(catalog,partnum, revision, filename,template_name,
                              saname)

  char		*catalog;
  char		*partnum;
  char		*revision;
  char          *filename;
  char          *template_name;
  char          *saname;
  {
	MEMptr	ret_bufr = NULL;
	char	**data = NULL;
        int     status;
	
	sprintf (s, "PDMprepare_bomparts_list: catalog = <%s>\n", catalog);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_bomparts_list: partnum = <%s>\n", partnum);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_bomparts_list: revision = <%s>\n", revision);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_bomparts_list: template_name = <%s>\n",
                 template_name);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_bomparts_list: saname = <%s>\n", saname);
	_pdm_debug (s, 0);

        PDUmessage(PDS_M_GEN_BOM_PARTS_LIST, 's');
	/* load exec structure */
        PDUload_exec_structure("", catalog, partnum, revision, filename,
			       template_name, saname, 0,0);

        _pdm_debug("calling PDMgen_bomparts_list", 0);
        status = PDMgen_bomparts_list(&ret_bufr);
        _pdm_status("PDMgen_bomparts_list", status);

        if (status != PDM_S_SUCCESS)
          {
          if(status != PDM_E_DBA_SINGLE && status != PDM_E_USER_NOT_LOGGED_IN)
          PDUmessage(status, 's');
	  MEMclose(&ret_bufr);
          return(status);
          }

	if ((status = MEMbuild_array(ret_bufr)) 
				!= MEM_S_SUCCESS)
	  {
		MEMclose(&ret_bufr);
		status = PDM_E_BUILD_ARRAY;
		return (status);
	  }
    data = (char **) ret_bufr->data_ptr;
	if(ret_bufr->rows)
	{
		strcpy(filename,data[0]);
		MEMclose(&ret_bufr);
    }
	else
	{
		_pdm_debug("bufr empty ", 0);
		return(PDM_E_FAILURE);
	}
     MEMclose(&ret_bufr);
	_pdm_debug ("PDMprepare_bomparts_list: returning SUCCESS", 0);
        PDUmessage(PDM_S_SUCCESS, 's');
	return (PDM_S_SUCCESS);
 }

/*
	Generates the SUMMARY BOM 

	INPUT:
			catalog
			n_itemname
			n_itemrev
			level      -> set it to -1

	OUTPUT:
	

			Columns in table_name:
	
			p_seqno,n_catalogname,n_itemname,n_itemrev,p_qty

	p_qty is in integer specifying the number of times a 
	part is placed
*/

int PDMprepare_summary_bom(catalog, partnum, revision, filename, template_name,
                           saname)

  char		*catalog;
  char		*partnum;
  char		*revision;
  char		*filename;
  char          *template_name;
  char          *saname;
  {
	MEMptr	ret_bufr = NULL;
	char	**data;
        int     status;
	
	sprintf (s, "PDMprepare_summary_bom: catalog = <%s>\n", catalog);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_summary_bom: partnum = <%s>\n", partnum);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_summary_bom: revision = <%s>\n", revision);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_summary_bom: template_name = <%s>\n",
                 template_name);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_summary_bom: saname = <%s>\n", saname);
	_pdm_debug (s, 0);

	/* load exec structure */
        PDUmessage(PDS_M_GEN_SUMMARY_BOM, 's');
        PDUload_exec_structure("", catalog, partnum, revision, filename,
			       template_name,saname,-1, 0);

        _pdm_debug("calling PDMgen_summary_bom", 0);
        status = PDMgen_summary_bom(&ret_bufr);
        _pdm_status("PDMgen_summary_bom", status);

        if (status != PDM_S_SUCCESS)
          {
          if(status != PDM_E_DBA_SINGLE && status != PDM_E_USER_NOT_LOGGED_IN)
          PDUmessage(status, 's');
	  MEMclose(&ret_bufr);
          return(status);
          }

	if ((status = MEMbuild_array(ret_bufr)) 
				!= MEM_S_SUCCESS)
	  {
		MEMclose(&ret_bufr);
		status = PDM_E_BUILD_ARRAY;
		return (status);
	  }
    data = (char **) ret_bufr->data_ptr;
	if(ret_bufr->rows)
	{
		strcpy(filename,data[0]);
		MEMclose(&ret_bufr);
    }
	else
	{
		_pdm_debug("bufr empty ", 0);
		MEMclose(&ret_bufr);
		return(PDM_E_FAILURE);
	}

	return (PDM_S_SUCCESS);
 }

int PDMprepare_explode_summary_bom(catalog, partnum, revision, filename, template_name,
                           saname)

  char		*catalog;
  char		*partnum;
  char		*revision;
  char		*filename;
  char          *template_name;
  char          *saname;
  {
	MEMptr	ret_bufr = NULL;
	char	**data;
        int     status;
	
	sprintf (s, "PDMprepare_explode_summary_bom: catalog = <%s>\n", catalog);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_explode_summary_bom: partnum = <%s>\n", partnum);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_explode_summary_bom: revision = <%s>\n", revision);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_explode_summary_bom: template_name = <%s>\n",
                 template_name);
	_pdm_debug (s, 0);
	sprintf (s, "PDMprepare_explode_summary_bom: saname = <%s>\n", saname);
	_pdm_debug (s, 0);

	/* load exec structure */
        PDUmessage(PDS_M_GEN_BOM, 's');
        PDUload_exec_structure("", catalog, partnum, revision, filename,
			       template_name,saname,-1, 0);

        _pdm_debug("calling PDMgen_summary_bom", 0);
        status = PDMgen_explode_summary_bom(&ret_bufr);
        _pdm_status("PDMgen_explode_summary_bom", status);

        if (status != PDM_S_SUCCESS)
          {
          if(status != PDM_E_DBA_SINGLE && status != PDM_E_USER_NOT_LOGGED_IN)
          PDUmessage(status, 's');
	  MEMclose(&ret_bufr);
          return(status);
          }

	if ((status = MEMbuild_array(ret_bufr)) 
				!= MEM_S_SUCCESS)
	  {
		MEMclose(&ret_bufr);
		status = PDM_E_BUILD_ARRAY;
		return (status);
	  }
    data = (char **) ret_bufr->data_ptr;
	if(ret_bufr->rows)
	{
		strcpy(filename,data[0]);
		MEMclose(&ret_bufr);
    }
	else
	{
		_pdm_debug("bufr empty ", 0);
		MEMclose(&ret_bufr);
		return(PDM_E_FAILURE);
	}

	return (PDM_S_SUCCESS);
 }

/*
	Generates WHERE USED IMMEDIATE

	INPUT:
			catalog
			n_itemname
			n_itemrev

	OUTPUT:
	

			Columns in table_name:
	
			n_catalogname,n_itemname,n_itemrev

*/

int PDMgen_where_used_imm(catalog,partnum,revision,filename,template_name,
                         saname)

  char		*catalog;
  char		*partnum;
  char		*revision;
  char          *filename;
  char          *template_name;
  char          *saname;

  {
	MEMptr	ret_bufr = NULL;
	char	**data;		
        int     status;
	
	sprintf (s, "PDMgen_where_used_imm: catalog = <%s>\n", catalog);
	_pdm_debug (s, 0);
	sprintf (s, "PDMgen_where_used_imm: partnum = <%s>\n", partnum);
	_pdm_debug (s, 0);
	sprintf (s, "PDMgen_where_used_imm: revision = <%s>\n", revision);
	_pdm_debug (s, 0);
	sprintf (s, "PDMgen_where_used_imm: template_name = <%s>\n", 
                 template_name);
	_pdm_debug (s, 0);
	sprintf (s, "PDMgen_where_used_imm: saname = <%s>\n", saname);
	_pdm_debug (s, 0);

	/* load exec structure */
        PDUload_exec_structure("", catalog, partnum, revision, filename,
                               template_name, saname, 0,0);

        _pdm_debug("calling PDMsgen_where_used_imm", 0);
        status = PDMsgen_where_used_imm(&ret_bufr);
        _pdm_status("PDMsgen_where_used_imm", status);

        if (status != PDM_S_SUCCESS)
          {
          if(status != PDM_E_DBA_SINGLE && status != PDM_E_USER_NOT_LOGGED_IN)
          PDUmessage(status, 's');
          MEMclose(&ret_bufr);
          return(status);
          }

	if ((status = MEMbuild_array(ret_bufr)) 
				!= MEM_S_SUCCESS)
	  {
		MEMclose(&ret_bufr);
		status = PDM_E_BUILD_ARRAY;
		return (status);
	  }
    data = (char **) ret_bufr->data_ptr;
	if(ret_bufr->rows)
	{
		strcpy(filename,data[0]);
		MEMclose(&ret_bufr);
    }
	else
	{
		_pdm_debug("bufr empty ", 0);
		return(PDM_E_FAILURE);
	}

        MEMclose(&ret_bufr);
	_pdm_debug ("PDMgen_where_used_imm: returning SUCCESS", 0);
	return (PDM_S_SUCCESS);
 }

/*
	Generates WHERE USED HIGHEST

	INPUT:
			catalog
			n_itemname
			n_itemrev

	OUTPUT:
	
			table_name  -> temp table name

			Columns in table_name:
	
			n_catalogname,n_itemname,n_itemrev

*/

int PDMgen_where_used_top(catalog,partnum,revision,filename,template_name,
                          saname)

  char		*catalog;
  char		*partnum;
  char		*revision;
  char		*filename;
  char		*template_name;
  char		*saname;

  {
	MEMptr	ret_bufr = NULL;
	char	**data = NULL;
        int     status;
	
	sprintf (s, "PDMgen_where_used_top: catalog = <%s>\n", catalog);
	_pdm_debug (s, 0);
	sprintf (s, "PDMgen_where_used_top: partnum = <%s>\n", partnum);
	_pdm_debug (s, 0);
	sprintf (s, "PDMgen_where_used_top: revision = <%s>\n", revision);
	_pdm_debug (s, 0);

	/* load exec structure */
        PDUload_exec_structure("", catalog, partnum, revision, filename,
			       template_name, saname, 0,0);

        _pdm_debug("calling PDMsgen_where_used_top", 0);
        status = PDMsgen_where_used_top(&ret_bufr);
        _pdm_status("PDMsgen_where_used_top", status);

        if (status != PDM_S_SUCCESS)
          {
          if(status != PDM_E_DBA_SINGLE && status != PDM_E_USER_NOT_LOGGED_IN)
          PDUmessage(status, 's');
	  MEMclose(&ret_bufr);
          return(status);
          }

	if ((status = MEMbuild_array(ret_bufr)) 
				!= MEM_S_SUCCESS)
	  {
		MEMclose(&ret_bufr);
		status = PDM_E_BUILD_ARRAY;
		return (status);
	  }
    data = (char **) ret_bufr->data_ptr;
	if(ret_bufr->rows)
	{
		strcpy(filename,data[0]);
		MEMclose(&ret_bufr);
    }
	else
	{
		_pdm_debug("bufr empty ", 0);
		return(PDM_E_FAILURE);
	}

        MEMclose(&ret_bufr);
	_pdm_debug ("PDMgen_where_used_top: returning SUCCESS", 0);
	return (PDM_S_SUCCESS);
 }

int PDMgen_bom_report(catalog,partnum,revision,filename,template_name,saname)

  char		*catalog;
  char		*partnum;
  char		*revision;
  char		*filename;
  char		*template_name;
  char		*saname;

  {
	MEMptr	ret_bufr = NULL;
	char	**data = NULL;
        int     status;
	
	sprintf (s, "PDMgen_bom_report: catalog = <%s>\n", catalog);
	_pdm_debug (s, 0);
	sprintf (s, "PDMgen_bom_report: partnum = <%s>\n", partnum);
	_pdm_debug (s, 0);
	sprintf (s, "PDMgen_bom_report: revision = <%s>\n", revision);
	_pdm_debug (s, 0);

        PDUmessage(PDS_M_GEN_EXPLODE_BOM, 's');
	/* load exec structure */
        PDUload_exec_structure("", catalog, partnum,revision, filename,
                               template_name,saname,0, 0); 

        _pdm_debug("calling PDMgenerate_review_bom", 0);
        status = PDMgenerate_review_bom(&ret_bufr);
        _pdm_status("PDMgenerate_review_bom", status);

        if (status != PDM_S_SUCCESS)
          {
          if(status != PDM_E_DBA_SINGLE && status != PDM_E_USER_NOT_LOGGED_IN)
          PDUmessage(status, 's');
	  MEMclose(&ret_bufr);
          return(status);
          }

	if ((status = MEMbuild_array(ret_bufr)) 
				!= MEM_S_SUCCESS)
	  {
		MEMclose(&ret_bufr);
		status = PDM_E_BUILD_ARRAY;
		return (status);
	  }
    data = (char **) ret_bufr->data_ptr;
	if(ret_bufr->rows)
	{
		strcpy(filename,data[0]);
		MEMclose(&ret_bufr);
    }
	else
	{
		_pdm_debug("bufr empty ", 0);
		return(PDM_E_FAILURE);
	}

        MEMclose(&ret_bufr);
	_pdm_debug ("PDMgen_report_bom: returning SUCCESS", 0);
	return (PDM_S_SUCCESS);
 }

int PDMrupdate_bom(catalog, partnum, revision)
  char		*catalog;
  char		*partnum;
  char		*revision;
  {
	int	status = PDM_S_SUCCESS;
        char    bomname[41];

	sprintf (s, "PDMrupdate_bom catalog = <%s>\n", catalog);
	_pdm_debug (s, 0);
	sprintf (s, "PDMrupdate_bom partnum = <%s>\n", partnum);
	_pdm_debug (s, 0);
	sprintf (s, "PDMrupdate_bom revision = <%s>\n", revision);
	_pdm_debug (s, 0);

        PDUmessage(PDS_M_UPDATE_BOM, 's');

	/* load exec structure */
	PDUload_exec_structure("", catalog,partnum,revision,"","","",0,0);

	_pdm_debug("calling PDMupdate_exist_bom", 0);
        PDUdeactivate_stop_sign();
	status = PDMupdate_exist_bom(bomname);
	_pdm_status("PDMupdate_exist_bom", status);
        PDUactivate_stop_sign();

	if (status != PDM_S_SUCCESS)
          {
          if(status != PDM_E_DBA_SINGLE && status != PDM_E_USER_NOT_LOGGED_IN)
	  PDUmessage(status, 's');
	  return(status);
	  }

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug ("PDMrupdate_bom: returning SUCCESS", 0);
	return (PDM_S_SUCCESS);
 }
