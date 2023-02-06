onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/clk
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/reset
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/pc
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/inst
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/ALUSrc
add wave -noupdate -radix binary /RV32I_System_tb/iRV32I_System/icpu/ALUcontrol
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/i_datapath/alusrc1
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/i_datapath/alusrc2
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/i_datapath/aluout
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/MemAddr
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/MemWData
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/MemWrite
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/MemRData
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/MemtoReg
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/RegWrite
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/i_datapath/i_regfile/x5
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/i_datapath/i_regfile/x6
add wave -noupdate -radix hexadecimal /RV32I_System_tb/iRV32I_System/icpu/i_datapath/i_regfile/x7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {397557 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 310
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {597618 ps} {1097770 ps}
