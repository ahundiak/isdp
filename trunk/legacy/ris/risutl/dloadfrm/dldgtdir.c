/* Do not alter this SPC information: $Revision: 1.4.3.1 $ */
/*
** NAME:		   comgtdir.c
** AUTHORS:		   Dave Buehmann
** CREATION DATE:	      2/89
** ABSTRACT:
**    
** 
** REVISION HISTORY:

	1996.06.21	Alan Barksdale	Changed .INI file name from RIS.INI to
					INGR.INI and section name from RIS-NN.NN
					to RIS\NN.NN to follow current standards
					according to Rick Kramer.  Also, needed
					to fix TR439601281.
*/
 
/*
** INCLUDES
*/
#if defined(unix)
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#endif

#if defined(WIN32)
#include <windows.h>
#include "ris.h"
#include "ris.prt"
#endif
#include "rispath.h"
#include "dloadfrm.h"

/*
** Unix System V rel 4 has a standard delivery package we may one day
** need to make use of.  Dan has done an initial port of ris installation
** using it and the MAYBE areas are those areas where changes were required.
** We're keeping them in-line as documentation and for future needs.
*/
#ifdef MAYBE
  #if defined(UNIXsysVr4_std_delivery) 
    #include <stdio.h>
    #include "net.h"
  #endif
#endif

/*
** DEFINES
*/

/*
** TYPES
*/

/*
** FUNCTION PROTOTYPES
*/
#define dldgtdir_c
#include "dlddebug.prt"
#include "dldgtdir.prt"
#include "sys.prt"

#ifdef MAYBE
    #if defined(UNIXsysVr4_std_delivery) 
     #include "netpopen.prt"
    #else  /* ! defined(UNIXsysVr4_std_delivery) */
      #include "comstcmi.prt"
      #include "comsyser.prt"
    #endif  
#endif

/*
** VARIABLES
*/
#if defined(unix)
extern int errno;
#endif

/*
** FUNCTIONS
*/

/*****************************************************************************/

/*
** Starting with RIS 4.x.x.x, older RISs will continue to work with newer ones.
** MATCH_COMPATIBLE mode algorithm is:
**    major # must be == or > than the one being requested; closest match
**    minor # must be == to requested (if major one ==) or highest one found
** rel # must be highest one found (same for seq # if later passed in)
*/

extern int RISdldFRM_get_risdir(
   char     *prodname,	   /* RIS for WIN32 right now */
   int	       version_maj,   /*  Major to look for */
   int	       version_min,   /*  Minor to look for */
   int	       version_rel,   /*  this will be ignored */
   int	       mode,	   /*  CLOSEST_MATCH */
   char     *risdir,	/*  this will set to Objects/DLL path name */
   int	       *developmentp,  /*  Set if in development mode */
   rissqlca *dbcap)	   /*  For errors */
{

#if defined(unix) || defined(WIN32)
   int	    prod_maj;
   int	    prod_min;
   int	    prod_rel;
   int	    compatible_maj = 0;
   int	    compatible_min = 0;
   int	    compatible_rel = 0;
   char  compatible_found;
   char  compatible_dir[256] = "";
   char  *prod_dir_addr = 0;
   char  prod_dir[256];
   char  *risdir_file = "/usr/ip32/ris/risdir";
   char  *config_file = "/etc/risconfig";
#if defined(unix)
   char  buffer[512];
   char  *prod_version_addr;
   char  *prodtoken;
   char  *prod_lname;
   char  *prod_sname;
   FILE  *fd;
   char  *cp;
   char  *prod_no;
   char  *prod_date;
   char  temp[512];
#endif
#endif
#if defined(WIN32)
   DWORD ProdSz = sizeof(prod_dir);
   TCHAR prod_version[20];
   TCHAR szKey[MAX_PATH+1];
   TCHAR szKey1[MAX_PATH+1];
    TCHAR   szSubKey[MAX_PATH+1];
    TCHAR   szFullSubKey[MAX_PATH+1];
   DWORD SubKeySz = sizeof(szKey);
   static TCHAR   devKey[255] = "SOFTWARE\\Intergraph\\RISDEVDIR";
   TCHAR szClass[128];
    HKEY hKey2;
    LONG lResult;
    DWORD   cchClass, dwNumSubKeys, cchMaxSubKey, cchMaxClass,
	 cValues, cchMaxValName, cbMaxValData, cbSecurityDescriptor;
    DWORD   i;
    FILETIME ftLastWrite;
    DWORD   prod_seq;
    DWORD   dwType;
   char windir[128];
   char section[128];
#endif
#ifdef MAYBE
  #if defined(UNIXsysVr4_std_delivery) 
   int	    prod_maj;
   int	    prod_min;
   int	    prod_rel;
   int	    compatible_maj = 0;
   int	    compatible_min = 0;
   int	    compatible_rel = 0;
   char  compatible_found;
   char  *cp;
   char  *prod_version_addr;
   char  *prod_dir_addr = 0;
   char  compatible_dir[256] = "";
   char  buffer[20];	/* used to read version number string */
   char  basedir[257];	/* used to read home directory string */
   char  command[80];	/* used to execute pkgparam command */
   char  temp[30];	/* used to generate /prodname string */
   FILE  *fp;
  #endif
#endif
#if defined(vms)
   int	 stat;
   int	 dir_size = RIS_MAX_PATH_SIZE - 1;
   struct item		itmlst;
   static $DESCRIPTOR(tabnam, "LNM$SYSTEM");
   static $DESCRIPTOR(lognam, "PRO_DD_RIS");
#endif

   if (RISdldFRM_debug)
   {
      RISdldFRM_output_debug("RISdld_get_risdir()\n");
      RISdldFRM_output_debug("\tprodname:<%s>\n", STRING(prodname));
      RISdldFRM_output_debug("\tvers_maj:%d vers_min:%d vers_rel:%d mode:%d\n",
	 version_maj, version_min, version_rel, mode);
      RISdldFRM_output_debug("risdir:0x%x development:0x%x dbcap:0x%x\n",
	 risdir, developmentp, dbcap);
   }

   if (developmentp)
   {
      *developmentp = 0;
   }

#if defined(unix)
   /*
   ** Check $RISDIR to override others
   */
    if ((cp = getenv("RISDEVDIR")) != NULL)
   {
	 DLD_DBG(("found risdir environment variable:<%s>\n", cp));
	 strcpy(risdir, cp);
	 if (developmentp)
	 {
	    *developmentp = 1;
	 }
      DLD_DBG(("RISdldFRM_get_risdir:complete\n\trisdir:<%s>\n",risdir));
      return(0);
   }
   /*
   ** check for risdir_file
   */
   else if (risdir_file && ((fd = fopen(risdir_file,"r")) != NULL))
   {
      DLD_DBG(("found risdir file:<%s>\n", risdir_file));

      cp = fgets(buffer, sizeof(buffer), fd);
      fclose(fd);
      if (!cp)
      {
	 DLD_DBG(("RISdldFRM_get_risdir:exiting fgets error reading %s\n",
		risdir_file));
	 return(RIS_E_CANT_GET_RISDIR);
      }
      cp = strtok(buffer,"\n");
      strcpy(risdir, cp);

      if (developmentp)
      {
	 *developmentp = 1;
      }
   }
   /*
   ** Read config file (on clipper, sun, and sco)
   */
   else
   {
      compatible_found = 0;
      compatible_min = -1;
      compatible_rel = -1;

      DLD_DBG(("checking config file:<%s>\n", config_file));

      fd = fopen(config_file,"r");
      if (!fd)
      {
	 syserr(errno, dbcap);
	 DLD_DBG(("RISdldFRM_get_risdir:exiting CANT OPEN INGRCONFIG\n"));
	 return(RIS_E_CANT_OPEN_INGRCONFIG);
      }

      while (fgets(buffer, sizeof(buffer), fd))
      {
	 prod_no = strtok(buffer,"#");    /* product number */
	 prod_sname = strtok(0,"#");         /* product short name */
	 prod_lname = strtok(0,"#");         /* product long short name */
	 prod_version_addr = strtok(0,"#");     /* product version */
	 prod_date = strtok(0,"#");       /* product date */
	 prod_dir_addr = strtok(0,"#");         /* product directory */
	 strcpy(prod_dir, prod_dir_addr);

	 DLD_DBG(("found prodname:<%s>\n", prod_sname));

	 strcpy(temp, prodname);
	 for (prodtoken = strtok(temp, ":");
	     prodtoken;
	     prodtoken = strtok(0, ":"))
	 {
	    /* 
	    ** ignore case ???
	    */
	    if (strcmp(prod_sname, prodtoken))
	    {
	       DLD_DBG(("prodnames don't match <%s> <%s>\n",
		  prod_sname, prodtoken));
	    }
	    else
	    {
	       DLD_DBG(("found matching prodname  <%s> <%s>\n",
		  prod_sname, prodtoken));
	       break;
	    }
	 }
	 if (!prodtoken)
	 {
	    continue;
	 }

	 DLD_DBG(("found version:<%s>\n",prod_version_addr));
	 if (sscanf(prod_version_addr, "%d.%d.%d", &prod_maj, &prod_min,
	    &prod_rel) != 3)
	 {
	    DLD_DBG(("invalid version string\n"));
	    continue;
	 }

	 if (version_maj > 3)
	 {
	    /*
	    ** NOTE:  Changes to this switch block must also be made
	    **	     lower down where it is duplicated
	    */
	    switch (mode)
	    {
		case MATCH_MAJOR_MINOR_RELEASE:
		{
		   if (version_maj == prod_maj &&
		     version_min == prod_min &&
		     version_rel == prod_rel)
		   {
		     DLD_DBG(("release versions match\n"));
		     compatible_maj = prod_maj;
		     compatible_min = prod_min;
		     compatible_rel = prod_rel;
		     strcpy(compatible_dir, prod_dir);
		     compatible_found = 1;
		     DLD_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
			 compatible_maj,compatible_min,compatible_rel,
			 compatible_dir));
		  }
		  else
		  {
		     DLD_DBG(("release versions don't match\n"));
		     continue;
		  }
		   break;
	       }
		case MATCH_COMPATIBLE:
		{
		   if (prod_maj >= version_maj)
		  {
		     /* check major # */
		     if (prod_maj == compatible_maj)
		     {
			/* check minor # */
			if (prod_maj == version_maj &&
			   prod_min == version_min)
			{
			   /* check rel # */
			   if (prod_min < compatible_min ||
			      prod_rel > compatible_rel)
			   {
			      compatible_maj = prod_maj;
			      compatible_min = prod_min;
			      compatible_rel = prod_rel;
			      strcpy(compatible_dir, prod_dir);
			      compatible_found = 1;
			      DLD_DBG(("Good Ver: %d.%d.%d dir:%s\n",
				    compatible_maj,compatible_min,
				    compatible_rel,compatible_dir));
			      continue;
			   }
			}
			if (prod_min > compatible_min &&
			   compatible_min != version_min)
			{
			   compatible_maj = prod_maj;
			   compatible_min = prod_min;
			   compatible_rel = prod_rel;
			   strcpy(compatible_dir, prod_dir);
			   compatible_found = 1;
			   DLD_DBG(("Good Ver: %d.%d.%d dir:%s\n",
				 compatible_maj,compatible_min,
				 compatible_rel,compatible_dir));
			   continue;
			}
			if (prod_min == compatible_min &&
			   prod_rel > compatible_rel )
			{
			   compatible_maj = prod_maj;
			   compatible_min = prod_min;
			   compatible_rel = prod_rel;
			   strcpy(compatible_dir, prod_dir);
			   compatible_found = 1;
			   DLD_DBG(("Good Ver: %d.%d.%d dir:%s\n",
				 compatible_maj,compatible_min,
				 compatible_rel,compatible_dir));
			   continue;
			}
			continue;
		     }
		     if (compatible_maj == 0 ||
			prod_maj < compatible_maj)
		        
		     {
			compatible_maj = prod_maj;
			compatible_min = prod_min;
			compatible_rel = prod_rel;
			strcpy(compatible_dir, prod_dir);
			compatible_found = 1;
			DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			       compatible_maj,compatible_min,
			       compatible_rel,compatible_dir));
			continue;
		     }
		  } /* if */
		   break;
	       } /* MATCH_COMPATIBLE */
		case MATCH_HIGHEST: 
		{
		  if (prod_maj > compatible_maj)
		  {
		     compatible_maj = prod_maj;
		     compatible_min = prod_min;
		     compatible_rel = prod_rel;
		     strcpy(compatible_dir, prod_dir);
		     compatible_found = 1;
		     DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			    compatible_maj,compatible_min,
			    compatible_rel,compatible_dir));
		     continue;
		  }
		  if (prod_maj == compatible_maj)
		  {
		     if (prod_min > compatible_min)
		     {
			compatible_maj = prod_maj;
			compatible_min = prod_min;
			compatible_rel = prod_rel;
			strcpy(compatible_dir, prod_dir);
			compatible_found = 1;
			DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			       compatible_maj,compatible_min,
			       compatible_rel,compatible_dir));
			continue;
		     }
		     if (prod_min == compatible_min &&
			prod_rel > compatible_rel)
		     {
			compatible_maj = prod_maj;
			compatible_min = prod_min;
			compatible_rel = prod_rel;
			strcpy(compatible_dir, prod_dir);
			compatible_found = 1;
			DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			       compatible_maj,compatible_min,
			       compatible_rel,compatible_dir));
			continue;
		     }
		  }
		   break;
	       } /* MATCH_HIGHEST */
	    } /* switch */
	 }
	 else  /* version_maj <= 3 */
	 {
	    if (version_maj == prod_maj)
	    {
	       /*
	       ** Major matches
	       */
	       DLD_DBG(("major versions match\n"));
	       if (mode == MATCH_MAJOR)
	       {
		  if (prod_min > compatible_min)
		  {
		     compatible_maj = prod_maj;
		     compatible_min = prod_min;
		     compatible_rel = prod_rel;
		     strcpy(compatible_dir, prod_dir);
		     compatible_found = 1;
		     DLD_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
			 compatible_maj,compatible_min,compatible_rel,
			 compatible_dir));
		  }
		  continue;
	       }
	    }
	    else
	    {
	       DLD_DBG(("major versions don't match\n"));
	       continue;
	    }

	    if (version_min == prod_min)
	    {
	       /*
	       ** Major & minor match
	       */
	       DLD_DBG(("minor versions match\n"));
	       if (mode == MATCH_MAJOR_MINOR)
	       {
		  if (prod_rel > compatible_rel)
		  {
		     compatible_maj = prod_maj;
		     compatible_min = prod_min;
		     compatible_rel = prod_rel;
		     strcpy(compatible_dir, prod_dir);
		     compatible_found = 1;
		     DLD_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
			 compatible_maj,compatible_min,compatible_rel,
			 compatible_dir));
		  }
		  continue;
	       }
	    }
	    else
	    {
	       DLD_DBG(("minor versions don't match\n"));
	       continue;
	    }

	    if (version_rel == prod_rel)
	    {
	       /*
	       ** Major, minor & release match
	       */
	       DLD_DBG(("release versions match\n"));
	       if (mode == MATCH_MAJOR_MINOR_RELEASE)
	       {
		  compatible_maj = prod_maj;
		  compatible_min = prod_min;
		  compatible_rel = prod_rel;
		  strcpy(compatible_dir, prod_dir);
		  compatible_found = 1;
		  DLD_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
			 compatible_maj,compatible_min,compatible_rel,
			 compatible_dir));
		  break;
	       }
	    }
	    else
	    {
	       DLD_DBG(("release versions don't match\n"));
	       continue;
	    }
	 }  /* version_maj <= 3 */

      }  /* while */

      fclose(fd);

      if (compatible_found)
      {
	 DLD_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
	    compatible_maj,compatible_min,compatible_rel,compatible_dir));
	 strcpy(risdir, compatible_dir);
      }
      else
      {
	 DLD_DBG(("RISdldFRM_get_risdir:exiting CANT FIND PRODUCT\n"));
	 return(RIS_E_CANT_FIND_PRODUCT);
      }
   }  /* else config file */
#endif
#if defined(WIN32)
   if (dldget_platform() != IS_WIN32S)
   {

   if (((lResult = RegOpenKeyEx(HKEY_LOCAL_MACHINE, devKey,
	       0, KEY_READ, &hKey2)) == ERROR_SUCCESS)
      &&
      (GetRegKeyValueEx(HKEY_LOCAL_MACHINE,devKey,
	 "PathName", &dwType, prod_dir, 255) == ERROR_SUCCESS))
   {
      DLD_DBG(("RISdldFRM_get_risdir: RISDEVDIR PathName:<%s>\n", prod_dir));
      strcpy(risdir, prod_dir);
      if (developmentp)
      {
	 *developmentp = 1;
      }
      RegCloseKey(hKey2);

      DLD_DBG(("RISdldFRM_get_risdir:complete\n\trisdir:<%s>\n",risdir));
      return(0);
   }
   /*
   ** Read registry (NT)
   */
      else
   {
      strcpy(szKey1, "Software\\Intergraph");
      sprintf(szKey, "%s\\%s", szKey1, prodname);

      DLD_DBG(("RISdldFRM_get_risdir:Opening Reg. key <%s>\n", szKey));
      if ((lResult = RegOpenKeyEx(HKEY_LOCAL_MACHINE, szKey, 0, KEY_READ,
			   &hKey2)) != ERROR_SUCCESS)
      {
	 DLD_DBG(("RISdldFRM_get_risdir:exiting CANT FIND REG PRODUCT\n"));
	 return(RIS_E_CANT_FIND_REG_PRODUCT);
      }

      cchClass=128;
      if ((lResult = RegQueryInfoKey(hKey2, szClass, &cchClass,
		  NULL, &dwNumSubKeys, &cchMaxSubKey, &cchMaxClass,
		  &cValues, &cchMaxValName, &cbMaxValData,
		  &cbSecurityDescriptor, &ftLastWrite)) != ERROR_SUCCESS)
      {
	 DLD_DBG(("RISdldFRM_get_risdir:exiting CANT FIND REG PRODUCT\n"));
	 return(RIS_E_CANT_FIND_REG_PRODUCT);   
      }

      if (dwNumSubKeys)
      {
	 DLD_DBG(("RISdldFRM_get_risdir:found %d Subkeys\n", dwNumSubKeys));

	 for (i = 0; i < dwNumSubKeys; i++)
	 {
		szSubKey[0] = '\0';
		SubKeySz = MAX_PATH + 1;
		if ((lResult = RegEnumKeyEx(hKey2, i, szSubKey, &SubKeySz,
		    0, NULL, NULL, &ftLastWrite)) == ERROR_SUCCESS)
	    {
	       DLD_DBG(("SubKey# %d: <%s>\n", i, szSubKey));

	       sprintf(szFullSubKey, "%s\\%s", szKey, szSubKey);

	       if (GetRegKeyValueEx(HKEY_LOCAL_MACHINE,szFullSubKey,
		  "Version", &dwType, prod_version, sizeof(prod_version))
		     != ERROR_SUCCESS)
	       {
		  DLD_DBG(("could'nt get version. continuing...\n"));
		  continue;
	       }
	       DLD_DBG(("Version:<%s>\n", prod_version));

	       //
	       // Note: we dont really use the prod_seq value. But
	       // we store it in the registry for possible future use.
	       //
	       if (sscanf(prod_version, "%d.%d.%d.%d",&prod_maj,&prod_min,
		  &prod_rel, &prod_seq) != 4)
	       {
		  DLD_DBG(("invalid version string, continuing...\n"));
		  continue;
	       }

		    if (GetRegKeyValueEx(HKEY_LOCAL_MACHINE,szFullSubKey,
			"PathName", &dwType, prod_dir, sizeof(prod_dir))
		  != ERROR_SUCCESS)
		    {
			DLD_DBG(("could'nt get PathName; continuing..\n"));
			continue;
		    }
 
	       DLD_DBG(("PathName:<%s>\n", prod_dir));

	       /*
	       ** NOTE:  Changes to this switch block must also be made
	       **	up above where it is duplicated
	       */
	       switch (mode)
	       {
		  case MATCH_MAJOR_MINOR_RELEASE:
		  {
		   if (version_maj == prod_maj &&
		     version_min == prod_min &&
		     version_rel == prod_rel)
		   {
		     DLD_DBG(("release versions match\n"));
		     compatible_maj = prod_maj;
		     compatible_min = prod_min;
		     compatible_rel = prod_rel;
		     strcpy(compatible_dir, prod_dir);
		     compatible_found = 1;
		     DLD_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
			 compatible_maj,compatible_min,compatible_rel,
			 compatible_dir));
		  }
		  else
		  {
		     DLD_DBG(("release versions don't match\n"));
		     continue;
		  }
		   break;
		 } /* MATCH_MAJOR_MINOR_RELEASE */
		  case MATCH_COMPATIBLE:
		  {
		   if (prod_maj >= version_maj)
		  {
		     /* check major # */
		     if (prod_maj == compatible_maj)
		     {
			/* check minor # */
			if (prod_maj == version_maj &&
			   prod_min == version_min)
			{
			   /* check rel # */
			   if (prod_min < compatible_min ||
			      prod_rel > compatible_rel)
			   {
			      compatible_maj = prod_maj;
			      compatible_min = prod_min;
			      compatible_rel = prod_rel;
			      strcpy(compatible_dir, prod_dir);
			      compatible_found = 1;
			      DLD_DBG(("Good Ver: %d.%d.%d dir:%s\n",
				    compatible_maj,compatible_min,
				    compatible_rel,compatible_dir));
			      continue;
			   }
			}
			if (prod_min > compatible_min &&
			   compatible_min != version_min)
			{
			   compatible_maj = prod_maj;
			   compatible_min = prod_min;
			   compatible_rel = prod_rel;
			   strcpy(compatible_dir, prod_dir);
			   compatible_found = 1;
			   DLD_DBG(("Good Ver: %d.%d.%d dir:%s\n",
				 compatible_maj,compatible_min,
				 compatible_rel,compatible_dir));
			   continue;
			}
			if (prod_min == compatible_min &&
			   prod_rel > compatible_rel )
			{
			   compatible_maj = prod_maj;
			   compatible_min = prod_min;
			   compatible_rel = prod_rel;
			   strcpy(compatible_dir, prod_dir);
			   compatible_found = 1;
			   DLD_DBG(("Good Ver: %d.%d.%d dir:%s\n",
				 compatible_maj,compatible_min,
				 compatible_rel,compatible_dir));
			   continue;
			}
			continue;
		     }
		     if (compatible_maj == 0 ||
			prod_maj < compatible_maj)
		        
		     {
			compatible_maj = prod_maj;
			compatible_min = prod_min;
			compatible_rel = prod_rel;
			strcpy(compatible_dir, prod_dir);
			compatible_found = 1;
			DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			       compatible_maj,compatible_min,
			       compatible_rel,compatible_dir));
			continue;
		     }
		  } /* if */
		   break;
		 } /* MATCH_COMPATIBLE */
		  case MATCH_HIGHEST: 
		  {
		  if (prod_maj > compatible_maj)
		  {
		     compatible_maj = prod_maj;
		     compatible_min = prod_min;
		     compatible_rel = prod_rel;
		     strcpy(compatible_dir, prod_dir);
		     compatible_found = 1;
		     DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			    compatible_maj,compatible_min,
			    compatible_rel,compatible_dir));
		     continue;
		  }
		  if (prod_maj == compatible_maj)
		  {
		     if (prod_min > compatible_min)
		     {
			compatible_maj = prod_maj;
			compatible_min = prod_min;
			compatible_rel = prod_rel;
			strcpy(compatible_dir, prod_dir);
			compatible_found = 1;
			DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			       compatible_maj,compatible_min,
			       compatible_rel,compatible_dir));
			continue;
		     }
		     if (prod_min == compatible_min &&
			prod_rel > compatible_rel)
		     {
			compatible_maj = prod_maj;
			compatible_min = prod_min;
			compatible_rel = prod_rel;
			strcpy(compatible_dir, prod_dir);
			compatible_found = 1;
			DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			       compatible_maj,compatible_min,
			       compatible_rel,compatible_dir));
			continue;
		     }
		  }
		   break;
		 } /* MATCH_HIGHEST */
	      } /* switch */
	    } /* if */
	    else
	    {
	       DLD_DBG(("lResult after enumeration:%d\n", lResult));
	    }
	 } /* for */
      }  /* if */
      else
      {
	 DLD_DBG(("RISdldFRM_get_risdir:exiting CANT FIND REG PRODUCT\n"));
	 return(RIS_E_CANT_FIND_REG_PRODUCT);   
      }
    } /* else registry */

   RegCloseKey(hKey2);
   if (compatible_found)
   {
      DLD_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
	 compatible_maj,compatible_min,compatible_rel,compatible_dir));
      strcpy(risdir, compatible_dir);
   }
   else
   {
      DLD_DBG(("RISdldFRM_get_risdir:exiting CANT FIND PRODUCT\n"));
      return(RIS_E_CANT_FIND_PRODUCT);
   }
   }
   else
   {
      /* WIN32S */
   prod_min=0;
   prod_maj=0;
   compatible_found = '\0';
   prod_rel=0;
   GetWindowsDirectory(windir,128);

   GetPrivateProfileString("RISDEVDIR","PathName","Default",prod_dir,128,"INGR.INI");
   
   if (strcmp(prod_dir,"Default") !=0)
   {
      DLD_DBG(("RISdld_get_risdir: RISDEVDIR PathName:<%s>\n", prod_dir));
      strcpy(risdir, prod_dir);
      if (developmentp)
      {
	 *developmentp = 1;
      }

      DLD_DBG(("RISdld_get_risdir:complete\n\trisdir:<%s>\n",risdir));
      return(0);
   }
   else
   {
   /*
   ** Read INGR.INI file
   */
      sprintf(section,"%s\\%02d.%02d",prodname,version_maj,version_min);
      DLD_DBG(("section: %s\n",section));

      GetPrivateProfileString(section,"PathName","Default",prod_dir,128,"INGR.INI");
      if (strcmp(prod_dir,"")==0)
      {
	 DLD_DBG(("RISdld_get_risdir:exiting CANT FIND REG PRODUCT\n"));
	 return(RIS_E_CANT_FIND_REG_PRODUCT);
      }

	       GetPrivateProfileString(section,"Version","Default",prod_version,sizeof(prod_version),"INGR.INI");
	       if (strcmp(prod_version,"Default") ==0)
	       {
		  DLD_DBG(("could'nt get version. continuing...\n"));
	       }
	       DLD_DBG(("Version:<%s>\n", prod_version));

	       //
	       // Note: we dont really use the prod_seq value. But
	       // we store it in the registry for possible future use.
	       //
	       if (sscanf(prod_version, "%d.%d.%d.%d",&prod_maj,&prod_min,
		  &prod_rel, &prod_seq) != 4)
	       {
		  DLD_DBG(("invalid version string, continuing...\n"));
	       }

	       GetPrivateProfileString(section,"PathName","Default",prod_dir,sizeof(prod_dir),"INGR.INI");
	       if (strcmp(prod_dir,"Default") !=0)
	       {
		       DLD_DBG(("could'nt get PathName; continuing..\n"));
	       }
 
	       DLD_DBG(("PathName:<%s>\n", prod_dir));

	       /*
	       ** NOTE:  Changes to this switch block must also be made
	       **	up above where it is duplicated
	       */
	       switch (mode)
	       {
		  case MATCH_MAJOR_MINOR_RELEASE:
		  {
		   if (version_maj == prod_maj &&
		     version_min == prod_min &&
		     version_rel == prod_rel)
		   {
		     DLD_DBG(("release versions match\n"));
		     compatible_maj = prod_maj;
		     compatible_min = prod_min;
		     compatible_rel = prod_rel;
		     strcpy(compatible_dir, prod_dir);
		     compatible_found = 1;
		     DLD_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
			 compatible_maj,compatible_min,compatible_rel,
			 compatible_dir));
		  }
		  else
		  {
		     DLD_DBG(("release versions don't match\n"));
		  }
		   break;
		 } /* MATCH_MAJOR_MINOR_RELEASE */
		  case MATCH_COMPATIBLE:
		  {
		   if (prod_maj >= version_maj)
		  {
		     /* check major # */
		     if (prod_maj == compatible_maj)
		     {
			/* check minor # */
			if (prod_maj == version_maj &&
			   prod_min == version_min)
			{
			   /* check rel # */
			   if (prod_min < compatible_min ||
			      prod_rel > compatible_rel)
			   {
			      compatible_maj = prod_maj;
			      compatible_min = prod_min;
			      compatible_rel = prod_rel;
			      strcpy(compatible_dir, prod_dir);
			      compatible_found = 1;
			      DLD_DBG(("Good Ver: %d.%d.%d dir:%s\n",
				    compatible_maj,compatible_min,
				    compatible_rel,compatible_dir));
			   }
			}
			if (prod_min > compatible_min &&
			   compatible_min != version_min)
			{
			   compatible_maj = prod_maj;
			   compatible_min = prod_min;
			   compatible_rel = prod_rel;
			   strcpy(compatible_dir, prod_dir);
			   compatible_found = 1;
			   DLD_DBG(("Good Ver: %d.%d.%d dir:%s\n",
				 compatible_maj,compatible_min,
				 compatible_rel,compatible_dir));
			}
			if (prod_min == compatible_min &&
			   prod_rel > compatible_rel )
			{
			   compatible_maj = prod_maj;
			   compatible_min = prod_min;
			   compatible_rel = prod_rel;
			   strcpy(compatible_dir, prod_dir);
			   compatible_found = 1;
			   DLD_DBG(("Good Ver: %d.%d.%d dir:%s\n",
				 compatible_maj,compatible_min,
				 compatible_rel,compatible_dir));
			}
		     }
		     if (compatible_maj == 0 ||
			prod_maj < compatible_maj)
		        
		     {
			compatible_maj = prod_maj;
			compatible_min = prod_min;
			compatible_rel = prod_rel;
			strcpy(compatible_dir, prod_dir);
			compatible_found = 1;
			DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			       compatible_maj,compatible_min,
			       compatible_rel,compatible_dir));
		     }
		  } /* if */
		   break;
		 } /* MATCH_COMPATIBLE */
		  case MATCH_HIGHEST: 
		  {
		  if (prod_maj > compatible_maj)
		  {
		     compatible_maj = prod_maj;
		     compatible_min = prod_min;
		     compatible_rel = prod_rel;
		     strcpy(compatible_dir, prod_dir);
		     compatible_found = 1;
		     DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			    compatible_maj,compatible_min,
			    compatible_rel,compatible_dir));
		  }
		  if (prod_maj == compatible_maj)
		  {
		     if (prod_min > compatible_min)
		     {
			compatible_maj = prod_maj;
			compatible_min = prod_min;
			compatible_rel = prod_rel;
			strcpy(compatible_dir, prod_dir);
			compatible_found = 1;
			DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			       compatible_maj,compatible_min,
			       compatible_rel,compatible_dir));
		     }
		     if (prod_min == compatible_min &&
			prod_rel > compatible_rel)
		     {
			compatible_maj = prod_maj;
			compatible_min = prod_min;
			compatible_rel = prod_rel;
			strcpy(compatible_dir, prod_dir);
			compatible_found = 1;
			DLD_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
			       compatible_maj,compatible_min,
			       compatible_rel,compatible_dir));
		     }
		  }
		   break;
		 } /* MATCH_HIGHEST */
	      } /* switch */
   } /* else INGR.INI */

   if (compatible_found)
   {
      DLD_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
	 compatible_maj,compatible_min,compatible_rel,compatible_dir));
      strcpy(risdir, compatible_dir);
   }
   else
   {
      DLD_DBG(("RISdld_get_risdir:exiting CANT FIND PRODUCT\n"));
      return(RIS_E_CANT_FIND_PRODUCT);
   }
   }
#endif

   DLD_DBG(("RISdldFRM_get_risdir:complete\n\trisdir:<%s>\n",risdir));
   return(0);
}

/**************************************************************************/

#if defined(WIN32)
/**************************************************************************/
static LONG GetRegKeyValueEx(
   HKEY hKey,
   LPCTSTR szKey,
   LPTSTR szValueName,
   LPDWORD lpdwType,
   LPBYTE lpBuf,
   DWORD cbBuf)
{
   HKEY  hKey2;
   DWORD cb = cbBuf;
    LONG lRetVal;

   DLD_DBG(("GetRegKeyValueEx(hKey:0x%x, szKey:0x%x, szValueName:%s\n",
      hKey, szKey, szValueName));

    if (lRetVal = RegOpenKeyEx(hKey, szKey, 0, KEY_READ, &hKey2) != ERROR_SUCCESS)
   {
      RegCloseKey(hKey2);
      DLD_DBG(("GetRegKeyValueEx(RegOpenKeyEx error:%d\n", lRetVal));
      DLD_DBG(("GetRegKeyValueEx:complete\n"));
      return(ERROR_BADKEY);
   }
   if (lRetVal = RegQueryValueEx(hKey2, (LPTSTR)szValueName, NULL,
      lpdwType, lpBuf, &cb) != ERROR_SUCCESS)
   {
      RegCloseKey(hKey2);
      DLD_DBG(("GetRegKeyValueEx(RegQueryKeyEx error:%d\n", lRetVal));
      DLD_DBG(("GetRegKeyValueEx:complete\n"));
      return(ERROR_BADKEY);
   }
   DLD_DBG(("GetRegKeyValueEx:complete\n"));
   return(lRetVal);
}
#endif /* WIN32 */

/*****************************************************************************/

extern void RISdldFRM_generate_path(
   char *ris_objects,
   char *ris_dir,
   int	  development)
{
   if( development )
   {
      sprintf(ris_objects, "%s%c%s%c%s%c%s%c%s", ris_dir, PATH_CHAR, "risutl", 
	 PATH_CHAR, "lib", PATH_CHAR, PLATFORM, PATH_CHAR, RIS_OBJECT_NAME);
   }
   else
   {
      sprintf(ris_objects, "%s%c%s%c%s", ris_dir, PATH_CHAR, "lib", PATH_CHAR, 
	 RIS_OBJECT_NAME);
   }
}

/*****************************************************************************/
#if defined(WIN32)
static int dldget_platform(
   )
{
/* This function returns the WIN32 platform that the user is running under */
   DWORD    win_vers;

    win_vers = GetVersion();
    if( ( win_vers & 0x80000000 ) == 0 )
    {
	/* this is real Windows NT */
      if (LOBYTE( LOWORD( win_vers ) ) ==3 &&
	 HIBYTE( LOWORD( win_vers ) ) == 10)
      {
	 DLD_DBG(("RISget_platform(WIN32 ret_value:<%d>)\n", IS_WIN32));
	 return (IS_WIN32);
      }
      else
      {
	 DLD_DBG(("RISget_platform(DAYTONA ret_value:<%d>)\n", IS_DAYTONA));
	 return(IS_DAYTONA);
      }
    }
    else
    {
	if( LOBYTE( LOWORD( win_vers ) ) < 4 )
	{
	    /* this is Win32s running on 16-bit Windows 3.1,
	       because the program is running in 32-bit mode it
	       cannot easily determine the version of Win32s as
	       that info comes from a 16-bit DLL - good innit.
	       the program *could* work out the version, but it
	       would require a 16-bit DLL to thunk to, and that
	       just is not worth the effort. */
	    DLD_DBG(("RISget_platform(WIN32s ret_value:<%d>)\n", IS_WIN32S));
	    return(IS_WIN32S);
	}
	else
	{
	    /* this is Chicago - Windows 4.x */
	    DLD_DBG(("RISget_platform(CHICAGO ret_value:<%d>)\n", IS_CHICAGO));
	    return(IS_CHICAGO);
	}
    }
}
#endif /* WIN32 */

