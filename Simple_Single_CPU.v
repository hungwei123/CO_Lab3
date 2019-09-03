module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input		clk_i;
input         	rst_n;

//Internal Signles
wire [32-1:0] instruction, pc_i, pc_o, rsData, rtData, rdData;
wire [32-1:0] extended, zeroFilled, rtData_before, aluResult, shifterResult;
wire [5-1:0] writeAddr;
wire [4-1:0] aluOperation;
wire [3-1:0] aluOP;
wire [2-1:0] furSlt;
wire regDst, regWrite, aluSrc, aluZero, aluOverflow, shiftLR;
//modules

Program_Counter PC(      
.clk_i(clk_i),
.rst_n(rst_n),
.pc_in_i(pc_i),   
.pc_out_o(pc_o) 
);
	


Adder Adder1(
.src1_i(pc_o),     
.src2_i(32'd4),
.sum_o(pc_i)    
);
	


Instr_Memory IM(
.pc_addr_i(pc_o),  
 .instr_o(instruction)    
 );



Mux2to1 #(.size(5)) Mux_Write_Reg(
.data0_i(instruction[20:16]),
.data1_i(instruction[15:11]),
.select_i(regDst),
.data_o(writeAddr)
);	
		


Reg_File RF(
.clk_i(clk_i),      
.rst_n(rst_n) ,     
.RSaddr_i(instruction[25:21]),  
.RTaddr_i(instruction[20:16]),  
.RDaddr_i(writeAddr),  // ?
.RDdata_i(rdData), 
.RegWrite_i(regWrite),
.RSdata_o(rsData) ,  
.RTdata_o(rtData_before)          
 );
	


Decoder Decoder(
.instr_op_i(instruction[31:26]), 
.RegWrite_o(regWrite),    
.ALUOp_o(aluOP),   
.ALUSrc_o(aluSrc),   
.RegDst_o(regDst)   		
);



ALU_Ctrl AC(
.funct_i(instruction[5:0]),   
.ALUOp_i(aluOP),   
.ALU_operation_o(aluOperation),
.leftRight_o(shiftLR),
.FURslt_o(furSlt) 
);
	
Sign_Extend SE(
.data_i(instruction[15:0]),
.data_o(extended)
);

Zero_Filled ZF(
.data_i(instruction[15:0]),
.data_o(zeroFilled)     
);
		
Mux2to1 #(.size(32)) ALU_src2Src(
.data0_i(rtData_before),
.data1_i(extended),
.select_i(aluSrc),
.data_o(rtData)
);	
		
ALU ALU(	
.aluSrc1(rsData),
.aluSrc2(rtData),
.ALU_operation_i(aluOperation),	
.result(aluResult),	
.zero(aluZero),	
.overflow(aluOverflow)
);
		
Shifter shifter( 	
.result(shifterResult), 	
.leftRight(shiftLR),	
.shamt(instruction[10:6]),
.sftSrc(rtData) 	
);

Mux3to1 #(.size(32)) 
RDdata_Source(
.data0_i(aluResult),
.data1_i(shifterResult),	
.data2_i(zeroFilled),
.select_i(furSlt),
.data_o(rdData)  
);			


endmodule



