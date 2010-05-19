/* $Id: VDloftbk.I,v 1.10 2002/01/26 02:05:32 ylong Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdloft/func/VDloftbk.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDloftbk.I,v $
 *      Revision 1.10  2002/01/26 02:05:32  ylong
 *      *** empty log message ***
 *
 *      Revision 1.9  2002/01/14 21:47:03  ylong
 *      *** empty log message ***
 *
 *      Revision 1.8  2002/01/14 16:23:09  ylong
 *      *** empty log message ***
 *
 *      Revision 1.7  2002/01/09 22:14:58  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/12/21 19:55:27  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/12/18 17:35:54  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/01/29 16:03:44  ad
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/01/26 22:54:41  ad
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/23 16:13:15  ad
 *      *** empty log message ***
 *
# Revision 1.3  2000/12/05  19:59:50  pinnacle
# ylong
#
# Revision 1.2  2000/12/01  15:08:42  pinnacle
# ylong
#
# Revision 1.1  2000/11/01  19:44:30  pinnacle
# ylong
#
 *
 * History:
 * MM/DD/YY	AUTHOR		DESCRIPTION
 * 10/30/00	ylong		CR179900929
 * 01/29/01	ylong		TR4522
 * -------------------------------------------------------------------*/

class implementation Root;

/*
#define  vdsDEBUG
#define  DEBUG
*/
#include <time.h>
#include <ctype.h>
#include "VDmaster.h"
#include "VDobj.h"
#include "vdAPImacros.h"
#include "VDgeom.h"
#include "vdrefmacros.h"
#include "grwireframe.h"
#include "grmacros.h"
#include "VDloftbk.h"
#include "VDxdom.h"
#include "VDctx.h"

extern	OPP_GRcurve_class_id;
extern	OPP_GRcompcurve_class_id;
extern	OPP_AScompcurve_class_id;
extern	OPP_VDsupGen_class_id;

from	GRvg		import	GRdetplane, GRgetgeom;
from	SMfrm_syst	import	SMfind_all_frame, SMfind_frame_objid;
from	SMframe		import	SMgive_rel_position;


#define VDloftbk_COL_NUM	12
#define VDloftbk_COL_NUM3	8
#define VDloftbk_DATA_LEN	10
#define	DATA_START		8

%safe
static IGRint	LOFTBK_SAVED = 0 ;

static	int	FormatCnt = 5;
static	char	*FormatList[40] = {	"1. WaterLine Half Breadths",
					"2. Control Lines",
					"3. Decks and Platforms",
					"4. Longitudinals",
					"5. Buttock Heights" };
static char	*DEFAULT_TITLE		= "",
		*DEFAULT_FORMAT		= "1. WaterLine Half Breadths",
		*DEFAULT_PREFIX		= "",
		*DEFAULT_OUTPUTFILE	= "output.txt",
		*DEFAULT_STARTP		= "1",
		*DEFAULT_ROWCNT		= "50",
		*DEFAULT_JOBNO		= "C6-017",
		*DEFAULT_DWGNO		= "05-00-03",
		*DEFAULT_REVISION	= "A",
		*DEFAULT_CLASSNO	= "839-7318299",
		*DEFAULT_CLASSSTR	= "LPD 17",
		*DEFAULT_CAGE		= "53711",
		*DEFAULT_CAGESIZE	= "B",
		*DEFAULT_FRMFORMAT	= "Number";
%endsafe

static char	TITLE[80],
		FORMAT[80],
		PREFIX[80],
		OUTPUTFILE[80],
		STARTP[80],
		ROWCNT[80],
		JOBNO[80],
		DWGNO[80],
		REVISION[80],
		CLASSNO[80],
		CLASSSTR[80],
		CAGE[80],
		CAGESIZE[80],
		FRMFORMAT[80];

/*-----------------------------------------------------------------
 * 
 */
IGRlong VDloftbk_setFormGadgetByXml( Form form, TGRid *gadgetID )
{
	IGRstat		sts;
	IGRlong		retFlag = 0;
	IGRint		i, cnt = 0;
	IGRint		gadget,fmt = 0;
	IGRchab		buf, name, type;
	TGRid		listID;
	
	if( !form || !gadgetID || gadgetID->objid == NULL_OBJID ) goto wrapup;

	/* get gadget number */
	sts = VDctxGetTxtAtr( gadgetID, "vgadget", buf );
	if( !(sts&1) ) goto wrapup;
	gadget = atoi( buf );

	/* get gadget type */
	sts = VDctxGetTxtAtr( gadgetID, "type", type );
	if( !(sts&1) ) goto wrapup;
	
	/* set gadget associative list */
	if( strcasecmp( type, "SINGLE" ) ) {
		VDctxGetChildNodeByType( gadgetID, "LIST", &listID );
		if( listID.objid == NULL_OBJID ) goto wrapup;
	
		cnt = 1;
		sprintf( name, "value%d", cnt );
		while(VDctxGetTxtAtr(&listID, name, buf) ) {
			sprintf( name, "value%d", ++cnt );
		}
		cnt--;

		if( !strcasecmp( type, "PDOWN_LIST" ) ) {
			FIfld_set_list_num_rows(form, gadget, 0, cnt);
		}
		else	FIfld_set_num_rows(form, gadget, 0, cnt);

		for( i = 0; i < cnt; i++ ) {
			sprintf( name, "value%d", i+1 );
			VDctxGetTxtAtr(&listID, name, buf);
			if( !strcasecmp( type, "PDOWN_LIST" ) ) {
			  FIfld_set_list_text(form, gadget, i, 0, buf, FALSE);
			}
			else FIfld_set_text(form, gadget, i, 0, buf, FALSE);
		}
	}

	/* set gadget value */
	VDctxGetTxtAtr( gadgetID, "value", buf );
	if(!strcasecmp(type, "ROLL_LIST") ) {
		if( !strcasecmp(buf, "Distance")) fmt = 1;
		FIfld_set_active_row(form, gadget, fmt, 0);
	}
	else {
		FIg_set_text( form, gadget, buf );
	}

	retFlag = 1 ;
wrapup:
	return retFlag;
}

/*-----------------------------------------------------------------
 * 
 */
IGRint VDloftbk_setFormByXml( Form form )
{
	IGRint		retFlag = 0, i;
	IGRlong		sts, msg;
	TGRid		xmlID, formID;
	IGRchar		xmlPath[MAXPATHLEN],
			*xmlFile = "loftbkForm.xml";
	IGRchab		valueBuf, gadgetBuf, type;
	IGRint		gadget;
	TVDctxNodeList	gList;
	
	VDctxInitNodeList(&gList);

	if( !form ) goto wrapup;

	xmlPath[0] = '\0';
	sts = vd$file_path( msg				= &msg,
			fileToFind			= xmlFile,
			dirToSearchFirst		= ".",
			dirInProdPathToSearchThen	= "config/xml",
			absPathName			= xmlPath );
	if( !(sts&msg&1) || xmlPath[0] == '\0' ) {
		sts = vd$file_path(
				msg                       = &msg,
				fileToFind                = xmlFile,
				dirToSearchFirst          = ".",
				dirInProdPathToSearchThen = "sample_config/xml",
				absPathName               = xmlPath );
		if( !(sts&msg&1) || xmlPath[0] == '\0' ) goto wrapup;
	}

	VDxdomCreateTreeFromXmlFile( xmlPath, &xmlID );
	if( xmlID.objid == NULL_OBJID ) goto wrapup;

	i = 0;
	sts = VDctxGetNthTreeChild( &xmlID, i, &formID );
	if( !(sts&1) || formID.objid == NULL_OBJID ) goto wrapup;

	/*
	 * set form title
	 */
	VDctxGetTxtAtr( &xmlID, "form_title", valueBuf );
	VDctxGetTxtAtr( &xmlID, "lgadget",  gadgetBuf );
	gadget = atoi( gadgetBuf );
	FIg_erase( form, gadget );
	FIg_set_text( form, gadget, valueBuf );
	FIg_display( form, gadget );

	VDctxGetNodeListByType( &formID, "GADGET", &gList );
	if( gList.cnt == 0 ) goto wrapup;
	
	/*
	 * set gadget lables and values
	 */
	for( i = 0; i < gList.cnt; i++ ) {
		/* set list and value if applied */
		sts = VDloftbk_setFormGadgetByXml( form, &gList.listIDs[i] ) ;
		if( !sts ) goto wrapup;

		/* set gadget lable text */
		VDctxGetTxtAtr( &gList.listIDs[i], "lgadget", gadgetBuf );
		VDctxGetTxtAtr( &gList.listIDs[i], "label", valueBuf );
		gadget = atoi( gadgetBuf );
		FIg_erase( form, gadget );
		FIg_set_text( form, gadget, valueBuf );
		FIg_display( form, gadget );
	}
	
	
	retFlag = 1;
wrapup:
	if( xmlID.objid != NULL_OBJID ) VDctxDeleteNode( &xmlID );
	VDctxFreeNodeList(&gList );

	return retFlag;
}

/*-----------------------------------------------------------------
 * fill initial parameters in the form
 */
IGRlong	VDloftbk_initForm(Form form)
{
	IGRlong		retFlag = 0;
	struct tm	*timep = NULL;
	time_t		clock;
	IGRchar		str[128] ;
	IGRchar		format[20];	
	IGRint		fmt = 0;

	// Set form by xml

	retFlag = VDloftbk_setFormByXml(form) ;

	// get local time and set date into form

	clock = time((long *) 0);
	timep = localtime( &clock );

	if( (timep->tm_mon + 1) < 10 ) {
		strcpy(format, "0%d/");
	}
	else {
		strcpy(format, "%d/");
	}

	if( timep->tm_mday < 10 ) {
		strcat(format, "0%d/%d");
	}
	else {
		strcat(format, "%d/%d");
	}

	sprintf(str, format, (timep->tm_mon + 1), 
			timep->tm_mday, (timep->tm_year + 1900) );

	FIg_set_text(form, LOFTBK_DATE_FLD, str);

	if(LOFTBK_SAVED) {
		FIg_set_text(form, LOFTBK_FORMAT_FLD, FORMAT);
		FIg_set_text(form, LOFTBK_TITLE_FLD, TITLE);
		FIg_set_text(form, LOFTBK_PREFIX_FLD, PREFIX);
		FIg_set_text(form, LOFTBK_FILE_FLD, OUTPUTFILE);
		FIg_set_text(form, LOFTBK_START_FLD, STARTP);
		FIg_set_text(form, LOFTBK_NROWS_FLD, ROWCNT);
		FIg_set_text(form, LOFTBK_JOB_NO_FLD, JOBNO);
		FIg_set_text(form, LOFTBK_DWG_NO_FLD, DWGNO);
		FIg_set_text(form, LOFTBK_REV_FLD, REVISION);
		FIg_set_text(form, LOFTBK_CLASS_NO_FLD, CLASSNO);
		FIg_set_text(form, LOFTBK_CLASS_FLD, CLASSSTR);
		FIg_set_text(form, LOFTBK_CAGE_FLD, CAGE);
		FIg_set_text(form, LOFTBK_CAGE_SIZE_FLD, CAGESIZE);
		if( !strcasecmp(FRMFORMAT, "Distance") ) fmt = 1;
		FIfld_set_active_row(form, LOFTBK_FRMFORMAT_FLD, fmt, 0);
	}
	else if( !retFlag ) { // just in case VDloftbk_setFormByXml failed
		FIg_set_text(form, LOFTBK_FORMAT_FLD, DEFAULT_FORMAT);
		FIg_set_text(form, LOFTBK_TITLE_FLD, DEFAULT_TITLE);
		FIg_set_text(form, LOFTBK_PREFIX_FLD, DEFAULT_PREFIX);
		FIg_set_text(form, LOFTBK_FILE_FLD, DEFAULT_OUTPUTFILE);
		FIg_set_text(form, LOFTBK_START_FLD, DEFAULT_STARTP);
		FIg_set_text(form, LOFTBK_NROWS_FLD, DEFAULT_ROWCNT);
		FIg_set_text(form, LOFTBK_JOB_NO_FLD, DEFAULT_JOBNO);
		FIg_set_text(form, LOFTBK_DWG_NO_FLD, DEFAULT_DWGNO);
		FIg_set_text(form, LOFTBK_REV_FLD, DEFAULT_REVISION);
		FIg_set_text(form, LOFTBK_CLASS_NO_FLD, DEFAULT_CLASSNO);
		FIg_set_text(form, LOFTBK_CLASS_FLD, DEFAULT_CLASSSTR);
		FIg_set_text(form, LOFTBK_CAGE_FLD, DEFAULT_CAGE);
		FIg_set_text(form, LOFTBK_CAGE_SIZE_FLD, DEFAULT_CAGESIZE);
		if( !strcasecmp(DEFAULT_FRMFORMAT, "Distance") ) fmt = 1;
		FIfld_set_active_row(form, LOFTBK_FRMFORMAT_FLD, fmt, 0);
	}

	retFlag = 1;
wrapup:
	return retFlag;	
}


/*-------------------------------------------------------------------
 * Sorting functions
 */
IGRint	VDloftbk_sortPointsX (
TGRid	*objID1, 
TGRid	*objID2)
{
	IGRint		ret = 0;
	IGRlong		msg;
	IGRpoint	pnt1, pnt2, pt;

	gr$get_endpoints(msg            = &msg,
			object_id       = objID1,
			point1          = pnt1,
			point2          = pt);

	gr$get_endpoints(msg            = &msg,
			object_id       = objID2,
			point1          = pnt2,
			point2          = pt);

	if( pnt1[0] < pnt2[0] )		ret = -1;
	else if( pnt1[0] > pnt2[0] )	ret =  1;
	else				ret =  0;

	return ret;
}

IGRint	VDloftbk_sortPointsY (
TGRid	*objID1, 
TGRid	*objID2)
{
	IGRint		ret = 0;
	IGRlong		msg;
	IGRpoint	pnt1, pnt2, pt;

	gr$get_endpoints(msg            = &msg,
			object_id       = objID1,
			point1          = pnt1,
			point2          = pt);

	gr$get_endpoints(msg            = &msg,
			object_id       = objID2,
			point1          = pnt2,
			point2          = pt);

	if( pnt1[1] < pnt2[1] )		ret = -1;
	else if( pnt1[1] > pnt2[1] )	ret =  1;
	else				ret =  0;

	return ret;
}


IGRint	VDloftbk_sortPointsZ (
TGRid	*objID1, 
TGRid	*objID2)
{
	IGRint		ret = 0;
	IGRlong		msg;
	IGRpoint	pnt1, pnt2, pt;

	gr$get_endpoints(msg            = &msg,
			object_id       = objID1,
			point1          = pnt1,
			point2          = pt);

	gr$get_endpoints(msg            = &msg,
			object_id       = objID2,
			point1          = pnt2,
			point2          = pt);

	if( pnt1[2] < pnt2[2] )		ret = -1;
	else if( pnt1[2] > pnt2[2] )	ret =  1;
	else				ret =  0;

	return ret;
}

IGRint	VDloftbk_sortIntPnts( TGRid *intIDs, IGRint cnt, IGRchar format)
{
	IGRint	ret = 0;
	if(intIDs == NULL || cnt <= 1) goto wrapup;

	switch( format ) {

		case '1':
		case '3':
		case '4':
			qsort(	(char *)(intIDs),
				cnt,
				sizeof(TGRid),
				(int(*)())VDloftbk_sortPointsY);
			break;
		case '2':
		case '5':
			qsort(	(char *)(intIDs),
				cnt,
				sizeof(TGRid),
				(int(*)())VDloftbk_sortPointsZ);
			break;
		default: goto wrapup;
	};

	ret = 1;
wrapup:
	return ret;
}

IGRint	VDloftbk_sortByObjNameComp( VDloftbkCv *cv1, VDloftbkCv *cv2 )
{
	IGRint		ret = 0, len1, len2;
	IGRchar		*cp1 = NULL, *cp2 = NULL, 
			str1[40], str2[40], 
			tail1[10], tail2[10];
	IGRdouble	num1 = 0, num2 = 0;
	
	tail1[0] = '\0';
	tail2[0] = '\0';

	strcpy(str1, cv1->cvName);
	strcpy(str2, cv2->cvName);

	cp1 = strpbrk(str1, "0123456789"); 
	cp2 = strpbrk(str2, "0123456789");

	if(cp1 != NULL) {
		num1 = atof( cp1 );
		strcpy(tail1, cp1); 
		*cp1 = '\0'; 
	}

	if(cp2 != NULL) {
		num2 = atof( cp2 );
		strcpy(tail2, cp2);
		*cp2 = '\0';
	}

	if( (ret = strcmp(str1, str2)) != 0 ) goto wrapup;

	if( num1 == num2 ) {
		/* in case alphabet extention */
		ret =  strcasecmp(tail1, tail2);
	}
	else {
		if(num1 < num2)		ret = -1;
		else if(num1 > num2)	ret = 1;
		else			ret = 0;
	}

wrapup:
	return ret;
}

VDloftbk_sortCvByObjName( VDloftbkCv *cvs, IGRint cnt )
{
	IGRint	i;
	IGRchar	objName[128];

	qsort(	(char *)(cvs),
		cnt,
		sizeof(VDloftbkCv),
		(int(*)())VDloftbk_sortByObjNameComp );

}

IGRint	VDloftbk_sortCvByY( VDloftbkCv *cv1, VDloftbkCv *cv2)
{
	IGRint		ret = 0;
	IGRlong		msg;
	IGRpoint	pnt1, pnt2, pt;
	TGRobj_env	cvOE1, cvOE2;

	if(vdobj$IsAncestryValid(	superClassName	= "VDsupGen",
					objOE		= &cv1->cvOE)) {
		vdobj$GetFoot(	objOE	= &cv1->cvOE,
				footOE	= &cvOE1);
	}
	else cvOE1 = cv1->cvOE;

	gr$get_endpoints(msg            = &msg,
			object_id       = &cvOE1.obj_id,
			point1          = pnt1,
			point2          = pt);

	if(vdobj$IsAncestryValid(	superClassName	= "VDsupGen",
					objOE		= &cv2->cvOE)) {
		vdobj$GetFoot(	objOE	= &cv2->cvOE,
				footOE	= &cvOE2);
	}
	else cvOE2 = cv2->cvOE;

	gr$get_endpoints(msg            = &msg,
			object_id       = &cvOE2.obj_id,
			point1          = pnt2,
			point2          = pt);

	if( pnt1[1] < pnt2[1] )		ret = -1;
	else if( pnt1[1] > pnt2[1] )	ret =  1;
	else				ret =  0;

	return ret;
}


IGRint	VDloftbk_sortCvByZ( VDloftbkCv *cv1, VDloftbkCv *cv2)
{
	IGRint		ret = 0;
	IGRlong		msg;
	IGRpoint	pnt1, pnt2, pt;
	TGRobj_env	cvOE1, cvOE2;

	if(vdobj$IsAncestryValid(	superClassName	= "VDsupGen",
					objOE		= &cv1->cvOE)) {
		vdobj$GetFoot(	objOE	= &cv1->cvOE,
				footOE	= &cvOE1);
	}
	else cvOE1 = cv1->cvOE;

	gr$get_endpoints(msg            = &msg,
			object_id       = &cvOE1.obj_id,
			point1          = pnt1,
			point2          = pt);

	if(vdobj$IsAncestryValid(	superClassName	= "VDsupGen",
					objOE		= &cv2->cvOE)) {
		vdobj$GetFoot(	objOE	= &cv2->cvOE,
				footOE	= &cvOE2);
	}
	else cvOE2 = cv2->cvOE;

	gr$get_endpoints(msg            = &msg,
			object_id       = &cvOE2.obj_id,
			point1          = pnt2,
			point2          = pt);

	if( pnt1[2] < pnt2[2] )		ret = -1;
	else if( pnt1[2] > pnt2[2] )	ret =  1;
	else				ret =  0;

	return ret;
}

/*-----------------------------------------------------------
 * disable gadgets
 */
void VDloftbk_enableForm( Form form)
{
	if( form == NULL ) return;

	FIg_enable(form, 0);
}

/*-----------------------------------------------------------
 * disable gadgets
 */
void VDloftbk_disableForm( Form form)
{
	if( form == NULL ) return;

	FIg_disable(form, 0);
	FIg_enable(form, FI_CANCEL);
}

void VDloftbk_saveFormInput( Form form)
{
	LOFTBK_SAVED = 1;
	FIg_get_text(form, LOFTBK_FORMAT_FLD, FORMAT);
	FIg_get_text(form, LOFTBK_TITLE_FLD, TITLE);
	FIg_get_text(form, LOFTBK_PREFIX_FLD, PREFIX);
	FIg_get_text(form, LOFTBK_FILE_FLD, OUTPUTFILE);
	FIg_get_text(form, LOFTBK_START_FLD, STARTP);
	FIg_get_text(form, LOFTBK_NROWS_FLD, ROWCNT);
	FIg_get_text(form, LOFTBK_JOB_NO_FLD, JOBNO);
	FIg_get_text(form, LOFTBK_DWG_NO_FLD, DWGNO);
	FIg_get_text(form, LOFTBK_REV_FLD, REVISION);
	FIg_get_text(form, LOFTBK_CLASS_NO_FLD, CLASSNO);
	FIg_get_text(form, LOFTBK_CLASS_FLD, CLASSSTR);
	FIg_get_text(form, LOFTBK_CAGE_FLD, CAGE);
	FIg_get_text(form, LOFTBK_CAGE_SIZE_FLD, CAGESIZE);
	FIg_get_text(form, LOFTBK_FRMFORMAT_FLD, FRMFORMAT);
}

/*----------------------------------------------------------------
 * manipulate form
 */
IGRlong	VDloftbk_notifyForm(VDloftbkInfo *info)
{
	IGRlong		retFlag = 0;
	IGRlong		sts;
	IGRint          gadget, row = -1, sel = 0, pos;
	Form            form;
	IGRchar         text[128];

	if( info == NULL || info->form == NULL )  goto wrapup;

	form = info->form;
	gadget = info->gadget;

	switch( gadget ) {

	case FI_CANCEL:
		VDloftbk_saveFormInput( form );
		retFlag = FI_CANCEL;
		goto wrapup;

	case LOFTBK_PROCESS_BTN:
		VDloftbk_saveFormInput( form );
		if( !VDloftbk_checkInput(info) ) break;
		if( VDloftbk_process(info) ) {
			sprintf(text, "Output printed to %s", info->filename);
			VDloftbk_delete(info);
			FIg_set_text(form, FI_MSG_FIELD, text);
			UI_status(text);
			VDloftbk_disableForm(form);
			UI_prompt("Identify Frame System");
			break;
		}
	
		strcpy(text, "Command failed. Check your input");
		UI_status(text);
		FIg_set_text(form, FI_MSG_FIELD, text);
		break;
	};

	retFlag = 1;
wrapup:
	return retFlag;
}

/*-----------------------------------------------------------------
 * Set formated header line
 */
IGRlong	VDloftbk_setHdrLine(	IGRchar format, 
				IGRchar *str1, 
				IGRchar *str2, 
				IGRchar *hdrLine ) 
{
	IGRlong		retFlag = 0;
	IGRint		lineSize = 0, pos2 = 0;
	IGRchar		fmt[20];

	switch( format ) {
	
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
		lineSize = DATA_START + VDloftbk_COL_NUM*VDloftbk_DATA_LEN;
		break;
	default: 
		printf("Unknown format\n");
		goto wrapup;
	};

	pos2 = ( lineSize - strlen(str2) - 1 )/2;
	sprintf( fmt, "   %s%s%ds%s", "%s", "%", (pos2 - strlen(str1)), "%s" );
	sprintf( hdrLine, fmt, str1, " ", str2 );

	retFlag = 1;

wrapup:
	return retFlag;
}

/*-----------------------------------------------------------------
 * Validate input
 */
IGRlong	VDloftbk_checkInput(VDloftbkInfo *info) 
{
	IGRlong		retFlag	= 0;
	IGRint		frmFlag = 0;
	IGRchar		format[128],
			command[40], 
			title[40], 
			prefix[40], 
			filename[40], 
			startp[40], 
			rowCnt[40], 
			mdate[40],
			jobNo[40], 
			dwgNo[40], 
			revision[40], 
			classNo[40], 
			classStr[80],
			cage[40], 
			cageSize[40],
			frmFormat[40],
			header[1024], text[128], hdrLine[256], *ptr;

	Form		form = NULL;
	
	title[0]	= '\0';
	format[0]	= '\0';
	prefix[0]	= '\0';
	startp[0]	= '\0';
	rowCnt[0]	= '\0';
	mdate[0]	= '\0';
	jobNo[0]	= '\0';
	dwgNo[0]	= '\0';
	revision[0]	= '\0';
	classNo[0]	= '\0';
	classStr[0]	= '\0';
	cage[0]		= '\0';
	cageSize[0]	= '\0';

	if( info == NULL ) goto wrapup;

	form  = info->form;
	if( form == NULL ) goto wrapup;

	if(info->frmSysOE.obj_id.objid == NULL_OBJID) {
		UI_prompt("Identify Frame System");
		UI_status("You need to locate a frame system first");
		goto wrapup;
	}

	FIg_get_text(form, LOFTBK_FORMAT_FLD, format);
	if(format[0] == '\0') {
		UI_status("Select a format");
		goto wrapup;
	}

	// title is optional
	FIg_get_text(form, LOFTBK_TITLE_FLD, title);

	FIg_get_text(form, LOFTBK_PREFIX_FLD, prefix);
	if(prefix[0] == '\0') {
		UI_status("Fill in curve's prefix name");
		FIfld_pos_cursor(form, LOFTBK_PREFIX_FLD,0, 0, 0, 0, 0, 0);
		goto wrapup;
	}
	if(prefix[strlen(prefix)-1] == '*') prefix[strlen(prefix)-1] = '\0';

	FIg_get_text(form, LOFTBK_FILE_FLD, filename);
	if(filename[0] == '\0') {
		UI_status("Fill in file name");
		FIfld_pos_cursor(form, LOFTBK_FILE_FLD,0, 0, 0, 0, 0, 0);
		goto wrapup;
	}

	FIg_get_text(form, LOFTBK_START_FLD, startp);
	if(startp[0] == '\0') {
		UI_status("Fill in start page number");
		FIfld_pos_cursor(form, LOFTBK_START_FLD,0, 0, 0, 0, 0, 0);
		goto wrapup;
	}

	FIg_get_text(form, LOFTBK_NROWS_FLD, rowCnt);
	if(rowCnt[0] == '\0') {
		UI_status("Fill in number of lines per page");
		FIfld_pos_cursor(form, LOFTBK_NROWS_FLD, 0, 0, 0, 0, 0, 0);
		goto wrapup;
	}

	FIg_get_text(form, LOFTBK_DATE_FLD, mdate);
	if(mdate[0] == '\0') {
		UI_status("Fill in date");
		FIfld_pos_cursor(form, LOFTBK_DATE_FLD, 0, 0, 0, 0, 0, 0);
		goto wrapup;
	}

	FIg_get_text(form, LOFTBK_JOB_NO_FLD, jobNo);
	if(jobNo[0] == '\0') {
		UI_status("Fill in jobj number");
		FIfld_pos_cursor(form, LOFTBK_JOB_NO_FLD, 0, 0, 0, 0, 0, 0);
		goto wrapup;
	}


	FIg_get_text(form, LOFTBK_DWG_NO_FLD, dwgNo);
	if(dwgNo[0] == '\0') {
		UI_status("Fill in AII DWG. No.");
		FIfld_pos_cursor(form, LOFTBK_DWG_NO_FLD, 0, 0, 0, 0, 0, 0);
		goto wrapup;
	}

	FIg_get_text(form, LOFTBK_REV_FLD, revision);
	if(revision[0] == '\0') {
		UI_status("Fill in revision");
		FIfld_pos_cursor(form, LOFTBK_REV_FLD, 0, 0, 0, 0, 0, 0);
		goto wrapup;
	}
	FIg_get_text(form, LOFTBK_CLASS_FLD, classStr);
	if(classStr[0] == '\0') {
		UI_status("Fill in calss");
		FIfld_pos_cursor(form, LOFTBK_CLASS_FLD, 0, 0, 0, 0, 0, 0);
		goto wrapup;
	}
	FIg_get_text(form, LOFTBK_CLASS_NO_FLD, classNo);
	if(classNo[0] == '\0') {
		UI_status("Fill in XXX number");
		FIfld_pos_cursor(form, LOFTBK_CLASS_NO_FLD, 0, 0, 0, 0, 0, 0);
		goto wrapup;
	}

	FIg_get_text(form, LOFTBK_CAGE_FLD, cage);
	if(cage[0] == '\0') {
		UI_status("Fill in cage number");
		FIfld_pos_cursor(form, LOFTBK_CAGE_FLD, 0, 0, 0, 0, 0, 0);
		goto wrapup;
	}

	FIg_get_text(form, LOFTBK_CAGE_SIZE_FLD, cageSize);
	if(cageSize[0] == '\0') {
		UI_status("Fill in cage size");
		FIfld_pos_cursor(form, LOFTBK_CAGE_SIZE_FLD, 0, 0, 0, 0, 0, 0);
		goto wrapup;
	}

	FIg_get_text(form, LOFTBK_FRMFORMAT_FLD, frmFormat);
	if( !strcasecmp( frmFormat, "Number") ) {
		info->frmFlag = 0;
	}
	else { 
		info->frmFlag = 1;
	}

	/*
	 * Get input
	 */

	// header first line
	FIg_get_text(form, LOFTBK_FORM_TITLE, command);
	sprintf( text, "DATE: %s", mdate);
	VDloftbk_setHdrLine (	format[0],
				text, 
				command, 
				info->date_title_page );

	// header 2nd line
	sprintf(info->header, "   JOB NO. %s\n", jobNo);

	// header 3rd line
	sprintf(header, "   AII DWG. No. %s  REV. %s\n", dwgNo, revision);
	strcat(info->header, header);

	// header 4th line
	VDloftbk_setHdrLine (	format[0],
				classNo, 
				classStr, 
				header );
	strcat(header, "\n");
	strcat(info->header, header);

	// header 5th line
	sprintf(header, "   CAGE %s\tSIZE %s\n", cage, cageSize);
	strcat(info->header, header);

	// header 6th line, 7th line is empty
	ptr = strchr( format, ' ');
	if( !ptr )	ptr = format;
	else		ptr++;
	VDloftbk_setHdrLine (	format[0],
				"", 
				ptr, 
				header );
	strcat(header, "\n\n");
	strcat(info->header, header);

	// header 8th line
	VDloftbk_setHdrLine (	format[0],
				"", 
				title, 
				header );
	strcat(header, "\n");
	strcat(info->header, header);

	// header 9th line
	strcat(info->header, "\n");

	strcpy(info->format, format);
	strcpy(info->prefix, prefix);
	strcpy(info->filename, filename);
	info->startPage = atoi(startp);
	info->rowCnt = atoi(rowCnt);

	retFlag = 1;
wrapup:
	return retFlag;
}

/*-------------------------------------------------------------------
 * Output basedon input
 */
IGRlong	VDloftbk_process( VDloftbkInfo *info)
{
	IGRlong		retFlag	= 0, sts ;
	IGRchar		text[128];
	FILE		*file = NULL;

	if( info == NULL ) goto wrapup;

	if( info->filename[0] == '\0') goto wrapup;
	file = fopen(info->filename, "wt") ;
	if( file == NULL ) {
		UI_status("Error for opening file");
		goto wrapup;
	}

	UI_status("Processing...");

	sts = VDloftbk_getCvsByPrefix (	info->prefix, 
					&info->cvList, 
					&info->cvCnt);

	if( !sts ) {
		printf("VDloftbk_getCvsByPrefix failed\n");
		goto wrapup;
	}

	if( info->cvCnt < 1 ) {
		printf("No curves found by prefix %s\n", info->prefix);
		sprintf(text,"No curves found by prefix %s\n", info->prefix);
		UI_status(text);
		FIg_set_text(info->form, FI_MSG_FIELD, text);
		goto wrapup;
	}

	switch( info->format[0] ) {
	
	case '1':
		qsort(	(char *)(info->cvList),
			info->cvCnt,
			sizeof(VDloftbkCv),
			(int(*)())VDloftbk_sortCvByZ );

		sts = VDloftbk_printFormat1(info, file);
		break;
	case '2':
		VDloftbk_sortCvByObjName( info->cvList, info->cvCnt );
		sts = VDloftbk_printFormat2(info, file);
		break;
	case '3':
		VDloftbk_sortCvByObjName( info->cvList, info->cvCnt );
		sts = VDloftbk_printFormat3(info, file);
		break;
	case '4':
		VDloftbk_sortCvByObjName( info->cvList, info->cvCnt );
		sts = VDloftbk_printFormat4(info, file);
		break;
	case '5':
		qsort(	(char *)(info->cvList),
			info->cvCnt,
			sizeof(VDloftbkCv),
			(int(*)())VDloftbk_sortCvByY );

		sts = VDloftbk_printFormat1(info, file);
		break;
	default:
		goto wrapup;
	};

	retFlag = 1;
wrapup:
	if(file) fclose(file) ;
	return retFlag;
}


/*-------------------------------------------------------------------
 * Print header to file for format 1 or 5
 */
IGRlong	VDloftbk_printHeader1 (
		FILE		*file, 
		VDloftbkInfo	*info, 
		IGRint		page,
		IGRint		grp,
		IGRint		*lineCnt)
{
	IGRlong		retFlag = 0, msg;
	IGRint		i, orient, pagePos;
	IGRint		grpSize = VDloftbk_COL_NUM;
	IGRpoint	pnt, pt;
	IGRchar		text[128], header[2048],
			pageNo[128], strFormat[40];
	TGRobj_env	cvOE;

	//SetProc(VDloftbk_printHeader); Begin

	if( file == NULL ) goto wrapup;
	if( info == NULL ) goto wrapup; 
 
	*lineCnt = 0;
	if( info->format[0] == '1' ) {
		orient = 2;
	}
	else if( info->format[0] == '5' ) {
		orient = 1;
	}
	else {
		printf("Format error!\n");
		goto wrapup;
	}

	sprintf(pageNo, "PAGE NO. %d", page);
	pagePos = DATA_START + VDloftbk_COL_NUM*VDloftbk_DATA_LEN 
				- strlen(pageNo);
	sprintf(strFormat, "%s%s%ds%s", "%s", "%", 
		pagePos - strlen(info->date_title_page), "%s");

	sprintf(header, strFormat, info->date_title_page, " ", pageNo);
	strcat( header, "\n" ) ;

	strcat( header, info->header ) ;
  	*lineCnt = 9;
	sprintf(text, "%8s", "FRAME");
	strcat(header, text);
	for( i = 0; i < grpSize && i+grp*grpSize<info->cvCnt; i++ ) {
		if(vdobj$IsAncestryValid(
				superClassName = "VDsupGen",
				objOE = &info->cvList[i+grp*grpSize].cvOE)) {
			vdobj$GetFoot(
				objOE  = &info->cvList[i+grp*grpSize].cvOE,
				footOE = &cvOE);
		}
		else {
			cvOE = info->cvList[i+grp*grpSize].cvOE;
		}
		gr$get_endpoints (	msg		= &msg, 
					md_env		= &cvOE.mod_env,
					object_id	= &cvOE.obj_id,
					point1		= pnt,
					point2		= pt);
		if( !(msg&1) ) {
			__DBGpr_com("gr$get_endpoints failed");
			__DBGpr_obj("\t for: ", cvOE.obj_id);
printf("gr$get_endpoints failed for: ");vdobj$Print(objOE=&cvOE);
			goto wrapup;
		}
		sprintf(text,"%10.3f", pnt[orient]*MTR);
		strcat(header, text);
	}

	if(info->frmFlag == 0) {
		sprintf(text, "\n%8s", "(No.)");
	}
	else {
		sprintf(text, "\n%8s", "(METER)");
	}
	strcat(header, text);
	(*lineCnt)++;
	for( i = 0; i < grpSize && i+grp*grpSize < info->cvCnt; i++ ) {
		sprintf(text, "%10s", "(METER)");
		strcat(header, text);
	}

	strcat(header, "\n\n"); (*lineCnt) += 2;
	fprintf(file, header);

	retFlag = 1;

wrapup:
	//End
	return retFlag;
}


/*-------------------------------------------------------------------
 * Print header to file for format 2
 */
IGRlong	VDloftbk_printHeader2 (
		FILE		*file, 
		VDloftbkInfo	*info, 
		IGRint		page,
		IGRint		grp,
		IGRint		*lineCnt)
{
	IGRlong		retFlag = 0, msg;
	IGRint		i, j, len, orient, pagePos;
	IGRint		grpSize;
	IGRpoint	pnt, pt;
	IGRchar		text[128], header[2048], str[128], 
			pageNo[128], strFormat[40],
			*ptr1 = NULL, *ptr = NULL;
	TGRobj_env	cvOE;

	SetProc(VDloftbk_printHeader); Begin

	if( file == NULL ) goto wrapup;
	if( info == NULL ) goto wrapup; 
 
	*lineCnt = 0;
	grpSize = VDloftbk_COL_NUM/2;

	sprintf(pageNo, "PAGE NO. %d", page);
	pagePos = DATA_START + VDloftbk_COL_NUM*VDloftbk_DATA_LEN 
				- strlen(pageNo);
	sprintf(strFormat, "%s%s%ds%s", "%s", "%", 
		pagePos - strlen(info->date_title_page), "%s");

	sprintf(header, strFormat, info->date_title_page, " ", pageNo);
	strcat( header, "\n" ) ;

	strcat( header, info->header ) ;
  	*lineCnt = 9;

	sprintf(text, "%8s", " ");
	strcat(header, text);
	for( i = 0; i < grpSize && i+grp*grpSize < info->cvCnt; i++ ) {
		strcpy(str, info->cvList[i+grp*grpSize].cvName);
		ptr = strtok(str, "_");
		if( ptr ) {
			ptr1 = strtok( NULL, "_" );
			if( ptr1 ) ptr = ptr1;
		}
		else	ptr = str;

		ptr1 = strchr( ptr, '-' );
		while( ptr1 ) {
			*ptr1 = ' ';
			ptr1 = strchr( ptr, '-' );
		}
		len = (16 - strlen(ptr))/2;
                for( j = 0; j < len; j++ ) strcat( ptr, " " );
                sprintf(text, "%20s", ptr);
		strcat(header, text);
	}
	strcat(header, "\n"); 
	(*lineCnt)++;

	sprintf(text, "%8s", "FRAME");
	strcat(header, text);
	for( i = 0; i < grpSize && i+grp*grpSize < info->cvCnt; i++ ) {
		sprintf(text,"%10s%10s", "HEIGHT", "HALF ");
		strcat(header, text);
	}

	sprintf(text, "\n%8s", " ");
	strcat(header, text); 
	(*lineCnt)++;
	for( i = 0; i < grpSize && i+grp*grpSize < info->cvCnt; i++ ) {
		sprintf(text, "%10s%10s", " ", "BREADTH");
		strcat(header, text);
	}

	if(info->frmFlag == 0) {
		sprintf(text, "\n%8s", "(No.)");
	}
	else {
		sprintf(text, "\n%8s", "(METER)");
	}
	strcat(header, text); 
	(*lineCnt)++;
	for( i = 0; i < grpSize && i+grp*grpSize < info->cvCnt; i++ ) {
		sprintf(text, "%10s%10s", "(METER)", "(METER)");
		strcat(header, text);
	}

	strcat(header, "\n\n"); (*lineCnt) += 2;
	fprintf(file, header);

	retFlag = 1;

wrapup:
	End
	return retFlag;
}

/*-------------------------------------------------------------------
 * Print header to file for format 3
 */
IGRlong	VDloftbk_printHeader3 (
		FILE		*file, 
		VDloftbkInfo	*info, 
		IGRint		page,
		IGRint		grp,
		IGRint		*lineCnt)
{
	IGRlong		retFlag = 0, msg;
	IGRint		i, j, len, orient, pagePos;
	IGRint		grpSize;
	IGRpoint	pnt, pt;
	IGRchar		text[128], header[3072], str[128], 
			pageNo[128], strFormat[40],
			*ptr1 = NULL, *ptr = NULL;
	TGRobj_env	cvOE;

	//SetProc(VDloftbk_printHeader); Begin

	if( file == NULL ) goto wrapup;
	if( info == NULL ) goto wrapup; 
 
	*lineCnt = 0;
	grpSize = VDloftbk_COL_NUM3;

	sprintf(pageNo, "PAGE NO. %d", page);
	pagePos = DATA_START + VDloftbk_COL_NUM*VDloftbk_DATA_LEN 
				- strlen(pageNo);
	sprintf(strFormat, "%s%s%ds%s", "%s", "%", 
		pagePos - strlen(info->date_title_page), "%s");

	sprintf(header, strFormat, info->date_title_page, " ", pageNo);
	strcat( header, "\n" ) ;

	strcat( header, info->header ) ;
  	*lineCnt = 9;

	sprintf(text, "%8s", " ");
	strcat(header, text);
	for( i = 1; i < grpSize && i+grp*grpSize < info->cvCnt; i+=2 ) {
		strcpy(str, info->cvList[i+grp*grpSize].cvName);
		ptr = strtok(str, "_");
		if( ptr ) {
			ptr1 = strtok( NULL, "_" );
			if( ptr1 ) ptr = ptr1;
		}
		else	ptr = str;

		ptr1 = strchr( ptr, '-' );
		while( ptr1 ) {
			*ptr1 = ' ';
			ptr1 = strchr( ptr, '-' );
		}
		len = (30 - strlen(ptr))/2;
                for(j = 0; j < len; j++) strcat( ptr, " ");
                sprintf(text, "%30s", ptr);
		strcat(header, text);
	}
	strcat(header, "\n"); (*lineCnt)++ ;

	sprintf(text, "%8s", "FRAME");
	strcat(header, text);
	for( i = 1; i < grpSize && i+grp*grpSize < info->cvCnt; i+=2 ) {
		sprintf(text,"%10s%10s%10s", "HEIGHT", "HEIGHT ", "HALF ");
		strcat(header, text);
	}

	sprintf(text, "\n%8s", " ");
	strcat(header, text); 
	(*lineCnt)++;
	for( i = 1; i < grpSize && i+grp*grpSize < info->cvCnt; i+=2 ) {
		sprintf(text, "%10s%10s%10s", "AT  CL", "AT  SIDE", "BREADTH");
		strcat(header, text);
	}

	if(info->frmFlag == 0) {
		sprintf(text, "\n%8s", "(No.)");
	}
	else {
		sprintf(text, "\n%8s", "(METER)");
	}
	strcat(header, text); 
	(*lineCnt)++;
	for( i = 1; i < grpSize && i+grp*grpSize < info->cvCnt; i+=2 ) {
		sprintf(text, "%10s%10s%10s", "(METER)", "(METER)", "(METER)");
		strcat(header, text);
	}

	strcat(header, "\n\n"); (*lineCnt) += 2;
	fprintf(file, header);

	retFlag = 1;

wrapup:
	//End
	return retFlag;
}


/*-------------------------------------------------------------------
 * Print header to file for format 4
 */
IGRlong	VDloftbk_printHeader4 (
		FILE		*file, 
		VDloftbkInfo	*info, 
		IGRint		page,
		IGRint		grp,
		IGRint		*lineCnt)
{
	IGRlong		retFlag = 0, msg;
	IGRint		i, j, len, orient, pagePos;
	IGRint		grpSize;
	IGRpoint	pnt, pt;
	IGRchar		text[128], str[128], header[2048], 
			pageNo[128], strFormat[40],
			*ptr1 = NULL, *ptr = NULL;
	TGRobj_env	cvOE;

	//SetProc(VDloftbk_printHeader); Begin

	if( file == NULL ) goto wrapup;
	if( info == NULL ) goto wrapup; 
 
	*lineCnt = 0;
	grpSize = VDloftbk_COL_NUM/2;

	sprintf(pageNo, "PAGE NO. %d", page);
	pagePos = DATA_START + VDloftbk_COL_NUM*VDloftbk_DATA_LEN 
				- strlen(pageNo);
	sprintf(strFormat, "%s%s%ds%s", "%s", "%", 
		pagePos - strlen(info->date_title_page), "%s");

	sprintf(header, strFormat, info->date_title_page, " ", pageNo);
	strcat( header, "\n" ) ;

	strcat( header, info->header ) ;
  	*lineCnt = 9;

	sprintf(text, "%8s", " ");
	strcat(header, text);
	for( i = 0; i < grpSize && i+grp*grpSize < info->cvCnt; i++ ) {
		strcpy(str, info->cvList[i+grp*grpSize].cvName);
		ptr = strtok(str, "_");
		if( ptr ) {
			ptr1 = strtok( NULL, "_" );
			if( ptr1 ) ptr = ptr1;
		}
		else	ptr = str;

		ptr1 = strchr( ptr, '-' );
		while( ptr1 ) {
			*ptr1 = ' ';
			ptr1 = strchr( ptr, '-' );
		}
		len = (16 - strlen(ptr))/2;
                for( j = 0; j < len; j++) strcat( ptr, " " );
                sprintf(text, "%20s", ptr);
		strcat(header, text);
	}

	sprintf(text, "\n%8s", "FRAME"); 
	strcat(header, text);
	(*lineCnt)++;
	for( i = 0; i < grpSize && i+grp*grpSize < info->cvCnt; i++ ) {
		sprintf(text,"%10s%10s", "HEIGHT", "HALF ");
		strcat(header, text);
	}

	sprintf(text, "\n%8s", " ");
	strcat(header, text); 
	(*lineCnt)++;
	for( i = 0; i < grpSize && i+grp*grpSize < info->cvCnt; i++ ) {
		sprintf(text, "%10s%10s", " ", "BREADTH");
		strcat(header, text);
	}

	if(info->frmFlag == 0) {
		sprintf(text, "\n%8s", "(No.)");
	}
	else {
		sprintf(text, "\n%8s", "(METER)");
	}
	strcat(header, text); 
	(*lineCnt)++;
	for( i = 0; i < grpSize && i+grp*grpSize < info->cvCnt; i++ ) {
		sprintf(text, "%10s%10s", "(METER)", "(METER)");
		strcat(header, text);
	}

	strcat(header, "\n\n"); (*lineCnt) += 2;
	fprintf(file, header);

	retFlag = 1;

wrapup:
	//End
	return retFlag;
}

/*-------------------------------------------------------------------
 * Check input curves. They have to be pairs, each center line has a 
 * corresponding side curve (on the shell).
 */
IGRlong	 VDloftbk_checkClSide(VDloftbkInfo *info)
{
	IGRlong		retFlag = 0;
	IGRint		i, j, cnt = 0;
	IGRchar		*p1 = NULL, *p2 = NULL;
	IGRchar		 name1[40], name2[40], tail1[10], tail2[10];
	VDloftbkCv	*cvs = NULL;

	if(info == NULL || info->cvCnt <= 1) goto wrapup;

	cvs = _CALLOC(info->cvCnt, VDloftbkCv);
	if(cvs == NULL) goto wrapup;

	qsort(	(char *)(info->cvList),
		info->cvCnt,
		sizeof(VDloftbkCv),
		(int(*)())VDloftbk_sortCvByZ );

	for(i = 0; i < info->cvCnt; i++) {
		strcpy(name1, info->cvList[i].cvName);
		p1 = strrchr(name1, '_');
		strcpy( tail1, ++p1 ); --p1;
		*p1 = '\0';
		if(tail1[0] != 'c' && tail1[0] != 'C') continue;
		for(j = 0; j < info->cvCnt; j++) {
			strcpy(name2, info->cvList[j].cvName);
			p2 = strrchr(name2, '_');
			strcpy( tail2, ++p2 ); --p2;
			*p2 = '\0';
			if(	!strcmp(name1, name2) && 
				(tail1[0] == 'c' || tail1[0] == 'C') &&
				(tail2[0] == 's' || tail2[0] == 'S') )
			{
				cvs[cnt].cvOE = info->cvList[i].cvOE;
				strcpy(cvs[cnt].cvName,info->cvList[i].cvName);
				cvs[cnt].intCnt = NULL;
				cvs[cnt].intIDs = NULL;
				cnt++;
				cvs[cnt].cvOE = info->cvList[j].cvOE;
				strcpy(cvs[cnt].cvName,info->cvList[j].cvName);
				cvs[cnt].intCnt = NULL;
				cvs[cnt].intIDs = NULL;
				cnt++;
				break;
			}
		}
	}

#ifdef DEBUG
	printf("\nCurves after check:\n");
	for(i=0; i < cnt; i++) {
		vdobj$Print(objOE = &cvs[i].cvOE);
	}
#endif

	_FREE(info->cvList);
	info->cvList = cvs;
	info->cvCnt = cnt;

	retFlag  = 1;
wrapup:
	return retFlag;
}


/*-----------------------------------------------------------------
 * Find all objects by object pre fix name
 */
IGRlong VDloftbk_getObjsByPreFix( 
GRspacenum      cur_osnum,
IGRchar		*className, 
IGRchar		*prefix, 
IGRint		*objCnt,
TGRobj_env	**objOEs )
{
	IGRlong         ret;
	IGRlong		sts, msg ;
	IGRint          i, nb_obj, nb_id, size;
	GRclassid       classids[3], calssid1;
	GRobjid		*obj_list = NULL;
	TGRid		*id_list = NULL, objID, id;
	TGRid		*compList = NULL;
	TGRobj_env	objOE;
	IGRchar		name[128], macName[40] ;

	SetProc( VDgetObjsByPreFix ); Begin

	ret		= 0 ;
	nb_obj		= 0 ;
	nb_id		= 0 ;
	*objCnt		= 0;
	*objOEs		= NULL  ;

        sts = om$get_classid (	classname = className ,
				p_classid = &classids[0]);
	if( !(sts&1) ) {
		printf("om$get_classid failed\n");
		goto wrapup ;
	}
	classids[1] = OPP_nci_macro_class_id;
	classids[2] = OPP_VDsupGen_class_id;

        sts = VDpms_findall_ancestryobjects (
                                        cur_osnum,
                                        3, 
                                        classids, 
                                        &nb_obj, 
                                        NULL);
	if( !(sts&1) || !nb_obj ) goto wrapup ;
	__DBGpr_int("nb_obj", nb_obj);

	obj_list = _CALLOC( nb_obj, GRobjid ) ;
	if( obj_list == NULL ) {
		printf("_CALLOC failed for obj_list\n") ;
		goto wrapup ;
	}

	id_list = _CALLOC( nb_obj, TGRid ) ;
	if( id_list == NULL ) {
		printf("_CALLOC failed for id_list\n") ;
		goto wrapup ;
	}

	sts = VDpms_findall_ancestryobjects(
					cur_osnum,
					3, 
					classids, 
					&nb_obj, 
					obj_list);
	if( !(sts&1) || !nb_obj ) goto wrapup ;

	objID.osnum = cur_osnum ;
	size = strlen(prefix);
	for(i = 0; i < nb_obj; i = i+1 ) {

		objID.objid = obj_list[i] ;
		name[0] = '\0' ;

		// Get object name
		vdobj$Get (	objID	= &objID,
				objName	= name);
		if(name[0] == '\0' ) continue ;

		if(!strncmp(name, prefix, size) ) {
        		sts = vdobj$IsAncestryValid(
						superClassName = "nci_macro",
						objID = &objID);
			if( sts ) {
				VDahGetObjectEnv(&objID, &objOE);
				sts = vd_$get_components(
					msg        = &msg,
                                        grobjId    = &objOE.obj_id,
                                        grobjEnv   = &objOE.mod_env,
                                        number     = &nb_id,
                                        components = &compList );
				if(!(sts&1)) continue;
				if(nb_id == 0 || compList == NULL) continue;
				id = compList[0]; _FREE(compList);
				if(!vdobj$IsAncestryValid(
					superClassName = className,
					objID = &id)) continue;
			}

			id_list[*objCnt] = objID ;
			(*objCnt)++;
		}
	}

	if( (*objCnt) < 1 ) {
		ret = 1;
		goto wrapup;
	}

	*objOEs = _CALLOC( *objCnt, TGRobj_env ) ;
	if( objOEs == NULL ) {
		printf("_CALLOC failed for objOEs\n") ;
		goto wrapup ;
	}

	for(i = 0; i < *objCnt; i = i+1 ) {
		VDahGetObjectEnv(&id_list[i], &(*objOEs)[i]);
	}

	ret = 1 ;
wrapup:
	_FREE( obj_list ) ;
	_FREE( id_list ) ;

	End
	return ret ;
}

/*-----------------------------------------------------------------
 * Get curves by prefix name
 */
IGRstat  VDloftbk_getCvsByPrefix(
IGRchar         *prefix,
VDloftbkCv	**cvList,
IGRint		*cvCnt)
{
        IGRstat         ret;
        IGRint          cnt = 0, i, j;
        IGRlong         sts, msg;
        IGRchar         preName[128], objName[128];
        TGRobj_env      **objOEs;
	IGRint		*listCnt = NULL, NbRefOs;
	GRspacenum	main_os, osnum, *RefOsList = NULL;

        ret     = 0;
        objOEs  = NULL;
        *cvCnt	= 0 ;
        *cvList	= NULL ;

	// Check prefix string
        __DBGpr_str("___ prefix", prefix);
        if( prefix[0] == '\0' ) goto wrapup;

        if( prefix[strlen(prefix)-1] != '*' ) {
                sprintf(preName, "%s*", prefix);
        }
        else {
                strcpy( preName, prefix );
		prefix[strlen(prefix)-1] = '\0';
        }
        __DBGpr_str("___ preName", preName);

	// Get reference files
	ex$get_cur_mod ( osnum = &main_os ) ;
	sts = vd$get_ref_os_list (      msg           =  &msg,
                                        main_os       =  &main_os,
                                        num_ref_os    =  &NbRefOs,
                                        ref_os_list   =  &RefOsList );
	if( !(sts&msg&1) ) {
		NbRefOs = 0; RefOsList = NULL;
		__DBGpr_com("vd$get_ref_os_list failed\n");
	}

	// Allocate memories for objOEs
	objOEs = _CALLOC(NbRefOs + 1, TGRobj_env *);
	if(objOEs == NULL) {
		goto wrapup;
	}

	listCnt = _CALLOC(NbRefOs + 1, IGRint);
	if(listCnt == NULL) {
		goto wrapup;
	}

	// Get objOEs from reference file
	__DBGpr_int("NbRefOs", NbRefOs);
	for(i = 0; i <= NbRefOs; i++) {
		listCnt[i] = 0;
		objOEs[i] = NULL;
		if( i == NbRefOs ) osnum = main_os;
		else osnum = RefOsList[i];
		sts = VDloftbk_getObjsByPreFix( 
				osnum, 
				"GRcurve", 
				prefix, 
				&listCnt[i], 
				&objOEs[i]);
		if( !(sts&1) ) {
			listCnt[i] = 0;
			objOEs[i] = NULL;
		}
		(*cvCnt) += listCnt[i];
	}


	if(*cvCnt == 0 ) {
		ret = 1;
		goto wrapup;
	}

        *cvList = _CALLOC( *cvCnt, VDloftbkCv );
        if( *cvList == NULL ) {
                printf("Error allocating space for tmpcvOEs\n");
                goto wrapup;
        }

	cnt = 0;
	for(i = 0; i <= NbRefOs; i++) {
		for(j = 0; j < listCnt[i]; j++) {
			(*cvList)[cnt+j].cvOE = objOEs[i][j];
			(*cvList)[cnt+j].intCnt = NULL;
			(*cvList)[cnt+j].intIDs = NULL;
			vdobj$Get (	objOE	= &objOEs[i][j],
					objName	= (*cvList)[cnt+j].cvName);
		}
		cnt += listCnt[i];
	}

	//VDloftbk_sortCvByObjName( *cvList, *cvCnt );

	for(i = 0; i <= NbRefOs; i++) {
		_FREE( objOEs[i] );
	}
	_FREE( listCnt );
	_FREE( objOEs );

#ifdef DEBUG
	printf("\nCurves :\n");
	for(j=0; j < *cvCnt; j++) {
		vdobj$Print(objOE = &(*cvList)[j].cvOE);
	}
#endif

        ret = 1;

wrapup:
        _FREE( listCnt );
        _FREE( objOEs );
	_FREE( RefOsList);
        return ret;
}



/*------------------------------------------------------------------
 * Find intersections. If any exceptions found, modify this function to
 * get correct intersections.
 */
IGRstat VDloftbk_getPlnCvInt (
TGRobj_env	*planeOE,
TGRobj_env	*cvOE,
IGRint		*intCnt,
TGRid		**intIDs)
{
	IGRstat		ret = 0;
	IGRlong		sts, msg;
	IGRint		i, j;
	IGRint		AScomp = 0, GRcomp = 0, intMac = 0;
	IGRint		cnt = 0, listCnt = 0, trim2 = INF_B, intMacCnt = 0;
	TGRid		*compList = NULL, *intList = NULL, *intMacs = NULL;
	TGRobj_env	objOE;
	
	//SetProc(VDloftbk_getPlnCvInt); Begin

	(*intCnt) = 0;
	(*intIDs) = NULL;

	if(planeOE == NULL || planeOE->obj_id.objid == NULL_OBJID) goto wrapup;
	if(cvOE == NULL || cvOE->obj_id.objid == NULL_OBJID) goto wrapup;

	AScomp = vdobj$IsAncestryValid(objID		= &cvOE->obj_id,
				superClassID	= OPP_AScompcurve_class_id);
	GRcomp = vdobj$IsAncestryValid(objID		= &cvOE->obj_id,
				superClassID	= OPP_GRcompcurve_class_id);
	intMac = vdobj$IsAncestryValid(objID		= &cvOE->obj_id,
				superClassID	= OPP_nci_macro_class_id);

	if( AScomp || GRcomp || intMac )
	{
		sts = vd_$get_components(msg            = &msg,
                                        grobjId         = &cvOE->obj_id,
                                        grobjEnv        = &cvOE->mod_env,
                                        number          = &cnt,
                                        components      = &compList );
		if( !(sts&1) ){
			printf("Failed to get composites of AScompcurve\n");
			goto wrapup;
		}

		if( intMac ) {
			intMacCnt = 0;
			intMacs = _CALLOC(1, TGRid);
			if( !intMacs ) goto wrapup;
			for( i = 0; i < cnt; i++ ) {
			   _FREE(intList);
			   listCnt = 0;
			   VDahGetObjectEnv(&compList[i], &objOE);
			   sts = vd_$get_components(
					msg		= &msg,
                                        grobjId         = &objOE.obj_id,
                                        grobjEnv        = &objOE.mod_env,
                                        number          = &listCnt,
                                        components      = &intList );
			   if( !(sts&1) || listCnt < 1 ) {
				continue;
			   }
			   intMacs = _REALLOC(intMacs, intMacCnt+listCnt,TGRid);
			   if( !intMacs ) goto wrapup;
			   for( j = 0; j < listCnt; j++ ) {
				intMacs[j+intMacCnt] = intList[j];
			   }
			   intMacCnt += listCnt;
			}
			if( intMacCnt > 0 ) {
				_FREE(compList);
				compList = intMacs;
				cnt = intMacCnt;
			}
			else {
				_FREE( intMacs );
			}
		}
	}
	else {
		cnt = 1;
		compList = _CALLOC(1, TGRid);
		if(compList == NULL) goto wrapup;
		compList[0] = cvOE->obj_id;
	}

	for(i = 0; i < cnt; i++) {
		listCnt = 0;
		intList = NULL;
		trim2 = IMP_B;

		objOE.obj_id  = compList[i];
		objOE.mod_env = cvOE->mod_env;
		sts = vd$int2elem(	elem1		= planeOE,
					elem2		= &objOE,
					trim1req	= INF_B,
					trim2req	= trim2,
					NumbInt		= &listCnt,
					GRidInt		= &intList);
		if( (sts&1) && intList && listCnt > 0)  {
			(*intCnt) = listCnt;
			(*intIDs) = intList;
			break;
		}
	}

	ret = 1;
wrapup:
	_FREE(compList);
if( !ret ) printf("Int failed !!!\n");
	//End
	return ret;
}

/*------------------------------------------------------------------
 * Find the range of frame system
 */
IGRstat VDloftbk_getFrmRangeFromCv(
  VDloftbkInfo	*info,
  TGRid		*frmIDs,
  IGRint	frmCnt,
  IGRint	*fmin,
  IGRint	*fmax )
{
  IGRlong	sts, msg ;
  IGRstat	retFlag = 0 ;
  IGRint	orient, frmMark = -9999999 ;
  IGRint	i, j, k, l, cnt, delt ;
  IGRint	fmn, fmx ;
  IGRpoint	pt1, pt2;
  IGRvector	normal ;
  TGRplane	plane ;
  TGRmd_env	md_env;
  TGRobj_env	frmOE1, frmOE2, cvOE;
  TGRid		*intIDs = NULL;
  IGRint	intCnt = 0;
  BSrc		rc ;

  SetProc( VDloft_getFrmRangeFromCv ); Begin

  if(frmIDs == NULL ) goto wrapup;

  gr$get_module_env(buffer = &md_env);

  // Get a plane normal to determine the orientation of frame system
  plane.normal = normal;
  plane.point  = pt1;
  sts = om$send(msg      = message GRvg.GRdetplane (
					&msg,
					&md_env.md_env.matrix_type,
					md_env.md_env.matrix,
					&plane	),
		senderid = NULL_OBJID,
		targetid = frmIDs[0].objid,
		targetos = frmIDs[0].osnum );

  if (!(sts & msg & 1)) {
	printf("GRvg.GRdetplane failed\n");
	goto wrapup ;
  }

  if( fabs(1 - fabs(normal[0]) ) < 0.00001 ) {
	orient = 0 ;
  }
  else if(fabs(1 - fabs(normal[1]) ) < 0.00001 ) {
	orient = 1 ;
  }
  else {
	orient = 2 ;
  }
  __DBGpr_vec("normal", normal);
  __DBGpr_int("orient", orient);

  plane.normal = normal;
  plane.point  = pt2;
  sts = om$send(msg      = message GRvg.GRdetplane (
					&msg,
					&md_env.md_env.matrix_type,
					md_env.md_env.matrix,
					&plane	),
		senderid = NULL_OBJID,
		targetid = frmIDs[frmCnt-1].objid,
		targetos = frmIDs[frmCnt-1].osnum );
  if (!(sts & msg & 1)) {
	printf("GRvg.GRdetplane failed\n");
	goto wrapup ;
  }

  if( pt1[orient] > pt2[orient] ) {
	i = frmCnt - 1 ;
	delt = -1 ;
  }
  else {
	i = 0 ;
	delt = 1 ;
  }

  __DBGpr_int("frmCnt", frmCnt);
  __DBGpr_int("delt for frames", delt);

  fmn = frmMark ;
  fmx = frmMark ;
  cnt = 0 ;
  while( cnt < frmCnt ) {
	frmOE1.obj_id = frmIDs[i];
	frmOE1.mod_env = info->frmSysOE.mod_env;
	frmOE2.obj_id = frmIDs[frmCnt-i-1];
	frmOE2.mod_env = info->frmSysOE.mod_env;
	for( j = 0; j < info->cvCnt; j++) {
	    cvOE = info->cvList[j].cvOE;
	    intCnt = 0;
	    if(fmn == frmMark) {
		VDloftbk_getPlnCvInt(&frmOE1, &cvOE, &intCnt, &intIDs);

		for( l = 0; l < intCnt; l++) {
			gr$delete_object(msg		= &msg,
					object_id	= &intIDs[l]);
		}

		if(intCnt > 0) {
			__DBGpr_obj("frmOE1", frmOE1.obj_id);
			fmn = i ;
		}
		_FREE(intIDs);
	    }

	    intCnt = 0;
	    if(fmx == frmMark) {
		VDloftbk_getPlnCvInt(&frmOE2, &cvOE, &intCnt, &intIDs);

		for( l = 0; l < intCnt; l++) {
			gr$delete_object(msg		= &msg,
					object_id	= &intIDs[l]);
		}

		if( intCnt > 0 ) {
			fmx = frmCnt - i - 1;
			__DBGpr_obj("frmOE2", frmOE2.obj_id);
		}
		_FREE(intIDs);
	    }

	    if( fmn != frmMark && fmx != frmMark ) goto get_range;
	}

	i += delt ;
	cnt++ ;
  }
  
get_range:
  __DBGpr_int("fmn", fmn);
  __DBGpr_int("fmx", fmx);

  if( fmn > fmx ) {
	*fmax = fmn ;
	*fmin = fmx ;
  }
  else {
	*fmax = fmx ;
	*fmin = fmn ;
  }


  retFlag = 1 ;
wrapup:
  End
  return retFlag ;
}


/*-------------------------------------------------------------------
 * Get Intersections
 */
IGRstat	VDloftbk_getIntInfo( VDloftbkInfo	*info )
{
	IGRint	i, j, k, l ;
	IGRstat	retFlag = 0;
	IGRlong	sts, msg ;

	IGRint		frmCnt = 0, cvCnt = 0 ;
	IGRint		frmLow = 0, frmHigh = 0 ;
	IGRint		intCnt = 0;
	TGRid		*frmIDs = NULL, *intIDs = NULL, intID;
	IGRint		cnt = 0;
	IGRint		fmin, fmax, *frmNum = NULL, *intMaxCnt = NULL;
	IGRchar		sig[128] ;
	TGRobj_env	frmOE, cvOE;

	SetProc(VDloftbk_getIntersections); Begin
	intID.objid = NULL_OBJID;

	// Get frame system
	sts = om$send(msg	= message SMfrm_syst.SMfind_all_frame(
					&msg,
					&frmIDs,
					&frmNum,
					&frmCnt,
					&frmLow,
					&frmHigh ),
			senderid = NULL_OBJID,
			targetid = info->frmSysOE.obj_id.objid,
			targetos = info->frmSysOE.obj_id.osnum );
	if( !(sts & msg & 1) ) {
		printf("SMfrm_syst.SMfind_all_frame failed\n");
		goto wrapup ;
	}

	// Find frame range
	sts = VDloftbk_getFrmRangeFromCv(info, frmIDs, frmCnt, &fmin, &fmax);
	if( !sts ) {
		printf("VDloftbk_getFrmRangeFromCv() failed !\n");
		goto wrapup;
	}
	if( (fmax - fmin + 1) <= 1 ) goto wrapup;
  
	// Get intersections between curves and frame system

	cvCnt = info->cvCnt ;
	frmCnt = fmax - fmin + 1;

	for(j = 0; j < cvCnt; j++ ) {
		info->cvList[j].intIDs = _CALLOC(frmCnt, TGRid *);
		if(info->cvList[j].intIDs == NULL ) goto wrapup;
		info->cvList[j].intCnt = _CALLOC(frmCnt, IGRint);
		if(info->cvList[j].intCnt == NULL ) goto wrapup;
	}

	intMaxCnt = _CALLOC(frmCnt, IGRint);
	if(intMaxCnt == NULL ) goto wrapup;
	for(i = 0; i < frmCnt; i++) {
		intMaxCnt[i] = 0;
	}

	strcpy(sig, "Processing");

	for( j = 0; j < cvCnt; j++ ) {
		if((j%30) == 0 ) strcpy(sig, "Processing");
		strcat(sig, ".");
		UI_status(sig);
		FIg_set_text(info->form, FI_MSG_FIELD, sig);

		cnt = 0;
		cvOE = info->cvList[j].cvOE;

		// get intersections
		for( i = fmin; i <= fmax; i = i + 1 ) {
			frmOE.obj_id = frmIDs[i];
			frmOE.mod_env = info->frmSysOE.mod_env;

			intCnt = 0;
			intIDs = NULL;
			VDloftbk_getPlnCvInt(&frmOE, &cvOE, &intCnt, &intIDs);
			if(intCnt > 1) 
			  VDloftbk_sortIntPnts(intIDs, intCnt, info->format[0]);

			if(intMaxCnt[cnt] < intCnt) {
				intMaxCnt[cnt] = intCnt;
			}
			info->cvList[j].intIDs[cnt] = intIDs;
			info->cvList[j].intCnt[cnt] = intCnt;
			cnt++;
	  	}
	}

	info->frmIntCnt = frmCnt;
	info->frmNum = frmNum;
	info->intMaxCnt = intMaxCnt;
	info->fmin = fmin;
	info->fmax = fmax;


	retFlag = 1;
wrapup:
	_FREE( frmIDs ) ; 
	End
	return retFlag ;
}

IGRstat	VDloftbk_reportFrame (
	IGRint	flag, 		// I: if 0 report frame, else empty
	IGRint	frmFlag, 	// I: 0 Frame no., 1 frmae position
	IGRint	frmNo,	 	// I: Frame no.
	TGRid	frmSys,		// I: frame system id
	IGRchar	*report)	// O: frame number or position
{
	IGRstat		ret = 0;
	IGRlong		sts = 0, msg = 0;
	IGRdouble	frmPosition[6];
	IGRchar		text[128];
	TGRid		frmID;

	if(report == NULL || frmSys.objid == NULL_OBJID) goto wrapup;

	// empty case
	if( flag ) {
		sprintf(report, "%8s", " ");
		ret = 1;
		goto wrapup;
	}
	// report frame number
	if( !frmFlag ) {
		sprintf(report, "%8d", frmNo);
		ret = 1;
		goto wrapup;
	}

	// report frame position
	frmID.objid = NULL_OBJID;
	sts = om$send(	msg      = message SMfrm_syst.SMfind_frame_objid(
						&msg, frmNo, &frmID),
			senderid = NULL_OBJID,
			targetid = frmSys.objid,
			targetos = frmSys.osnum );
	if( !(sts&msg&1) || frmID.objid == NULL_OBJID) {
		sprintf(report, "%8s", "Unkown");
		goto wrapup;
	}

	sts = om$send(msg	= message SMframe.SMgive_rel_position(
					&msg, frmPosition),
		senderid = NULL_OBJID,
		targetid = frmID.objid,
		targetos = frmID.osnum );
	if( !(sts&msg&1) ) {
		sprintf(report, "%8s", "Unkown");
		goto wrapup;
	}

	sprintf(report, "%8.3f", (MTR*frmPosition[0]) );

	ret = 1;
wrapup:
	return ret;
}

/*-------------------------------------------------------------------
 * Output all intersetion points in format 1 or 5, WATERLINE HALF BREADTHS
 * or BUTTOCK HEIGHTS
 */
IGRstat	VDloftbk_printFormat1(
VDloftbkInfo	*info,
FILE		*file)
{
	IGRint		i, j, k, l ;
	IGRstat		retFlag = 0;
	IGRlong		sts, msg ;

	IGRint		*frmNum = NULL, *intMaxCnt = NULL;
	IGRint		frmCnt = 0, cvCnt = 0 ;
	IGRint		intCnt = 0;
	TGRid		*frmIDs = NULL, *intIDs = NULL, intID;
	IGRint		grp, grpCnt ;
	IGRint		grpSize, page, line = 0, cnt = 0;
	IGRint		fmin, fmax, orient;
	IGRchar		text[128], lineStr[1024], *ptr = NULL;
	IGRpoint	pnt, pt;
	

	SetProc( VDloftbk_printFormat1 ); Begin
	text[0] = '\0';
	lineStr[0] = '\0';

	if( info->format[0] == '1' ) {
		orient = 1;
	}
	else if(info->format[0] == '5' ) {
		orient = 2;
	}
	else {
		printf("Format error !\n");
		goto wrapup;
	}

	// Get intersection points
	sts = VDloftbk_getIntInfo(info);
	if(!sts) {
		printf("VDloftbk_getIntInfo failed\n");
		goto wrapup;
	}

	fmin = info->fmin;
	fmax = info->fmax;
	frmCnt = info->frmIntCnt;
	frmNum = info->frmNum;
	intMaxCnt = info->intMaxCnt;

	__DBGpr_int("frmCnt", frmCnt);
	__DBGpr_int("fmin  ", fmin);

	// Print intersection points

	cnt = 0; 
	cvCnt = info->cvCnt;
	page = info->startPage;
	grpSize = VDloftbk_COL_NUM ;
	grpCnt = ceil( (double)(cvCnt)/grpSize ) ;

	for(grp = 0; grp < grpCnt; grp++ ) {
		VDloftbk_printHeader1( file, info, page, grp, &cnt ) ;
		line += cnt;
		for( i = 0; i < frmCnt; i++ ) {
		    for(k = 0; k < intMaxCnt[i]; k++) {
			VDloftbk_reportFrame (	k, 
						info->frmFlag,  
						frmNum[fmin+i], 
						info->frmSysOE.obj_id, 
						lineStr);
			for(j = 0; j < grpSize && j+grp*grpSize < cvCnt; j++) {
			    if(k < info->cvList[j+grp*grpSize].intCnt[i]) {
				intID = info->cvList[j+grp*grpSize].intIDs[i][k];
				gr$get_endpoints(msg            = &msg,
                                                object_id       = &intID,
                                                point1          = pnt,
                                                point2          = pt);
				sprintf(text,"%10.3f", pnt[orient]*MTR);
			    }
			    else {
				sprintf(text,"%10s", " ");
			    }
			    strcat(lineStr, text);
			}
			if((ptr = strpbrk(&lineStr[DATA_START], ".")) == NULL) {
				lineStr[0] = '\0';
				continue;
			}
			strcat(lineStr, "\n"); line++;
			fprintf(file, lineStr);
			if(line == (info->rowCnt-3)) {
			   fprintf(file, "\n\n\n");
			   VDloftbk_printHeader1(file, info, ++page, grp, &cnt);
			   line = cnt; // reset line
			}
		    }
		}

		if( (grp+1) < grpCnt ) {
			lineStr[0] = '\0';
			for(i = 0; i < (info->rowCnt - line); i++) {
		       		strcat(lineStr, "\n");
                	}
			fprintf(file, lineStr);
			page++;
			line = 0;
		}
	}
			
	
	retFlag = 1 ;

wrapup:

	End
	return retFlag ;
}

/*-------------------------------------------------------------------
 * Output all intersetion points in format 2
 */
IGRstat	VDloftbk_printFormat2(
VDloftbkInfo	*info,
FILE		*file)
{
	IGRint		i, j, k, l ;
	IGRstat		retFlag = 0;
	IGRlong		sts, msg ;

	IGRint		*frmNum = NULL, *intMaxCnt = NULL;
	IGRint		frmCnt = 0, cvCnt = 0 ;
	IGRint		intCnt = 0;
	TGRid		*frmIDs = NULL, *intIDs = NULL, intID;
	IGRint		grp, grpCnt ;
	IGRint		grpSize, page, line = 0, cnt = 0;
	IGRint		fmin, fmax ;
	IGRchar		text[128], lineStr[1024], *ptr = NULL;
	IGRpoint	pnt, pt;
	

	SetProc( VDloftbk_printFormat2 ); Begin
	text[0] = '\0';
	lineStr[0] = '\0';
	intID.objid = NULL_OBJID;

	// Get intersection points
	sts = VDloftbk_getIntInfo(info);
	if(!sts) {
		printf("VDloftbk_getIntInfo failed\n");
		goto wrapup;
	}

	fmin = info->fmin;
	fmax = info->fmax;
	frmCnt = info->frmIntCnt;
	frmNum = info->frmNum;
	intMaxCnt = info->intMaxCnt;

	// Print intersection points
	cnt = 0; 
	cvCnt = info->cvCnt;
	page = info->startPage;
	grpSize = VDloftbk_COL_NUM/2 ;
	grpCnt = ceil( (double)(cvCnt)/grpSize ) ;

	for(grp = 0; grp < grpCnt; grp++ ) {
		VDloftbk_printHeader2( file, info, page, grp, &cnt ) ;
		line += cnt;
		for( i = 0; i < frmCnt; i++ ) {
		    for(k = 0; k < intMaxCnt[i]; k++) {
			VDloftbk_reportFrame (	k, 
						info->frmFlag,  
						frmNum[fmin+i], 
						info->frmSysOE.obj_id, 
						lineStr);
			for(j = 0; j < grpSize && j+grp*grpSize < cvCnt; j++) {
			    if(k < info->cvList[j+grp*grpSize].intCnt[i]) {
				intID = info->cvList[j+grp*grpSize].intIDs[i][k];
				gr$get_endpoints(msg            = &msg,
                                                object_id       = &intID,
                                                point1          = pnt,
                                                point2          = pt);
				sprintf(text,"%10.3f%10.3f", pnt[2]*MTR,pnt[1]*MTR);
			    }
			    else {
				sprintf(text,"%20s", " ");
			    }
			    strcat(lineStr, text);
			}
			if((ptr = strpbrk(&lineStr[DATA_START], ".")) == NULL) {
				lineStr[0] = '\0';
				continue;
			}
			strcat(lineStr, "\n"); line++;
			fprintf(file, lineStr);
			if(line == (info->rowCnt-3)) {
			   fprintf(file, "\n\n\n");
			   VDloftbk_printHeader2(file, info, ++page, grp, &cnt);
			   line = cnt; // reset line
			}
		    }
		}

		if( (grp+1) < grpCnt ) {
			lineStr[0] = '\0';
			for(i = 0; i < (info->rowCnt - line); i++) {
		       		strcat(lineStr, "\n");
                	}
			fprintf(file, lineStr);
			page++;
			line = 0;
		}

	}
			
	
	retFlag = 1 ;

wrapup:

	End
	return retFlag ;
}


/*-------------------------------------------------------------------
 * Output all intersetion points in format 3
 */
IGRstat	VDloftbk_printFormat3(
VDloftbkInfo	*info,
FILE		*file)
{
	IGRint		i, j, k, l ;
	IGRstat		retFlag = 0;
	IGRlong		sts, msg ;

	IGRint		*frmNum = NULL, *intMaxCnt = NULL;
	IGRint		frmCnt = 0, cvCnt = 0 ;
	IGRint		intCnt = 0;
	TGRid		*frmIDs = NULL, *intIDs = NULL, intID;
	IGRint		grp, grpCnt ;
	IGRint		grpSize, page, line = 0, cnt = 0;
	IGRint		fmin, fmax ;
	IGRchar		text[128], str[128], lineStr[1024], *ptr = NULL;
	IGRpoint	pnt, pt;
	

	SetProc( VDloftbk_printFormat3 ); Begin
	text[0] = '\0';
	lineStr[0] = '\0';
	intID.objid = NULL_OBJID;

	// Check center line and side curves for format 3
	sts = VDloftbk_checkClSide(info);

	// Get intersection points
	sts = VDloftbk_getIntInfo(info);
	if(!sts) {
		printf("VDloftbk_getIntInfo failed\n");
		goto wrapup;
	}

	fmin = info->fmin;
	fmax = info->fmax;
	frmCnt = info->frmIntCnt;
	frmNum = info->frmNum;
	intMaxCnt = info->intMaxCnt;


	// Print intersection points
	cnt = 0; 
	cvCnt = info->cvCnt;
	page = info->startPage;
	grpSize = VDloftbk_COL_NUM3 ;
	grpCnt = ceil( (double)(cvCnt)/grpSize ) ;

	for(grp = 0; grp < grpCnt; grp++ ) {
		VDloftbk_printHeader3( file, info, page, grp, &cnt ) ;
		line += cnt;
		for( i = 0; i < frmCnt; i++ ) {
		    for(k = 0; k < intMaxCnt[i]; k++) {
			VDloftbk_reportFrame (	k, 
						info->frmFlag,  
						frmNum[fmin+i], 
						info->frmSysOE.obj_id, 
						lineStr);
			for(j = 0; j < grpSize && j+grp*grpSize < cvCnt; j++) {
			    if(k < info->cvList[j+grp*grpSize].intCnt[i]) {
				intID = info->cvList[j+grp*grpSize].intIDs[i][k];
				gr$get_endpoints(msg            = &msg,
                                                object_id       = &intID,
                                                point1          = pnt,
                                                point2          = pt);
				sprintf(text,"%10.3f", pnt[2]*MTR);

				if((j%2) == 1) { 
				   sprintf(str,"%10.3f",pnt[1]*MTR);
				   strcat(text, str);
				}
					
			    }
			    else {
				sprintf(text,"%10s", " ");
				if((j%2) == 1) {
					sprintf(str,"%10s", " ");
					strcat(text, str);
				}
			    }
			    strcat(lineStr, text);
			}
			if((ptr = strpbrk(&lineStr[DATA_START], ".")) == NULL) {
				lineStr[0] = '\0';
				continue;
			}
			strcat(lineStr, "\n"); line++;
			fprintf(file, lineStr);
			if(line == (info->rowCnt-3)) {
			   fprintf(file, "\n\n\n");
			   VDloftbk_printHeader3(file, info, ++page, grp, &cnt);
			   line = cnt; // reset line
			}
		    }
		}

		if( (grp+1) < grpCnt ) {
			lineStr[0] = '\0';
			for(i = 0; i < (info->rowCnt - line); i++) {
		       		strcat(lineStr, "\n");
                	}
			fprintf(file, lineStr);
			page++;
			line = 0;
		}

	}
			
	
	retFlag = 1 ;

wrapup:
	End
	return retFlag ;
}


/*-------------------------------------------------------------------
 * Output all intersetion points in format 4
 */
IGRstat	VDloftbk_printFormat4(
VDloftbkInfo	*info,
FILE		*file)
{
	IGRint		i, j, k, l ;
	IGRstat		retFlag = 0;
	IGRlong		sts, msg ;

	IGRint		*frmNum = NULL, *intMaxCnt = NULL;
	IGRint		frmCnt = 0, cvCnt = 0 ;
	IGRint		intCnt = 0;
	TGRid		*frmIDs = NULL, *intIDs = NULL, intID;
	
	IGRpoint	pnt, pt;
	
	IGRint		grp, grpCnt ;
	IGRint		grpSize, page, line = 0, cnt = 0;
	IGRint		fmin, fmax ;
	IGRchar		text[128], str[128], lineStr[1024], *ptr = NULL;

	SetProc( VDloftbk_printFormat4 ); Begin

	text[0] = '\0';
	lineStr[0] = '\0';
	intID.objid = NULL_OBJID;

	// Get intersection points
	sts = VDloftbk_getIntInfo(info);
	if(!sts) {
		printf("VDloftbk_getIntInfo failed\n");
		goto wrapup;
	}

	fmin = info->fmin;
	fmax = info->fmax;
	frmCnt = info->frmIntCnt;
	frmNum = info->frmNum;
	intMaxCnt = info->intMaxCnt;

  
	// Print intersection points

	cnt = 0; 
	cvCnt =info->cvCnt;
	page = info->startPage;
	grpSize = VDloftbk_COL_NUM/2 ;
	grpCnt = ceil( (double)(cvCnt)/grpSize ) ;

	for(grp = 0; grp < grpCnt; grp++ ) {
		VDloftbk_printHeader4( file, info, page, grp, &cnt ) ;
		line += cnt;
		for( i = 0; i < frmCnt; i++ ) {
		    for(k = 0; k < intMaxCnt[i]; k++) {
			VDloftbk_reportFrame (	k, 
						info->frmFlag,  
						frmNum[fmin+i], 
						info->frmSysOE.obj_id, 
						lineStr);
			for(j = 0; j < grpSize && j+grp*grpSize < cvCnt; j++) {
			    if(k < info->cvList[j+grp*grpSize].intCnt[i]) {
				intID = info->cvList[j+grp*grpSize].intIDs[i][k];
				gr$get_endpoints(msg            = &msg,
                                                object_id       = &intID,
                                                point1          = pnt,
                                                point2          = pt);
				sprintf(text,"%10.3f%10.3f", pnt[2]*MTR,pnt[1]*MTR);
			    }
			    else {
				sprintf(text,"%20s", " ");
			    }
			    strcat(lineStr, text);
			}
			if((ptr = strpbrk(&lineStr[DATA_START], ".")) == NULL) {
				lineStr[0] = '\0';
				continue;
			}
			strcat(lineStr, "\n"); line++;
			fprintf(file, lineStr);
			if(line == (info->rowCnt-3)) {
			   fprintf(file, "\n\n\n");
			   VDloftbk_printHeader4(file, info, ++page, grp, &cnt);
			   line = cnt; // reset line
			}
		    }
		}

		if( (grp+1) < grpCnt ) {
			lineStr[0] = '\0';
			for(i = 0; i < (info->rowCnt - line); i++) {
		       		strcat(lineStr, "\n");
                	}
			fprintf(file, lineStr);
			page++;
			line = 0;
		}

	}
			
	
	retFlag = 1 ;

wrapup:
	End
	return retFlag ;
}


/* --------------------------------------
 * Misc stuff
 */
#argsused
IGRlong	VDloftbk_init( VDloftbkInfo *info)
{
	IGRlong		retFlag = 0, msg;

	memset(info,0,sizeof(VDloftbkInfo));

	info->frmSysOE.obj_id.objid = NULL_OBJID;
	info->cvList		= NULL;
	info->frmNum		= NULL;
	info->intMaxCnt		= NULL;
	info->cvCnt		= 0;
	info->fmin		= 0;
	info->fmax		= 0;
	info->frmIntCnt		= 0;
	info->header[0]		= '\0';
	info->format[0]		= '\0';
	info->prefix[0]		= '\0';;
	info->filename[0]	= '\0';;
	info->startPage		= 1;
	info->rowCnt		= 50;
	info->date_title_page[0]	= '\0';
	
	dp$erase_hilite(msg = &msg);

	retFlag = 1;
wrapup:
	return retFlag;
}

#argsused
IGRlong	VDloftbk_sleep(VDloftbkInfo *info)
{
	IGRint msg;
	
	if (info->form) FIf_erase(info->form);

	dp$erase_hilite(msg = &msg);

	return 1;
}

#argsused
IGRlong	VDloftbk_wakeup(VDloftbkInfo *info)
{
	return 1;
}

#argsused
IGRlong VDloftbk_delete(VDloftbkInfo *info)
{
	IGRlong		retFlag = 0, msg;
	IGRint		i, j, k;
	IGRchar		sig[128];

	SetProc(VDloftbk_delete); Begin

	strcpy(sig, "Processing");
	for( i = 0; i < info->cvCnt; i++ ) {
		if((i%30) == 0 ) strcpy(sig, "Processing");
		strcat(sig, ".");
		UI_status(sig);
		FIg_set_text(info->form, FI_MSG_FIELD, sig);

		for( j = 0; j < info->frmIntCnt; j++ ) {
			for(k = 0; k < info->cvList[i].intCnt[j]; k++) {
			  gr$delete_object(
				msg	  = &msg,
				object_id = &info->cvList[i].intIDs[j][k]);
			}
			_FREE(info->cvList[i].intIDs[j]);
		}
		_FREE(info->cvList[i].intIDs);
		_FREE(info->cvList[i].intCnt);
	}

	_FREE(info->cvList);
	_FREE(info->frmNum);
	_FREE(info->intMaxCnt);
	info->cvCnt		= 0;
	info->fmin		= 0;
	info->fmax		= 0;
	info->frmIntCnt		= 0;
	info->header[0]		= '\0';
	info->format[0]		= '\0';
	info->prefix[0]		= '\0';;
	info->filename[0]	= '\0';;
	info->startPage		= 1;
	info->rowCnt		= 50;
	info->date_title_page[0]	= '\0';
	

	End
	return 1;
}

end implementation Root;
