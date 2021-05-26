# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\Users\pedra\Documents\CR\labs\vitis_workspace\CustomPeriph_system\_ide\scripts\systemdebugger_customperiph_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\Users\pedra\Documents\CR\labs\vitis_workspace\CustomPeriph_system\_ide\scripts\systemdebugger_customperiph_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Nexys4 210274504707A" && level==0 && jtag_device_ctx=="jsn-Nexys4-210274504707A-13631093-0"}
fpga -file C:/Users/pedra/Documents/CR/labs/vitis_workspace/CustomPeriph/_ide/bitstream/download.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw C:/Users/pedra/Documents/CR/labs/vitis_workspace/mb_design_custom_periph/export/mb_design_custom_periph/hw/mb_design_custom_periph.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow C:/Users/pedra/Documents/CR/labs/vitis_workspace/CustomPeriph/Debug/CustomPeriph.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
