/* $Id: VDureflib.I,v 1.6 2002/06/10 19:29:36 jdsauby Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/cmd / VDureflib.I
 *
 * Description: List updated reference files and attached libraries.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDureflib.I,v $
 *	Revision 1.6  2002/06/10 19:29:36  jdsauby
 *	JTSMP TR6425
 *	
 *	Revision 1.5  2001/08/01 21:56:56  ramarao
 *	Fixed TR# 5480.
 *	
 *	Revision 1.4  2001/03/23 21:43:03  ramarao
 *	Fixed a crash.
 *	
 *	Revision 1.3  2001/03/12 18:40:20  ramarao
 *	Check Symbol macro libraries.
 *	
 *	Revision 1.2  2001/01/22 16:08:49  ahundiak
 *	sp merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/09/27  22:23:12  pinnacle
# Replaced: vds/vdstartup/imp/VDureflib.I for:  by aharihar for Service Pack
#
# Revision 1.1  2000/09/20  18:37:44  pinnacle
# Created: vds/vdstartup/imp/VDureflib.I by aharihar for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/08  22:35:08  pinnacle
# Replaced: vdstartup/imp/VDureflib.I for:  by mdong for vds
#
# Revision 1.3  1998/02/11  23:50:56  pinnacle
# Replaced: vdstartup/imp/VDureflib.I for:  by lawaddel for vds
#
# Revision 1.2  1997/09/30  16:56:06  pinnacle
# Replaced: vdstartup/imp/VDureflib.I for:  by lawaddel for vds
#
# Revision 1.1  1997/09/16  20:03:28  pinnacle
# Created: vdstartup/imp/VDureflib.I by lawaddel for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/27/97	law		created for 2.5.0 (CR179701052)
 *	09/30/97	law		simplified program interface.
 *      02/11/98        law             TR179800118- Crashing or hanging w/ new file
 *      04/08/98        Ming            TR179800800
 *      09/20/2k        Anand           Implemented function VDSchkMissRefFiles
 *      01/22/01        ah              sp merge
 *	03/12/01	Rama Rao	Added Symbol Macro Checking.
 * -------------------------------------------------------------------*/

class implementation VDCmdStrtup ;


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <FI.h>
#include <sys/types.h>
#include <dirent.h>
#include <OMOSfilehdr.h>
#include "DIdef.h"

/* Below include files added by Anand */
#include "OMindex.h"
#include "OMminimum.h"
#include "ref.h"
#include "refdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VDmem.h"
/* Above include files added by Anand */

/*********************/

#       include "igetypedef.h"
#       include "igrtypedef.h"
#       include "igrdef.h"              /* Constants IGR??              */
#       include "igr.h"                 /* Structs IGR* for geometries  */
#       include "igrdp.h"               /* Structs IGR* for display     */
#       include "gr.h"                  /* Structs GR* for graphic info */
#       include "godef.h"               /* Constants GR* for graphics   */
#       include "go.h"                  /* Struct GR* for graphics      */
#       include "griodef.h"             /* Constants for graphic I/O    */
#       include "grio.h"                /* Structs for graphic I/O      */
#	include "griomacros.h"

/*********************/
#include "exmacros.h"

#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "grlicense.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "VDmsg.h"
#include "vdprdmacros.h"
#include "GRtypedef.h"
#include "vdrefmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"


/*
 * Includes of function prototypes.
 */
%safe
#include <VX_FIproto.h>
%endsafe

/*
 * "Update dependency of reference files" form.
 */
#define VDS_UPDREFLIB_FORM	"VDSupdRefLib"
#define VD_MAX_RefLibBuff       1024

extern int	UI_error			__(( char * )) ;
extern long	ASsuper_construct		__(( void )) ;
extern void	VDsuper_construct		__(( void )) ;
extern void	VDSet_SUper_construct		__(( void )) ;
extern int	SMAddToPocketMenu		__(( void )) ;
extern int	VDSnopdu_init			__(( void )) ;
extern int	VDSudp_init			__(( void )) ;
extern int	ACcond_CLEAR    		__(( void )) ;

struct vdfile_struct
{
    int inuseflg; /* 0 = no file loaded */
    char filename[OM_K_MAXOSNAME_LEN];
    char filepath[MAXPATHLEN];
    char filepathname[OM_K_MAXOSNAME_LEN];
    OMuword osnum; /* -1 = not loaded */
    char modcaldate[26];
    IGRdouble moddecdate;
    char product[8];
};

from super_para import give_path_size;
from super_para import give_path;

from Super_rfmgr import GRget_channel_count;
from Super_rfmgr import GRget_channel_objects;
from GRreffile	 import GRgetobjinfo;
from GRreffile	 import GRinquireref;

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/

int VDdispfiledat()
{

IGRint  num_ref = 0, row,
        num_libs = 0 ;
IGRint fileupd, ifile;
int     rc;
IGRdouble actdate;
void VDSchkMissRefFiles(void);
struct vdfile_struct *VDactfile = NULL ;
struct vdfile_struct *VDreffile = NULL ;
struct vdfile_struct *VDlibfile = NULL ;

/***********************************************************************/

   VDSchkMissRefFiles(); // Function call placed by Anand

   rc = VDgetfilestat(&num_ref,&num_libs,&VDactfile,&VDreffile,&VDlibfile);
   fileupd = FALSE;
    /* TR179800118 */
   if(VDactfile)
     actdate = VDactfile->moddecdate;
   else
   {
     rc = 1 ;
     goto wrapup ;
   }

   if( VDreffile )
   {
      for (ifile = 0; ifile < num_ref; ifile++)
      {
         if((VDreffile+ifile)->moddecdate > actdate)
            fileupd = TRUE;
      }
   }
   if( VDlibfile )
   {
      for (ifile = 0; ifile < num_libs; ifile++)
      {
         if((VDlibfile+ifile)->moddecdate > actdate)
            fileupd = TRUE;
      }
   }

   if(fileupd)
      rc = VDSupdChkRefLibForm();

   for( row = 0 ; row < num_ref ; row++ )
   {
       if( !strcmp( VDactfile->filename, VDreffile[row].filename ) )
       {
          EX_error_box( FI_CURRENT_SCREEN, 
			"Current File is attached directly as reference file",
			"WARNING" );
          break;
       }
   }

wrapup:
   _FREE(VDactfile);
   _FREE(VDreffile);
   _FREE(VDlibfile);

return (rc);
}

/* Below function implemented by Anand (Sept 20, 2k) */

void VDSchkMissRefFiles(void)
{
    IGRlong		status,sts;
    IGRshort		count_nested;
    GRobjid		*objlist=NULL;
    GRspacenum		*oslist =NULL;
    IGRint		i;
    IGRlong		count,count_returned;
    IGRulong		Super_id, prop_mask;
    struct GRobj_info	refinfo;
    struct GRmd_env	mod_env;
    struct GRinquire_list requests[2];
    IGRboolean		ref_file_found;

    SetProc( VDSchkMissingRefFiles ); Begin

    gr$get_module_env( buffer = &mod_env );

    /*| Get id of ref manager */
    status = ex$get_objid_from_NOD( NODname   = "IGENOD",
				    objname   = "Ref Mgr",
				    pobjid    = &Super_id,
				    modid     = mod_env.md_id.objid,
				    mod_osnum = mod_env.md_id.osnum);
    __DBGpr_int(" Refmgr id",(int)Super_id);
    if( !(status&1) ) goto wrapup ;

    /*| Get count of reference file */
    prop_mask = 0;
    count_nested = 1; // Mask needs to be set to get nested reference files
    count = 0;
    status= om$send( msg      = message Super_rfmgr.GRget_channel_count
				    (&sts, &prop_mask, &count_nested, &count),
		     senderid = NULL_OBJID,
		     targetid = Super_id,
		     targetos = mod_env.md_id.osnum );
    if( !(sts&1) || !count ) goto wrapup ;
    __DBGpr_int(" count from GRget_channel_count",count);

    objlist = _CALLOC( count, GRobjid );
    __CheckPtr( objlist, "Alloc of objlist failed",wrapup);
    oslist  = _CALLOC( count, GRspacenum );
    __CheckPtr( oslist,  "Alloc of oslist failed", wrapup);

    status =
    om$send(msg      = message Super_rfmgr.GRget_channel_objects
				    (&sts, &prop_mask, &count_nested, &count,
				     objlist, oslist, &count_returned),
	    senderid = NULL_OBJID,
	    targetid = Super_id,
	    targetos = mod_env.md_id.osnum );
    if( !(status&1) || !(sts&1) || !count_returned ) goto wrapup ;
    __DBGpr_int(" count returned from GRget_channel_objects", count_returned);

    /* Prepare GRinquire_list structure for the fetching needed info */
    requests[0].var = REFERENCE_FILE_FOUND;
    requests[0].var_ptr = (char *)&ref_file_found;
    requests[0].num_requested = sizeof(IGRboolean);

    requests[1].var = END_REPORT_REQUEST;
    requests[1].var_ptr = NULL;
    requests[1].num_requested = 0;

    for( i=0 ; i<count_returned ; i++ )
    {
	IGRchar	FileName[64];
	IGRint	num_lines;

	__DBGpr_int(" Objlist",objlist[i]);
	__DBGpr_int(" Oslist ",oslist[i] );

	status =
	om$send( msg      = message GRreffile.GRgetobjinfo( &sts, &refinfo ),
		 senderid = NULL_OBJID,
		 targetid = objlist[i],
		 targetos = oslist[i] );
	if( !(status&1) || !(sts&1) ) continue ;

	strncpy( FileName, refinfo.type, strcspn(refinfo.type,","));
	FileName[strcspn(refinfo.type,",")]='\0';
	__DBGpr_str(" file name",FileName);

	count=0; // Just give it a pointer to a variable filled with zero.
	status =
	om$send( msg      = message GRreffile.GRinquireref( &sts, &mod_env,
							    requests,
							    (IGRint *)&count,
							    (short  *)&count,
							    NULL ),
		 senderid = NULL_OBJID,
		 targetid = objlist[i],
		 targetos = oslist[i] );
	if( !(status&1) || !(sts&1) ) continue ;

	if( ! ref_file_found )
	    EX_error_box( FI_CURRENT_SCREEN, FileName,
					      "* MISSING REFERENCE FILE *");
    }

    /*| Free locals allocated ptrs */
    if (objlist) _FREE( objlist ); objlist  = NULL;  //TR6425
    if (oslist)  _FREE( oslist );  oslist   = NULL;  //TR6425

    End
    return;

wrapup:

    /*| Free locals allocated ptrs */
    if (objlist) _FREE( objlist ); objlist = NULL;  //TR6425
    if (oslist)  _FREE( oslist  ); oslist  = NULL;  //TR6425

    End
    return;

}

/* Above function implemented by Anand (Sept 20, 2k) */


void VDSchkRefLibNotification( form_label, gadget, value, form )

int	form_label ;
int	gadget ;
double	value ;
char	*form ;
{
	long	msg ;
	int	resp;
	double	ddummy;
	int	idummy;

	SetProc( VDSchkRefLibNotification ); Begin

	ddummy = value;
	idummy = form_label;
 
	switch( gadget ) {
		case FI_ACCEPT	:

			/* No break on purpose */

		case FI_CANCEL	:
			FIf_delete( form ) ;
			resp =  EX_FORM_FINISHED ;
			ex$putque(	msg	= &msg,
					response= &resp ) ;
			break ;

		default	:
			break ;
	}

	End ;
	return;

} /* VDSchkRefFilesNotification */
/*----------------------------------------------------------------------------*/
int VDSupdChkRefLibForm()

{
/*	extern  OM_p_OSD *OM_GA_OSDs; */
	extern void VDSchkRefLibNotification();
	extern int FIfld_set_num_rows();
	extern int FIf_display();
	extern int FIf_set_notification_routine();
	extern int FIf_new();

	char		*form ;
        int             rc,
			textMode;
	IGRint		lineno ,
			row ,
			num_ref=0 ,
			i, outdated_lib=0, libCnt=0,int_sts,
			num_libs=0;   /* TR179800118 */
        double          actdate,
                        refdate,
                        libdate;
        char		osdate[26]={"\0"};   /* TR179800118 */
	char		pwd_name[DI_PATH_MAX], cur_path[DI_PATH_MAX], *p,
			**libNames=NULL;
	OMuword		actosnum;
	GRobjid		actobjid;
        GRname          buffer;

	struct vdfile_struct *VDactfile = NULL;
	struct vdfile_struct *VDreffile = NULL;
	struct vdfile_struct *VDlibfile = NULL;
	IGRint  response,status;
        char    response_data[256]={"\0"};  /* TR179800118 */
        long    msg, done = 0;
	struct GRevent  event;

/****************************************************************************/
	SetProc( VDSupdChkRefLibForm ); Begin

	rc=VDgetfilestat(&num_ref,&num_libs,&VDactfile,&VDreffile,&VDlibfile);

	__DBGpr_com(" FIf_new VDS_UPDREFLIB_FORM ");

	rc = FIf_new(	0,
			VDS_UPDREFLIB_FORM,
			VDSchkRefLibNotification,
			&form ) ;
         /* TR179800118 */
        if(VDactfile->osnum == 0)
        {
           FIg_set_text( form, 10, 
               "A new file must be saved before using this command" ) ;
           FIf_display(form);
           goto wrapup;
        }
        FIg_set_text( form, 10, 
           " ** Files updated more recently than active design file" ) ;

	if (VDactfile) {  //TR6425
	    actdate = VDactfile->moddecdate;
	    strcpy(osdate,VDactfile->modcaldate);

	    __DBGpr_com(" output active os info to form field 23");
	    rc = FIfld_set_num_rows( form, 23, 1 ) ;
	    FIfld_set_text(	form,23,0,0,VDactfile->filename,FALSE ) ;
	    FIfld_set_text(	form,23,0,1,VDactfile->product,FALSE ) ;
	    FIfld_set_text(	form,23,0,2,&osdate[4],FALSE ) ;
	    FIfld_set_text(	form,23,0,3,VDactfile->filepath,FALSE ) ;
	}

/* forms giving back unpredictable status */
/*	if( rc != FI_SUCCESS ) goto wrapup ; */

	/* Output a new line to the form */
        if(num_libs)  /* TR179800118 */
           rc = FIfld_set_num_rows( form, 14, num_libs ) ;

        ex$get_cur_mod( id      = &actobjid,
                        osnum   = &actosnum );

        di$pwd( dirname = pwd_name );

        di$give_pathname( osnum    = actosnum,
                          pathname = cur_path );

        strcat( cur_path, ":models_lib" );

        int_sts = di$cd ( dirname = cur_path );

	if( int_sts == DIR_S_SUCCESS )
	{
           di$ls( lines = &libNames,  ptr = &libCnt );

	   di$cd ( dirname = pwd_name );
	}
	else	libCnt = 0;

	for( i=0; i<libCnt; ++i )
	{
	    libNames[i][strlen(libNames[i])-1] = '\0' ;
	    p = strrchr( libNames[i],':' );
	    if(p) { strcpy( libNames[i], p+1 ); }
	}

	if (VDlibfile) {  //TR6425
	    for(lineno = 0; lineno<num_libs; lineno++)
	    {
		libdate = (VDlibfile+lineno)->moddecdate;
		__DBGpr_dbl ("libdate ",libdate);
		strcpy(osdate,(VDlibfile+lineno)->modcaldate);

		if( outdated_lib == FALSE )
		{
		    for( i=0; i<libCnt; ++i )
		    {
			if( !strcmp( libNames[i], (VDlibfile+lineno)->filename ) )
			{
			    outdated_lib = TRUE;
			    break;
			}
		    }
		}

		if(libdate > actdate)
		{
		    textMode   = TRUE ;
		    sprintf( buffer, "**%s", (VDlibfile+lineno)->filename );
		    __DBGpr_str(" file update ", (VDlibfile+lineno)->filename );
		}
		else
		{
		    textMode   = FALSE ;
		    sprintf( buffer, "%s", (VDlibfile+lineno)->filename );
		    __DBGpr_str(" file OK ", (VDlibfile+lineno)->filename );
		}

		__DBGpr_com(" output library info to form field 14");
		FIfld_set_text( form, 14, lineno, 0,
			buffer, textMode ) ;

		FIfld_set_text( form, 14, lineno, 1,
			(VDlibfile+lineno)->product, textMode ) ;

		FIfld_set_text( form, 14, lineno, 2,
			&osdate[4], textMode );

		FIfld_set_text( form, 14, lineno, 3,
			(VDlibfile+lineno)->filepath, textMode ) ;
	    }
	}

        if(num_ref) /* TR179800118 */
           rc = FIfld_set_num_rows( form, 13, num_ref ) ;
/*          if( rc != FI_SUCCESS ) goto wrapup ; */

	rc = FI_SUCCESS;

	if (VDreffile) {  //TR6425
	    for( row = 0 ; row < num_ref ; row++ )
	    {
		strcpy(osdate,(VDreffile+row)->modcaldate);
		refdate = (VDreffile+row)->moddecdate;

		if(refdate > actdate)
		{
		    textMode   = TRUE ;
		    sprintf( buffer, "**%s", (VDreffile+row)->filename );
		}
		else
		{
		    textMode   = FALSE ;
		    sprintf( buffer, "%s", (VDreffile+row)->filename );
		}

		__DBGpr_com(" output reference os info to form field 13");
		FIfld_set_text( form, 13, row, 0,
			buffer, textMode ) ;

		FIfld_set_text( form, 13, row, 1,
			(VDreffile+row)->product, textMode ) ;

		FIfld_set_text( form, 13, row, 2,
			&osdate[4], textMode );

		FIfld_set_text( form, 13, row, 3,
			(VDreffile+row)->filepath, textMode ) ;
	    }
	}
	/*
	 * NOTE: FIf_display will fail if the quiet mode is ON, eg. I/VDS
	 * is run in batch mode.
	 */
        rc = FIf_display(form);

        rc = FI_SUCCESS;

	if( rc != FI_SUCCESS ) goto wrapup; /* get rid of compile warnings */
        /*  Loop until user dismisses the form *****/
        status = 1;
	do
        {
	  done = 0;
          response = 0;

          status = status &
                        co$getevent ( msg      = &msg,
                        event_mask      = (long) ( EX_RJT_MOVEON |
						   EX_DATA | CLEAR_STACK |
                                                   EX_FORM_FINISHED ),
                        prompt          = "File Modification Dates",
                        event           = &event,
                        response        = &response,
                        response_data   = response_data);
          if ( (response == EX_RJT_MOVEON) ||
               (response == EX_DATA      ) ||
               (response == CLEAR_STACK  ) ||
               (response == TERMINATE    ) )
          {
			FIf_delete( form ) ;
			response =  EX_FORM_FINISHED ;
			ex$putque(	msg	= &msg,
					response= &response ) ;
          }
          else if (response == EX_FORM_FINISHED)

            {
              done = 1;
              continue;
            }
	} while ( !done ) ;

	if( outdated_lib )
	{
	  EX_error_box( FI_CURRENT_SCREEN, "ci=COz_chkSym",
			"Symbol Macros may be outdated. Run the ppl" );
	}

	wrapup :
		if( rc != FI_SUCCESS ) {
			if( form ) FIf_delete( form ) ;
			rc = FALSE ;
		} else	rc = TRUE ;

	        if( libNames )
		{
		   di$free( lines = libNames, count = libCnt );
		}
		_FREE(VDactfile);
		_FREE(VDreffile);
		_FREE(VDlibfile);

		End ;
		return rc;

} /* VDSupdChkRefFilesForm */
/****************************************************/
/**************************************************************/
/* Output file statistics for active OS, reference files, and libraries */

int VDgetfilestat(num_ref,num_libs,VDoactfile,VDoreffile,VDolibfile)
IGRint *num_ref,*num_libs;
struct vdfile_struct **VDoactfile;
struct vdfile_struct **VDoreffile;
struct vdfile_struct **VDolibfile;

{
	extern  OM_p_OSD *OM_GA_OSDs;

	struct  GRid    superId;

struct vdfile_struct *VDactfile;
struct vdfile_struct *VDreffile;
struct vdfile_struct *VDlibfile;
        int refCount ;
        OMuword		*refList ;
        OMuword		actosnum;
        OM_S_OBJID	actobjid;
	IGRint		rc,
			i ,
			j ,
			size,
                        chr ,
			status ,
                        lstslsh ,
                        not_complete ,
                        not_finished ,
                        file_found ,
			namendx ,
			namlng ,
			numlib ,
                        no_commas,
                        no_libs,
			row ;
        double          actdate,
                        refdate,
                        libdate;
        FILE            *f = NULL ;
        char		osname[OM_K_MAXOSNAME_LEN],
                        osdate[26],
        		actfilnam[OM_K_MAXOSNAME_LEN],
                        liblstbuff[VD_MAX_RefLibBuff],
        		previous[OM_K_MAXOSNAME_LEN],
                        pathname[MAXPATHLEN];

        IGRlong msg;
        struct OM_sd_OS_filehdr_OM      buffer ;

/****************************************************************************/
	SetProc( VDgetfilestat ); Begin

        VDactfile = NULL;
        VDreffile = NULL;
        VDlibfile = NULL;

        ex$get_cur_mod( id      = &actobjid,
                        osnum   = &actosnum );

	__DBGpr_int(" Active OSNUM ", actosnum );

        rc =
        vd$get_ref_os_list(     msg             = &msg ,
                                main_os         = &actosnum,
                                num_ref_os      = &refCount,
                                ref_os_list     = &refList );
        if( !(rc&1) ){ goto wrapup ; };

/*        *num_ref = refCount; */
        VDactfile = NULL;
        VDactfile = _CALLOC(1,struct vdfile_struct);
	__CheckPtr( VDactfile,  "Alloc of VDactfile failed", wrapup);  //TR6425
        om$os_number_to_name(	osnum = actosnum,
       				osname  = actfilnam ) ;
        strcpy(pathname,OM_GA_OSDs[actosnum]->name);
	__DBGpr_com ("Read active os file header ");
        f = (FILE *) fopen ( pathname, "r" );
        if( f )
        {
          status =
                fread( &buffer, (sizeof(struct OM_sd_OS_filehdr_OM )) , 1, f);
	  __DBGpr_com(" fread OM_sd_OS_filehdr_OM ");
          fclose( f );
        } /* IF MYMAGIC */
        else
          goto wrapup;
 
        __DBGpr_com("Get file mod date for active os");
        strcpy( osdate,buffer.stop_time);
        /* if date later than curr-os date */
        __DBGpr_com("Convert to decimal date");
        status = VDann_cal_tick (osdate,&actdate);
	__DBGpr_com(" VDann_cal_tick done ");
        __DBGpr_com("Separate pathname from filename");
        lstslsh = -1;
        not_finished = TRUE;
        for(chr=0; not_finished; chr++)
        {
          if(pathname[chr] == '\0')
            not_finished = FALSE;
          else if(pathname[chr] == '/')
            lstslsh = chr;
        }
        if(lstslsh != -1)
          pathname[lstslsh] = '\0';

        __DBGpr_com(" output active os info into structure");

        VDactfile->inuseflg = 1;
        strcpy(VDactfile->filename,&pathname[lstslsh+1]);
        strcpy(VDactfile->filepath,pathname);
        strcpy(VDactfile->filepathname,OM_GA_OSDs[actosnum]->name);
        VDactfile->osnum = actosnum;
        strcpy(VDactfile->modcaldate,osdate);
        VDactfile->moddecdate = actdate;
        strcpy(VDactfile->product,&buffer.image_name[0]);

        superId.objid = NULL_OBJID ;
        rc =
        ex$get_super(         create          = 0,
                              mod_id          = actobjid,
                              mod_osnum       = actosnum,
                              super_name      = "super_para",
                              super_class     = "super_para",
                              super_id        = &(superId.objid),
                              super_osnum     = &(superId.osnum) );

        __DBGpr_int(" get_super status ",rc);
        __DBGpr_obj("superobjid " ,superId);
        numlib = 0;
        if( rc&1 )
        {
	   size = 0 ;
           rc =
           om$send(msg = message super_para.give_path_size( &size ),
		   senderid = NULL_OBJID,
                   targetid = superId.objid,
                   targetos = superId.osnum );
	   __DBGpr_int(" SIZE of lib-list buffer", size );

           if( rc&1 || size < VD_MAX_RefLibBuff )
           {
             rc = om$send(msg = message super_para.give_path(liblstbuff ),
		         senderid = NULL_OBJID,
                         targetid = superId.objid,
                         targetos = superId.osnum );
             if( rc&1 )
             {
                __DBGpr_str("liblist ", liblstbuff);
                __DBGpr_com
                    ("Separate and Process macro libraries of active file");
                /* Count the libraries */
                no_commas = 0;
                not_finished = TRUE;
                for(chr=0;not_finished;chr++)
                {
                  if(liblstbuff[chr] == '\0')
                     not_finished = FALSE;
                  else if(liblstbuff[chr] == ',')
                     no_commas++;
                }
		if(liblstbuff[0] == '\0')
                {
		  no_libs = 0;
		  numlib = 0;
                  VDlibfile = NULL;
                }
		else
		{
		  no_libs = no_commas + 1;
		  VDlibfile = _CALLOC(no_libs,struct vdfile_struct);
		  __CheckPtr( VDlibfile,  "Alloc of VDlibfile failed", wrapup);  //TR6425
		}
                not_finished = TRUE;
                namendx = 0;
                namlng = 0;
                while(not_finished)
                {
                  if(liblstbuff[namendx] == '\0')
                    not_finished = FALSE;
                  else
                  {
                     __DBGpr_com("Parse the list of libraries");
                     chr = namendx;
                     while ((liblstbuff[chr] != ',') &&
                            (liblstbuff[chr] != '\0'))
                     {
                        chr = chr + 1;
                     }
                     if(liblstbuff[chr] == '\0')
                       not_finished = FALSE;
                     else
                       liblstbuff[chr] = '\0';

                     __DBGpr_str("new filename ",&liblstbuff[namendx]);
                     /* Process namendx */                         
                     __DBGpr_com("Match the file name to OM_GA_OSDs");
                     file_found = -1;
		     for( i = 0; (i < OM_Gw_maxOS)&&(file_found == -1); i++)
                     {
	               /* pull pathname from OM_GA_OSDs */
                       if(! OM_GA_OSDs[i])
                         not_finished = FALSE;
                       else if(! OM_GA_OSDs[i]->name[0])
                         not_finished = FALSE;

                       if(not_finished)
                       {
                          __DBGpr_str("osfilename ",OM_GA_OSDs[i]->name);
                          strcpy(pathname,OM_GA_OSDs[i]->name);
                          __DBGpr_com("Separate pathname from filename");
                          /* look for last slash in path */
                          lstslsh = -1;
                          not_complete = TRUE;
                          for(j=0; not_complete; j++)
                          {
                            if(pathname[j] == '\0')
                              not_complete = FALSE;
                            else if(pathname[j] == '/')
                              lstslsh = j;
                          }
                          if(lstslsh != -1)
                            pathname[lstslsh] = '\0';
                          namlng = strlen(&pathname[lstslsh + 1]);

                          __DBGpr_str(" refname ",&pathname[lstslsh + 1]);

                          if((liblstbuff[namendx+namlng] != ',') && 
                             (liblstbuff[namendx+namlng] != '\0'))
                            file_found = -1;
                          else if( ! strncmp(&pathname[lstslsh + 1],
                                             &liblstbuff[namendx],namlng))
                            file_found = i;

                          __DBGpr_int ("library-os-index ",file_found);
                       }
                    }
/*  COULD NOT GET TO WORK !!!!!!!!! 
                    if(file_found == -1)
                    {
                      strncpy((VDlibfile+numlib)->filename,
                                                &liblstbuff[namendx],namlng);
                      (VDlibfile+numlib)->inuseflg = 0;
                      numlib++;
                    }
*/
                    if(file_found != -1)
                    {
                       __DBGpr_com("Process library entry on form");
                       /* Check the date on the file */
                       f = (FILE *)
                          fopen ( OM_GA_OSDs[file_found]->name, "r" );
                       /* read header */
                       if( f )
                       {
                          status = fread( &buffer,
                               (sizeof(struct OM_sd_OS_filehdr_OM )) , 1, f);
                          fclose( f );
                          /* Output a new line to the form */
                          /* strip off date */
                          strcpy( osdate,buffer.stop_time);
                          /* if date later than curr-os date */
                          status = VDann_cal_tick (osdate,&libdate);
                          /* set output color */
                          __DBGpr_dbl ("libdate ",libdate);
                          __DBGpr_com(" output library info to structure");

                          strcpy((VDlibfile+numlib)->filename,
                                                         &pathname[lstslsh+1]);
                          strcpy((VDlibfile+numlib)->filepath,pathname);
                          strcpy((VDlibfile+numlib)->filepathname,
                                                OM_GA_OSDs[file_found]->name);
                          (VDlibfile+numlib)->osnum = file_found;
                          strcpy((VDlibfile+numlib)->modcaldate,osdate);
                          (VDlibfile+numlib)->moddecdate = libdate;
                          strcpy((VDlibfile+numlib)->product,
                                                        &buffer.image_name[0]);
                          (VDlibfile+numlib)->inuseflg = 1;
                          numlib++;
                       } /* IF MYMAGIC */
                     }
                     namendx = chr + 1;
                     __DBGpr_int ("next name index ",namendx);

                    }
                }
             } /* end om-send  success */
           } /* pathsize */
        } /* Get super */
        *num_libs = numlib;

	VDreffile = NULL;
	if(refCount > 0) {
           VDreffile = _CALLOC(refCount,struct vdfile_struct);
	   __CheckPtr( VDreffile,  "Alloc of VDreffile failed", wrapup);  //TR6425
	}
	rc = OM_S_SUCCESS;
	*previous = '\0' ;
	for( i = 0 , row = 0 ; i < refCount ; i++ )
        {
	   /*
	    * Do not display same name of reference file, in case we have
	    * a multiple attachment of the same file.
	    */
	    om$os_number_to_name(	osnum   = refList[i],
        				osname  = osname ) ;
	    for( j=0; j<i; j++ )
            {
		om$os_number_to_name( osnum   = refList[j],
				      osname  = previous );
		if( !strcmp( previous, osname ) ) break ;
	    }
	    if( j<i ) continue;
            /* Pathname extension goes here */
            not_finished = TRUE;
            /* pull pathname from OM_GA_OSDs */
            strcpy(pathname,OM_GA_OSDs[refList[i]]->name);
            /* look for last slash in path */
            lstslsh = -1;
            for(chr=0; not_finished; chr++)
            {
               if(pathname[chr] == '\0')
                 not_finished = FALSE;
               else if(pathname[chr] == '/')
                 lstslsh = chr;
            }

            /* open file */
            f = (FILE *) fopen ( pathname, "r" );
                /* read header */
            if( f )
            {
              status =
                fread( &buffer, (sizeof(struct OM_sd_OS_filehdr_OM )) , 1, f);
                fclose( f );
            } /* IF MYMAGIC */
 
            /* strip off date */
            strcpy( osdate,buffer.stop_time);
            /* if date later than curr-os date */
            /* change output color */
            status = VDann_cal_tick (osdate,&refdate);
            __DBGpr_dbl("refdate ",refdate);
            /* truncate pathname */

            if(lstslsh != -1) pathname[lstslsh] = '\0';

            if(lstslsh == 0)lstslsh = -1;

            __DBGpr_com(" output reference os info to structure");
            (VDreffile+row)->inuseflg = 1;
            strcpy((VDreffile+row)->filename,&osname[lstslsh+1]);
            strcpy((VDreffile+row)->filepath,pathname);
            strcpy((VDreffile+row)->filepathname,OM_GA_OSDs[refList[i]]->name);
            (VDreffile+row)->osnum = refList[i];
            strcpy((VDreffile+row)->modcaldate,osdate);
            (VDreffile+row)->moddecdate = refdate;
            strcpy((VDreffile+row)->product,&buffer.image_name[0]);
            row++;
            strcpy( previous, osname ) ;

        }
        *num_ref = row;
        rc = OM_S_SUCCESS;


	wrapup :

                *VDoactfile = VDactfile;
                *VDoreffile = VDreffile;
                *VDolibfile = VDlibfile;

		if( rc != OM_S_SUCCESS ) {
			rc = FALSE ;
		} else	rc = TRUE ;

		End ;
		return rc;

} /* VDgetfilestat */
/****************************************************/
/* Input = 26 character date from file header       */
/* Output= Decimal date.                            */
/* Leap years are corrected, leap millineau are not */
/* Note that the year is added, no 2000 error       */
int VDann_cal_tick (caldate,outdate)
char caldate[26];
double *outdate; /* decimal year */
{
	IGRint		monadd,
			day, hour, min, sec, year,
			lp ;
	IGRchar		bfchr[DI_PATH_MAX];
	IGRdouble	lpadd,
			dadd ,
			yrlng;

	SetProc( VDann_cal_tick ); Begin

	if( ! outdate ) return( 0 );

	monadd = 0;
	strcpy(bfchr,caldate);

	bfchr[ 7] = '\0';
	bfchr[10] = '\0';
	bfchr[13] = '\0';
	bfchr[16] = '\0';
	bfchr[19] = '\0';
	bfchr[24] = '\0';

	year = atoi(&bfchr[20]);
	day  = atoi(&bfchr[8]) - 1;
	hour = atoi(&bfchr[11]);
	min  = atoi(&bfchr[14]);
	sec  = atoi(&bfchr[17]);

	__DBGpr_int(" Year", year );
	__DBGpr_int(" Day-1 ", day );
	__DBGpr_int(" Hour", hour );
	__DBGpr_int(" Min ", min );
	__DBGpr_int(" Sec ", sec );

	lpadd = 0.;
	lp = year%4;

	__DBGpr_int(" LP ", lp );

	yrlng = 31536000.0;

	if( ! lp )
	{
	 yrlng = 31622400.0;
	 lpadd = 86400.;
	}

	dadd = 86400. * day + hour * 3600. + min * 60. + sec;

	__DBGpr_dbl(" DAYADD ", dadd );

	if( ! strcmp("Jan",&bfchr[4]))
	    monadd = dadd;
	else if( ! strcmp("Feb",&bfchr[4]))
	    monadd = 2678400. + dadd;
	else if( ! strcmp("Mar",&bfchr[4]))
	    monadd = 5097600. + dadd + lpadd;
	else if( ! strcmp("Apr",&bfchr[4]))
	    monadd = 7776000. + dadd + lpadd;
	else if( ! strcmp("May",&bfchr[4]))
	    monadd = 10368000. + dadd + lpadd;
	else if( ! strcmp("Jun",&bfchr[4]))
	    monadd = 13046400. + dadd + lpadd;
	else if( ! strcmp("Jul",&bfchr[4]))
	    monadd = 15638400. + dadd + lpadd;
	else if( ! strcmp("Aug",&bfchr[4]))
	    monadd = 18316800. + dadd + lpadd;
	else if( ! strcmp("Sep",&bfchr[4]))
	    monadd = 20995200. + dadd + lpadd;
	else if( ! strcmp("Oct",&bfchr[4]))
	    monadd = 23587200. + dadd + lpadd;
	else if( ! strcmp("Nov",&bfchr[4]))
	    monadd = 26265600. + dadd + lpadd;
	else
	    monadd = 28857600. + dadd + lpadd;

	*outdate = year + monadd / yrlng;

	__DBGpr_dbl(" OutDate", *outdate );

	End ;
	return (1);
}
/*----------------------------------------------------------------------------*/

end implementation VDCmdStrtup ;
