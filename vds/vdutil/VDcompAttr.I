/* $Id $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdutil/VDcompAttr.I
 *
 * Description:
 *	Compute the attributes of macros.
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/29/00        Rama Rao        File Creation
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "EMSmsgdef.h"
#include "VDmem.h"
#include "VDobj.h"
#include "vdsmacros.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

typedef IGRchar  TVDctAttrName     [1024];

static long VDatGetNextWord( IGRchar  *buf,
                             IGRchar  *out_buf,
                             IGRint   size_out_buf )
{
IGRint 		i, j;
IGRchar 	*ptr;

   if(buf == NULL) return 0;

   ptr = NULL;

   /*| Take out first spaces */
   for(i=0;i<strlen(buf);i++)
   {
      if(buf[i] != ' ' && buf[i] != '\t' && buf[i] != '\0' )
      { ptr = &buf[i]; break; }
   }

   for( j=i; j<strlen(buf); j++ )
   {
      if(buf[j] == ' ' || buf[j] == '\t' || buf[j] == '\0' )
      { ptr = &buf[j]; break; }
   }

   if( j == strlen(buf) )
   {
      if( ptr ) strcpy( out_buf, ptr );
      return 1;
   }

   return 1;
}

IGRlong		VDatReportAttrInfo( IGRlong		*msg,
				    IGRint		inp_count,
				    struct GRobj_env	*inp_list,
				    struct GRmd_env	loc_env,
				    IGRchar		*inp_filename,
				    IGRchar		*out_filename )
{
IGRlong			sts;
IGRint			i, j, loc_cnt, tab, sort_cnt, attr_cnt, is_malloc;
IGRdouble		range[6];
IGRchar			cc, status_msg[50];
TVDctAttrName		macName, macro_name, AttrName, attr_value, line, NoUse,
			absPathName, attr_names[100];
GRclassid		classid[1];
struct GRobj_env	*sort_list=NULL, *objenv_list=NULL;
FILE			*inp_fp=NULL, *out_fp=NULL;

   sts = *msg = MSSUCC;

   classid[0] = OPP_ACcpx_class_id ;

   if( !inp_filename || inp_filename[0] == '\0' )
   {
	UI_status("Need to specify the Input File Name" );
	printf("Need to specify the Input File Name\n"  );
	goto wrapup;
   }

   vd$file_path( msg 		  = msg,
                 fileToFind 	  = inp_filename,
                 dirToSearchFirst = ".",
                 dirInProdPathToSearchThen = "config/reports",
                 absPathName      = absPathName );


   if( !( inp_fp = VDopenFile( msg, absPathName, "r" ) ) )
   {
      printf("Can not open file: %s\n", absPathName  );
      return 0;
   }

   if( out_filename && !( out_fp = VDopenFile( &msg, out_filename, "w" ) ) )
      printf( "Output will be sent to unix window\n" );
  
   if( !out_fp ) out_fp = stdout;

   if( inp_count && inp_list )
   {
      is_malloc = FALSE;
      loc_cnt  = inp_count;
      objenv_list = inp_list;
      if( !( sort_list = _MALLOC( loc_cnt, struct GRobj_env ) ) ) 
		vd_$mem_fail();
   }
   else
   {
      is_malloc = TRUE;
      range[0] = range[1] = range[2] = -1.0e100;
      range[3] = range[4] = range[5] =  1.0e100;

      VD_findall_objects_in_range( range, 1, classid, TRUE, loc_env,
				   &loc_cnt, &objenv_list );
      __DBGpr_int("Number of Macros found", loc_cnt );
      if( !( sort_list = _MALLOC( loc_cnt, struct GRobj_env ) ) )
                vd_$mem_fail();
   }

   macro_name[0] = '\0' ;
   sort_cnt = attr_cnt = 0;

   while( fgets( line, 100, inp_fp ) )
   {
      line[strlen(line)-1] = '\0';
      __DBGpr_str( "Line", line );
      cc = line[0];
      if( cc == '#' )	
      {
	 macro_name[0] = '\0' ;
	 VDatGetNextWord( line+1, macro_name, 80 );
	 __DBGpr_str( "Macro Name", macro_name );
	 if( macro_name[0] == '\0' ) continue;
	 for( i=0; i<sort_cnt; ++i )
	 {
	    fprintf( out_fp, "Object[%d/%d] --- ", i+1, sort_cnt );
	    vdobj$Print( objOE = &sort_list[i], file = out_fp );

	    for( j=0; j<attr_cnt; ++j )
	    {
	       if( IGEstop() )
	       {
		  fprintf( out_fp, "Stop Signal Sent .....\n" );
		  fflush( out_fp );
		  goto wrapup;
	       }

	       tab =  strlen(attr_names[j]) / 8 ;
	       if( tab == 0 )  
	         fprintf( out_fp, "\t %s\t\t---> ", attr_names[j] );
	       else
		 fprintf( out_fp, "\t %s\t---> ", attr_names[j] );

               VD_getItemValueForReport( &sort_list[i],
                                         attr_names[j], attr_value );
	       fprintf( out_fp, "%s\n", attr_value );
	       fflush( out_fp );
	    }
	    if( attr_cnt ) fprintf( out_fp, "\n" );
	 }
	 if( sort_cnt ) fprintf( out_fp, "\n" );

	 sort_cnt = attr_cnt = 0;

	 sprintf( status_msg, "Collecting \"%s\" macros", macro_name );

	 UI_status( status_msg );

	 for( i=0; i<loc_cnt; ++i )
	 {
	    vdobj$Get( objOE   = &objenv_list[i],
		       macName = macName    );
	    if( VD_matchRE( macro_name, macName ) )
	    {
		sort_list[sort_cnt++] = objenv_list[i];
	    }
	 }
      }
      else if( cc == '%' && macro_name[0] != '\0' && sort_cnt )	
      {
	 AttrName[0] = '\0';
	 VDatGetNextWord( line+1, AttrName, 80 );
	 __DBGpr_str( "Attribute Name", AttrName );
	 if( AttrName[0] == '\0' ) continue;
	 strcpy( attr_names[attr_cnt++], AttrName );
      }
   }

   for( i=0; i<sort_cnt; ++i )
   {
       fprintf( out_fp, "Object[%d/%d] --- ", i+1, sort_cnt );
       vdobj$Print( objOE = &sort_list[i], file = out_fp );
       for( j=0; j<attr_cnt; ++j )
       {
          if( IGEstop() )
          {
              fprintf( out_fp, "Stop Signal Sent .....\n" );
              fflush( out_fp );
              goto wrapup;
          }

          tab =  strlen(attr_names[j]) / 8 ;
          if( tab == 0 )  
              fprintf( out_fp, "\t %s\t\t---> ", attr_names[j] );
          else
              fprintf( out_fp, "\t %s\t---> ", attr_names[j] );
	  VD_getItemValueForReport( &sort_list[i], attr_names[j], attr_value );
	  fprintf( out_fp, "%s\n", attr_value );
       }
       if( attr_cnt ) fprintf( out_fp, "\n" );
   }

wrapup:
   fclose( inp_fp );
   if( out_fp != stdout ) fclose( out_fp );
   if( is_malloc )      _FREE( objenv_list );
   _FREE( sort_list );
   return 1;
}

end implementation VDSroot;
