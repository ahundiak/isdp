#include	<stdio.h>
#include	"PDUstr.h"
#include	"PDUerror.h"
#include	"PDUextdef.h"
#include	"PDUproto.h"

int PDUget_loc_sort_names(count,sort_names,stat_msg)
  int				*count;
  char				***sort_names;
  char				*stat_msg;
  {
  int				status=PDM_S_SUCCESS;
  char				**loc_sorts;
  int				loc_count;
  
  _pdm_debug("In the get loc sort names function",0);
  
  *sort_names = NULL;
    
  status = PDUlist_reports(LOC_SORT_LIST, &loc_sorts, &loc_count);
  _pdm_status("PDUlist_reports", status);

  if ( status != PDM_S_SUCCESS) 
    {
      strcpy(stat_msg,"PDM Internal:PDUlist_reports");
      return(PDM_E_FAILURE);
    }

  *sort_names = loc_sorts;
  *count = loc_count;

  if (*count == 0)
    {
      strcpy(stat_msg, "No Sort Criterias exist");
      status = PDM_E_SORT_CRIT_NOT_FOUND;
    }
  return( status );
  }
 
int PDUget_cat_sort_names(count,sort_names,stat_msg)
  int				*count;
  char				***sort_names;
  char				*stat_msg;
  {
  int				status=PDM_S_SUCCESS;
  char				**cat_sorts;  
  int				cat_count;
  
  _pdm_debug("In the get cat sort names function",0);
  
  *sort_names = NULL;

  status = PDUlist_reports(CAT_SORT_LIST, &cat_sorts, &cat_count);
  _pdm_status("PDUlist_reports", status);

  if ( status != PDM_S_SUCCESS) 
    {
      strcpy(stat_msg,"PDM Internal:PDUlist_reports");
      return(PDM_E_FAILURE);
    }

  *sort_names = cat_sorts;
  *count = cat_count;
  if (*count == 0)
    {
      strcpy(stat_msg, "No Sort Criterias exist");
      status = PDM_E_SORT_CRIT_NOT_FOUND;
    }
  	
  return( status );
  }


