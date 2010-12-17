#include "machine.h"
#include "CVT.h"
#include <pwd.h>

  extern struct CVTglobal_st CVTglobal ;

  static char *titles_c [] = { "Delete .dmp & scripts",
			      "Delete old tables",
			      "Delete reports directory",
			      NULL } ;

  static char *other_c[] ={"-----------------------------------", 
			     "" ,
			     "Control C - To Terminate Conversion now",
			     "PF1       - To Resume Conversion now",
			     NULL } ;


static char *defs_v [] = { "n", "n", "n", NULL } ;

static short attrs_c[] = { 0, 0, 0, NULL } ;

static char *extra_char_c[] = {"", "", "", NULL} ;

long CVTcompletion_check ()
{
  char *fname = "CVTcompletion_check" ;
  UNIT_INFO dat1 ;
  char **defs_b ;
  long status, y ;
  char del_dmp, del_tab , del_rep ;
  char status_flag [40] ;
  long last_row ;
  char pth [200], rm_str [500], message [200] ;
  struct passwd *pswd_ptr ;
  struct stat fbuf;

  _NFMdebug ((fname, "ENTER\n")) ;
  /* check nfmcvtlog -> cvtstatus for all sections to be completed */

  status = CVTquery_cvtlog_entry ("CVTSTATUS1", status_flag, &last_row) ;
  if (status != NFM_S_SUCCESS)
    {
      strcpy (message, "Section 1 of conversion not finished") ;
      _NFMdebug ((fname, "%s\n", message)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }

  status = CVTquery_cvtlog_entry ("CVTSTATUS2", status_flag, &last_row) ;
  if (status != NFM_S_SUCCESS)
    {
      strcpy (message, "Section 2 of conversion not finished") ;
      _NFMdebug ((fname, "%s\n", message)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }

  status = CVTquery_cvtlog_entry ("CVTSTATUS3", status_flag, &last_row) ;
  if (status != NFM_S_SUCCESS)
    {
      strcpy (message, "Section 3 of conversion not finished") ;
      _NFMdebug ((fname, "%s\n", message)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }

  status = CVTquery_cvtlog_entry ("CVTSTATUS4", status_flag, &last_row) ;
  if (status != NFM_S_SUCCESS)
    {
      strcpy (message, "Section 4 of conversion not finished") ;
      _NFMdebug ((fname, "%s\n", message)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }

  status = CVTquery_cvtlog_entry ("CVTSTATUS5", status_flag, &last_row) ;
  if (status != NFM_S_SUCCESS)
    {
      strcpy (message, "Section 5 of conversion not finished") ;
      _NFMdebug ((fname, "%s\n", message)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }

  /** all sections are complete **/
  /* put stuff in screen */

  defs_b = (char **) malloc (3*sizeof(char *)) ;
  if (defs_b == NULL)
    {
      _NFMdebug ((fname, "Failure : Malloc\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  for (y=0; y<3; y++)
    {
      defs_b[y] = (char *) malloc (strlen (defs_v[y]) + 1) ;
      if (defs_b[y] == NULL)
	{
	  _NFMdebug ((fname, "Failure : Malloc\n")) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  return (NFM_E_MALLOC) ;
	}

      strcpy (defs_b[y], defs_v[y]) ;
    }

  for (y=0; y<30; y++) fprintf (stderr, "\n") ;

  menu("CHECK/CLEANUP", titles_c, defs_b, attrs_c,
       extra_char_c, &dat1, other_c) ;

  del_dmp =  dat1.data [0][0] ;
  del_tab =  dat1.data [1][0] ;
  del_rep = dat1.data [2][0] ;
  _NFMdebug ((fname, "%s %s %s\n", del_dmp, del_tab, del_rep)) ;

  for (y=0; y<3; y++) if (defs_b[y]) free (defs_b[y]) ;
  if (defs_b) free (defs_b) ;

  status = confirmation () ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if ((del_dmp == 'y') || (del_dmp == 'Y'))
    {
      fprintf (stderr, "deleting dump files..\n") ;
      unlink ("s_tables.dmp") ;
      unlink ("cvt.dmp") ;
      unlink ("CVTcatalog.dmp") ;
      unlink ("CVTtable.dmp") ;
      unlink ("SAVECVTcat.dmp") ;
      fprintf (stderr, "deleting script files..\n") ;
      unlink ("CVTNScat.sh") ;
      unlink ("CVTNcat.sh") ;
      unlink ("CVTtable.sh") ;
	  /*unlink ("CVTcat.sh") ;*/
	  unlink ("CVTcat.bad") ;
	  unlink ("CVTcat.log") ;
    }

  if ((del_tab == 'y') || (del_tab == 'Y'))
    {
      fprintf (stderr, "dropping o_<tables>..\n") ;
      SQLstmt ("drop table o_nfmaccess") ;
      SQLstmt ("drop table o_nfmacls") ;
      SQLstmt ("drop table o_nfmaclusers") ;
      SQLstmt ("drop table o_nfmactivity") ;
      SQLstmt ("drop table o_nfmarchives") ;
      SQLstmt ("drop table o_nfmattributes") ;
      SQLstmt ("drop table o_nfmcatalogaclmap") ;
      SQLstmt ("drop table o_nfmcatalogs") ;
      SQLstmt ("drop table o_nfmcatalogsamap") ;
      SQLstmt ("drop table o_nfmclasses") ;
      SQLstmt ("drop table o_nfmcommands") ;
      SQLstmt ("drop table o_nfmindex") ;
      SQLstmt ("drop table o_nfmlists") ;
      SQLstmt ("drop table o_nfmnodes") ;
      SQLstmt ("drop table o_nfmprocesses") ;
      SQLstmt ("drop table o_nfmprograms") ;
      SQLstmt ("drop table o_nfmprojectaclmap") ;
      SQLstmt ("drop table o_nfmprojectcit") ;
      SQLstmt ("drop table o_nfmprojects") ;
      SQLstmt ("drop table o_nfmprojectsamap") ;
      SQLstmt ("drop table o_nfmreports") ;
      SQLstmt ("drop table o_nfmprojectsamap") ;
      SQLstmt ("drop table o_nfmreports") ;
      SQLstmt ("drop table o_nfmsafiles") ;
      SQLstmt ("drop table o_nfmsavesets") ;
      SQLstmt ("drop table o_nfmsetcit") ;
      SQLstmt ("drop table o_nfmsignoff") ;
      SQLstmt ("drop table o_nfmsignoffusers") ;
      SQLstmt ("drop table o_nfmstates") ;
      SQLstmt ("drop table o_nfmstoragearea") ;
      SQLstmt ("drop table o_nfmsysattributes") ;
      SQLstmt ("drop table o_nfmtables") ;
      SQLstmt ("drop table o_nfmtransitions") ;
      SQLstmt ("drop table o_nfmusers") ;
      SQLstmt ("drop table o_nfmvalues") ;
      SQLstmt ("drop table o_nfmworkflow") ;
      SQLstmt ("drop table o_nfmsyscat") ;
      SQLstmt ("drop table f_nfmsyscat") ;
      SQLstmt ("drop table s_nfmsysattributes") ;
    }
  if ((del_rep == 'y') || (del_rep == 'Y'))
    {
      pswd_ptr =  getpwnam("nfmadmin");
      sprintf(pth, "%s/%s/reports", pswd_ptr -> pw_dir, CVTglobal.env_name);
      sprintf (rm_str, "rm -rf %s", pth) ;
      fprintf (stderr, "removing %s..\n", pth) ;
      status = system (rm_str) ;
      if (status)
	{
	  _NFMdebug ((fname, "Remove directories failed : errno <%d>\n",
		      errno));
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
			  "removing reports subdirectory failed") ;
/*	  return (NFM_E_MESSAGE) ; */
	}
    }
  status = CVTnfmsyscat () ;
  if (status != NFM_S_SUCCESS)
    {
      strcpy (message, "NFMSYSCAT FAILED TO BE LOADED") ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }

  status = CVTupdate_cvtlog ("CVTSTATUS6", "C", -1 );
  if (status != NFM_S_SUCCESS)
  {
	_NFMdebug((fname, "Failure : status = <0x%.8x>\n", status));
	ERRload_struct (NFM, NFM_E_FAILURE, "", "");
	return (NFM_E_FAILURE);
  }

  status = stat ("CVTbad_in.ris", &fbuf) ;
  if (status == 0)
    {
      fprintf (stderr, "****** WARNING ********\nCHECK/EDIT CVTbad_in.ris for bad insert statements\n1) add default schema statement 2) edit/correct insert statements 3) add exit statement 4) run $ris <CVTbad_in.ris") ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}



