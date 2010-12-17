#define NFM_NO_LOAD_ITEM_FILE 0
#define NFM_LOAD_ITEM_FILE    1
/******************************************/
#define NFM_DEFINE_FILE      1
#define NFM_GET_FILE_INFO    2
#define NFM_DEFINE_MEMBER    3
#define NFM_COPYFILES        4
#define NFM_CHECK_OUT        5
#define NFM_CHECK_IN         6
#define NFM_CANCEL_CHECK_OUT 7
#define NFM_CHECK_OUT_SET_SELECTIVELY 8
#define NFM_PLOT_ITEM        9
#define NFM_PLOT_SET        10
#define NFM_SAVE_FILES      11
#define NFM_MOVE_CHECKED_OUT_FILES 12

/* defines for the NFMload_error_message */
#define NFM_SET              1
#define NFM_ITEM             2
#define NFM_PRIMARY_MEMBER   3
#define NFM_SECONDARY_MEMBER 4
#define NFM_ALL_MEMBERS      5

/*defines for NFMmount_add_index */
#define NFM_ITEM_NO_KEYWORDS 5
#define NFM_SET_NO_KEYWORDS  6

/* microstation design file */
#define NFM_DROPPED_MEMBER 1
#define NFM_JUST_ADDED_RASTER 2


/* LFM */
#define NFM_NO_CHANGE                       -1
#define NFM_ADD_CO                           0
#define NFM_ADD_COPY                         0
#define NFM_UPDATE_COPY                      1
#define NFM_UPDATE_CO                        1
#define NFM_DELETE_FROM_NFMSAFILES           2
#define NFM_NULL_CO_FROM_NFMSAFILES          3
#define NFM_DECREMENT_REF                    4
#define NFM_UPDATE_FILEVERSION               5
#define NFM_NULL_SOURCE_UPDATE_DESTINATION   6
#define NFM_DELETE_SOURCE_UPDATE_DESTINATION 7
#define NFM_NULL_SOURCE_ADD_TO_DESTINATION   8
#define NFM_DELETE_SOURCE_ADD_TO_DESTINATION 9


/* NFMitems.h */
#define NFM_NO_MOVE 1

/*NFMset_item_status */
#define MINUS_ONE -1

/*NFMretrieve_values*/
#define NFM_RETURN_STR 0
#define NFM_RETURN_VALUE 1
#define NFM_RETURN_MEMPTR 2

/*NFMcommon_queries*/
#define NFM_ITEM_QUERY      0
#define NFM_ITEM_FILE_QUERY 1
#define NFM_CAT_QUERY       2
#define NFM_LFM_QUERY       3

#define NFM_NO_LOCK         0
#define NFM_LOCK_NO_COMMIT  1
#define NFM_LOCK_COMMIT     2 
#define NFM_COMMIT_ONLY     3

/*NFMrollback_and_undo_buffer*/
#define NFM_RLBK_LFM1       1
#define NFM_RLBK_LFM1_FCAT  2
#define NFM_RLBK_LFM2_FCAT  3
#define NFM_RLBK_FCAT       4
#define NFM_RLBK_FCAT_NT    5 /* NFM_NO_TRANSFER */

/*hybrid and autocad files*/
#define DM_AUTOCAD       11
#define DM_MICROSTATION  22
#define NFM_AUTOCAD      33
#define NFM_MICROSTATION 44

/*_NFMfind_the_length*/
#define NFM_KEYWORDS  0
#define NFM_POSITIONS 1

/*_NFMextract_info_from_buf*/
#define NFM_SINGLE_ERROR 0
#define NFM_STACK_ERROR 1
