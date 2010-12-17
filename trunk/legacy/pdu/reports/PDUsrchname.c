#include	<stdio.h>
#include	"PDUerror.h"
#include	"PDUstr.h"
#include	"PDUproto.h"

int PDUget_cat_search_names(count,search_names,stat_msg)
  int				*count;
  char				***search_names;
  char				*stat_msg;
  {
  int				status=PDM_S_SUCCESS;
  char				**cat_searchs;
  int				cat_count;
  
  _pdm_debug("In the get search names function",0);
  
  *search_names = NULL;
  
  /* get the list of search criteria names */
  status = PDUlist_reports(CAT_SEARCH_LIST, &cat_searchs, &cat_count);
  _pdm_status("PDUlist_reports", status);

  if ( status != PDM_S_SUCCESS) 
    {
     strcpy(stat_msg,"PDM Internal:PDUlist_reports");
     return(PDM_E_FAILURE);
    }

  *search_names = cat_searchs;
  *count = cat_count;

  if (*count == 0)
    {
      status = PDM_I_SEARCH_NAME_NOT_FOUND;
      strcpy(stat_msg, "No Search Criterias exists");
    }
  return( status );
  }

int PDUget_loc_search_names(count,search_names,stat_msg)
  int				*count;
  char				***search_names;
  char				*stat_msg;
  {
  int				status=PDM_S_SUCCESS;
  char				**loc_searchs;
  int				loc_count;
  
  _pdm_debug("In the get search names function",0);
  
  *search_names = NULL;
  
  /* get the list of search criteria names */
  status = PDUlist_reports(LOC_SEARCH_LIST, &loc_searchs, &loc_count);
  _pdm_status("PDUlist_reports", status);

  if ( status != PDM_S_SUCCESS) 
    {
     strcpy(stat_msg,"PDM Internal:PDUlist_reports");
     return(PDM_E_FAILURE);
    }

  *search_names = loc_searchs;
  *count = loc_count;

  if (*count == 0)
    {
      status = PDM_I_SEARCH_NAME_NOT_FOUND;
      strcpy(stat_msg, "No Search Criterias exists");
    }

  return( status );
  }

int PDUget_search_criteria_names(count,search_crit_names,stat_msg)
  int				*count;
  char				***search_crit_names;
  char				*stat_msg;
  {
  int				status=PDM_S_SUCCESS;
  char 				**names;
  
  _pdm_debug("In the get search criteria names function",0);
  _pdm_debug("stat_msg = <%s>", stat_msg); 
  names = (char **) malloc ( 2 * sizeof(char *));
  memset(names, NULL, ( 2 * sizeof (char *)));
  
  PDUfill_in_string( &names[0], "INACTIVE");
  PDUfill_in_string( &names[1], "ACTIVE");

  *search_crit_names = names;  
  *count = 2;

  return( status );
  }


