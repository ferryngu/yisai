//
//  fe_coredump_handle.h
//  FECore
//
//  Created by apps on 15/11/9.
//  Copyright © 2015年 apps. All rights reserved.
//

#ifndef fe_coredump_handle_h
#define fe_coredump_handle_h

#include <stdio.h>

void create_coredump_flage_file();

void clean_coredump_flag_file();

void fe_coredump_set_signal();

int fe_coredump_check();

#endif /* fe_coredump_handle_h */
