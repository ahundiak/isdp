/* $Id: PDUvd_refresh.c,v 1.4 2002/05/10 13:33:05 jdsauby Exp $ */
/* -------------------------------------------------------------------
 * I/VDS
 *
 * File: vds/emsfixes/pdu/PDUvd_refresh.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *       $Log: PDUvd_refresh.c,v $
 *       Revision 1.4  2002/05/10 13:33:05  jdsauby
 *       PDM sub form for selecting a revision was popping up, causing PDM to hang up.  Fixed by just entering catalog, which satisfies the original requirements.  JDS 05/10/2002.
 *
 *       Revision 1.3  2002/05/06 14:56:42  jdsauby
 *       Continuation of TR6317.  The fix caused the revision subform to undesirably pop up.  JDS
 *
 *       Revision 1.2  2002/04/30 18:23:48  jdsauby
 *       JTS MPTR 6317.
 *
 *       Revision 1.1  2002/01/07 18:29:57  jdsauby
 *       JTSMP CR 4008
 *
 *
 * History:
 *       MM/DD/YY        AUTHOR          DESCRIPTION
 *       12/13/01	 js		 creation
 * -------------------------------------------------------------------------*/

#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDassert.h"
#include "part_gadgets.h"
#include "PDUstr.h"


VDASSERT_FFN("emsfixes/pdu/PDUvd_refresh.c");

extern struct PDUrefresh *refresh;
extern PDUfill_in_string();

/* --------------------------------------------
 * write the cat, part, rev ... data to the refresh file
 * **/
static void writeVDrefreshDataFile(IGRchar *cat,
	                           IGRchar *part,
				   IGRchar *rev,
				   IGRchar *pfile,
				   IGRchar *desc)
{
    VDASSERT_FN("writeVDrefreshDataFile");

    FILE *file = NULL;
    IGRchar fbuf[1024];

    VDASSERTW(cat && *cat != 0);

    // open the file, it will always be in the local directory
    file = fopen("./.vdrefresh.dat","w");
    if (file == NULL) goto wrapup;

    // set up fbuf for writing
    // catalog
    strcpy(fbuf,cat);

    // part
    if (part && *part != 0) {
	strcat(fbuf,"|");
	strcat(fbuf,part);
    }
    // rev
    if (rev && *rev != 0) {
	strcat(fbuf,"|");
	strcat(fbuf,rev);
    }
    // pfile
    if (pfile && *pfile != 0) {
	strcat(fbuf,"|");
	strcat(fbuf,pfile);
    }
    // desc
    if (desc && *desc != 0) {
	strcat(fbuf,"|");
	strcat(fbuf,desc);
    }

    // write the file
    fprintf(file,"%s|\n",fbuf);

    // done
wrapup:
    if (file) fclose(file);
    return;
}

/* --------------------------------------------
 * open/process .vdrefresh.dat file and store cat,part,etc... info
 * **/
static IGRstat getVDrefreshDataFromFile(IGRchar *cat,
	                                IGRchar *part,
					IGRchar *rev,
					IGRchar *pfile,
					IGRchar *desc)
{
    VDASSERT_FN("getVDrefreshDataFromFile");

    IGRstat retFlag = 0;
    FILE   *file = NULL;
    IGRchar fbuf[1024];
    IGRchar *p;
    IGRchar buf[1024];

    VDASSERTW(cat);
    VDASSERTW(part);
    VDASSERTW(rev);
    VDASSERTW(pfile);
    VDASSERTW(desc);

    // open the file
    file = fopen("./.vdrefresh.dat","r");
    if (file == NULL) goto wrapup;

    // get the data from the file
    *fbuf = 0;
    fgets(fbuf,sizeof(fbuf),file);
    if (*fbuf == 0) goto wrapup;

    // process to get info
    // catalog
    p = strchr(fbuf,'|');
    if (p) {
	*p = 0;
	strcpy(cat,fbuf);
	strcpy(fbuf,p+1);
    }
    else goto wrapup;
    retFlag = 1;
    // part
    p = strchr(fbuf,'|');
    if (p) {
	*p = 0;
	strcpy(part,fbuf);
	strcpy(fbuf,p+1);
    }
    else goto wrapup;
    // rev
    p = strchr(fbuf,'|');
    if (p) {
	*p = 0;
	strcpy(rev,fbuf);
	strcpy(fbuf,p+1);
    }
    else goto wrapup;
    // pfile
    p = strchr(fbuf,'|');
    if (p) {
	*p = 0;
	strcpy(pfile,fbuf);
	strcpy(fbuf,p+1);
    }
    else goto wrapup;
    // desc
    p = strchr(fbuf,'|');
    if (p) {
	*p = 0;
	strcpy(desc,fbuf);
	strcpy(fbuf,p+1);
    }
    else goto wrapup;

    // done
    
wrapup:
    if (file) fclose(file);
    return retFlag;
}

/* --------------------------------------------
 * Create the .vdrefresh.dat file with data from form
 * **/
void PDUvd_SetLFVDrefreshData(Form lf_form)
{
    VDASSERT_FN("PDUvd_SetLFVDrefreshData");

    IGRchar cat[80],part[80],rev[80],file[80],desc[240];

    VDASSERTW(lf_form);

    // init
    *cat   = 0;
    *part  = 0;
    *rev   = 0;
    *file  = 0;
    *desc  = 0;
    
    // get the data
    VDfrmGetgText(lf_form,CATALOG_FLD,cat);
    if (*cat == 0 || !strcmp(cat,"")) goto wrapup;

    

    VDfrmGetgText(lf_form,PARTNUM_FLD,part);
    VDfrmGetgText(lf_form,PART_REV_FLD,rev);
    VDfrmGetgText(lf_form,PART_FILE_FLD,file);
    VDfrmGetgText(lf_form,PART_DESC_FLD,desc);

    // write the file
    writeVDrefreshDataFile(cat,part,rev,file,desc);

    // done

wrapup:
    return;
}

/* --------------------------------------------
 * GEt the .vdrefresh.dat file and set data on form
 * **/
void PDUvd_GetLFVDrefreshData(Form lf_form)
{
    VDASSERT_FN("PDUvd_GetLFVDrefreshData");

    IGRstat sts;
    IGRchar cat[80],part[80],rev[80],file[80],desc[240];

    VDASSERTW(lf_form);

    // init
    *cat   = 0;
    *part  = 0;
    *rev   = 0;
    *file  = 0;
    *desc  = 0;

    // get the data
    sts = getVDrefreshDataFromFile(cat,part,rev,file,desc);
    if (!(sts & 1)) goto wrapup;

    if (*cat != 0) {
	VDfrmSetgText(lf_form,CATALOG_FLD,cat);
	PDUep_cat_fld();
    }

    /************************************************************
     * PDUep_cat_fld() broadcasts to PDM that a catalog has been entered.
     * Adding the part, rev, and etc.. info onto the form as below, causes
     * problems.  It brings up the select revision sub form, which will
     * eventually hang up the system.  For now, just putting the catalog
     * into the form will satisfy the requirements.  JDS 05/10/2002
     * *************/
#if 0
    // if the catalog broadcast did not work, then don't populate the rest.
    // determine be getting the catalog info again.
    VDfrmGetgText(lf_form,CATALOG_FLD,cat);
    if (*cat == 0 || !strcmp(cat,"")) goto wrapup;

    if (*part != 0) {
	VDfrmSetgText(lf_form,PARTNUM_FLD,part);
        //PDUep_part_fld();
    }
    if (*rev != 0) {
	VDfrmSetgText(lf_form,PART_REV_FLD,rev);
        //PDUep_rev_fld();
    }
    if (*file != 0) VDfrmSetgText(lf_form,PART_FILE_FLD,file);
    if (*desc != 0) VDfrmSetgText(lf_form,PART_DESC_FLD,desc);

    if( *cat!= 0 && *part!= 0 && *rev!= 0)
    {
	PDMInfoOnCommandbar(cat, part, rev);

    }
#endif
    // done

wrapup:
    return;
}

