//
//  Author: Prof. Taeweon Suh
//          Computer Science & Engineering
//          Korea University
//  Date: July 14, 2020
//  Description: Skeleton design of RV32I Single-cycle CPU
//

`timescale 1ns/1ns
`define simdelay 1

module rv32i_cpu (
		      input         clk, reset,
            output [31:0] pc,		  		// program counter for instruction fetch
            input  [31:0] inst, 			// incoming instruction
            output        Memwrite, 	// 'memory write' control signal
            output [31:0] Memaddr,  	// memory address 
            output [31:0] MemWdata, 	// data to write to memory
            input  [31:0] MemRdata); 	// data read from memory

  wire        auipc, lui;
  wire        alusrc, regwrite;
  wire [4:0]  alucontrol;
  wire        memtoreg, memwrite;
  wire        branch, jal, jalr;

  assign Memwrite = memwrite ;

  // Instantiate Controller
  controller i_controller(
      .opcode		(inst[6:0]), 
		.funct7		(inst[31:25]), 
		.funct3		(inst[14:12]), 
		.auipc		(auipc),
		.lui			(lui),
		.memtoreg	(memtoreg),
		.memwrite	(memwrite),
		.branch		(branch),
		.alusrc		(alusrc),
		.regwrite	(regwrite),
		.jal			(jal),
		.jalr			(jalr),
		.alucontrol	(alucontrol));

  // Instantiate Datapath
  datapath i_datapath(
		.clk				(clk),
		.reset			(reset),
		.auipc			(auipc),
		.lui				(lui),
		.memtoreg		(memtoreg),
		.memwrite		(memwrite),
		.branch			(branch),
		.alusrc			(alusrc),
		.regwrite		(regwrite),
		.jal				(jal),
		.jalr				(jalr),
		.alucontrol		(alucontrol),
		.pc				(pc),
		.inst				(inst),
		.aluout			(Memaddr), 
		.MemWdata		(MemWdata),
		.MemRdata		(MemRdata));

endmodule


//
// Instruction Decoder 
// to generate control signals for datapath
//
module controller(input  [6:0] opcode,
                  input  [6:0] funct7,
                  input  [2:0] funct3,
                  output       auipc,
                  output       lui,
                  output       alusrc,
                  output [4:0] alucontrol,
                  output       branch,
                  output       jal,
                  output       jalr,
                  output       memtoreg,
                  output       memwrite,
                  output       regwrite);

	maindec i_maindec(
		.opcode		(opcode),
		.auipc		(auipc),
		.lui			(lui),
		.memtoreg	(memtoreg),
		.memwrite	(memwrite),
		.branch		(branch),
		.alusrc		(alusrc),
		.regwrite	(regwrite),
		.jal			(jal),
		.jalr			(jalr));

	aludec i_aludec( 
		.opcode     (opcode),
		.funct7     (funct7),
		.funct3     (funct3),
		.alucontrol (alucontrol));


endmodule


//
// RV32I Opcode map = Inst[6:0]
//
`define OP_R			7'b0110011
`define OP_I_ARITH	7'b0010011
`define OP_I_LOAD  	7'b0000011
`define OP_I_JALR  	7'b1100111
`define OP_S			7'b0100011
`define OP_B			7'b1100011
`define OP_U_LUI		7'b0110111
`define OP_J_JAL		7'b1101111


//
// Main decoder generates all control signals except alucontrol 
//
//
module maindec(input  [6:0] opcode,
               output       auipc,
               output       lui,
               output       regwrite,
               output       alusrc,
               output       memtoreg, memwrite,
               output       branch, 
               output       jal,
               output       jalr);

  reg [8:0] controls;

  assign {auipc, lui, regwrite, alusrc, 
			 memtoreg, memwrite, branch, jal, 
			 jalr} = controls;

  always @(*)
  begin
    case(opcode)
      `OP_R: 			controls <= #`simdelay 9'b0010_0000_0; // R-type
      `OP_I_ARITH: 	controls <= #`simdelay 9'b0011_0000_0; // I-type Arithmetic
      `OP_I_LOAD: 	controls <= #`simdelay 9'b0011_1000_0; // I-type Load
		  `OP_I_JALR:    controls <= #`simdelay 9'b0011_0000_1; // JALR
      `OP_S: 			controls <= #`simdelay 9'b0001_0100_0; // S-type Store
      `OP_B: 			controls <= #`simdelay 9'b0000_0010_0; // B-type Branch
      `OP_U_LUI: 		controls <= #`simdelay 9'b0111_0000_0; // LUI
      `OP_J_JAL: 		controls <= #`simdelay 9'b0011_0001_0; // JAL
      default:    	controls <= #`simdelay 9'b0000_0000_0; // ???
    endcase
  end

endmodule

//
// ALU decoder generates ALU control signal (alucontrol)
//
module aludec(input      [6:0] opcode,
              input      [6:0] funct7,
              input      [2:0] funct3,
              output reg [4:0] alucontrol);

  always @(*) begin
    case(opcode)
      `OP_R: begin  		// R-type
        case({funct7,funct3})
        10'b0000000_000: alucontrol <= #`simdelay 5'b00000; // addition (add)
        10'b0100000_000: alucontrol <= #`simdelay 5'b10000; // subtraction (sub)
        10'b0000000_001: alucontrol <= #`simdelay 5'b00100; // shift-left logical (sll)
        10'b0000000_010: alucontrol <= #`simdelay 5'b10111; // set less than (slt)
        10'b0000000_011: alucontrol <= #`simdelay 5'b11000; // set less than unsigned (sltu)
        10'b0000000_100: alucontrol <= #`simdelay 5'b00011; // xor (xor)
        10'b0000000_101: alucontrol <= #`simdelay 5'b00101; // shift-right logical (srl)
        10'b0100000_101: alucontrol <= #`simdelay 5'b00110; // shift-right arithmetic (sra)
        10'b0000000_110: alucontrol <= #`simdelay 5'b00010; // or (or)
        10'b0000000_111: alucontrol <= #`simdelay 5'b00001; // and (and)
        default:         alucontrol <= #`simdelay 5'bxxxxx; // ???
        endcase
		  end
      `OP_I_ARITH: begin  // I-type Arithmetic
        case(funct3)
        // 3'b000:  alucontrol <= #`simdelay 5'b00000; // addition (addi)
        // 3'b110:  alucontrol <= #`simdelay 5'b00010; // or (ori)
        // 3'b111:  alucontrol <= #`simdelay 5'b00001; // and (andi)
        // 3'b100:  alucontrol <= #`simdelay 5'b00100; // xor (xori)
        3'b000:  alucontrol <= #`simdelay 5'b00000; // addi (=add)
        3'b001:  alucontrol <= #`simdelay 5'b00100; // slli (=sll)
        3'b010:  alucontrol <= #`simdelay 5'b10111; // slti (=slt)
        3'b011:  alucontrol <= #`simdelay 5'b11000; // sltiu (=sltu)
        3'b100:  alucontrol <= #`simdelay 5'b00011; // xori (=xor)
        3'b101:  alucontrol <= #`simdelay 5'b00101; // srli (=srl)
        3'b101:  alucontrol <= #`simdelay 5'b00110; // srai (=sra)
        3'b110:  alucontrol <= #`simdelay 5'b00010; // or (ori)
        3'b111:  alucontrol <= #`simdelay 5'b00001; // and (andi)
        default: alucontrol <= #`simdelay 5'bxxxxx; // ???
        endcase
		  end
      `OP_I_JALR  : alucontrol <= #`simdelay 5'b00000;  // addition
      `OP_I_LOAD  : alucontrol <= #`simdelay 5'b00000;  // addition
      `OP_B       : alucontrol <= #`simdelay 5'b10000;  // B-type Branch (BEQ, BNE, ...) : subtraction 
      `OP_S       : alucontrol <= #`simdelay 5'b00000;  // S-type Store (SW, SH, SB) : addition    	
      `OP_U_LUI   : alucontrol <= #`simdelay 5'b00000;  // U-type (LUI) : addition
      default     : alucontrol <= #`simdelay 5'b00000;  // 
    endcase
  end
endmodule


//
// CPU datapath
//
module datapath(input         clk, reset,
                input  [31:0] inst,
                input         auipc,
                input         lui,
                input         regwrite,
                input         memtoreg,
                input         memwrite,
                input         alusrc, 
                input  [4:0]  alucontrol,
                input         branch,
                input         jal,
                input         jalr,

                output reg [31:0] pc,
                output [31:0] aluout,
                output [31:0] MemWdata,
                input  [31:0] MemRdata);

  wire [4:0]  rs1, rs2, rd;
  wire [2:0]  funct3;
  wire [31:0] rs1_data, rs2_data;
  reg  [31:0] rd_data;
  wire [20:1] jal_imm;
  wire [31:0] se_jal_imm;
  wire [12:1] br_imm;
  wire [31:0] se_br_imm;
  wire [31:0] se_imm_itype;
  wire [31:0] se_imm_stype;
  wire [31:0] auipc_lui_imm;
  reg  [31:0] alusrc1;
  reg  [31:0] alusrc2;
  wire [31:0] branch_dest, jal_dest;
  wire		  Nflag, Zflag, Cflag, Vflag;
  wire		  f3beq, f3blt;
  wire		  beq_taken;
  wire		  blt_taken;

  //HDU
  reg stall = 0;
  always@(*) begin
  	if((memtoreg == 1) & ((IDEX_rd == rs1) | (IDEX_rd == rs2))) stall = 1;
	  else stall = 0;
  end

  //IF-ID FF
  reg [31:0]  IFID_pc, IFID_inst;
  always @(*) begin
    if (stall) begin
      IFID_pc[31:0]   <= #`simdelay pc;
      //?????? stall ?????? ??????
      IFID_inst[31:0] <= #`simdelay IFID_inst;
    end
    else begin
      IFID_pc[31:0]   <= #`simdelay pc;
      //?????? stall ?????? ??????
      IFID_inst[31:0] <= #`simdelay inst;
    end
  end
  
  assign rs1     = IFID_inst[19:15];
  assign rs2     = IFID_inst[24:20];
  assign rd      = IFID_inst[11:7];
  assign funct3  = IFID_inst[14:12];

  //ID-EX FF
  reg [31:0]  IDEX_pc;
  reg [4:0]   IDEX_rd, IDEX_rs1, IDEX_rs2;
  reg [31:0]  IDEX_rs1_data, IDEX_rs2_data;
  reg [2:0]   IDEX_funct3;
  reg [31:0]  IDEX_se_imm_itype, IDEX_se_imm_stype, IDEX_se_auipc_lui_imm, IDEX_se_br_imm, IDEX_se_jal_imm;
  
  reg 		    IDEX_auipc, IDEX_lui;
  reg 		    IDEX_alusrc, IDEX_regwrite;
  reg [4:0]   IDEX_alucontrol;
  reg         IDEX_memtoreg, IDEX_memwrite;
  reg         IDEX_branch, IDEX_jal, IDEX_jalr;

  always @(*) begin
    if (stall) begin
      IDEX_pc[31:0]     <= #`simdelay IFID_pc;

      IDEX_rd[4:0]      <= #`simdelay rd;
      IDEX_funct3[2:0]  <= #`simdelay funct3;
      IDEX_rs1[4:0]     <= #`simdelay rs1;
      IDEX_rs2[4:0]     <= #`simdelay rs2;

      IDEX_se_imm_itype[31:0]     <= #`simdelay se_imm_itype[31:0];
      IDEX_se_imm_stype[31:0]     <= #`simdelay se_imm_stype[31:0];
      IDEX_se_auipc_lui_imm[31:0] <= #`simdelay auipc_lui_imm[31:0];
      IDEX_se_br_imm[31:0]        <= #`simdelay se_br_imm;
      IDEX_se_jal_imm[31:0]       <= #`simdelay se_jal_imm;

      //?????? stall ?????? ??????
      IDEX_auipc      <= #`simdelay 0;
      IDEX_lui        <= #`simdelay 0;
      IDEX_alusrc     <= #`simdelay 0;
      IDEX_regwrite   <= #`simdelay 0;
      IDEX_alucontrol <= #`simdelay 0;
      IDEX_memtoreg   <= #`simdelay 0;
      IDEX_memwrite   <= #`simdelay 0;
      IDEX_branch     <= #`simdelay 0;
      IDEX_jal        <= #`simdelay 0;
      IDEX_jalr       <= #`simdelay 0;
    end
    else begin
      IDEX_pc[31:0]     <= #`simdelay IFID_pc;

      IDEX_rd[4:0]      <= #`simdelay rd;
      IDEX_funct3[2:0]  <= #`simdelay funct3;
      IDEX_rs1[4:0]     <= #`simdelay rs1;
      IDEX_rs2[4:0]     <= #`simdelay rs2;

      IDEX_se_imm_itype[31:0]     <= #`simdelay se_imm_itype[31:0];
      IDEX_se_imm_stype[31:0]     <= #`simdelay se_imm_stype[31:0];
      IDEX_se_auipc_lui_imm[31:0] <= #`simdelay auipc_lui_imm[31:0];
      IDEX_se_br_imm[31:0]        <= #`simdelay se_br_imm;
      IDEX_se_jal_imm[31:0]       <= #`simdelay se_jal_imm;

      //?????? stall ?????? ??????
      IDEX_auipc      <= #`simdelay auipc;
      IDEX_lui        <= #`simdelay lui;
      IDEX_alusrc     <= #`simdelay alusrc;
      IDEX_regwrite   <= #`simdelay regwrite;
      IDEX_alucontrol <= #`simdelay alucontrol;
      IDEX_memtoreg   <= #`simdelay memtoreg;
      IDEX_memwrite   <= #`simdelay memwrite;
      IDEX_branch     <= #`simdelay branch;
      IDEX_jal        <= #`simdelay jal;
      IDEX_jalr       <= #`simdelay jalr;
    end
  end

  //dataforwarding
  always @(posedge clk, posedge reset) begin
    //if ((MEMWB_rd == rs1) & MEMWB_regwrite & (MEMWB_rd !=0))  IDEX_rs1_data[31:0] <= #`simdelay rd_data[31:0];
		//else
    IDEX_rs1_data[31:0] <= #`simdelay rs1_data[31:0];
  end

  always @(posedge clk, posedge reset) begin
    //if ((MEMWB_rd == rs2) & MEMWB_regwrite & (MEMWB_rd !=0))  IDEX_rs2_data[31:0] <= #`simdelay rd_data[31:0];
    //else 
    IDEX_rs2_data[31:0] <= #`simdelay rs2_data[31:0]; 
  end

  //EX-MEM FF
  reg [31:0]  EXMEM_pc, EXMEM_aluout;
  reg [4:0]   EXMEM_rd, EXMEM_rs2;
  reg [2:0]   EXMEM_funct3;

  reg [31:0]  EXMEM_rs2_data;

  reg         EXMEM_Nflag, EXMEM_Zflag, EXMEM_Cflag, EXMEM_Vflag;
  reg         EXMEM_memwrite, EXMEM_branch, EXMEM_jal, EXMEM_jalr;
  reg         EXMEM_memtoreg, EXMEM_regwrite;
  reg [31:0]  EXMEM_branch_dest, EXMEM_jal_dest, EXMEM_jalr_dest;

  always @(posedge clk, posedge reset) begin
    EXMEM_pc[31:0]     <= #`simdelay IDEX_pc[31:0];
	  EXMEM_rd[4:0]      <= #`simdelay IDEX_rd[4:0];
	  EXMEM_rs2[4:0]     <= #`simdelay IDEX_rs2[4:0];
	  EXMEM_funct3[2:0]  <= #`simdelay IDEX_funct3[2:0];
	  EXMEM_aluout[31:0] <= #`simdelay aluout[31:0];

    EXMEM_Nflag <= #`simdelay Nflag;
	  EXMEM_Zflag <= #`simdelay Zflag;
	  EXMEM_Cflag <= #`simdelay Cflag;
	  EXMEM_Vflag <= #`simdelay Vflag;
	  EXMEM_memwrite <= #`simdelay IDEX_memwrite;
	  EXMEM_branch <= #`simdelay branch;
	  EXMEM_jal <= #`simdelay jal;
	  EXMEM_jalr <= #`simdelay jalr;
	  EXMEM_memtoreg <= #`simdelay memtoreg;
	  EXMEM_regwrite <= #`simdelay regwrite;
	  EXMEM_branch_dest <= #`simdelay branch_dest;
	  EXMEM_jal_dest <= #`simdelay jal_dest;
  end

  // (sw) EXMEM_rs2_data forwarding
  always @(posedge clk, posedge reset) begin
    //if ((EXMEM_rd == IDEX_rs2) & (memwrite == 1)) EXMEM_rs2_data[31:0] <= #`simdelay EXMEM_aluout[31:0];
    //else if ((MEMWB_rd == IDEX_rs2) & (memwrite == 1)) EXMEM_rs2_data[31:0] <= #`simdelay rd_data[31:0];
    //else
    EXMEM_rs2_data[31:0] <= #`simdelay IDEX_rs2_data[31:0];
  end

  //MEM WB FF
  reg [31:0]  MEMWB_aluout;
  reg [4:0]   MEMWB_rd;
  reg [31:0]  MEMWB_MemRdata;
  reg         MEMWB_memtoreg, MEMWB_regwrite;

  always @(posedge clk, posedge reset) begin
	  MEMWB_rd[4:0]         <= #`simdelay EXMEM_rd[4:0];
	  MEMWB_aluout[31:0]    <= #`simdelay EXMEM_aluout[31:0];
	  MEMWB_MemRdata[31:0]  <= #`simdelay MemRdata[31:0];
	  MEMWB_memtoreg        <= #`simdelay EXMEM_memtoreg;
	  MEMWB_regwrite        <= #`simdelay EXMEM_regwrite;
  end

  //
  // PC (Program Counter) logic 
  //
  assign f3beq    = (EXMEM_funct3 == 3'b000);
  assign f3bne    = (EXMEM_funct3 == 3'b001);
  assign f3blt    = (EXMEM_funct3 == 3'b100);
  assign f3bge    = (EXMEM_funct3 == 3'b101);
  assign f3bltu   = (EXMEM_funct3 == 3'b110);
  assign f3bgeu   = (EXMEM_funct3 == 3'b111);

  assign beq_taken  =  EXMEM_branch & f3beq & EXMEM_Zflag;
  assign bne_taken  =  EXMEM_branch & f3bne & ~EXMEM_Zflag;
  assign blt_taken  =  EXMEM_branch & f3blt & (EXMEM_Nflag != EXMEM_Vflag);
  assign bge_taken  =  EXMEM_branch & f3bge & (EXMEM_Nflag == EXMEM_Vflag);
  assign bltu_taken =  EXMEM_branch & f3bltu & ~EXMEM_Cflag;
  assign bgeu_taken =  EXMEM_branch & f3bgeu & EXMEM_Cflag;
 
  assign branch_dest = (IDEX_pc + IDEX_se_br_imm);
  assign jal_dest 	 = (IDEX_pc + IDEX_se_jal_imm);
  assign jalr_dest   = (aluout);

  always @(posedge clk, posedge reset)
  begin
     if (reset)  pc <= 32'b0;
	  else 
	  begin
        if (stall) pc <= #`simdelay pc;
	      else if (beq_taken | bne_taken | blt_taken | bge_taken | bltu_taken | bgeu_taken) // branch_taken
				pc <= #`simdelay EXMEM_branch_dest;
		    else if (EXMEM_jal) // jal
				pc <= #`simdelay EXMEM_jal_dest;
			  else if (EXMEM_jalr) // jalr
				pc <= #`simdelay EXMEM_jalr_dest;
		    else 
				pc <= #`simdelay (pc + 4);
	  end
  end


  // JAL immediate
  assign jal_imm[20:1] = {IFID_inst[31],IFID_inst[19:12],IFID_inst[20],IFID_inst[30:21]};
  assign se_jal_imm[31:0] = {{11{jal_imm[20]}},jal_imm[20:1],1'b0};

  // Branch immediate
  assign br_imm[12:1] = {IFID_inst[31],IFID_inst[7],IFID_inst[30:25],IFID_inst[11:8]};
  assign se_br_imm[31:0] = {{19{br_imm[12]}},br_imm[12:1],1'b0};



  // 
  // Register File 
  //
  regfile i_regfile(
    .clk			(clk),
    .we			  (MEMWB_regwrite),
    .rs1			(rs1),
    .rs2			(rs2),
    .rd			  (MEMWB_rd),
    .rd_data	(rd_data),
    .rs1_data	(rs1_data),
    .rs2_data	(rs2_data));


	assign MemWdata = EXMEM_rs2_data;


	//
	// ALU 
	//
	alu i_alu(
		.a			(alusrc1),
		.b			(alusrc2),
		.alucont	(alucontrol),
		.result	(aluout),
		.N			(Nflag),
		.Z			(Zflag),
		.C			(Cflag),
		.V			(Vflag));

	// 1st source to ALU (alusrc1)
	always@(*)
	begin
		if      (auipc)	  alusrc1[31:0]    =  IDEX_pc;
		else if (lui) 		alusrc1[31:0]  =  32'b0;
		else          		alusrc1[31:0]  =  IDEX_rs1_data[31:0];
	end
	
	// 2nd source to ALU (alusrc2)
	always@(*)
	begin
		if	     (auipc | lui)			alusrc2[31:0] = IDEX_se_auipc_lui_imm[31:0];
		else if (alusrc & memwrite)	alusrc2[31:0] = IDEX_se_imm_stype[31:0];
		else if (alusrc)					  alusrc2[31:0] = IDEX_se_imm_itype[31:0];
		else								      	alusrc2[31:0] = IDEX_rs2_data[31:0];
	end
	
	assign se_imm_itype[31:0]   = {{20{IFID_inst[31]}},IFID_inst[31:20]};
	assign se_imm_stype[31:0]   = {{20{IFID_inst[31]}},IFID_inst[31:25],IFID_inst[11:7]};
	assign auipc_lui_imm[31:0]  = {IFID_inst[31:12],12'b0};


	// Data selection for writing to RF
	always@(*)
	begin
		if	     (jal)			rd_data[31:0] = EXMEM_pc + 4;
		else if (memtoreg)	rd_data[31:0] = MEMWB_MemRdata;
		else						    rd_data[31:0] = EXMEM_aluout;
	end
	
endmodule
