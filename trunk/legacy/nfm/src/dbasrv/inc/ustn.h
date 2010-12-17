/* $Revision: 1.1 $ */
#ifndef USTN_H
#define USTN_H

char dba_app_id[16], dba_ustn_id[7];

int dba_nest_mode, dba_fence_mode, dba_active_command, dba_partition_bits,
  dba_link_mode, dba_mce_restrict, dba_ustn_on_levels_only,  dba_ris_link,
  dba_dmrs_link, dba_oracle_link, dba_informix_link, dba_dbase_link,
  dba_level_mode;

short dba_type_mask[8], dba_level_mask[4];

#endif
