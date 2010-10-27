/* $Id: VDfld.c,v 1.1 2001/02/08 15:19:10 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdahVDfld.I
 *
 * Description: VDfld Processing Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDfld.c,v $
 *      Revision 1.1  2001/02/08 15:19:10  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/01/11 16:34:31  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/06/29  18:17:58  pinnacle
# ct
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/07  14:04:48  pinnacle
# ah
#
# Revision 1.1  1998/03/29  13:50:40  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/25/98  ah      Creation
 *
 ***************************************************************************/


#include "VDtypedefc.h"
#include "VDfld.h"

/* ---------------------------------------------
 * Map Type to Short Text String
 */
IGRstat VDfldGetTypeText(TVDfld *fld, IGRlong a_type, IGRchar *txt)
{
  IGRstat retFlag = 0;
  IGRlong type;

  // Arg check
  if (txt == NULL) goto wrapup;
  if (fld) type = fld->type;
  else     type = a_type;

  retFlag = 1;

  switch(type) {
  case VDFLD_TYPE_NONE:     strcpy(txt,"NON"); break;
  case VDFLD_TYPE_TXT:      strcpy(txt,"TXT"); break;
  case VDFLD_TYPE_NUMERIC:  strcpy(txt,"NUM"); break;
  case VDFLD_TYPE_DECIMAL:  strcpy(txt,"DEC"); break;
  case VDFLD_TYPE_INT:      strcpy(txt,"INT"); break;
  case VDFLD_TYPE_SMALLINT: strcpy(txt,"SNT"); break;
  case VDFLD_TYPE_REAL:     strcpy(txt,"REA"); break;
  case VDFLD_TYPE_DBL:      strcpy(txt,"DBL"); break;
  case VDFLD_TYPE_DATE:     strcpy(txt,"DAT"); break;

  default: 
    strcpy(txt,"UNK");
    retFlag = 0;
  }
  
wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Convert to RS
 */
IGRstat VDrsToRS(Tret_struct *rs,
                 TVDfld      *fld
                )
{
  IGRstat retFlag = 0;

  // Areg check, assume cleared
  if (rs == NULL) goto wrapup;

  // A fld
  if (fld) {

    switch(fld->type) {

    case VDFLD_TYPE_CHAR:
      rs->type = text_type;
      strcpy(rs->var.text_st.text_string,fld->val.txt);
      break;

    case VDFLD_TYPE_DOUBLE:
      rs->type = double_type;
      rs->var.root_pm_st.value = fld->val.dbl;
      break;

    case VDFLD_TYPE_INT:
      rs->type = double_type;
      rs->var.root_pm_st.value = (IGRdouble)fld->val.jnt;
      break;

    default:
      goto wrapup;

    }
    retFlag = 1;
    goto wrapup;

  }

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Convert from various formats
 */
IGRstat VDfldSetFrom(IGRchar *ris,
                     TVDfld  *fld
                    )
{
  IGRstat retFlag = 0;

  // Arg check
  if (fld == NULL) goto wrapup;

  // Special from ris data buffer
  if (ris) {

    // fld already contains data type information
    switch(fld->type) {

    case VDFLD_TYPE_CHAR:
      strcpy(fld->val.txt,ris);
      break;

    case VDFLD_TYPE_SMALLINT:
    case VDFLD_TYPE_INT:
      fld->val.jnt = atoi(ris);
      break;

    case VDFLD_TYPE_REAL:
    case VDFLD_TYPE_DOUBLE:
      fld->val.dbl = atof(ris);
      break;

    default:
      printf("Unknown field type when getting data from table: '%s'\n",ris);
      strcpy(fld->val.txt,ris);
      goto wrapup;
    }
    retFlag = 1;
    goto wrapup;
  }

  // Unknown, should we clear??

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Generic print routine
 */
IGRstat VDfldPrint(TVDfld   *fld,
		   TVDflds  *flds,
		   IGRchar  *hdr)
{
  IGRstat retFlag;
  IGRint  i;
  IGRchar desc[1024];
  
  // Optional header
  if (hdr) printf("%s\n",hdr);
 
  // Get the data
  if (fld) {
    *desc = 0;
    VDfldGetFldDesc(fld,desc);
    printf("%s\n",desc);
  }
 
  if (flds) {
    for(i = 0; i < flds->cnt; i++) {
      *desc = 0;
      VDfldGetFldDesc(&flds->fld[i],desc);
      printf("%2d %s\n",i,desc);
    }
  }
  
  retFlag = 1;
  
  return retFlag;
}

/* ----------------------------------------------
 * Generic set routine
 * Tried to make it crash proof but not a whole lot
 * of other error checking beside that
 * Pretty much up to the user to init correctly
 */
IGRstat VDfldSet(TVDfld   *fld,
		 TVDflds  *flds,
		 IGRchar  *name,
		 IGRint    type,
		 IGRint    flag,
		 IGRchar  *txt,
		 IGRint    jnt,
		 IGRdouble dbl)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  TVDfld *fldx = NULL;
  
  // First find which field to set
  if  (fld  != NULL) fldx = fld;
  if ((flds != NULL) && (name != NULL)) {
      
    for(i = 0; (i < flds->cnt) && (strcmp(flds->fld[i].name,name)); i++);
    if (i < flds->cnt) fldx = &flds->fld[i];
  }
  if (fldx == NULL) goto wrapup;
  
  // Set the flag
  if (flag != -1) fldx->flag = flag;

  // Set the name
  if (name != NULL) strcpy(fldx->name,name);
  
  // Set the type
  fldx->type = type;
  
  // set the value
  switch(type) {
  case VDFLD_TYPE_TXT: 
    if (txt) strcpy(fldx->val.txt,txt);
    else     *fldx->val.txt = 0;
    break;
    
  case VDFLD_TYPE_REAL:
  case VDFLD_TYPE_DOUBLE:
    fldx->val.dbl = dbl;
    break;
    
  case VDFLD_TYPE_SMALLINT:
  case VDFLD_TYPE_INT:
    fldx->val.jnt = jnt;
    break;
    
  default:
    printf("Unsupported data type in VDfldSet, %d\n",type);
    goto wrapup;
  }
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Generic get routine
 * Tried to make it crash proof but not a whole lot
 * of other error checking beside that
 * Pretty much up to the user to init correctly
 */
IGRstat VDfldGet(TVDfld    *fld,
		 TVDflds   *flds,
		 IGRchar   *name,
		 IGRchar   *nameo,
		 IGRint    *type,
		 IGRint    *flag,
		 IGRchar   *txt,
		 IGRint    *jnt,
		 IGRdouble *dbl,
		 IGRchar   *desc,
		 TVDfld   **fldo)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  TVDfld *fldx = NULL;

  IGRchar typeText[16];
  
  // Init
  if (type) *type = 0;
  if (flag) *flag = 0;
  
  if (txt)  *txt  = 0;
  if (dbl)  *dbl  = 0.0;
  if (jnt)  *jnt  = 0;

  if (desc) *desc = 0;
  if (fldo) *fldo = NULL;
  
  if (nameo) *nameo = 0;
  
  // First find which field to get
  if  (fld  != NULL) fldx = fld;
  if ((flds != NULL) && (name != NULL)) {
      
    for(i = 0; (i < flds->cnt) && (strcmp(flds->fld[i].name,name)); i++);
    if (i < flds->cnt) fldx = &flds->fld[i];
  }
  if (fldx == NULL) goto wrapup;
  
  // Return the field of intrest
  if (fldo) *fldo = fldx;
  
  // Set the name
  if (nameo) strcpy(nameo,fldx->name);

  // Get the flag
  if (flag) *flag = fldx->flag;
  
  // Get the type
  if (type) *type = fldx->type;
  
  VDfldGetTypeText(fldx,VDFLD_TYPE_NONE,typeText);
  
  // set the value
  switch(fldx->type) {

  case VDFLD_TYPE_TXT: 
  case VDFLD_TYPE_DATE:
    if (txt)  strcpy(txt,fldx->val.txt);
    if (desc) sprintf(desc,"%s %s = %s ",typeText,fldx->name,fldx->val.txt);
    break;
    
  case VDFLD_TYPE_REAL:
  case VDFLD_TYPE_DOUBLE:
    if (dbl) *dbl = fldx->val.dbl;
    if (desc) sprintf(desc,"%s %s = %f ",typeText,fldx->name,fldx->val.dbl);
    break;
    
  case VDFLD_TYPE_SMALLINT:
  case VDFLD_TYPE_INT:
    if (jnt) *jnt = fldx->val.jnt;
    if (desc) sprintf(desc,"%s %s = %d ",typeText,fldx->name,fldx->val.jnt);
    break;
    
  default:
    printf("Unsupported data type in VDfldGet, %d %s\n",type,typeText);
    goto wrapup;
  }
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}
