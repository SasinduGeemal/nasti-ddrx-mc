/**
 *
 */

`include "timescale.svh"
`include "defines.svh"
`include "enums.svh"
`include "functions.svh"
`include "structs.svh"

module afifo #(
    C_DATA_WIDTH = 0,
    C_ADDR_WIDTH = 0
) (
    input  [C_DATA_WIDTH-1:0] wdata ,
    output                    wfull ,
    input                     wren  ,
    input                     wclk  ,
    input                     wrstn ,
    output [C_DATA_WIDTH-1:0] rdata ,
    output                    rempty,
    input                     rden  ,
    input                     rclk  ,
    input                     rrstn
);

    localparam upper = ceild(C_DATA_WIDTH, 72);

    logic rst;
    assign rst = ~ (rrstn & wrstn);

    logic inhibit;

    logic [upper-1:0] rempty_i;
    logic [upper-1:0] wfull_i ;

    assign rempty = inhibit | |rempty_i;
    assign wfull  = inhibit | |wfull_i;

    logic [upper-1:0][71:0] rdata_mapped;
    logic [upper-1:0][71:0] wdata_mapped;

    logic [3:0] rst_counter;

    always_ff @(posedge rclk or negedge rrstn) begin : proc_inhibit
        if(~rrstn) begin
            rst_counter <= 0;
            inhibit     <= 1;
        end else begin
            if(4 == rst_counter) begin
                rst_counter <= rst_counter;
                inhibit     <= 0;
            end else begin
                rst_counter <= rst_counter + 1;
                inhibit     <= 1;
            end
        end
    end

    generate
        for (genvar i = 0; i < C_DATA_WIDTH; i++) begin : gen_map
            assign rdata[i] = rdata_mapped[i/72][i%72];
            assign wdata_mapped[i/72][i%72] = wdata[i];
        end
    endgenerate

    generate
        for (genvar i = 0; i < upper; i++) begin : gen_fifo
            FIFO_DUALCLOCK_MACRO #(
                .ALMOST_EMPTY_OFFSET    (9'h080   ), // Sets the almost empty threshold
                .ALMOST_FULL_OFFSET     (9'h080   ), // Sets almost full threshold
                .DATA_WIDTH             (72       ), // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
                .DEVICE                 ("7SERIES"), // Target device: "7SERIES"
                .FIFO_SIZE              ("36Kb"   ), // Target BRAM: "18Kb" or "36Kb"
                .FIRST_WORD_FALL_THROUGH("TRUE"   )  // Sets the FIFO FWFT to "TRUE" or "FALSE"
            ) FIFO_DUALCLOCK_MACRO_inst (
                .ALMOSTEMPTY(               ), // 1-bit output almost empty
                .ALMOSTFULL (               ), // 1-bit output almost full
                .DO         (rdata_mapped[i]), // Output data, width defined by DATA_WIDTH parameter
                .EMPTY      (rempty_i[i]    ), // 1-bit output empty
                .FULL       (wfull_i[i]     ), // 1-bit output full
                .RDCOUNT    (               ), // Output read count, width determined by FIFO depth
                .RDERR      (               ), // 1-bit output read error
                .WRCOUNT    (               ), // Output write count, width determined by FIFO depth
                .WRERR      (               ), // 1-bit output write error
                .DI         (wdata_mapped[i]), // Input data, width defined by DATA_WIDTH parameter
                .RDCLK      (rclk           ), // 1-bit input read clock
                .RDEN       (rden & ~rst    ), // 1-bit input read enable
                .RST        (rst            ), // 1-bit input reset
                .WRCLK      (wclk           ), // 1-bit input write clock
                .WREN       (wren & ~rst    )  // 1-bit input write enable
            );
        end
    endgenerate

endmodule // afifo
