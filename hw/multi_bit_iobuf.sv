module multi_bit_iobuf #(
  //Size corresponds to the number of buffers
  parameter integer size = 32
) (
    inout wire  [size - 1 : 0] bidirectional, 
    input wire  [size - 1 : 0] data_in,
    output wire [size -1 : 0] data_out,
    input wire  [size - 1 : 0] oe
);

    genvar i;
    generate
        for (i = 0; i <= size - 1; i = i + 1) begin : iobuf_gen
            IOBUF iobuf_inst (
                .IO(bidirectional[i]),
                .I(data_in[i]),
                .O(data_out[i]),
                .T(~oe[i])  // When oe is high, output is enabled; when oe is low, tristate is enabled
            );
        end
    endgenerate

endmodule
