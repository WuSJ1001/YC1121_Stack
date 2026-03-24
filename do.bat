@set FPGA_PATH=fpgajic\fpga
@set ROM_PATH=.
@set MV_PATCH=mv\src\yichip
@set YC_PATCH_FILE=yc_patch_yc1021.h
@set enc=1
@set enckey=0000000000000000
@rem set device_option=rfbqb
@rem set device_option=mouse
@rem set device_option=shutter
@rem set device_option=shutter_dy
@rem set device_option=hci
@rem set device_option=antilost
@rem set device_option=dongle
@set device_option=module
@rem set device_option=keyboard
@rem set device_option=car
@rem set device_option=remote_car
@rem set device_option=mesh
@rem set device_option=otp
@rem set device_option=flippen
@echo off

setlocal enabledelayedexpansion
:: Main Build Logic
for %%f in (program\ble_protocol_stack\*.prog) do @set progs=!progs! %%f
for %%f in (program\g24_protocol_stack\*.prog) do @set progs=!progs! %%f
for %%f in (program\mesh_protocol_stack\*.prog) do @set progs=!progs! %%f
for %%f in (program\*.prog) do @if not %%f==program\bt.prog if not %%f==program\patch.prog if not %%f==program\sim.prog set progs=!progs! %%f
type program\bt.prog %progs% %light_progs% > output\bt_program23.meta

for %%f in (format\ble_protocol_stack\*.format) do set fmts=!fmts! %%f
for %%f in (format\g24_protocol_stack\*.format) do set fmts=!fmts! %%f
for %%f in (format\mesh_protocol_stack\*.format) do set fmts=!fmts! %%f
for %%f in (format\*.format) do @if not %%f==format\bt.format if not %%f==format\command.format set fmts=!fmts! %%f
type format\bt.format %fmts% format\command.format > output\bt_format.meta

if "%device_option%" equ "hci" (
  copy sched\hci_boot.dat output\sched.rom
) else if "%device_option%" equ "keyboard" (
  copy sched\keyboard.dat + sched\1305.dat output\sched.rom
) else if "%device_option%" equ "mouse" (
  copy sched\mouse.dat + sched\1305.dat output\sched.rom
) else if "%device_option%" equ "module" (
  copy sched\DM_module.dat + sched\1305.dat output\sched.rom
) else if "%device_option%" equ "shutter" (
  copy sched\shutter.dat + sched\1305.dat output\sched.rom
) else if "%device_option%" equ "shutter_dy" (
  copy sched\shutter_dy.dat + sched\1305.dat output\sched.rom
) else if "%device_option%" equ "antilost" (
  copy sched\antilost.dat + sched\1305.dat output\sched.rom
) else if "%device_option%" equ "dongle" (
  copy sched\dongle.dat + sched\1305.dat output\sched.rom
) else if "%device_option%" equ "car" (
  copy sched\car.dat + sched\1305.dat output\sched.rom
) else if "%device_option%" equ "remote_car" (
  copy sched\remote_car.dat + sched\1305.dat output\sched.rom
 ) else if "%device_option%" equ "mesh" (
  copy sched\1305.dat +sched\mesh.dat output\sched.rom
) else if "%device_option%" equ "otp" (
  copy sched\1305.dat output\sched.rom
) else if "%device_option%" equ "flippen" (
  copy sched\mouse.dat + sched\flippen.dat + sched\1305.dat output\sched.rom
)else  (

cd ..
echo **********************************
echo Error: illegal device_option !
echo **********************************
goto end
) 

perl util/mergepatch.pl 

cd output
osiuasm bt_program23 -O-W

geneep -n 

echo create auth rom
perl ../util/mergepatch.pl mouse_ble_att_list usb_kbdata_vendor_define usb_kbdata usb_msdata usb_devicedata usb_confdata ble_shutter_gatt_list ble_shutter_key_value_list ble_car_att_list sha256 
perl ../util/romcrc.pl romcode.rom
perl  ../util/mergepatch.pl otp


if "%device_option%" equ "mous" (
cd ..\output
copy eeprom.dat ..\util\eeprom.dat
cd ..\util
eeprom2fulleeprom.exe eeprom.dat 64>compare2.dat
crc16.exe compare2.dat 2 >..\output\eeprom.dat
del eeprom.dat
del compare2.dat
cd ..\output
copy eeprom.dat ..\output\flash.dat 
)


:end



