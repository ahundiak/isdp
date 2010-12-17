/* ALR  7/23/93 This functions is a dummy stub for PDUcleanup_local_filemgr. */

#include <stdio.h>
#include <PDUerror.h>
#include <PDUsts_st.h>
#include <MEMstruct.h>

int PDUcleanup_local_filemgr()
{
 return(PDM_S_SUCCESS);
}
/* This is an exnuc function that displays messages on the message strip.
    This will not be used in API's.
*/
void UI_status()
{
}

/*  These MRP functions are stubbed out because they will never be
     needed in the API.

*/
void MRPget_time()
{
}

void MRPget_date()
{
}

/*
void MRPstrcpy()
{
}
*/

/*
void PSUexe_rpt()
{
}
*/

struct MRPvar *mrpvar;

PDUsts_ptr PDUsts;

void MS_init()
{
}

void MS_out_msg()
{
}

void MSmessage()
{
}

void MS_fix_type()
{
}

char *PDUtranslate_message(int i)
{
  static char *string = "";
  return(string);
}

char *PDUtranslate_message_and_vars(int i)
{
  static char *string = "";
  return(string);
}

void EXPlocate                       () {}
void warn_box                       () {}
/*
CID_yyparse                   
to_lower                     
*/
char *s_text = NULL;
#if defined (clipper)
char CID_yytext[200];
#endif
void RISquery                    () {}
void GetOriginalMacroInfo  () {}
void from_cat_to_work_units() {}
void GetDyncolIndx        () {}
void add_attribute       () {}
void ReadAtrsFromCols   () {}
/*
void SVSGetTablesAndColumnsInView () {}
void SVSFreeTablesAndColumns     () {}
void RIS_box () {}
void FreeArrayPtr               () {}
*/
void CheckACrgAttribVal () {}
void pull_main           () {}
void FlashMessage       () {}
void no_of_param_vals             () {}
void MacroDisplayed             () {}
void ModifyPartForm            () {}
void place_part_f             () {}
void PDU_cat_selected        () {}
void PDU_comm_attribs       () {}
void PDM_old_dir           () {}
void init_selprt          () {}
void UI_prompt () {}
void UI_error () {}
void PDUget_keyin () {}
void Help_toc () {}
void Help_active () {}
void Help_topic () {}
void Help_kill () {}
void Help_document () {}
void IGEresetstop () {}
void IGEstop () {}
void GetAttribindx () {}
void NFT_add_file () {}
void NFT_init () {}
void NFT_start_group () {}
void NFT_ftr_search () {}
void NFT_get_keywords () {}
void NFT_delete_item () {}
void NFT_index () {}
void NFT_delete_entry () {}
void FTR_enter () {}
void whence () {}
