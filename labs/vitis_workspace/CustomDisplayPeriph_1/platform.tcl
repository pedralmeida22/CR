# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\pedra\Documents\CR\labs\vitis_workspace\CustomDisplayPeriph_1\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\pedra\Documents\CR\labs\vitis_workspace\CustomDisplayPeriph_1\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {CustomDisplayPeriph_1}\
-hw {C:\Users\pedra\Documents\CR\labs\lab7\CustomDisplayPeriph\CustomDisplayPeriph.xsa}\
-fsbl-target {psu_cortexa53_0} -out {C:/Users/pedra/Documents/CR/labs/vitis_workspace}

platform write
domain create -name {standalone_microblaze_0} -display-name {standalone_microblaze_0} -os {standalone} -proc {microblaze_0} -runtime {cpp} -arch {32-bit} -support-app {hello_world}
platform generate -domains 
platform active {CustomDisplayPeriph_1}
platform generate -quick
platform clean
platform clean
platform generate
platform clean
platform generate
