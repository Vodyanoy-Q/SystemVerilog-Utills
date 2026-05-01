module test_pipeline # (
    parameter DATA_IN_WIDTH  = 8,
    parameter DATA_OUT_WIDTH = 4,
    parameter LATENCY        = 4
)(
    input  logic                       clk,
    input  logic                       rst,
    input  logic [DATA_IN_WIDTH - 1:0] data_in,
    input  logic                       valid_in,

    output logic [DATA_OUT_WIDTH - 1:0] data_out,
    output logic                        valid_out
);
    // ==================== SIGNALS ====================

    logic [LATENCY - 1:0] valid_ff;
    logic [DATA_OUT_WIDTH - 1:0] data_ff [LATENCY - 1:0];

    // ==================== VALID LOGIC ====================

    always_ff @( posedge clk or posedge rst ) 
        if ( rst )
            valid_ff <= '0;
        else
            valid_ff <= { valid_ff[LATENCY - 2:0], valid_in };

    assign valid_out = valid_ff[LATENCY - 1];
    
    // ==================== DATA LOGIC ====================
    
    always_ff @( posedge clk ) begin
        data_ff[LATENCY - 1] <= data_in * 2;
        for ( int i = LATENCY - 1; i > 0; i = i - 1 )
            data_ff[i - 1] <= data_ff[i];
    end

    assign data_out = data_ff[0];

endmodule;