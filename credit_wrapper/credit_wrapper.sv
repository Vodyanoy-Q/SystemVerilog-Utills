module credit_wrapper #(
    parameter CREDIT         = 8,
    parameter UP_DATA_SIZE   = 8,
    parameter DOWN_DATA_SIZE = 16
)(
    input  logic                        clk,
    input  logic                        rst,
    input  logic   [UP_DATA_SIZE - 1:0] up_data,
    input  logic                        up_valid,
    output logic                        up_ready,
    output logic [DOWN_DATA_SIZE - 1:0] down_data,
    output logic                        down_valid,
    input  logic                        down_ready,
    output logic   [UP_DATA_SIZE - 1:0] pipeline_data_in,
    output logic                        pipeline_valid_in,
    input  logic [DOWN_DATA_SIZE - 1:0] pipeline_data_out,
    input  logic                        pipeline_valid_out
);
    // ==================== PARAMETERS ====================

    localparam CNT_WIDTH = $clog2(CREDIT + 1);

    // ==================== SIGNALS ====================

    logic      [CNT_WIDTH - 1:0] credit_cnt;

    // ---------- Handshakes ----------
    logic                        up_handshake;
    logic                        down_handshake;

    // ---------- FIFO ----------
    logic [DOWN_DATA_SIZE - 1:0] fifo_read_data;
    logic                        fifo_is_empty;
    logic                        fifo_is_full;
    logic                        bypass;

    // ==================== FIFO INITIALIZATION ====================

    fifo # (
        .WIDTH ( DOWN_DATA_SIZE ),
        .DEPTH ( CREDIT         )
    ) credit_fifo (
        .clk        ( clk                ),
        .rst        ( rst                ),
        .push       ( pipeline_valid_out ),
        .pop        ( down_handshake     ),
        .write_data ( pipeline_data_out  ),
        .read_data  ( down_data          ),
        .is_empty   ( fifo_is_empty      ),
        .is_full    ( fifo_is_full       )     
    );

    // ==================== UP_READY LOGIC ====================

    assign up_ready = ( credit_cnt != 0 ) || ( down_handshake );

    // ==================== HANDSHAKE LOGIC ====================

    assign up_handshake   =   up_ready && up_valid;
    assign down_handshake = down_valid && down_ready;

    // ==================== DOWNSTREAM LOGIC ====================

    assign bypass     = fifo_is_empty && down_ready;
    assign down_valid = bypass ? pipeline_valid_out : ~ fifo_is_empty;

    // ==================== CREDIT COUNTER LOGIC ====================
    
    always_ff @( posedge clk or posedge rst )
        if ( rst )
            credit_cnt <= CREDIT;
        else if ( up_handshake && down_handshake )
            credit_cnt <= credit_cnt;
        else if ( up_handshake )
            credit_cnt <= credit_cnt - 1;
        else if ( down_handshake )
            credit_cnt <= credit_cnt + 1;
        else
            credit_cnt <= credit_cnt;

    // ==================== PIPELINE_IN LOGIC ====================

    assign pipeline_data_in  = up_data;
    assign pipeline_valid_in = up_handshake;

endmodule