module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
)(
    input logic                clk,
    input logic                rst,
    input logic                push,
    input logic                pop,
    input logic  [WIDTH - 1:0] write_data,

    output logic [WIDTH - 1:0] read_data,
    output logic               is_empty,
    output logic               is_full
);
    // ==================== PARAMETERS ====================

    localparam PTR_WIDTH = $clog2(DEPTH);
    localparam MAX_PTR   = PTR_WIDTH'(DEPTH - 1);

    // ==================== SIGNALS ====================

    logic          [PTR_WIDTH - 1:0] write_ptr; 
    logic          [PTR_WIDTH - 1:0] read_ptr;
    logic                            write_odd;
    logic                            read_odd;
    logic [DEPTH - 1:0][WIDTH - 1:0] data; 
    logic                            bypass;

    // ==================== BYPASS LOGIC ====================

    assign bypass = is_empty && push && pop;

    // ==================== WRITE LOGIC ====================

    always_ff @( posedge clk or posedge rst )
        if ( rst ) begin
            write_odd  <= '0;
            write_ptr  <= '0;
        end
        else if ( bypass ) begin end
        else if ( push ) begin   
            if ( write_ptr == MAX_PTR ) begin
                write_ptr <= '0;
                write_odd <= ~ write_odd;
            end
            else begin
                write_ptr <= write_ptr + 1;
            end
        end

    // ==================== READ LOGIC ====================

    always_ff @( posedge clk or posedge rst )
        if ( rst ) begin
            read_odd  <= '0;
            read_ptr  <= '0;
        end
        else if ( bypass ) begin end
        else if ( pop ) begin   
            if ( read_ptr == MAX_PTR ) begin
                read_ptr <= '0;
                read_odd <= ~ read_odd;
            end
            else begin
                read_ptr <= read_ptr + 1;
            end
        end

    // ==================== FULL LOGIC ====================

    assign is_full  = ( read_ptr == write_ptr ) & ( read_odd != write_odd );

    // ==================== EMPTY LOGIC ====================
    
    assign is_empty = ( read_ptr == write_ptr ) & ( read_odd == write_odd );

    // ==================== WRITE DATA LOGIC ====================

    always_ff @( posedge clk )
        if ( bypass ) begin end
        else if ( push )
            data [write_ptr] <= write_data;

    // ==================== READ DATA LOGIC ====================

    assign read_data = bypass ? write_data : data [read_ptr];
    
endmodule       