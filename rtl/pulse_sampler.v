module pulse_sampler (
    input clk, rst_n, en, din, arm, soft_rst,
    output armed, ready,
    output [15:0] width, period
);
    wire din_s;
    sync2 u_sync (.clk(clk), .rst_n(rst_n), .din(din), .dout(din_s));
    reg din_d;
    wire rise = din_s & ~din_d;
    wire fall = ~din_s & din_d;
    localparam ST_IDLE=2'd0, ST_WAIT_R=2'd1, ST_HIGH=2'd2, ST_WAIT_P=2'd3;
    reg [1:0] st;
    reg [15:0] wcnt, pcnt, width_q, period_q;
    reg ready_q;
    assign width=width_q; assign period=period_q; assign ready=ready_q;
    assign armed = (st != ST_IDLE);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            din_d<=0; st<=ST_IDLE; wcnt<=0; pcnt<=0; width_q<=0; period_q<=0; ready_q<=0;
        end else begin
            din_d <= din_s;
            if (soft_rst || !en) begin st<=ST_IDLE; ready_q<=0; end
            else case (st)
                ST_IDLE: if (arm) begin ready_q<=0; wcnt<=0; pcnt<=0; st<=ST_WAIT_R; end
                ST_WAIT_R: if (rise) begin wcnt<=1; pcnt<=1; st<=ST_HIGH; end
                ST_HIGH: begin
                    if (wcnt!=16'hFFFF) wcnt<=wcnt+1;
                    if (pcnt!=16'hFFFF) pcnt<=pcnt+1;
                    if (fall) begin width_q<=wcnt; st<=ST_WAIT_P; end
                end
                ST_WAIT_P: begin
                    if (pcnt!=16'hFFFF) pcnt<=pcnt+1;
                    if (rise) begin period_q<=pcnt; ready_q<=1; st<=ST_IDLE; end
                end
                default: st<=ST_IDLE;
            endcase
        end
    end
endmodule
