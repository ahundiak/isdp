#include	<stdio.h>
#include	<PDUstr.h>
#include	<PDUerror.h>
#include	<MEMerrordef.h>
#include	<PDUproto.h>

int PDUcreate_table_group_search_sort_buffers( tbl_bufr, grp_bufr, 
			search_name_bufr, search_str_bufr, sort_name_bufr, 
			sort_str_bufr)
  MEMptr		*tbl_bufr;
  MEMptr		*grp_bufr;
  MEMptr		*search_name_bufr;
  MEMptr		*search_str_bufr;
  MEMptr		*sort_name_bufr;
  MEMptr		*sort_str_bufr;
  {
    int			status;
    MEMptr		bufr1 = NULL;
    MEMptr		bufr2 = NULL;
    MEMptr		bufr3 = NULL;
    MEMptr		bufr4 = NULL;
    MEMptr		bufr5 = NULL;
    MEMptr		bufr6 = NULL;

    status = MEMopen(&bufr1, 512);
    _pdm_status("MEMopen", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(&bufr1);
        *tbl_bufr = NULL;
        *grp_bufr = NULL;
        *search_name_bufr = NULL;
 	*search_str_bufr = NULL;
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_OPEN_BUFFER);
      }

    status = MEMwrite_format(bufr1, "table_name", "char(40)");
    _pdm_status("MEMwrite_format", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(&bufr1);
        *tbl_bufr = NULL;
        *grp_bufr = NULL;
        *search_name_bufr = NULL;
 	*search_str_bufr = NULL;
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_WRITE_FORMAT);
      }

    status = MEMwrite(bufr1, "");
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(&bufr1);
        *tbl_bufr = NULL;
        *grp_bufr = NULL;
        *search_name_bufr = NULL;
 	*search_str_bufr = NULL;
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_WRITE_BUFFER);
      }

    *tbl_bufr = bufr1;
   
    status = MEMopen(&bufr2, 512);
    _pdm_status("MEMopen", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(&bufr2);
        *grp_bufr = NULL;
        *search_name_bufr = NULL;
 	*search_str_bufr = NULL;
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_OPEN_BUFFER);
      }

    status = MEMwrite_format(bufr2, "group_name", "char(40)");
    _pdm_status("MEMwrite_format", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(&bufr2);
        *grp_bufr = NULL;
        *search_name_bufr = NULL;
 	*search_str_bufr = NULL;
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_WRITE_FORMAT);
      }

    status = MEMwrite(bufr2, "");
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(&bufr2);
        *grp_bufr = NULL;
        *search_name_bufr = NULL;
 	*search_str_bufr = NULL;
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_WRITE_BUFFER);
      }
   
    *grp_bufr = bufr2;

    status = MEMopen(&bufr3, 512);
    _pdm_status("MEMopen", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(&bufr3);
        *search_name_bufr = NULL;
        *search_str_bufr = NULL;
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_OPEN_BUFFER);
      }

    status = MEMwrite_format(bufr3, "search_name", "char(40)");
    _pdm_status("MEMwrite_format", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(&bufr3);
        *search_name_bufr = NULL;
        *search_str_bufr = NULL;
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_WRITE_FORMAT);
      }

    status = MEMwrite(bufr3, "");
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(&bufr3);
        *search_name_bufr = NULL;
        *search_str_bufr = NULL;
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_WRITE_BUFFER);
      }

    *search_name_bufr = bufr3;

    status = MEMopen(&bufr4, 512);
    _pdm_status("MEMopen", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(search_name_bufr);
        MEMclose(&bufr4);
        *search_str_bufr = NULL;
 	*sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_OPEN_BUFFER);
      }

    status = MEMwrite_format(bufr4, "search_str", "char(1024)");
    _pdm_status("MEMwrite_format", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(search_name_bufr);
        MEMclose(&bufr4);
        *search_str_bufr = NULL;
 	*sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_WRITE_FORMAT);
      }

    status = MEMwrite(bufr4, "");
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(search_name_bufr);
        MEMclose(&bufr4);
        *search_str_bufr = NULL;
 	*sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_WRITE_BUFFER);
      }

    *search_str_bufr = bufr4;

    status = MEMopen(&bufr5, 512);
    _pdm_status("MEMopen", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(search_name_bufr);
        MEMclose(search_str_bufr);
        MEMclose(&bufr5);
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_OPEN_BUFFER);
      }

    status = MEMwrite_format(bufr5, "sort_name", "char(40)");
    _pdm_status("MEMwrite_format", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(search_name_bufr);
        MEMclose(search_str_bufr);
        MEMclose(&bufr5);
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_WRITE_FORMAT);
      }

    status = MEMwrite(bufr5, "");
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(search_name_bufr);
        MEMclose(search_str_bufr);
        MEMclose(&bufr5);
        *sort_name_bufr = NULL;
        *sort_str_bufr = NULL;
        return(PDM_E_WRITE_BUFFER);
      }

    *sort_name_bufr = bufr5;

    status = MEMopen(&bufr6, 512);
    _pdm_status("MEMopen", status);

     if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(search_name_bufr);
        MEMclose(search_str_bufr);
        MEMclose(sort_name_bufr);
        MEMclose(&bufr6);
        *sort_str_bufr = NULL;
        return(PDM_E_OPEN_BUFFER);
      }

   status = MEMwrite_format(bufr6, "sort_str", "char(1024)");
    _pdm_status("MEMwrite_format", status);

    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(search_name_bufr);
        MEMclose(search_str_bufr);
        MEMclose(sort_name_bufr);
        MEMclose(&bufr6);
        *sort_str_bufr = bufr6;
        return(PDM_E_WRITE_FORMAT);
      }

    status = MEMwrite(bufr6, "");
    _pdm_status("MEMwrite", status);
    if (status != MEM_S_SUCCESS)
      {
 	MEMclose(tbl_bufr);
        MEMclose(grp_bufr);
        MEMclose(search_name_bufr);
        MEMclose(search_str_bufr);
        MEMclose(sort_name_bufr);
        MEMclose(&bufr6);
        *sort_str_bufr = NULL;
        return(PDM_E_WRITE_BUFFER);
      }
     
    *sort_str_bufr = bufr6;

    return(PDM_S_SUCCESS);
  }
