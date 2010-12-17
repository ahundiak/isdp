#include <stdio.h>
#include "FI.h"
#include <tools.h>
#include "MRPstr.h"
#include "rMRPstr.h"
#include "MRPmacros.h"
#include "MRPmessage.h"
#include "PDUstr.h"
#include "PDUproto.h"
#include "MRPintdef.h"



extern struct rMRPvar  *rmrpvar;
extern struct PSUrpt   *psurpt;
extern int part_total;
extern int PSU_list_total;
extern int PSU_attr_total;
extern int PSUmessage;
extern int MRPlevel;
extern int MRPchange;
extern int MRPscroll_col;
extern int PSUjustification;
extern int current_form_num;
extern int ps_current_form_num;
extern FILE 	*rMRPdbg_fileptr;
extern int	MRP_debug_on;
extern int RPT_list_position;
extern char PSUdef_file[80];
extern char PSUdirectory[80];
extern char PSUworkflow[20];
extern char PSUsaname[14];
extern char PSUpart_acl[20];
extern char PSUems_file[80];
extern char *PSUtemplib;
extern long PSUcommand;
extern Form current_form_id;
extern Form ps_current_form_id;
extern Form psu_master_id;


int rMRPalloc_var ()
{

  /* allocate mrpvar if none exists */
if ( rmrpvar == NULL )
     {
/*     _mrp_debug_mes("malloc for rmrpvar"); */
     rmrpvar = (struct rMRPvar *) malloc( sizeof(struct rMRPvar) );
/*     if ( rmrpvar == NULL)
        _pdm_debug("Could not malloc rmrpvar",0); */
     }
   if ( rmrpvar )
     {
      rmrpvar->struct_list = NULL;
      rmrpvar->index_slot = NULL;
      rmrpvar->cit_lev_val_struct = NULL;
      rmrpvar->rmrparg = NULL;
     }

    /* set defaults */
    strcpy(PSUworkflow, "PDM_PART_WORKFLOW");
    strcpy(PSUsaname, "NFMFILES");
    strcpy(PSUpart_acl, "PDM_PART_ACL");
    strcpy(PSUems_file, "./design.dgn");

return( MRP_S_Success );
}

int PDUalloc_rpt (pdurpt)
struct PSUrpt   **pdurpt;
{
PSUtemplib=NULL;

  /* allocate mrpvar if none exists */
if ( *pdurpt == NULL )
     {
     *pdurpt = (struct PSUrpt *) malloc( sizeof(struct PSUrpt) );
     if ( *pdurpt == NULL)
printf("Could not malloc psurpt\n");
     }
if ( *pdurpt )
 {
   strcpy(((*pdurpt)->options).table, "");
   strcpy(((*pdurpt)->options).template_name, "");
   strcpy(((*pdurpt)->options).description, "");
   strcpy(((*pdurpt)->options).output, "");
   strcpy(((*pdurpt)->options).title, "");
   strcpy((*pdurpt)->templatetype, "");
   (*pdurpt)->options.subtotals = 0;
   (*pdurpt)->options.totals = 0;
   (*pdurpt)->options.width = 80;
   (*pdurpt)->options.lines = 60;
   (*pdurpt)->list = NULL;
   (*pdurpt)->justification = NULL;
   (*pdurpt)->list_total = 0;
   (*pdurpt)->where = NULL;
   (*pdurpt)->templib = NULL;
 }
return( MRP_S_Success );
}

int PSUalloc_rpt()
{
PSUtemplib=NULL;

  /* allocate mrpvar if none exists */
if ( psurpt == NULL )
     {
     psurpt = (struct PSUrpt *) malloc( sizeof(struct PSUrpt) );
     if ( psurpt == NULL)
printf("Could not malloc psurpt\n");
     }
if ( psurpt )
 {
   strcpy(psurpt->options.table, "");
   strcpy(psurpt->options.template_name, "");
   strcpy(psurpt->options.description, "");
   strcpy(psurpt->options.output, "");
   strcpy(psurpt->options.title, "");
   strcpy(psurpt->templatetype, "");
   psurpt->options.subtotals = 0;
   psurpt->options.totals = 0;
   psurpt->options.width = 80;
   psurpt->options.lines = 60;
   psurpt->list = NULL;
   psurpt->justification = NULL;
   psurpt->list_total = 0;
   psurpt->where = NULL;
   psurpt->templib = NULL;
 }
return( MRP_S_Success );
}

