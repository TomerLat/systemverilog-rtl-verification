# File saved with Nlview 7.0.19  2019-03-26 bk=1.5019 VDI=41 GEI=35 GUI=JA:9.0 TLS
# 
# non-default properties - (restore without -noprops)
property attrcolor #000000
property attrfontsize 8
property autobundle 1
property backgroundcolor #ffffff
property boxcolor0 #000000
property boxcolor1 #000000
property boxcolor2 #000000
property boxinstcolor #000000
property boxpincolor #000000
property buscolor #008000
property closeenough 5
property createnetattrdsp 2048
property decorate 1
property elidetext 40
property fillcolor1 #ffffcc
property fillcolor2 #dfebf8
property fillcolor3 #f0f0f0
property gatecellname 2
property instattrmax 30
property instdrag 15
property instorder 1
property marksize 12
property maxfontsize 12
property maxzoom 5
property netcolor #19b400
property objecthighlight0 #ff00ff
property objecthighlight1 #ffff00
property objecthighlight2 #00ff00
property objecthighlight3 #ff6666
property objecthighlight4 #0000ff
property objecthighlight5 #ffc800
property objecthighlight7 #00ffff
property objecthighlight8 #ff00ff
property objecthighlight9 #ccccff
property objecthighlight10 #0ead00
property objecthighlight11 #cefc00
property objecthighlight12 #9e2dbe
property objecthighlight13 #ba6a29
property objecthighlight14 #fc0188
property objecthighlight15 #02f990
property objecthighlight16 #f1b0fb
property objecthighlight17 #fec004
property objecthighlight18 #149bff
property objecthighlight19 #eb591b
property overlapcolor #19b400
property pbuscolor #000000
property pbusnamecolor #000000
property pinattrmax 20
property pinorder 2
property pinpermute 0
property portcolor #000000
property portnamecolor #000000
property ripindexfontsize 8
property rippercolor #000000
property rubberbandcolor #000000
property rubberbandfontsize 12
property selectattr 0
property selectionappearance 2
property selectioncolor #0000ff
property sheetheight 44
property sheetwidth 68
property showmarks 1
property shownetname 0
property showpagenumbers 1
property showripindex 4
property timelimit 1
#
module new fifo_top work:fifo_top:NOFILE -nosplit
load symbol LUT1 hdi_primitives BOX pin O output.right pin I0 input.left fillcolor 1
load symbol LUT6 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left pin I4 input.left pin I5 input.left fillcolor 1
load symbol LUT2 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left fillcolor 1
load symbol FDRE hdi_primitives GEN pin Q output.right pin C input.clk.left pin CE input.left pin D input.left pin R input.left fillcolor 1
load symbol IBUF hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol OBUF hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol LUT3 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left fillcolor 1
load symbol LUT5 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left pin I4 input.left fillcolor 1
load symbol RAM32M {hdi_primitives:netlist:no file specified} HIERBOX pin WCLK input.left pin WE input.left pinBus DOA output.right [1:0] pinBus DOB output.right [1:0] pinBus DOC output.right [1:0] pinBus DOD output.right [1:0] pinBus ADDRA input.left [4:0] pinBus ADDRB input.left [4:0] pinBus ADDRC input.left [4:0] pinBus ADDRD input.left [4:0] pinBus DIA input.left [1:0] pinBus DIB input.left [1:0] pinBus DIC input.left [1:0] pinBus DID input.left [1:0] fillcolor 2
load symbol RAM32M {hdi_primitives:abstract:no file specified} HIERBOX pin WCLK input.left pin WE input.left pinBus DOA output.right [1:0] pinBus DOB output.right [1:0] pinBus DOC output.right [1:0] pinBus DOD output.right [1:0] pinBus ADDRA input.left [4:0] pinBus ADDRB input.left [4:0] pinBus ADDRC input.left [4:0] pinBus ADDRD input.left [4:0] pinBus DIA input.left [1:0] pinBus DIB input.left [1:0] pinBus DIC input.left [1:0] pinBus DID input.left [1:0] fillcolor 2
load symbol BUFG hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol LUT4 hdi_primitives BOX pin O output.right pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left fillcolor 1
load symbol RAMD32 hdi_primitives BOX pin O output.right pin CLK input.left pin I input.left pin RADR0 input.left pin RADR1 input.left pin RADR2 input.left pin RADR3 input.left pin RADR4 input.left pin WADR0 input.left pin WADR1 input.left pin WADR2 input.left pin WADR3 input.left pin WADR4 input.left pin WE input.left fillcolor 1
load port {fif\.clk} input -pg 1 -lvl 0 -x 0 -y 490
load port {fif\.empty} output -pg 1 -lvl 19 -x 4500 -y 720
load port {fif\.full} output -pg 1 -lvl 19 -x 4500 -y 570
load port {fif\.rd} input -pg 1 -lvl 0 -x 0 -y 400
load port {fif\.rst} input -pg 1 -lvl 0 -x 0 -y 630
load port {fif\.wr} input -pg 1 -lvl 0 -x 0 -y 440
load portBus {fif\.data_in} input [7:0] -attr @name {fif\.data_in[7:0]} -pg 1 -lvl 0 -x 0 -y 1510
load portBus {fif\.data_out} output [7:0] -attr @name {fif\.data_out[7:0]} -pg 1 -lvl 19 -x 4500 -y 990
load inst cnt[0]_i_1 LUT1 hdi_primitives -attr @cell(#000000) LUT1 -pg 1 -lvl 2 -x 270 -y 550
load inst cnt[1]_i_1 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 4 -x 770 -y 430
load inst cnt[2]_i_1 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 8 -x 1550 -y 510
load inst cnt[3]_i_1 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 11 -x 2380 -y 360
load inst cnt[4]_i_2 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 11 -x 2380 -y 640
load inst cnt[4]_i_3 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 6 -x 1170 -y 250
load inst cnt_reg[0] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 530 -y 550
load inst cnt_reg[1] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 5 -x 950 -y 580
load inst cnt_reg[2] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 9 -x 1760 -y 630
load inst cnt_reg[3] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 12 -x 2540 -y 690
load inst cnt_reg[4] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 7 -x 1330 -y 600
load inst cnt_reg[4]_i_1 IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 270 -y 630
load inst cnt_reg[4]_i_4 IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 530 -y 440
load inst {fif\.data_out[0]_INST_0} OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 18 -x 4290 -y 990
load inst {fif\.data_out[1]_INST_0} OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 18 -x 4290 -y 1140
load inst {fif\.data_out[2]_INST_0} OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 18 -x 4290 -y 1290
load inst {fif\.data_out[3]_INST_0} OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 18 -x 4290 -y 1440
load inst {fif\.data_out[4]_INST_0} OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 18 -x 4290 -y 1590
load inst {fif\.data_out[5]_INST_0} OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 18 -x 4290 -y 1740
load inst {fif\.data_out[6]_INST_0} OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 18 -x 4290 -y 1890
load inst {fif\.data_out[7]_INST_0} OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 18 -x 4290 -y 2040
load inst {fif\.data_out[7]_i_1} LUT3 hdi_primitives -attr @cell(#000000) LUT3 -pg 1 -lvl 16 -x 3670 -y 1010
load inst {fif\.data_out[7]_i_2} LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 10 -x 2110 -y 340
load inst {fif\.data_out_reg[0]} FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 17 -x 4140 -y 990
load inst {fif\.data_out_reg[1]} FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 17 -x 4140 -y 1140
load inst {fif\.data_out_reg[2]} FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 17 -x 4140 -y 1290
load inst {fif\.data_out_reg[3]} FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 17 -x 4140 -y 1440
load inst {fif\.data_out_reg[4]} FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 17 -x 4140 -y 1590
load inst {fif\.data_out_reg[5]} FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 17 -x 4140 -y 1740
load inst {fif\.data_out_reg[6]} FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 17 -x 4140 -y 1890
load inst {fif\.data_out_reg[7]} FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 17 -x 4140 -y 2040
load inst {fif\.data_out_reg[7]_i_3} IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 9 -x 1760 -y 350
load inst {fif\.empty_INST_0} OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 18 -x 4290 -y 720
load inst {fif\.empty_INST_0_i_1} LUT5 hdi_primitives -attr @cell(#000000) LUT5 -pg 1 -lvl 17 -x 4140 -y 670
load inst {fif\.full_INST_0} OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 18 -x 4290 -y 570
load inst {fif\.full_INST_0_i_1} LUT5 hdi_primitives -attr @cell(#000000) LUT5 -pg 1 -lvl 17 -x 4140 -y 520
load inst mem_reg_0_15_0_5 RAM32M {hdi_primitives:netlist:no file specified} -autohide -attr @cell(#000000) RAM32M -attr @fillcolor #fafafa -pinBusAttr DOA @name DOA[1:0] -pinBusAttr DOB @name DOB[1:0] -pinBusAttr DOC @name DOC[1:0] -pinBusAttr DOD @name DOD[1:0] -pinBusAttr DOD @attr n/c -pinBusAttr ADDRA @name ADDRA[4:0] -pinBusAttr ADDRB @name ADDRB[4:0] -pinBusAttr ADDRC @name ADDRC[4:0] -pinBusAttr ADDRD @name ADDRD[4:0] -pinBusAttr DIA @name DIA[1:0] -pinBusAttr DIB @name DIB[1:0] -pinBusAttr DIC @name DIC[1:0] -pinBusAttr DID @name DID[1:0] -pg 1 -lvl 16 -x 3670 -y 3130
load inst mem_reg_0_15_0_5_i_1 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 15 -x 3210 -y 1410
load inst mem_reg_0_15_0_5_i_2 IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 15 -x 3210 -y 1510
load inst mem_reg_0_15_0_5_i_3 IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 15 -x 3210 -y 1580
load inst mem_reg_0_15_0_5_i_4 IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 15 -x 3210 -y 1650
load inst mem_reg_0_15_0_5_i_5 IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 15 -x 3210 -y 1720
load inst mem_reg_0_15_0_5_i_6 IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 15 -x 3210 -y 1790
load inst mem_reg_0_15_0_5_i_7 IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 15 -x 3210 -y 1860
load inst mem_reg_0_15_6_7 RAM32M {hdi_primitives:abstract:no file specified} -autohide -attr @cell(#000000) RAM32M -attr @fillcolor #fafafa -pinBusAttr DOA @name DOA[1:0] -pinBusAttr DOB @name DOB[1:0] -pinBusAttr DOB @attr n/c -pinBusAttr DOC @name DOC[1:0] -pinBusAttr DOC @attr n/c -pinBusAttr DOD @name DOD[1:0] -pinBusAttr DOD @attr n/c -pinBusAttr ADDRA @name ADDRA[4:0] -pinBusAttr ADDRB @name ADDRB[4:0] -pinBusAttr ADDRC @name ADDRC[4:0] -pinBusAttr ADDRD @name ADDRD[4:0] -pinBusAttr DIA @name DIA[1:0] -pinBusAttr DIB @name DIB[1:0] -pinBusAttr DIC @name DIC[1:0] -pinBusAttr DID @name DID[1:0] -pg 1 -lvl 16 -x 3670 -y 1200
load inst mem_reg_0_15_6_7_i_1 IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 15 -x 3210 -y 1930
load inst mem_reg_0_15_6_7_i_2 IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 15 -x 3210 -y 2000
load inst n_0_21_BUFG_inst BUFG hdi_primitives -attr @cell(#000000) BUFG -pg 1 -lvl 2 -x 270 -y 490
load inst n_0_21_BUFG_inst_i_1 IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 1 -x 40 -y 490
load inst rptr[0]_i_1 LUT1 hdi_primitives -attr @cell(#000000) LUT1 -pg 1 -lvl 14 -x 2930 -y 80
load inst rptr[1]_i_1 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 14 -x 2930 -y 210
load inst rptr[2]_i_1 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 14 -x 2930 -y 430
load inst rptr[2]_i_2 LUT3 hdi_primitives -attr @cell(#000000) LUT3 -pg 1 -lvl 14 -x 2930 -y 520
load inst rptr[3]_i_1 LUT4 hdi_primitives -attr @cell(#000000) LUT4 -pg 1 -lvl 14 -x 2930 -y 300
load inst rptr_reg[0] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 15 -x 3210 -y 80
load inst rptr_reg[1] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 15 -x 3210 -y 230
load inst rptr_reg[2] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 15 -x 3210 -y 380
load inst rptr_reg[3] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 15 -x 3210 -y 530
load inst wptr[0]_i_1 LUT1 hdi_primitives -attr @cell(#000000) LUT1 -pg 1 -lvl 14 -x 2930 -y 880
load inst wptr[1]_i_1 LUT2 hdi_primitives -attr @cell(#000000) LUT2 -pg 1 -lvl 14 -x 2930 -y 960
load inst wptr[2]_i_1 LUT3 hdi_primitives -attr @cell(#000000) LUT3 -pg 1 -lvl 14 -x 2930 -y 1120
load inst wptr[3]_i_1 LUT6 hdi_primitives -attr @cell(#000000) LUT6 -pg 1 -lvl 13 -x 2750 -y 500
load inst wptr[3]_i_2 LUT4 hdi_primitives -attr @cell(#000000) LUT4 -pg 1 -lvl 14 -x 2930 -y 1280
load inst wptr_reg[0] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 15 -x 3210 -y 810
load inst wptr_reg[1] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 15 -x 3210 -y 960
load inst wptr_reg[2] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 15 -x 3210 -y 1140
load inst wptr_reg[3] FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 15 -x 3210 -y 1300
load inst mem_reg_0_15_0_5|RAMA RAMD32 hdi_primitives -hier mem_reg_0_15_0_5 -attr @cell(#000000) RAMD32 -attr @name RAMA -pg 1 -lvl 1 -x 3730 -y 3130
load inst mem_reg_0_15_0_5|RAMA_D1 RAMD32 hdi_primitives -hier mem_reg_0_15_0_5 -attr @cell(#000000) RAMD32 -attr @name RAMA_D1 -pg 1 -lvl 1 -x 3730 -y 3440
load inst mem_reg_0_15_6_7|RAMA RAMD32 hdi_primitives -hier mem_reg_0_15_6_7 -attr @cell(#000000) RAMD32 -attr @name RAMA -pg 1 -lvl 1 -x 3730 -y 1200
load inst mem_reg_0_15_6_7|RAMA_D1 RAMD32 hdi_primitives -hier mem_reg_0_15_6_7 -attr @cell(#000000) RAMD32 -attr @name RAMA_D1 -pg 1 -lvl 1 -x 3730 -y 1510
load inst mem_reg_0_15_0_5|RAMB RAMD32 hdi_primitives -hier mem_reg_0_15_0_5 -attr @cell(#000000) RAMD32 -attr @name RAMB -pg 1 -lvl 1 -x 3730 -y 3750
load inst mem_reg_0_15_0_5|RAMB_D1 RAMD32 hdi_primitives -hier mem_reg_0_15_0_5 -attr @cell(#000000) RAMD32 -attr @name RAMB_D1 -pg 1 -lvl 1 -x 3730 -y 4060
load inst mem_reg_0_15_6_7|RAMB RAMD32 hdi_primitives -hier mem_reg_0_15_6_7 -attr @cell(#000000) RAMD32 -attr @name RAMB -pg 1 -lvl 1 -x 3730 -y 1820
load inst mem_reg_0_15_6_7|RAMB_D1 RAMD32 hdi_primitives -hier mem_reg_0_15_6_7 -attr @cell(#000000) RAMD32 -attr @name RAMB_D1 -pg 1 -lvl 1 -x 3730 -y 2130
load inst mem_reg_0_15_0_5|RAMC RAMD32 hdi_primitives -hier mem_reg_0_15_0_5 -attr @cell(#000000) RAMD32 -attr @name RAMC -pg 1 -lvl 1 -x 3730 -y 4370
load inst mem_reg_0_15_0_5|RAMC_D1 RAMD32 hdi_primitives -hier mem_reg_0_15_0_5 -attr @cell(#000000) RAMD32 -attr @name RAMC_D1 -pg 1 -lvl 1 -x 3730 -y 4680
load inst mem_reg_0_15_6_7|RAMC RAMD32 hdi_primitives -hier mem_reg_0_15_6_7 -attr @cell(#000000) RAMD32 -attr @name RAMC -pg 1 -lvl 1 -x 3730 -y 2440
load inst mem_reg_0_15_6_7|RAMC_D1 RAMD32 hdi_primitives -hier mem_reg_0_15_6_7 -attr @cell(#000000) RAMD32 -attr @name RAMC_D1 -pg 1 -lvl 1 -x 3730 -y 2750
load net <const0> -ground -pin {fif\.data_out_reg[0]} R -pin {fif\.data_out_reg[1]} R -pin {fif\.data_out_reg[2]} R -pin {fif\.data_out_reg[3]} R -pin {fif\.data_out_reg[4]} R -pin {fif\.data_out_reg[5]} R -pin {fif\.data_out_reg[6]} R -pin {fif\.data_out_reg[7]} R -pin mem_reg_0_15_0_5 ADDRA[4] -pin mem_reg_0_15_0_5 ADDRB[4] -pin mem_reg_0_15_0_5 ADDRC[4] -pin mem_reg_0_15_0_5 ADDRD[4] -pin mem_reg_0_15_0_5 DID[1] -pin mem_reg_0_15_0_5 DID[0] -pin mem_reg_0_15_6_7 ADDRA[4] -pin mem_reg_0_15_6_7 ADDRB[4] -pin mem_reg_0_15_6_7 ADDRC[4] -pin mem_reg_0_15_6_7 ADDRD[4] -pin mem_reg_0_15_6_7 DIB[1] -pin mem_reg_0_15_6_7 DIB[0] -pin mem_reg_0_15_6_7 DIC[1] -pin mem_reg_0_15_6_7 DIC[0] -pin mem_reg_0_15_6_7 DID[1] -pin mem_reg_0_15_6_7 DID[0]
load net cnt[0]_i_1_n_1 -pin cnt[0]_i_1 O -pin cnt_reg[0] D
netloc cnt[0]_i_1_n_1 1 2 1 NJ 560
load net cnt[1]_i_1_n_1 -pin cnt[1]_i_1 O -pin cnt_reg[1] D
netloc cnt[1]_i_1_n_1 1 4 1 880 480n
load net cnt[2]_i_1_n_1 -pin cnt[2]_i_1 O -pin cnt_reg[2] D
netloc cnt[2]_i_1_n_1 1 8 1 1640 560n
load net cnt[3]_i_1_n_1 -pin cnt[3]_i_1 O -pin cnt_reg[3] D
netloc cnt[3]_i_1_n_1 1 11 1 2510 410n
load net cnt[4]_i_2_n_1 -pin cnt[4]_i_2 O -pin cnt_reg[0] CE -pin cnt_reg[1] CE -pin cnt_reg[2] CE -pin cnt_reg[3] CE -pin cnt_reg[4] CE
netloc cnt[4]_i_2_n_1 1 2 10 490 670 NJ 670 900 680 NJ 680 1280 700 NJ 700 1700 730 NJ 730 NJ 730 2470
load net cnt[4]_i_3_n_1 -pin cnt[4]_i_3 O -pin cnt_reg[4] D
netloc cnt[4]_i_3_n_1 1 6 1 1260 300n
load net cnt_reg[0] -pin cnt[0]_i_1 I0 -pin cnt[1]_i_1 I4 -pin cnt[2]_i_1 I3 -pin cnt[3]_i_1 I0 -pin cnt[4]_i_3 I2 -pin cnt_reg[0] Q -pin {fif\.data_out[7]_i_2} I3 -pin {fif\.empty_INST_0_i_1} I2 -pin {fif\.full_INST_0_i_1} I1 -pin wptr[3]_i_1 I4
netloc cnt_reg[0] 1 1 16 230 680 470J 630 680 340 NJ 340 1060 480 NJ 480 1480 440 NJ 440 2010 490 2330 530 NJ 530 2650 690 NJ 690 NJ 690 NJ 690 3990
load net cnt_reg[1] -pin cnt[1]_i_1 I2 -pin cnt[2]_i_1 I5 -pin cnt[3]_i_1 I3 -pin cnt[4]_i_3 I0 -pin cnt_reg[1] Q -pin {fif\.data_out[7]_i_2} I4 -pin {fif\.empty_INST_0_i_1} I1 -pin {fif\.full_INST_0_i_1} I3 -pin wptr[3]_i_1 I2
netloc cnt_reg[1] 1 3 14 700 300 NJ 300 1040 520 NJ 520 1420 660 1660J 550 2030 550 2270 570 NJ 570 2710 670 NJ 670 NJ 670 NJ 670 4050
load net cnt_reg[2] -pin cnt[1]_i_1 I5 -pin cnt[2]_i_1 I4 -pin cnt[3]_i_1 I5 -pin cnt[4]_i_3 I3 -pin cnt_reg[2] Q -pin {fif\.data_out[7]_i_2} I2 -pin {fif\.empty_INST_0_i_1} I3 -pin {fif\.full_INST_0_i_1} I0 -pin wptr[3]_i_1 I5
netloc cnt_reg[2] 1 3 14 740 580 860J 500 1100 500 NJ 500 1520 420 NJ 420 1970 590 2350 590 NJ 590 2630 710 NJ 710 NJ 710 NJ 710 3970
load net cnt_reg[3] -pin cnt[1]_i_1 I1 -pin cnt[2]_i_1 I1 -pin cnt[3]_i_1 I4 -pin cnt[4]_i_3 I5 -pin cnt_reg[3] Q -pin {fif\.data_out[7]_i_2} I1 -pin {fif\.empty_INST_0_i_1} I4 -pin {fif\.full_INST_0_i_1} I4 -pin wptr[3]_i_1 I1
netloc cnt_reg[3] 1 3 14 740 380 NJ 380 1140 440 NJ 440 1440 400 NJ 400 1950 570 2250 610 NJ 610 2670 730 NJ 730 NJ 730 NJ 730 3950
load net cnt_reg[4] -pin cnt[1]_i_1 I3 -pin cnt[2]_i_1 I2 -pin cnt[3]_i_1 I1 -pin cnt[4]_i_3 I4 -pin cnt_reg[4] Q -pin {fif\.data_out[7]_i_2} I5 -pin {fif\.empty_INST_0_i_1} I0 -pin {fif\.full_INST_0_i_1} I2 -pin wptr[3]_i_1 I3
netloc cnt_reg[4] 1 3 14 720 360 NJ 360 1120 460 NJ 460 1460 460 NJ 460 2050 510 2290 550 NJ 550 2690 650 NJ 650 NJ 650 NJ 650 4070
load net cnt_reg[4]_i_1_n_1 -pin cnt_reg[0] R -pin cnt_reg[1] R -pin cnt_reg[2] R -pin cnt_reg[3] R -pin cnt_reg[4] R -pin cnt_reg[4]_i_1 O -pin {fif\.data_out[7]_i_1} I2 -pin mem_reg_0_15_0_5_i_1 I1 -pin rptr_reg[0] R -pin rptr_reg[1] R -pin rptr_reg[2] R -pin rptr_reg[3] R -pin wptr_reg[0] R -pin wptr_reg[1] R -pin wptr_reg[2] R -pin wptr_reg[3] R
netloc cnt_reg[4]_i_1_n_1 1 2 14 450 690 NJ 690 860 700 NJ 700 1260 720 NJ 720 1680 750 NJ 750 NJ 750 2510 810 NJ 810 NJ 810 3090 1060 N
load net cnt_reg[4]_i_4_n_1 -pin cnt[1]_i_1 I0 -pin cnt[2]_i_1 I0 -pin cnt[3]_i_1 I2 -pin cnt[4]_i_3 I1 -pin cnt_reg[4]_i_4 O -pin wptr[3]_i_1 I0
netloc cnt_reg[4]_i_4_n_1 1 3 10 660 320 NJ 320 1080 420 NJ 420 1500 480 NJ 480 1990J 530 2310 510 NJ 510 N
load net {fif\.clk} -port {fif\.clk} -pin n_0_21_BUFG_inst_i_1 I
netloc {fif\.clk} 1 0 1 NJ 490
load net {fif\.data_in[0]} -attr @rip(#000000) {fif\.data_in[0]} -port {fif\.data_in[0]} -pin mem_reg_0_15_0_5_i_3 I
load net {fif\.data_in[1]} -attr @rip(#000000) {fif\.data_in[1]} -port {fif\.data_in[1]} -pin mem_reg_0_15_0_5_i_2 I
load net {fif\.data_in[2]} -attr @rip(#000000) {fif\.data_in[2]} -port {fif\.data_in[2]} -pin mem_reg_0_15_0_5_i_5 I
load net {fif\.data_in[3]} -attr @rip(#000000) {fif\.data_in[3]} -port {fif\.data_in[3]} -pin mem_reg_0_15_0_5_i_4 I
load net {fif\.data_in[4]} -attr @rip(#000000) {fif\.data_in[4]} -port {fif\.data_in[4]} -pin mem_reg_0_15_0_5_i_7 I
load net {fif\.data_in[5]} -attr @rip(#000000) {fif\.data_in[5]} -port {fif\.data_in[5]} -pin mem_reg_0_15_0_5_i_6 I
load net {fif\.data_in[6]} -attr @rip(#000000) {fif\.data_in[6]} -port {fif\.data_in[6]} -pin mem_reg_0_15_6_7_i_2 I
load net {fif\.data_in[7]} -attr @rip(#000000) {fif\.data_in[7]} -port {fif\.data_in[7]} -pin mem_reg_0_15_6_7_i_1 I
load net {fif\.data_out0[0]} -attr @rip(#000000) DOA[0] -pin {fif\.data_out_reg[0]} D -pin mem_reg_0_15_0_5 DOA[0]
load net {fif\.data_out0[1]} -attr @rip(#000000) DOA[1] -pin {fif\.data_out_reg[1]} D -pin mem_reg_0_15_0_5 DOA[1]
load net {fif\.data_out0[2]} -attr @rip(#000000) DOB[0] -pin {fif\.data_out_reg[2]} D -pin mem_reg_0_15_0_5 DOB[0]
load net {fif\.data_out0[3]} -attr @rip(#000000) DOB[1] -pin {fif\.data_out_reg[3]} D -pin mem_reg_0_15_0_5 DOB[1]
load net {fif\.data_out0[4]} -attr @rip(#000000) DOC[0] -pin {fif\.data_out_reg[4]} D -pin mem_reg_0_15_0_5 DOC[0]
load net {fif\.data_out0[5]} -attr @rip(#000000) DOC[1] -pin {fif\.data_out_reg[5]} D -pin mem_reg_0_15_0_5 DOC[1]
load net {fif\.data_out0[6]} -attr @rip(#000000) DOA[0] -pin {fif\.data_out_reg[6]} D -pin mem_reg_0_15_6_7 DOA[0]
load net {fif\.data_out0[7]} -attr @rip(#000000) DOA[1] -pin {fif\.data_out_reg[7]} D -pin mem_reg_0_15_6_7 DOA[1]
load net {fif\.data_out[0]} -attr @rip(#000000) 0 -port {fif\.data_out[0]} -pin {fif\.data_out[0]_INST_0} O
load net {fif\.data_out[1]} -attr @rip(#000000) 1 -port {fif\.data_out[1]} -pin {fif\.data_out[1]_INST_0} O
load net {fif\.data_out[2]} -attr @rip(#000000) 2 -port {fif\.data_out[2]} -pin {fif\.data_out[2]_INST_0} O
load net {fif\.data_out[3]} -attr @rip(#000000) 3 -port {fif\.data_out[3]} -pin {fif\.data_out[3]_INST_0} O
load net {fif\.data_out[4]} -attr @rip(#000000) 4 -port {fif\.data_out[4]} -pin {fif\.data_out[4]_INST_0} O
load net {fif\.data_out[5]} -attr @rip(#000000) 5 -port {fif\.data_out[5]} -pin {fif\.data_out[5]_INST_0} O
load net {fif\.data_out[6]} -attr @rip(#000000) 6 -port {fif\.data_out[6]} -pin {fif\.data_out[6]_INST_0} O
load net {fif\.data_out[7]} -attr @rip(#000000) 7 -port {fif\.data_out[7]} -pin {fif\.data_out[7]_INST_0} O
load net {fif\.data_out[7]_i_1_n_1} -pin {fif\.data_out[7]_i_1} O -pin {fif\.data_out_reg[0]} CE -pin {fif\.data_out_reg[1]} CE -pin {fif\.data_out_reg[2]} CE -pin {fif\.data_out_reg[3]} CE -pin {fif\.data_out_reg[4]} CE -pin {fif\.data_out_reg[5]} CE -pin {fif\.data_out_reg[6]} CE -pin {fif\.data_out_reg[7]} CE
netloc {fif\.data_out[7]_i_1_n_1} 1 16 1 4030 980n
load net {fif\.data_out_OBUF[0]} -pin {fif\.data_out[0]_INST_0} I -pin {fif\.data_out_reg[0]} Q
netloc {fif\.data_out_OBUF[0]} 1 17 1 N 990
load net {fif\.data_out_OBUF[1]} -pin {fif\.data_out[1]_INST_0} I -pin {fif\.data_out_reg[1]} Q
netloc {fif\.data_out_OBUF[1]} 1 17 1 N 1140
load net {fif\.data_out_OBUF[2]} -pin {fif\.data_out[2]_INST_0} I -pin {fif\.data_out_reg[2]} Q
netloc {fif\.data_out_OBUF[2]} 1 17 1 N 1290
load net {fif\.data_out_OBUF[3]} -pin {fif\.data_out[3]_INST_0} I -pin {fif\.data_out_reg[3]} Q
netloc {fif\.data_out_OBUF[3]} 1 17 1 N 1440
load net {fif\.data_out_OBUF[4]} -pin {fif\.data_out[4]_INST_0} I -pin {fif\.data_out_reg[4]} Q
netloc {fif\.data_out_OBUF[4]} 1 17 1 N 1590
load net {fif\.data_out_OBUF[5]} -pin {fif\.data_out[5]_INST_0} I -pin {fif\.data_out_reg[5]} Q
netloc {fif\.data_out_OBUF[5]} 1 17 1 N 1740
load net {fif\.data_out_OBUF[6]} -pin {fif\.data_out[6]_INST_0} I -pin {fif\.data_out_reg[6]} Q
netloc {fif\.data_out_OBUF[6]} 1 17 1 N 1890
load net {fif\.data_out_OBUF[7]} -pin {fif\.data_out[7]_INST_0} I -pin {fif\.data_out_reg[7]} Q
netloc {fif\.data_out_OBUF[7]} 1 17 1 N 2040
load net {fif\.data_out_reg[7]_i_3_n_1} -pin {fif\.data_out[7]_i_2} I0 -pin {fif\.data_out_reg[7]_i_3} O
netloc {fif\.data_out_reg[7]_i_3_n_1} 1 9 1 NJ 350
load net {fif\.empty} -port {fif\.empty} -pin {fif\.empty_INST_0} O
netloc {fif\.empty} 1 18 1 NJ 720
load net {fif\.empty_INST_0_i_1_n_1} -pin {fif\.empty_INST_0} I -pin {fif\.empty_INST_0_i_1} O
netloc {fif\.empty_INST_0_i_1_n_1} 1 17 1 NJ 720
load net {fif\.full} -port {fif\.full} -pin {fif\.full_INST_0} O
netloc {fif\.full} 1 18 1 NJ 570
load net {fif\.full_INST_0_i_1_n_1} -pin {fif\.full_INST_0} I -pin {fif\.full_INST_0_i_1} O
netloc {fif\.full_INST_0_i_1_n_1} 1 17 1 NJ 570
load net {fif\.rd} -pin {fif\.data_out_reg[7]_i_3} I -port {fif\.rd}
netloc {fif\.rd} 1 0 9 NJ 400 NJ 400 NJ 400 NJ 400 NJ 400 NJ 400 NJ 400 1420J 380 1660J
load net {fif\.rst} -pin cnt_reg[4]_i_1 I -port {fif\.rst}
netloc {fif\.rst} 1 0 2 NJ 630 NJ
load net {fif\.wr} -pin cnt_reg[4]_i_4 I -port {fif\.wr}
netloc {fif\.wr} 1 0 3 NJ 440 NJ 440 NJ
load net mem_reg_0_15_0_5_i_1_n_1 -pin mem_reg_0_15_0_5 WE -pin mem_reg_0_15_0_5_i_1 O -pin mem_reg_0_15_6_7 WE
netloc mem_reg_0_15_0_5_i_1_n_1 1 15 1 3450 1420n
load net mem_reg_0_15_0_5_i_2_n_1 -attr @rip(#000000) 1 -pin mem_reg_0_15_0_5 DIA[1] -pin mem_reg_0_15_0_5_i_2 O
load net mem_reg_0_15_0_5_i_3_n_1 -attr @rip(#000000) 0 -pin mem_reg_0_15_0_5 DIA[0] -pin mem_reg_0_15_0_5_i_3 O
load net mem_reg_0_15_0_5_i_4_n_1 -attr @rip(#000000) 1 -pin mem_reg_0_15_0_5 DIB[1] -pin mem_reg_0_15_0_5_i_4 O
load net mem_reg_0_15_0_5_i_5_n_1 -attr @rip(#000000) 0 -pin mem_reg_0_15_0_5 DIB[0] -pin mem_reg_0_15_0_5_i_5 O
load net mem_reg_0_15_0_5_i_6_n_1 -attr @rip(#000000) 1 -pin mem_reg_0_15_0_5 DIC[1] -pin mem_reg_0_15_0_5_i_6 O
load net mem_reg_0_15_0_5_i_7_n_1 -attr @rip(#000000) 0 -pin mem_reg_0_15_0_5 DIC[0] -pin mem_reg_0_15_0_5_i_7 O
load net mem_reg_0_15_6_7_i_1_n_1 -attr @rip(#000000) 1 -pin mem_reg_0_15_6_7 DIA[1] -pin mem_reg_0_15_6_7_i_1 O
load net mem_reg_0_15_6_7_i_2_n_1 -attr @rip(#000000) 0 -pin mem_reg_0_15_6_7 DIA[0] -pin mem_reg_0_15_6_7_i_2 O
load net n_0_21_BUFG -pin cnt_reg[0] C -pin cnt_reg[1] C -pin cnt_reg[2] C -pin cnt_reg[3] C -pin cnt_reg[4] C -pin {fif\.data_out_reg[0]} C -pin {fif\.data_out_reg[1]} C -pin {fif\.data_out_reg[2]} C -pin {fif\.data_out_reg[3]} C -pin {fif\.data_out_reg[4]} C -pin {fif\.data_out_reg[5]} C -pin {fif\.data_out_reg[6]} C -pin {fif\.data_out_reg[7]} C -pin mem_reg_0_15_0_5 WCLK -pin mem_reg_0_15_6_7 WCLK -pin n_0_21_BUFG_inst O -pin rptr_reg[0] C -pin rptr_reg[1] C -pin rptr_reg[2] C -pin rptr_reg[3] C -pin wptr_reg[0] C -pin wptr_reg[1] C -pin wptr_reg[2] C -pin wptr_reg[3] C
netloc n_0_21_BUFG 1 2 15 430 650 NJ 650 920 660 NJ 660 1300 680 NJ 680 1720 710 NJ 710 NJ 710 2490 830 NJ 830 NJ 830 3070 1380 3470 5020 3990
load net n_0_21_BUFG_inst_n_1 -pin n_0_21_BUFG_inst I -pin n_0_21_BUFG_inst_i_1 O
netloc n_0_21_BUFG_inst_n_1 1 1 1 NJ 490
load net p_0_in[0] -pin wptr[0]_i_1 O -pin wptr_reg[0] D
netloc p_0_in[0] 1 14 1 3110 820n
load net p_0_in[1] -pin wptr[1]_i_1 O -pin wptr_reg[1] D
netloc p_0_in[1] 1 14 1 N 970
load net p_0_in[2] -pin wptr[2]_i_1 O -pin wptr_reg[2] D
netloc p_0_in[2] 1 14 1 N 1150
load net p_0_in[3] -pin wptr[3]_i_2 O -pin wptr_reg[3] D
netloc p_0_in[3] 1 14 1 NJ 1310
load net rptr0 -pin cnt[4]_i_2 I0 -pin {fif\.data_out[7]_i_1} I1 -pin {fif\.data_out[7]_i_2} O -pin rptr[2]_i_1 I0
netloc rptr0 1 10 6 2230 790 NJ 790 NJ 790 2850 630 NJ 630 3570
load net rptr[0] -attr @rip(#000000) 0 -pin mem_reg_0_15_0_5 ADDRA[0] -pin mem_reg_0_15_0_5 ADDRB[0] -pin mem_reg_0_15_0_5 ADDRC[0] -pin mem_reg_0_15_6_7 ADDRA[0] -pin mem_reg_0_15_6_7 ADDRB[0] -pin mem_reg_0_15_6_7 ADDRC[0] -pin rptr[0]_i_1 I0 -pin rptr[1]_i_1 I0 -pin rptr[2]_i_2 I0 -pin rptr[3]_i_1 I1 -pin rptr_reg[0] Q
load net rptr[0]_i_1_n_1 -pin rptr[0]_i_1 O -pin rptr_reg[0] D
netloc rptr[0]_i_1_n_1 1 14 1 N 90
load net rptr[1] -attr @rip(#000000) 1 -pin mem_reg_0_15_0_5 ADDRA[1] -pin mem_reg_0_15_0_5 ADDRB[1] -pin mem_reg_0_15_0_5 ADDRC[1] -pin mem_reg_0_15_6_7 ADDRA[1] -pin mem_reg_0_15_6_7 ADDRB[1] -pin mem_reg_0_15_6_7 ADDRC[1] -pin rptr[1]_i_1 I1 -pin rptr[2]_i_2 I1 -pin rptr[3]_i_1 I0 -pin rptr_reg[1] Q
load net rptr[1]_i_1_n_1 -pin rptr[1]_i_1 O -pin rptr_reg[1] D
netloc rptr[1]_i_1_n_1 1 14 1 3110 220n
load net rptr[2] -attr @rip(#000000) 2 -pin mem_reg_0_15_0_5 ADDRA[2] -pin mem_reg_0_15_0_5 ADDRB[2] -pin mem_reg_0_15_0_5 ADDRC[2] -pin mem_reg_0_15_6_7 ADDRA[2] -pin mem_reg_0_15_6_7 ADDRB[2] -pin mem_reg_0_15_6_7 ADDRC[2] -pin rptr[2]_i_2 I2 -pin rptr[3]_i_1 I2 -pin rptr_reg[2] Q
load net rptr[2]_i_1_n_1 -pin rptr[2]_i_1 O -pin rptr_reg[0] CE -pin rptr_reg[1] CE -pin rptr_reg[2] CE -pin rptr_reg[3] CE
netloc rptr[2]_i_1_n_1 1 14 1 3130 70n
load net rptr[2]_i_2_n_1 -pin rptr[2]_i_2 O -pin rptr_reg[2] D
netloc rptr[2]_i_2_n_1 1 14 1 3030 390n
load net rptr[3] -attr @rip(#000000) 3 -pin mem_reg_0_15_0_5 ADDRA[3] -pin mem_reg_0_15_0_5 ADDRB[3] -pin mem_reg_0_15_0_5 ADDRC[3] -pin mem_reg_0_15_6_7 ADDRA[3] -pin mem_reg_0_15_6_7 ADDRB[3] -pin mem_reg_0_15_6_7 ADDRC[3] -pin rptr[3]_i_1 I3 -pin rptr_reg[3] Q
load net rptr[3]_i_1_n_1 -pin rptr[3]_i_1 O -pin rptr_reg[3] D
netloc rptr[3]_i_1_n_1 1 14 1 3050 330n
load net wptr0 -pin cnt[4]_i_2 I1 -pin {fif\.data_out[7]_i_1} I0 -pin mem_reg_0_15_0_5_i_1 I0 -pin rptr[2]_i_1 I1 -pin wptr[3]_i_1 O -pin wptr_reg[0] CE -pin wptr_reg[1] CE -pin wptr_reg[2] CE -pin wptr_reg[3] CE
netloc wptr0 1 10 6 2310 770 NJ 770 NJ 770 2870 850 3130 1040 3410
load net wptr_reg[0] -attr @rip(#000000) 0 -pin mem_reg_0_15_0_5 ADDRD[0] -pin mem_reg_0_15_6_7 ADDRD[0] -pin wptr[0]_i_1 I0 -pin wptr[1]_i_1 I0 -pin wptr[2]_i_1 I0 -pin wptr[3]_i_2 I1 -pin wptr_reg[0] Q
load net wptr_reg[1] -attr @rip(#000000) 1 -pin mem_reg_0_15_0_5 ADDRD[1] -pin mem_reg_0_15_6_7 ADDRD[1] -pin wptr[1]_i_1 I1 -pin wptr[2]_i_1 I1 -pin wptr[3]_i_2 I0 -pin wptr_reg[1] Q
load net wptr_reg[2] -attr @rip(#000000) 2 -pin mem_reg_0_15_0_5 ADDRD[2] -pin mem_reg_0_15_6_7 ADDRD[2] -pin wptr[2]_i_1 I2 -pin wptr[3]_i_2 I2 -pin wptr_reg[2] Q
load net wptr_reg[3] -attr @rip(#000000) 3 -pin mem_reg_0_15_0_5 ADDRD[3] -pin mem_reg_0_15_6_7 ADDRD[3] -pin wptr[3]_i_2 I3 -pin wptr_reg[3] Q
load net mem_reg_0_15_0_5|ADDRA0 -attr @rip(#000000) ADDRA[0] -attr @name ADDRA0 -hierPin mem_reg_0_15_0_5 ADDRA[0] -pin mem_reg_0_15_0_5|RAMA RADR0 -pin mem_reg_0_15_0_5|RAMA_D1 RADR0
netloc mem_reg_0_15_0_5|ADDRA0 1 0 1 3700 3180n
load net mem_reg_0_15_6_7|ADDRA0 -attr @rip(#000000) ADDRA[0] -attr @name ADDRA0 -hierPin mem_reg_0_15_6_7 ADDRA[0] -pin mem_reg_0_15_6_7|RAMA RADR0 -pin mem_reg_0_15_6_7|RAMA_D1 RADR0
netloc mem_reg_0_15_6_7|ADDRA0 1 0 1 3700 1250n
load net mem_reg_0_15_0_5|ADDRB0 -attr @rip(#000000) ADDRB[0] -attr @name ADDRB0 -hierPin mem_reg_0_15_0_5 ADDRB[0] -pin mem_reg_0_15_0_5|RAMB RADR0 -pin mem_reg_0_15_0_5|RAMB_D1 RADR0
netloc mem_reg_0_15_0_5|ADDRB0 1 0 1 3700 3800n
load net mem_reg_0_15_6_7|ADDRB0 -attr @rip(#000000) ADDRB[0] -attr @name ADDRB0 -hierPin mem_reg_0_15_6_7 ADDRB[0] -pin mem_reg_0_15_6_7|RAMB RADR0 -pin mem_reg_0_15_6_7|RAMB_D1 RADR0
netloc mem_reg_0_15_6_7|ADDRB0 1 0 1 3700 1870n
load net mem_reg_0_15_0_5|ADDRC0 -attr @rip(#000000) ADDRC[0] -attr @name ADDRC0 -hierPin mem_reg_0_15_0_5 ADDRC[0] -pin mem_reg_0_15_0_5|RAMC RADR0 -pin mem_reg_0_15_0_5|RAMC_D1 RADR0
netloc mem_reg_0_15_0_5|ADDRC0 1 0 1 3700 4420n
load net mem_reg_0_15_6_7|ADDRC0 -attr @rip(#000000) ADDRC[0] -attr @name ADDRC0 -hierPin mem_reg_0_15_6_7 ADDRC[0] -pin mem_reg_0_15_6_7|RAMC RADR0 -pin mem_reg_0_15_6_7|RAMC_D1 RADR0
netloc mem_reg_0_15_6_7|ADDRC0 1 0 1 3700 2490n
load netBundle {@fif\.data_in} 8 {fif\.data_in[7]} {fif\.data_in[6]} {fif\.data_in[5]} {fif\.data_in[4]} {fif\.data_in[3]} {fif\.data_in[2]} {fif\.data_in[1]} {fif\.data_in[0]} -autobundled
netbloc {@fif\.data_in} 1 0 15 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 NJ 1510 3090
load netBundle {@fif\.data_out} 8 {fif\.data_out[7]} {fif\.data_out[6]} {fif\.data_out[5]} {fif\.data_out[4]} {fif\.data_out[3]} {fif\.data_out[2]} {fif\.data_out[1]} {fif\.data_out[0]} -autobundled
netbloc {@fif\.data_out} 1 18 1 4480 990n
load netBundle {@fif\.data_out0} 2 {fif\.data_out0[1]} {fif\.data_out0[0]} -autobundled
netbloc {@fif\.data_out0} 1 16 1 3970 1000n
load netBundle {@fif\.data_out0_1} 2 {fif\.data_out0[3]} {fif\.data_out0[2]} -autobundled
netbloc {@fif\.data_out0_1} 1 16 1 4010 1300n
load netBundle {@fif\.data_out0_2} 2 {fif\.data_out0[5]} {fif\.data_out0[4]} -autobundled
netbloc {@fif\.data_out0_2} 1 16 1 4050 1600n
load netBundle {@fif\.data_out0_3} 2 {fif\.data_out0[7]} {fif\.data_out0[6]} -autobundled
netbloc {@fif\.data_out0_3} 1 16 1 3950 1290n
load netBundle @rptr 4 rptr[3] rptr[2] rptr[1] rptr[0] -autobundled
netbloc @rptr 1 13 3 2890 610 NJ 610 3550
load netBundle @wptr_reg 4 wptr_reg[3] wptr_reg[2] wptr_reg[1] wptr_reg[0] -autobundled
netbloc @wptr_reg 1 13 3 2890 1220 NJ 1220 3530
load netBundle @mem_reg_0_15_0_5_i_2_n_ 2 mem_reg_0_15_0_5_i_2_n_1 mem_reg_0_15_0_5_i_3_n_1 -autobundled
netbloc @mem_reg_0_15_0_5_i_2_n_ 1 15 1 3510 1510n
load netBundle @mem_reg_0_15_0_5_i_4_n_ 2 mem_reg_0_15_0_5_i_4_n_1 mem_reg_0_15_0_5_i_5_n_1 -autobundled
netbloc @mem_reg_0_15_0_5_i_4_n_ 1 15 1 3430 1650n
load netBundle @mem_reg_0_15_0_5_i_6_n_ 2 mem_reg_0_15_0_5_i_6_n_1 mem_reg_0_15_0_5_i_7_n_1 -autobundled
netbloc @mem_reg_0_15_0_5_i_6_n_ 1 15 1 3410 1790n
load netBundle @mem_reg_0_15_6_7_i_1_n_ 2 mem_reg_0_15_6_7_i_1_n_1 mem_reg_0_15_6_7_i_2_n_1 -autobundled
netbloc @mem_reg_0_15_6_7_i_1_n_ 1 15 1 3490 1930n
levelinfo -pg 1 0 40 270 530 770 950 1170 1330 1550 1760 2110 2380 2540 2750 2930 3210 3670 4140 4290 4500
levelinfo -hier mem_reg_0_15_0_5 * 3730 *
levelinfo -hier mem_reg_0_15_6_7 * 3730 *
pagesize -pg 1 -db -bbox -sgen -150 0 4660 5030
pagesize -hier mem_reg_0_15_0_5 -db -bbox -sgen 3670 3100 3860 4970
pagesize -hier mem_reg_0_15_6_7 -db -bbox -sgen 3670 1170 3860 3040
show
zoom 0.717936
scrollpos 1638 40
#
# initialize ictrl to current module fifo_top work:fifo_top:NOFILE
ictrl init topinfo |
