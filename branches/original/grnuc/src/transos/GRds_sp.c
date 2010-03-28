#include "OMminimum.h"
#include "igrtypedef.h"
#include "ds.h"
#include "dsdef.h"
#include "OMport.h"

	struct GRds_instance
	{
		int default_standard;
		struct OM_sd_varlenarr_descr standard_tab;
		struct OM_sd_varlenarr_descr sheet_tab;
	};


#if defined(__STDC__) || defined(__cplusplus)
	GRds_OMPORT_GRds(short classid, char *ME, struct GRds_instance *me)
#else
	GRds$GRds(classid, ME, me)
	short classid;
	char *ME;
	struct GRds_instance *me;
#endif
	{
		int		   sts, i;
		int		   stan_count, sheet_count;
		struct ds_standard *stan_tab;
		struct ds_sheet    *sheet_tab;

#if defined(__STDC__) || defined(__cplusplus)
		stan_count = OMPORT_DIMENSION_OF(&me->standard_tab);
		stan_tab = (struct ds_standard *)OMPORT_VLA_VALUE(&me->standard_tab);

		sheet_count = OMPORT_DIMENSION_OF(&me->sheet_tab);
		sheet_tab = (struct ds_sheet *)OMPORT_VLA_VALUE(&me->sheet_tab);
#else
		stan_count = om$dimension_of(&me->standard_tab);
		stan_tab = om$vla_value(&me->standard_tab);

		sheet_count = om$dimension_of(&me->sheet_tab);
		sheet_tab = om$vla_value(&me->sheet_tab);
#endif

		for (i=0; i<stan_count; i++)
		{
			sts =
#if defined(__STDC__) || defined(__cplusplus)
			OMPORT_CONV_BITFIELDS(
				(char *)stan_tab + MAX_STANDARD_LEN,
				sizeof(int));
#else
			om$conv_bitfields(
				(char *)stan_tab + MAX_STANDARD_LEN,
				sizeof(int));
#endif
			if (!sts) return(sts);

			stan_tab++;
		}

		for (i=0; i<sheet_count; i++)
		{
			sts =
#if defined(__STDC__) || defined(__cplusplus)
			OMPORT_CONV_BITFIELDS(
				(char *)sheet_tab +
				MAX_SHEET_LEN +
				MAX_STANDARD_LEN +
				MAX_FILE_LEN +
				MAX_CELL_LEN,
				sizeof(int));
#else
			om$conv_bitfields(
				(char *)sheet_tab +
				MAX_SHEET_LEN +
				MAX_STANDARD_LEN +
				MAX_FILE_LEN +
				MAX_CELL_LEN,
				sizeof(int));
#endif
			if (!sts) return(sts);

			sheet_tab++;
		}

		return(1);
	}
