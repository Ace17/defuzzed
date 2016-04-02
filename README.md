# defuzzed
A fuzzer for D compilers

Usage:
$ rdmd ./defuzzed.d

Example use on the GNU D compiler:
```
$ ./defuzzed.d gdc -c %s -o %o
["gdc", "-c", "/tmp/test_000.d", "-o", "/tmp/test_000.o"]
["gdc", "-c", "/tmp/test_001.d", "-o", "/tmp/test_001.o"]
["gdc", "-c", "/tmp/test_002.d", "-o", "/tmp/test_002.o"]
["gdc", "-c", "/tmp/test_003.d", "-o", "/tmp/test_003.o"]
["gdc", "-c", "/tmp/test_004.d", "-o", "/tmp/test_004.o"]
["gdc", "-c", "/tmp/test_005.d", "-o", "/tmp/test_005.o"]
["gdc", "-c", "/tmp/test_006.d", "-o", "/tmp/test_006.o"]
["gdc", "-c", "/tmp/test_007.d", "-o", "/tmp/test_007.o"]
["gdc", "-c", "/tmp/test_008.d", "-o", "/tmp/test_008.o"]
["gdc", "-c", "/tmp/test_009.d", "-o", "/tmp/test_009.o"]
["gdc", "-c", "/tmp/test_010.d", "-o", "/tmp/test_010.o"]
["gdc", "-c", "/tmp/test_011.d", "-o", "/tmp/test_011.o"]
["gdc", "-c", "/tmp/test_012.d", "-o", "/tmp/test_012.o"]
["gdc", "-c", "/tmp/test_013.d", "-o", "/tmp/test_013.o"]
["gdc", "-c", "/tmp/test_014.d", "-o", "/tmp/test_014.o"]
["gdc", "-c", "/tmp/test_015.d", "-o", "/tmp/test_015.o"]
["gdc", "-c", "/tmp/test_016.d", "-o", "/tmp/test_016.o"]
["gdc", "-c", "/tmp/test_017.d", "-o", "/tmp/test_017.o"]
["gdc", "-c", "/tmp/test_018.d", "-o", "/tmp/test_018.o"]
["gdc", "-c", "/tmp/test_019.d", "-o", "/tmp/test_019.o"]
["gdc", "-c", "/tmp/test_020.d", "-o", "/tmp/test_020.o"]
["gdc", "-c", "/tmp/test_021.d", "-o", "/tmp/test_021.o"]
["gdc", "-c", "/tmp/test_022.d", "-o", "/tmp/test_022.o"]
["gdc", "-c", "/tmp/test_023.d", "-o", "/tmp/test_023.o"]
["gdc", "-c", "/tmp/test_024.d", "-o", "/tmp/test_024.o"]
["gdc", "-c", "/tmp/test_025.d", "-o", "/tmp/test_025.o"]
["gdc", "-c", "/tmp/test_026.d", "-o", "/tmp/test_026.o"]
["gdc", "-c", "/tmp/test_027.d", "-o", "/tmp/test_027.o"]
["gdc", "-c", "/tmp/test_028.d", "-o", "/tmp/test_028.o"]
["gdc", "-c", "/tmp/test_029.d", "-o", "/tmp/test_029.o"]
["gdc", "-c", "/tmp/test_030.d", "-o", "/tmp/test_030.o"]
["gdc", "-c", "/tmp/test_031.d", "-o", "/tmp/test_031.o"]
["gdc", "-c", "/tmp/test_032.d", "-o", "/tmp/test_032.o"]
["gdc", "-c", "/tmp/test_033.d", "-o", "/tmp/test_033.o"]
["gdc", "-c", "/tmp/test_034.d", "-o", "/tmp/test_034.o"]
["gdc", "-c", "/tmp/test_035.d", "-o", "/tmp/test_035.o"]
["gdc", "-c", "/tmp/test_036.d", "-o", "/tmp/test_036.o"]
["gdc", "-c", "/tmp/test_037.d", "-o", "/tmp/test_037.o"]
["gdc", "-c", "/tmp/test_038.d", "-o", "/tmp/test_038.o"]
["gdc", "-c", "/tmp/test_039.d", "-o", "/tmp/test_039.o"]
["gdc", "-c", "/tmp/test_040.d", "-o", "/tmp/test_040.o"]
["gdc", "-c", "/tmp/test_041.d", "-o", "/tmp/test_041.o"]
["gdc", "-c", "/tmp/test_042.d", "-o", "/tmp/test_042.o"]
["gdc", "-c", "/tmp/test_043.d", "-o", "/tmp/test_043.o"]
["gdc", "-c", "/tmp/test_044.d", "-o", "/tmp/test_044.o"]
["gdc", "-c", "/tmp/test_045.d", "-o", "/tmp/test_045.o"]
["gdc", "-c", "/tmp/test_046.d", "-o", "/tmp/test_046.o"]
/tmp/test_046.d: In member function ‘i11’:
/tmp/test_046.d:24:1: internal compiler error: in expand_expr_real_1, at expr.c:9608
 i3();
 ^
0x64e19b expand_expr_real_1(tree_node*, rtx_def*, machine_mode, expand_modifier, rtx_def**, bool)
	../../src/gcc/expr.c:9603
0xd158dc expand_expr_real(tree_node*, rtx_def*, machine_mode, expand_modifier, rtx_def**, bool)
	../../src/gcc/expr.c:8018
0xd158dc expand_expr
	../../src/gcc/expr.h:254
0xd158dc expand_expr_real_1(tree_node*, rtx_def*, machine_mode, expand_modifier, rtx_def**, bool)
	../../src/gcc/expr.c:9904
0xd15e05 expand_expr_real(tree_node*, rtx_def*, machine_mode, expand_modifier, rtx_def**, bool)
	../../src/gcc/expr.c:8018
0xd15e05 expand_expr_real_1(tree_node*, rtx_def*, machine_mode, expand_modifier, rtx_def**, bool)
	../../src/gcc/expr.c:10172
0xd18418 expand_expr_real(tree_node*, rtx_def*, machine_mode, expand_modifier, rtx_def**, bool)
	../../src/gcc/expr.c:8018
0xd18418 store_expr_with_bounds(tree_node*, rtx_def*, int, bool, tree_node*)
	../../src/gcc/expr.c:5382
0xd17c1c expand_assignment(tree_node*, tree_node*, bool)
	../../src/gcc/expr.c:5154
0xc733f0 expand_gimple_stmt_1
	../../src/gcc/cfgexpand.c:3426
0xc733f0 expand_gimple_stmt
	../../src/gcc/cfgexpand.c:3522
0xc6c738 expand_gimple_basic_block
	../../src/gcc/cfgexpand.c:5534
0xc6c738 execute
	../../src/gcc/cfgexpand.c:6152
Please submit a full bug report,
with preprocessed source if appropriate.
Please include the complete backtrace with any bug report.
See <file:///usr/share/doc/gcc-5/README.Bugs> for instructions.

Fatal: Seed 46: can't compile source file
command: gdc -c /tmp/test_046.d -o /tmp/test_046.o
exitcode: 1
```

