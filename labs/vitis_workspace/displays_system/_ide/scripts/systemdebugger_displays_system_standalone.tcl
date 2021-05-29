# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\Users\pedra\Documents\CR\labs\vitis_workspace\displays_system\_ide\scripts\systemdebugger_displays_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\Users\pedra\Documents\CR\labs\vitis_workspace\displays_system\_ide\scripts\systemdebugger_displays_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Nexys4 210274504950A" && level==0 && jtag_device_ctx=="jsn-Nexys4-210274504950A-13631093-0"}
fpga -file C:/Users/pedra/Documents/CR/labs/vitis_workspace/displays/_ide/bitstream/CustomDisplayPeriph.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw C:/Users/pedra/Documents/CR/labs/vitis_workspace/CustomDisplayPeriph_1/export/CustomDisplayPeriph_1/hw/CustomDisplayPeriph.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow C:/Users/pedra/Documents/CR/labs/vitis_workspace/displays/Debug/displays.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
