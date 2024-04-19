`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zuerich
// Engineer: Illian Gruenberg
// 
// Create Date: 03/14/2024 05:34:34 PM
// Design Name: 
// Module Name: axi_snoop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module cycle_latency #(
parameter type axi_mst_req_t = logic,
parameter type axi_mst_rsp_t = logic,
parameter type axi_slv_req_t = logic,
parameter type axi_slv_rsp_t = logic

)(  
    input rst_ni,
    input clk_i,
    input axi_mst_req_t  axi_mst_req_i,
    input axi_mst_rsp_t  axi_mst_rsp_i,
    input axi_slv_req_t  axi_slv_req_o,
    input axi_slv_req_t  axi_slv_rsp_o

    );
      
    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [31:0] counter_reg_q ;
    logic [31:0] counter_reg_d ;
    (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [31:0] counter_stall_q ;
    logic [31:0] counter_stall_d ;
    
    initial begin
      counter_reg_q = 32'b0;
      counter_reg_d = 32'b0;
      counter_stall_q = 32'b0;
      counter_stall_d = 32'b0;
    end
    
    
    always_ff @(posedge clk_i) begin
            if (axi_mst_rsp_i.r_valid & axi_mst_req_i.r_ready) begin
                counter_reg_q <= counter_reg_d + 1;
                counter_reg_d <= counter_reg_q;
            end
       
            if (axi_mst_rsp_i.b_valid & axi_mst_req_i.b_ready) begin
                counter_reg_q <= counter_reg_d + 1;
                counter_reg_d <= counter_reg_q;
            end

            if (!rst_ni)begin
            counter_reg_d <= 0;
            counter_reg_q <= 0;
            end
    end

    always_ff @(posedge clk_i) begin
            if ((axi_mst_rsp_i.r_valid && !axi_mst_req_i.r_ready)) begin
                counter_stall_q <= counter_stall_d + 1;
                counter_stall_d <= counter_stall_q;
            end
       
            if ((axi_mst_rsp_i.b_valid && !axi_mst_req_i.b_ready)) begin
                counter_stall_q <= counter_stall_d + 1;
                counter_stall_d <= counter_stall_q;
            end

            if (!rst_ni)begin
            counter_stall_d <= 0;
            counter_stall_q <= 0;
            end
    end
endmodule