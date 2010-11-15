extern LONG RISRemoveProduct(HWND hwndowner,
                  LPTSTR title,
                  LPTSTR version_string,
                  PVOID *appdata,
                  BOOLEAN delete_remove,
                  BOOLEAN delete_mark,
                  BOOLEAN delete_tmp_dir,
                  BOOLEAN ask_delete,
                  PINT remove);
