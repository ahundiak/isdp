/* Do not alter this PINNACLE information: $Revision: 1.6.3.1 $ */
/*
**	NAME:							comgtdir.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					2/89
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:

	1996.06.21	Alan Barksdale	Changed .INI file name from RIS.INI to
					INGR.INI and section name from RIS-NN.NN
					to RIS\NN.NN to follow current standards
					according to Rick Kramer.  Also, needed
					to fix TR439601281.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <errno.h>

#include "riscom.h"
#include "ris_err.h"
#include "risdebug.h"
#include "risprods.h"
#include "ris.h"

/*****************************************************************************/

/*
** Starting with RIS 4.x.x.x, older RISs will continue to work with newer ones.
** MATCH_COMPATIBLE mode algorithm is:
** 	major # must be == or > than the one being requested; closest match
** 	minor # must be == to requested (if major one ==) or highest one found
**	rel # must be highest one found (same for seq # if later passed in)
*/

extern int RIScom_get_risdir(
	char		*prodname,
	int			version_maj,
	int			version_min,
	int			version_rel,
	int			mode,
	char		*risdir_file,
	char		*config_file,
	char		*risdir,
	int			*developmentp,
	rissqlca	*dbcap)
{

#if defined(unix) || defined(WIN32)
	int		prod_maj;
	int		prod_min;
	int		prod_rel;
	int		compatible_maj = 0;
	int		compatible_min = 0;
	int		compatible_rel = 0;
	char	compatible_found;
	char	compatible_dir[256] = "";
	FILE	*fd;
	char	*cp;
	char	buffer[512];
#if !defined(WIN32)
	char    *ptr;
#endif
	char	*prod_no;
	char	temp[512];
	char	*prod_date;
	char	*prod_lname;
	char	*prod_sname;
	char	*prodtoken;
	char	*prod_version_addr;
	char	*prod_dir_addr = 0;
	char	prod_dir[256];
#endif

#ifndef NO_COM_DBG
	if (RIScom_debug)
	{
		RIScom_output_debug("RIScom_get_risdir()\n");
		RIScom_output_debug("\tprodname:<%s>\n", STRING(prodname));
		RIScom_output_debug("\tvers_maj:%d vers_min:%d vers_rel:%d mode:%d\n",
			version_maj, version_min, version_rel, mode);
		RIScom_output_debug("risdir_file:<%s> config_file:<%s>\n",
			STRING(risdir_file), STRING(config_file));
		RIScom_output_debug("risdir:0x%x development:0x%x dbcap:0x%x\n",
			risdir, developmentp, dbcap);
	}
#endif

	if (developmentp)
	{
		*developmentp = 0;
	}

#if defined(unix)
	/*
	**	if filenames are null set them to default values
	*/
	if (!risdir_file)
	{
//risdir_file = "/usr/ip32/ris/risdir";
		risdir_file = "/opt/ingr/ris/risdir";
	}

	if (!config_file)
	{
		config_file = INGRCONFIG_FILE;
	}

	/*
	**	Check $RISDIR to override others
	*/
    if ((cp = getenv("RISDEVDIR")) != NULL)
	{
			COM_DBG(("found risdir environment variable:<%s>\n", cp));
			strcpy(risdir, cp);
			if (developmentp)
			{
				*developmentp = 1;
			}
	}
	/*
	**	check for risdir_file
	*/
	else if (risdir_file && ((fd = RIScom_fopen(risdir_file,"r")) != NULL))
	{
		COM_DBG(("found risdir file:<%s>\n", risdir_file));

		cp = RIScom_fgets(buffer, sizeof(buffer), fd);
		RIScom_fclose(fd);
		if (!cp)
		{
			COM_DBG(("RIScom_get_risdir:exiting fgets error reading %s\n",
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
	**	Read config file (on clipper, sun, and sco) and remote schema
	**
	*/
	else
	{
		compatible_found = 0;
		compatible_min = -1;
		compatible_rel = -1;
		COM_DBG(("checking config file:<%s>\n", config_file));

		fd = RIScom_fopen(config_file,"r");
		if (!fd)
		{
            if ( !RIScom_strcmp_ic(config_file,RISCONFIG_FILE) ) 
            {
               COM_DBG(("RIScom_get_risdir:exiting CANT OPEN RISCONFIG\n")); 
               return(RIS_E_CANT_OPEN_RISCONFIG);
            }

			RIScom_syserr(errno, dbcap);
			COM_DBG(("RIScom_get_risdir:exiting CANT OPEN INGRCONFIG\n"));
			return(RIS_E_CANT_OPEN_INGRCONFIG);
		}

		while (RIScom_fgets(buffer, sizeof(buffer), fd))
		{
         /* The following lines are included to fix a coredump if
            the /etc/risconfig contained blank lines */
            ptr = buffer;
            while (*ptr == ' ')
            {
              ptr++;
            }
            if (*ptr != '\n')
			{
			prod_no = strtok(buffer,"#");		/* product number */
			prod_sname = strtok(0,"#");			/* product short name */
			prod_lname = strtok(0,"#");			/* product long short name */
			prod_version_addr = strtok(0,"#");		/* product version */
			prod_date = strtok(0,"#");			/* product date */
			prod_dir_addr = strtok(0,"#");			/* product directory */
			strcpy(prod_dir, prod_dir_addr);

			COM_DBG(("found prodname:<%s>\n", prod_sname));

			strcpy(temp, prodname);
			for (prodtoken = strtok(temp, ":");
				 prodtoken;
				 prodtoken = strtok(0, ":"))
			{
				if (RIScom_strcmp_ic(prod_sname, prodtoken))
				{
					COM_DBG(("prodnames don't match <%s> <%s>\n",
						prod_sname, prodtoken));
				}
				else
				{
					COM_DBG(("found matching prodname  <%s> <%s>\n",
						prod_sname, prodtoken));
					break;
				}
			}
			if (!prodtoken)
			{
				continue;
			}

			COM_DBG(("found version:<%s>\n",prod_version_addr));
			if (sscanf(prod_version_addr, "%d.%d.%d", &prod_maj, &prod_min,
				&prod_rel) != 3)
			{
				COM_DBG(("invalid version string\n"));
				continue;
			}

			if (version_maj > 3)
			{
				/*
				** NOTE:  Changes to this switch block must also be made
				**	      lower down where it is duplicated
				*/
				switch (mode)
				{
				    case MATCH_MAJOR_FEATURE:
				    {
						/* 
						**  5.1 client should be able to talk to
						**  5.0, and 5.1 data servers.
						*/
					    if (version_maj == prod_maj &&
							prod_min >= version_min)
					    {
							COM_DBG(("release versions match\n"));
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						else
						{
							COM_DBG(("release versions don't match\n"));
							continue;
						}
					    break;
					}
				    case MATCH_MAJOR_MINOR_RELEASE:
				    {
					    if (version_maj == prod_maj &&
							version_min == prod_min &&
							version_rel == prod_rel)
					    {
							COM_DBG(("release versions match\n"));
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						else
						{
							COM_DBG(("release versions don't match\n"));
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
										COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
									COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
									COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
							COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
										 compatible_maj,compatible_min,
										 compatible_rel,compatible_dir));
								continue;
							}
						}
					    break;
					} /* MATCH_HIGHEST */
				} /* switch */
			}
			else	/* version_maj <= 3 */
			{
				if (version_maj == prod_maj)
				{
					/*
					**	Major matches
					*/
					COM_DBG(("major versions match\n"));
					if (mode == MATCH_MAJOR)
					{
						if (prod_min > compatible_min)
						{
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						continue;
					}
				}
				else
				{
					COM_DBG(("major versions don't match\n"));
					continue;
				}

				if (version_min == prod_min)
				{
					/*
					**	Major & minor match
					*/
					COM_DBG(("minor versions match\n"));
					if (mode == MATCH_MAJOR_MINOR)
					{
						if (prod_rel > compatible_rel)
						{
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						continue;
					}
				}
				else
				{
					COM_DBG(("minor versions don't match\n"));
					continue;
				}

				if (version_rel == prod_rel)
				{
					/*
					**	Major, minor & release match
					*/
					COM_DBG(("release versions match\n"));
					if (mode == MATCH_MAJOR_MINOR_RELEASE)
					{
						compatible_maj = prod_maj;
						compatible_min = prod_min;
						compatible_rel = prod_rel;
						strcpy(compatible_dir, prod_dir);
						compatible_found = 1;
						COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						break;
					}
				}
				else
				{
					COM_DBG(("release versions don't match\n"));
					continue;
				}
			}	/* version_maj <= 3 */
          } /* if ptr != \n */
		}	/* while */

		RIScom_fclose(fd);

		if (compatible_found)
		{
			COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
				compatible_maj,compatible_min,compatible_rel,compatible_dir));
			strcpy(risdir, compatible_dir);
		}
		else
		{
            if ( !RIScom_strcmp_ic(prodname,RIS_CLIENT_RUNTIME_PRODUCT) &&
                 !RIScom_strcmp_ic(config_file, RISCONFIG_FILE) )
            {
               COM_DBG(("RIScom_get_risdir:exiting CANT FIND RISCLI PRODUCT\n"));
               return(RIS_E_CANT_FIND_RISCLI_PRODUCT);
            }
            else if ( !RIScom_strcmp_ic(prodname,RIS_DEVELOPMENT_PRODUCT) &&
                      !RIScom_strcmp_ic(config_file, RISCONFIG_FILE) )
            {
               COM_DBG(("RIScom_get_risdir:exiting CANT FIND RISDP PRODUCT\n"));
               return(RIS_E_CANT_FIND_RISDP_PRODUCT);
            }
            else 
			{
               COM_DBG(("RIScom_get_risdir:exiting CANT FIND PRODUCT\n"));
			   return(RIS_E_CANT_FIND_PRODUCT);
            }
		}
	}	/* else config file */
#endif /* unix */
#if defined(WIN32)
/*
 On WINNT platform risdir_file and config_file are only defined for 
 the remote schema file scenario so must check for these before local
 RISDEVDIR key
*/	
	if (RIScom_get_platform() != IS_WIN32S)
	{
	if (!risdir_file && !config_file &&
		((lResult = RegOpenKeyEx(HKEY_LOCAL_MACHINE, devKey,
						0, KEY_READ, &hKey2)) == ERROR_SUCCESS)
			&&
		(GetRegKeyValueEx(HKEY_LOCAL_MACHINE,devKey,
			"PathName", &dwType, prod_dir, 255)==ERROR_SUCCESS))
	{
		COM_DBG(("found RISDEVDIR PathName:<%s>\n",prod_dir));
		strcpy(risdir, prod_dir);
		if (developmentp)
		{
			*developmentp = 1;
		}
		   RegCloseKey(hKey2);                 
	}
	/*
	**	check for risdir_file
	*/
	else if (risdir_file && ((fd = RIScom_fopen(risdir_file,"r")) != NULL))
	{
		COM_DBG(("found risdir file:<%s>\n", risdir_file));

		cp = RIScom_fgets(buffer, sizeof(buffer), fd);
		RIScom_fclose(fd);
		if (!cp)
		{
			COM_DBG(("RIScom_get_risdir:exiting fgets error reading %s\n",
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
	**	Read config file (on clipper, sun, and sco) and remote schema
	**  file case for WIN32
	*/
	else
	{
		compatible_found = 0;
		compatible_min = -1;
		compatible_rel = -1;
	  if (config_file)
	  {
		COM_DBG(("checking config file:<%s>\n", config_file));

		fd = RIScom_fopen(config_file,"r");
		if (!fd)
		{
            if ( !RIScom_strcmp_ic(config_file,RISCONFIG_FILE) ) 
            {
               COM_DBG(("RIScom_get_risdir:exiting CANT OPEN RISCONFIG\n")); 
               return(RIS_E_CANT_OPEN_RISCONFIG);
            }

			RIScom_syserr(errno, dbcap);
			COM_DBG(("RIScom_get_risdir:exiting CANT OPEN INGRCONFIG\n"));
			return(RIS_E_CANT_OPEN_INGRCONFIG);
		}

		while (RIScom_fgets(buffer, sizeof(buffer), fd))
		{
			prod_no = strtok(buffer,"#");		/* product number */
			prod_sname = strtok(0,"#");			/* product short name */
			prod_lname = strtok(0,"#");			/* product long short name */
			prod_version_addr = strtok(0,"#");		/* product version */
			prod_date = strtok(0,"#");			/* product date */
			prod_dir_addr = strtok(0,"#");			/* product directory */
			strcpy(prod_dir, prod_dir_addr);

			COM_DBG(("found prodname:<%s>\n", prod_sname));

			strcpy(temp, prodname);
			for (prodtoken = strtok(temp, ":");
				 prodtoken;
				 prodtoken = strtok(0, ":"))
			{
				if (RIScom_strcmp_ic(prod_sname, prodtoken))
				{
					COM_DBG(("prodnames don't match <%s> <%s>\n",
						prod_sname, prodtoken));
				}
				else
				{
					COM_DBG(("found matching prodname  <%s> <%s>\n",
						prod_sname, prodtoken));
					break;
				}
			}
			if (!prodtoken)
			{
				continue;
			}

			COM_DBG(("found version:<%s>\n",prod_version_addr));
			if (sscanf(prod_version_addr, "%d.%d.%d", &prod_maj, &prod_min,
				&prod_rel) != 3)
			{
				COM_DBG(("invalid version string\n"));
				continue;
			}

			if (version_maj > 3)
			{
				/*
				** NOTE:  Changes to this switch block must also be made
				**	      lower down where it is duplicated
				*/
				switch (mode)
				{
				    case MATCH_MAJOR_FEATURE:
				    {
					    if (version_maj == prod_maj &&
							prod_min >= version_min)
					    {
							COM_DBG(("release versions match\n"));
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						else
						{
							COM_DBG(("release versions don't match\n"));
							continue;
						}
					    break;
					}
				    case MATCH_MAJOR_MINOR_RELEASE:
				    {
					    if (version_maj == prod_maj &&
							version_min == prod_min &&
							version_rel == prod_rel)
					    {
							COM_DBG(("release versions match\n"));
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						else
						{
							COM_DBG(("release versions don't match\n"));
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
										COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
									COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
									COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
							COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
										 compatible_maj,compatible_min,
										 compatible_rel,compatible_dir));
								continue;
							}
						}
					    break;
					} /* MATCH_HIGHEST */
				} /* switch */
			}
			else	/* version_maj <= 3 */
			{
				if (version_maj == prod_maj)
				{
					/*
					**	Major matches
					*/
					COM_DBG(("major versions match\n"));
					if (mode == MATCH_MAJOR)
					{
						if (prod_min > compatible_min)
						{
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						continue;
					}
				}
				else
				{
					COM_DBG(("major versions don't match\n"));
					continue;
				}

				if (version_min == prod_min)
				{
					/*
					**	Major & minor match
					*/
					COM_DBG(("minor versions match\n"));
					if (mode == MATCH_MAJOR_MINOR)
					{
						if (prod_rel > compatible_rel)
						{
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						continue;
					}
				}
				else
				{
					COM_DBG(("minor versions don't match\n"));
					continue;
				}

				if (version_rel == prod_rel)
				{
					/*
					**	Major, minor & release match
					*/
					COM_DBG(("release versions match\n"));
					if (mode == MATCH_MAJOR_MINOR_RELEASE)
					{
						compatible_maj = prod_maj;
						compatible_min = prod_min;
						compatible_rel = prod_rel;
						strcpy(compatible_dir, prod_dir);
						compatible_found = 1;
						COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						break;
					}
				}
				else
				{
					COM_DBG(("release versions don't match\n"));
					continue;
				}
			}	/* version_maj <= 3 */

		}	/* while */

		RIScom_fclose(fd);

		if (compatible_found)
		{
			COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
				compatible_maj,compatible_min,compatible_rel,compatible_dir));
			strcpy(risdir, compatible_dir);
		}
		else
		{
            if ( !RIScom_strcmp_ic(prodname,RIS_CLIENT_RUNTIME_PRODUCT) &&
                 !RIScom_strcmp_ic(config_file, RISCONFIG_FILE) )
            {
               COM_DBG(("RIScom_get_risdir:exiting CANT FIND RISCLI PRODUCT\n"));
               return(RIS_E_CANT_FIND_RISCLI_PRODUCT);
            }
            else if ( !RIScom_strcmp_ic(prodname,RIS_DEVELOPMENT_PRODUCT) &&
                      !RIScom_strcmp_ic(config_file, RISCONFIG_FILE) )
            {
               COM_DBG(("RIScom_get_risdir:exiting CANT FIND RISDP PRODUCT\n"));
               return(RIS_E_CANT_FIND_RISDP_PRODUCT);
            }
            else 
			{
               COM_DBG(("RIScom_get_risdir:exiting CANT FIND PRODUCT\n"));
			   return(RIS_E_CANT_FIND_PRODUCT);
            }
		}
	  }	/* if config_file */

	  /*
	  **	Read registry (NT)
	  */
      else
	  {
		strcpy(szKey1, "Software\\Intergraph");
		sprintf(szKey, "%s\\%s", szKey1, prodname);
		COM_DBG(("Opening Reg. key <%s>\n", szKey));
		if ((lResult = RegOpenKeyEx(HKEY_LOCAL_MACHINE, szKey, 0, KEY_READ,
									&hKey2)) != ERROR_SUCCESS)
		{
			COM_DBG(("RIScom_get_risdir:exiting CANT FIND REG PRODUCT\n"));
			return(RIS_E_CANT_FIND_REG_PRODUCT);
		}

		COM_DBG(("Checking to see how many subkeys this key has\n"));
		cchClass=128;
		if ((lResult = RegQueryInfoKey(hKey2, szClass, &cchClass,
						NULL, &dwNumSubKeys, &cchMaxSubKey, &cchMaxClass,
						&cValues, &cchMaxValName, &cbMaxValData,
						&cbSecurityDescriptor, &ftLastWrite)) != ERROR_SUCCESS)
		{
			COM_DBG(("RIScom_get_risdir:CANT FIND REG PRODUCT Error: %d\n",
					 lResult));
			return(RIS_E_CANT_FIND_REG_PRODUCT);	
		}

		if (dwNumSubKeys)
		{
			for (i = 0; i < dwNumSubKeys; i++)
			{
				SubKeySz = MAX_PATH+1;
				if ((lResult = RegEnumKeyEx(hKey2, i, szSubKey, &SubKeySz,
					0, NULL, NULL, &ftLastWrite)) == ERROR_SUCCESS)
				{
					COM_DBG(("Getting the version value for this subkey\n"));
					sprintf(szFullSubKey, "%s\\%s", szKey, szSubKey);
					if (GetRegKeyValueEx(HKEY_LOCAL_MACHINE,szFullSubKey,
						"Version", &dwType, prod_version, 20)!=ERROR_SUCCESS)
					{
						COM_DBG(("could'nt get version. continuing...\n"));
						continue;
					}
					COM_DBG(("found version:<%s>\n",prod_version));

					/*
					 Note: we dont really use the prod_seq value. But
					 we store it in the registry for possible future use.
					*/
					if (sscanf(prod_version, "%d.%d.%d.%d",&prod_maj,&prod_min,
						&prod_rel, &prod_seq) != 4)
					{
						COM_DBG(("invalid version string, continuing...\n"));
						continue;
					}

					COM_DBG(("Getting the PathName value for this subkey\n"));
					if (GetRegKeyValueEx(HKEY_LOCAL_MACHINE,szFullSubKey,
						"PathName", &dwType, prod_dir, 255)!=ERROR_SUCCESS)
					{
						COM_DBG(("could'nt get PathName; continuing..\n"));
						continue;
					}
					COM_DBG(("found PathName:<%s>\n",prod_dir));
                                        RIScom_StripSlash (prod_dir) ;
                                        
					/*
					** NOTE:  Changes to this switch block must also be made
					**	      up above where it is duplicated
					*/
					switch (mode)
					{
						case MATCH_MAJOR_FEATURE:
				    	{
					    	if (version_maj == prod_maj &&
							prod_min >= version_min)
					    	{
								COM_DBG(("release versions match\n"));
								compatible_maj = prod_maj;
								compatible_min = prod_min;
								compatible_rel = prod_rel;
								strcpy(compatible_dir, prod_dir);
								compatible_found = 1;
								COM_DBG(("prod_found:Version %d.%d.%d dir:%s\n",
								 	compatible_maj,compatible_min,
									compatible_rel,compatible_dir));
							}
							else
							{
								COM_DBG(("release versions don't match\n"));
								continue;
							}
					    	break;
						}
				      case MATCH_MAJOR_MINOR_RELEASE:
				      {
					    if (version_maj == prod_maj &&
							version_min == prod_min &&
							version_rel == prod_rel)
					    {
							COM_DBG(("release versions match\n"));
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						else
						{
							COM_DBG(("release versions don't match\n"));
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
										COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
									COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
									COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
							COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
					COM_DBG(("RegEnumKey Error: %d\n", lResult));
			} /* for */
		}	/* if */
      } /* else registry */

	  RegCloseKey(hKey2);
	  if (compatible_found)
	  {
		COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
			compatible_maj,compatible_min,compatible_rel,compatible_dir));
		strcpy(risdir, compatible_dir);
	  }
	  else
	  {
		COM_DBG(("RIScom_get_risdir:exiting CANT FIND REG PRODUCT\n"));
		return(RIS_E_CANT_FIND_REG_PRODUCT);
	  }
	}	/* else config file */
	}
	else
	{
		/* WIN32s */
	prod_min=0;
	prod_maj=0;
	compatible_found = '\0';
	prod_rel=0;

	GetPrivateProfileString("RISDEVDIR","PathName","Default",prod_dir,128,"INGR.INI");
	
	if (strcmp(prod_dir,"Default") !=0)
	{
		COM_DBG(("found RISDEVDIR PathName:<%s>\n",prod_dir));
		strcpy(risdir, prod_dir);
		if (developmentp)
		{
			*developmentp = 1;
		}

	}
	/*
	**	check for risdir_file
	*/
	else if (risdir_file && ((fd = RIScom_fopen(risdir_file,"r")) != NULL))
	{
		COM_DBG(("found risdir file:<%s>\n", risdir_file));

		cp = RIScom_fgets(buffer, sizeof(buffer), fd);
		RIScom_fclose(fd);
		if (!cp)
		{
			COM_DBG(("RIScom_get_risdir:exiting fgets error reading %s\n",
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
	**	Read config file (on clipper, sun, and sco) and remote schema
	**  file case for WIN32
	*/
	else
	{
		compatible_found = 0;
		compatible_min = -1;
		compatible_rel = -1;
	  if (config_file)
	  {
		COM_DBG(("checking config file:<%s>\n", config_file));

		fd = RIScom_fopen(config_file,"r");
		if (!fd)
		{
            if ( !RIScom_strcmp_ic(config_file,RISCONFIG_FILE) ) 
            {
               COM_DBG(("RIScom_get_risdir:exiting CANT OPEN RISCONFIG\n")); 
               return(RIS_E_CANT_OPEN_RISCONFIG);
            }

			RIScom_syserr(errno, dbcap);
			COM_DBG(("RIScom_get_risdir:exiting CANT OPEN INGRCONFIG\n"));
			return(RIS_E_CANT_OPEN_INGRCONFIG);
		}

		while (RIScom_fgets(buffer, sizeof(buffer), fd))
		{
			prod_no = strtok(buffer,"#");		/* product number */
			prod_sname = strtok(0,"#");			/* product short name */
			prod_lname = strtok(0,"#");			/* product long short name */
			prod_version_addr = strtok(0,"#");		/* product version */
			prod_date = strtok(0,"#");			/* product date */
			prod_dir_addr = strtok(0,"#");			/* product directory */
			strcpy(prod_dir, prod_dir_addr);

			COM_DBG(("found prodname:<%s>\n", prod_sname));

			strcpy(temp, prodname);
			for (prodtoken = strtok(temp, ":");
				 prodtoken;
				 prodtoken = strtok(0, ":"))
			{
				if (RIScom_strcmp_ic(prod_sname, prodtoken))
				{
					COM_DBG(("prodnames don't match <%s> <%s>\n",
						prod_sname, prodtoken));
				}
				else
				{
					COM_DBG(("found matching prodname  <%s> <%s>\n",
						prod_sname, prodtoken));
					break;
				}
			}
			if (!prodtoken)
			{
				continue;
			}

			COM_DBG(("found version:<%s>\n",prod_version_addr));
			if (sscanf(prod_version_addr, "%d.%d.%d", &prod_maj, &prod_min,
				&prod_rel) != 3)
			{
				COM_DBG(("invalid version string\n"));
				continue;
			}

			if (version_maj > 3)
			{
				/*
				** NOTE:  Changes to this switch block must also be made
				**	      lower down where it is duplicated
				*/
				switch (mode)
				{
				    case MATCH_MAJOR_FEATURE:
				    {
					    if (version_maj == prod_maj &&
							prod_min >= version_min)
					    {
							COM_DBG(("release versions match\n"));
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						else
						{
							COM_DBG(("release versions don't match\n"));
							continue;
						}
					    break;
					}
				    case MATCH_MAJOR_MINOR_RELEASE:
				    {
					    if (version_maj == prod_maj &&
							version_min == prod_min &&
							version_rel == prod_rel)
					    {
							COM_DBG(("release versions match\n"));
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						else
						{
							COM_DBG(("release versions don't match\n"));
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
										COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
									COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
									COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
							COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
										 compatible_maj,compatible_min,
										 compatible_rel,compatible_dir));
								continue;
							}
						}
					    break;
					} /* MATCH_HIGHEST */
				} /* switch */
			}
			else	/* version_maj <= 3 */
			{
				if (version_maj == prod_maj)
				{
					/*
					**	Major matches
					*/
					COM_DBG(("major versions match\n"));
					if (mode == MATCH_MAJOR)
					{
						if (prod_min > compatible_min)
						{
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						continue;
					}
				}
				else
				{
					COM_DBG(("major versions don't match\n"));
					continue;
				}

				if (version_min == prod_min)
				{
					/*
					**	Major & minor match
					*/
					COM_DBG(("minor versions match\n"));
					if (mode == MATCH_MAJOR_MINOR)
					{
						if (prod_rel > compatible_rel)
						{
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						continue;
					}
				}
				else
				{
					COM_DBG(("minor versions don't match\n"));
					continue;
				}

				if (version_rel == prod_rel)
				{
					/*
					**	Major, minor & release match
					*/
					COM_DBG(("release versions match\n"));
					if (mode == MATCH_MAJOR_MINOR_RELEASE)
					{
						compatible_maj = prod_maj;
						compatible_min = prod_min;
						compatible_rel = prod_rel;
						strcpy(compatible_dir, prod_dir);
						compatible_found = 1;
						COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						break;
					}
				}
				else
				{
					COM_DBG(("release versions don't match\n"));
					continue;
				}
			}	/* version_maj <= 3 */

		}	/* while */

		RIScom_fclose(fd);

		if (compatible_found)
		{
			COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
				compatible_maj,compatible_min,compatible_rel,compatible_dir));
			strcpy(risdir, compatible_dir);
		}
		else
		{
            if ( !RIScom_strcmp_ic(prodname,RIS_CLIENT_RUNTIME_PRODUCT) &&
                 !RIScom_strcmp_ic(config_file, RISCONFIG_FILE) )
            {
               COM_DBG(("RIScom_get_risdir:exiting CANT FIND RISCLI PRODUCT\n"));
               return(RIS_E_CANT_FIND_RISCLI_PRODUCT);
            }
            else if ( !RIScom_strcmp_ic(prodname,RIS_DEVELOPMENT_PRODUCT) &&
                      !RIScom_strcmp_ic(config_file, RISCONFIG_FILE) )
            {
               COM_DBG(("RIScom_get_risdir:exiting CANT FIND RISDP PRODUCT\n"));
               return(RIS_E_CANT_FIND_RISDP_PRODUCT);
            }
            else 
			{
               COM_DBG(("RIScom_get_risdir:exiting CANT FIND PRODUCT\n"));
			   return(RIS_E_CANT_FIND_PRODUCT);
            }
		}
	  }	/* if config_file */
      else
	  {
		  /*
		  **	Read ini file
		  */
			sprintf(section,"%s\\%02d.%02d",prodname,version_maj,version_min);
			COM_DBG(("section: %s\n",section));

			GetPrivateProfileString(section,"PathName","Default",prod_dir,128,"INGR.INI");
			if (strcmp(prod_dir,"")==0)
			{
				COM_DBG(("RIScom_get_risdir:exiting CANT FIND REG PRODUCT\n"));
				return(RIS_E_CANT_FIND_REG_PRODUCT);
			}

			COM_DBG(("Getting the version value\n"));
			GetPrivateProfileString(section,"Version","Default",prod_version,sizeof(prod_version),"INGR.INI");
			if (strcmp(prod_version,"Default") ==0)
			{
				COM_DBG(("could'nt get version. continuing...\n"));
			}
			COM_DBG(("found version:<%s>\n",prod_version));

			/*
			 Note: we dont really use the prod_seq value. But
			 we store it in the registry for possible future use.
			*/
			if (sscanf(prod_version, "%d.%d.%d.%d",&prod_maj,&prod_min,
				&prod_rel, &prod_seq) != 4)
			{
				COM_DBG(("invalid version string, continuing...\n"));
			}
			COM_DBG(("Getting the PathName value\n"));
			GetPrivateProfileString(section,"PathName","Default",prod_dir,sizeof(prod_dir),"INGR.INI");
			if (strcmp(prod_dir,"Default") !=0)
			{
				COM_DBG(("could'nt get PathName; continuing..\n"));
			}
			COM_DBG(("found PathName:<%s>\n",prod_dir));
			/*
			** NOTE:  Changes to this switch block must also be made
			**	      up above where it is duplicated
			*/
			switch (mode)
			{
		    	case MATCH_MAJOR_FEATURE:
		    	{
			    	if (version_maj == prod_maj &&
					prod_min >= version_min)
					    	{
								COM_DBG(("release versions match\n"));
								compatible_maj = prod_maj;
								compatible_min = prod_min;
								compatible_rel = prod_rel;
								strcpy(compatible_dir, prod_dir);
								compatible_found = 1;
								COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 	compatible_maj,compatible_min,compatible_rel,
								 	compatible_dir));
							}
							else
							{
								COM_DBG(("release versions don't match\n"));
							}
					    	break;
						}
				      case MATCH_MAJOR_MINOR_RELEASE:
				      {
					    if (version_maj == prod_maj &&
							version_min == prod_min &&
							version_rel == prod_rel)
					    {
							COM_DBG(("release versions match\n"));
							compatible_maj = prod_maj;
							compatible_min = prod_min;
							compatible_rel = prod_rel;
							strcpy(compatible_dir, prod_dir);
							compatible_found = 1;
							COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
								 compatible_maj,compatible_min,compatible_rel,
								 compatible_dir));
						}
						else
						{
							COM_DBG(("release versions don't match\n"));
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
										COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
									COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
									COM_DBG(("Good Ver: %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
							COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
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
								COM_DBG(("prod_found: Ver %d.%d.%d dir:%s\n",
										 compatible_maj,compatible_min,
										 compatible_rel,compatible_dir));
							}
						}
					    break;
					  } /* MATCH_HIGHEST */
				  } /* switch */
     } /* else ini */

	  if (compatible_found)
	  {
		COM_DBG(("prod_found: Version %d.%d.%d dir:%s\n",
			compatible_maj,compatible_min,compatible_rel,compatible_dir));
		strcpy(risdir, compatible_dir);
	  }
	  else
	  {
		COM_DBG(("RIScom_get_risdir:exiting CANT FIND REG PRODUCT\n"));
		return(RIS_E_CANT_FIND_REG_PRODUCT);
	  }
	}	/* else config file */
	}
#endif /* nt */
#if defined(DOS)
    /*
    **  Check $RISDIR to override others
    */
    if ((cp = getenv("RISDEVDIR")) != NULL)
    {
        COM_DBG(("found RISDIR environment variable:<%s>\n", cp));
        strcpy(risdir, cp);
        if (developmentp)
        {
            *developmentp = 1;
        }
    }
    else if ((cp = getenv(prodname)) != NULL)
    {
        COM_DBG(("found %s environment variable:<%s>\n", prodname, cp));
        strcpy(risdir, cp);
        if (developmentp)
        {
            *developmentp = 0;
        }
    }
    else
    {
		COM_DBG(("RIScom_get_risdir:exiting CANT FIND ENV PRODUCT %s\n",
				 prodname));
		return(RIS_E_CANT_FIND_ENV_PRODUCT);
    }
#endif

	COM_DBG(("RIScom_get_risdir:complete\n\trisdir:<%s>\n",risdir));
	return(0);
}

/**************************************************************************/

#if defined(WIN32)
static LONG GetRegKeyValueEx(
	HKEY hKey,
	LPCTSTR szKey,
	LPTSTR szValueName,
	LPDWORD lpdwType,
	LPBYTE lpBuf,
	DWORD cbBuf)
{
	HKEY	hKey2;
	DWORD	cb = cbBuf;
    LONG	lRetVal;

	COM_DBG(("GetRegKeyValueEx(hKey:0x%x, szKey:0x%x, szValueName:%s\n",
		hKey, szKey, szValueName));

    if (lRetVal = RegOpenKeyEx(hKey, szKey, 0, KEY_READ, &hKey2) != ERROR_SUCCESS)
	{
		RegCloseKey(hKey2);
		COM_DBG(("GetRegKeyValueEx(RegOpenKeyEx error:%d\n", lRetVal));
		COM_DBG(("GetRegKeyValueEx:complete\n"));
		return(ERROR_BADKEY);
	}
	if (lRetVal = RegQueryValueEx(hKey2, (LPTSTR)szValueName, NULL,
		lpdwType, lpBuf, &cb) != ERROR_SUCCESS)
	{
		RegCloseKey(hKey2);
		COM_DBG(("GetRegKeyValueEx(RegQueryKeyEx error:%d\n", lRetVal));
		COM_DBG(("GetRegKeyValueEx:complete\n"));
		return(ERROR_BADKEY);
	}
	COM_DBG(("GetRegKeyValueEx:complete\n"));
	  RegCloseKey(hKey2);  
	return(lRetVal);
}

/**************************************************************************/
#endif /* WIN32 */
