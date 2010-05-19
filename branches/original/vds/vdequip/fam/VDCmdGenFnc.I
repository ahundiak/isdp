/* $Id: VDCmdGenFnc.I,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $ */

/* I/VDS 
 *
 * File:     VDSequip/slic/VDgenfamfnc.I
 *
 * Description:
 *      Defines all functions related to the command object VDgenfamfil.
 *      This command creates .f (family) and .p (part) ascii files for
 *      the loading of a VDS data base.
 *
 * Revision History:
 *	$Log: VDCmdGenFnc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/06/13  09:09:24  pinnacle
# Replaced: vdequip/fam/VDCmdGenFnc.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.9  1996/06/10  16:19:10  pinnacle
# Replaced: vdequip/fam/VDCmdGenFnc.I for:  by azuurhou for vds.240
#
# Revision 1.8  1996/03/14  21:36:24  pinnacle
# Replaced: vdequip/fam/VDCmdGenFnc.I for:  by yzhu for vds.240
#
# Revision 1.7  1996/03/01  17:34:28  pinnacle
# Replaced: vdequip/fam/VDCmdGenFnc.I for:  by yzhu for vds.240
#
# Revision 1.6  1995/12/18  21:56:02  pinnacle
# Replaced: vdequip/fam/VDCmdGenFnc.I for:  by yzhu for vds.240
#
# Revision 1.5  1995/11/16  14:11:42  pinnacle
# Replaced: vdequip/fam/VDCmdGenFnc.I for:  by yzhu for vds.240
#
# Revision 1.4  1995/11/14  17:23:28  pinnacle
# Replaced: vdequip/fam/VDCmdGenFnc.I for:  by tlbriggs for vds.240
#
# Revision 1.3  1995/11/02  03:20:22  pinnacle
# Replaced: vdequip/fam/VDCmdGenFnc.I for:  by yzhu for vds.240
#
# Revision 1.2  1995/09/25  22:54:40  pinnacle
# Replaced: vdequip/fam/VDCmdGenFnc.I for:  by sundar for vds.240
#
# Revision 1.1  1995/02/07  22:54:00  pinnacle
# src correction
#
# Revision 1.1  1994/11/16  20:17:08  pinnacle
# forgotten directory
#
 *
 * History:
 *      25/02/94       Chaya Rao  
 *
 *              formed this new file to include functions related to  
 *              the command object VDgenfamfil. 
 *
 *	11/02/95	yzhu	change to accept nagtive double value and 
 *                              to truncate string  if  over the length
 *	11/05/95	tlb	Changed chack_double to a static
 *	11/14/95	yzhu	Changed path for keyword.doc
 *	06/13/97	sundar	Changed the function VD_get_stat_attr
 */

class implementation VDCmdGenFam;

#include <string.h>

%safe
#include <VX_FIproto.h>
%endsafe
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "ACrg_collect.h"
#include "macro.h"
#include "expression.h"
#include "expmacros.h"
#include "vdsmacros.h"
#include "vdbmacros.h"
#include "VDgenfam.h"
#include "vdgenfamfil.h"
#include "FI.h"
#include "VDmsg.h"
#include "v_dbgmacros.h"

#include "AS_status.h"

/* #define DEBUG 1; */  

from ACcpx_defn import ACgive_feet_desc;

%safe
static int    check_double = 1 ;
%endsafe;

extern void     VD_add_mesg();

/******************************************************************************/

/* 
   This function returns the positions of the attribute n_creator,
   n_creationdate, p_parttype and n_cofilename.
   Created for TR: 179601493 & 179700314
*/ 
   
int VD_get_stat_attr(IGRchar *f_ptr, char *mac_name, int *n_creator,
                int *n_creationdate, int *p_parttype, int *n_cofilename)
{
	IGRchar st_str[MAXWORD], filename1[MAXWORD], p[MAXWORD];
        IGRint   usf_index, p_index, non_p;
        FILE    *fpp;
 
        *n_creator=0;
        *n_creationdate=0;
        *p_parttype=0;
        *n_cofilename=0;
        usf_index=0;
        p_index=0;
        non_p=0;
 
        strcpy(filename1,mac_name);
        strcat(filename1,".f");
        fpp = fopen( filename1, "r" );
        if ( fpp == NULL )
        {
                strcpy(p,"file not found: ");
                strcat(p,filename1);
                FIg_set_text( f_ptr, MESS1,p);
                fclose(fpp);
                return(-1);
        }
        while ( fgets( st_str, MAXWORD, fpp) != NULL ){
                if ( st_str[2] == 'u' || st_str[2] == 's' || st_str[2] == 'f')
                        break;
                usf_index++;
        }
        while ( fgets( st_str, MAXWORD, fpp) != NULL ){
                char *t;
 
                p_index++;
                if ( st_str[2] != 'u' && st_str[2] != 's' && st_str[2] != 'f')
                        non_p++;
                t = strchr(st_str,'|');
                if ( t != NULL ){
                        if ( strncmp(&t[1],"n_creator",9) == 0 )
                                *n_creator=p_index-non_p+1;
                        if ( strncmp(&t[1],"n_creationdate",14) == 0 )
                                *n_creationdate=p_index-non_p+1;
                        if ( strncmp(&t[1],"p_parttype",10) == 0 )
                                *p_parttype=p_index-non_p+1;
                        if ( strncmp(&t[1],"n_cofilename",12) == 0 )
                                *n_cofilename=p_index-non_p+1;
                }
        }
        fclose(fpp);
 
        return 1;
}

/* This function finds the selected line in the gadget "LIST".      */

int VD_get_list_data(form_ptr,review_only,family)

char      *form_ptr;		/* I : form pointer		*/

IGRint    review_only,family;	/* I : flag  review_only checks if family 		                         * file is for review.
                                 * I : flag  family tells if family or 
                                 * part is to be processed
                                 */

{
IGRint    pos,i,number_rows,offset,sel_flag;
IGRchar   text3[MAXWORD],sttmp[MAXWORD],save_text[MAXWORD];

	SetProc( VD_get_list_data ); Begin

	if( review_only == TRUE && family == FALSE ) 
	{
		return(1);
	}

	pos = -1;
	FIfld_get_num_rows( form_ptr, LIST, &number_rows);
	for(i=0;i<number_rows;i=i+1){
 		FIfld_get_select(form_ptr,LIST,i,0,&sel_flag);
		if(sel_flag == TRUE) break; 
	}

	if( i <number_rows ){
		FIfld_get_text( form_ptr, LIST, i, 0, 50,(unsigned char*) save_text, &sel_flag, &pos);
		FIfld_get_text( form_ptr, LIST, i, 4, 50,(unsigned char*) text3, &sel_flag, &pos);
		offset = atof(text3);

		if( pos == 0 && family == FALSE && strcmp(save_text,"") == 0) 
		{
			FIfld_get_text( form_ptr, LIST, 0, 3, 50,(unsigned char*) save_text, &sel_flag, &pos);
			strcpy( sttmp,"Key in new description for library" );
			VD_add_mesg( sttmp, save_text, form_ptr,i);
			check_double = 1;
		}
		else if( family == TRUE)
		{
			FIfld_get_text( form_ptr, LIST, i, 1, 50,(unsigned char*) save_text, &sel_flag, &pos);
			FIfld_get_text( form_ptr, LIST, i, 2, 50,(unsigned char*) sttmp, &sel_flag, &pos);
			if( sttmp[0] == 'c' || sttmp[0] == 't')	
			{
				strcpy(sttmp,"Key in new ");
				check_double = 1;
			}
			else if( sttmp[0] == 'd' ||  sttmp[0] == 's') 
			{
				check_double = 0;
				if(sttmp[0] == 's') check_double = 2;
				strcpy(sttmp,"Key in value for ");
			}
			strcat(sttmp,save_text);
			FIfld_get_text( form_ptr, LIST, i, 3, 50,(unsigned char*) save_text, &sel_flag, &pos);
			VD_add_mesg(sttmp, save_text,form_ptr,i);

		}
		else if(!strcmp(save_text, "static"))
		{
			strcpy(save_text, "dynamic");
			FIfld_set_text( form_ptr, LIST, i, 0, save_text, FALSE);
			FIfld_set_text( form_ptr, MESS1, 0, 0, "Dynamic = Input at placement time", FALSE);
			FIfld_get_text( form_ptr, HIDDEN_FAM_LIST, offset, 0, 50,(unsigned char*) save_text, &sel_flag, &pos);
			save_text[2]='c';
			FIfld_set_text( form_ptr, HIDDEN_FAM_LIST, offset, 0, save_text, TRUE);
 			FIfld_set_select(form_ptr,LIST,i,0,0);
 			FIfld_set_select(form_ptr,LIST,i,1,0);
 			FIfld_set_select(form_ptr,LIST,i,2,0);
	 		FIfld_set_select(form_ptr,LIST,i,3,0);
		}
		else if(!strcmp(save_text, "dynamic")) 
		{
			strcpy(save_text, "static");
			FIfld_set_text( form_ptr, LIST, i, 0, save_text, FALSE);
			FIfld_set_text( form_ptr, MESS1, 0, 0, "Static = Data retrieved from part files", FALSE);
			FIfld_get_text( form_ptr, HIDDEN_FAM_LIST, offset, 0, 50,(unsigned char*) save_text, &sel_flag, &pos);
			save_text[2]='s';
			FIfld_set_text( form_ptr, HIDDEN_FAM_LIST, offset, 0, save_text, TRUE);
 			FIfld_set_select(form_ptr,LIST,i,0,0);
 			FIfld_set_select(form_ptr,LIST,i,1,0);
 			FIfld_set_select(form_ptr,LIST,i,2,0);
	 		FIfld_set_select(form_ptr,LIST,i,3,0);
		}
	}

        End
	return(0);
}

/****************************************************************************/

void VD_set_up_part_list(form_ptr, macro_name, macro_lib, myfile)
 
/* sets up the part list on the form */

IGRchar		*form_ptr,
		*macro_name,
		*macro_lib,
                *myfile;
{
IGRint		tot_up,ii, 
		k, l, m,num,sel_flag,pos;
IGRchar		t[MAXWORD],
		n[MAXWORD],
		d[MAXWORD],
		p[MAXWORD],tmp[MAXWORD];
IGRchar		date[MAXWORD], c; 
FILE		*fp;
	SetProc( VD_set_up_part_list ); Begin

	FIg_set_text( form_ptr, MESS1,"Processing...");


        system( "date '+%m/%d/%Y' > /usr/tmp/dates" );
        /* types month.date.year into /usr/tmp/dates */

        ii = 0;
     
	fp = fopen( "/usr/tmp/dates", "r" );
        c = fgetc(fp);
        while( c != EOF ){
             if( c != '\n' ){
                 date[ii] = c;
                 ii++;
             }
             c = fgetc(fp);
        }
        date[ii] = '\0';
        fclose(fp);

#ifdef DEBUG
        printf("---date%s\n",date );
#endif
	/*
	 * clear the visible list
	 */

        VDcleanup_list( form_ptr, LIST );

	/*
	 * clear the hidden parts list
	 */

	VDcleanup_list( form_ptr, HIDDEN_PART_LIST );
        
	FIfld_set_text( form_ptr, MESS1, 0,0, "",FALSE);

	l=0;
	m=0;
	tot_up=0;

	FIfld_get_num_rows( form_ptr, HIDDEN_FAM_LIST,&num);

	for( k=0; k<num; k++ ){

	    FIfld_get_text( form_ptr, HIDDEN_FAM_LIST, k, 0,50,
					(unsigned char*) t, &sel_flag, &pos);
	    FIfld_get_text( form_ptr, HIDDEN_FAM_LIST, k, 1,50,
					(unsigned char*) n, &sel_flag, &pos);
                
	    if (!strcmp(n,NFM2)) tot_up = 0;

#ifdef DEBUG
    	    printf("%d,t>%s<, n>%s<\n", k, t, n );
#endif 

	    if( !k || t[2] == 'u' || t[2] == 's' || t[2] == 'f')
            /* check for p_u or p_s or p_f type of attributes */
 
	    {
		/*
		 * skip units_set in list
                 */
#ifdef DEBUG 
 printf( " NFM2:%s-macro_lib:%s-myfile:%s\n",NFM2, macro_lib, myfile );
#endif
		   if(!strcmp(n,NFM1)) strcpy(d,macro_name);
		   else if(!strcmp(n,NFM3)) strcpy(d,"nfmadmin");
		   else if(!strcmp(n,PDM5)) strcpy(d,"");
		   else if(!strcmp(n,PDM3)) strcpy(d,macro_lib);
		   else if(!strcmp(n,PDM1)) strcpy(d,date);
		   else if(!strcmp(n,PDM4)) strcpy(d,"P");
                   else if((!strcmp(n,NFM2))&&( !strcmp( macro_lib, "." )))
                           strcpy(d, myfile );
                   else if((!strcmp(n,NFM2))&&( strcmp( macro_lib, "." ) != 0))
                           strcpy(d,macro_lib); 
		   else strcpy(d, "0.0");

		   FIfld_get_text( form_ptr, HIDDEN_FAM_LIST,
				   k, 2,50, (unsigned char*)p, &sel_flag, &pos);

		   FIfld_set_text( form_ptr, HIDDEN_PART_LIST, l,0, "",FALSE);
		   FIfld_set_text( form_ptr, HIDDEN_PART_LIST, l,1, n,FALSE);
		   FIfld_set_text( form_ptr, HIDDEN_PART_LIST, l,2, p,FALSE);
		   FIfld_set_text( form_ptr, HIDDEN_PART_LIST, l,3, d,FALSE);

		   FIfld_get_text( form_ptr, HIDDEN_FAM_LIST,
				   k, 3,50,(unsigned char*) d, &sel_flag, &pos);

		   if ( t[2] == 'u' || t[2] == 's') {
                   /* check for p_u or p_s or p_f type of attributes */

		      if (!strcmp ( n, NFM3)	||
		          !strcmp ( n, PDM1)	||
		          !strcmp ( n, PDM4)	||
		          !strcmp ( n, NFM2)) m = m;
		      else
		      {
		          FIfld_set_text( form_ptr, LIST, m,0, "",FALSE);
			  FIfld_set_text( form_ptr, LIST, m,1, d,FALSE);
			  FIfld_set_text( form_ptr, LIST, m,2, p,FALSE);
			  FIfld_set_text( form_ptr, LIST, m,3, "",FALSE);
                          sprintf(tmp,"%d",l);
			  FIfld_set_text( form_ptr, LIST, m,4,tmp,FALSE);
			  m++;
		      }
		  }/*  if ( t[2] == 'u' || t[2] == 's') */

		  strcpy(d,"");
		  l++;
	     } /* !k || t[2] == 'u' || t[2] == 's' || t[2] == 'f' */
	} /* for( k=0; k<num; k++ ) */

        End
}

/**************************************************************************/

void VD_add_mesg(mess,mess3,form_ptr,i)
 
/* sets the row i for user to enter corresponding data */

char	*mess, *mess3; /* message strings */
char    *form_ptr;
int     i; /* row */
{        
        SetProc( VD_add_mesg ); Begin
 
	FIfld_set_text( form_ptr, MESS1, 0,0, mess,FALSE);
	FIfld_set_mode( form_ptr, MESS2, 0, FI_INSERT);
	FIfld_set_text( form_ptr, MESS2, 0,0, mess3,TRUE);

 	FIfld_set_select(form_ptr,LIST,i,0, TRUE );
 	FIfld_set_select(form_ptr,LIST,i,1, TRUE );
 	FIfld_set_select(form_ptr,LIST,i,2, TRUE );
 	FIfld_set_select(form_ptr,LIST,i,3, TRUE );
        End
}

/**************************************************************************/

int read_part_from_part_file( form_ptr,macro_name, modifyrownum, append  )

/* reads part from file macro.p */

IGRchar            *form_ptr;
IGRchar            *macro_name;
IGRint             *modifyrownum;
IGRint             append;
{
IGRchar  	p[MAXWORD],
                sttmp[MAXWORD],
                save_text[MAXWORD],
                filename[MAXWORD];
FILE            *fp;
IGRint	        pos1,pos,
		i,count,
		num_rows,
		j,sel_flag,stat_sts,n_creator,
		n_creationdate,p_parttype,n_cofilename;

        SetProc( read_part_from_part_file ); Begin

	FIg_set_text( form_ptr, MESS1,"Reading part from file..");

	FIfld_get_text (form_ptr,PART_LIST,0,0,50,(unsigned char*)save_text,
                        &sel_flag,&pos);

	num_rows = 0;
	FIfld_get_list_num_rows( form_ptr, PART_LIST, 0, &num_rows);

	for(i=0;i<num_rows;i++)
	{
		FIfld_get_list_text( form_ptr,PART_LIST,i,0,50,
                                     (unsigned char*)sttmp,&sel_flag);
		if(sel_flag == TRUE ) break; 
	}
	if(i == num_rows)
	{
                /* if user type in a part name */
		for(i=0;i<num_rows;i=i+1)
		{
			FIfld_get_list_text( form_ptr,PART_LIST,i,0,50,
                                      (unsigned char*)sttmp,&sel_flag);
			if(!strcmp(sttmp, save_text)) break; 
		}

	}

        /* TR179600319: record the modify row number to allow user to
           modify part name and version*/
        if( i < num_rows && append == 1) {
                *modifyrownum = i;
        } 

        /* if i == num_rows, form will set junk, if continue */	
        if ( i == num_rows) goto quit;
 
	FIfld_set_list_select(form_ptr,PART_LIST,i,0,FALSE);

	FIfld_set_text( form_ptr, MESS1, 0,0, "",FALSE);

	strcpy(filename,macro_name);
	strcat(filename,".p");

	fp = fopen( filename, "r" );
	if ( fp == NULL )
	{
		strcpy(p,"file not found: ");
		strcat(p,filename);
		strcat(p,": write out the file displayed");
		FIg_set_text( form_ptr, MESS1,p);
		fclose(fp);
		return(-1);
	}

	FIfld_get_num_rows( form_ptr, HIDDEN_PART_LIST,&pos);

	for(j=0;j<i*(pos+2)+1; j=j+1) {
               fgets( sttmp, MAXWORD, fp);
        }

	for( j=0; j<pos; j++)
	{
		fgets( sttmp, MAXWORD,fp);
		VD_part_parse( sttmp );
#ifdef DEBUG
                printf("new value of  sttmp from parse= %s\n",sttmp);
#endif
		FIfld_set_text( form_ptr, HIDDEN_PART_LIST, j, 3, sttmp, FALSE);
	}

	fclose(fp);

	/* Changed for the TR: 179700314 by Sundar */
	stat_sts = VD_get_stat_attr( form_ptr, macro_name,
                &n_creator, &n_creationdate, &p_parttype, &n_cofilename);

	if ( stat_sts == -1 )
		goto quit ;

        count = 0; 
	/* Changed for the TR: 179700314 by Sundar */
	for(j=1; j<pos; j++)
	{ 
           if (j==n_creator || j==n_creationdate || j==p_parttype
			|| j==n_cofilename ) 
           {
		FIfld_get_text(form_ptr,HIDDEN_PART_LIST,j,3,50,
                               (unsigned char*)sttmp,&sel_flag,&pos1);
           }
           else
           {
                FIfld_get_text(form_ptr,HIDDEN_PART_LIST,j,3,50,
                               (unsigned char*)sttmp,&sel_flag,&pos1);
                 
		FIfld_set_text(form_ptr,LIST,count,3, sttmp,FALSE);
                count++;
	    }
	}
quit:
        End
	return(0);    
}

/*****************************************************************************/

int    VD_part_parse( sttmp)

/* parses the string sttmp obtained from function read_part_from_part_file */
 
IGRchar sttmp[MAXWORD]; /* I/O : to be parsed/parsed string */

{
IGRchar	n[MAXWORD], nn[MAXWORD],*n1;
IGRint	x,y;
        SetProc( VD_part_parse ); Begin

	if( n1 = strchr(sttmp,'=')) strcpy(n, n1);

#ifdef DEBUG
        printf("Before strcpy sttmp = %s\n",sttmp);
        printf("After strcpy n = %s\n ",  n);
#endif

	if( n[1] == 39) x=2; else x=1;
	y=0;
 	while(1)
	{
		nn[y] = n[x];
		if( nn[y] == 39 || nn[y] == '\0' || nn[y] == '\n' || x > 130 )break;
		x=x+1;
		y=y+1;
	}
	nn[y] = 0;
	strcpy(sttmp, nn);

#ifdef DEBUG
        printf("After  final strcpy sttmp = %s\n ",  sttmp);
	printf("exiting parse part\n");
#endif
        End
        return(0);
}

/*****************************************************************************/

int VD_avoid_mess2( form_ptr,family,get_serv,save_text,row )

/* takes in text keyed in the user input field and processes it */

IGRchar		*form_ptr;
IGRchar		*save_text; /* user input */
IGRint		family,     /* flag if family or part to be processed */
                row,        /* user input row */
                get_serv;
{
IGRint 		num,
                counter,
                temp,
		cnum,
		offset,
		sel_flag,		/* used in FIfld_set_text */
		pos;			/* used in FIfld_set_text */
IGRchar		chrnum[MAXWORD],
		sttmp[MAXWORD];
IGRchar         len, lenText;
IGRchar         *ptr, *ptr1, tmp_text[MAXWORD], att_text[MAXWORD];
 
        SetProc( VD_avoid_mess2 ); Begin 
	/*
	 * produce message and set the cursor to the predefined 
	 * location for input.
	 */

	if( get_serv == 1)
	{
	  FIfld_set_text( form_ptr, MAC_LIB, 0, 0, save_text, TRUE);
	  FIfld_pos_cursor( form_ptr, MAC_LIB, 0, 0, 0, 0, 0, 0);
	  FIfld_pos_cursor( form_ptr, MAC_LIB, 0, 0, 0, 0, 0, 0);
	  return TRUE;
	}

	if( check_double != 1){ 
         /* check to see if user has keyed in double or string value */
 
        	counter = 0;
		cnum = 1;
		temp  = strlen(save_text);
		while ( counter <=( temp - 1 ) && cnum ==  1){
                  if(  counter == 0 && save_text[counter]=='-') {
                        cnum = 1;
                        counter = counter+1;
                  }
		  else if(  
                        (save_text[counter] >='0' && save_text[counter] <= '9') 
		        || save_text[counter]=='.'){
			cnum = 1;
			counter = counter+1;
		  }
		  else{	cnum = 0;	}
		} 

		if( cnum != 1)
		{
			if( check_double == 0)
			{
				FIg_set_text( form_ptr, MESS1,"value is not a double");
			}
			else
			{
				FIg_set_text( form_ptr, MESS1,"value is not an integer");
			}
			return(-1);
		}
	}

	FIfld_get_text( form_ptr, LIST, row, 2, MAXWORD,
                        (unsigned char*) att_text, &sel_flag, &pos);
        if ( check_double == 1 && att_text[0] != '\0' ) {
                ptr = NULL;
                ptr1 = NULL;
                len = strlen(save_text);
 		ptr = strchr(att_text,'[');
 		ptr1 = strchr(att_text,']');
                if ( ptr != NULL && ptr1 != NULL) {
                     strncpy( tmp_text, &ptr[1], strlen(ptr)-strlen(ptr1) - 1);
                     lenText = atoi(tmp_text); 
                     if ( lenText < len ) 
                      save_text[lenText] = '\0';
                }      
        }
	FIfld_set_mode(form_ptr,MESS2,0,FI_REVIEW);
#ifdef DEBUG
        printf("save_text,%s\n",save_text);
#endif
	FIfld_set_text( form_ptr, LIST, row, 3, save_text, FALSE);
	FIfld_get_text( form_ptr, LIST, row, 4, 10,(unsigned char*) chrnum, &sel_flag, &pos);
	offset = atoi(chrnum);
	if( family == FALSE )
	{
		FIfld_set_text( form_ptr, HIDDEN_FAM_LIST, 1, 3, save_text, FALSE);
		FIfld_set_select(form_ptr,LIST,row,0,0);
 		FIfld_set_select(form_ptr,LIST,row,1,0);
 		FIfld_set_select(form_ptr,LIST,row,2,0);
 	}
	else
	{
		FIfld_get_num_rows( form_ptr, LIST,&num);
		FIfld_set_text( form_ptr, HIDDEN_PART_LIST, offset, 3, save_text, FALSE);
		if( row <num)
		{ 
			row++;
		} 
		else 
		{ 
			FIfld_set_mode(form_ptr,MESS2,0,FI_REVIEW);
			FIg_set_text( form_ptr, MESS2,"");
			FIg_set_text( form_ptr, MESS1,"");
			FIfld_set_select(form_ptr,LIST,row,0,0);
 			FIfld_set_select(form_ptr,LIST,row,1,0);
 			FIfld_set_select(form_ptr,LIST,row,2,0);
			return(1);
		}

		FIfld_get_text( form_ptr, LIST, row, 1, 50,(unsigned char*) save_text, &sel_flag, &pos);
		if(!strcmp(save_text,""))
		{	
			FIfld_set_num_rows( form_ptr, LIST, row); 
			row=row-1;
			FIfld_get_text( form_ptr, LIST, row, 1, 50,(unsigned char*) save_text, &sel_flag, &pos);
		}
		if( row > 7 && pos == -1)
		{
			FIfld_pos_cursor( form_ptr, LIST, row,8,0,0,0,0);
			FIfld_erase_cursor( form_ptr, LIST);
		}
		FIfld_get_text( form_ptr, LIST, row, 2, 50,(unsigned char*) sttmp, &sel_flag, &pos);
		if( sttmp[0] == 'c' || sttmp[0] == 't')	
		{
			strcpy(sttmp,"Key in new ");
			check_double = 1;
		}
		else if( sttmp[0] == 'd' ) 
		{
			strcpy(sttmp,"Key in value for ");
			check_double = 0;
		}
		strcat(sttmp,save_text);
		FIfld_get_text( form_ptr, LIST, row, 3, 50,(unsigned char*) save_text, &sel_flag, &pos);
		VD_add_mesg(sttmp, save_text,form_ptr,row);
		return(3);
	}
	FIg_set_text( form_ptr, MESS2, "");
	FIg_set_text( form_ptr, MESS1,"");

        End
        return(0);
}

/****************************************************************************/

void VDreset_messages_fields( form_ptr )

char		*form_ptr;
{
int     i,pos;

   SetProc( VDreset_messages_fields ); Begin
  /*
   * reseting of the message ...
   */
  
  FIfld_set_mode( form_ptr, MESS2, 0, FI_REVIEW);
  FIg_set_text( form_ptr, MESS2,"");
  FIfld_get_num_rows( form_ptr, LIST,&pos);

  for(i = 0;i <= pos; i++){
	FIfld_set_text( form_ptr, MESS1, 0, 0, "", FALSE);
 	FIfld_set_select(form_ptr,LIST,i,0,FALSE);
 	FIfld_set_select(form_ptr,LIST,i,1,FALSE);
 	FIfld_set_select(form_ptr,LIST,i,2,FALSE);
	FIfld_set_select(form_ptr,LIST,i,3,FALSE);
  }
  End
}
/***************************************************************************/

int VDcheck_for_cpt( obj )
 
/* check for connect point */

struct GRid	*obj;
{
struct myfeet	*FeetDesc;
IGRint		i, NumFeet,count,status;

        SetProc( VDcheck_for_cpt ); Begin
	count=0;
  
/* 
  Public Message ACgive_feet_desc
        
      Abstract
 
         * This message returns a full description of my feet
         * This information is in the following structure :
         *
         *      struct myfeet
         *      {
         *        char name[macro_MAX_CHAR];  feet name 
         *        int  chan;  type of the feet , in one of the following : 
         * #define feet_in_template 0                      
         * #define feet_virtual     1                     
         * #define feet_in_graphic  2                    
         * int pos;    my index on my associated channel            
         * int prop;   the type as defined in parametric.h         
         *      };
         *
     Arguments
         *  int *feet_num           O : number of feet returned
         *
         *  struct myfeet **myfeet  O : array of structure returned
  */

	status = 
	om$send(msg = message ACcpx_defn.ACgive_feet_desc(&NumFeet,
							  &FeetDesc),
                senderid = NULL_OBJID,
		targetid = obj->objid);
	if( ! (status&1)) return( count );

	for( i=0; i<NumFeet; i++)
	  if( strncmp( FeetDesc[i].name,"VRcpt_",6) == 0) count++;

        End
	return(count);
}

/*****************************************************************************/

int VD_check_for_reserved_words(	form_ptr,	/* file pointer */
					errors )	/* error msg string  */

/* checks if reserved words from /usr/ip32/ris/risccu/doc/keyword.doc
 * have been used.
 */

IGRchar		*form_ptr;
IGRchar		errors[MAXWORD]; /* error message string */
{

IGRint		num,
		status,
		i,j,k,
		ch_no_lines, /* number of lines in /tmp/key_wd_wc */
		sel_flag,
		pos;
IGRchar		t[MAXWORD],
		tmp[MAXWORD];
IGRchar		*res_big_list; /* stores words from /tmp/key_wd_wc */
IGRint		check_errors;
FILE            *fp;
IGRchar         *path, sysInfo[MAXWORD] ;
IGRlong         sts;

        SetProc( VD_check_for_reserved_words ); Begin
	status = MSSUCC;
	check_errors = FALSE ;
	res_big_list = NULL ;

        sts = ex$get_product_data ( in_logo = "I/VDS", config_path = &path);

        sprintf( sysInfo, 
            "cat %s/config/loaddata/keyword.doc|cut -c0-25> /tmp/keywd", path );
        system( sysInfo );

        system("wc -l /tmp/keywd|cut -c'1-7'|sed 's/[	 ]*//'>/tmp/keywd_wc"); 

        fp = fopen("/tmp/keywd_wc","r");
        fscanf(fp,"%d" ,&ch_no_lines );
        fclose(fp);

	res_big_list = (char *) malloc (ch_no_lines * MAXWORD * sizeof(char));

	fp = fopen("/tmp/keywd" , "r" );

	for(i=0;i<ch_no_lines;i=i+1)
	{
		fscanf(fp,"%s",&res_big_list[i*MAXWORD]);
		if(strncmp(&res_big_list[i*MAXWORD], "----",4) == 0)
		{
			ch_no_lines = ch_no_lines -i;
			i = 0;
		}
	}
	fclose(fp);

	FIfld_get_num_rows( form_ptr, HIDDEN_FAM_LIST,&num);
	for(j=0;j<num;j=j+1)
	{
	    FIfld_get_text( form_ptr, HIDDEN_FAM_LIST,
				j, 1, 50,(unsigned char*) t, &sel_flag, &pos);
/*  TR179600319      	    for(k=0;k<i;k=k+1)  */
	    for(k=0;k<ch_no_lines;k=k+1)
	    {
		if( strcmp(t,&res_big_list[k * MAXWORD]) == 0 && 

		    strcmp(t, "env") != 0 )
		{
			if( check_errors == FALSE ){

				strcpy(errors,"Reserved word->");
				strcat(errors,t);
				strcat(errors,", at line ");
                                sprintf(tmp,"%d",(j+2));
				strcat(errors,tmp);
				strcat(errors,"\n");

				check_errors = TRUE ;
                        }
		}
	    }
	}

	status = 
	VD_check_family_list_attrs_names(	form_ptr,
						&check_errors,
						errors );
	/*
	 * free memory 
	 */
	if (res_big_list != NULL)	free(res_big_list);  

        End
	return( ( status == MSFAIL || check_errors ) ? MSFAIL : MSSUCC );
}


/*****************************************************************************/

int VD_check_family_list_attrs_names(
				form_ptr,	/* form pointer		*/
				check_errors,	/* error process flag   */
				errors )	/* error string		*/
/* checks for non alphanumeric values */

IGRchar		*form_ptr;
IGRint		*check_errors;
IGRchar		errors[MAXWORD];
{
IGRchar		t[MAXWORD],
		tmp[MAXWORD];
IGRint		num,
		status,
		j,k,
		sel_flag,
		pos;

        SetProc( VD_check_family_list_attrs_names ); Begin	

	status = MSSUCC;
	FIfld_get_num_rows( form_ptr, HIDDEN_FAM_LIST,&num);

	for(j=0;j<num;j=j+1)
	{
	    FIfld_get_text( form_ptr, HIDDEN_FAM_LIST,
			j, 1, 50,(unsigned char*) t, &sel_flag, &pos);

	    for(k=0;k<strlen(t);k=k+1)
	    {
		if( isalnum(t[k]) == 0 && t[k] != 95 )
		{
			if( *check_errors == FALSE ){
                                
				strcpy(errors,"Non alphanumeric->");
				strcat(errors,t);
				strcat(errors,", at line ");
                                sprintf(tmp,"%d",(j+2));
				strcat(errors,tmp);
				strcat(errors,"\n");			

				*check_errors = TRUE ;
			} 
			else {
				tolower(t[k]);
			}
		}

		FIfld_set_text( form_ptr, HIDDEN_FAM_LIST, j,1, t,FALSE);
	    }

	    status =
	    VD_check_family_duplicate_attrs_names(	form_ptr,
							check_errors,
							errors );	

	    if( status == MSFAIL || *check_errors == TRUE ) return( MSFAIL );
	}

        End	
	return( MSSUCC );
}

/******************************************************************************/

int VD_check_family_duplicate_attrs_names( 
				form_ptr,	/* form pointer		*/
 				check_errors,	/* error process flag   */
                                errors )
/* checks for duplicate attribute names */
 
IGRchar		*form_ptr;
IGRint	        *check_errors;
IGRchar		errors[MAXWORD];             /* error msg string     */
{
IGRchar		t[MAXWORD],
		u[MAXWORD],
		tmp[MAXWORD];
IGRint		num,
		j,k,
		sel_flag,
		pos;

        SetProc( VD_check_family_duplicate_attrs_names ); Begin
	FIfld_get_num_rows( form_ptr, HIDDEN_FAM_LIST, &num);

	for( j=0; j<num; j++ )
	{
 	    FIfld_get_text( form_ptr, HIDDEN_FAM_LIST, 
				j, 1, 50,(unsigned char*) t, &sel_flag, &pos);

	    for( k=j+1; k<num; k++ )
	    {
	 	FIfld_get_text( form_ptr, HIDDEN_FAM_LIST, 
				k, 1, 50,(unsigned char*) u, &sel_flag, &pos);
		if( strcmp(t,u) == 0 && 
		    strcmp(t,NFM2) != 0  &&
		    strcmp(t,PDM3) != 0 )
		{
			if( *check_errors == FALSE ){

				strcpy(errors,"Duplicate attribute name->");
				strcat(errors,t);
				strcat(errors,"=");
				strcat(errors,u);
				strcat(errors,", at lines ");
                                sprintf(tmp,"%d",(j+2));

				strcat(errors,tmp);

				strcat(errors,",");
                                sprintf(tmp,"%d",(k+2));
				strcat(errors,tmp);
				strcat(errors,"\n");			
                                  
				*check_errors = TRUE ;			
			}
		}
	    }

	    if( *check_errors == TRUE ) return( MSFAIL ); 
	}
	End
	return( MSSUCC );
}

/*****************************************************************************/

int VDcleanup_list(	form_ptr,
		     	gadget_number )

IGRchar		*form_ptr;
IGRint		gadget_number;/* gadget_number that needs to be cleaned */ 
{
IGRint		num, k;
	SetProc( VDcleanup_list ); Begin
	/*
         * clear out the list
         */

        FIfld_get_num_rows( form_ptr, gadget_number,&num);
        for( k=0; k<num; k++ )
        {
               FIfld_set_text( form_ptr, gadget_number, k,0, "",FALSE);
               FIfld_set_text( form_ptr, gadget_number, k,1, "",FALSE);
               FIfld_set_text( form_ptr, gadget_number, k,2, "",FALSE);
               FIfld_set_text( form_ptr, gadget_number, k,3, "",FALSE);
        }

        FIfld_set_num_rows( form_ptr, gadget_number, 0);
        End
	return( TRUE );
}

/*****************************************************************************/

int VD_pars_line(input, ptype, name, type, deflt)

char    *input;         /* I : input string from ASCI file.      */
char    *ptype;         /* O : static/dynamic type               */
char    *name;          /* O : attribute name                    */
char    *type;          /* O : attribute type                    */
char    *deflt;         /* O : default value                     */
{
int     j,k;
char    l_ptype[MAXWORD];
char    l_name[MAXWORD];
char    l_type[MAXWORD];
char    l_deflt[MAXWORD];

        SetProc( VD_pars_line ); Begin 

        l_ptype[0] = '\0';
        l_type[0]  = '\0';
        l_deflt[0] = '\0';
        l_name[0]  = '\0';

        /*
         * input contains a string from the ASCII file and needs to be
         * split in to the following parts according to the syntax of the
         * line.
         * input = <type> '|' <name> '(' <attribute type> ')' '=' <default>
         * where:
         *      <type>  : static, dynamic attribute type or NIL
         */

        /*
         * test if input exists and is there any text given.
         */
        if( input[0] == '\0' ) return FALSE;

        /*
         * the attribute type is small or less than NINE characters
         */
        j=0;
        while( input[j] != '|' ){
                if((input[j] == '\0') ||(j >= 9))
                { j = -1;
                  l_ptype[0] = '\0';
                  break;
                }
                l_ptype[j]=input[j];
                j++;
        }
         l_ptype[j]='\0';

        j++;
        k=0;
        while( input[j] != '(' ) l_name[k++]=input[j++];
        l_name[k]='\0';

        j++;
        k=0;
        while( input[j] != ')' ) l_type[k++]=input[j++];
        l_type[k]='\0';

        j=j+2;  /* skip the '=' character */
        k=0;
        while( input[j] != '\n' ) l_deflt[k++]=input[j++];
        l_deflt[k]='\0';

        if( ptype ) strcpy( ptype, l_ptype );
        if( name  ) strcpy( name , l_name );
        if( type  ) strcpy( type , l_type );
        if( deflt ) strcpy( deflt, l_deflt );

#ifdef  DEBUG
        if( ptype ) printf(" ptype : %s \n", ptype );
        if( name  ) printf(" name  : %s \n", name );
        if( type  ) printf(" type  : %s \n", type );
        if( deflt ) printf(" deflt : %s \n", deflt );
        printf("exiting pars_line()\n");
#endif
        End
        return TRUE;
}

/****************************************************************************/

void VD_post_line(output, ptype, name, type, deflt, family)

IGRchar *output,        /* I/O : string to be posted          */
        *ptype,         /* I   : static/dynamic               */
        *name,          /* I   : attribute name               */
        *type,          /* I   : attribute type               */
        *deflt;         /* I   : default value                */

IGRint    family;       /* */

{
int    off,k;

        SetProc( VD_post_line ); Begin 
#ifdef  DEBUG
        printf("entering post_line()\n");
#endif

        /*
         * clean up properly the output buffer for posting.
         */
        strncpy(output,"",MAXWORD-2);

        k=0;
        if(strcmp( ptype, ""))
        {
                off = 5;
                strcpy(output,ptype);
                strcat(output,"|");
        }else off = 4;

        strcat(output,name);
        if( family == 0) strcat(output,"(");
 strcat(output,type);
        if( family == 0) strcat(output,")="); else strcat(output,"=");
        strcat(output,deflt);
        strcat(output,"\n");
        output[strlen(ptype)+strlen(name)+strlen(type)+strlen(deflt)+off] = '\0'
;

#ifdef  DEBUG
        printf("exiting post_line()\n");
#endif
	End
}

/****************************************************************************/

  
end implementation VDCmdGenFam;


